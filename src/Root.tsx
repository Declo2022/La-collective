import React from 'react';
import {Composition} from 'remotion';
import {Montage} from './montage/Montage';
import {FPS, dureeTotaleEnFrames} from './montage/config';

/**
 * Les compositions disponibles dans Remotion Studio.
 * Trois formats du même montage : paysage (YouTube), carré et
 * vertical (Reels / TikTok / Shorts).
 */
export const Root: React.FC = () => {
  const duree = dureeTotaleEnFrames();

  return (
    <>
      <Composition
        id="Montage"
        component={Montage}
        durationInFrames={duree}
        fps={FPS}
        width={1920}
        height={1080}
      />
      {/* Format 4:3, celui de « La Boulangère de Monceau » */}
      <Composition
        id="Montage43"
        component={Montage}
        durationInFrames={duree}
        fps={FPS}
        width={1440}
        height={1080}
      />
      <Composition
        id="MontageCarre"
        component={Montage}
        durationInFrames={duree}
        fps={FPS}
        width={1080}
        height={1080}
      />
      <Composition
        id="MontageVertical"
        component={Montage}
        durationInFrames={duree}
        fps={FPS}
        width={1080}
        height={1920}
      />
    </>
  );
};
