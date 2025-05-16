"use strict";

import { createConfigUI } from "../../config-ui/config-ui.js";
import { FlexLight, PointLight, Prototype, Vector, Camera, Scene, AlbedoTexture, EmissiveTexture, MetallicTexture, NormalTexture, RoughnessTexture, Texture } from "../../flexlight/flexlight.js";

export const staticPath = './static/';
// Create new canvas
const canvas = document.createElement("canvas");
// Append it to body
document.body.appendChild(canvas);
// Create new engine object for canvas
const engine = new FlexLight (canvas);
engine.io = 'web';



const controlPanel = document.getElementById("controlPanel");
if (!controlPanel) throw new Error("Control panel not found");

const configUI = createConfigUI(engine);
controlPanel.appendChild(configUI);


const loadTexture = async (textureUrl: string, textureType: "normal" | "albedo" |  "emissive" | "roughness" | "metallic"): Promise<Texture> => {
	let promise = new Promise<HTMLImageElement>((resolve) => {
		let img = new Image();
		img.onload = () => resolve(img);
		img.src = textureUrl;
	});

	let img = await promise;
	switch (textureType) {
		case "normal":
			return new NormalTexture(img);
		case "albedo":
			return new AlbedoTexture(img);
		case "emissive":
			return new EmissiveTexture(img);
		case "roughness":
			return new RoughnessTexture(img);
		case "metallic":
			return new MetallicTexture(img);
	}
}


let camera: Camera = engine.camera;
let scene: Scene = engine.scene;

// Set camera perspective and position.
[camera.position.x, camera.position.y, camera.position.z] = [-10, 10, 10];
[camera.direction.x, camera.direction.y] = [-2.38, 0.4];

let light1 = new PointLight(new Vector(0, -2, 0), new Vector(1, 0, 0), 5000, 10);
let light2 = new PointLight(new Vector(0, -2, 50), new Vector(0, 0, 1), 5000, 10);
let light3 = new PointLight(new Vector(0, 20, 100), new Vector(1, 1, 1), 10000, 20);
let light4 = new PointLight(new Vector(0, 20, -70), new Vector(1, 1, 1), 10000, 20);

scene.addPointLight(light1);
scene.addPointLight(light2);
scene.addPointLight(light3);
scene.addPointLight(light4);

scene.ambientLight = new Vector(0.1, 0.1, 0.1);

// Start render engine.
engine.renderer.render();

const loadObj = async (model: string) => {	
	console.log('loading ' + model);
	const objPath = staticPath + 'objects/' + model + '.obj';
	// const mtlPath = staticPath + 'objects/' + model + '.mtl';
	const prototype = await Prototype.fromObjStatic(objPath);
	console.log("Loaded prototype", prototype);
	return prototype;
}

let tentative = await loadObj('local/tentative_blend');
let monkey = await loadObj('monke');

const tentativeInstance = scene.instance(tentative);
tentativeInstance.transform.position = new Vector(0, -32, 0);
tentativeInstance.transform.scale(30);
tentativeInstance.material.color = new Vector(0.7, 0.7, 0.7);
tentativeInstance.material.roughness = 0.4;
tentativeInstance.material.metallic = 0.3;

const monkeyInstanceRed = scene.instance(monkey);
monkeyInstanceRed.transform.position = new Vector(0, -2, 0);
monkeyInstanceRed.transform.scale(5);
monkeyInstanceRed.material.roughness = 1;
monkeyInstanceRed.material.metallic = 0;
monkeyInstanceRed.material.emissive = new Vector(5, 0, 0);

const monkeyInstanceBlue = scene.instance(monkey);
monkeyInstanceBlue.transform.position = new Vector(0, -2, -50);
monkeyInstanceBlue.transform.scale(5);
monkeyInstanceBlue.material.roughness = 1;
monkeyInstanceBlue.material.metallic = 0;
monkeyInstanceBlue.material.emissive = new Vector(0, 0, 5);


// Add FPS counter to top-right corner
const fpsCounter = document.createElement("div");
// Append it to body.
document.body.appendChild(fpsCounter);
// Update Counter periodically.
setInterval(() => {
	fpsCounter.textContent = String(Math.round(engine.renderer.fps)) + "\n" + String(scene.triangleCount);
}, 1000);
