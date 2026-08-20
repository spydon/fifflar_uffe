-- Online highscore list.
--
-- Clients are anonymous auth users (role "authenticated" with the
-- is_anonymous claim). They never touch the tables directly: row level
-- security is enabled without policies and all access goes through the
-- security definer functions below. Every function returns a jsonb object
-- with an "ok" flag so that rejected runs can be flagged inside the same
-- committed transaction.
--
-- The server replays each run from sequence numbered progress reports and
-- only accepts state transitions the real game can produce, using the same
-- economy rules as lib/model/economy.dart:
--   price of the n:th copy of a skill  = ceil(base_price * growth ^ n)
--   income per second                  = sum(income_per_second * count)
--   value of one click                 = 10 * product(click_factor ^ count)
--   time passes at 8 days per unpaused second
--   coins spawn every 0.7 to 2.0 seconds and live at most 12.6 seconds

create table public.skill_catalog (
  id text primary key,
  base_price double precision not null,
  growth double precision not null,
  income_per_second double precision not null,
  click_factor integer not null,
  requires text references public.skill_catalog (id)
);

insert into public.skill_catalog
  (id, base_price, growth, income_per_second, click_factor, requires)
values
  ('hire_cleaner', 100, 1.15, 2, 1, null),
  ('cheat_apartment', 250, 1.15, 5, 1, 'hire_cleaner'),
  ('taxi_rides', 3000, 1.15, 30, 1, 'cheat_apartment'),
  ('china_trips', 20000, 1.15, 150, 1, 'taxi_rides'),
  ('furnish_palace', 150000, 1.15, 900, 1, 'china_trips'),
  ('write_book', 750, 5, 0, 2, 'hire_cleaner'),
  ('lower_taxes', 12500, 5, 0, 3, 'write_book'),
  ('break_promise', 750000, 5, 0, 4, 'lower_taxes'),
  ('cut_sick_leave', 5000000, 5, 0, 5, 'break_promise'),
  ('privatize_schools', 10000, 1.15, 100, 1, 'hire_cleaner'),
  ('privatize_hospitals', 60000, 1.15, 450, 1, 'privatize_schools'),
  ('sell_preschools', 350000, 1.15, 2200, 1, 'privatize_hospitals'),
  ('sell_public_housing', 2000000, 1.15, 11000, 1, 'sell_preschools');

create table public.runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  started_at timestamptz not null default now(),
  reported_at timestamptz,
  seq integer not null default 0,
  elapsed_days double precision not null default 0,
  total_earned double precision not null default 0,
  balance double precision not null default 0,
  owned jsonb not null default '{}'::jsonb,
  flagged text,
  submitted_at timestamptz,
  score double precision,
  broke_capitalism_at timestamptz
);

create index runs_user_started_idx
  on public.runs (user_id, started_at desc);

create index runs_broke_capitalism_idx
  on public.runs (user_id)
  where broke_capitalism_at is not null;

create table public.highscores (
  user_id uuid primary key references auth.users (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 10),
  score double precision not null check (score > 0),
  run_id uuid references public.runs (id) on delete set null,
  achieved_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  hidden boolean not null default false
);

create index highscores_ranking_idx
  on public.highscores (score desc, achieved_at asc)
  where not hidden;

alter table public.skill_catalog enable row level security;
alter table public.runs enable row level security;
alter table public.highscores enable row level security;

revoke all on table public.skill_catalog from anon, authenticated;
revoke all on table public.runs from anon, authenticated;
revoke all on table public.highscores from anon, authenticated;

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

create or replace function public._error(p_error text, p_hint text default null)
returns jsonb
language sql
immutable
as $$
  select jsonb_strip_nulls(
    jsonb_build_object('ok', false, 'error', p_error, 'hint', p_hint)
  );
$$;

create or replace function public._is_finite(p_value double precision)
returns boolean
language sql
immutable
as $$
  select p_value is not null
    and p_value <> 'NaN'::double precision
    and abs(p_value) <> 'Infinity'::double precision;
$$;

create or replace function public._flag(p_run_id uuid, p_reason text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.runs set flagged = p_reason where id = p_run_id;
  return public._error('implausible', p_reason);
end;
$$;

-- Validates a reported game state against the last accepted state of the
-- run and stores it when it is plausible. The caller must own the run.
create or replace function public._advance_run(
  p_run_id uuid,
  p_seq integer,
  p_elapsed_days double precision,
  p_total_earned double precision,
  p_balance double precision,
  p_owned jsonb,
  p_min_gap interval
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  run public.runs%rowtype;
  since timestamptz;
  wall_seconds double precision;
  play_seconds double precision;
  skill public.skill_catalog%rowtype;
  key text;
  raw_count numeric;
  old_count integer;
  new_count integer;
  k integer;
  spent double precision := 0;
  purchases integer := 0;
  income double precision := 0;
  multiplier double precision := 1;
  earned double precision;
  max_earned double precision;
  expected_balance double precision;
begin
  if uid is null then
    return public._error('not_authenticated');
  end if;

  select * into run
  from public.runs r
  where r.id = p_run_id and r.user_id = uid
  for update;
  if not found then
    return public._error('unknown_run');
  end if;
  if run.flagged is not null then
    return public._error('flagged', run.flagged);
  end if;
  if p_seq is distinct from run.seq + 1 then
    return public._error('bad_sequence', run.seq::text);
  end if;

  if not public._is_finite(p_elapsed_days)
     or not public._is_finite(p_total_earned)
     or not public._is_finite(p_balance)
     or p_elapsed_days < 0
     or p_total_earned < 0
     or p_balance < 0
     or p_owned is null
     or jsonb_typeof(p_owned) <> 'object' then
    return public._error('invalid_state');
  end if;

  for key in select jsonb_object_keys(p_owned) loop
    if jsonb_typeof(p_owned -> key) <> 'number'
       or not exists (select 1 from public.skill_catalog c where c.id = key)
    then
      return public._error('invalid_state');
    end if;
    raw_count := (p_owned ->> key)::numeric;
    if raw_count < 0 or raw_count <> floor(raw_count) or raw_count > 1000 then
      return public._error('invalid_state');
    end if;
  end loop;

  since := coalesce(run.reported_at, run.started_at);
  if p_min_gap > interval '0' and now() - since < p_min_gap then
    return public._error('cooldown');
  end if;

  wall_seconds := extract(epoch from now() - since);
  play_seconds := (p_elapsed_days - run.elapsed_days) / 8;
  if play_seconds < 0 then
    return public._flag(p_run_id, 'time_backwards');
  end if;
  if play_seconds > wall_seconds + 15 then
    return public._flag(p_run_id, 'time_too_fast');
  end if;

  begin
    for skill in select * from public.skill_catalog loop
      old_count := coalesce((run.owned ->> skill.id)::integer, 0);
      new_count := coalesce((p_owned ->> skill.id)::numeric, 0)::integer;
      if new_count < old_count then
        return public._flag(p_run_id, 'skill_removed');
      end if;
      if new_count > 0
         and skill.requires is not null
         and coalesce((p_owned ->> skill.requires)::numeric, 0) < 1 then
        return public._flag(p_run_id, 'requirement_missing');
      end if;
      for k in old_count .. new_count - 1 loop
        spent := spent + ceil(skill.base_price * power(skill.growth, k));
      end loop;
      purchases := purchases + (new_count - old_count);
      income := income + skill.income_per_second * new_count;
      multiplier := multiplier * power(skill.click_factor, new_count);
    end loop;
  exception
    when numeric_value_out_of_range then
      return public._flag(p_run_id, 'overflow');
  end;

  earned := p_total_earned - run.total_earned;
  if earned < 0 then
    return public._flag(p_run_id, 'earnings_decreased');
  end if;
  max_earned := income * play_seconds * 1.01
    + 10 * multiplier * (play_seconds / 0.7 + 20);
  if earned > max_earned then
    return public._flag(p_run_id, 'earned_too_much');
  end if;

  expected_balance := run.balance + earned - spent;
  if abs(p_balance - expected_balance)
     > 1e-6 * greatest(1, p_total_earned) + purchases then
    return public._flag(p_run_id, 'balance_mismatch');
  end if;

  update public.runs
  set seq = p_seq,
      reported_at = now(),
      elapsed_days = p_elapsed_days,
      total_earned = p_total_earned,
      balance = p_balance,
      owned = p_owned
  where id = p_run_id;

  return jsonb_build_object('ok', true, 'seq', p_seq);
end;
$$;

-------------------------------------------------------------------------------
-- Public functions
-------------------------------------------------------------------------------

-- Issues a server timestamped token for a run that starts from zero.
create or replace function public.start_run()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  recent integer;
  new_id uuid;
begin
  if uid is null then
    return public._error('not_authenticated');
  end if;

  select count(*) into recent
  from public.runs r
  where r.user_id = uid and r.started_at > now() - interval '1 hour';
  if recent >= 10 then
    return public._error('rate_limited');
  end if;

  insert into public.runs (user_id) values (uid) returning id into new_id;
  return jsonb_build_object('ok', true, 'run_id', new_id, 'seq', 0);
end;
$$;

create or replace function public.report_progress(
  p_run_id uuid,
  p_seq integer,
  p_elapsed_days double precision,
  p_total_earned double precision,
  p_balance double precision,
  p_owned jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Nothing after election day is recorded for a continued run, except a
  -- broken capitalism report.
  if public._is_finite(p_elapsed_days) and p_elapsed_days > 9752 + 1e-6 then
    return public._error('run_finished');
  end if;
  return public._advance_run(
    p_run_id, p_seq, p_elapsed_days, p_total_earned, p_balance, p_owned,
    interval '10 seconds'
  );
end;
$$;

-- Lets a client resynchronise its sequence number after a lost response.
create or replace function public.run_state(p_run_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  run public.runs%rowtype;
begin
  if uid is null then
    return public._error('not_authenticated');
  end if;
  select * into run from public.runs r
  where r.id = p_run_id and r.user_id = uid;
  if not found then
    return public._error('unknown_run');
  end if;
  return jsonb_build_object(
    'ok', true,
    'seq', run.seq,
    'flagged', run.flagged,
    'submitted', run.submitted_at is not null,
    'broke_capitalism', run.broke_capitalism_at is not null
  );
end;
$$;

create or replace function public.submit_score(
  p_run_id uuid,
  p_name text,
  p_seq integer,
  p_elapsed_days double precision,
  p_total_earned double precision,
  p_balance double precision,
  p_owned jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  clean_name text;
  run public.runs%rowtype;
  advanced jsonb;
  previous_best double precision;
  new_best double precision;
  best_at timestamptz;
  new_rank bigint;
begin
  if uid is null then
    return public._error('not_authenticated');
  end if;

  clean_name := btrim(regexp_replace(coalesce(p_name, ''), '\s+', ' ', 'g'));
  if char_length(clean_name) not between 1 and 10
     or clean_name !~ '^[[:alnum:] .,_!?''-]+$' then
    return public._error('invalid_name');
  end if;

  select * into run
  from public.runs r
  where r.id = p_run_id and r.user_id = uid
  for update;
  if not found then
    return public._error('unknown_run');
  end if;
  if run.submitted_at is not null then
    return public._error('already_submitted');
  end if;
  if run.flagged is not null then
    return public._error('flagged', run.flagged);
  end if;
  if not public._is_finite(p_elapsed_days) or p_elapsed_days < 9752 - 1e-6 then
    return public._error('run_not_finished');
  end if;
  if now() - run.started_at < interval '20 minutes' then
    return public._error('too_early');
  end if;
  if not public._is_finite(p_total_earned) or p_total_earned <= 0 then
    return public._error('invalid_score');
  end if;
  if exists (
    select 1 from public.runs r
    where r.user_id = uid and r.submitted_at > now() - interval '60 seconds'
  ) then
    return public._error('cooldown');
  end if;

  advanced := public._advance_run(
    p_run_id, p_seq, p_elapsed_days, p_total_earned, p_balance, p_owned,
    interval '0'
  );
  if not (advanced ->> 'ok')::boolean then
    return advanced;
  end if;

  update public.runs
  set submitted_at = now(), score = p_total_earned
  where id = p_run_id;

  select h.score into previous_best
  from public.highscores h
  where h.user_id = uid;

  insert into public.highscores as h (user_id, name, score, run_id)
  values (uid, clean_name, p_total_earned, p_run_id)
  on conflict (user_id) do update
    set name = excluded.name,
        score = greatest(h.score, excluded.score),
        run_id = case when excluded.score > h.score
                      then excluded.run_id else h.run_id end,
        achieved_at = case when excluded.score > h.score
                           then now() else h.achieved_at end,
        updated_at = now()
  returning h.score, h.achieved_at into new_best, best_at;

  select count(*) + 1 into new_rank
  from public.highscores o
  where not o.hidden
    and (o.score > new_best
         or (o.score = new_best and o.achieved_at < best_at));

  return jsonb_build_object(
    'ok', true,
    'seq', p_seq,
    'rank', new_rank,
    'best', new_best,
    'is_new_best', previous_best is null or p_total_earned > previous_best
  );
end;
$$;

create or replace function public.report_broken_capitalism(
  p_run_id uuid,
  p_seq integer,
  p_elapsed_days double precision,
  p_total_earned double precision,
  p_balance double precision,
  p_owned jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  run public.runs%rowtype;
  advanced jsonb;
begin
  if uid is null then
    return public._error('not_authenticated');
  end if;

  select * into run
  from public.runs r
  where r.id = p_run_id and r.user_id = uid
  for update;
  if not found then
    return public._error('unknown_run');
  end if;
  if run.broke_capitalism_at is not null then
    return public._error('already_submitted');
  end if;
  if run.flagged is not null then
    return public._error('flagged', run.flagged);
  end if;
  if now() - run.started_at < interval '5 minutes' then
    return public._error('too_early');
  end if;
  if not public._is_finite(p_balance) or p_balance < 1e9 then
    return public._error('invalid_state');
  end if;

  advanced := public._advance_run(
    p_run_id, p_seq, p_elapsed_days, p_total_earned, p_balance, p_owned,
    interval '0'
  );
  if not (advanced ->> 'ok')::boolean then
    return advanced;
  end if;

  update public.runs set broke_capitalism_at = now() where id = p_run_id;
  return jsonb_build_object('ok', true, 'seq', p_seq);
end;
$$;

create or replace function public.leaderboard()
returns jsonb
language sql
security definer
stable
set search_path = public
as $$
  with ranked as (
    select
      h.user_id,
      h.name,
      h.score,
      row_number() over (order by h.score desc, h.achieved_at asc) as rank
    from public.highscores h
    where not h.hidden
  )
  select jsonb_build_object(
    'ok', true,
    'top', coalesce(
      (select jsonb_agg(
         jsonb_build_object(
           'rank', r.rank,
           'name', r.name,
           'score', r.score,
           'is_me', r.user_id = auth.uid()
         ) order by r.rank)
       from ranked r
       where r.rank <= 10),
      '[]'::jsonb),
    'me', (
      select jsonb_build_object(
        'rank', r.rank,
        'name', r.name,
        'score', r.score,
        'is_me', true
      )
      from ranked r
      where r.user_id = auth.uid()
    ),
    'broken_capitalism_count', (
      select count(distinct r.user_id)
      from public.runs r
      where r.broke_capitalism_at is not null
    )
  );
$$;

-------------------------------------------------------------------------------
-- Grants: only signed in (including anonymous) users may call the public
-- functions, nobody may call the helpers directly.
-------------------------------------------------------------------------------

revoke execute on function public._error(text, text)
  from public, anon, authenticated;
revoke execute on function public._is_finite(double precision)
  from public, anon, authenticated;
revoke execute on function public._flag(uuid, text)
  from public, anon, authenticated;
revoke execute on function public._advance_run(
  uuid, integer, double precision, double precision, double precision,
  jsonb, interval
) from public, anon, authenticated;

revoke execute on function public.start_run() from public, anon;
revoke execute on function public.report_progress(
  uuid, integer, double precision, double precision, double precision, jsonb
) from public, anon;
revoke execute on function public.run_state(uuid) from public, anon;
revoke execute on function public.submit_score(
  uuid, text, integer, double precision, double precision, double precision,
  jsonb
) from public, anon;
revoke execute on function public.report_broken_capitalism(
  uuid, integer, double precision, double precision, double precision, jsonb
) from public, anon;
revoke execute on function public.leaderboard() from public, anon;

grant execute on function public.start_run() to authenticated;
grant execute on function public.report_progress(
  uuid, integer, double precision, double precision, double precision, jsonb
) to authenticated;
grant execute on function public.run_state(uuid) to authenticated;
grant execute on function public.submit_score(
  uuid, text, integer, double precision, double precision, double precision,
  jsonb
) to authenticated;
grant execute on function public.report_broken_capitalism(
  uuid, integer, double precision, double precision, double precision, jsonb
) to authenticated;
grant execute on function public.leaderboard() to authenticated;
