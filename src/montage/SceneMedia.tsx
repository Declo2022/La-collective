import React from 'react';
import {
  AbsoluteFill,
  Img,
  OffthreadVideo,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {COULEURS} from './config';

const Legende: React.FC<{texte: string}> = ({texte}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  const apparition = spring({
    frame: frame - 8,
    fps,
    config: {damping: 200},
    durationInFrames: 25,
  });

  return (
    <div
      style={{
        position: 'absolute',
        bottom: 70,
        left: 0,
        right: 0,
        display: 'flex',
        justifyContent: 'center',
        opacity: Math.max(0, apparition),
        transform: `translateY(${interpolate(
          Math.max(0, apparition),
          [0, 1],
          [30, 0]
        )}px)`,
      }}
    >
      <div
        style={{
          backgroundColor: 'rgba(15, 15, 26, 0.72)',
          color: COULEURS.texte,
          fontFamily: 'Helvetica, Arial, sans-serif',
          fontSize: 38,
          fontWeight: 500,
          padding: '18px 44px',
          borderRadius: 14,
          borderLeft: `6px solid ${COULEURS.accent}`,
          maxWidth: '80%',
          textAlign: 'center',
        }}
      >
        {texte}
      </div>
    </div>
  );
};

/**
 * Affiche une image avec un léger effet Ken Burns (zoom lent),
 * ou une vidéo, avec une légende optionnelle.
 */
export const SceneMedia: React.FC<{
  type: 'image' | 'video';
  fichier: string;
  legende?: string;
  debut?: number;
  muet?: boolean;
  dureeEnFrames: number;
}> = ({type, fichier, legende, debut, muet, dureeEnFrames}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  // Effet Ken Burns : zoom progressif de 1 à 1.08 sur la durée de la scène
  const zoom = interpolate(frame, [0, dureeEnFrames], [1, 1.08], {
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{backgroundColor: COULEURS.fond}}>
      <AbsoluteFill style={{overflow: 'hidden'}}>
        {type === 'image' ? (
          <Img
            src={staticFile(fichier)}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover',
              transform: `scale(${zoom})`,
            }}
          />
        ) : (
          <OffthreadVideo
            src={staticFile(fichier)}
            startFrom={Math.round((debut ?? 0) * fps)}
            muted={muet ?? false}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'cover',
            }}
          />
        )}
      </AbsoluteFill>
      {legende ? <Legende texte={legende} /> : null}
    </AbsoluteFill>
  );
};
