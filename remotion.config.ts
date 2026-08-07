import fs from 'node:fs';
import {Config} from '@remotion/cli/config';

// Dans l'environnement distant, un Chromium est déjà installé :
// on l'utilise au lieu de laisser Remotion en télécharger un.
// Sur votre machine locale, ce chemin n'existe pas et Remotion
// utilisera son navigateur habituel.
const chromiumPreinstalle =
  '/opt/pw-browsers/chromium_headless_shell-1194/chrome-linux/headless_shell';
if (fs.existsSync(chromiumPreinstalle)) {
  Config.setBrowserExecutable(chromiumPreinstalle);
}

// Qualité d'image des frames intermédiaires (JPEG)
Config.setVideoImageFormat('jpeg');
Config.setJpegQuality(90);

// Écrase le fichier de sortie s'il existe déjà
Config.setOverwriteOutput(true);

// Codec de sortie par défaut
Config.setCodec('h264');
