'use strict';

export class Config {
  // Quality settings
  samplesPerRay = 1;
  renderQuality = 1;
  maxReflections = 5;
  minImportancy = 0.3;
  firstPasses = 3;
  secondPasses = 3;
  temporal = true;
  temporalSamples = 4;
  filter = false;
  hdr = true;
  antialiasing = 'fxaa';
}
