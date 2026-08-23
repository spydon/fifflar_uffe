-- Let the secret key (service_role) inspect and moderate the tables through
-- the REST API. Players still only reach them through the functions.

grant select, update, delete on table public.runs to service_role;
grant select, update, delete on table public.highscores to service_role;
grant select on table public.skill_catalog to service_role;
