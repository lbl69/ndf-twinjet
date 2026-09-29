-- Restreint l'inscription aux adresses @twinjet.net.
--
-- Cette fonction est destinée à être enregistrée comme Auth Hook
-- « Before User Created » (Dashboard Supabase → Authentication → Hooks →
-- Before User Created → choisir cette fonction Postgres). Ce n'est PAS
-- automatique juste en exécutant cette migration : il faut ensuite aller
-- cocher le hook dans le dashboard (ou le déclarer dans supabase/config.toml
-- si le projet est géré par la CLI Supabase).
--
-- Le hook reçoit un événement JSON {"user": {"email": "...", ...}, ...} et
-- doit soit renvoyer l'événement tel quel (autorisé), soit lever une
-- exception (refusé — GoTrue renvoie alors une erreur au client).
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

-- Le hook Auth appelle cette fonction avec le rôle supabase_auth_admin.
grant execute on function public.restrict_signup_domain(jsonb) to supabase_auth_admin;
revoke execute on function public.restrict_signup_domain(jsonb) from authenticated, anon, public;
