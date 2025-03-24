"use strict";

import { Camera, FlexLight, Scene, Vector, AlbedoTexture, PointLight, Prototype, Texture, MetallicTexture, RoughnessTexture, NormalTexture, EmissiveTexture, Instance, cross, vector_difference } from '../../flexlight/flexlight.js';
import { createConfigUI } from '../../config-ui/config-ui.js';

const staticPath = './static/';
// Create new canvas
const canvas = document.createElement("canvas");
// Append it to body
document.body.appendChild(canvas);
const engine = new FlexLight(canvas);
engine.io = 'web';

// Create config UI - needs to be called after engine initialization
createConfigUI(engine);

let camera: Camera = engine.camera;
let scene: Scene = engine.scene;

// Load texture function
const loadTexture = async (textureUrl: string, textureType: "normal" | "albedo" | "emissive" | "roughness" | "metallic"): Promise<Texture> => {
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

const loadObj = async (model: string): Promise<Prototype> => {
    console.log('loading ' + model);
    const objPath = staticPath + 'objects/' + model + '.obj';
    const prototype = await Prototype.fromObjStatic(objPath);
    console.log("Loaded prototype", prototype);
    return prototype;
}

// Helper function to create a cuboid
const createCuboid = async (
    xmin: number, xmax: number,
    ymin: number, ymax: number,
    zmin: number, zmax: number
): Promise<Instance> => {
    const cubePrototype = await loadObj('cube');
    const instance = scene.instance(cubePrototype);
    
    // Calculate dimensions
    const width = xmax - xmin;
    const height = ymax - ymin;
    const depth = zmax - zmin;
    
    // Set position to center of cuboid
    instance.transform.position = new Vector(
        (xmin + xmax) / 2,
        (ymin + ymax) / 2,
        (zmin + zmax) / 2
    );
    
    // Scale to match dimensions
    instance.transform.scale(new Vector(width/2, height/2, depth/2));
    
    return instance;
}

// Helper function to create a plane - using quad approach
const createPlane = async (
    p1: Vector<3>, 
    p2: Vector<3>, 
    p3: Vector<3>, 
    p4: Vector<3>
): Promise<Instance> => {
    // Load a plane prototype
    const planePrototype = await loadObj('plane');
    const instance = scene.instance(planePrototype);
    
    // Calculate center
    const center = new Vector<3>(
        (p1.x + p2.x + p3.x + p4.x) / 4,
        (p1.y + p2.y + p3.y + p4.y) / 4,
        (p1.z + p2.z + p3.z + p4.z) / 4
    );
    
    // Position at center
    instance.transform.position = center;
    /*
    // Calculate dimensions (simplified - assumes rectangular planes)
    const maxXDiff = Math.max(Math.max(Math.abs(p1.x - p2.x), Math.abs(p1.x - p3.x),
        Math.max(Math.abs(p2.x - p1.x), Math.abs(p4.x - p3.x)));


    const width = Math.max(
        Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.z - p1.z, 2)),
        Math.sqrt(Math.pow(p4.x - p3.x, 2) + Math.pow(p4.z - p3.z, 2))
    );
    
    const height = Math.max(
        Math.sqrt(Math.pow(p3.x - p2.x, 2) + Math.pow(p3.y - p2.y, 2)),
        Math.sqrt(Math.pow(p4.x - p1.x, 2) + Math.pow(p4.y - p1.y, 2))
    );
    */
    
    // Scale to match dimensions
    // instance.transform.scale(new Vector(width/2, , height/2));

    // Calculate normal vector
    const normal = cross(vector_difference(p1, p3), vector_difference(p1, p2));
    instance.transform.rotateDirection(normal);
    /*
    // Handle rotation based on normal vector (simplified)
    // This is a basic approach - may need refinement for complex orientations
    if (Math.abs(p1.y - p2.y) > 0.01 || Math.abs(p2.y - p3.y) > 0.01) {
        // This is a vertical plane - needs rotation
        // For vertical planes along X axis
        if (Math.abs(p1.z - p2.z) < 0.01) {
            instance.transform.rotateSpherical(0, Math.PI / 2);
        }
        // For other orientations, more complex rotation logic would be needed
    }
    */
    return instance;
}

const buildScene = async (): Promise<void> => {
    // Load wood texture
    const woodTexture = await loadTexture(staticPath + "textures/holz.jpg", "albedo");
    
    // Move camera out of center
    camera.position = new Vector(35, 35, -53);
    camera.direction = new Vector(0.47, 0.44);
    
    // Set ambient light to 0
    scene.ambientLight = new Vector(0.1, 0.1, 0.1);
    
    // Create light sources
    const lightPositions: Array<Vector<3>> = [
        new Vector(-58.03, 26, 7.5),
        new Vector(-58.03, 26, -10.5),
        new Vector(43.03, 26, 0),
        new Vector(43.03, 26, -11.5),
        new Vector(-20, 26, -40),
        new Vector(-10, 26, -40),
        new Vector(0, 26, -40),
        new Vector(10, 26, -40),
        new Vector(20, 26, -40)
    ];
    
    // Add point lights
    lightPositions.forEach(position => {
        const light = new PointLight(position, new Vector(1, 1, 1), 1000, 10);
        scene.addPointLight(light);
    });
    
    // Create bottom plane (floor)
    const bottomPlane = await createPlane(
        new Vector(-43.03, 0, -28), 
        new Vector(43.03, 0, -28), 
        new Vector(43.03, 0, 27.28), 
        new Vector(-43.03, 0, 27.28)
    );
    
    // Create back plane (wall)
    const backPlane = await createPlane(
        new Vector(-24.5, 0, 27.28), 
        new Vector(24.5, 0, 27.28), 
        new Vector(24.5, 22, 27.28), 
        new Vector(-24.5, 22, 27.28)
    );
    
    // Create left plane (wall)
    const leftPlane = await createPlane(
        new Vector(-43.03, 0, 0), 
        new Vector(-24.5, 0, 27.28), 
        new Vector(-24.5, 22, 27.28), 
        new Vector(-43.03, 22, 0)
    );
    
    // Create right plane (wall)
    const rightPlane = await createPlane(
        new Vector(43.03, 0, 0), 
        new Vector(24.5, 0, 27.28), 
        new Vector(24.5, 22, 27.28), 
        new Vector(43.03, 22, 0)
    );
    
    // Set materials for planes
    bottomPlane.albedo = woodTexture as AlbedoTexture;
    bottomPlane.material.roughness = 1.0;
    bottomPlane.material.metallic = 0.3;
    
    backPlane.albedo = woodTexture as AlbedoTexture;
    backPlane.material.roughness = 0.4;
    backPlane.material.metallic = 0.2;
    
    leftPlane.albedo = woodTexture as AlbedoTexture;
    leftPlane.material.roughness = 1.0;
    
    rightPlane.albedo = woodTexture as AlbedoTexture;
    rightPlane.material.roughness = 1.0;
    
    // Create cube in center
    const cube = await createCuboid(-3, 3, 0, 17, 2, 8);
    cube.material.color = new Vector<3>(255/255, 80/255, 120/255);

};


// Start building the scene
buildScene();
engine.renderer.render();

// Add FPS counter to top-right corner
const fpsCounter = document.createElement("div");
// Append it to body.
document.body.appendChild(fpsCounter);
// Update Counter periodically.
setInterval(() => {
	fpsCounter.textContent = String(Math.round(engine.renderer.fps)) + "\n" + String(scene.triangleCount);
}, 1000);
