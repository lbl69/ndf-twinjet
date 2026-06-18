# NDF · Twin Jet

Notes de frais Twin Jet : saisie manuelle rapide (par mission/vol ou mensuelle par ligne),
calculs HT/TVA/TTC, plafond repas par couvert, indemnités km, et génération d'une note
**calquée sur le formulaire officiel** prête à imprimer / enregistrer en PDF.

- 100 % côté navigateur, **aucune donnée envoyée** (tout reste dans le stockage local de l'appareil).
- Fonctionne **hors ligne** une fois la page chargée (service worker).
- Installable sur l'écran d'accueil (PWA).

## Déployer sur GitHub Pages
1. Crée un dépôt (public) et dépose ces fichiers à la racine :
   `index.html`, `manifest.webmanifest`, `sw.js`, `icon-192.png`, `icon-512.png`.
2. **Settings → Pages → Build and deployment → Deploy from a branch**, branche `main`, dossier `/ (root)`, *Save*.
3. Attends ~1 min : l'URL est `https://<utilisateur>.github.io/<repo>/`.
4. Ouvre l'URL sur le téléphone → menu **Partager → Sur l'écran d'accueil**.

## Mettre à jour
Pousse une nouvelle version de `index.html`, puis incrémente `CACHE = "ndf-v1"` → `"ndf-v2"`
dans `sw.js` pour forcer le rafraîchissement du cache.

## Sauvegarde / changement de téléphone
Les données vivent dans le navigateur. Pour migrer, on peut ajouter un bouton
**Exporter / Importer** (fichier JSON) — demande-le si besoin.
