/**
 * Configuration du montage — c'est ICI que vous personnalisez votre vidéo.
 *
 * 1. Déposez vos images / vidéos / musique dans le dossier `public/`
 * 2. Décrivez vos scènes dans le tableau `scenes` ci-dessous
 * 3. Lancez `npm run dev` pour prévisualiser, `npm run render` pour exporter
 */

export type Scene =
  | {
      type: 'titre';
      titre: string;
      sousTitre?: string;
      /** Durée de la scène en secondes */
      duree: number;
    }
  | {
      /** Carton de texte narratif (style Rohmer uniquement) */
      type: 'narration';
      texte: string;
      duree: number;
    }
  | {
      type: 'image';
      /** Nom du fichier dans le dossier `public/` (ex. "photo1.jpg") */
      fichier: string;
      /** Légende affichée en bas de l'écran (optionnelle) */
      legende?: string;
      duree: number;
    }
  | {
      type: 'video';
      /** Nom du fichier dans le dossier `public/` (ex. "clip1.mp4") */
      fichier: string;
      legende?: string;
      /** Démarrer le clip à cette seconde (optionnel) */
      debut?: number;
      /** Couper le son du clip (utile si une musique de fond est active) */
      muet?: boolean;
      duree: number;
    };

export const FPS = 30;

/**
 * Style visuel du montage :
 * - 'rohmer'  : hommage à « La Boulangère de Monceau » d'Éric Rohmer —
 *               noir et blanc granuleux, cartons de titre en serif sur
 *               fond noir, coupes franches (fondus courts uniquement)
 * - 'moderne' : couleurs, titres sans-serif animés, transitions variées
 */
export const STYLE: 'rohmer' | 'moderne' = 'rohmer';

/**
 * Durée des transitions entre scènes, en secondes.
 * Le style Rohmer privilégie les coupes franches : fondus très courts.
 */
export const DUREE_TRANSITION = STYLE === 'rohmer' ? 0.4 : 0.7;

/** Palette de couleurs du montage */
export const COULEURS = {
  fond: '#0f0f1a',
  accent: '#e8b04b',
  texte: '#ffffff',
  texteSecondaire: 'rgba(255, 255, 255, 0.72)',
};

/**
 * Musique de fond : nom d'un fichier audio placé dans `public/`
 * (ex. 'musique.mp3'), ou `null` pour aucune musique.
 */
export const MUSIQUE: string | null = null;

/** Volume de la musique de fond (entre 0 et 1) */
export const VOLUME_MUSIQUE = 0.5;

/**
 * Les scènes du montage, dans l'ordre de lecture.
 * Remplacez ces exemples par vos propres contenus.
 */
export const scenes: Scene[] = [
  {
    type: 'titre',
    titre: "La petite vie rangée d'un libraire",
    sousTitre: 'Un conte moral',
    duree: 4.5,
  },

  // ── Chapitre I ─────────────────────────────────────────────
  {
    type: 'titre',
    titre: 'I',
    sousTitre: "L'ouverture",
    duree: 2.5,
  },
  {
    type: 'narration',
    texte:
      "Il descend le rideau de fer chaque matin à la même heure, comme si l'exactitude était, à elle seule, une vertu.",
    duree: 4,
  },
  // Placez ici votre extrait : rideau de fer, clef dans la serrure,
  // lumière allumée dans la boutique vide.
  // {
  //   type: 'video',
  //   fichier: 'ouverture.mp4',
  //   debut: 0,
  //   muet: true,
  //   duree: 8,
  // },

  // ── Chapitre II ────────────────────────────────────────────
  {
    type: 'titre',
    titre: 'II',
    sousTitre: 'Les habitués',
    duree: 2.5,
  },
  {
    type: 'narration',
    texte:
      'Ils reviennent toujours, moins pour ce qu’ils achètent que pour ce qu’ils y retrouvent : eux-mêmes, inchangés.',
    duree: 4,
  },
  // Un client familier, un échange bref, un livre choisi sans hésiter.
  // {
  //   type: 'video',
  //   fichier: 'habitues.mp4',
  //   debut: 0,
  //   muet: true,
  //   duree: 10,
  // },

  // ── Chapitre III ───────────────────────────────────────────
  {
    type: 'titre',
    titre: 'III',
    sousTitre: "L'heure creuse",
    duree: 2.5,
  },
  {
    type: 'narration',
    texte:
      "Entre midi et deux, il cesse un instant d'être libraire, et redevient, simplement, un lecteur.",
    duree: 4,
  },
  // La boutique vide, la poussière, un livre feuilleté pour soi.
  // {
  //   type: 'video',
  //   fichier: 'heure-creuse.mp4',
  //   debut: 0,
  //   muet: true,
  //   duree: 10,
  // },

  // ── Chapitre IV ────────────────────────────────────────────
  {
    type: 'titre',
    titre: 'IV',
    sousTitre: 'La fermeture',
    duree: 2.5,
  },
  {
    type: 'narration',
    texte:
      'Il range les piles, éteint les lumières, et referme sur sa journée comme on referme un livre déjà lu.',
    duree: 4,
  },
  // Le rideau qui redescend, la rue qui s'assombrit.
  // {
  //   type: 'video',
  //   fichier: 'fermeture.mp4',
  //   debut: 0,
  //   muet: true,
  //   duree: 8,
  // },

  {
    type: 'titre',
    titre: 'Fin',
    duree: 3.5,
  },
];

/** Durée totale du montage en frames (les transitions se chevauchent) */
export const dureeTotaleEnFrames = (): number => {
  const dureeScenes = scenes.reduce(
    (total, scene) => total + Math.round(scene.duree * FPS),
    0
  );
  const chevauchement =
    (scenes.length - 1) * Math.round(DUREE_TRANSITION * FPS);
  return dureeScenes - chevauchement;
};
