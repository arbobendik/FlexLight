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
    image.src = partCanvas.toDataURL();
    return image;
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
  // update all bounding volumes in scene
  updateBoundings (obj = this.queue) {
    // subtract bias of 2^(-16)
    const bias = 0.00152587890625;
    let minMax = new Array(6);
    if (Array.isArray(obj) || obj.indexable) {
      if (obj.length === 0) {
        console.error('problematic object structure', 'isArray:', Array.isArray(obj), 'indexable:', obj.indexable, 'object:', obj);
      } else {
        minMax = this.updateBoundings (obj[0]);
        for (let i = 1; i < obj.length; i++) {
          // get updated bounding of lower element
          let b = this.updateBoundings (obj[i]);
          // update maximums and minimums
          minMax = minMax.map((item, i) => (i % 2 === 0) ? Math.min(item, b[i] - bias) : Math.max(item, b[i] + bias));
        }
      }
    } else {
      let v = obj.vertices;
      minMax = [v[0], v[0], v[1], v[1], v[2], v[2]];
      // get min and max values of veritces of object
      for (let i = 3; i < obj.vertices.length; i++) {
        minMax[(i%3) * 2] = Math.min(minMax[(i%3) * 2], v[i]);
        minMax[(i%3) * 2 + 1] = Math.max(minMax[(i%3) * 2 + 1], v[i]);
      }
    }
    // set minMax as new bounding volume
    obj.bounding = minMax;
    // return current bounding box
    return minMax;
  }
    
  // object constructors
  // axis aligned cuboid element prototype
  Cuboid = (x, x2, y, y2, z, z2) => new Cuboid (x, x2, y, y2, z, z2, this);
  // surface element prototype
  Plane = (c0, c1, c2, c3) => new Plane (c0, c1, c2, c3, this);
  // triangle element prototype
  Triangle = (a, b, c) => new Triangle (a, b, c, this);
  // generate object from array
  // create object from .obj file
  fetchObjFile = async (path) => {
    // get scene for reference inside object
    let scene = this;
    // final object variable 
    let obj = [];
    // collect parts of object
    let v = [];
    let vt = [];
    let vn = [];
    // line interpreter
    let interpreteLine = line => {
      let words = [];
      // get array of words
      line.split(' ').forEach(word => { if (word !== '') words.push(word) });
      // interpret current line
      switch (words[0]) {
        case 'v':
          // push vector
          v.push([Number(words[1]), Number(words[2]), Number(words[3])]);
          break;
        case 'vt':
          // push uv
          vt.push([Number(words[1]), Number(words[2])]);
          break;
        case 'vn':
          // push normal
          vn.push([Number(words[1]), Number(words[2]), Number(words[3])]);
          break;
        case 'f':
          // extract array indecies form string
          let data = words.slice(1, words.length).map(word => word.split('/').map(numStr => Number(numStr)));
          // test if new part should be a triangle or plane
          if (words.length === 5) {
            // generate plane with vertecies
            let plane = new Plane (
              v[data[3][0] - 1],
              v[data[2][0] - 1],
              v[data[1][0] - 1],
              v[data[0][0] - 1],
              scene
            );
            // set uvs according to .obj file
            plane.uvs = [3, 2, 1, 1, 0, 3].map(i => (vt[data[i][1] - 1] ?? plane.uvs.slice(i * 2, i * 2 + 2))).flat();
            // set normals according to .obj file
            plane.normals = [3, 2, 1, 1, 0, 3].map(i => (vn[data[i][2] - 1] ?? plane.normals.slice(i * 3, i * 3 + 2))).flat();
            // push new plane in object array
            obj.push(plane);
          } else {
             // generate triangle with vertecies
             let triangle = new Triangle (
               v[data[2][0] - 1],
               v[data[1][0] - 1],
               v[data[0][0] - 1],
              scene
            );
            // set uvs according to .obj file
            triangle.uvs = [2, 1, 0].map(i => (vt[data[i][1] - 1] ?? triangle.uvs.slice(i * 2, i * 2 + 2))).flat();
            // set normals according to .obj file
            triangle.normals = [2, 1, 0].map(i => (vn[data[0][2] - 1] ?? triangle.normals.slice(i * 3, i * 3 + 3))).flat();
            // triangle.setColor(triangle.normals[0] * 1000);
            obj.push(triangle);
          }
          break;
      }
    };
    // fetch file and iterate over its lines
    let text = await (await fetch(path)).text();
    text.split(/\r\n|\r|\n/).forEach(line => interpreteLine(line));
    // generate boundings for object and give it 
    obj = new Bounding(obj, scene);
    scene.updateBoundings(obj);
    // return built object
    return obj;
  }
}

class Object3D {
  setColor (r, g, b) {
    if (Array.isArray(r)) [r, g, b] = r;
    if (this.indexable) {
      for (let i = 0; i < this.length; i++) this[i].setColor(r, g, b);
    } else {
      this.colors = new Array(this.length).fill([r / 255, g / 255, b / 255]).flat();
    }
  }
  setTextureNums (tex, pbr, trans) {
    if (this.indexable) {
      for (let i = 0; i < this.length; i++) this[i].setTextureNums(tex, pbr, trans);
    } else {
      this.textureNums = new Array(this.length).fill([tex, pbr, trans]).flat();
    }
  }
  // move object by given vector
  move (x, y, z) {
    if (this.indexable) {
      for (let i = 0; i < this.length; i++) this[i].move(x, y, z, true);
    } else {
      this.vertices = this.vertices.map((coord, i) => {
        switch (i % 3){
          case 0:
            return coord + x;
          case 1:
            return coord + y;
          case 2:
            return coord + z;
        }
      });
    }
  }
  constructor (length, indexable, scene) {
    this.length = length;
    this.indexable = indexable;
    this.scene = scene;
  }
}

class Cuboid extends Object3D {
  constructor (x, x2, y, y2, z, z2, scene) {
    super(6, true, scene);
    // Add bias of 2^(-16)
    const bias = 0.00152587890625;
    [x, y, z] = [x + bias, y + bias, z + bias];
    [x2, y2, z2] = [x2 - bias, y2 - bias, z2 - bias];
    // Create surface elements for cuboid
    this.bounding = [x, x2, y, y2, z, z2];
    this.top = new Plane([x,y2,z], [x2,y2,z], [x2,y2,z2], [x,y2,z2], scene);
    this.right = new Plane([x2,y2,z], [x2,y,z], [x2,y,z2], [x2,y2,z2], scene);
    this.front = new Plane([x2,y2,z2], [x2,y,z2], [x,y,z2], [x,y2,z2], scene);
    this.bottom = new Plane([x,y,z2], [x2,y,z2], [x2,y,z], [x,y,z], scene);
    this.left = new Plane([x,y2,z2], [x,y,z2], [x,y,z], [x,y2,z], scene);
    this.back = new Plane([x,y2,z], [x,y,z], [x2,y,z], [x2,y2,z], scene);

    [this.top, this.right, this.front, this.bottom, this.left, this.back].forEach((item, i) => this[i] = item);
  }
}

class Plane extends Object3D {
  // default color to white
  colors = new Array(18).fill(1);
  // set UVs
  uvs = [0,0,0,1,1,1,1,1,1,0,0,0];
  // set used textures
  textureNums = new Array(6).fill([-1,-1,-1]).flat();

  constructor (c0, c1, c2, c3, scene) {
    super(6, false, scene);
    // set normals
    this.normals = new Array(6).fill(cross(vec_diff(c0, c2), vec_diff(c0, c1))).flat();
    // set vertices
    this.vertices = [c0,c1,c2,c2,c3,c0].flat();
  }
}

class Triangle extends Object3D {
  // default color to white
  colors = new Array(9).fill(1);
  // UVs to map textures on triangle
  uvs = [0,0,0,1,1,1];
  // set used textures
  textureNums = new Array(3).fill([-1,-1,-1]).flat();

  constructor (a, b, c, scene) {
    super(3, false, scene);
    // generate surface normal
    this.normals = new Array(3).fill(cross(
      vec_diff(a, c),
      vec_diff(a, b)
    )).flat();
    // vertecies for queue
    this.vertices = [a,b,c].flat();
  }
}

class Bounding extends Object3D {
  constructor (array, scene) { 
    super(array.length, true, scene);
    array.forEach((item, i) => this[i] = item);
  }
}
