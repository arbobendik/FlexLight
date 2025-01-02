'use strict';

import { vec2, vec3 } from '../math/math_types.js';


export class Camera {
  // Camera and frustrum settings
  position: vec3 = { x: 0, y: 0, z: 0 };
  rotation: vec2 = { x: 0, y: 0 };
  fov: number = 1 / Math.PI;
}
