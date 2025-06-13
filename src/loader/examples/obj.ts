"use strict";

import { createConfigUI } from "../../config-ui/config-ui.js";
import { FlexLight, PointLight, Prototype, Vector, Camera, Scene, AlbedoTexture, EmissiveTexture, MetallicTexture, NormalTexture, RoughnessTexture, Texture, EnvironmentMap } from "../../flexlight/flexlight.js";

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
[camera.position.x, camera.position.y, camera.position.z] = [-10, 10, -10];
[camera.direction.x, camera.direction.y] = [5 * Math.PI / 4, 0.4];


let choose_lights = true;
choose_lights = false;
scene.ambientLight = new Vector(0, 0, 0);

if (choose_lights) {
	let light1 = new PointLight(new Vector(50, 100, -100), new Vector(1, 1, 1), 10000, 10);
	let light2 = new PointLight(new Vector(-100, 100, 50), new Vector(1, 1, 1), 10000, 10);
	let light3 = new PointLight(new Vector(-100, 100, -100), new Vector(1, 1, 1), 10000, 10);

	scene.addPointLight(light1);
	scene.addPointLight(light2);
	scene.addPointLight(light3);

}

if (!choose_lights) {
	let light1 = new PointLight(new Vector(0, 0, 0), new Vector(1, 1, 1), 0, 10);
	scene.addPointLight(light1);
	// engine.renderer.fpsLimit = 600;
	let environmentMapURL = staticPath + "textures/house_2k.hdr";
	fetch(environmentMapURL).then(response => response.arrayBuffer()).then(arrayBuffer => scene.environmentMap = new EnvironmentMap(new DataView(arrayBuffer), 0.0625, 0.5));
}
// }
/*
*/

// console.log(search.getAll());


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
// let plane = await loadObj('plane2');
// let dragon = await loadObj('dragon_lp');
// let fullScene = await loadObj('sinan');
let sphere = await loadObj('sphere');
// let monkey = await loadObj('monke');

// const fullScene1 = scene.instance(fullScene);
// const cube1 = scene.instance(cube);


for (let i = 0; i < 5; i++) {
	for (let j = 0; j < 5; j++) {
		for (let k = 0; k < 5; k++) {
			let dragon_instance = scene.instance(sphere);
			dragon_instance.transform.position = new Vector(2*j + 2, 2*k - 2.5, 2*i + 2 );
			
			dragon_instance.material.roughness = j * 1 / 5;
			dragon_instance.material.transmission = k / 5;
			dragon_instance.material.metallic = 1.0 - i / 5;
			dragon_instance.material.color = new Vector(1.0, 0.5, 0.5);
			/*
			// init iterator variable for simple animations
			let iterator = 0;

			setInterval(() => {
				// increase iterator
				iterator += 0.001;// + 0.0005 * j + 0.0007 * i;
				// precalculate sin and cos
				dragon_instance.transform.rotateAxis(new Vector(0, 1, 0), iterator);
				// transform3.rotateAxis(new Vector(0, 1, 0), iterator);
			}, 100/6);
			*/
		}
	}
}


/*
let dragon_instance = scene.instance(dragon);
dragon_instance.transform.position = new Vector(0, 0, -20);
dragon_instance.transform.scale(1);
dragon_instance.material.roughness = 0.5;
dragon_instance.material.metallic = 1.0;
*/
/*


// init iterator variable for simple animations
let iterator = 0;


setInterval(() => {
	// increase iterator
	iterator += 0.005;
	// precalculate sin and cos
	dragon_instance.transform.rotateAxis(new Vector(0, 1, 0), iterator);
	// dragon_instance.transform.position = new Vector(Math.sin(iterator) * 10, Math.cos(iterator) * 10, -20);
	// transform3.rotateAxis(new Vector(0, 1, 0), iterator);
}, 100/6);
*/

// instance2.transform.position = new Vector(-30, 0, 0);

// sphere1.transform.position = new Vector(0, 10, 0);

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
