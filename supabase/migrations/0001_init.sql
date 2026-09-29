-- NDF Twin Jet — schéma multi-pilotes.
-- Chaque pilote a un compte Supabase Auth ; ses notes de frais ne sont
-- visibles/modifiables que par lui (Row Level Security sur user_id).
--
-- Miroir direct de l'objet `state` de l'app (state.id / state.notes /
-- state.exps / state.kms) : les colonnes reprennent les mêmes noms de champs
-- que dans index.html pour que la synchro reste une simple recopie.

-- ============================================================
-- profils (identité + réglages, un par pilote)
-- ============================================================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  nom text not null default '',
  fonction text not null default '',
  trigramme text not null default '',
  base text not null default '',
  cap numeric not null default 21.50,
  ik numeric not null default 0.636,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Un pilote gère son propre profil"
  on public.profiles for all
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- Création automatique du profil à l'inscription (valeurs par défaut ;
-- le pilote les complète ensuite dans Réglages).
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- notes (missions / vols ou notes mensuelles « ligne »)
-- ============================================================
create table public.notes (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('mission','ligne')),
  date text,
  mois text,
  titre text,
  objet text,
  categorie text,
  equipage text,
  veh_marque text,
  veh_cv text,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false
);

alter table public.notes enable row level security;

create policy "Un pilote gère ses propres notes"
  on public.notes for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create index notes_user_updated_idx on public.notes (user_id, updated_at);

-- ============================================================
-- expenses (dépenses rattachées à une note)
-- ============================================================
create table public.expenses (
  id uuid primary key,
  note_id uuid not null references public.notes(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  date text,
  ttc numeric,
  fournisseur text,
  libelle text,
  repas boolean not null default false,
  couverts integer not null default 1,
  tiers numeric not null default 0,
  tva numeric,
  tva_manuel boolean not null default false,
  tva_montant numeric not null default 0,
  cur text not null default 'EUR',
  fx numeric not null default 1,
  fx_date text default '',
  cur_ttc numeric,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false
);

alter table public.expenses enable row level security;

create policy "Un pilote gère ses propres dépenses"
  on public.expenses for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create index expenses_user_updated_idx on public.expenses (user_id, updated_at);
create index expenses_note_idx on public.expenses (note_id);

-- ============================================================
-- kms (indemnités kilométriques rattachées à une note)
-- ============================================================
create table public.kms (
  id uuid primary key,
  note_id uuid not null references public.notes(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  marque text,
  cv text,
  depart text,
  arrivee text,
  nbkm numeric,
  taux numeric,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false
);

alter table public.kms enable row level security;

create policy "Un pilote gère ses propres indemnités km"
  on public.kms for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create index kms_user_updated_idx on public.kms (user_id, updated_at);
create index kms_note_idx on public.kms (note_id);
