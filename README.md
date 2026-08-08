# La Collective — Montage vidéo avec Remotion

Ce projet permet de créer des montages vidéo par le code grâce à
[Remotion](https://www.remotion.dev/) : vous décrivez vos scènes dans un
fichier de configuration, et Remotion génère une vidéo MP4.

## Démarrage rapide

```bash
npm install       # installer les dépendances (une seule fois)
npm run dev       # ouvrir Remotion Studio (prévisualisation en direct)
npm run render    # exporter la vidéo dans out/montage.mp4
```

## Comment personnaliser le montage

Tout se passe dans **`src/montage/config.ts`** :

### 1. Ajoutez vos médias

Déposez vos images (`.jpg`, `.png`), vidéos (`.mp4`, `.webm`) et musique
(`.mp3`) dans le dossier **`public/`**.

### 2. Décrivez vos scènes

Modifiez le tableau `scenes` du fichier `src/montage/config.ts`.
Trois types de scènes sont disponibles :

```ts
// Un écran de titre animé
{ type: 'titre', titre: 'Mon titre', sousTitre: 'Optionnel', duree: 3 }

// Une image avec effet de zoom lent (Ken Burns) et légende optionnelle
{ type: 'image', fichier: 'photo1.jpg', legende: 'Été 2026', duree: 4 }

// Un extrait vidéo (debut = démarrer à la seconde N, muet = couper le son)
{ type: 'video', fichier: 'clip1.mp4', debut: 2, muet: true, duree: 5 }
```

Les scènes s'enchaînent automatiquement avec des transitions
(fondu et glissement en alternance).

### 3. Musique de fond (optionnelle)

Dans `config.ts`, remplacez :

```ts
export const MUSIQUE: string | null = null;
```

par le nom de votre fichier audio placé dans `public/` :

```ts
export const MUSIQUE: string | null = 'musique.mp3';
```

### 4. Style visuel

La constante `STYLE` de `config.ts` choisit l'esthétique du montage :

- **`'rohmer'`** (actif) : hommage à « La Boulangère de Monceau »
  d'Éric Rohmer — noir et blanc granuleux avec vignettage, cartons de
  titre en serif sur fond noir, coupes franches (fondus très courts).
- **`'moderne'`** : couleurs, titres sans-serif animés, transitions
  variées (fondu / glissement). La palette se règle alors dans la
  constante `COULEURS`.

## Guide de tournage — « La petite vie rangée d'un libraire »

Le montage actuel attend quatre courts extraits, un par chapitre. Filmés
au téléphone en suivant ces quelques principes, ils s'intégreront
naturellement au style Rohmer (le rendu passe automatiquement en noir et
blanc granuleux) :

- **Téléphone à l'horizontale**, poser l'appareil plutôt que le tenir
  (contre un livre, une étagère...) : pas de mouvement de caméra.
- **Lumière naturelle**, pas de flash ni de lumière artificielle forte.
- **10 à 15 secondes par plan**, sans réaction face caméra — on filme la
  scène comme si personne ne filmait.
- Le son n'est pas utilisé pour l'instant (`muet: true` dans la config) :
  aucune contrainte sur le bruit ambiant.

| Chapitre | Fichier attendu | Ce qu'il faut filmer |
|---|---|---|
| I. L'ouverture | `ouverture.mp4` | Le rideau de fer qui se lève, la clef dans la serrure, la lumière qu'on allume dans la boutique vide |
| II. Les habitués | `habitues.mp4` | Un client familier, un échange bref, un livre choisi sans hésiter |
| III. L'heure creuse | `heure-creuse.mp4` | La boutique déserte, la poussière dans la lumière, un livre feuilleté pour soi |
| IV. La fermeture | `fermeture.mp4` | Les piles rangées, les lumières éteintes, le rideau qui redescend |

Une fois un extrait filmé et découpé (voir plus bas s'il est trop lourd),
envoyez-le dans la conversation avec Claude : il sera placé dans le bon
chapitre et le montage sera rendu à nouveau.

**Si le fichier est trop volumineux pour être envoyé directement** (plus
de 100 Mo environ), publiez-le comme *Release* sur ce dépôt GitHub
(Code → Releases → « Create a new release » → joindre le fichier), qui
accepte jusqu'à 2 Go par fichier.

## Formats disponibles

| Commande | Composition | Format | Usage |
|---|---|---|---|
| `npm run render` | `Montage` | 1920×1080 (16:9) | YouTube, projection |
| `npm run render:43` | `Montage43` | 1440×1080 (4:3) | Style cinéma classique |
| `npm run render:carre` | `MontageCarre` | 1080×1080 (1:1) | Instagram |
| `npm run render:vertical` | `MontageVertical` | 1080×1920 (9:16) | Reels, TikTok, Shorts |

## Structure du projet

```
├── public/                  # Vos médias (images, vidéos, musique)
├── src/
│   ├── index.ts             # Point d'entrée Remotion
│   ├── Root.tsx             # Déclaration des compositions (3 formats)
│   └── montage/
│       ├── config.ts        # ⭐ Configuration : scènes, couleurs, musique
│       ├── Montage.tsx      # Enchaînement des scènes + transitions
│       ├── SceneTitre.tsx   # Écran de titre animé
│       └── SceneMedia.tsx   # Scène image (Ken Burns) ou vidéo + légende
├── remotion.config.ts       # Réglages de rendu (codec, qualité…)
└── package.json
```

## Astuces

- **Prévisualiser une seule frame** : `npm run still` génère `out/apercu.png`.
- **Changer la durée d'une transition** : constante `DUREE_TRANSITION` dans `config.ts`.
- **Rendu partiel** : `npx remotion render Montage out/test.mp4 --frames=0-90`
  pour ne rendre que les 3 premières secondes.
- La durée totale de la vidéo est calculée automatiquement à partir des
  durées des scènes.
