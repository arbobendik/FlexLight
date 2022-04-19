# Web Ray Tracer

## JavaScript + WebGL 2

### Changes
You can now dynamically load the scenes listed on the [demo page](https://arbobendik.github.io/web-ray-tracer/)!
Unload a page by clearing the site cache (Hard Reload).

### Description
Generates a canvas and scenery through JavaScript and traces the flow of light in real time.
It is possible to manipulate the scenes to your heart's content by creating a script in scenes and adding it to the loader.
You can create triangles, planes and even cuboids with this library.

### Getting started
To generate a new RayTracer, you need to write the following line of code:
```javascript
var rt = new rayTracer(canvas);
```

Loader format:
```html
<option value = "filename">Description</option>
```
There is **no file-ending**!
Always add content at the bottom, the top-most option will be ignored.

Primary light sources can be added via the librarys rt.primaryLightSources object.The engine supports custom textures,
pbr (rough, metallic) textures with emissives and several physical effects like the fresnel effect.
All structures are aranged in AABBs (Axis Aligned Bounding Boxes) to improve performance.
This tree like structure is completly customizable over the API by appending all objects in
their respective desired bounding tree to the rt.queue object, where the 0th position of all sub arrays
describes the minimum and maximum values of their respective AABB. For example:

```javascript
rt.queue = [
    // set min and max values for bounding box
    [xMin, xMax, yMin, yMax, zMin, zMax],
    // Actual sub elements of this bounding box.
    // Bounding boxes can be sub elements of other bounding boxes.
    cuboid0, plane0, cuboid1
];
```
Actual example code (working web-sites / scenes) on my github is linked under Examples/Screenshots below.
For performance reasons the path tracer works with 1 Sample per ray and 7 3x3 filter passes and one 5x5 pass.
The Filter can be switched on/off via the rt.filter variable.
The sample count per ray can be controlled over the rt.samplesPerRay varible as well.
The library (ray tracer object) offers many more options and functions that can't all be shown here.

(Safari & IE unsupported due to a lack of WebGl2 support).


### Screenshots

![](screenshots/screen2.png?raw=true)
example_0 (scale = 2 (1080p -> 4k), samples = 8)



![](screenshots/cornell.png?raw=true)
![](screenshots/emissive.png?raw=true)
![](screenshots/wave.png?raw=true)





### More screenshots (deprecated versions):

![](screenshots/screen3.png?raw=true)

![](screenshots/screen1.png?raw=true)

![](screenshots/screen0.png?raw=true)
