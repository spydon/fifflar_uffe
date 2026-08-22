-- The leaderboard can be asked for all time, the last seven days or the
-- last twenty four hours. Period lists are built from submitted runs, so
-- every submission keeps its own timestamp; the all time list still comes
-- from the per player best in public.highscores.

update public.runs
set submitted_at = now()
where score is not null and submitted_at is null;

create index runs_submitted_idx
  on public.runs (submitted_at desc)
  where score is not null and flagged is null;

drop function public.leaderboard();

create or replace function public.leaderboard(p_period text default 'all')
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  window_start timestamptz;
  result jsonb;
begin
  window_start := case p_period
    when 'day' then now() - interval '24 hours'
    when 'week' then now() - interval '7 days'
    when 'all' then null
    else null
  end;
  if p_period not in ('all', 'week', 'day') then
    return public._error('invalid_state');
  end if;

  if window_start is null then
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
          'rank', r.rank, 'name', r.name, 'score', r.score, 'is_me', true
        )
        from ranked r
        where r.user_id = auth.uid()
      )
    ) into result;
  else
    with best as (
      select distinct on (r.user_id)
        r.user_id,
        h.name,
        r.score,
        r.submitted_at
      from public.runs r
      join public.highscores h on h.user_id = r.user_id
      where r.score is not null
        and r.flagged is null
        and r.submitted_at >= window_start
        and not h.hidden
      order by r.user_id, r.score desc, r.submitted_at asc
    ),
    ranked as (
      select
        b.*,
        row_number() over (order by b.score desc, b.submitted_at asc) as rank
      from best b
    )
    select jsonb_build_object(
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
          'rank', r.rank, 'name', r.name, 'score', r.score, 'is_me', true
        )
        from ranked r
        where r.user_id = auth.uid()
      )
    ) into result;
  end if;

  return result || jsonb_build_object(
    'ok', true,
    'period', p_period,
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
end;
$$;

revoke execute on function public.leaderboard(text) from public, anon;
grant execute on function public.leaderboard(text) to authenticated;
