"use strict";
// @ts-ignore
import { createConfigUI } from "../../config-ui/config-ui.js";
// import { vector_difference, vector_length } from "../../flexlight/common/lib/math.js";
import { FlexLight, PointLight, Prototype, Vector, BIAS_16, NormalTexture, AlbedoTexture, MetallicTexture, RoughnessTexture, EmissiveTexture, Texture } from "../../flexlight/flexlight.js";

export const staticPath = './static/';
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


const loadObj = async (model: string) => {
    console.log('loading ' + model);
    const objPath = staticPath + 'objects/' + model + '.obj';
    // const mtlPath = staticPath + 'objects/' + model + '.mtl';
    const prototype = await Prototype.fromObjStatic(objPath);
    console.log("Loaded prototype", prototype);
    return prototype;
};

// Set camera perspective and position.
[camera.position.x, camera.position.y, camera.position.z] = [-10, 14, 10];
[camera.direction.x, camera.direction.y] = [-.9, .45];

/*
let environmentMapURL = staticPath + "textures/house_2k.hdr";
fetch(environmentMapURL).then(response => response.arrayBuffer()).then(arrayBuffer => scene.environmentMap = new EnvironmentMap(new DataView(arrayBuffer), 0.0125, 1, 1));

*/
let light1 = new PointLight(new Vector(30, 20.5, -30), new Vector(1, 1, 1), 1500, 2);
scene.ambientLight = new Vector(0.0, 0.0, 0.0);
scene.addPointLight(light1);
// scene.ambientLight = new Vector(0.025, 0.025, 0.025);


const plane = await loadObj('plane');
const glass = await loadObj('glass_new');

let planeInstance = scene.instance(plane);
planeInstance.transform.move(0, -1, 0);
planeInstance.transform.scale(50);
planeInstance.material.roughness = 1;
planeInstance.material.metallic = 0;


let glassInstance = scene.instance(glass);
// glassInstance.normal = await loadTexture(staticPath + 'textures/wet_glass_normal.jpg', 'normal');
// glassInstance.roughness = await loadTexture(staticPath + 'textures/fingerprints.jpg', 'roughness');
glassInstance.transform.move(15, -1 + BIAS_16, -15);
glassInstance.transform.scale(new Vector(5, 5, 5));
glassInstance.material.color = new Vector(0.0, 0.4, 1.0);
glassInstance.material.roughness = 0;
glassInstance.material.metallic = 0;
glassInstance.material.transmission = 1;
glassInstance.material.ior = 1.5;

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