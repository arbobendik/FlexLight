"use strict";

import { createConfigUI } from "../../config-ui/config-ui.js";
import { FlexLight, PointLight, Prototype, Vector, Camera, Scene, AlbedoTexture, EmissiveTexture, MetallicTexture, NormalTexture, RoughnessTexture, Texture, EnvironmentMap, normalize, vector_add } from "../../flexlight/flexlight.js";

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
[camera.position.x, camera.position.y, camera.position.z] = [-22.4, 9.4, 21.3];
[camera.direction.x, camera.direction.y] = [- 2.45, 0.1];

let light1 = new PointLight(new Vector(110, 110, 110), new Vector(1, 0.5, 0.5), 0, 10);
// let light2 = new PointLight(new Vector(-110, 110, -110), new Vector(0.5, 0.5, 1), 50000, 10);
// let light3 = new PointLight(new Vector(-110, 100, 100), new Vector(1, 1, 1), 100000, 10);
scene.addPointLight(light1);

scene.ambientLight = new Vector(0.1, 0.1, 0.1);
let environmentMapURL = staticPath + "textures/house_8k.hdr";
fetch(environmentMapURL).then(response => response.arrayBuffer()).then(arrayBuffer => scene.environmentMap = new EnvironmentMap(new DataView(arrayBuffer), 0.25, 0.5));

const loadObj = async (model: string) => {	
	console.log('loading ' + model);
	const objPath = staticPath + 'objects/' + model + '.obj';
	// const mtlPath = staticPath + 'objects/' + model + '.mtl';
	const prototype = await Prototype.fromObjStatic(objPath);
	console.log("Loaded prototype", prototype);
	return prototype;
}

// let model = urlParams.get('model') ?? 'sphere';
// let prototype = await loadObj(model);
// let cube = await loadObj('cube');
let plane = await loadObj('plane2');
let dragon = await loadObj('dragon');
let statue = await loadObj('monke_smooth');
let robot = await loadObj('robot');
let sphere = await loadObj('sphere');
let monkey = await loadObj('monke');

// const fullScene1 = scene.instance(fullScene);
// const cube1 = scene.instance(cube);
const groundPlane = scene.instance(plane);
// const cube2 = scene.instance(cube);

const monkey1 = scene.instance(monkey);


const sphere_rusted = scene.instance(sphere);
const sphere_metallic = scene.instance(sphere);
const sphere_diffuse = scene.instance(sphere);
const sphere_rough_metal = scene.instance(sphere);
const sphere_rough_diffuse = scene.instance(sphere);

groundPlane.transform.position = new Vector(0, -2, 0);
groundPlane.transform.scale(30);

groundPlane.material.roughness = 0.6;
groundPlane.material.metallic = 0;
groundPlane.albedo = await loadTexture(staticPath + "textures/stonework/albedo.png", "albedo");
// groundPlane.normal = await loadTexture(staticPath + "textures/stonework/normal.png", "normal");
groundPlane.roughness = await loadTexture(staticPath + "textures/stonework/roughness.png", "roughness");

monkey1.transform.position = new Vector(5, 1, 0);
// monkey1.transform.scale(new Vector(3, 1.8, 0.5));
monkey1.material.roughness = 0;
monkey1.material.metallic = 0;
monkey1.material.transmission = 1;
monkey1.material.ior = 1.5;

//sphere1.transform.position = new Vector(10, 0, 0);
sphere_metallic.transform.position = new Vector(10, 0, 0);
sphere_diffuse.transform.position = new Vector(13, 0, 0);
sphere_rough_metal.transform.position = new Vector(16, 0, 0);
sphere_rough_diffuse.transform.position = new Vector(19, 0, 0);

sphere_rusted.transform.position = new Vector(10, 0, -3);

sphere_metallic.material.roughness = 0.1;
sphere_metallic.material.metallic = 1.0;

sphere_diffuse.material.roughness = 0.5;
sphere_diffuse.material.metallic = 1.0;

sphere_rough_metal.material.roughness = 0.7;
sphere_rough_metal.material.metallic = 0.5;

sphere_rough_diffuse.material.metallic = 0.0;
sphere_rough_diffuse.material.roughness = 1.0;
sphere_rough_diffuse.material.emissive = new Vector(10, 2, 2);

sphere_rusted.albedo = await loadTexture(staticPath + "textures/rusted/albedo.png", "albedo");
sphere_rusted.roughness = await loadTexture(staticPath + "textures/rusted/roughness.png", "roughness");
sphere_rusted.metallic = await loadTexture(staticPath + "textures/rusted/metallic.png", "metallic");
sphere_rusted.normal = await loadTexture(staticPath + "textures/rusted/normal.png", "normal");

let dragon_instance = scene.instance(dragon);
dragon_instance.transform.position = new Vector(2.5, -0.75, -20);
dragon_instance.transform.scale(0.75);
dragon_instance.material.roughness = 0
dragon_instance.material.metallic = 1;


let statue_instance = scene.instance(statue);
statue_instance.transform.position = new Vector(13, 2, -8);
statue_instance.transform.rotateAxis(new Vector(0, 1, 0), Math.PI / 4);
statue_instance.transform.scale(2);
statue_instance.material.roughness = 0;
statue_instance.material.metallic = 0;
statue_instance.material.ior = 2.5;
statue_instance.material.color = new Vector(0.1, 0.1, 1);

let robot_instance = scene.instance(robot);
statue_instance.transform.rotateAxis(new Vector(0, 1, 0), Math.PI / 2);
robot_instance.transform.position = new Vector(0, -2, -10);
robot_instance.transform.scale(2);
robot_instance.material.roughness = 0.1;
robot_instance.material.metallic = 1;
robot_instance.material.color = new Vector(1, 0.784, 0.392);


for (let i = 0; i < 5; i++) {
	for (let j = 0; j < 5; j++) {
		for (let k = 0; k < 1; k++) {
			let sphere_instance = scene.instance(sphere);
			sphere_instance.transform.rotateAxis(new Vector(0, 1, 0), Math.PI / 4);
			sphere_instance.transform.position = vector_add(new Vector(12, 1, - 16), new Vector(Math.sqrt(2) * i, 2 * j, Math.sqrt(2) * i));
			sphere_instance.material.roughness = 0;
			sphere_instance.material.transmission = j / 5;
			sphere_instance.material.metallic = 1.0 - i / 5;
			sphere_instance.material.color = new Vector(1.0, 0.25, 0.25);
		}
	}
}

// Init iterator variable for simple animations
let iterator = 0;

setInterval(() => {
	// increase iterator
	// iterator += 0.002;
	// precalculate sin and cos
	dragon_instance.transform.rotateAxis(new Vector(0, 1, 0), iterator);
	// dragon_instance.transform.position = new Vector(Math.sin(iterator) * 10, Math.cos(iterator) * 10, -20);
	// transform3.rotateAxis(new Vector(0, 1, 0), iterator);
}, 100/6);



/*
let selected: Instance | null = null;
let selectedAlbedoTexture: AlbedoTexture | null = null;
let selectedOriginalColor: Vector<3> = new Vector(0, 0, 0);
setInterval(() => {
	let newSelected = engine.ui.selected;
	if (selected !== newSelected) {
		if (selected) {
			// Restore original color
			selected.material.color = selectedOriginalColor;
			// Restore original albedo texture
			if (selectedAlbedoTexture) selected.albedo = selectedAlbedoTexture;
		}
		// Swap variables
		selected = newSelected;
		if (selected) {
			// Save original color
			selectedOriginalColor = selected.material.color;
			// Save original albedo texture
			selectedAlbedoTexture = selected.albedo ?? null;
			// Set new color
			selected.material.color = new Vector(1, 0, 0);
			// Set albedo texture to undefined
			selected.albedo = undefined;
		}
	}
}, 10);
*/

// Start render engine.
engine.renderer.render();
// Add FPS counter to top-right corner
const fpsCounter = document.createElement("div");
// Append it to body.
document.body.appendChild(fpsCounter);
// Update Counter periodically.
setInterval(() => {
	fpsCounter.textContent = String(Math.round(engine.renderer.fps)) + "\n" + String(scene.triangleCount);
}, 1000);
