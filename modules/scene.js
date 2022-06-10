"use strict";

// Calculate cross product
let cross = (a, b) => [a[1]*b[2] - a[2]*b[1], a[2]*b[0] - a[0]*b[2], a[0]*b[1] - a[1]*b[0]];
// Determines vector between 2 points
let vec_diff = (a, b) => a.map((item, i) => b[i] - item);

export class Scene {
  // light sources and textures
  primaryLightSources = [[0, 10, 0]];
  defaultLightIntensity = 200;
  defaultLightVariation = 0.4;
  ambientLight = [0.1, 0.1, 0.1];
  textures = [];
  pbrTextures = [];
  translucencyTextures = [];
  standardTextureSizes = [64, 64];
  // The queue object contains all data of all vertices in the scene
  queue = [];
  // texture constructors
  textureFromRGB = async (array, width, height) => await Scene.textureFromRGB (array, width, height);
  // Generate texture from rgb array in static function to have function precompiled
  static async textureFromRGB (array, width, height) {
    var partCanvas = document.createElement('canvas');
    var partCtx = partCanvas.getContext('2d');
    partCanvas.width = width;
    partCanvas.height = height;
		// Disable image smoothing to get non-blury pixel values
		partCtx.imageSmoothingEnabled = false;
    // Create Image element
    let imgData = partCtx.createImageData(width, height);
    // Set imgArray as image source
    imgData.data.set(new Uint8ClampedArray(array), 0);
    // Set image data in canvas
    partCtx.putImageData(imgData, 0, 0);
    // Set part canvas as image source
    let image = new Image();
    image.src = await partCanvas.toDataURL();
    return await image;
  }
  // Make static function callable from object
  textureFromRME = async (array, width, height) => await Scene.textureFromRME (array, width, height);
  // Generate pbr texture (roughness, metallicity, emissiveness)
  static async textureFromRME(array, width, height) {
    // Create new array
    let texelArray = [];
    // Convert image to Uint8 format
    for (let i = 0; i < array.length; i+=3) texelArray.push(array[i] * 255, array[i +1] * 255, array[i+2] * 255, 255);
    // From here on rgb images are generated the same way
    return await this.textureFromRGB(texelArray, width, height);
  }
  // Generate translucency texture (translucency, particle density, optical density)
  // Pbr images are generated the same way
  textureFromTPO = async (array, width, height) => await Scene.textureFromRME (array, width, height);
  // object constructors
  // Axis aligned cuboid element prototype
  Cuboid = (x, x2, y, y2, z, z2) => new Cuboid (x, x2, y, y2, z, z2);
  // Surface element prototype
  Plane = (c0, c1, c2, c3) => new Plane (c0, c1, c2, c3);
  // Triangle element prototype
  Triangle = (a, b, c) => new Triangle (a, b, c);
}

class Object3D {
  setColor (r, g, b) {
    if (Array.isArray(r)) [r, g, b] = r;
    if (this.indexable) {
      for (let i = 1; i < this.length; i++) this[i].setColor(r, g, b);
    } else {
      this.colors = new Array(this.length).fill([r / 255, g / 255, b / 255]).flat();
    }
  }
  setTextureNums (tex, pbr, trans) {
    if (this.indexable) {
      for (let i = 1; i < this.length; i++) this[i].setTextureNums(tex, pbr, trans);
    } else {
      this.textureNums = new Array(this.length).fill([tex, pbr, trans]).flat();
    }
  }
  /*moveVector(x, y, z) {

  }*/
  constructor (length, indexable) {
    this.length = length;
    this.indexable = indexable;
  }
}

class Cuboid extends Object3D {
  constructor (x, x2, y, y2, z, z2) {
    super(7, true);
    // Add bias of 2^(-16)
    let b = 0.00152587890625;
    [x, y, z] = [x + b, y + b, z + b];
    [x2, y2, z2] = [x2 - b, y2 - b, z2 - b];
    // Create surface elements for cuboid
    this[0] = [x, x2, y, y2, z, z2];
    this.top = new Plane([x,y2,z],[x2,y2,z],[x2,y2,z2],[x,y2,z2]);
    this.right = new Plane([x2,y2,z],[x2,y,z],[x2,y,z2],[x2,y2,z2]);
    this.front = new Plane([x2,y2,z2],[x2,y,z2],[x,y,z2],[x,y2,z2]);
    this.bottom = new Plane([x,y,z2],[x2,y,z2],[x2,y,z],[x,y,z]);
    this.left = new Plane([x,y2,z2],[x,y,z2],[x,y,z],[x,y2,z]);
    this.back = new Plane([x,y2,z],[x,y,z],[x2,y,z],[x2,y2,z]);

    [this.top, this.right, this.front, this.bottom, this.left, this.back].forEach((item, i) => {
      this[i + 1] = item;
    });
  }
}

class Plane extends Object3D {
  // default color to white
  colors = new Array(18).fill(1);
  // set UVs
  uvs = [0,0,0,1,1,1,1,1,1,0,0,0];
  // set used textures
  textureNums = new Array(6).fill([-1,-1,-1]).flat();

  constructor (c0, c1, c2, c3) {
    super(6, false);
    // set normals
    this.normals = new Array(6).fill(cross(vec_diff(c0, c2), vec_diff(c0, c1))).flat();
    // set vertices
    this.vertices = [c0,c1,c2,c2,c3,c0].flat();
    // define bounding volume of plane
    this.bounding = [ Math.min(c0[0],c1[0],c2[0],c3[0]),
                      Math.max(c0[0],c1[0],c2[0],c3[0]),
                      Math.min(c0[1],c1[1],c2[1],c3[1]),
                      Math.max(c0[1],c1[1],c2[1],c3[1]),
                      Math.min(c0[2],c1[2],c2[2],c3[2]),
                      Math.max(c0[2],c1[2],c2[2],c3[2]) ];
  }
}

class Triangle extends Object3D {
  // default color to white
  colors = new Array(9).fill(1);
  // UVs to map textures on triangle
  uvs = [0,0,0,1,1,1];
  // set used textures
  textureNums = new Array(3).fill([-1,-1,-1]).flat();

  constructor (a, b, c) {
    super(3, false);
    // generate surface normal
    this.normals = new Array(3).fill(cross(
      vec_diff(a, c),
      vec_diff(a, b)
    )).flat();
    // vertecies for queue
    this.vertices = [a,b,c].flat();
  }
}
