-- Counts played games on the leaderboard. A game counts as played once the
-- server has accepted at least one progress report for its run, so idle
-- tokens and flagged runs are left out.

create index runs_played_idx
  on public.runs (id)
  where reported_at is not null and flagged is null;

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
    ),
    'games_played', (
      select count(*)
      from public.runs r
      where r.reported_at is not null and r.flagged is null
    )
  );
$$;
