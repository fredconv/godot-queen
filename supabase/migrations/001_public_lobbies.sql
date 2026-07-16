-- Registre éphémère des parties en ligne (codes d'invitation + recherche par pseudo).
-- À appliquer sur votre projet Supabase (SQL Editor ou CLI).

create table if not exists public.public_lobbies (
	invite_code text primary key,
	host_name text not null,
	host_address text not null,
	port integer not null default 7777,
	player_count integer not null default 1,
	max_players integer not null default 4,
	updated_at timestamptz not null default now()
);

create index if not exists public_lobbies_host_name_idx
	on public.public_lobbies (host_name);

create index if not exists public_lobbies_updated_at_idx
	on public.public_lobbies (updated_at desc);

alter table public.public_lobbies enable row level security;

create policy "public_lobbies_select_anon"
	on public.public_lobbies
	for select
	to anon
	using (true);

create policy "public_lobbies_insert_anon"
	on public.public_lobbies
	for insert
	to anon
	with check (true);

create policy "public_lobbies_update_anon"
	on public.public_lobbies
	for update
	to anon
	using (true)
	with check (true);

create policy "public_lobbies_delete_anon"
	on public.public_lobbies
	for delete
	to anon
	using (true);

-- Nettoyage optionnel des entrées expirées (cron Supabase ou Edge Function).
-- delete from public.public_lobbies where updated_at < now() - interval '2 minutes';
