-- One time moderation of the all time list: some players submitted from
-- several anonymous accounts. Hide the mistyped names outright and keep
-- only the best entry per name. Hidden rows disappear from every list,
-- including the weekly and daily ones, since those join on highscores.

update public.highscores
set hidden = true, updated_at = now()
where not hidden and name in ('ÄgdSimon1', 'simon1339');

with ranked as (
  select
    h.user_id,
    row_number() over (
      partition by h.name
      order by h.score desc, h.achieved_at asc
    ) as position
  from public.highscores h
  where not h.hidden
)
update public.highscores h
set hidden = true, updated_at = now()
from ranked r
where r.user_id = h.user_id and r.position > 1;
