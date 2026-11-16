-- Brightlife public website project content.
-- Run once in the Supabase SQL Editor if public.site_content does not exist.
create table if not exists public.site_content (
  id uuid primary key default gen_random_uuid(),
  content_key text not null unique,
  title text not null default '',
  body text not null default '',
  image_url text not null default '',
  published boolean not null default true,
  updated_by uuid null references public.members(id) on delete set null,
  updated_at timestamptz not null default now(),
  constraint site_content_key_format check (content_key ~ '^[a-zA-Z0-9_-]{2,80}$')
);
create index if not exists site_content_published_key_idx
  on public.site_content (published, content_key);
alter table public.site_content enable row level security;
-- Browser clients receive no direct table policies. The Vercel API accesses
-- this table server-side with the configured Supabase service-role key.
