# NDF · Twin Jet

Notes de frais Twin Jet : saisie manuelle rapide (par mission/vol ou mensuelle par ligne),
calculs HT/TVA/TTC, plafond repas par couvert, indemnités km, devises étrangères, et génération
d'une note **calquée sur le formulaire officiel** prête à imprimer / enregistrer en PDF.

- **Devises étrangères** : à la saisie d'une dépense, on choisit la devise ; l'app interroge
  `api.frankfurter.dev` (taux de référence BCE) avec seulement le code devise + la date — aucun
  montant, aucun nom. Hors ligne ou devise hors BCE (AED, MAD, TND…) : saisie manuelle du taux.
  Le total final et les colonnes HT/TVA/TTC sont toujours en euros.
- Fonctionne **hors ligne** une fois la page chargée (service worker), y compris pour créer des
  notes en vol — la génération du PDF ne dépend jamais du réseau.
- Installable sur l'écran d'accueil (PWA).

## Compte cloud (multi-pilotes)

Chaque pilote a son espace privé : ses notes ne sont visibles que par lui (isolation appliquée
côté base de données — Row Level Security Supabase, pas juste côté app). L'inscription est
**réservée aux adresses `@twinjet.net`** (vérifié côté serveur), par lien de connexion envoyé par
email — pas de mot de passe.

Principe : l'app reste **locale d'abord**. Une note créée hors-ligne (en vol) est stockée sur
l'appareil, puis synchronisée automatiquement dès que la connexion revient (ou via le bouton
**⚙ Compte → Synchroniser**). Se déconnecter ne supprime rien sur l'appareil.

Tant que `SUPABASE_URL`/`SUPABASE_ANON_KEY` (en haut du `<script>` d'`index.html`) ne sont pas
renseignés, l'app tourne entièrement en local, sans écran de connexion — comportement identique à
la version mono-pilote d'origine.

### Mettre en place le projet Supabase
1. Créer un projet sur [supabase.com](https://supabase.com).
2. Exécuter dans l'éditeur SQL, dans l'ordre : `supabase/migrations/0001_init.sql` puis
   `0002_signup_domain.sql`.
3. **Authentication → Hooks → Before User Created** : sélectionner la fonction
   `public.restrict_signup_domain` (bloque toute inscription hors `@twinjet.net`).
4. **Authentication → URL Configuration** : ajouter l'URL de déploiement (Netlify) aux
   *Redirect URLs*, pour que le lien de connexion par email fonctionne.
5. Copier l'URL du projet et la clé `anon` (**Project Settings → API**) dans les constantes
   `SUPABASE_URL` / `SUPABASE_ANON_KEY` d'`index.html`.

## Déployer

**Netlify** (recommandé pour la version multi-pilotes) : connecter le dépôt GitHub sur
[netlify.com](https://netlify.com), site statique (`netlify.toml` déjà présent, aucune étape de
build) — chaque `git push` republie automatiquement.

**GitHub Pages** (version mono-pilote, sans compte cloud) :
1. Crée un dépôt (public) et dépose ces fichiers à la racine.
2. **Settings → Pages → Build and deployment → Deploy from a branch**, branche `main`, dossier
   `/ (root)`, *Save*.
3. Attends ~1 min : l'URL est `https://<utilisateur>.github.io/<repo>/`.

Dans les deux cas : ouvre l'URL sur le téléphone → menu **Partager → Sur l'écran d'accueil**.

## Mettre à jour l'app

Le service worker sert le HTML **réseau d'abord** : pousser une nouvelle version d'`index.html`
suffit, elle est récupérée automatiquement au prochain lancement en ligne (ou via
**⚙ Compte → Mettre à jour**). Incrémenter `VERSION` dans `sw.js` uniquement si on modifie `sw.js`
lui-même ou la liste `STATIC_ASSETS`.

## Sauvegarde / changement de téléphone

Avec un compte cloud configuré, les notes se resynchronisent automatiquement sur tout nouvel
appareil connecté au même compte. Sans compte (ou en secours) : **⚙ Compte → Exporter (.json)**
puis **Importer** sur le nouvel appareil.
