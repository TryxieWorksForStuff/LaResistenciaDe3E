-- Ejecuta en Supabase > SQL Editor
create table profiles(id uuid primary key references auth.users on delete cascade,
 username text unique not null check (char_length(username) between 3 and 20),
 role text not null default 'student' check (role in ('student','admin')),
 xp int not null default 0, streak int not null default 0, last_day date, show_board boolean not null default true);
create table courses(id text primary key, data jsonb not null, published boolean not null default false);
create table progress(user_id uuid references auth.users on delete cascade, course_id text, lesson_id text, best int not null default 0,
 primary key(user_id,lesson_id));
alter table profiles enable row level security; alter table courses enable row level security; alter table progress enable row level security;

create function is_admin() returns boolean language sql security definer set search_path=public as
$$ select exists(select 1 from profiles where id=auth.uid() and role='admin') $$;

create policy "perfil propio" on profiles for select using (id=auth.uid());
create policy "progreso propio" on progress for select using (user_id=auth.uid());
create policy "cursos publicados" on courses for select using (published or is_admin());
create policy "admin escribe cursos" on courses for all using (is_admin()) with check (is_admin());
-- Nadie escribe profiles/progress directamente: solo mediante las funciones de abajo.

create function handle_new_user() returns trigger language plpgsql security definer set search_path=public as
$$ begin insert into profiles(id,username) values(new.id,new.raw_user_meta_data->>'username'); return new; end $$;
create trigger on_signup after insert on auth.users for each row execute function handle_new_user();

create function complete_lesson(p_course text,p_lesson text,p_score int,p_total int) returns int
language plpgsql security definer set search_path=public as $$
declare gained int:=0; fst boolean; d date:=current_date;
begin
 if auth.uid() is null or p_total<=0 or p_score<0 or p_score>p_total then raise exception 'invalid'; end if;
 insert into progress(user_id,course_id,lesson_id,best) values(auth.uid(),p_course,p_lesson,p_score*100/p_total)
  on conflict(user_id,lesson_id) do update set best=greatest(progress.best,excluded.best) returning (xmax=0) into fst;
 if fst then gained:=10+2*p_score; end if;  -- XP solo la primera vez
 update profiles set xp=xp+gained,
  streak=case when last_day=d then streak when last_day=d-1 then streak+1 else 1 end, last_day=d where id=auth.uid();
 return gained;
end $$;

create function set_board(b boolean) returns void language sql security definer set search_path=public as
$$ update profiles set show_board=b where id=auth.uid() $$;

create view leaderboard as select username,xp from profiles where show_board order by xp desc limit 20;
grant select on leaderboard to authenticated;
grant execute on function complete_lesson, set_board to authenticated;
revoke all on leaderboard from anon;
-- Primer admin (después de registrarte en la app):
-- update profiles set role='admin' where username='TU_USUARIO';
