"use strict";
// @ts-ignore
import { createConfigUI } from "../../config-ui/config-ui.js";
import { FlexLight, Instance, PointLight, Prototype, Vector, Transform } from "../../flexlight/flexlight.js";
const staticPath = './static/';
// Create new canvas
const canvas = document.createElement("canvas");
// Append it to body
document.body.appendChild(canvas);
// Create new engine object for canvas
const engine = new FlexLight(canvas);
engine.io = 'web';
const controlPanel = document.getElementById("controlPanel");
if (!controlPanel)
    throw new Error("Control panel not found");
const configUI = createConfigUI(engine);
controlPanel.appendChild(configUI);
let camera = engine.camera;
let scene = engine.scene;
/*
[
    staticPath + "textures/grass.jpg",     // 0
].forEach(item => {
    let img = new Image();
    img.src = item;
    scene.textures.push(img);
});
*/
// Set camera perspective and position.
[camera.position.x, camera.position.y, camera.position.z] = [-50, 50, 50];
[camera.direction.x, camera.direction.y] = [-2.38, 0.8];
let light1 = new PointLight(new Vector(100, 500, 100), new Vector(2000000, 0, 0), 100);
let light2 = new PointLight(new Vector(-100, 100, 500), new Vector(1500000, 0, 0), 100);
scene.addPointLight(light1);
scene.addPointLight(light2);
scene.ambientLight = new Vector(0.01, 0.01, 0.01);
// scene.queue.push(plane);
// Start render engine.
engine.renderer.render();
engine.renderer.fpsLimit = 100;
// const search = new URLSearchParams(location.search);
let urlParams = new URL(String(document.location)).searchParams;
// console.log(search.getAll());
const loadObj = async (model) => {
    console.log('loading ' + model);
    const objPath = staticPath + 'objects/' + model + '.obj';
    const mtlPath = staticPath + 'objects/' + model + '.mtl';
    const prototype = await Prototype.fromObj(objPath, mtlPath);
    console.log("Loaded prototype", prototype);
    return prototype;
};
let model = urlParams.get('model') ?? 'sphere';
let prototype = await loadObj(model);
let dragon = await loadObj('dragon');
let sphere = await loadObj('sphere');
let monkey = await loadObj('monke');
let bike = await loadObj('bike');
const instance1 = new Instance(prototype);
const instance2 = new Instance(prototype);
const dragon1 = new Instance(dragon);
const dragon2 = new Instance(dragon);
const bike1 = new Instance(bike);
const sphere1 = new Instance(sphere);
const monkey1 = new Instance(monkey);
let transform = new Transform();
instance1.transform = transform;
transform.position = new Vector(30, 0, 0);
let transform2 = new Transform();
transform2.position = new Vector(0, 10, 0);
sphere1.transform = transform2;
let transform3 = new Transform();
transform3.position = new Vector(0, -20, 30);
bike1.transform = transform3;
let transform4 = new Transform();
transform4.position = new Vector(0, 0, 10);
monkey1.transform = transform4;
let transform5 = new Transform();
transform5.position = new Vector(0, -20, 0);
dragon1.transform = transform5;
let transform6 = new Transform();
transform6.position = new Vector(0, -50, 0);
dragon2.transform = transform6;
scene.addInstance(monkey1);
scene.addInstance(instance1);
scene.addInstance(instance2);
scene.addInstance(dragon1);
scene.addInstance(sphere1);
scene.addInstance(bike1);
scene.addInstance(dragon2);
console.log(scene.instanceManager.bufferView);
// obj.emissiveness = 0;
// obj.scale(5);
// obj.move(5, 0, - 5);
/*
obj.roughness = .1;
console.log(obj);
obj.metallicity = 0.1;
obj.translucency = 0.9;
obj.ior = 9.5;
obj.color = [255, 200, 90];
*/
// scene.queue.push(obj);
// engine.renderer.updateScene();
// Add FPS counter to top-right corner
const fpsCounter = document.createElement("div");
// Append it to body.
document.body.appendChild(fpsCounter);
// setTimeout(() => engine.renderer.freeze = true, 1000);
/*
// init iterator variable for simple animations
let iterator = 0;

setInterval(() => {
    // increase iterator
    iterator += 0.01;
    // precalculate sin and cos
    transform2.rotateAxis(new Vector(0, 1, 0), iterator);
    // transform3.rotateAxis(new Vector(0, 1, 0), iterator);
}, 100/6);
*/
// Update Counter periodically.
setInterval(() => {
    fpsCounter.textContent = String(Math.round(engine.renderer.fps));
}, 1000);
