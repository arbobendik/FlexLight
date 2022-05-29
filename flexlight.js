'use strict';

import {Camera} from './camera.js';
import {RayTracer} from './raytracer.js';
import {WebIo} from './io.js';

export class FlexLight {
  #idRenderer;
  #idIo;

  #canvas;
  camera;
  #renderer;
  #io;

  constructor (canvas) {
    this.#canvas = canvas;
    this.camera = new Camera();
    this.#renderer = new RayTracer(canvas, this.camera);
    this.#io = new WebIo(canvas, this.camera);
    this.#io.renderer = this.#renderer;
  }

  get canvas () {
    return this.#canvas;
  }

  get renderer () {
    return this.#renderer;
  }

  get io () {
    return this.#io;
  }

  set canvas (canvas) {
    this.#canvas = canvas;
    this.renderer(this.#idRenderer);
    this.io(this.#idIo);
  }

  set renderer (renderer) {
    this.#idRenderer = renderer ?? 'raytracer';
    switch (this.#idRenderer) {
      case 'raytracer':
        this.#renderer = new RayTracer(this.#canvas, this.camera);
        break;
    }
  }

  set io (io) {
    this.#idIo = io ?? 'web';
    switch (this.#idIo) {
      case 'web':
        this.#io = new WebIo(this.#canvas, this.camera);
        break;
    }
    this.#io.renderer = this.#renderer;
  }
}
