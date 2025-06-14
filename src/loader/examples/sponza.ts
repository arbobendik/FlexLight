"use strict";

import { Instance, Camera, FlexLight, Prototype, Scene, Vector, PointLight, vector_length, vector_scale, normalize, NormalTexture, AlbedoTexture, MetallicTexture, RoughnessTexture, EmissiveTexture, Texture, EnvironmentMap } from '../../flexlight/flexlight.js';
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

const loadObj = async function* (model: string): AsyncGenerator<Prototype> {
    console.log('Loading ' + model);
    const objPath = staticPath + 'objects/' + model + '.obj';
    const mtlPath = staticPath + 'objects/' + model + '.mtl';
    let prototypeGenerator = Prototype.fromObj(objPath, mtlPath);
    // yield prototypeGenerator;
    for await (let prototype of prototypeGenerator) yield prototype;
}

// Load the Cornell box prototype
const sponzaGenerator = loadObj('sponza_ultra');


let normalTextures = new Map<string, Texture>();
let normalTextureIndecies = [0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];

for (let i of normalTextureIndecies) {
    let normalTexture = await loadTexture(staticPath + "textures/sponza/normal/Material_" + i + ".jpg", "normal");
    normalTextures.set("Material_" + i, normalTexture);
}

let albedoTextures = new Map<string, Texture>();
let albedoTextureIndecies = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];

for (let i of albedoTextureIndecies) {
    let albedoTexture = await loadTexture(staticPath + "textures/sponza/albedo/Material_" + i + ".jpg", "albedo");
    albedoTextures.set("Material_" + i, albedoTexture);
}

// let kamenTexture = await loadTexture(staticPath + "textures/sponza/KAMEN.JPG", "albedo");

// Create instances for each part of the Cornell box
const sponzaInstances: Array<Instance> = [];
for await (let prototype of sponzaGenerator) {
    const instance = scene.instance(prototype);
    console.log(prototype.label);
    // instance.material.metallic = 0;
    // instance.material.emissive = new Vector(0.1, 0.1, 0.1);
    /*
    switch (prototype.label) {
        case ":
            instance.albedo = kapitelTexture;
            break;
        case "kamen":
            instance.albedo = kamenTexture;
            break;
    }
    */
    let albedoTexture = albedoTextures.get(prototype.label);
    if (albedoTexture) {
        instance.albedo = albedoTexture;
    }

    let normalTexture = normalTextures.get(prototype.label);
    if (normalTexture) {
        instance.normal = normalTexture;
    }

    instance.material.roughness = 1;
    // instance.material.roughness = 0;
    sponzaInstances.push(instance);
}

scene.ambientLight = new Vector(0.1, 0.1, 0.1);
let environmentMapURL = staticPath + "textures/house_2k.hdr";
fetch(environmentMapURL).then(response => response.arrayBuffer()).then(arrayBuffer => scene.environmentMap = new EnvironmentMap(new DataView(arrayBuffer), 0.25, 0.5));


// Set camera position and direction for a good view of the scene
camera.position = new Vector(10, 1, 0);
camera.direction = new Vector(Math.PI / 2, - 0.25);

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