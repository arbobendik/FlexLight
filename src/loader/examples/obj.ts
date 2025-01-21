"use strict";

// @ts-ignore
import { createConfigUI } from "../../config-ui/config-ui.js";
import { FlexLight, PointLight, Prototype, Vector, Camera, Scene } from "../../flexlight/flexlight.js";

const staticPath = './static/';
// Create new canvas
const canvas = document.createElement("canvas");
// Append it to body
document.body.appendChild(canvas);
// Create new engine object for canvas

console.log(canvas.clientWidth, canvas.clientHeight);


const engine = new FlexLight (canvas);
console.log(canvas.clientWidth, canvas.clientHeight);
engine.io = 'web';



const controlPanel = document.getElementById("controlPanel");
if (!controlPanel) throw new Error("Control panel not found");

const configUI = createConfigUI(engine);
controlPanel.appendChild(configUI);

console.log(canvas.clientWidth, canvas.clientHeight);



let camera: Camera = engine.camera;
let scene: Scene = engine.scene;
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
[camera.position.x, camera.position.y, camera.position.z] = [-10, 10, 10];
[camera.direction.x, camera.direction.y] = [-2.38, 0.8];

let light1 = new PointLight(new Vector(100, 100, 100), new Vector(1, 0, 0), 20000, 0);
let light2 = new PointLight(new Vector(-100, 100, -100), new Vector(0, 1, 1), 50000, 0);
let light3 = new PointLight(new Vector(-100, 100, 100), new Vector(0, 0, 1), 50000, 0);

scene.addPointLight(light1);
scene.addPointLight(light2);
scene.addPointLight(light3);

scene.ambientLight = new Vector(0.1, 0.1, 0.1);

// scene.queue.push(plane);

console.log(canvas.clientWidth, canvas.clientHeight);
// Start render engine.
engine.renderer.render();
console.log(canvas.clientWidth, canvas.clientHeight);
// engine.renderer.fpsLimit = 1;

// const search = new URLSearchParams(location.search);
let urlParams = new URL(String(document.location)).searchParams;



// console.log(search.getAll());


const loadObj = async (model: string) => {	
	console.log('loading ' + model);
	const objPath = staticPath + 'objects/' + model + '.obj';
	const mtlPath = staticPath + 'objects/' + model + '.mtl';
	const prototype = await Prototype.fromObj(objPath, mtlPath);
	console.log("Loaded prototype", prototype);
	return prototype;
}

// let model = urlParams.get('model') ?? 'sphere';
// let prototype = await loadObj(model);
let cube = await loadObj('cube');
// let dragon = await loadObj('dragon');
let monkey = await loadObj('monke');
let sphere = await loadObj('sphere');
// let bike = await loadObj('bike');

const cube1 = scene.instance(cube);
const monkey1 = scene.instance(monkey);
const sphere1 = scene.instance(sphere);
const sphere2 = scene.instance(sphere);
// const dragon1 = new Instance(dragon);
// const dragon2 = new Instance(dragon);

// const bike1 = new Instance(bike);
// const sphere1 = scene.instance(sphere);
// const monkey1 = scene.instance(monkey);

cube1.transform.position = new Vector(0, -102, 0);
cube1.transform.scaleFactor = 100;
cube1.material.roughness = 1.0;
cube1.material.metallic = 0.0;

sphere1.transform.position = new Vector(10, 0, 0);
sphere2.transform.position = new Vector(-10, 0, 0);
// instance2.transform.position = new Vector(-30, 0, 0);

// sphere1.transform.position = new Vector(0, 10, 0);



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
