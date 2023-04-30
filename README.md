# FlexLight game and render engine for the web

## JavaScript + WebGL 2

### [Live Demo]( https://arbobendik.github.io/FlexLight/exampleLoader.html?v=cornell)

### Description
Generates a canvas and scenery through JavaScript and traces the flow of light in real time.
It is possible to manipulate the scenes to your heart's content in the scene folder.
You can create triangles, planes and even cuboids with this library.

### Getting started
To generate a new FlexLight engine, you need to write the following line of code:
```javascript
// Setup engine for a chosen canvas
var engine = new FlexLight(canvas);
// Choose pathtracing renderer
engine.renderer = 'pathtracer';
// Use web io
engine.io = 'web';
```

Primary light sources can be added via the librarys rt.primaryLightSources object. The engine supports custom textures,
pbr (rough, metallic) textures with emissives and several physical effects like the fresnel effect.
All structures are aranged in AABBs (Axis Aligned Bounding Boxes) to improve performance.
This tree like structure is completly customizable over the API by appending all objects in
their respective desired bounding tree to the rt.queue object. For example:

```javascript
// Configure primary lightsources
scene.primaryLightSources = [[10, 0, 10]];
scene.primaryLightSources[0].intensity = 500;
// Set ambient (RGB)
scene.ambientLight = [0.1, 0.1, 0.1];
// Create cube object
let cube = engine.scene.Cuboid(xMin, xMax, yMin, yMax, zMin, zMax);
// Append cube to render queue
engine.scene.queue.push(cuboid);
// Start frame generation
engine.renderer.render();
```

For working in depth examples check out the '/exaples' folder in this repo.

For performance reasons the raytracer works with 1 Sample per ray and 7 3x3 filter passes and one 5x5 pass.
The Filter can be switched on/off via the renderer.filter variable.
The sample count per ray can be controlled over the rt.samplesPerRay varible as well.
The library (ray tracer object) offers many more options and functions that can't all be shown here.

(IE unsupported due to a lack of WebGl2 support).


### Screenshots

![](screenshots/screen0.png?raw=true)
![](screenshots/screen1.png?raw=true)
![](screenshots/screen2.png?raw=true)
![](screenshots/screen3.png?raw=true)
![](screenshots/screen4.png?raw=true)
