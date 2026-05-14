
-- The Splash of Lives / Kalindi-template Supabase setup
-- Run in Supabase SQL Editor. Then create these PUBLIC storage buckets:
-- novel-pdfs, character-art, artwork-gallery, letter-images, letter-replies

create extension if not exists pgcrypto;

create table if not exists public.episodes (
  id uuid primary key default gen_random_uuid(),
  num integer unique not null,
  title text not null,
  part text,
  pdf_path text not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.characters (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text,
  lore text,
  image_path text,
  sort_order integer default 0,
  is_visible boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.artworks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  episode_label text,
  image_path text,
  sort_order integer default 0,
  is_visible boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.reader_letters (
  id uuid primary key default gen_random_uuid(),
  parent_letter_id uuid references public.reader_letters(id) on delete cascade,
  letter_type text default 'reader',
  is_author_post boolean default false,
  sender_name text not null,
  sender_name_normalized text,
  character_name text,
  addressed_to text default 'Letters to St. Cross',
  letter_content text not null,
  image_url text,
  image_path text,
  reply_file_url text,
  reply_file_path text,
  reply_file_type text,
  is_approved boolean default true,
  is_pinned boolean default false,
  created_at timestamptz default now()
);

alter table public.episodes enable row level security;
alter table public.characters enable row level security;
alter table public.artworks enable row level security;
alter table public.reader_letters enable row level security;

-- Public reading
create policy "episodes public read" on public.episodes for select using (true);
create policy "characters public read" on public.characters for select using (true);
create policy "artworks public read" on public.artworks for select using (true);
create policy "letters public read approved" on public.reader_letters for select using (is_approved = true);

-- Public insert/update/delete for your no-login writer-studio setup.
-- This matches your current HTML template. For a private production setup, move writer actions behind auth.
create policy "episodes public write" on public.episodes for all using (true) with check (true);
create policy "characters public write" on public.characters for all using (true) with check (true);
create policy "artworks public write" on public.artworks for all using (true) with check (true);
create policy "letters public insert" on public.reader_letters for insert with check (true);
create policy "letters public update" on public.reader_letters for update using (true) with check (true);
create policy "letters public delete" on public.reader_letters for delete using (true);

-- Storage policies for public buckets
create policy "public read storage" on storage.objects for select using (
  bucket_id in ('novel-pdfs','character-art','artwork-gallery','letter-images','letter-replies')
);
create policy "public upload storage" on storage.objects for insert with check (
  bucket_id in ('novel-pdfs','character-art','artwork-gallery','letter-images','letter-replies')
);
create policy "public update storage" on storage.objects for update using (
  bucket_id in ('novel-pdfs','character-art','artwork-gallery','letter-images','letter-replies')
) with check (
  bucket_id in ('novel-pdfs','character-art','artwork-gallery','letter-images','letter-replies')
);
create policy "public delete storage" on storage.objects for delete using (
  bucket_id in ('novel-pdfs','character-art','artwork-gallery','letter-images','letter-replies')
);
