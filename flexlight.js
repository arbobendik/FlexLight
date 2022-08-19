'use strict';

import {Camera} from './modules/camera.js';
import {Scene} from './modules/scene.js';
import {RayTracer} from './modules/raytracer.js';
import {Rasterizer} from './modules/rasterizer.js';
import {WebIo} from './modules/io.js';

export class FlexLight {
  #idRenderer;
  #idIo;
  #canvas;

  camera;
  #scene;
  #renderer;
  #io;

  //lol

  constructor (canvas) {
    this.#canvas = canvas;
    this.camera = new Camera();
    this.#scene = new Scene();
    this.#renderer = new Rasterizer(canvas, this.camera, this.#scene);
    this.#io = new WebIo(canvas, this.camera);
    this.#io.renderer = this.#renderer;
  }

  get canvas () {
    return this.#canvas;
  }

  get scene () {
    return this.#scene;
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

  set scene (scene) {
    this.#scene = scene;
    this.#renderer.scene = scene;
  }

  set renderer (renderer) {
    this.#idRenderer = renderer ?? 'rasterizer';
    this.#renderer.halt();
    switch (this.#idRenderer) {
      case 'raytracer':
        this.#renderer = new RayTracer(this.#canvas, this.camera, this.#scene);
        break;
      case 'rasterizer':
        this.#renderer = new Rasterizer(this.#canvas, this.camera, this.#scene);
        break;
      default:
        console.error("Renderer option " + this.#idRenderer + " doesn't exist.");
    }
  }

  set io (io) {
    this.#idIo = io ?? 'web';
    switch (this.#idIo) {
      case 'web':
        this.#io = new WebIo(this.#canvas, this.camera);
        break;
      default:
        console.error("Io option " + this.#idIo + " doesn't exist.");
    }
    this.#io.renderer = this.#renderer;
  }
}
