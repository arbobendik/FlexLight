'use strict';

import { Math } from './math.js';
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
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    canvas.width = width;
    canvas.height = height;
    // Disable image smoothing to get non-blury pixel values
    ctx.imageSmoothingEnabled = false;
    // Create Image element
    let imgData = ctx.createImageData(width, height);
    // Set imgArray as image source
    imgData.data.set(new Uint8ClampedArray(array), 0);
    // Set image data in canvas
    ctx.putImageData(imgData, 0, 0);
    // Set canvas as image source
    let image = new Image();
    image.src = canvas.toDataURL();
    return image;
  }
  // Make static function callable from object
  textureFromRME = async (array, width, height) => await Scene.textureFromRME (array, width, height);
  // Generate pbr texture (roughness, metallicity, emissiveness)
  static async textureFromRME(array, width, height) {
    // Create new array
    let texelArray = [];
    // Convert image to Uint8 format
    for (let i = 0; i < array.length; i += 3) texelArray.push(array[i] * 255, array[i + 1] * 255, array[i+2] * 255, 255);
    // From here on rgb images are generated the same way
    return await this.textureFromRGB(texelArray, width, height);
  }
  // Generate translucency texture (translucency, particle density, optical density)
  // Pbr images are generated the same way
  textureFromTPO = async (array, width, height) => await Scene.textureFromRME (array, width, height);

  // Autogenerate oct-tree for imported structures or structures without BVH-tree
  generateOctTree (objects = this.queue) {
    // get scene for reference inside object
    let scene = this;

    let topTree = new Bounding(objects);
    // Determine bounding for each object
    this.updateBoundings(topTree);

    let fitsInBound = (bound, obj) => {
      return bound[0] <= obj.bounding[0] && bound[2] <= obj.bounding[2] && bound[4] <= obj.bounding[4]
      && bound[1] >= obj.bounding[1] && bound[3] >= obj.bounding[3] && bound[5] >= obj.bounding[5];
    }

    let divideTree = (tree, bounding) => {
      // If there are only 2 or less objects in tree, there is no need to subdivide
      if (tree.length <= 2) return new Bounding(tree, scene);
      else {
        // Calculate general offsets
        let off = Math.mul([bounding[1] - bounding[0], bounding[1] - bounding[0],
                            bounding[3] - bounding[2], bounding[3] - bounding[2],
                            bounding[5] - bounding[4], bounding[5] - bounding[4]], 0.5);
        // Offsetmultiplier for different parts of Oct-tree
        let multip = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 1], 
                      [0, 0, 1, 1, 1, 0], [0, 0, 1, 1, 1, 1],
                      [1, 1, 0, 0, 0, 0], [1, 1, 0, 0, 1, 1],
                      [1, 1, 1, 1, 0, 0], [1, 1, 1, 1, 1, 1]];
        // Calculate offset per subtree
        let offsets = multip.map(mult => Math.mul(off, mult));
        // Get bounds of base cube
        let baseBounds = [bounding[0], (bounding[0] + bounding[1]) * 0.5,
                          bounding[2], (bounding[2] + bounding[3]) * 0.5,
                          bounding[4], (bounding[4] + bounding[5]) * 0.5];
        // Caluclate bounds for all subtrees
        let bounds = offsets.map(offset => Math.add(baseBounds, offset));
        // Have 8 buickets for sub trees
        let arrayBuckets = new Array(8).fill(0).map(e => []);
        // Bucket for all objects that fit into neither of the subtrees
        let noBucket = [];
        // Iterate over objects
        for (let i = 0; i < tree.length; i++) {
          let foundBucket = false;
          for (let j = 0; j < 8; j++) {
            if (fitsInBound(bounds[j], tree[i])) {
              arrayBuckets[j].push(tree[i]);
              console.log("loaded Triangle");
              foundBucket = true;
              break;
            }
          }
          if (!foundBucket) noBucket.push(tree[i]);
        }
        // Iterate over all filled buckets and return 
        let finalObjArray = [];

        for (let i = 0; i < 8; i++) if (arrayBuckets[i].length !== 0) finalObjArray.push(divideTree(arrayBuckets[i], bounds[i]));
        noBucket.forEach(e => finalObjArray.push(e));
        // finalObjArray.push(...noBucket);
        // Return sorted object array aas bounding volume.
        return new Bounding(finalObjArray, scene);
      }
    }
    
    topTree = divideTree(topTree, topTree.bounding);
    console.log("done building Oct-Tree");
    return topTree;
  }
  
  // Update all bounding volumes in scene
  updateBoundings (obj = this.queue) {
    // subtract bias of 2^(-16)
    const bias = 0.00152587890625;
    let minMax = new Array(6);
    if (Array.isArray(obj) || obj.indexable) {
      if (obj.length === 0 && !obj.blockError) {
        console.error('problematic object structure', 'isArray:', Array.isArray(obj), 'indexable:', obj.indexable, 'object:', obj);
        obj.blockError = true;
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
        minMax[(i % 3) * 2] = Math.min(minMax[(i % 3) * 2], v[i]);
        minMax[(i % 3) * 2 + 1] = Math.max(minMax[(i % 3) * 2 + 1], v[i]);
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
  // bounding element
  Bounding = (array) => new Bounding (array, this);
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
    obj = await scene.generateOctTree(obj);
    console.log(obj);
    // obj = new Bounding(obj, scene);
    await scene.updateBoundings(obj);

    // return built object
    return obj;
  }
}

class Primitive {
  #vertices;
  #colors;
  #uvs;
  #textureNums;
  #normals;

  textureArray;

  #buildTextureArray = () => {
    this.textureArray = [];
    for (let i = 0; i < this.length; i+= 3) {
      let i2 = i * 2;
      let i3 = i * 3;
      this.textureArray.push(
        this.#vertices[i3 + 0], this.#vertices[i3 + 1], this.#vertices[i3 + 2],
        this.#vertices[i3 + 3], this.#vertices[i3 + 4], this.#vertices[i3 + 5],
        this.#vertices[i3 + 6], this.#vertices[i3 + 7], this.#vertices[i3 + 8],
        this.#colors[0], this.#colors[1], this.#colors[2],
        this.#normals[0], this.#normals[1], this.#normals[2],
        this.#textureNums[0], this.#textureNums[1], this.#textureNums[2],
        this.#uvs[i2 + 0],this.#uvs[i2 + 1], this.#uvs[i2 + 2],
        this.#uvs[i2 + 3], this.#uvs[i2 + 4], this.#uvs[i2 + 5]
      );
    }
  }
    
  get vertices () { return this.#vertices };
  get colors () { return this.#colors };
  get uvs () { return this.#uvs };
  get textureNums () { return this.#textureNums };
  get normals () {return this.#normals };

  set vertices (v) {
    this.#vertices = v;
    this.#buildTextureArray();
  }
  set colors (c) {
    this.#colors = new Array(this.length).fill(c.map(val => val / 255)).flat();;
    this.#buildTextureArray();
  }
  set uvs (uv) {
    this.#uvs = uv;
    this.#buildTextureArray();
  }
  set textureNums (tn) {
    this.#textureNums = new Array(this.length).fill(tn).flat();
    this.#buildTextureArray();
  }
  set normals (n) {
    this.#normals = n;
    this.#buildTextureArray();
  }

  constructor (length, vertices, normals, uvs) {
    this.indexable = false;
    this.length = length;
    this.#vertices = vertices;
    this.#normals = normals;
    this.#colors = new Array(length).fill([1, 1, 1]).flat();
    this.#uvs = uvs;
    this.#textureNums = new Array(length).fill([-1, -1, -1]).flat();
    this.#buildTextureArray();
  }
}

class Object3D {
  setColor (r, g, b) {
    if (Array.isArray(r)) [r, g, b] = r;
    for (let i = 0; i < this.length; i++) {
      if (this[i].indexable) {
        this[i].setColor(r, g, b);
      } else {
        this[i].colors = [r, g, b];
      }
    }
  }

  setTextureNums (tex, pbr, trans) {
    for (let i = 0; i < this.length; i++) {
      if (this[i].indexable) {
        this[i].setTextureNums(tex, pbr, trans);
      } else {
        this[i].textureNums = new Array(this.length).fill([tex, pbr, trans]).flat();
      }
    }
  }
  // move object by given vector
  move (x, y, z) {
    for (let i = 0; i < this.length; i++) {
      if (this[i].indexable) {
        this[i].move(x, y, z, true);
      } else {
        this[i].vertices = this[i].vertices.map((coord, i) => {
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
  }
  
  constructor (length, indexable, scene) {
    this.length = length;
    this.indexable = indexable;
    this.scene = scene;
  }
}


class Bounding extends Object3D {
  constructor (array, scene) { 
    super(array.length, true, scene);
    array.forEach((item, i) => this[i] = item);
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
    this.top = new Plane([x, y2, z], [x2, y2, z], [x2, y2, z2], [x, y2, z2], scene);
    this.right = new Plane([x2, y2, z], [x2, y, z], [x2, y, z2], [x2, y2, z2], scene);
    this.front = new Plane([x2, y2, z2], [x2, y, z2], [x, y, z2], [x, y2, z2], scene);
    this.bottom = new Plane([x, y, z2], [x2, y, z2], [x2, y, z], [x, y, z], scene);
    this.left = new Plane([x, y2, z2], [x, y, z2], [x, y, z], [x, y2, z], scene);
    this.back = new Plane([x, y2, z], [x, y, z], [x2, y, z], [x2, y2, z], scene);

    [this.top, this.right, this.front, this.bottom, this.left, this.back].forEach((item, i) => this[i] = item);
  }
}

class Plane extends Primitive {
  constructor (c0, c1, c2, c3) {
    super(6, [c0, c1, c2, c2, c3, c0].flat(), new Array(6).fill(Math.normalize(Math.cross(Math.diff(c0, c2), Math.diff(c0, c1)))).flat(), [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0]);
  }
}

class Triangle extends Primitive {
  constructor (a, b, c) {
    super(3, [a, b, c].flat(), new Array(3).fill(Math.cross(Math.diff(a, c), Math.diff(a, b))).flat(), [0, 0, 0, 1, 1, 1]);
  }
}
