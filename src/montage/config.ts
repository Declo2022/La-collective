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

/** Durée des transitions entre scènes, en secondes */
export const DUREE_TRANSITION = 0.7;

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
    titre: 'La Collective',
    sousTitre: 'Notre histoire en images',
    duree: 3.5,
  },
  {
    type: 'titre',
    titre: 'Chapitre 1',
    sousTitre: 'Ajoutez vos photos dans le dossier public/',
    duree: 3,
  },
  // Exemple avec une image (décommentez après avoir ajouté le fichier) :
  // {
  //   type: 'image',
  //   fichier: 'photo1.jpg',
  //   legende: 'Un moment mémorable',
  //   duree: 4,
  // },
  // Exemple avec une vidéo :
  // {
  //   type: 'video',
  //   fichier: 'clip1.mp4',
  //   debut: 2,
  //   muet: true,
  //   duree: 5,
  // },
  {
    type: 'titre',
    titre: 'À bientôt',
    sousTitre: 'Montage réalisé avec Remotion',
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
