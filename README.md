# FlexLight Render Engine for the Web

## TypeScript + WebGPU (WebGL 2 fallback planned)

### [Live Demo]( https://arbogast.dev/FlexLight/loader.html?v=example2)

### Description

FlexLight is a high-performance rendering engine designed for the web, built with TypeScript. It leverages modern web technologies like WebGPU (with plans for WebGL 2 fallback) to render complex 3D scenes in real-time directly within a browser canvas.

The engine currently supports path tracing and rasterization techniques. It can load `.obj` models, manage materials (including PBR properties like roughness, metallic, and emissive), handle various light types (PointLights, AmbientLight, Environment Maps), and apply post-processing effects like FXAA and TAA.

Scenes are structured efficiently using internal acceleration structures (like BVHs) to optimize rendering performance.

### Core Concepts

*   **`FlexLight`**: The main engine class. It orchestrates the renderer, scene, camera, and I/O handling.
*   **`Scene`**: Manages all the objects, lights, and textures within the 3D world.
*   **`Camera`**: Defines the viewpoint and projection for rendering the scene.
*   **`Prototype`**: Represents the geometry and material data loaded from sources like `.obj` files. It's a template for creating renderable objects.
*   **`Instance`**: A specific occurrence of a `Prototype` in the scene, with its own position, rotation, and scale (`Transform`).
*   **`PointLight`**: A light source emitting light uniformly in all directions from a single point.
*   **`Vector`**: A utility class for representing 3D points, directions, and colors.
*   **`Config`**: Holds configuration settings for the renderer, such as quality, samples per ray, and anti-aliasing modes.

### Getting Started

1.  **HTML Setup**: You need an HTML file with a `<canvas>` element.

    ```html
    <!DOCTYPE html>
    <html>
    <head>
        <title>FlexLight Example</title>
        <style>
            body { margin: 0; overflow: hidden; }
            canvas { display: block; width: 100vw; height: 100vh; }
        </style>
    </head>
    <body>
        <canvas id="renderCanvas"></canvas>
        <script type="module" src="your-script.js"></script> 
    </body>
    </html>
    ```

2.  **TypeScript Initialization**: In your TypeScript file (which compiles to `your-script.js`), import `FlexLight` and initialize it with the canvas.

    ```typescript
    import { FlexLight, Scene, Camera, Vector, PointLight, Prototype } from 'flexlight'; // Adjust path as needed

    // Get the canvas element.
    const canvas: HTMLCanvasElement | null = document.getElementById("renderCanvas") as HTMLCanvasElement;

    if (!canvas) {
        throw new Error("Canvas element not found.");
    }

    // Create a new FlexLight engine instance.
    const engine: FlexLight = new FlexLight(canvas);

    // Set up IO handling (optional, defaults to 'web').
    // engine.io = 'web'; // Already the default

    // Access scene and camera.
    const scene: Scene = engine.scene;
    const camera: Camera = engine.camera;

    // --- Scene setup code goes here ---

    // Start the rendering loop.
    engine.renderer.render(); 
    ```

### Example Usage

Here's how to set up a basic scene:

```typescript
import { FlexLight, Scene, Camera, Vector, PointLight, Prototype, Instance } from 'flexlight'; // Adjust path as needed

// --- Assume engine, scene, camera are initialized as above ---

// 1. Configure the Camera.
camera.position = new Vector(-10, 5, -15); // Set camera position.
camera.direction = new Vector(-0.4, 0.2);  // Set camera look direction (azimuth, altitude).

// 2. Add Lights.
// Add a point light.
const lightPosition: Vector<3> = new Vector(0, 10, 0);
const lightColor: Vector<3> = new Vector(1, 1, 1); // White light.
const lightIntensity: number = 500;
const lightVariance: number = 0.1; // Affects soft shadows for path tracing.
const myLight: PointLight = new PointLight(lightPosition, lightColor, lightIntensity, lightVariance);
scene.addPointLight(myLight);

// Set ambient light (a subtle global illumination).
scene.ambientLight = new Vector(0.1, 0.1, 0.1);

// 3. Load a Model Prototype (e.g., a cube).
// Assumes 'cube.obj' is available at the specified path.
const staticPath: string = './static/'; // Adjust if needed.
const cubeObjPath: string = staticPath + 'objects/cube.obj';
let cubePrototype: Prototype; 
try {
    cubePrototype = await Prototype.fromObjStatic(cubeObjPath);
    console.log("Cube prototype loaded successfully.");
} catch (error) {
    console.error("Failed to load cube prototype:", error);
    throw error; // Or handle appropriately
}

// 4. Create Instances from the Prototype.
// Create an instance of the cube.
const cubeInstance: Instance = scene.instance(cubePrototype);

// Position the cube instance.
cubeInstance.transform.position = new Vector(0, 0, 0);

// Scale the cube instance (optional).
cubeInstance.transform.scale(new Vector(2, 2, 2)); // Make it 2x size in all dimensions.

// Create another instance.
const secondCubeInstance: Instance = scene.instance(cubePrototype);
secondCubeInstance.transform.position = new Vector(5, 0, 2);
secondCubeInstance.transform.rotation = new Vector(0, Math.PI / 4, 0); // Rotate 45 degrees around Y axis.

// --- Instances are automatically added to the scene's internal structures ---

// 5. Start Rendering (already called in Getting Started).
// engine.renderer.render(); 
```

### Configuration

You can adjust rendering quality and features via the `engine.config` object:

```typescript
// Access the configuration object.
const config: Config = engine.config;

// Set the number of samples per ray (for path tracing). Higher values mean less noise but lower performance.
config.samplesPerRay = 4;

// Set the maximum number of light bounces (for path tracing).
config.maxReflections = 8;

// Set the anti-aliasing method ('fxaa', 'taa', or undefined).
config.antialiasing = 'fxaa'; 

// Enable/disable temporal accumulation (smooths results over time, requires TAA or temporal flag).
config.temporal = true;

// Enable/disable High Dynamic Range rendering pipeline.
config.hdr = true;

// Adjust render resolution scaling (1 = native, <1 = lower res, >1 = supersampling).
config.renderQuality = 1.0; 

// Minimum importance for a ray path to be continued (path tracing optimization).
config.minImportancy = 0.2; 
```

*(Note: Changes to `config` might require the renderer to be updated or recreated depending on the specific setting.)*

### Performance

FlexLight uses several techniques to achieve high performance:

*   **GPU Acceleration**: Leverages WebGPU (or WebGL 2) for massively parallel rendering calculations.
*   **Optimized Data Structures**: Scene geometry is organized in Bounding Volume Hierarchies (BVHs) for efficient ray intersection tests (especially relevant for path tracing).
*   **Efficient Updates**: Buffer managers handle updates to scene data on the GPU efficiently.

### Screenshots

![](public/static/screenshots/screen0.png?raw=true)
![](public/static/screenshots/screen1.png?raw=true)
![](public/static/screenshots/screen2.png?raw=true)
![](public/static/screenshots/screen3.png?raw=true)
![](public/static/screenshots/screen4.png?raw=true)

*(Note: Internet Explorer is unsupported due to a lack of WebGPU and WebGL 2 support.)*