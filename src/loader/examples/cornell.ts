"use strict";

import { Instance, Camera, FlexLight, Prototype, Scene, Vector, PointLight, vector_length, vector_scale, normalize } from '../../flexlight/flexlight.js';
import { createConfigUI } from '../../config-ui/config-ui.js';

const staticPath = './static/';
// Create new canvas
const canvas = document.createElement("canvas");
// Append it to body
document.body.appendChild(canvas);
// Create new engine object for canvas
const engine = new FlexLight(canvas);
engine.io = 'web';

const controlPanel = document.getElementById("controlPanel");
if (!controlPanel) throw new Error("Control panel not found");

const configUI = createConfigUI(engine);
controlPanel.appendChild(configUI);

let camera: Camera = engine.camera;
export let scene: Scene = engine.scene;

const loadObj = async function* (model: string): AsyncGenerator<Prototype> {
    console.log('Loading ' + model);
    const objPath = staticPath + 'objects/' + model + '.obj';
    const mtlPath = staticPath + 'objects/' + model + '.mtl';
    let prototypeGenerator = Prototype.fromObj(objPath, mtlPath);
    // yield prototypeGenerator;
    for await (let prototype of prototypeGenerator) yield prototype;
}

// Load the Cornell box prototype
const cornellGenerator = loadObj('cornell');

// Create instances for each part of the Cornell box
const cornellInstances: Array<Instance> = [];
for await (let prototype of cornellGenerator) {
    const instance = scene.instance(prototype);
    // instance.material.metallic = 0;
    // instance.material.roughness = 1;
    cornellInstances.push(instance);
}

// Set material properties based on the MTL file

const [floor, ceiling, backWall, rightWall, leftWall, shortBox, tallBox, light] = cornellInstances;

if (!floor || !ceiling || !backWall || !rightWall || !leftWall || !shortBox || !tallBox || !light) {
    throw new Error("Failed to load all Cornell box instances");
}
/*
floor.material.color = new Vector(.7295, .7355, .729);
ceiling.material.color = new Vector(.7295, .7355, .729);
backWall.material.color = new Vector(.7295, .7355, .729);
rightWall.material.color = new Vector(.117, .4125, .115);
leftWall.material.color = new Vector(.611, .0555, .062);
shortBox.material.color = new Vector(.7295, .7355, .729);
tallBox.material.color = new Vector(.7295, .7355, .729);
*/
let frac = 255/255;
floor.material.color = new Vector(frac, frac, frac);
ceiling.material.color = new Vector(frac, frac, frac);
backWall.material.color = new Vector(frac, frac, frac);
rightWall.material.color = new Vector(0, frac, 0);
leftWall.material.color = new Vector(frac, 0, 0);
shortBox.material.color = new Vector(frac, frac, frac);
tallBox.material.color = new Vector(frac, frac, frac);

tallBox.material.metallic = 1;
tallBox.material.roughness = 0;

let emissive: Vector<3> = new Vector(16.86, 8.76 + 2., 3.2 + .5);

let emissiveLength = vector_length(emissive);
let emissiveColor: Vector<3> = normalize(emissive);
light.material.emissive = vector_scale(emissiveColor, emissiveLength * 4); // Emissive light


console.log(emissiveColor.x, emissiveColor.y, emissiveColor.z, emissiveLength);
// Add a point light at the center of the area light


const pointLight = new PointLight(
    new Vector(0, 1.97, 0),  // Center of the area light
    emissiveColor,           // White light
    emissiveLength * 0,    // Intensity
    0.22                      // Variation
);

console.log(pointLight);

scene.addPointLight(pointLight);

// Set camera position and direction for a good view of the scene
camera.position = new Vector(0, 1, 5);
camera.direction = new Vector(0, 0);

// Add ambient light
scene.ambientLight = new Vector(0, 0, 0);

// Start rendering
engine.renderer.render();

// Add FPS counter to top-right corner
const fpsCounter = document.createElement("div");
document.body.appendChild(fpsCounter);
setInterval(() => {
    fpsCounter.textContent = String(Math.round(engine.renderer.fps)) + "\n" + String(scene.triangleCount);
}, 1000); 