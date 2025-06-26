"use strict";

import { FlexLight, Camera, Scene, Vector, PointLight, Prototype, Instance, Material } from '../../flexlight/flexlight.js';

const staticPath = './static/';

// Build example scene
async function buildScene() {
    // Create new canvas.
    const canvas = document.createElement("canvas");
    // Append it to body.
    document.body.appendChild(canvas);
    const engine = new FlexLight(canvas);
    engine.io = 'web';

    const camera: Camera = engine.camera;
    const scene: Scene = engine.scene;

    // Set camera perspective and position.
    camera.position = new Vector(4.5, 10, -7);
    camera.direction = new Vector(0, 0.85);

    // Create the ground plane
    const planeProto = await Prototype.fromObjStatic(staticPath + 'objects/plane.obj');
    const groundPlane = scene.instance(planeProto);
    groundPlane.material.color = new Vector(8/255, 64/255, 126/255);
    groundPlane.transform.scale(50);

    // Load the ETH logo. It may consist of multiple objects/prototypes.
    const objPath: string = staticPath + 'objects/eth.obj';
    const mtlPath: string = staticPath + 'objects/eth.mtl';
    for await (const prototype of Prototype.fromObj(objPath, mtlPath)) {
        const instance = scene.instance(prototype);
        // The position is already part of the obj, so we don't need to set it.
    }

    // Add lighting
    const light = new PointLight(new Vector(40, 50, 40), new Vector(1, 1, 1), 50000, 20);
    scene.addPointLight(light);
    
    scene.ambientLight = new Vector(0.2, 0.2, 0.2);

    // Start render engine.
    engine.renderer.render();

    // Add FPS counter to top-right corner.
    const fpsCounter = document.createElement("div");
    // Append it to body.
    document.body.appendChild(fpsCounter);
    // Update Counter periodically.
    setInterval(() => {
        fpsCounter.textContent = String(engine.renderer.fps);
    }, 100);
}

// Start scene buider
buildScene(); 