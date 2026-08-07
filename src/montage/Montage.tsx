import React from 'react';
import {AbsoluteFill, Audio, staticFile} from 'remotion';
import {TransitionSeries, linearTiming} from '@remotion/transitions';
import {fade} from '@remotion/transitions/fade';
import {slide} from '@remotion/transitions/slide';
import {
  DUREE_TRANSITION,
  FPS,
  MUSIQUE,
  VOLUME_MUSIQUE,
  scenes,
} from './config';
import {SceneTitre} from './SceneTitre';
import {SceneMedia} from './SceneMedia';

/**
 * Le montage principal : enchaîne les scènes définies dans `config.ts`
 * en alternant les transitions (fondu, glissement).
 */
export const Montage: React.FC = () => {
  const dureeTransition = Math.round(DUREE_TRANSITION * FPS);

  return (
    <AbsoluteFill style={{backgroundColor: '#000'}}>
      {MUSIQUE ? (
        <Audio src={staticFile(MUSIQUE)} volume={VOLUME_MUSIQUE} />
      ) : null}
      <TransitionSeries>
        {scenes.map((scene, index) => {
          const dureeEnFrames = Math.round(scene.duree * FPS);
          const elements = [
            <TransitionSeries.Sequence
              key={`scene-${index}`}
              durationInFrames={dureeEnFrames}
            >
              {scene.type === 'titre' ? (
                <SceneTitre titre={scene.titre} sousTitre={scene.sousTitre} />
              ) : (
                <SceneMedia
                  type={scene.type}
                  fichier={scene.fichier}
                  legende={scene.legende}
                  debut={scene.type === 'video' ? scene.debut : undefined}
                  muet={scene.type === 'video' ? scene.muet : undefined}
                  dureeEnFrames={dureeEnFrames}
                />
              )}
            </TransitionSeries.Sequence>,
          ];

          // Ajoute une transition après chaque scène sauf la dernière,
          // en alternant fondu et glissement.
          if (index < scenes.length - 1) {
            elements.push(
              <TransitionSeries.Transition
                key={`transition-${index}`}
                presentation={
                  index % 2 === 0 ? fade() : slide({direction: 'from-right'})
                }
                timing={linearTiming({durationInFrames: dureeTransition})}
              />
            );
          }

          return elements;
        })}
      </TransitionSeries>
    </AbsoluteFill>
  );
};
