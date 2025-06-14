"use strict";

/*
@misc{ZeroDay,
   title = {Zero-Day, Open Research Content Archive (ORCA)},
   author = {Mike Winkelmann},
   year = {2019},
   month = {November},
   note = {\small \texttt{https://developer.nvidia.com/orca/beeple-zero-day}},
   url = {https://developer.nvidia.com/orca/beeple-zero-day}
}
*/

import { createConfigUI } from "../../config-ui/config-ui.js";
import { FlexLight, PointLight, Instance, Prototype, Vector, Camera, Scene, AlbedoTexture, EmissiveTexture, MetallicTexture, NormalTexture, RoughnessTexture, Texture, EnvironmentMap } from "../../flexlight/flexlight.js";

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
[camera.direction.x, camera.direction.y] = [5 * Math.PI / 4, 0.4];

const loadGltf = async function* (model: string): AsyncGenerator<Prototype> {
    console.log('Loading ' + model);
    const gltfPath = staticPath + 'objects/local/' + model + '.gltf';
    let prototypeGenerator = Prototype.fromGltf(gltfPath);
    // yield prototypeGenerator;
    for await (let prototype of prototypeGenerator) yield prototype;
}

let mesh = loadGltf('cornell');
console.log(mesh);

let meshInstances: Array<Instance> = [];
for await (let prototype of mesh) {
	const mesh_instance = scene.instance(prototype);
	// mesh_instance.transform.scale(0.01);
	mesh_instance.transform.position = new Vector(20, 0, 20);
	mesh_instance.material.roughness = 1.0;
	mesh_instance.material.metallic = 0.0;
	meshInstances.push(mesh_instance);
}

// Add ambient light
scene.ambientLight = new Vector(0.1, 0.1, 0.1);

// Start rendering
engine.renderer.render();

console.log("Kitchen instances:", meshInstances);

// Add FPS counter to top-right corner
const fpsCounter = document.createElement("div");
// Append it to body.
document.body.appendChild(fpsCounter);
// Update Counter periodically.
setInterval(() => {
	fpsCounter.textContent = String(Math.round(engine.renderer.fps)) + "\n" + String(scene.triangleCount);
}, 1000);
