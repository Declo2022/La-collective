import React from 'react';
import {
  AbsoluteFill,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';

/**
 * Style « Nouvelle Vague » en hommage à La Boulangère de Monceau (1963) :
 * cartons de titre serif sur fond noir, pellicule noir et blanc
 * granuleuse avec un léger vignettage.
 */

const POLICE_SERIF = 'Georgia, "Times New Roman", "Liberation Serif", serif';

/** Grain de pellicule animé (bruit différent à chaque frame) */
const GrainPellicule: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{opacity: 0.1, pointerEvents: 'none'}}>
      <svg width="100%" height="100%">
        <filter id={`grain-${frame}`}>
          <feTurbulence
            type="fractalNoise"
            baseFrequency="0.8"
            numOctaves="2"
            seed={frame}
            stitchTiles="stitch"
          />
          <feColorMatrix type="saturate" values="0" />
        </filter>
        <rect width="100%" height="100%" filter={`url(#grain-${frame})`} />
      </svg>
    </AbsoluteFill>
  );
};

/** Vignettage : coins légèrement assombris comme sur du 16 mm */
const Vignettage: React.FC = () => (
  <AbsoluteFill
    style={{
      background:
        'radial-gradient(ellipse at center, transparent 55%, rgba(0, 0, 0, 0.5) 100%)',
      pointerEvents: 'none',
    }}
  />
);

/**
 * Enveloppe une scène vidéo/image pour lui donner l'aspect
 * pellicule noir et blanc : désaturation, contraste, grain, vignettage.
 */
export const PelliculeNoirEtBlanc: React.FC<{
  children: React.ReactNode;
}> = ({children}) => (
  <AbsoluteFill style={{backgroundColor: '#000'}}>
    <AbsoluteFill style={{filter: 'grayscale(1) contrast(1.08) brightness(1.02)'}}>
      {children}
    </AbsoluteFill>
    <Vignettage />
    <GrainPellicule />
  </AbsoluteFill>
);

/**
 * Carton de titre à la Rohmer : texte serif centré sur fond noir,
 * simple fondu d'ouverture et de fermeture.
 */
export const SceneTitreRohmer: React.FC<{
  titre: string;
  sousTitre?: string;
}> = ({titre, sousTitre}) => {
  const frame = useCurrentFrame();
  const {durationInFrames} = useVideoConfig();

  const fondu = interpolate(
    frame,
    [0, 18, durationInFrames - 18, durationInFrames],
    [0, 1, 1, 0],
    {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}
  );

  return (
    <AbsoluteFill
      style={{
        backgroundColor: '#000',
        justifyContent: 'center',
        alignItems: 'center',
        fontFamily: POLICE_SERIF,
      }}
    >
      <div style={{opacity: fondu, textAlign: 'center', padding: '0 100px'}}>
        <div
          style={{
            color: '#f0ede4',
            fontSize: 92,
            fontWeight: 400,
            lineHeight: 1.25,
            letterSpacing: '0.01em',
          }}
        >
          {titre}
        </div>
        {sousTitre ? (
          <div
            style={{
              color: '#f0ede4',
              fontSize: 44,
              fontStyle: 'italic',
              marginTop: 46,
              opacity: 0.85,
            }}
          >
            {sousTitre}
          </div>
        ) : null}
      </div>
      <GrainPellicule />
    </AbsoluteFill>
  );
};
