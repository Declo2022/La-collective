import React from 'react';
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {COULEURS} from './config';

export const SceneTitre: React.FC<{
  titre: string;
  sousTitre?: string;
}> = ({titre, sousTitre}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  const apparition = spring({
    frame,
    fps,
    config: {damping: 200},
    durationInFrames: 25,
  });

  const apparitionSousTitre = spring({
    frame: frame - 12,
    fps,
    config: {damping: 200},
    durationInFrames: 25,
  });

  const largeurLigne = interpolate(apparition, [0, 1], [0, 180]);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COULEURS.fond,
        justifyContent: 'center',
        alignItems: 'center',
        fontFamily: 'Helvetica, Arial, sans-serif',
      }}
    >
      <div
        style={{
          opacity: apparition,
          transform: `translateY(${interpolate(apparition, [0, 1], [40, 0])}px)`,
          color: COULEURS.texte,
          fontSize: 110,
          fontWeight: 700,
          letterSpacing: '0.02em',
          textAlign: 'center',
          padding: '0 80px',
        }}
      >
        {titre}
      </div>
      <div
        style={{
          height: 5,
          width: largeurLigne,
          backgroundColor: COULEURS.accent,
          borderRadius: 3,
          marginTop: 32,
        }}
      />
      {sousTitre ? (
        <div
          style={{
            opacity: Math.max(0, apparitionSousTitre),
            transform: `translateY(${interpolate(
              Math.max(0, apparitionSousTitre),
              [0, 1],
              [24, 0]
            )}px)`,
            color: COULEURS.texteSecondaire,
            fontSize: 42,
            fontWeight: 400,
            marginTop: 36,
            textAlign: 'center',
            padding: '0 120px',
          }}
        >
          {sousTitre}
        </div>
      ) : null}
    </AbsoluteFill>
  );
};
