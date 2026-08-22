begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

-- Two anonymous users.
insert into auth.users (id, is_anonymous) values
  ('00000000-0000-0000-0000-000000000001', true),
  ('00000000-0000-0000-0000-000000000002', true);

create temp table ids (key text primary key, run_id uuid);
grant all on ids to authenticated, anon;

create or replace function pg_temp.act_as(p_user text) returns void
language plpgsql as $$
begin
  perform set_config(
    'request.jwt.claims',
    format('{"sub": "%s", "role": "authenticated"}', p_user),
    true
  );
  execute 'set local role authenticated';
end;
$$;

create or replace function pg_temp.as_admin() returns void
language plpgsql as $$
begin
  execute 'reset role';
end;
$$;

create or replace function pg_temp.start(p_key text) returns jsonb
language plpgsql as $$
declare result jsonb;
begin
  result := public.start_run();
  insert into ids values (p_key, (result ->> 'run_id')::uuid);
  return result;
end;
$$;

create or replace function pg_temp.run(p_key text) returns uuid
language sql as $$ select run_id from ids where key = p_key $$;

-------------------------------------------------------------------------------
-- Tables are not reachable directly
-------------------------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-000000000001');
select throws_ok('select * from public.runs', '42501');
select throws_ok('select * from public.highscores', '42501');
select throws_ok('select * from public.skill_catalog', '42501');
select throws_ok(
  $$select public._advance_run(gen_random_uuid(), 1, 0, 0, 0, '{}', '0')$$,
  '42501'
);

-------------------------------------------------------------------------------
-- start_run and the hourly limit
-------------------------------------------------------------------------------
select is((pg_temp.start('u1') ->> 'ok')::boolean, true, 'start_run works');
select is(
  (select count(*) from (
    select public.start_run() as r from generate_series(1, 9)
  ) s where (r ->> 'ok')::boolean),
  9::bigint,
  'ten runs per hour are allowed'
);
select is(
  public.start_run() ->> 'error', 'rate_limited',
  'the eleventh run in an hour is rate limited'
);

-------------------------------------------------------------------------------
-- Progress reports
-------------------------------------------------------------------------------
select is(
  public.report_progress(pg_temp.run('u1'), 1, 400, 600, 500,
    '{"hire_cleaner": 1}') ->> 'error',
  'cooldown',
  'reports right after the start are throttled'
);

select pg_temp.as_admin();
update public.runs set started_at = now() - interval '60 seconds'
  where id = pg_temp.run('u1');
select pg_temp.act_as('00000000-0000-0000-0000-000000000001');

select is(
  public.report_progress(pg_temp.run('u1'), 1, 400, 600, 500,
    '{"hire_cleaner": 1}'),
  '{"ok": true, "seq": 1}'::jsonb,
  'a plausible first report is accepted'
);
select is(
  public.report_progress(pg_temp.run('u1'), 1, 400, 600, 500,
    '{"hire_cleaner": 1}'),
  '{"ok": false, "error": "bad_sequence", "hint": "1"}'::jsonb,
  'a repeated sequence number is rejected with the current one as hint'
);
select is(
  public.report_progress(pg_temp.run('u1'), 2, 400, 600, 500,
    '{"hire_cleaner": 1, "bogus": 1}') ->> 'error',
  'invalid_state',
  'unknown skills are rejected'
);
select is(
  public.run_state(pg_temp.run('u1')),
  '{"ok": true, "seq": 1, "flagged": null, "submitted": false,
    "broke_capitalism": false}'::jsonb,
  'run_state reports the accepted sequence number'
);
select is(
  public.leaderboard() ->> 'games_played', '1',
  'a run counts as played once a report is accepted'
);

-- Implausible reports flag the run.
select pg_temp.act_as('00000000-0000-0000-0000-000000000002');
select pg_temp.start('too_much');
select pg_temp.start('missing_requirement');
select pg_temp.start('balance');
select pg_temp.start('too_fast');
select pg_temp.as_admin();
update public.runs set started_at = now() - interval '60 seconds'
  where user_id = '00000000-0000-0000-0000-000000000002';
select pg_temp.act_as('00000000-0000-0000-0000-000000000002');

select is(
  public.report_progress(pg_temp.run('too_much'), 1, 400, 1000000, 1000000,
    '{}'),
  '{"ok": false, "error": "implausible", "hint": "earned_too_much"}'::jsonb,
  'earning more than clicks and income allow is implausible'
);
select is(
  public.report_progress(pg_temp.run('too_much'), 2, 400, 1000, 1000, '{}'),
  '{"ok": false, "error": "flagged", "hint": "earned_too_much"}'::jsonb,
  'a flagged run stays flagged'
);
select is(
  public.report_progress(pg_temp.run('missing_requirement'), 1, 400, 600, 0,
    '{"taxi_rides": 1}') ->> 'hint',
  'requirement_missing',
  'skills need their prerequisite'
);
select is(
  public.report_progress(pg_temp.run('balance'), 1, 400, 600, 600,
    '{"hire_cleaner": 1}') ->> 'hint',
  'balance_mismatch',
  'the balance must match earnings minus purchases'
);
select is(
  public.report_progress(pg_temp.run('too_fast'), 1, 9752, 600, 600, '{}')
    ->> 'hint',
  'time_too_fast',
  'play time cannot exceed wall time'
);

-------------------------------------------------------------------------------
-- Submitting a score
-------------------------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-000000000001');
select is(
  public.submit_score(pg_temp.run('u1'), '<script>', 2, 9752, 5600, 5385,
    '{"hire_cleaner": 2}') ->> 'error',
  'invalid_name',
  'names are restricted to plain characters'
);
select is(
  public.submit_score(pg_temp.run('u1'), 'ElvaTecken!', 2, 9752, 5600, 5385,
    '{"hire_cleaner": 2}') ->> 'error',
  'invalid_name',
  'names are at most ten characters'
);
select is(
  public.submit_score(pg_temp.run('u1'), 'Uffe', 2, 9000, 5600, 5385,
    '{"hire_cleaner": 2}') ->> 'error',
  'run_not_finished',
  'scores need a finished run'
);
select is(
  public.submit_score(pg_temp.run('u1'), 'Uffe', 2, 9752, 5600, 5385,
    '{"hire_cleaner": 2}') ->> 'error',
  'too_early',
  'a run cannot finish in under twenty minutes'
);

select pg_temp.as_admin();
update public.runs
  set started_at = now() - interval '21 minutes',
      reported_at = now() - interval '20 minutes'
  where id = pg_temp.run('u1');
select pg_temp.act_as('00000000-0000-0000-0000-000000000001');

select is(
  public.submit_score(pg_temp.run('u1'), '  Uffe  K ', 2, 9752, 5600, 5385,
    '{"hire_cleaner": 2}'),
  '{"ok": true, "seq": 2, "rank": 1, "best": 5600, "is_new_best": true}'::jsonb,
  'a consistent final state is accepted'
);
select is(
  public.submit_score(pg_temp.run('u1'), 'Uffe', 3, 9752, 5600, 5385,
    '{"hire_cleaner": 2}') ->> 'error',
  'already_submitted',
  'a run is submitted once'
);
select is(
  public.leaderboard() -> 'top' -> 0 ->> 'name', 'Uffe K',
  'whitespace is collapsed in names'
);

-- A second player takes the lead.
select pg_temp.act_as('00000000-0000-0000-0000-000000000002');
select pg_temp.start('winner');
select pg_temp.as_admin();
update public.runs set started_at = now() - interval '21 minutes'
  where id = pg_temp.run('winner');
select pg_temp.act_as('00000000-0000-0000-0000-000000000002');
select is(
  public.submit_score(pg_temp.run('winner'), 'Magda', 1, 9752, 10000, 10000,
    '{}') ->> 'rank',
  '1',
  'a higher score takes first place'
);
select is(
  public.report_progress(pg_temp.run('winner'), 2, 9800, 10000, 10000, '{}')
    ->> 'error',
  'run_finished',
  'nothing is recorded after election day'
);

select pg_temp.act_as('00000000-0000-0000-0000-000000000001');
select is(
  public.leaderboard() -> 'me' ->> 'rank', '2',
  'the caller sees their own place'
);
select is(
  jsonb_array_length(public.leaderboard() -> 'top'), 2,
  'the top list holds every visible entry'
);
select is(
  public.leaderboard() -> 'top' -> 1 ->> 'is_me', 'true',
  'the caller is marked in the top list'
);
select is(
  jsonb_array_length(public.leaderboard('week') -> 'top'), 2,
  'runs submitted this week are on the weekly list'
);
select is(
  public.leaderboard('day') -> 'me' ->> 'rank', '2',
  'the daily list ranks the caller by today''s best run'
);
select pg_temp.as_admin();
update public.runs set submitted_at = now() - interval '3 days'
  where id = pg_temp.run('u1');
select pg_temp.act_as('00000000-0000-0000-0000-000000000001');
select is(
  public.leaderboard('day') -> 'me', 'null'::jsonb,
  'a run older than a day leaves the daily list'
);
select is(
  public.leaderboard('week') -> 'me' ->> 'rank', '2',
  'a run from three days ago stays on the weekly list'
);
select is(
  public.leaderboard('all') -> 'me' ->> 'rank', '2',
  'the all time list is unaffected by the window'
);
select is(
  public.leaderboard('month') ->> 'error', 'invalid_state',
  'unknown periods are rejected'
);

-------------------------------------------------------------------------------
-- Broken capitalism
-------------------------------------------------------------------------------
select pg_temp.act_as('00000000-0000-0000-0000-000000000002');
select pg_temp.start('broken');
select pg_temp.start('poor');
select is(
  public.report_broken_capitalism(pg_temp.run('broken'), 1, 2040,
    1000000050, 1000000050, '{}') ->> 'error',
  'too_early',
  'capitalism cannot break within five minutes'
);
select pg_temp.as_admin();
update public.runs
  set started_at = now() - interval '6 minutes'
  where id in (pg_temp.run('broken'), pg_temp.run('poor'));
update public.runs
  set seq = 1, elapsed_days = 2000, total_earned = 1000000000,
      balance = 1000000000, reported_at = now() - interval '60 seconds'
  where id = pg_temp.run('broken');
select pg_temp.act_as('00000000-0000-0000-0000-000000000002');
select is(
  public.report_broken_capitalism(pg_temp.run('poor'), 1, 400, 100, 100, '{}')
    ->> 'error',
  'invalid_state',
  'a small balance cannot have broken capitalism'
);
select is(
  public.report_broken_capitalism(pg_temp.run('broken'), 2, 2040,
    1000000050, 1000000050, '{}'),
  '{"ok": true, "seq": 2}'::jsonb,
  'a plausible overflow is recorded'
);
select is(
  public.report_broken_capitalism(pg_temp.run('broken'), 3, 2040,
    1000000050, 1000000050, '{}') ->> 'error',
  'already_submitted',
  'capitalism breaks once per run'
);
select is(
  public.leaderboard() ->> 'broken_capitalism_count', '1',
  'the leaderboard counts people who broke capitalism'
);
select is(
  public.leaderboard() ->> 'games_played', '3',
  'flagged and idle runs are not counted as played games'
);

-------------------------------------------------------------------------------
-- Anonymous role (no session) cannot call anything
-------------------------------------------------------------------------------
select pg_temp.as_admin();
set local role anon;
select throws_ok('select public.leaderboard()', '42501');
select throws_ok($$select public.leaderboard('day')$$, '42501');
select throws_ok('select public.start_run()', '42501');

select * from finish();
rollback;
