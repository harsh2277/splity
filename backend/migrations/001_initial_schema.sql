create extension if not exists pgcrypto;

create table if not exists profiles (
  id uuid primary key default gen_random_uuid(),
  supabase_user_id uuid not null unique,
  email text not null,
  full_name text,
  avatar text,
  phone text,
  upi_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  company_name text not null,
  type text not null default 'Other',
  invite_code text not null unique,
  approval_required boolean not null default false,
  image_url text,
  created_by uuid not null references profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references groups(id) on delete cascade,
  profile_id uuid references profiles(id) on delete cascade,
  display_name text,
  email text,
  avatar text,
  role text not null default 'member',
  status text not null default 'active',
  invited_by uuid references profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint group_members_known_person check (profile_id is not null or email is not null),
  constraint group_members_role_check check (role in ('owner', 'admin', 'member')),
  constraint group_members_status_check check (status in ('pending', 'active', 'removed')),
  unique (group_id, profile_id),
  unique (group_id, email)
);

create table if not exists expenses (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references groups(id) on delete cascade,
  created_by uuid not null references profiles(id) on delete cascade,
  paid_by uuid references profiles(id) on delete set null,
  title text not null,
  amount numeric(12, 2) not null check (amount > 0),
  currency text not null default 'INR',
  category text not null default 'other',
  split_method text not null default 'equal',
  notes text,
  expense_date date not null default current_date,
  is_personal boolean not null default false,
  status text not null default 'approved',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint expenses_status_check check (status in ('pending', 'approved', 'rejected')),
  constraint expenses_split_method_check check (split_method in ('equal', 'exact', 'percentage'))
);

create table if not exists expense_splits (
  id uuid primary key default gen_random_uuid(),
  expense_id uuid not null references expenses(id) on delete cascade,
  profile_id uuid references profiles(id) on delete cascade,
  member_email text,
  amount numeric(12, 2) not null check (amount >= 0),
  percentage numeric(5, 2),
  settled_at timestamptz,
  created_at timestamptz not null default now(),
  constraint expense_splits_known_person check (profile_id is not null or member_email is not null),
  unique (expense_id, profile_id),
  unique (expense_id, member_email)
);

create table if not exists settlements (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references groups(id) on delete cascade,
  payer_id uuid not null references profiles(id) on delete cascade,
  payee_id uuid references profiles(id) on delete set null,
  payee_email text,
  amount numeric(12, 2) not null check (amount > 0),
  currency text not null default 'INR',
  status text not null default 'pending',
  note text,
  settled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint settlements_known_payee check (payee_id is not null or payee_email is not null),
  constraint settlements_status_check check (status in ('pending', 'completed', 'failed', 'cancelled'))
);

create table if not exists schema_migrations (
  id text primary key,
  applied_at timestamptz not null default now()
);

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists profiles_set_updated_at on profiles;
create trigger profiles_set_updated_at
before update on profiles
for each row execute function set_updated_at();

drop trigger if exists groups_set_updated_at on groups;
create trigger groups_set_updated_at
before update on groups
for each row execute function set_updated_at();

drop trigger if exists group_members_set_updated_at on group_members;
create trigger group_members_set_updated_at
before update on group_members
for each row execute function set_updated_at();

drop trigger if exists expenses_set_updated_at on expenses;
create trigger expenses_set_updated_at
before update on expenses
for each row execute function set_updated_at();

drop trigger if exists settlements_set_updated_at on settlements;
create trigger settlements_set_updated_at
before update on settlements
for each row execute function set_updated_at();

create index if not exists idx_groups_created_by on groups(created_by);
create index if not exists idx_group_members_profile_id on group_members(profile_id);
create index if not exists idx_group_members_group_id on group_members(group_id);
create index if not exists idx_expenses_group_id on expenses(group_id);
create index if not exists idx_expenses_created_by on expenses(created_by);
create index if not exists idx_expense_splits_profile_id on expense_splits(profile_id);
create index if not exists idx_settlements_payer_id on settlements(payer_id);
create index if not exists idx_settlements_payee_id on settlements(payee_id);
