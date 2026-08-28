-- Speed boost.
--
-- The client has a fast forward toggle that runs the whole world at double
-- speed: the calendar, the passive income and the coin spawner all advance
-- twice as fast per wall clock second, so a boosted run produces the same
-- game state per game day as a normal one and just finishes sooner. The
-- plausibility rules that compare game time with wall time therefore allow
-- up to _max_speed() times real time, and the minimum run durations shrink
-- by the same factor.

create or replace function public._max_speed()
returns double precision
language sql
immutable
as $$ select 2::double precision $$;

revoke execute on function public._max_speed()
  from public, anon, authenticated;

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
  if play_seconds > public._max_speed() * wall_seconds + 15 then
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
  if now() - run.started_at < interval '20 minutes' / public._max_speed() then
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
  if now() - run.started_at < interval '5 minutes' / public._max_speed() then
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
