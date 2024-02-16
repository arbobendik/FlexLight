'use strict';

import { Math } from './math.js';
import { Float16Array, Arrays } from './arrays.js';

const MAX_TRANSFORMS = 65520;
export class Scene {
  // light sources and textures
  primaryLightSources = [[0, 10, 0]];
  defaultLightIntensity = 200;
  defaultLightVariation = 0.4;
  ambientLight = [0.1, 0.1, 0.1];
  textures = [];
  pbrTextures = [];
  translucencyTextures = [];
  standardTextureSizes = [1024, 1024];
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


  fitsInBound (bound, obj) {
    return bound[0] <= obj.bounding[0] && bound[2] <= obj.bounding[2] && bound[4] <= obj.bounding[4]
    && bound[1] >= obj.bounding[1] && bound[3] >= obj.bounding[3] && bound[5] >= obj.bounding[5];
  }

  // Autogenerate oct-tree for imported structures or structures without BVH-tree
  generateBVH (objects = this.queue) {
    // Test how many triangles can be sorted into neiter bounding.
    let testOnEdge = (objs, bounding0, bounding1) => {
      let onEdge = 0;
      for (let i = 0; i < objs.length; i++) if ((! scene.fitsInBound(bounding0, objs[i])) && (! scene.fitsInBound(bounding1, objs[i]))) onEdge++;
      return onEdge;
    }

    let divideTree = (objs, depth = 0) => {
      // If there are only 4 or less objects in tree, there is no need to subdivide further
      if (objs.length <= 4 || depth > maxTree) {
        polyCount += objs.length;
        // console.log("loaded", polyCount, "polygons so far.");
        return objs;
      } else {
        // Find center
        let center = [
          (objs.bounding[0] + objs.bounding[1]) / 2,
          (objs.bounding[2] + objs.bounding[3]) / 2,
          (objs.bounding[4] + objs.bounding[5]) / 2
        ];

        let idealSplit = 0;
        let leastOnEdge = Infinity;

        let onEdges = [];

        for (let i = 0; i < 3; i++) {
          let bounding0 = objs.bounding.concat();
          let bounding1 = objs.bounding.concat();

          bounding0[i * 2] = center[i];
          bounding1[i * 2 + 1] = center[i];

          let minDiff = Math.min(bounding0[i * 2 + 1] - center[i], center[i] - bounding1[i * 2]);
          let onEdge = testOnEdge(objs, bounding0, bounding1);
          onEdges.push(onEdge);

          if (leastOnEdge >= onEdge && minDiff > minBoundingWidth) {
            idealSplit = i;
            leastOnEdge = onEdge;
          }
        }

        if (leastOnEdge === Infinity) {
          console.error("OPTIMIZATION failed for subtree!", objs.length);
          console.log(onEdges);
          return objs;
        }
        // Sort into ideal buckets
        // The third bucket is for the objects in the cut
        let buckets = [[], [], []];
        let bounds = [objs.bounding, objs.bounding.concat(), objs.bounding.concat()];
        bounds[0][idealSplit * 2] = center[idealSplit];
        bounds[1][idealSplit * 2 + 1] = center[idealSplit];

        for (let i = 0; i < objs.length; i++) {
          if (scene.fitsInBound(bounds[0], objs[i])) buckets[0].push(objs[i]);
          else if (scene.fitsInBound(bounds[1], objs[i])) buckets[1].push(objs[i]);
          else buckets[2].push(objs[i]);
        }
        // Iterate over all filled buckets and return 
        let finalObjArray = [];

        for (let i = 0; i < 3; i++) if (buckets[i].length !== 0) {
          // Tighten bounding
          let b = new Bounding(buckets[i], scene);
          scene.updateBoundings(b);
          finalObjArray.push(divideTree(b, depth + 1));
        }
        // finalObjArray.push(...buckets[2]);
        // Return sorted object array as bounding volume.
        let commonBounding = new Bounding(finalObjArray, scene);
        commonBounding.bounding = objs.bounding;
        return commonBounding;
      }
    }

    const minBoundingWidth = 1 / 256;
    // get scene for reference inside object
    let scene = this;
    let topTree = new Bounding(objects);
    // Determine bounding for each object
    this.updateBoundings(topTree);

    let polyCount = 0;

    let maxTree = Math.log2(topTree.length) + 8;
    topTree = divideTree(topTree);
    console.log("done building BVH-Tree");
    console.log(maxTree);
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
  
  // Pass some constructors
  Transform = matrix => new Transform (matrix);
  // axis aligned cuboid element prototype
  Cuboid = (x, x2, y, y2, z, z2) => new Cuboid (x, x2, y, y2, z, z2);
  // surface element prototype
  Plane = (c0, c1, c2, c3) => new Plane (c0, c1, c2, c3);
  // triangle element prototype
  Triangle = (a, b, c) => new Triangle (a, b, c);
  // bounding element
  Bounding = array => new Bounding (array);
  // generate object from array
  // Create object from .obj file
  importObj = async path => {
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
      line.split(/[\t \s\s+]/g).forEach(word => { if (word.length) words.push(word) });
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
          // "-" or space is sperating different vertices while "/" seperates different properties
          let dataString = words.slice(1, words.length).join(' ');
          // extract array indecies form string
          let data = dataString.split(/[ ]/g).filter(vertex => vertex.length).map(vertex => vertex.split(/[/]/g).map(numStr => {
            let num = Number(numStr);
            if (num < 0) num = v.length + num + 1;
            return num;
          }));
          // test if new part should be a triangle or plane
          if (data.length === 4) {
            // generate plane with vertecies
            let plane = new Plane (
              v[data[3][0] - 1],
              v[data[2][0] - 1],
              v[data[1][0] - 1],
              v[data[0][0] - 1],           
              scene
            );
            // set uvs according to .obj file
            // plane.uvs = [3, 2, 1, 1, 0, 3].map(i => (vt[data[i][1] - 1] ?? plane.uvs.slice(i * 2, i * 2 + 2))).flat();
            // set normals according to .obj file
            [3, 2, 1, 1, 0, 3].forEach((index, i) => {
              if (vt[data[index][1] - 1] !== undefined) plane.uvs.set(vt[data[index][1] - 1], i * 2);
              if (vn[data[index][2] - 1] !== undefined) plane.normals.set(vn[data[index][2] - 1], i * 3);
            });
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
            // triangle.uvs = [2, 1, 0].map(i => (vt[data[i][1] - 1] ?? triangle.uvs.slice(i * 2, i * 2 + 2))).flat();
            // set normals according to .obj file
            [2, 1, 0].forEach((index, i) => {
              if (vt[data[index][1] - 1] !== undefined) triangle.uvs.set(vt[data[index][1] - 1], i * 2);
              if (vn[data[index][2] - 1] !== undefined) triangle.normals.set(vn[data[index][2] - 1], i * 3);
            });
            // console.log([2, 1, 0].map(i => (vn[data[0][2] - 1] ?? triangle.normals.slice(i * 3, i * 3 + 3))).flat());
            // triangle.setColor(triangle.normals[0] * 1000);
            obj.push(triangle);
          }
          break;
        case 'g':
          break;
      }
    };
    // fetch file and iterate over its lines
    let text = await (await fetch(path)).text();
    text.split(/\r\n|\r|\n/).forEach(line => interpreteLine(line));
    // generate boundings for object and give it 
    obj = scene.generateBVH(obj);
    scene.updateBoundings(obj);
    // return built object
    return obj;
  }

  importMtl = async path => {
    // Accumulate information
    let materials = [];
    let currentMaterialName;
    // line interpreter
    let interpreteLine = line => {
      let words = [];
      // get array of words
      line.split(/[\t \s\s+]/g).forEach(word => { if (word.length) words.push(word) });
      // interpret current line
      switch (words[0]) {
        case 'newmtl':
          currentMaterialName = words[1];
          materials[currentMaterialName] = {};
          break;
        case 'Ni':
          // materials[currentMaterialName].metalicity = 
      }
    };
    // fetch file and iterate over its lines
    let text = await (await fetch(path)).text();
    text.split(/\r\n|\r|\n/).forEach(line => interpreteLine(line));
  }
}

export class Transform {
  number = -1;
  #matrix;

  static used = new Array(MAX_TRANSFORMS);
  static count = 0;
  static transformList = new Array(MAX_TRANSFORMS);

  static buildUBOArray = () => {
    // Create UBO buffer array
    let buffer = new Float32Array(16 * Transform.count);
    // Iterate over set elements
    for (let i = 0; i < Transform.count; i++) {
      buffer.set(this.transformList[i].#matrix, i * 16);
    }
    // console.log(Transform.count);
    return buffer;
  }

  set matrix (matrix) {
    this.#matrix = new Float32Array(matrix);
  }

  get matrix () {
    return Array.from(this.#matrix);
  }

  move (x, y, z) {
    this.#matrix[12] = x;
    this.#matrix[13] = y;
    this.#matrix[14] = z;
  }

  scale (s) {
    this.#matrix[0] = s;
    this.#matrix[5] = s;
    this.#matrix[10] = s;
  }

  constructor (matrix) {
    if (Array.isArray(matrix)){
      this.#matrix = new Float32Array(matrix);
    } else {
      this.#matrix = Math.identity(4).flat();
      // Default to identity matrix
    }
    // Assign next larger available number
    for (let i = 0; i < MAX_TRANSFORMS; i++) {
      if (Transform.used[i]) continue;
      Transform.used[i] = true;
      this.number = i;
      break;
    }
    // All transformation matricies slots in UBO are blocked
    if (this.number === -1) {
      console.error(
        'Exceeded limit of', 
        MAX_TRANSFORMS,
        'transformation matrices! Try altering your matrices instead of generating them.'
      );
      return;
    }
    // Update max index
    Transform.count = Math.max(Transform.count, this.number + 1);
    // Set in transform list
    Transform.transformList[this.number] = this;
  }
}

export class Primitive {
  #vertices;
  #normal;
  #normals;
  #uvs;
  #transform;
  #textureNums = new Float32Array([-1, -1, -1]);
  #albedo = new Float32Array([1, 1, 1]);
  #rme = new Float32Array([1, 0, 0]);
  #tpo = new Float32Array([0, 0, 1]);

  geometryTextureArray;
  sceneTextureArray;

  #buildTextureArrays = () => {
    // a, b, c, na, nb, nc, uv01, uv12, tn, albedo, rme, tpo
    for (let i = 0; i < this.length; i ++) {
      let i12 = i * 12;
      this.geometryTextureArray.set(this.#vertices.slice(i * 9, i * 9 + 9), i12);
      this.geometryTextureArray[i12 + 9] = this.transformNum;
      let i27 = i * 27;
      this.sceneTextureArray.set(this.#normals.slice(i * 9, i * 9 + 9), i27);
      this.sceneTextureArray.set(this.#uvs.slice(i * 6, i * 6 + 6), i27 + 9);
      this.sceneTextureArray.set(this.#textureNums, i27 + 15);
      this.sceneTextureArray.set(this.#albedo, i27 + 18);
      this.sceneTextureArray.set(this.#rme, i27 + 21);
      this.sceneTextureArray.set(this.#tpo, i27 + 24);
    }
  }
    
  get vertices () { return this.#vertices };
  get normals () { return this.#normals };
  get normal () { return this.#normal };

  get transformNum () {
    if (this.#transform === undefined) return - 1;
    else return this.#transform.number;
  }
  get transform () { return this.#transform };
  
  get textureNums () { return this.#textureNums };
  get color () { return this.#albedo };
  get albedo () { return this.#albedo };
  get roughness () { return this.#rme[0] };
  get metallicity () { return this.#rme[1] };
  get emissiveness () { return this.#rme[2] };
  get translucency () { return this.#tpo[0] };
  get ior () { return this.#tpo[2] };
  get uvs () { return this.#uvs };

  set vertices (v) {
    this.#vertices = new Float32Array(v);
    this.#buildTextureArrays();
  }

  set normals (ns) {
    this.#normals = new Float32Array(ns);
    this.#normal = new Float32Array(ns.slice(0, 3));
    this.#buildTextureArrays();
  }

  set normal (n) {
    this.#normals = new Float32Array(new Array(this.length * 3).fill(n).flat());
    this.#normal = new Float32Array(n);
    this.#buildTextureArrays();
  }

  set transform (t) {
    this.#transform = t;
    this.#buildTextureArrays();
  }

  set textureNums (tn) {
    this.#textureNums = tn;
    this.#buildTextureArrays();
  }

  set color (c) {
    let color = c.map(val => val / 255);
    this.#albedo = new Float32Array(color);
    this.#buildTextureArrays();
  }

  set albedo (a) {
    this.color = a;
  }

  set roughness (r) {
    this.#rme[0] = r;
    this.#buildTextureArrays();
  }

  set metallicity (m) {
    this.#rme[1] = m;
    this.#buildTextureArrays();
  }

  set emissiveness (e) {
    this.#rme[2] = e;
    this.#buildTextureArrays();
  }

  set translucency (t) {
    this.#tpo[0] = t;
    this.#buildTextureArrays();
  }

  set ior (i) {
    this.#tpo[2] = 1.5;
    this.#buildTextureArrays();
  }

  set uvs (uv) {
    this.#uvs = new Float32Array(uv);
    this.#buildTextureArrays();
  }

  constructor (length, vertices, normal, uvs) {
    this.indexable = false;
    this.length = length;
    
    this.#vertices = new Float32Array(vertices);
    this.#normal = new Float32Array(normal);
    this.#normals = new Float32Array(new Array(this.length * 3).fill(normal).flat());
    this.#uvs = new Float32Array(uvs);
    
    this.geometryTextureArray = new Float32Array(this.length * 12);
    this.sceneTextureArray = new Float32Array(this.length * 27);
    this.#buildTextureArrays();
  }
}

export class Plane extends Primitive {
  constructor (c0, c1, c2, c3) {
    super(2, [c0, c1, c2, c2, c3, c0].flat(), Math.normalize(Math.cross(Math.diff(c0, c2), Math.diff(c0, c1))), [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0]);
  }
}

export class Triangle extends Primitive {
  constructor (a, b, c) {
    super(1, [a, b, c].flat(), Math.normalize(Math.cross(Math.diff(a, c), Math.diff(a, b))), [0, 0, 0, 1, 1, 1]);
  }
}

export class Object3D {
  #static = false;
  #staticPermanent = false;

  #transform;

  get transformNum () {
    if (this.#transform === undefined) {
      return -1;
    } else {
      return this.#transform.number;
    }
  }
  get transform () { return this.#transform };

  set transform (t) {
    this.#transform = t;
    for (let i = 0; i < this.length; i++) this[i].transform = t;
  }

  set textureNums (tn) {
    for (let i = 0; i < this.length; i++) this[i].textureNums = tn;
  }

  set color (c) {
    for (let i = 0; i < this.length; i++) this[i].color = c;
  }

  set albedo (a) {
    for (let i = 0; i < this.length; i++) this[i].albedo = a;
  }

  set roughness (r) {
    for (let i = 0; i < this.length; i++) this[i].roughness = r;
  }

  set metallicity (m) {
    for (let i = 0; i < this.length; i++) this[i].metallicity = m;
  }

  set emissiveness (e) {
    for (let i = 0; i < this.length; i++) this[i].emissiveness = e;
  }

  set translucency (t) {
    for (let i = 0; i < this.length; i++) this[i].translucency = t;
  }

  set ior (i) {
    for (let i = 0; i < this.length; i++) this[i].ior = i;
  }
  // move object by given vector
  move (x, y, z) {
    this.relativePosition = [x, y, z];
    for (let i = 0; i < this.length; i++) {
      if (this[i].indexable) {
        this[i].move(x, y, z);
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

  scale (s) {
    for (let i = 0; i < this.length; i++) {
      if (this[i].indexable) {
        this[i].scale(s);
      } else {
        this[i].vertices = this[i].vertices.map((coord, i) => (coord - this.relativePosition[i % 3]) * s + this.relativePosition[i % 3]);
      }
    }
  }

  set static (isStatic) {
    if (isStatic) {
      // Track ids
      let walkGraph = (item) => {
        if (item.static) {
          // Adjust id that wasn't increased so far due to bounding boxes missing in the objectLength array
          this.textureLength += item.textureLength;
          this.bufferLength += item.bufferLength;
        } else if (Array.isArray(item) || item.indexable) {
          // Item is dynamic and indexable, recursion continues
          if (item.length === 0) return 0;
          this.textureLength ++;
          // Iterate over all sub elements
          for (let i = 0; i < item.length; i++) walkGraph(item[i]);
        } else {
          // Give item new id property to identify vertex in fragment shader
          this.textureLength += item.length;
          this.bufferLength += item.length;
        }
      }

      // Build simple AABB tree (Axis aligned bounding box)
      let fillData = (item) => {
        let minMax = [];
        if (item.static) {
          // Item is static and precaluculated values can just be used
          this.geometryTextureArray.set(item.geometryTextureArray, texturePos * 12);
          this.sceneTextureArray.set(item.sceneTextureArray, texturePos * 27);
          // Update id buffer
          for (let i = 0; i < item.bufferLength; i++) this.idBuffer[bufferPos + i] = texturePos + item.idBuffer[i];
          texturePos += item.textureLength;
          bufferPos += item.bufferLength;

          return item.minMax;
        } else if (Array.isArray(item) || item.indexable) {
          // Item is dynamic and indexable, recursion continues
          if (item.length === 0) return [];
          // Begin bounding volume array
          let oldTexturePos = texturePos;
          texturePos ++;
          // Iterate over all sub elements
          minMax = fillData (item[0]);
          for (let i = 1; i < item.length; i++) {
            // get updated bounding of lower element
            let b = fillData(item[i]);
            // update maximums and minimums
            minMax[0] = Math.min(minMax[0], b[0]);
            minMax[1] = Math.min(minMax[1], b[1]);
            minMax[2] = Math.min(minMax[2], b[2]);
            minMax[3] = Math.max(minMax[3], b[3]);
            minMax[4] = Math.max(minMax[4], b[4]);
            minMax[5] = Math.max(minMax[5], b[5]);
          }
          // Set now calculated vertices length of bounding box
          // to skip if ray doesn't intersect with it
          for (let i = 0; i < 6; i++) this.geometryTextureArray[oldTexturePos * 12 + i] = minMax[i];
          this.geometryTextureArray[oldTexturePos * 12 + 6] = texturePos - oldTexturePos - 1;
          this.geometryTextureArray[oldTexturePos * 12 + 9] = item.transformNum;
        } else {
          // Item is dynamic and non-indexable.
          // a, b, c, color, normal, texture_nums, UVs1, UVs2 per triangle in item
          this.geometryTextureArray.set(item.geometryTextureArray, texturePos * 12);
          this.sceneTextureArray.set(item.sceneTextureArray, texturePos * 27);
          // Give item new id property to identify vertex in fragment shader
          for (let i = 0; i < item.length; i ++) this.idBuffer[bufferPos ++] = texturePos ++;
          // Declare bounding volume of object.
          let v = item.vertices;
          minMax = [v[0], v[1], v[2], v[0], v[1], v[2]];
          // get min and max values of veritces of object
          for (let i = 3; i < v.length; i += 3) {
            minMax[0] = Math.min(minMax[0], v[i]);
            minMax[1] = Math.min(minMax[1], v[i + 1]);
            minMax[2] = Math.min(minMax[2], v[i + 2]);
            minMax[3] = Math.max(minMax[3], v[i]);
            minMax[4] = Math.max(minMax[4], v[i + 1]);
            minMax[5] = Math.max(minMax[5], v[i + 2]);
          }
        }
        return minMax;
      }
      // Determine array lengths by walking the graph
      this.textureLength = 0;
      this.bufferLength = 0;
      walkGraph(this);
      // Create new texture and additional arrays
      this.geometryTextureArray = new Float32Array(this.textureLength * 12);
      this.sceneTextureArray = new Float32Array(this.textureLength * 27);
      this.idBuffer = new Int32Array(this.bufferLength);

      let texturePos = 0;
      let bufferPos = 0;
      // Set min and max x, y, z coordinates and start recursion
      this.minMax = fillData(this);
      // Set static flag to true
      this.#static = true;
    } else {
      // Make objects dynamic again
      this.#static = false;
      // Object ids to keep track of
      this.textureLength = 0;
      this.bufferLength = 0;
      // Precalculate arrays and values
      this.geometryTextureArray = null;
      this.sceneTextureArray = null;
      this.minMax = null;
    }
  }

  get static () {
    return this.#static;
  }

  set staticPermanent (staticPermanent) {
    if (this.#staticPermanent && !staticPermanent) {
      console.error('Can\'t unset static permanent, tree is permanently lost');
    }

    if (staticPermanent) {
      this.#staticPermanent = staticPermanent;
      // Make object static
      this.static = true;
      // Dereference subtree children and give them to the garbage collector
      for (let i = 0; i < this.length; i++) this[i] = undefined;
    }
  }

  get staticPermanent () {
    return this.#staticPermanent;
  }

  
  constructor (length) {
    this.relativePosition = [0, 0, 0];
    this.length = length;
    this.indexable = true;
  }
}

export class Bounding extends Object3D {
  constructor (array) { 
    super(array.length);
    array.forEach((item, i) => this[i] = item);
  }
}

export class Cuboid extends Object3D {
  constructor (x, x2, y, y2, z, z2) {
    super(6);
    // Add bias of 2^(-16)
    const bias = 0.00152587890625;
    [x, y, z] = [x + bias, y + bias, z + bias];
    [x2, y2, z2] = [x2 - bias, y2 - bias, z2 - bias];
    // Create surface elements for cuboid
    this.bounding = [x, x2, y, y2, z, z2];
    this.top = new Plane([x, y2, z], [x2, y2, z], [x2, y2, z2], [x, y2, z2]);
    this.right = new Plane([x2, y2, z], [x2, y, z], [x2, y, z2], [x2, y2, z2]);
    this.front = new Plane([x2, y2, z2], [x2, y, z2], [x, y, z2], [x, y2, z2]);
    this.bottom = new Plane([x, y, z2], [x2, y, z2], [x2, y, z], [x, y, z]);
    this.left = new Plane([x, y2, z2], [x, y, z2], [x, y, z], [x, y2, z]);
    this.back = new Plane([x, y2, z], [x, y, z], [x2, y, z], [x2, y2, z]);

    [this.top, this.right, this.front, this.bottom, this.left, this.back].forEach((item, i) => this[i] = item);
  }
}
