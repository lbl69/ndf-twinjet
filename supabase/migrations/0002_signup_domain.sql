create or replace function public.restrict_signup_domain(event jsonb)
returns jsonb
language plpgsql
security definer set search_path = public
as $$
declare
  email text := lower(event->'user'->>'email');
begin
  if email is null or email !~* '^[^@\s]+@twinjet\.net$' then
    raise exception 'signup_domain_not_allowed'
      using detail = 'Inscription réservée aux adresses @twinjet.net.',
            hint = 'contact_admin';
  end if;
  return event;
end;
$$;

grant execute on function public.restrict_signup_domain(jsonb) to supabase_auth_admin;
revoke execute on function public.restrict_signup_domain(jsonb) from authenticated, anon, public;
