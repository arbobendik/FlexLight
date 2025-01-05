// src/flexlight/common/lib/math.ts
var BIAS = 1e-10;
var Vector = class extends Float32Array {
  // Getters for components
  get x() {
    if (this.length > 0) return this[0];
    else throw new Error("Vector has no x component");
  }
  get y() {
    if (this.length > 1) return this[1];
    else throw new Error("Vector has no y component");
  }
  get z() {
    if (this.length > 2) return this[2];
    else throw new Error("Vector has no z component");
  }
  get w() {
    if (this.length > 3) return this[3];
    else throw new Error("Vector has no w component");
  }
  // Setters for components
  set x(value) {
    this[0] = value;
  }
  set y(value) {
    this[1] = value;
  }
  set z(value) {
    this[2] = value;
  }
  set w(value) {
    this[3] = value;
  }
  // Constructor for the Vector class
  constructor(...args) {
    let all_numbers = true;
    for (let arg of args) if (typeof arg !== "number") all_numbers = false;
    if (args.length === 1 && !all_numbers) {
      if ("vector_length" in args[0]) {
        super(args[0].vector_length);
      } else {
        super(args[0]);
      }
    } else if (all_numbers) {
      super(args);
    } else {
      throw new Error("Invalid arguments for Vector constructor.");
    }
  }
  *[Symbol.iterator]() {
    for (let i = 0; i < this.length; i++) yield this[i];
  }
};
var ZeroVector = class extends Vector {
  constructor(n) {
    super({ vector_length: n });
    for (let i = 0; i < n; i++) this[i] = 0;
  }
};
var Matrix = class extends Array {
  // Type assertion for size attributes, matrix is row major
  height;
  width;
  get(x, y) {
    return this[x][y];
  }
  set(x, y, value) {
    this[x][y] = value;
  }
  // Constructor for the Matrix class
  constructor(...rows) {
    let all_arrays = true;
    for (let row of rows) if (!Array.isArray(row)) all_arrays = false;
    if (rows.length === 1 && "matrix_height" in rows[0] && "matrix_width" in rows[0]) {
      let dims = rows[0];
      super(dims.matrix_height);
      this.height = dims.matrix_height;
      this.width = dims.matrix_width;
      for (let i = 0; i < dims.matrix_height; i++) {
        this[i] = new Vector({ vector_length: dims.matrix_width });
      }
    } else if (!all_arrays) {
      super(...rows);
      this.height = this.length;
      this.width = this[0].length;
    } else if (all_arrays) {
      let vectors = rows.map((row) => new Vector(row));
      super(...vectors);
      this.height = this.length;
      this.width = this[0].length;
    } else {
      throw new Error("Invalid number of rows");
    }
  }
  *[Symbol.iterator]() {
    for (let i = 0; i < this.length; i++) yield this[i];
  }
};
var IdentityMatrix = class extends Matrix {
  constructor(n) {
    super({ matrix_height: n, matrix_width: n });
    for (let i = 0; i < n; i++) {
      let row = this[i];
      row[i] = 1;
    }
  }
};
var ZeroMatrix = class extends Matrix {
  constructor(m, n) {
    super({ matrix_height: m, matrix_width: n });
    for (let i = 0; i < m; i++) this[i] = new ZeroVector(n);
  }
};
var HouseholderMatrix = class extends IdentityMatrix {
  constructor(v) {
    super(v.length);
    let outer_product = outer(v, v);
    let scale = 2 / dot(v, v);
    for (let i = 0; i < this.height; i++) for (let j = 0; j < this.width; j++) this[i][j] -= scale * outer_product[i][j];
  }
};
function vector_add(a, b) {
  let result = new Vector({ vector_length: a.length });
  for (let i = 0; i < a.length; i++) result[i] = a[i] + b[i];
  return result;
}
function vector_scale(a, b) {
  let result = new Vector({ vector_length: a.length });
  for (let i = 0; i < a.length; i++) result[i] = a[i] * b;
  return result;
}
function dot(a, b) {
  let result = 0;
  for (let i = 0; i < a.length; i++) result += a[i] * b[i];
  return result;
}
function normalize(a) {
  let result = new ZeroVector(a.length);
  let denominator = Math.sqrt(dot(a, a));
  if (Math.abs(denominator) < BIAS) return result;
  for (let i = 0; i < a.length; i++) result[i] = a[i] / denominator;
  return result;
}
function outer(a, b) {
  let result = new Matrix({ matrix_height: a.length, matrix_width: b.length });
  for (let i = 0; i < result.height; i++) for (let j = 0; j < result.width; j++) result[i][j] = a[i] * b[j];
  return result;
}
function transpose(A) {
  let result = new Matrix({ matrix_height: A.width, matrix_width: A.height });
  for (let i = 0; i < result.height; i++) for (let j = 0; j < result.width; j++) result[i][j] = A[j][i];
  return result;
}
function matrix_scale(A, b) {
  let result = new Matrix({ matrix_height: A.height, matrix_width: A.width });
  for (let i = 0; i < result.height; i++) result[i] = vector_scale(A[i], b);
  return result;
}
function matrix_mul(A, B) {
  let result = new Matrix({ matrix_height: A.height, matrix_width: B.width });
  for (let i = 0; i < result.height; i++) for (let j = 0; j < result.width; j++) for (let k = 0; k < A.width; k++) result[i][j] += A[i][k] * B[k][j];
  return result;
}
function qr(A) {
  let Q = new IdentityMatrix(A.height);
  let R = new Matrix({ matrix_height: A.height, matrix_width: A.width });
  for (let i = 0; i < A.height; i++) for (let j = 0; j < A.width; j++) R[i][j] = A[i][j];
  for (let j = 0; j < Math.min(A.width, A.height - 1); j++) {
    let x = new ZeroVector(A.height);
    for (let i = j; i < A.height; i++) x[i] = R[i][j];
    let xnorm = Math.sqrt(dot(x, x));
    if (Math.abs(xnorm) < BIAS) continue;
    let s = -Math.sign(x[j] || 1);
    let u = new ZeroVector(A.height);
    u[j] = s * xnorm;
    let v = normalize(vector_add(x, u));
    let vnorm = Math.sqrt(dot(v, v));
    if (vnorm < BIAS) continue;
    for (let i = j; i < A.height; i++) v[i] = v[i] / vnorm;
    let H = new HouseholderMatrix(v);
    R = matrix_mul(H, R);
    Q = matrix_mul(Q, transpose(H));
  }
  return { Q, R };
}
function moore_penrose(A) {
  const n = A.width;
  let AT = transpose(A);
  const ATA = matrix_mul(AT, A);
  const QR = qr(ATA);
  let Rinv = new Matrix({ matrix_height: n, matrix_width: n });
  for (let i = n - 1; i >= 0; i--) {
    Rinv[i][i] = 1;
    for (let j = n - 1; j > i; j--) Rinv[i] = vector_add(Rinv[i], vector_scale(Rinv[j], -QR.R[i][j] / QR.R[j][j]));
  }
  for (let i = 0; i < n; i++) Rinv[i] = vector_scale(Rinv[i], 1 / QR.R[i][i]);
  return matrix_mul(matrix_mul(Rinv, transpose(QR.Q)), AT);
}

// src/flexlight/common/scene/camera.ts
var Camera = class {
  // Camera and frustrum settings
  position = new ZeroVector(3);
  direction = new ZeroVector(2);
  fov = 1 / Math.PI;
};

// src/flexlight/common/config.js
var Config = class {
  // Quality settings
  antialiasing = "fxaa";
  temporal = true;
  hdr = true;
  renderQuality = 1;
  samplesPerRay = 1;
  maxReflections = 5;
  minImportancy = 0.3;
  temporalSamples = 4;
};

// src/flexlight/common/math.js
var Math2 = window.Math;
Object.assign(Math2, {
  // Floating point bias for unstable mathods
  BIAS: 2 ** -32,
  // Make results numerically stable
  stabilize: (x) => Math2.abs(x) % 1 < Math2.BIAS || Math2.abs(x) % 1 > 1 - Math2.BIAS ? Math2.round(x) : x,
  // Sum up list of parameters
  sum: function() {
    return Array.prototype.slice.call(arguments).reduce((p, c) => p + c, 0);
  },
  // Multiplies matrices, vectors elementwise or with scalar
  mul: (a, b) => {
    const matMul = (A, B) => {
      let BT = Math2.transpose(B);
      let C = A.map(() => new Array(B[0].length).fill(0));
      return C.map((row, i) => row.map((e, j) => Math2.dot(A[i], BT[j])));
    };
    const dim = (obj) => Array.isArray(obj) ? dim(obj[0]) + 1 : 0;
    const dimA = dim(a);
    const dimB = dim(b);
    switch (dimA) {
      case 0:
        switch (dimB) {
          case 0:
            return a * b;
          case 1:
            return b.map((e) => Math2.stabilize(e * a));
          case 2:
            return b.map((row) => row.map((e) => e * a));
        }
      case 1:
        switch (dimB) {
          case 0:
            return a.map((e) => Math2.stabilize(e * b));
          case 1:
            return a.map((e, i) => Math2.stabilize(e * b[i]));
          case 2:
            return void 0;
        }
      case 2:
        switch (dimB) {
          case 0:
            return a.map((row) => row.map((e) => e * b));
          case 1:
            return matMul(a, b.map((e) => [e])).flat();
          case 2:
            return matMul(a, b);
        }
    }
  },
  // Calculate dot product
  dot: (a, b) => Math2.stabilize(Math2.mul(a, b).reduce((p, c) => p + c, 0)),
  // Calculate cross product for vec3
  cross: (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]],
  // Adds two vectors
  add: (a, b) => a.map((e, i) => e + b[i]),
  // Determines vector between 2 points
  diff: (a, b) => a.map((e, i) => e - b[i]),
  length: (a) => Math2.stabilize(Math2.sqrt(a.reduce((p, c) => p + c ** 2, 0))),
  // Normalize vector
  normalize: (a) => {
    const length = Math2.length(a);
    return a.map((e) => Math2.stabilize(length) < Math2.BIAS ? 0 : Math2.stabilize(e / length));
  },
  // Give identity matrix
  identity: (dim) => {
    let res = new Array(dim).fill(0).map((item) => new Array(dim).fill(0));
    for (let i = 0; i < dim; i++) res[i][i] = 1;
    return res;
  },
  // Orthogonalization
  gramSchmidt: (A, dot2 = Math2.dot) => {
    let B = [];
    A.forEach((row) => {
      B.push(Math2.add(row, Math2.mul(-1, B.reduce((p, c) => {
        return Math2.add(p, Math2.mul(dot2(c, row) / dot2(c, c), c));
      }, new Array(A[0].length).fill(0)))));
    });
    return B;
  },
  // transpose matrix
  transpose: (A) => {
    let C = A[0].map(() => new Array(A.length).fill(0));
    return C.map((row, i) => row.map((e, j) => A[j][i]));
  },
  // QR decomposition
  qr: (A) => {
    let QT = Math2.gramSchmidt(Math2.transpose(A)).map((row) => Math2.normalize(row));
    return {
      Q: Math2.transpose(QT),
      R: Math2.mul(QT, A)
    };
  },
  // find Moore Penrose pseudo inverse of A
  moorePenrose: (A) => {
    let AT = Math2.transpose(A);
    const QR = Math2.qr(Math2.mul(AT, A));
    let Rinv = new Array(QR.R.length);
    for (let i = QR.R.length - 1; i >= 0; i--) {
      Rinv[i] = QR.R.map((e, j) => i === j ? 1 : 0);
      for (let j = QR.R.length - 1; j > i; j--) {
        Rinv[i] = Math2.add(Rinv[i], Math2.mul(Rinv[j], -QR.R[i][j] / QR.R[j][j]));
      }
    }
    for (let i = 0; i < QR.R.length; i++) Rinv[i] = Math2.mul(Rinv[i], 1 / QR.R[i][i]);
    if (Number.isNaN(Rinv[0][0])) return Math2.transpose(Math2.moorePenrose(AT));
    return Math2.mul(Math2.mul(Rinv, Math2.transpose(QR.Q)), AT);
  },
  // linear regression of the points for a polynomial of n-th degree
  regression: (points, n) => {
    let A = points.map(() => new Array(n + 1));
    for (let i = 0; i < points.length; i++) for (let j = 0; j <= n; j++) A[i][j] = points[i][0] ** j;
    let b = points.map((item) => item[1]);
    return Math2.mul(Math2.moorePenrose(A), b);
  },
  // Test if ray intersects triangle and return point of intersection
  rayTriangle: (rayOrigin, rayDirection, tA, tB, tC, n) => {
    const BIAS2 = 2 ** -12;
    const s = Math2.dot(n, Math2.diff(tA, rayOrigin)) / Math2.dot(n, Math2.normalize(rayDirection));
    if (s <= BIAS2) return Infinity;
    let d = Math2.add(Math2.mul(s, Math2.normalize(rayDirection)), rayOrigin);
    let v0 = Math2.diff(tB, tA);
    let v1 = Math2.diff(tC, tA);
    let v2 = Math2.diff(d, tA);
    let d00 = Math2.dot(v0, v0);
    let d01 = Math2.dot(v0, v1);
    let d11 = Math2.dot(v1, v1);
    let d20 = Math2.dot(v2, v0);
    let d21 = Math2.dot(v2, v1);
    let denom = d00 * d11 - d01 * d01;
    let v = (d11 * d20 - d01 * d21) / denom;
    let w = (d00 * d21 - d01 * d20) / denom;
    let u = 1 - v - w;
    if (Math2.min(u, v) <= BIAS2 || u + v >= 1 - BIAS2) return Infinity;
    return s;
  },
  // Sigmoid activation function commonly used in ANNs
  /*
  
                     1-|        ,____------
                       |    /---
                       |   /
                       | /
                   0.5-/
                     / |
                   /   |
               ___/    |
    ______----'________|____________________
         -3            0            3
  
    */
  sigmoid: (x) => 1 / (1 + Math2.E ** -x),
  // Derivative of sigmoid function used for backpropagation in ANNs
  /*
  
                0.25-|-,_
                ,'   |   ',
                /     |     \
              |      |      |
              |       |       |
            /        |        \
            /         |         \
        _-'           |           '-_
    _--'______________|______________'--_
          -3         0         3
  
    */
  sigmoidPrime: (x) => Math2.sigmoid(x) * (1 - Math2.sigmoid(x)),
  // Modulo operator.
  mod: (x, y) => x - y * Math2.floor(x / y)
});

// src/flexlight/common/scene/transform.ts
var Transform = class _Transform {
  referenceNumber = 0;
  rotationMatrix;
  position;
  scaleFactor = 1;
  transformedNodes = /* @__PURE__ */ new Set();
  static NO_TRANSFORM;
  static used = [];
  static transformList = [];
  static buildWGL2Arrays = () => {
    let length = _Transform.transformList.length;
    let rotationBuffer = new Float32Array(24 * length);
    let shiftBuffer = new Float32Array(8 * length);
    for (let i = 0; i < length; i++) {
      let transform = _Transform.transformList[i] ?? _Transform.NO_TRANSFORM;
      let matrix = transform.matrix;
      let inverse = moore_penrose(matrix);
      let pos = transform.position;
      let invPos = vector_scale(transform.position, -1);
      rotationBuffer.set(matrix[0], i * 24);
      rotationBuffer.set(matrix[1], i * 24 + 4);
      rotationBuffer.set(matrix[2], i * 24 + 8);
      rotationBuffer.set(inverse[0], i * 24 + 12);
      rotationBuffer.set(inverse[1], i * 24 + 16);
      rotationBuffer.set(inverse[2], i * 24 + 20);
      shiftBuffer.set(pos, i * 8);
      shiftBuffer.set(invPos, i * 8 + 4);
    }
    return { rotationBuffer, shiftBuffer };
  };
  static buildWGPUArray = () => {
    let length = _Transform.transformList.length;
    let transfromBuffer = new Float32Array(32 * length);
    for (let i = 0; i < length; i++) {
      let transform = _Transform.transformList[i] ?? _Transform.NO_TRANSFORM;
      let matrix = transform.matrix;
      let inverse = moore_penrose(matrix);
      let pos = transform.position;
      let invPos = vector_scale(transform.position, -1);
      transfromBuffer.set(matrix[0], i * 32);
      transfromBuffer.set(matrix[1], i * 32 + 4);
      transfromBuffer.set(matrix[2], i * 32 + 8);
      transfromBuffer.set(pos, i * 32 + 12);
      transfromBuffer.set(inverse[0], i * 32 + 16);
      transfromBuffer.set(inverse[1], i * 32 + 20);
      transfromBuffer.set(inverse[2], i * 32 + 24);
      transfromBuffer.set(invPos, i * 32 + 28);
    }
    return transfromBuffer;
  };
  get number() {
    return this.referenceNumber;
  }
  get matrix() {
    return matrix_scale(this.rotationMatrix, this.scaleFactor);
  }
  move(x, y, z) {
    this.position = new Vector(x, y, z);
  }
  rotateAxis(normal, theta) {
    let n = normal;
    let sT = Math.sin(theta);
    let cT = Math.cos(theta);
    this.rotationMatrix = new Matrix(
      [n.x * n.x * (1 - cT) + cT, n.x * n.y * (1 - cT) - n.z * sT, n.x * n.z * (1 - cT) + n.y * sT],
      [n.x * n.y * (1 - cT) + n.z * sT, n.y * n.y * (1 - cT) + cT, n.y * n.z * (1 - cT) - n.x * sT],
      [n.x * n.z * (1 - cT) - n.y * sT, n.y * n.z * (1 - cT) + n.x * sT, n.z * n.z * (1 - cT) + cT]
    );
  }
  rotateSpherical(theta, psi) {
    let sT = Math.sin(theta);
    let cT = Math.cos(theta);
    let sP = Math.sin(psi);
    let cP = Math.cos(psi);
    this.rotationMatrix = new Matrix(
      [cT, 0, sT],
      [-sT * sP, cP, cT * sP],
      [-sT * cP, -sP, cT * cP]
    );
  }
  scale(s) {
    this.scaleFactor = s;
  }
  addNode(n) {
    this.transformedNodes.add(n);
  }
  removeNode(n) {
    this.transformedNodes.delete(n);
  }
  destroy() {
    _Transform.used[this.referenceNumber] = false;
    _Transform.transformList[this.referenceNumber] = void 0;
  }
  static classConstructor = function() {
    _Transform.NO_TRANSFORM = new _Transform();
  }();
  constructor() {
    this.rotationMatrix = new IdentityMatrix(3);
    this.position = new ZeroVector(3);
    for (let i = 0; i < Infinity; i++) {
      if (_Transform.used[i]) continue;
      _Transform.used[i] = true;
      this.referenceNumber = i;
      break;
    }
    _Transform.transformList[this.referenceNumber] = this;
  }
};

// src/flexlight/common/scene.js
var BVH_MAX_LEAVES_PER_NODE = 4;
var Scene = class _Scene {
  // light sources and textures
  primaryLightSources = [[0, 10, 0]];
  defaultLightIntensity = 200;
  defaultLightVariation = 0.4;
  ambientLight = [0.025, 0.025, 0.025];
  textures = [];
  pbrTextures = [];
  translucencyTextures = [];
  standardTextureSizes = [1024, 1024];
  // The queue object contains all data of all vertices in the scene
  queue = [];
  // Generate texture from rgb array in static function to have function precompiled
  static async textureFromRGB(array, width, height) {
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    canvas.width = width;
    canvas.height = height;
    ctx.imageSmoothingEnabled = false;
    let imgData = ctx.createImageData(width, height);
    imgData.data.set(new Uint8ClampedArray(array), 0);
    ctx.putImageData(imgData, 0, 0);
    let image = new Image();
    image.src = canvas.toDataURL();
    return image;
  }
  // Generate pbr texture (roughness, metallicity, emissiveness)
  static async textureFromRME(array, width, height) {
    let texelArray = [];
    for (let i = 0; i < array.length; i += 3) texelArray.push(array[i] * 255, array[i + 1] * 255, array[i + 2] * 255, 255);
    return await this.textureFromRGB(texelArray, width, height);
  }
  static fitsInBound(bound, obj) {
    return bound[0] <= obj.bounding[0] && bound[2] <= obj.bounding[2] && bound[4] <= obj.bounding[4] && bound[1] >= obj.bounding[1] && bound[3] >= obj.bounding[3] && bound[5] >= obj.bounding[5];
  }
  // Autogenerate oct-tree for imported structures or structures without BVH-tree
  static generateBVH(objects) {
    let testOnEdge = (objs, bounding0, bounding1) => {
      let onEdge = 0;
      for (let i = 0; i < objs.length; i++) if (!_Scene.fitsInBound(bounding0, objs[i]) && !_Scene.fitsInBound(bounding1, objs[i])) onEdge++;
      return onEdge;
    };
    let divideTree = (objs, depth = 0) => {
      if (objs.length <= BVH_MAX_LEAVES_PER_NODE || depth > maxTree) {
        polyCount += objs.length;
        return objs;
      } else {
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
          let minDiff = Math2.min(bounding0[i * 2 + 1] - center[i], center[i] - bounding1[i * 2]);
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
        let buckets = [[], [], []];
        let bounds = [objs.bounding, objs.bounding.concat(), objs.bounding.concat()];
        bounds[0][idealSplit * 2] = center[idealSplit];
        bounds[1][idealSplit * 2 + 1] = center[idealSplit];
        for (let i = 0; i < objs.length; i++) {
          if (_Scene.fitsInBound(bounds[0], objs[i])) buckets[0].push(objs[i]);
          else if (_Scene.fitsInBound(bounds[1], objs[i])) buckets[1].push(objs[i]);
          else buckets[2].push(objs[i]);
        }
        let finalObjArray = [];
        for (let i = 0; i < 3; i++) if (buckets[i].length !== 0) {
          let b = new Bounding(buckets[i]);
          _Scene.updateBoundings(b);
          finalObjArray.push(divideTree(b, depth + 1));
        }
        let commonBounding = new Bounding(finalObjArray);
        commonBounding.bounding = objs.bounding;
        return commonBounding;
      }
    };
    const minBoundingWidth = 1 / 256;
    let topTree = new Bounding(objects);
    _Scene.updateBoundings(topTree);
    let polyCount = 0;
    let maxTree = Math2.log2(topTree.length) + 8;
    topTree = divideTree(topTree);
    console.log("done building BVH-Tree");
    console.log(maxTree);
    return topTree;
  }
  // Update all bounding volumes in scene
  static updateBoundings(obj) {
    const bias = 0.00152587890625;
    let minMax = new Array(6);
    if (Array.isArray(obj) || obj.indexable) {
      if (obj.length === 0 && !obj.blockError) {
        console.error("problematic object structure", "isArray:", Array.isArray(obj), "indexable:", obj.indexable, "object:", obj);
        obj.blockError = true;
      } else {
        minMax = _Scene.updateBoundings(obj[0]);
        for (let i = 1; i < obj.length; i++) {
          let b = _Scene.updateBoundings(obj[i]);
          minMax = minMax.map((item, i2) => i2 % 2 === 0 ? Math2.min(item, b[i2] - bias) : Math2.max(item, b[i2] + bias));
        }
      }
    } else {
      let v = obj.vertices;
      minMax = [v[0], v[0], v[1], v[1], v[2], v[2]];
      for (let i = 3; i < obj.vertices.length; i++) {
        minMax[i % 3 * 2] = Math2.min(minMax[i % 3 * 2], v[i]);
        minMax[i % 3 * 2 + 1] = Math2.max(minMax[i % 3 * 2 + 1], v[i]);
      }
    }
    obj.bounding = minMax;
    return minMax;
  }
  // Generate texture arrays
  static generateArraysFromGraph(obj) {
    let textureLength;
    let bufferLength;
    let geometryBufferWidth;
    let sceneBufferWidth;
    let geometryBufferHeight;
    let sceneBufferHeight;
    let geometryBuffer;
    let sceneBuffer;
    let idBuffer;
    let walkGraph = (item) => {
      if (item.static) {
        textureLength += item.textureLength;
        bufferLength += item.bufferLength;
      } else if (Array.isArray(item) || item.indexable) {
        if (item.length === 0) return;
        textureLength++;
        for (let i = 0; i < item.length; i++) walkGraph(item[i]);
      } else {
        textureLength += item.length;
        bufferLength += item.length;
      }
    };
    let fillData = (item) => {
      if (item.static) {
        geometryBuffer.set(item.geometryBuffer, texturePos * 12);
        sceneBuffer.set(item.sceneBuffer, texturePos * 28);
        for (let i = 0; i < item.bufferLength; i++) idBuffer[bufferPos + i] = texturePos + item.idBuffer[i];
        texturePos += item.textureLength;
        bufferPos += item.bufferLength;
        return item.minMax;
      } else if (Array.isArray(item) || item.indexable) {
        if (item.length === 0) return [];
        let oldTexturePos = texturePos;
        texturePos++;
        let curMinMax = fillData(item[0]);
        for (let i = 1; i < item.length; i++) {
          let b = fillData(item[i]);
          curMinMax[0] = Math2.min(curMinMax[0], b[0]);
          curMinMax[1] = Math2.min(curMinMax[1], b[1]);
          curMinMax[2] = Math2.min(curMinMax[2], b[2]);
          curMinMax[3] = Math2.max(curMinMax[3], b[3]);
          curMinMax[4] = Math2.max(curMinMax[4], b[4]);
          curMinMax[5] = Math2.max(curMinMax[5], b[5]);
        }
        for (let i = 0; i < 6; i++) geometryBuffer[oldTexturePos * 12 + i] = curMinMax[i];
        geometryBuffer[oldTexturePos * 12 + 6] = texturePos - oldTexturePos - 1;
        geometryBuffer[oldTexturePos * 12 + 9] = item.transformNum ?? 0;
        geometryBuffer[oldTexturePos * 12 + 10] = 1;
        return curMinMax;
      } else {
        geometryBuffer.set(item.geometryBuffer, texturePos * 12);
        sceneBuffer.set(item.sceneBuffer, texturePos * 28);
        for (let i = 0; i < item.length; i++) idBuffer[bufferPos++] = texturePos++;
        let curMinMax = item.aabb;
        return curMinMax;
      }
    };
    textureLength = 0;
    bufferLength = 0;
    walkGraph(obj);
    let texturePos = 0;
    let bufferPos = 0;
    geometryBufferWidth = 3 * 4 * 256;
    sceneBufferWidth = 7 * 4 * 256;
    console.log(Math2.ceil(textureLength * 12 / geometryBufferWidth) * geometryBufferWidth);
    geometryBuffer = new Float32Array(Math2.ceil(textureLength * 12 / geometryBufferWidth) * geometryBufferWidth);
    sceneBuffer = new Float32Array(Math2.ceil(textureLength * 28 / sceneBufferWidth) * sceneBufferWidth);
    idBuffer = new Int32Array(bufferLength);
    let minMax = fillData(obj);
    geometryBufferHeight = geometryBuffer.length / geometryBufferWidth;
    sceneBufferHeight = geometryBuffer.length / geometryBufferWidth;
    return {
      textureLength,
      bufferLength,
      idBuffer,
      minMax,
      geometryBufferHeight,
      geometryBuffer,
      sceneBufferHeight,
      sceneBuffer
    };
  }
  // texture constructors
  textureFromRGB = async (array, width, height) => await _Scene.textureFromRGB(array, width, height);
  // Make static function callable from object
  textureFromRME = async (array, width, height) => await _Scene.textureFromRME(array, width, height);
  // Generate translucency texture (translucency, particle density, optical density)
  // Pbr images are generated the same way
  textureFromTPO = async (array, width, height) => await _Scene.textureFromRME(array, width, height);
  generateBVH() {
    return _Scene.generateBVH(this.queue);
  }
  updateBoundings() {
    return _Scene.updateBoundings(this.queue);
  }
  generateArraysFromGraph() {
    return _Scene.generateArraysFromGraph(this.queue);
  }
  // Pass some constructors
  Transform = (matrix) => new Transform(matrix);
  // axis aligned cuboid element prototype
  Cuboid = (x, x2, y, y2, z, z2) => new Cuboid(x, x2, y, y2, z, z2);
  // surface element prototype
  Plane = (c0, c1, c2, c3) => new Plane(c0, c1, c2, c3);
  // triangle element prototype
  Triangle = (a, b, c) => new Triangle(a, b, c);
  // bounding element
  Bounding = (array) => new Bounding(array);
  // generate object from array
  // Create object from .obj file
  importObj = async (path, materials = []) => {
    let obj = [];
    let v = [];
    let vt = [];
    let vn = [];
    let curMaterialName;
    let interpreteLine = (line) => {
      let words = [];
      line.split(/[\t \s\s+]/g).forEach((word) => {
        if (word.length) words.push(word);
      });
      switch (words[0]) {
        case "v":
          v.push([Number(words[1]), Number(words[2]), Number(words[3])]);
          break;
        case "vt":
          vt.push([Number(words[1]), Number(words[2])]);
          break;
        case "vn":
          vn.push([Number(words[1]), Number(words[2]), Number(words[3])]);
          break;
        case "f":
          let dataString = words.slice(1, words.length).join(" ");
          let data = dataString.split(/[ ]/g).filter((vertex) => vertex.length).map((vertex) => vertex.split(/[/]/g).map((numStr) => {
            let num = Number(numStr);
            if (num < 0) num = v.length + num + 1;
            return num;
          }));
          let primitive;
          if (data.length === 4) {
            primitive = new Plane(
              v[data[3][0] - 1],
              v[data[2][0] - 1],
              v[data[1][0] - 1],
              v[data[0][0] - 1]
            );
            [3, 2, 1, 1, 0, 3].forEach((index, i) => {
              if (vt[data[index][1] - 1] !== void 0) primitive.uvs.set(vt[data[index][1] - 1], i * 2);
              if (vn[data[index][2] - 1] !== void 0) primitive.normals.set(vn[data[index][2] - 1], i * 3);
            });
          } else {
            primitive = new Triangle(
              v[data[2][0] - 1],
              v[data[1][0] - 1],
              v[data[0][0] - 1]
            );
            [2, 1, 0].forEach((index, i) => {
              if (vt[data[index][1] - 1] !== void 0) primitive.uvs.set(vt[data[index][1] - 1], i * 2);
              if (vn[data[index][2] - 1] !== void 0) primitive.normals.set(vn[data[index][2] - 1], i * 3);
            });
          }
          if (curMaterialName) {
            let material = materials[curMaterialName];
            primitive.color = material.color ?? [255, 255, 255];
            primitive.emissiveness = material.emissiveness ?? 0;
            primitive.metallicity = material.metallicity ?? 0;
            primitive.roughness = material.roughness ?? 1;
            primitive.translucency = material.translucency ?? 0;
            primitive.ior = material.ior ?? 1;
          }
          obj.push(primitive);
          break;
        case "usemtl":
          if (materials[words[1]]) {
            curMaterialName = words[1];
          } else {
            console.warn("Couldn't resolve material", curMaterialName);
          }
          break;
      }
    };
    let text = await (await fetch(path)).text();
    console.log("Parsing vertices ...");
    text.split(/\r\n|\r|\n/).forEach((line) => interpreteLine(line));
    console.log("Generating BVH ...");
    obj = _Scene.generateBVH(obj);
    _Scene.updateBoundings(obj);
    return obj;
  };
  importMtl = async (path) => {
    let materials = [];
    let currentMaterialName;
    let interpreteLine = (line) => {
      let words = [];
      line.split(/[\t \s\s+]/g).forEach((word) => {
        if (word.length) words.push(word);
      });
      switch (words[0]) {
        case "newmtl":
          currentMaterialName = words[1];
          materials[currentMaterialName] = {};
          break;
        case "Ka":
          materials[currentMaterialName].color = Math2.mul(255, [Number(words[1]), Number(words[2]), Number(words[3])]);
          break;
        case "Ke":
          let emissiveness = Math2.max(Number(words[1]), Number(words[2]), Number(words[3]));
          if (emissiveness > 0) {
            materials[currentMaterialName].emissiveness = emissiveness * 4;
            materials[currentMaterialName].color = Math2.mul(255 / emissiveness, [Number(words[1]), Number(words[2]), Number(words[3])]);
          }
          break;
        case "Ns":
          materials[currentMaterialName].metallicity = Number(words[1] / 1e3);
          break;
        case "d":
          break;
        case "Ni":
          materials[currentMaterialName].ior = Number(words[1]);
          break;
      }
    };
    let text = await (await fetch(path)).text();
    console.log("Parsing materials ...");
    text.split(/\r\n|\r|\n/).forEach((line) => interpreteLine(line));
    console.log(materials);
    return materials;
  };
};
var Primitive = class {
  #vertices;
  #normal;
  #normals;
  #uvs;
  #transform;
  #textureNums = new Float32Array([-1, -1, -1]);
  #albedo = new Float32Array([1, 1, 1]);
  #rme = new Float32Array([1, 0, 0]);
  #tpo = new Float32Array([0, 0, 1]);
  geometryBuffer;
  sceneBuffer;
  #buildTextureArrays = () => {
    for (let i = 0; i < this.length; i++) {
      let i12 = i * 12;
      this.geometryBuffer.set(this.#vertices.slice(i * 9, i * 9 + 9), i12);
      this.geometryBuffer[i12 + 9] = this.transformNum;
      this.geometryBuffer[i12 + 10] = 2;
      let i28 = i * 28;
      this.sceneBuffer.set(this.#normals.slice(i * 9, i * 9 + 9), i28);
      this.sceneBuffer.set(this.#uvs.slice(i * 6, i * 6 + 6), i28 + 9);
      this.sceneBuffer.set(this.#textureNums, i28 + 15);
      this.sceneBuffer.set(this.#albedo, i28 + 18);
      this.sceneBuffer.set(this.#rme, i28 + 21);
      this.sceneBuffer.set(this.#tpo, i28 + 24);
    }
  };
  get aabb() {
    let v = this.vertices;
    let curMinMax = [v[0], v[1], v[2], v[0], v[1], v[2]];
    for (let i = 3; i < v.length; i += 3) {
      curMinMax[0] = Math2.min(curMinMax[0], v[i]);
      curMinMax[1] = Math2.min(curMinMax[1], v[i + 1]);
      curMinMax[2] = Math2.min(curMinMax[2], v[i + 2]);
      curMinMax[3] = Math2.max(curMinMax[3], v[i]);
      curMinMax[4] = Math2.max(curMinMax[4], v[i + 1]);
      curMinMax[5] = Math2.max(curMinMax[5], v[i + 2]);
    }
    return curMinMax;
  }
  get vertices() {
    return this.#vertices;
  }
  get normals() {
    return this.#normals;
  }
  get normal() {
    return this.#normal;
  }
  get transformNum() {
    return this.#transform ? this.#transform.number : 0;
  }
  get transform() {
    return this.#transform;
  }
  get textureNums() {
    return this.#textureNums;
  }
  get color() {
    return this.#albedo;
  }
  get albedo() {
    return this.#albedo;
  }
  get roughness() {
    return this.#rme[0];
  }
  get metallicity() {
    return this.#rme[1];
  }
  get emissiveness() {
    return this.#rme[2];
  }
  get translucency() {
    return this.#tpo[0];
  }
  get ior() {
    return this.#tpo[2];
  }
  get uvs() {
    return this.#uvs;
  }
  set vertices(v) {
    this.#vertices = new Float32Array(v);
    this.#buildTextureArrays();
  }
  set normals(ns) {
    this.#normals = new Float32Array(ns);
    this.#normal = new Float32Array(ns.slice(0, 3));
    this.#buildTextureArrays();
  }
  set normal(n) {
    this.#normals = new Float32Array(new Array(this.length * 3).fill(n).flat());
    this.#normal = new Float32Array(n);
    this.#buildTextureArrays();
  }
  set transform(t) {
    if (this.#transform) this.#transform.deleteNode(this);
    t.addNode(this);
    this.setTransformRec(t);
  }
  setTransformRec = (t) => {
    this.#transform = t;
    this.#buildTextureArrays();
  };
  set textureNums(tn) {
    this.#textureNums = tn;
    this.#buildTextureArrays();
  }
  set color(c) {
    let color = c.map((val) => val / 255);
    this.#albedo = new Float32Array(color);
    this.#buildTextureArrays();
  }
  set albedo(a) {
    this.color = a;
  }
  set roughness(r) {
    this.#rme[0] = r;
    this.#buildTextureArrays();
  }
  set metallicity(m) {
    this.#rme[1] = m;
    this.#buildTextureArrays();
  }
  set emissiveness(e) {
    this.#rme[2] = e;
    this.#buildTextureArrays();
  }
  set translucency(t) {
    this.#tpo[0] = t;
    this.#buildTextureArrays();
  }
  set ior(o) {
    this.#tpo[2] = o;
    this.#buildTextureArrays();
  }
  set uvs(uv) {
    this.#uvs = new Float32Array(uv);
    this.#buildTextureArrays();
  }
  constructor(length, vertices, normal, uvs) {
    this.indexable = false;
    this.length = length;
    this.#vertices = new Float32Array(vertices);
    this.#normal = new Float32Array(normal);
    this.#normals = new Float32Array(new Array(this.length * 3).fill(normal).flat());
    this.#uvs = new Float32Array(uvs);
    this.geometryBuffer = new Float32Array(this.length * 12);
    this.sceneBuffer = new Float32Array(this.length * 28);
    this.#buildTextureArrays();
  }
};
var Plane = class extends Primitive {
  constructor(c0, c1, c2, c3) {
    super(2, [c0, c1, c2, c2, c3, c0].flat(), Math2.normalize(Math2.cross(Math2.diff(c0, c2), Math2.diff(c0, c1))), [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0]);
  }
};
var Triangle = class extends Primitive {
  constructor(a, b, c) {
    super(1, [a, b, c].flat(), Math2.normalize(Math2.cross(Math2.diff(a, c), Math2.diff(a, b))), [0, 0, 0, 1, 1, 1]);
  }
};
var Object3D = class {
  #static = false;
  #staticPermanent = false;
  #transform;
  get transformNum() {
    return this.#transform ? this.#transform.number : 0;
  }
  get transform() {
    return this.#transform;
  }
  set transform(t) {
    if (this.#transform) this.#transform.deleteNode(this);
    t.addNode(this);
    this.setTransformRec(t);
  }
  setTransformRec = (t) => {
    this.#transform = t;
    for (let i = 0; i < this.length; i++) this[i].setTransformRec(t);
  };
  set textureNums(tn) {
    for (let i = 0; i < this.length; i++) this[i].textureNums = tn;
  }
  set color(c) {
    for (let i = 0; i < this.length; i++) this[i].color = c;
  }
  set albedo(a) {
    for (let i = 0; i < this.length; i++) this[i].albedo = a;
  }
  set roughness(r) {
    for (let i = 0; i < this.length; i++) this[i].roughness = r;
  }
  set metallicity(m) {
    for (let i = 0; i < this.length; i++) this[i].metallicity = m;
  }
  set emissiveness(e) {
    for (let i = 0; i < this.length; i++) this[i].emissiveness = e;
  }
  set translucency(t) {
    for (let i = 0; i < this.length; i++) this[i].translucency = t;
  }
  set ior(o) {
    for (let i = 0; i < this.length; i++) this[i].ior = o;
  }
  // move object by given vector
  move(x, y, z) {
    this.relativePosition = [x, y, z];
    for (let i = 0; i < this.length; i++) {
      if (this[i].indexable) {
        this[i].move(x, y, z);
      } else {
        this[i].vertices = this[i].vertices.map((coord, i2) => {
          switch (i2 % 3) {
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
  scale(s) {
    for (let i = 0; i < this.length; i++) {
      if (this[i].indexable) {
        this[i].scale(s);
      } else {
        this[i].vertices = this[i].vertices.map((coord, i2) => (coord - this.relativePosition[i2 % 3]) * s + this.relativePosition[i2 % 3]);
      }
    }
  }
  set static(isStatic) {
    if (isStatic) {
      let attribs = Scene.generateArraysFromGraph(this);
      this.textureLength = attribs.textureLength;
      this.bufferLength = attribs.bufferLength;
      this.idBuffer = attribs.idBuffer;
      this.geometryBuffer = attribs.geometryBuffer;
      this.sceneBuffer = attribs.sceneBuffer;
      this.minMax = attribs.minMax;
      this.#static = true;
    } else {
      this.#static = false;
      this.textureLength = 0;
      this.bufferLength = 0;
      this.geometryBuffer = null;
      this.sceneBuffer = null;
      this.minMax = null;
    }
  }
  get static() {
    return this.#static;
  }
  set staticPermanent(staticPermanent) {
    if (this.#staticPermanent && !staticPermanent) {
      console.error("Can't unset static permanent, tree is permanently lost");
    }
    if (staticPermanent) {
      this.#staticPermanent = staticPermanent;
      this.static = true;
      for (let i = 0; i < this.length; i++) this[i] = void 0;
    }
  }
  get staticPermanent() {
    return this.#staticPermanent;
  }
  constructor(length) {
    this.relativePosition = [0, 0, 0];
    this.length = length;
    this.indexable = true;
  }
};
var Bounding = class extends Object3D {
  constructor(array) {
    super(array.length);
    array.forEach((item, i) => this[i] = item);
  }
};
var Cuboid = class extends Object3D {
  constructor(x, x2, y, y2, z, z2) {
    super(6);
    const bias = 0.00152587890625;
    [x, y, z] = [x + bias, y + bias, z + bias];
    [x2, y2, z2] = [x2 - bias, y2 - bias, z2 - bias];
    this.bounding = [x, x2, y, y2, z, z2];
    this.top = new Plane([x, y2, z], [x2, y2, z], [x2, y2, z2], [x, y2, z2]);
    this.right = new Plane([x2, y2, z], [x2, y, z], [x2, y, z2], [x2, y2, z2]);
    this.front = new Plane([x2, y2, z2], [x2, y, z2], [x, y, z2], [x, y2, z2]);
    this.bottom = new Plane([x, y, z2], [x2, y, z2], [x2, y, z], [x, y, z]);
    this.left = new Plane([x, y2, z2], [x, y, z2], [x, y, z], [x, y2, z]);
    this.back = new Plane([x, y2, z], [x, y, z], [x2, y, z], [x2, y2, z]);
    [this.top, this.right, this.front, this.bottom, this.left, this.back].forEach((item, i) => this[i] = item);
  }
};

// src/flexlight/webgl2/renderer.js
var GLLib = class _GLLib {
  static postVertex = `#version 300 es
  in vec2 position2d;
  // Pass clip space position to fragment shader
  out vec2 clipSpace;
  void main() {
    vec2 pos = position2d * 2.0 - 1.0;
    // Set final clip space position
    gl_Position = vec4(pos, 0, 1);
    clipSpace = position2d;
  }
  `;
  static computeVertex = `#version 300 es
  in vec4 position;
  void main() {
    gl_Position = position;
  }`;
  static addCompileTimeConstant = (shaderSrc, name, value) => {
    let newSrc = shaderSrc.slice(15);
    return `#version 300 es
    #define ` + name + ` ` + value + `
    ` + newSrc;
  };
  static compile = (gl, vertex, fragment) => {
    var shaders = [
      { source: vertex, type: gl.VERTEX_SHADER },
      { source: fragment, type: gl.FRAGMENT_SHADER }
    ];
    let program = gl.createProgram();
    shaders.forEach(async (item, i) => {
      let shader = gl.createShader(item.type);
      gl.shaderSource(shader, item.source);
      gl.compileShader(shader);
      if (gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        gl.attachShader(program, shader);
      } else {
        console.warn(gl.getShaderInfoLog(shader));
        console.log(item.source);
        gl.deleteShader(shader);
      }
    });
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      console.warn(gl.getProgramInfoLog(program));
      gl.deleteProgram(program);
    } else {
      return program;
    }
  };
  static setTexParams = (gl) => {
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
  };
  static setByteTexture = (gl, array, width, height) => {
    let tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, array);
    _GLLib.setTexParams(gl);
    return tex;
  };
  // Convert 4 bytes, texture channels to usable float.
  static toFloat = (bytes) => (bytes[0] + bytes[1] / 255 + bytes[2] / 65025 + bytes[3] / 16581375) * 2 - 255;
  // Split float into 4 8-bit texture channels.
  static toBytes = (num) => {
    let f = (num + 255) / 2;
    let bytes = [f, f * 255, f * 65025, f * 16581375];
    return bytes.map((item, i) => bytes[i] = Math2.floor(Math2.mod(item, 255)));
  };
};

// src/flexlight/webgl2/shaders/fxaa.glsl
var fxaa_default = "#version 300 es\n\n// Define FXAA constants\n#define FXAA_EDGE_THRESHOLD_MIN 1.0 / 32.0\n#define FXAA_EDGE_THRESHOLD 1.0 / 2.0\n#define FXAA_SUBPIX_TRIM 0.0\n#define FXAA_SUBPIX_TRIM_SCALE 1.0\n#define FXAA_SUBPIX_CAP 7.0 / 8.0\n#define FXAA_SEARCH_STEPS 6\nprecision highp float;\nin vec2 clipSpace;\nuniform sampler2D preRender;\nout vec4 out_color;\nvec2 texel;\n\nvec4 fetch(int x, int y) {\n    return texelFetch(preRender, ivec2(texel) + ivec2(x, y), 0);\n}\n\n// Color to luminance conversion from NVIDIA FXAA white paper\nfloat fxaa_luma(vec4 rgba) {\n    return (rgba.y * (0.587/0.299) + rgba.x) * rgba.w;\n}\n\nfloat tex_luma(int x, int y) {\n    // Devide length through square root of 3 to have a maximum length of 1\n    return fxaa_luma(fetch(x, y));\n}\n\n// Local contrast checker from NVIDIA FXAA white paper\nvec2 fxaa_contrast(int x, int y) {\n    return vec2(\n    min(tex_luma(x, y), min(min(tex_luma(x, y-1), tex_luma(x-1, y)), min(tex_luma(x, y+1), tex_luma(x+1, y)))),\n    max(tex_luma(x, y), max(max(tex_luma(x, y-1), tex_luma(x-1, y)), max(tex_luma(x, y+1), tex_luma(x+1, y))))\n    );\n}\n\n// Local low contrast checker from NVIDIA FXAA white paper\nbool fxaa_is_low_contrast(int x, int y) {\n    vec2 range_min_max = fxaa_contrast(x, y);\n    float range = range_min_max.y - range_min_max.x;\n    return (range < max(FXAA_EDGE_THRESHOLD_MIN, range_min_max.y * FXAA_EDGE_THRESHOLD));\n}\n\nvec4 blur_3x3(int x, int y) {\n    return 1.0 / 9.0 * (\n        fetch(x-1,y-1) + fetch(  x,y-1) + fetch(x+1,y-1)\n    + fetch(x-1,  y) + fetch(  x,  y) + fetch(x+1,  y)\n    + fetch(x-1,y+1) + fetch(  x,y+1) + fetch(x+1,y+1)\n    );\n}\n\nfloat fxaa_sub_pixel_aliasing(int x, int y) {\n    float luma_l = 0.25 * (tex_luma(x,y-1) + tex_luma(x-1,y) + tex_luma(x+1,y) + tex_luma(x,y+1));\n    float range_l = abs(luma_l - tex_luma(x, y));\n    // Get contrast range\n    vec2 range_min_max = fxaa_contrast(x, y);\n    float range = range_min_max.y - range_min_max.x;\n    float blend_l = max(0.0,\n    (range_l / range) - FXAA_SUBPIX_TRIM) * FXAA_SUBPIX_TRIM_SCALE;\n    blend_l = min(FXAA_SUBPIX_CAP, blend_l);\n    return blend_l;\n}\n\nvoid main() {\n    // Get texture size\n    texel = vec2(textureSize(preRender, 0)) * clipSpace;\n    vec4 original_color = fetch(0, 0);\n    float original_luma = tex_luma(0, 0);\n\n    mat3 luma = mat3(\n    vec3(tex_luma(-1,-1),tex_luma(0,-1),tex_luma(1,-1)),\n    vec3(tex_luma(-1, 0),tex_luma(0, 0),tex_luma(1, 0)),\n    vec3(tex_luma(-1, 1),tex_luma(0, 1),tex_luma(1, 1))\n    );\n\n    // Edge detection from NVIDIA FXAA white paper\n    float edge_vert =\n    abs((0.25 * luma[0].x) + (-0.5 * luma[0].y) + (0.25 * luma[0].z)) +\n    abs((0.50 * luma[1].x) + (-1.0 * luma[1].y) + (0.50 * luma[1].z)) +\n    abs((0.25 * luma[2].x) + (-0.5 * luma[2].y) + (0.25 * luma[2].z));\n\n    float edge_horz =\n    abs((0.25 * luma[0].x) + (-0.5 * luma[1].x) + (0.25 * luma[2].x)) +\n    abs((0.50 * luma[0].y) + (-1.0 * luma[1].y) + (0.50 * luma[2].y)) +\n    abs((0.25 * luma[0].z) + (-0.5 * luma[1].z) + (0.25 * luma[2].z));\n\n    bool horz_span = edge_horz >= edge_vert;\n    ivec2 step = ivec2(0, 1);\n    if (horz_span) step = ivec2(1, 0);\n\n    if (fxaa_is_low_contrast(0, 0)) {\n    out_color = original_color;\n    return;\n    }\n\n    ivec2 pos_n = - step;\n    ivec2 pos_p = step;\n    vec4 color = original_color;\n    float pixel_count = 1.0;\n    bool done_n = false;\n    bool done_p = false;\n\n    // Luma of neighbour with highest contrast\n    float luma_mcn = max(\n    max(abs(luma[0].y - luma[1].y), abs(luma[1].z - luma[1].y)),\n    max(abs(luma[2].y - luma[1].y), abs(luma[1].x - luma[1].y))\n    );\n\n    float gradient = abs(luma_mcn - luma[1].y);\n\n    for (int i = 0; i < FXAA_SEARCH_STEPS; i++) {\n    // Blend pixel with 3x3 box filter to preserve sub pixel detail\n    if (!done_n) {\n        vec4 local_blur_n = blur_3x3(pos_n.x, pos_n.y);\n        done_n = (abs(fxaa_luma(local_blur_n) - luma_mcn) >= gradient);\n        color += mix(fetch(pos_n.x, pos_n.y), local_blur_n, fxaa_sub_pixel_aliasing(pos_n.x, pos_n.y));\n        pixel_count++;\n        pos_n -= step;\n    } else if (!done_p) {\n        vec4 local_blur_p = blur_3x3(pos_p.x, pos_p.y);\n        done_p = (abs(fxaa_luma(local_blur_p) - luma_mcn) >= gradient);\n        color += mix(fetch(pos_p.x, pos_p.y), local_blur_p, fxaa_sub_pixel_aliasing(pos_p.x, pos_p.y));\n        pixel_count++;\n        pos_p += step;\n    } else {\n        break;\n    }\n    }\n    out_color = color / pixel_count;\n}";

// src/flexlight/webgl2/fxaa.js
var FXAA = class {
  textureIn;
  #canvas;
  #program;
  #tex;
  #vao;
  #vertexBuffer;
  #gl;
  constructor(gl, canvas) {
    this.#gl = gl;
    this.#canvas = canvas;
    this.#program = GLLib.compile(gl, GLLib.postVertex, fxaa_default);
    this.#vao = gl.createVertexArray();
    this.textureIn = gl.createTexture();
    gl.bindVertexArray(this.#vao);
    gl.useProgram(this.#program);
    this.#tex = gl.getUniformLocation(this.#program, "preRender");
    this.#vertexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, this.#vertexBuffer);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, this.#vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, Float32Array.from([0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0]), gl.DYNAMIC_DRAW);
    this.createTexture();
  }
  createTexture = () => {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.textureIn);
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#canvas.width, this.#canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, null);
    GLLib.setTexParams(this.#gl);
  };
  renderFrame = () => {
    this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, null);
    this.#gl.activeTexture(this.#gl.TEXTURE0);
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.textureIn);
    this.#gl.useProgram(this.#program);
    this.#gl.bindVertexArray(this.#vao);
    this.#gl.uniform1i(this.#tex, 0);
    this.#gl.drawArrays(this.#gl.TRIANGLES, 0, 6);
  };
};

// src/flexlight/webgl2/shaders/taa.glsl
var taa_default = "#version 300 es\nprecision highp float;\nin vec2 clipSpace;\nuniform sampler2D cache0;\nuniform sampler2D cache1;\nuniform sampler2D cache2;\nuniform sampler2D cache3;\nuniform sampler2D cache4;\nuniform sampler2D cache5;\nuniform sampler2D cache6;\nuniform sampler2D cache7;\nuniform sampler2D cache8;\nout vec4 outColor;\n\nvoid main () {\n    ivec2 texel = ivec2(vec2(textureSize(cache0, 0)) * clipSpace);\n\n    mat4 c0 = mat4(\n        texelFetch(cache1, texel, 0), \n        texelFetch(cache2, texel, 0),\n        texelFetch(cache3, texel, 0),\n        texelFetch(cache4, texel, 0)\n    );\n\n    mat4 c1 = mat4(\n        texelFetch(cache5, texel, 0), \n        texelFetch(cache6, texel, 0),\n        texelFetch(cache7, texel, 0),\n        texelFetch(cache8, texel, 0)\n    );\n\n    vec4 minRGB = vec4(1.0);\n    vec4 maxRGB = vec4(0.0);\n    \n    for (int i = 0; i < 3; i++) {\n        for (int j = 0; j < 3; j++) {\n            vec4 p = texelFetch(cache0, texel + ivec2(i - 1, j - 1), 0);\n            minRGB = min(minRGB, p);\n            maxRGB = max(maxRGB, p);\n        }\n    }\n    \n    outColor = texelFetch(cache0, texel, 0);\n    for (int i = 0; i < 4; i++) outColor += min(max(c0[i], minRGB), maxRGB);\n    for (int i = 0; i < 4; i++) outColor += min(max(c1[i], minRGB), maxRGB);\n    outColor /= 9.0;\n}";

// src/flexlight/webgl2/taa.js
var FRAMES = 9;
var TAA = class {
  textureIn;
  #program;
  #tex = new Array(FRAMES);
  #textures = new Array(FRAMES);
  #vao;
  #vertexBuffer;
  #gl;
  #canvas;
  frameIndex = 0;
  #randomVecs;
  constructor(gl, canvas) {
    this.#gl = gl;
    this.#canvas = canvas;
    this.#program = GLLib.compile(gl, GLLib.postVertex, taa_default);
    this.#vao = gl.createVertexArray();
    this.textureIn = gl.createTexture();
    gl.bindVertexArray(this.#vao);
    gl.useProgram(this.#program);
    for (let i = 0; i < FRAMES; i++) this.#textures[i] = gl.createTexture();
    for (let i = 0; i < FRAMES; i++) this.#tex[i] = gl.getUniformLocation(this.#program, "cache" + i);
    this.#vertexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, this.#vertexBuffer);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, this.#vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, Float32Array.from([0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0]), gl.DYNAMIC_DRAW);
    this.createTexture();
    this.#randomVecs = this.genPseudoRandomVecsWith0Sum(FRAMES);
  }
  createTexture = () => {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.textureIn);
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#canvas.width, this.#canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, null);
    GLLib.setTexParams(this.#gl);
    for (let i = 0; i < FRAMES; i++) {
      this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#textures[i]);
      this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#canvas.width, this.#canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, null);
      GLLib.setTexParams(this.#gl);
    }
  };
  renderFrame = () => {
    this.frameIndex = (this.frameIndex + 1) % FRAMES;
    this.#textures.unshift(this.textureIn);
    this.textureIn = this.#textures.pop();
    this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, null);
    for (let i = 0; i < FRAMES; i++) {
      this.#gl.activeTexture(this.#gl.TEXTURE0 + i);
      this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#textures[i]);
    }
    this.#gl.useProgram(this.#program);
    this.#gl.bindVertexArray(this.#vao);
    for (let i = 0; i < FRAMES; i++) this.#gl.uniform1i(this.#tex[i], i);
    this.#gl.drawArrays(this.#gl.TRIANGLES, 0, 6);
  };
  jitter = () => {
    let frameIndex = (this.frameIndex + 1) % FRAMES;
    let scale = 0.3 / Math.min(this.#canvas.width, this.#canvas.height);
    return { x: this.#randomVecs[frameIndex][0] * scale, y: this.#randomVecs[frameIndex][1] * scale };
  };
  // Generate n d-dimensional pseudo random vectors that all add up to 0.
  genPseudoRandomVecsWith0Sum = (n) => {
    let vecs = new Array(n).fill(0).map(() => new Array(2));
    vecs[0] = [0, 1];
    vecs[1] = [1, 0];
    let combined = [1, 1];
    for (let i = 2; i < n; i++) {
      for (let j = 0; j < 2; j++) {
        let min = Math.max(-Math.min(i + 1, n - 1 - i), combined[j] - 1);
        let max = Math.min(Math.min(i + 1, n - 1 - i), combined[j] + 1);
        vecs[i][j] = 0.5 * (max + min + (max - min) * Math.sign(Math.random() - 0.5) * (Math.random() * 0.5) ** (1 / 2)) - combined[j];
        combined[j] += vecs[i][j];
      }
    }
    return vecs;
  };
};

// src/flexlight/webgl2/shaders/pathtracer-vertex.glsl
var pathtracer_vertex_default = "#version 300 es\n#define TRIANGLES_PER_ROW_POWER 8\n#define TRIANGLES_PER_ROW 256\n#define INV_65535 0.000015259021896696422\n\nprecision highp int;\nprecision highp float;\nprecision highp sampler2D;\n\nin int triangleId;\nin int vertexId;\n\nlayout (std140) uniform transformMatrix\n{\n    mat3 rotation[MAX_TRANSFORMS];\n    vec3 shift[MAX_TRANSFORMS];\n};\n\nuniform vec3 cameraPosition;\nuniform mat3 viewMatrix;\n\n// Texture with vertex information about all triangles in scene\nuniform sampler2D geometryTex;\n\nout vec3 relativePosition;\nout vec3 absolutePosition;\nout vec2 uv;\nout vec3 clipSpace;\n\nflat out vec3 camera;\nflat out int initTriangleId;\nflat out int transformationId;\n\nconst vec2 baseUVs[3] = vec2[3](\n    vec2(1, 0), \n    vec2(0, 1), \n    vec2(0, 0)\n);\n\nvoid main() {\n    // Calculate vertex position in texture\n    int triangleColumn = triangleId >> TRIANGLES_PER_ROW_POWER;\n    ivec2 index = ivec2((triangleId - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);\n\n    vec4 t0 = texelFetch(geometryTex, index, 0);\n    vec4 t1 = texelFetch(geometryTex, index + ivec2(1, 0), 0);\n    vec4 t2 = texelFetch(geometryTex, index + ivec2(2, 0), 0);\n\n    transformationId = int(t2.y);\n    // Apply local geometry transform\n    int tI = transformationId << 1;\n    // Combine vertex position\n    switch (vertexId) {\n        case 0:\n            relativePosition = t0.xyz;\n            break;\n        case 1:\n            relativePosition = vec3(t0.w, t1.xy);\n            break;\n        case 2:\n            relativePosition = vec3(t1.zw, t2.x);\n            break;\n    }\n    // Transform position\n    absolutePosition = rotation[tI] * relativePosition + shift[tI];\n    clipSpace = viewMatrix * (absolutePosition - cameraPosition);\n    // Set triangle position in clip space\n    gl_Position = vec4(clipSpace.xy, - 1.0f / (1.0f + exp(clipSpace.z * INV_65535)), clipSpace.z);\n\n    uv = baseUVs[vertexId];\n    camera = cameraPosition;\n    initTriangleId = triangleId;\n}";

// src/flexlight/webgl2/shaders/pathtracer-fragment.glsl
var pathtracer_fragment_default = "#version 300 es\n#define TRIANGLES_PER_ROW_POWER 8\n#define TRIANGLES_PER_ROW 256\n#define PI 3.141592653589793\n#define PHI 1.61803398874989484820459\n#define SQRT3 1.7320508075688772\n#define POW32 4294967296.0\n#define BIAS 0.0000152587890625\n#define THIRD 0.3333333333333333\n#define INV_PI 0.3183098861837907\n#define INV_256 0.00390625\n#define INV_255 0.00392156862745098\n#define INV_65536 0.0000152587890625\n\nprecision highp int;\nprecision highp float;\nprecision highp sampler2D;\n\nstruct Ray {\n    vec3 origin;\n    vec3 unitDirection;\n};\n\nstruct Material {\n    vec3 albedo;\n    vec3 rme;\n    vec3 tpo;\n};\n\nstruct Hit {\n    vec3 suv;\n    int transformId;\n    int triangleId;\n};\n\nin vec3 relativePosition;\nin vec3 absolutePosition;\nin vec2 uv;\nin vec3 clipSpace;\n\nflat in vec3 camera;\nflat in int initTriangleId;\nflat in int transformationId;\n\nlayout (std140) uniform transformMatrix\n{\n    mat3 rotation[MAX_TRANSFORMS];\n    vec3 shift[MAX_TRANSFORMS];\n};\n\n// Quality configurators\nuniform int samples;\nuniform int maxReflections;\nuniform float minImportancy;\nuniform int hdr;\nuniform int isTemporal;\n\n// Get global illumination color, intensity\nuniform vec3 ambient;\n\nuniform float randomSeed;\n// Textures in parallel for texture atlas\nuniform vec2 textureDims;\n\n// Texture with information about all triangles in scene\nuniform sampler2D geometryTex;\nuniform sampler2D sceneTex;\nuniform sampler2D translucencyTex;\nuniform sampler2D pbrTex;\nuniform sampler2D tex;\n\n// Texture with all primary light sources of scene\nuniform sampler2D lightTex;\n\nlayout(location = 0) out vec4 renderColor;\nlayout(location = 1) out vec4 renderColorIp;\nlayout(location = 2) out vec4 renderId;\n\nconst Hit NO_HIT = Hit(vec3(0.0), 0, -1);\n\n// Prevent blur over shadow border or over (close to) perfect reflections\nfloat firstRayLength = 1.0f;\n// Accumulate color of mirror reflections\n// float glassFilter = 0.0f;\nfloat originalRMEx = 0.0f;\nfloat originalTPOx = 0.0f;\nvec3 originalColor;\n\nfloat to4BitRepresentation(float a, float b) {\n    uint aui = uint(a * 255.0f) & uint(240);\n    uint bui = (uint(b * 255.0f) & uint(240)) >> 4;\n    return float(aui | bui) * INV_255;\n}\n\nfloat normalToSphearical4BitRepresentation(vec3 n) {\n    float phi = (atan(n.z, n.x) * INV_PI) * 0.5f + 0.5f;\n    float theta = (atan(n.x, n.y) * INV_PI) * 0.5f + 0.5f;\n    return to4BitRepresentation(phi, theta);\n}\n\nvec3 combineNormalRME(vec3 n, vec3 rme) {\n    return vec3(normalToSphearical4BitRepresentation(n), rme.x, to4BitRepresentation(rme.y, rme.z));\n}\n\n// Lookup values for texture atlases\nvec3 fetchTexVal(sampler2D atlas, vec2 uv, float texNum, vec3 defaultVal) {\n    if (texNum == - 1.0) return defaultVal;\n\n    vec2 atlasSize = vec2(textureSize(atlas, 0));\n    vec2 offset = vec2(\n        mod((textureDims.x * texNum), atlasSize.x),\n        floor((textureDims.x * texNum) / atlasSize.x) * textureDims.y\n    );\n    vec2 atlasCoords = (offset + uv * textureDims) / atlasSize;\n    // Return texel on requested location\n    return texture(atlas, atlasCoords).xyz;\n}\n\nvec4 noise(vec2 n, float seed) {\n    return fract(sin(dot(n.xy, vec2(12.9898f, 78.233f)) + vec4(53.0f, 59.0f, 61.0f, 67.0f) * (seed + randomSeed * PHI)) * 43758.5453f) * 2.0f - 1.0f;\n    // fract(sin(dot(n.xy, vec2<f32>(12.9898f, 78.233f)) + vec4<f32>(53.0f, 59.0f, 61.0f, 67.0f) * sin(seed + uniforms.temporal_target * PHI)) * 43758.5453f) * 2.0f - 1.0f;\n}\n\nvec3 moellerTrumbore(mat3 t, Ray ray, float l) {\n    vec3 edge1 = t[1] - t[0];\n    vec3 edge2 = t[2] - t[0];\n    vec3 pvec = cross(ray.unitDirection, edge2);\n    float det = dot(edge1, pvec);\n    if(abs(det) < BIAS) return vec3(0.0f);\n    float inv_det = 1.0f / det;\n    vec3 tvec = ray.origin - t[0];\n    float u = dot(tvec, pvec) * inv_det;\n    if(u < BIAS || u > 1.0f) return vec3(0.0f);\n    vec3 qvec = cross(tvec, edge1);\n    float v = dot(ray.unitDirection, qvec) * inv_det;\n    float uvSum = u + v;\n    if(v < BIAS || uvSum > 1.0f) return vec3(0.0f);\n    float s = dot(edge2, qvec) * inv_det;\n    if(s > l || s <= BIAS) return vec3(0.0f);\n    return vec3(s, u, v);\n}\n\n// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles\nbool moellerTrumboreCull(mat3 t, Ray ray, float l) {\n    vec3 edge1 = t[1] - t[0];\n    vec3 edge2 = t[2] - t[0];\n    vec3 pvec = cross(ray.unitDirection, edge2);\n    float det = dot(edge1, pvec);\n    float invDet = 1.0f / det;\n    if(det < BIAS) return false;\n    vec3 tvec = ray.origin - t[0];\n    float u = dot(tvec, pvec) * invDet;\n    if(u < BIAS || u > 1.0f) return false;\n    vec3 qvec = cross(tvec, edge1);\n    float v = dot(ray.unitDirection, qvec) * invDet;\n    if(v < BIAS || u + v > 1.0f) return false;\n    float s = dot(edge2, qvec) * invDet;\n    return (s <= l && s > BIAS);\n}\n\n// Don't return intersection point, because we're looking for a specific triangle not bounding box\nbool rayCuboid(float l, Ray ray, vec3 minCorner, vec3 maxCorner) {\n    vec3 v0 = (minCorner - ray.origin) / ray.unitDirection;\n    vec3 v1 = (maxCorner - ray.origin) / ray.unitDirection;\n    float tmin = max(max(min(v0.x, v1.x), min(v0.y, v1.y)), min(v0.z, v1.z));\n    float tmax = min(min(max(v0.x, v1.x), max(v0.y, v1.y)), max(v0.z, v1.z));\n    return tmax >= max(tmin, BIAS) && tmin < l;\n}\n\n// Test for closest ray triangle intersection\n// return intersection position in world space and index of target triangle in geometryTex\n// plus triangle and transformation Id\nHit rayTracer(Ray ray) {\n    // Cache transformed ray attributes\n    Ray tR = Ray(ray.origin, ray.unitDirection);\n    int cachedTI = 0;\n    // Latest intersection which is now closest to origin\n    Hit hit = NO_HIT;\n    // Length to latest intersection\n    float minLen = POW32;\n    // Get texture size as max iteration value\n    ivec2 geometryTexSize = textureSize(geometryTex, 0).xy;\n    int size = geometryTexSize.y * TRIANGLES_PER_ROW;\n    // Iterate through lines of texture\n    for(int i = 0; i < size; i++) {\n        // Get position of current triangle/vertex in geometryTex\n        int triangleColumn = i >> TRIANGLES_PER_ROW_POWER;\n        ivec2 index = ivec2((i - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);\n        // Fetch triangle coordinates from scene graph\n        vec4 t0 = texelFetch(geometryTex, index, 0);\n        vec4 t1 = texelFetch(geometryTex, index + ivec2(1, 0), 0);\n        vec4 t2 = texelFetch(geometryTex, index + ivec2(2, 0), 0);\n\n        int tI = int(t2.y) << 1;\n        // Test if cached transformed variables are still valid\n        if (tI != cachedTI) {\n            int iI = tI + 1;\n            mat3 rotationII = rotation[iI];\n            cachedTI = tI;\n            tR = Ray(\n                rotationII * (ray.origin + shift[iI]),\n                rotationII * ray.unitDirection\n            );\n        }\n        // Three cases:\n        // t2.z = 0        => end of list: stop loop\n        // t2.z = 1        => is bounding volume: do AABB intersection test\n        // t2.z = 2        => is triangle: do triangle intersection test\n        if (t2.z == 0.0) return hit;\n\n        if (t2.z == 1.0) {\n            if (!rayCuboid(minLen, tR, t0.xyz, vec3(t0.w, t1.xy))) i += int(t1.z);\n        } else {\n            mat3 triangle = mat3 (t0, t1, t2.x);\n            // Test if triangle intersects ray\n            vec3 intersection = moellerTrumbore(triangle, tR, minLen);\n            // Test if ray even intersects\n            if(intersection.x != 0.0) {\n                // Calculate intersection point\n                hit = Hit(intersection, tI, i);\n                // Update maximum object distance for future rays\n                minLen = intersection.x;\n            }\n        }\n    }\n    // Return ray hit with all required information\n    return hit;\n}\n\n\n// Simplified rayTracer to only test if ray intersects anything\nbool shadowTest(Ray ray, float l) {\n    // Cache transformed ray attributes\n    Ray tR = Ray(ray.origin, ray.unitDirection);\n    int cachedTI = 0;\n    // Precompute max length\n    float minLen = l;\n    // Get texture size as max iteration value\n    int size = textureSize(geometryTex, 0).y * TRIANGLES_PER_ROW;\n    // Iterate through lines of texture\n    for(int i = 0; i < size; i++) {\n        // Get position of current triangle/vertex in geometryTex\n        int triangleColumn = i >> TRIANGLES_PER_ROW_POWER;\n        ivec2 index = ivec2((i - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);\n        // Fetch triangle coordinates from scene graph\n        vec4 t0 = texelFetch(geometryTex, index, 0);\n        vec4 t1 = texelFetch(geometryTex, index + ivec2(1, 0), 0);\n        vec4 t2 = texelFetch(geometryTex, index + ivec2(2, 0), 0);\n\n        int tI = int(t2.y) << 1;\n        // Test if cached transformed variables are still valid\n        if (tI != cachedTI) {\n            int iI = tI + 1;\n            mat3 rotationII = rotation[iI];\n            cachedTI = tI;\n            tR = Ray(\n                rotationII * (ray.origin + shift[iI]),\n                normalize(rotationII * ray.unitDirection)\n            );\n        }\n        // Three cases:\n        // t2.z = 0        => end of list: stop loop\n        // t2.z = 1        => is bounding volume: do AABB intersection test\n        // t2.z = 2        => is triangle: do triangle intersection test\n        if (t2.z == 0.0) return false;\n\n        if (t2.z == 1.0) {\n            if (!rayCuboid(minLen, tR, t0.xyz, vec3(t0.w, t1.xy))) i += int(t1.z);\n        } else {\n            mat3 triangle = mat3 (t0, t1, t2.x);\n            // Test for triangle intersection in positive light ray direction\n            if (moellerTrumboreCull(triangle, tR, minLen)) return true;\n        }\n    }\n    // Tested all triangles, but there is no intersection\n    return false;\n}\n\nfloat trowbridgeReitz(float alpha, float NdotH) {\n    float numerator = alpha * alpha;\n    float denom = NdotH * NdotH * (numerator - 1.0f) + 1.0f;\n    return numerator / max(PI * denom * denom, BIAS);\n}\n\nfloat schlickBeckmann(float alpha, float NdotX) {\n    float k = alpha * 0.5f;\n    float denominator = NdotX * (1.0f - k) + k;\n    denominator = max(denominator, BIAS);\n    return NdotX / denominator;\n}\n\nfloat smith(float alpha, float NdotV, float NdotL) {\n    return schlickBeckmann(alpha, NdotV) * schlickBeckmann(alpha, NdotL);\n}\n\nvec3 fresnel(vec3 F0, float theta) {\n    // Use Schlick approximation\n    return F0 + (1.0f - F0) * pow(1.0f - theta, 5.0f);\n}\n\nvec3 forwardTrace(Material material, vec3 lightDir, float strength, vec3 N, vec3 V) {\n    float lenP1 = 1.0f + length(lightDir);\n    // Apply inverse square law\n    float brightness = strength / (lenP1 * lenP1);\n\n    vec3 L = normalize(lightDir);\n    vec3 H = normalize(V + L);\n\n    float VdotH = max(dot(V, H), 0.0f);\n    float NdotL = max(dot(N, L), 0.0f);\n    float NdotH = max(dot(N, H), 0.0f);\n    float NdotV = max(dot(N, V), 0.0f);\n\n    float alpha = material.rme.x * material.rme.x;\n    float BRDF = mix(1.0f, NdotV, material.rme.y);\n    vec3 F0 = material.albedo * BRDF;\n\n    vec3 Ks = fresnel(F0, VdotH);\n    vec3 Kd = (1.0f - Ks) * (1.0f - material.rme.y);\n    vec3 lambert = material.albedo * INV_PI;\n\n    vec3 cookTorranceNumerator = Ks * trowbridgeReitz(alpha, NdotH) * smith(alpha, NdotV, NdotL);\n    float cookTorranceDenominator = 4.0f * NdotV * NdotL;\n    cookTorranceDenominator = max(cookTorranceDenominator, BIAS);\n\n    vec3 cookTorrance = cookTorranceNumerator / cookTorranceDenominator;\n    vec3 radiance = Kd * lambert + cookTorrance;\n\n    // Outgoing light to camera\n    return radiance * NdotL * brightness;\n}\n\n/*\nvec3 referenceSample (sampler2D lightTex, vec4 randomVec, vec3 N, vec3 target, vec3 V, Material material, bool dontFilter, int triangleId, int i) {\n    vec3 localColor = vec3(0);\n    int lights = textureSize(lightTex, 0).y;\n\n    for (int j = 0; j < lights; j++) {\n        // Read light position\n        vec3 light = texelFetch(lightTex, ivec2(0, j), 0).xyz;\n        // Read light strength from texture\n        vec2 strengthVariation = texelFetch(lightTex, ivec2(1, j), 0).xy;\n        // Skip if strength is negative or zero\n        // if (strengthVariation.x <= 0.0) continue;\n        // Alter light source position according to variation.\n        light = randomVec.xyz * strengthVariation.y + light;\n        vec3 lightDir = light - target;\n        vec3 lightColor = forwardTrace(lightDir, N, V, material, strengthVariation.x);\n        // Compute quick exit criterion to potentially skip expensive shadow test\n        bool quickExitCriterion = dot(lightDir, N) <= BIAS;\n        Ray lightRay = Ray(light, target, lightDir, normalize(lightDir));\n        // Test if in shadow\n        if (quickExitCriterion || shadowTest(lightRay, triangleId)) {\n            if (dontFilter || i == 0) renderId.w = float(((j % 128) << 1) + 1) * INV_255;\n        } else {\n            if (dontFilter || i == 0) renderId.w = float((j % 128) << 1) * INV_255;\n            // localColor *= (totalWeight / reservoirLength) / reservoirWeight;\n            localColor += lightColor;\n        }\n    }\n\n    return localColor + material.rme.z + ambient * material.rme.y;\n}\n\n\nvec3 randomSample (vec4 randomVec, vec3 N, vec3 smoothNormal, vec3 target,  vec3 V, Material material, bool dontFilter, int triangleId, int i) {\n    int lights = textureSize(lightTex, 0).y;\n\n    int randIndex = int(floor(abs(randomVec.y) * float(lights)));\n\n    \n    // Read light position\n    vec3 light = texelFetch(lightTex, ivec2(0, randIndex), 0).xyz;\n    // Read light strength from texture\n    vec2 strengthVariation = texelFetch(lightTex, ivec2(1, randIndex), 0).xy;\n    // Skip if strength is negative or zero\n    // if (strengthVariation.x <= 0.0) continue;\n    // Alter light source position according to variation.\n    light = randomVec.xyz * strengthVariation.y + light;\n    vec3 lightDir = light - target;\n    vec3 lightColor = forwardTrace(material, lightDir, strengthVariation.x, N, V);\n    // Compute quick exit criterion to potentially skip expensive shadow test\n    bool quickExitCriterion = dot(lightDir, N) <= BIAS;\n    // Ray lightRay = Ray(light, target, lightDir, normalize(lightDir));\n    Ray lightRay = Ray(target, light, lightDir, normalize(lightDir));\n    // Test if in shadow\n    if (quickExitCriterion || shadowTest(lightRay, triangleId)) {\n        if (dontFilter || i == 0) renderId.w = float(((randIndex % 128) << 1) + 1) * INV_255;\n        return vec3(material.rme.z);\n    } else {\n        if (dontFilter || i == 0) renderId.w = float((randIndex % 128) << 1) * INV_255;\n        return lightColor * float(lights) + material.rme.z;\n    }\n}\n*/\n\nvec3 reservoirSample (Material material, Ray ray, vec4 randomVec, vec3 N, vec3 smoothNormal, float geometryOffset, bool dontFilter, int i) {\n    vec3 localColor = vec3(0);\n    float reservoirLength = 0.0f;\n    float totalWeight = 0.0f;\n    int reservoirNum = 0;\n    float reservoirWeight = 0.0f;\n    vec3 reservoirLight;\n    vec3 reservoirLightDir;\n    vec2 lastRandom = noise(randomVec.zw, BIAS).xy;\n\n    int size = textureSize(lightTex, 0).y;\n    for (int j = 0; j < size; j++) {\n      // Read light strength from texture\n      vec2 strengthVariation = texelFetch(lightTex, ivec2(1, j), 0).xy;\n      // Skip if strength is negative or zero\n      if (strengthVariation.x <= 0.0) continue;\n      // Increment light weight\n      reservoirLength ++;\n      // Alter light source position according to variation.\n      vec3 light = texelFetch(lightTex, ivec2(0, j), 0).xyz + randomVec.xyz * strengthVariation.y;\n      vec3 dir = light - ray.origin;\n    \n      vec3 colorForLight = forwardTrace(material, dir, strengthVariation.x, N, - ray.unitDirection);\n      localColor += colorForLight;\n      float weight = length(colorForLight);\n      totalWeight += weight;\n      if (abs(lastRandom.y) * totalWeight <= weight) {\n        reservoirNum = j;\n        reservoirWeight = weight;\n        reservoirLight = light;\n        reservoirLightDir = dir;\n      }\n      // Update pseudo random variable.\n      lastRandom = noise(lastRandom, BIAS).zw;\n    }\n\n    vec3 unitLightDir = normalize(reservoirLightDir);\n    // Compute quick exit criterion to potentially skip expensive shadow test\n    bool showColor = reservoirLength == 0.0 || reservoirWeight == 0.0;\n    bool showShadow = dot(smoothNormal, unitLightDir) <= BIAS;\n    // Apply emissive texture and ambient light\n    vec3 baseLuminance = vec3(material.rme.z) * material.albedo;\n    // Update filter\n    if (dontFilter || i == 0) renderId.w = float((reservoirNum % 128) << 1) * INV_255;\n    // Test if in shadow\n    if (showColor) return localColor + baseLuminance;\n\n    if (showShadow) {\n        if (dontFilter || i == 0) renderId.w += INV_255;\n        return baseLuminance;\n    }\n    // Apply geometry offset\n    vec3 offsetTarget = ray.origin + geometryOffset * smoothNormal;\n    Ray lightRay = Ray(offsetTarget, unitLightDir);\n\n    if (shadowTest(lightRay, length(reservoirLightDir))) {\n        if (dontFilter || i == 0) renderId.w += INV_255;\n        return baseLuminance;\n    } else {\n        return localColor + baseLuminance;\n    }\n}\n\n\nvec3 lightTrace(Hit hit, vec3 target, vec3 camera, float cosSampleN, int bounces) {\n    // Set bool to false when filter becomes necessary\n    bool dontFilter = true;\n    // Use additive color mixing technique, so start with black\n    vec3 finalColor = vec3(0);\n    vec3 importancyFactor = vec3(1);\n    vec3 filterFactor = vec3(1);\n    originalColor = vec3(1);\n\n    Ray ray = Ray(camera, normalize(target - camera));\n    vec3 lastHitPoint = camera;\n    // Iterate over each bounce and modify color accordingly\n    for (int i = 0; i < bounces && length(filterFactor) >= minImportancy * SQRT3; i++) {\n        float fi = float(i);\n        mat3 rTI = rotation[hit.transformId];\n        vec3 sTI = shift[hit.transformId];\n        // Transform hit point\n        ray.origin = hit.suv.x * ray.unitDirection + ray.origin;\n        // Calculate barycentric coordinates\n        vec3 uvw = vec3(1.0 - hit.suv.y - hit.suv.z, hit.suv.y, hit.suv.z);\n\n        // Get position of current triangle/vertex in sceneTex\n        int triangleColumn = hit.triangleId >> TRIANGLES_PER_ROW_POWER;\n        // Fetch triangle coordinates from scene graph texture\n        ivec2 indexGeometry = ivec2((hit.triangleId - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);\n        vec4 g0 = texelFetch(geometryTex, indexGeometry, 0);\n        vec4 g1 = texelFetch(geometryTex, indexGeometry + ivec2(1, 0), 0);\n        vec4 g2 = texelFetch(geometryTex, indexGeometry + ivec2(2, 0), 0);\n\n        mat3 triangle = rTI * mat3(g0, g1, g2.x);\n        vec3 offsetRayTarget = ray.origin - sTI;\n\n        vec3 geometryNormal = normalize(cross(triangle[0] - triangle[1], triangle[0] - triangle[2]));\n        vec3 diffs = vec3(\n            distance(offsetRayTarget, triangle[0]),\n            distance(offsetRayTarget, triangle[1]),\n            distance(offsetRayTarget, triangle[2])\n        );\n        // Fetch scene texture data\n        ivec2 indexScene = ivec2((hit.triangleId - triangleColumn * TRIANGLES_PER_ROW) * 7, triangleColumn);\n        // Fetch texture data\n        vec4 t0 = texelFetch(sceneTex, indexScene, 0);\n        vec4 t1 = texelFetch(sceneTex, indexScene + ivec2(1, 0), 0);\n        vec4 t2 = texelFetch(sceneTex, indexScene + ivec2(2, 0), 0);\n        vec4 t3 = texelFetch(sceneTex, indexScene + ivec2(3, 0), 0);\n        vec4 t4 = texelFetch(sceneTex, indexScene + ivec2(4, 0), 0);\n        vec4 t5 = texelFetch(sceneTex, indexScene + ivec2(5, 0), 0);\n        vec4 t6 = texelFetch(sceneTex, indexScene + ivec2(6, 0), 0);\n        // Pull normals\n        mat3 normals = rTI * mat3(t0, t1, t2.x);\n        // Interpolate smooth normal\n        vec3 smoothNormal = normalize(normals * uvw);\n        // to prevent unnatural hard shadow / reflection borders due to the difference between the smooth normal and geometry\n        vec3 angles = acos(abs(geometryNormal * normals));\n        vec3 angleTan = clamp(tan(angles), 0.0, 1.0);\n        float geometryOffset = dot(diffs * angleTan, uvw);\n        // Interpolate final barycentric texture coordinates between UV's of the respective vertices\n        vec2 barycentric = mat3x2(t2.yzw, t3.xyz) * uvw;\n        // Gather material attributes (albedo, roughness, metallicity, emissiveness, translucency, partical density and optical density aka. IOR) out of world texture\n        Material material = Material(\n            fetchTexVal(tex, barycentric, t3.w, vec3(t4.zw, t5.x)),\n            fetchTexVal(pbrTex, barycentric, t4.x, t5.yzw),\n            fetchTexVal(translucencyTex, barycentric, t4.y, t6.xyz)\n        );\n        \n        ray = Ray(ray.origin, normalize(ray.origin - lastHitPoint));\n        // If ray reflects from inside or onto an transparent object,\n        // the surface faces in the opposite direction as usual\n        float signDir = sign(dot(ray.unitDirection, smoothNormal));\n        smoothNormal *= - signDir;\n\n        // Generate pseudo random vector\n        vec4 randomVec = noise(clipSpace.xy * length(ray.origin - lastHitPoint), fi + cosSampleN * PHI);\n        vec3 randomSpheareVec = normalize(smoothNormal + normalize(randomVec.xyz));\n        float BRDF = mix(1.0f, abs(dot(smoothNormal, ray.unitDirection)), material.rme.y);\n\n        // Alter normal according to roughness value\n        float roughnessBRDF = material.rme.x * BRDF;\n        vec3 roughNormal = normalize(mix(smoothNormal, randomSpheareVec, roughnessBRDF));\n\n        vec3 H = normalize(roughNormal - ray.unitDirection);\n        float VdotH = max(dot(- ray.unitDirection, H), 0.0f);\n        vec3 F0 = material.albedo * BRDF;\n        vec3 f = fresnel(F0, VdotH);\n\n        float fresnelReflect = max(f.x, max(f.y, f.z));\n        // object is solid or translucent by chance because of the fresnel effect\n        bool isSolid = material.tpo.x * fresnelReflect <= abs(randomVec.w);\n\n        // Determine local color considering PBR attributes and lighting\n        vec3 localColor = reservoirSample(material, ray, randomVec, - signDir * roughNormal, - signDir * smoothNormal, geometryOffset, dontFilter, i);\n        // Calculate primary light sources for this pass if ray hits non translucent object\n        finalColor += localColor * importancyFactor;\n        // Multiply albedo with either absorption value or filter colo\n        if (dontFilter) {\n            originalColor *= (material.albedo + INV_255);\n            finalColor /= (material.albedo + INV_255);\n            \n            // importancyFactor /= material.albedo;\n            // importancyFactor *= material.albedo;\n            // Update last used tpo.x value\n            originalTPOx = material.tpo.x;\n            // Add filtering intensity for respective surface\n            originalRMEx += material.rme.x;\n            // Update render id\n            vec4 renderIdUpdate = pow(2.0f, - fi) * vec4(combineNormalRME(smoothNormal, material.rme), 0.0f);\n\n            renderId += renderIdUpdate;\n            // if (i == 0) renderOriginalId += renderIdUpdate;\n            // Test if filter is already necessary\n            dontFilter = (material.rme.x < 0.01f && isSolid) || !isSolid;\n\n            if(isSolid && material.tpo.x > 0.01f) {\n                // glassFilter += 1.0f;\n                dontFilter = false;\n            }\n            \n        } else {\n            importancyFactor *= material.albedo;\n        }\n\n        filterFactor *= material.albedo;\n        // Update length of first fector to control blur intensity\n        if (i == 1) firstRayLength = min(length(ray.origin - lastHitPoint) / length(lastHitPoint - camera), firstRayLength);\n\n        // Handle translucency and skip rest of light calculation\n        if(isSolid) {\n            // Calculate reflecting ray\n            ray.unitDirection = normalize(mix(reflect(ray.unitDirection, smoothNormal), randomSpheareVec, roughnessBRDF));\n        } else {\n            float eta = mix(1.0f / material.tpo.z, material.tpo.z, max(signDir, 0.0f));\n            // Refract ray depending on IOR (material.tpo.z)\n            ray.unitDirection = normalize(mix(refract(ray.unitDirection, smoothNormal, eta),randomSpheareVec, roughnessBRDF));\n        }\n        // Calculate next intersection\n        hit = rayTracer(ray);\n        // Stop loop if there is no intersection and ray goes in the void\n        if (hit.triangleId == - 1) break;\n        // Update other parameters\n        lastHitPoint = ray.origin;\n    }\n    // Return final pixel color\n    return finalColor + importancyFactor * ambient;\n}\n\nvoid main() {\n    // Transform normal according to object transform\n    int tI = transformationId << 1;\n    vec3 uvw = vec3(uv, 1.0f - uv.x - uv.y);\n    // Generate hit struct for pathtracer\n    Hit hit = Hit(vec3(distance(absolutePosition, camera), uvw.yz), tI, initTriangleId);\n    // vec3 finalColor = material.rme;\n    vec3 finalColor = vec3(0);\n    // Generate multiple samples\n    for(int i = 0; i < samples; i++) {\n        // Use cosine as noise in random coordinate picker\n        float cosSampleN = cos(float(i));\n        finalColor += lightTrace(hit, absolutePosition, camera, cosSampleN, maxReflections);\n    }\n    // Average ray colors over samples.\n    float invSamples = 1.0f / float(samples);\n    finalColor *= invSamples;\n\n    /*if(useFilter == 1) {\n        // Render all relevant information to 4 textures for the post processing shader\n        renderColor = vec4(fract(finalColor), 1.0f);\n        // 16 bit HDR for improved filtering\n        renderColorIp = vec4(floor(finalColor) * INV_255, glassFilter);\n    } else {\n    */\n    finalColor *= originalColor;\n\n    if (isTemporal == 0 && hdr == 1) {\n        // Apply Reinhard tone mapping\n        finalColor = finalColor / (finalColor + vec3(1.0f));\n        // Gamma correction\n        // float gamma = 0.8f;\n        // finalColor = pow(4.0f * finalColor, vec3(1.0f / gamma)) / 4.0f * 1.3f;\n    }\n\n\n    if (isTemporal == 1) {\n        renderColor = vec4(fract(finalColor), 1.0f);\n        // 16 bit HDR for improved filtering\n        renderColorIp = vec4(floor(finalColor) * INV_255, 1.0f);\n    } else {\n        renderColor = vec4(finalColor, 1.0f);\n    }\n    //}\n    /*\n    \n    */\n    // render normal (last in transparency)\n    renderId += vec4(0.0f, 0.0f, 0.0f, INV_255);\n    // render modulus of absolute position (last in transparency)\xB4\n    // renderColor = vec4(smoothNormal, 1.0);\n    // renderColorIp = vec4(0.0);\n}";

// src/flexlight/webgl2/pathtracer.js
var PathtracingUniformLocationIdentifiers = [
  "cameraPosition",
  "viewMatrix",
  "samples",
  "maxReflections",
  "minImportancy",
  "hdr",
  "isTemporal",
  "ambient",
  "randomSeed",
  "textureDims",
  "geometryTex",
  "sceneTex",
  "pbrTex",
  "translucencyTex",
  "tex",
  "lightTex"
];
var PathtracingUniformFunctionTypes = [
  "uniform3f",
  "uniformMatrix3fv",
  "uniform1i",
  "uniform1i",
  "uniform1f",
  "uniform1i",
  "uniform1i",
  "uniform3f",
  "uniform1f",
  "uniform2f",
  "uniform1i",
  "uniform1i",
  "uniform1i",
  "uniform1i",
  "uniform1i",
  "uniform1i"
];
var PathTracerWGL2 = class {
  type = "pathtracer";
  // Configurable runtime properties of the pathtracer (public attributes)
  config;
  // Performance metric
  fps = 0;
  fpsLimit = Infinity;
  // Internal state of antialiasing
  #antialiasing;
  #AAObject;
  // Make gl object inaccessible from outside the class
  #gl;
  #canvas;
  #geometryTexture;
  #sceneTexture;
  // Buffer arrays
  #triangleIdBufferArray;
  #bufferLength;
  // Internal gl texture variables of texture atlases
  #textureAtlas;
  #pbrAtlas;
  #translucencyAtlas;
  #textureList = [];
  #pbrList = [];
  #translucencyList = [];
  #lightTexture;
  // Shader source will be generated later
  #tempGlsl;
  #engineState = {};
  #resizeEvent;
  /*readonly*/
  #isRunning = false;
  // Create new PathTracer from canvas and setup movement
  constructor(canvas, scene, camera, config) {
    this.#canvas = canvas;
    this.camera = camera;
    this.scene = scene;
    this.config = config;
    this.#gl = canvas.getContext("webgl2");
  }
  halt = () => {
    let oldIsRunning = this.#isRunning;
    try {
      this.#gl.loseContext();
    } catch (e) {
      console.warn("Unable to lose previous context, reload page in case of performance issue");
    }
    this.#isRunning = false;
    window.removeEventListener("resize", this.#resizeEvent);
    return oldIsRunning;
  };
  // Make canvas read only accessible
  get canvas() {
    return this.#canvas;
  }
  // Functions to update texture atlases to add more textures during runtime
  async #updateAtlas(list) {
    if (list.length === 0) {
      this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, 1, 1, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, new Uint8Array(4));
      return;
    }
    const [width, height] = this.scene.standardTextureSizes;
    const textureWidth = Math.floor(2048 / width);
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    canvas.width = Math.min(width * list.length, 2048);
    canvas.height = height * (Math.floor(width * list.length / 2048) + 1);
    ctx.imageSmoothingEnabled = false;
    list.forEach(async (texture, i) => ctx.drawImage(texture, width * (i % textureWidth), height * Math.floor(i / textureWidth), width, height));
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, canvas);
  }
  async #updateTextureAtlas() {
    if (this.scene.textures.length === this.#textureList.length && this.scene.textures.every((e, i) => e === this.#textureList[i])) return;
    this.#textureList = this.scene.textures;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#textureAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    GLLib.setTexParams(this.#gl);
    this.#updateAtlas(this.scene.textures);
  }
  async #updatePbrAtlas() {
    if (this.scene.pbrTextures.length === this.#pbrList.length && this.scene.pbrTextures.every((e, i) => e === this.#pbrList[i])) return;
    this.#pbrList = this.scene.pbrTextures;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#pbrAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    GLLib.setTexParams(this.#gl);
    this.#updateAtlas(this.scene.pbrTextures);
  }
  async #updateTranslucencyAtlas() {
    if (this.scene.translucencyTextures.length === this.#translucencyList.length && this.scene.translucencyTextures.every((e, i) => e === this.#translucencyList[i])) return;
    this.#translucencyList = this.scene.translucencyTextures;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#translucencyAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    GLLib.setTexParams(this.#gl);
    this.#updateAtlas(this.scene.translucencyTextures);
  }
  // Functions to update vertex and light source data textures
  async updatePrimaryLightSources() {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#lightTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    GLLib.setTexParams(this.#gl);
    if (this.scene.primaryLightSources.length === 0) {
      this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 2, 1, 0, this.#gl.RGB, this.#gl.FLOAT, Float32Array.from([0, 0, 0, 0, 0, 0]));
      return;
    }
    var lightTexArray = [];
    for (let lightSource of this.scene.primaryLightSources) {
      if (!lightSource) continue;
      const intensity = lightSource["intensity"] ?? this.scene.defaultLightIntensity;
      const variation = lightSource["variation"] ?? this.scene.defaultLightVariation;
      lightTexArray.push(lightSource[0], lightSource[1], lightSource[2], intensity, variation, 0);
    }
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 2, this.scene.primaryLightSources.length, 0, this.#gl.RGB, this.#gl.FLOAT, Float32Array.from(lightTexArray));
  }
  async updateScene() {
    let builtScene = await this.scene.generateArraysFromGraph();
    this.#bufferLength = builtScene.bufferLength;
    this.#triangleIdBufferArray = builtScene.idBuffer;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#geometryTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    GLLib.setTexParams(this.#gl);
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA32F, 3 * 256, builtScene.geometryBufferHeight, 0, this.#gl.RGBA, this.#gl.FLOAT, builtScene.geometryBuffer);
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#sceneTexture);
    GLLib.setTexParams(this.#gl);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA32F, 7 * 256, builtScene.sceneBufferHeight, 0, this.#gl.RGBA, this.#gl.FLOAT, builtScene.sceneBuffer);
  }
  async render() {
    this.#isRunning = true;
    let Program;
    let TempProgram, TempHdrLocation;
    let triangleIdBuffer, vertexIdBuffer;
    let UboBuffer, UboVariableIndices, UboVariableOffsets;
    let Framebuffer, TempFramebuffer;
    let HdrLocation;
    let RenderTexture = this.#gl.createTexture();
    let IpRenderTexture = this.#gl.createTexture();
    let DepthTexture = this.#gl.createTexture();
    let IdRenderTexture = this.#gl.createTexture();
    let TempTexture;
    let TempIpTexture;
    let TempIdTexture;
    let TempTex;
    let TempIpTex;
    let TempIdTex;
    let Vao = this.#gl.createVertexArray();
    let TempVao = this.#gl.createVertexArray();
    let frameCycle = () => {
      if (!this.#isRunning) return;
      let timeStamp = performance.now();
      this.#updateTextureAtlas();
      this.#updatePbrAtlas();
      this.#updateTranslucencyAtlas();
      this.updatePrimaryLightSources();
      if (this.#engineState.temporal !== this.config.temporal || this.#engineState.temporalSamples !== this.config.temporalSamples || this.#engineState.renderQuality !== this.config.renderQuality) {
        console.log("FORCED PREPARE ENGINE BY CONFIG CHANGE");
        requestAnimationFrame(() => prepareEngine());
        return;
      }
      if (this.#engineState.antialiasing !== this.config.antialiasing) {
        this.#engineState.antialiasing = this.config.antialiasing;
        let val = this.config.antialiasing.toLowerCase();
        switch (val) {
          case "fxaa":
            this.#antialiasing = val;
            this.#AAObject = new FXAA(this.#gl, this.#canvas);
            break;
          case "taa":
            this.#antialiasing = val;
            this.#AAObject = new TAA(this.#gl, this.#canvas);
            break;
          default:
            this.#antialiasing = void 0;
            this.#AAObject = void 0;
        }
      }
      renderFrame(this.#engineState);
      this.#engineState.intermediateFrames++;
      this.#engineState.temporalFrame = (this.#engineState.temporalFrame + 1) % 2048;
      let timeDifference = timeStamp - this.#engineState.lastTimeStamp;
      if (timeDifference > 500) {
        this.fps = (1e3 * this.#engineState.intermediateFrames / timeDifference).toFixed(0);
        this.#engineState.lastTimeStamp = timeStamp;
        this.#engineState.intermediateFrames = 0;
      }
      setTimeout(function() {
        requestAnimationFrame(() => frameCycle());
      }, 1e3 / this.fpsLimit);
    };
    let pathtracingPass = () => {
      let jitter = { x: 0, y: 0 };
      if (this.#AAObject && this.#antialiasing === "taa") jitter = this.#AAObject.jitter();
      let dir = { x: this.camera.direction.x + jitter.x, y: this.camera.direction.y + jitter.y };
      let invFov = 1 / this.camera.fov;
      let heightInvWidthFov = this.#canvas.height * invFov / this.#canvas.width;
      let viewMatrix = [
        Math.cos(dir.x) * heightInvWidthFov,
        0,
        Math.sin(dir.x) * heightInvWidthFov,
        -Math.sin(dir.x) * Math.sin(dir.y) * invFov,
        Math.cos(dir.y) * invFov,
        Math.cos(dir.x) * Math.sin(dir.y) * invFov,
        -Math.sin(dir.x) * Math.cos(dir.y),
        -Math.sin(dir.y),
        Math.cos(dir.x) * Math.cos(dir.y)
      ];
      this.#gl.bindVertexArray(Vao);
      this.#gl.useProgram(Program);
      [this.#geometryTexture, this.#sceneTexture, this.#pbrAtlas, this.#translucencyAtlas, this.#textureAtlas, this.#lightTexture].forEach((texture, i) => {
        this.#gl.activeTexture(this.#gl.TEXTURE0 + i);
        this.#gl.bindTexture(this.#gl.TEXTURE_2D, texture);
      });
      let uniformValues = [
        // 3d position of camera
        [this.camera.position.x, this.camera.position.y, this.camera.position.z],
        // View rotation and TAA jitter
        [true, viewMatrix],
        // amount of samples per ray
        [this.config.samplesPerRay],
        // max reflections of ray
        [this.config.maxReflections],
        // min importancy of light ray
        [this.config.minImportancy],
        // render for filter or not
        [this.config.hdr],
        // render for temporal or not
        [this.config.temporal],
        // ambient background color
        this.scene.ambientLight,
        // random seed for monte carlo pathtracing
        [this.config.temporal ? this.#engineState.temporalFrame : 0],
        // width of textures
        this.scene.standardTextureSizes,
        // whole triangle based geometry scene graph, triangle attributes for scene graph
        [0],
        [1],
        // pbr texture, translucency texture, texture
        [2],
        [3],
        [4],
        // data texture of all primary light sources
        [5]
      ];
      PathtracingUniformFunctionTypes.forEach((functionType, i) => this.#gl[functionType](this.#engineState.pathtracingUniformLocations[i], ...uniformValues[i]));
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, UboBuffer);
      let transformArrays = Transform.buildWGL2Arrays();
      this.#gl.bufferSubData(this.#gl.UNIFORM_BUFFER, UboVariableOffsets[0], transformArrays.rotationBuffer, 0);
      this.#gl.bufferSubData(this.#gl.UNIFORM_BUFFER, UboVariableOffsets[1], transformArrays.shiftBuffer, 0);
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, null);
      this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, triangleIdBuffer);
      this.#gl.bufferData(this.#gl.ARRAY_BUFFER, this.#triangleIdBufferArray, this.#gl.DYNAMIC_DRAW);
      this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, vertexIdBuffer);
      this.#gl.bufferData(this.#gl.ARRAY_BUFFER, new Int32Array([0, 1, 2]), this.#gl.STATIC_DRAW);
      this.#gl.drawArraysInstanced(this.#gl.TRIANGLES, 0, 3, this.#bufferLength);
    };
    let renderFrame = () => {
      if (this.config.temporal || this.#antialiasing) {
        this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, Framebuffer);
        this.#gl.drawBuffers([
          this.#gl.COLOR_ATTACHMENT0,
          this.#gl.COLOR_ATTACHMENT1,
          this.#gl.COLOR_ATTACHMENT2
        ]);
        if (this.config.temporal) {
          TempTexture.unshift(TempTexture.pop());
          TempIpTexture.unshift(TempIpTexture.pop());
          TempIdTexture.unshift(TempIdTexture.pop());
          this.#gl.framebufferTexture2D(this.#gl.FRAMEBUFFER, this.#gl.COLOR_ATTACHMENT0, this.#gl.TEXTURE_2D, TempTexture[0], 0);
          this.#gl.framebufferTexture2D(this.#gl.FRAMEBUFFER, this.#gl.COLOR_ATTACHMENT1, this.#gl.TEXTURE_2D, TempIpTexture[0], 0);
          this.#gl.framebufferTexture2D(this.#gl.FRAMEBUFFER, this.#gl.COLOR_ATTACHMENT2, this.#gl.TEXTURE_2D, TempIdTexture[0], 0);
        } else if (this.#antialiasing) {
          this.#gl.framebufferTexture2D(this.#gl.FRAMEBUFFER, this.#gl.COLOR_ATTACHMENT0, this.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
        }
        this.#gl.framebufferTexture2D(this.#gl.FRAMEBUFFER, this.#gl.DEPTH_ATTACHMENT, this.#gl.TEXTURE_2D, DepthTexture, 0);
      }
      this.#gl.clear(this.#gl.COLOR_BUFFER_BIT | this.#gl.DEPTH_BUFFER_BIT);
      pathtracingPass();
      if (this.config.temporal) {
        if (this.#antialiasing) {
          this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, TempFramebuffer);
          this.#gl.drawBuffers([
            this.#gl.COLOR_ATTACHMENT0
          ]);
          this.#gl.framebufferTexture2D(this.#gl.FRAMEBUFFER, this.#gl.COLOR_ATTACHMENT0, this.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
        } else {
          this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, null);
        }
        [...TempTexture, ...TempIpTexture, ...TempIdTexture].forEach((item, i) => {
          this.#gl.activeTexture(this.#gl.TEXTURE0 + i);
          this.#gl.bindTexture(this.#gl.TEXTURE_2D, item);
        });
        this.#gl.bindVertexArray(TempVao);
        this.#gl.useProgram(TempProgram);
        this.#gl.uniform1i(TempHdrLocation, this.config.hdr);
        for (let i = 0; i < this.config.temporalSamples; i++) {
          this.#gl.uniform1i(TempTex[i], i);
          this.#gl.uniform1i(TempIpTex[i], this.config.temporalSamples + i);
          this.#gl.uniform1i(TempIdTex[i], 2 * this.config.temporalSamples + i);
        }
        this.#gl.drawArrays(this.#gl.TRIANGLES, 0, 6);
      }
      if (this.#antialiasing) this.#AAObject.renderFrame();
    };
    let prepareEngine = () => {
      console.log("PREPARE ENGINE");
      this.halt();
      this.#isRunning = true;
      Object.assign(this.#engineState, {
        // Attributes to meassure frames per second
        intermediateFrames: 0,
        lastTimeStamp: performance.now(),
        // Parameters to compare against current state of the engine and recompile shaders on change
        temporal: this.config.temporal,
        temporalFrame: 0,
        temporalSamples: this.config.temporalSamples,
        renderQuality: this.config.renderQuality,
        // New buffer length
        bufferLength: 0
      });
      let newLine = `
      `;
      this.#tempGlsl = `#version 300 es
      precision highp float;
      in vec2 clipSpace;
      uniform int hdr;
      `;
      for (let i = 0; i < this.config.temporalSamples; i++) {
        this.#tempGlsl += "uniform sampler2D cache" + i + ";" + newLine;
        this.#tempGlsl += "uniform sampler2D cacheIp" + i + ";" + newLine;
        this.#tempGlsl += "uniform sampler2D cacheId" + i + ";" + newLine;
      }
      this.#tempGlsl += `
      layout(location = 0) out vec4 renderColor;
      `;
      this.#tempGlsl += `void main () {
        ivec2 texel = ivec2(vec2(textureSize(cache0, 0)) * clipSpace);
        vec4 id = texelFetch(cacheId0, texel, 0);
        float counter = 1.0;

        vec3 color = texelFetch(cache0, texel, 0).xyz + texelFetch(cacheIp0, texel, 0).xyz * 256.0;
      `;
      for (let i = 1; i < this.config.temporalSamples; i += 4) {
        this.#tempGlsl += "mat4 c" + i + " = mat4(";
        for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < this.config.temporalSamples ? "texelFetch(cache" + j + ", texel, 0)," : "vec4(0),") + newLine;
        this.#tempGlsl += (i + 3 < this.config.temporalSamples ? "texelFetch(cache" + (i + 3) + ", texel, 0) " + newLine + " ); " : "vec4(0) " + newLine + "); ") + newLine;
        this.#tempGlsl += "mat4 ip" + i + " = mat4(";
        for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < this.config.temporalSamples ? "texelFetch(cacheIp" + j + ", texel, 0)," : "vec4(0),") + newLine;
        this.#tempGlsl += (i + 3 < this.config.temporalSamples ? "texelFetch(cacheIp" + (i + 3) + ", texel, 0) " + newLine + "); " : "vec4(0) " + newLine + "); ") + newLine;
        this.#tempGlsl += "mat4 id" + i + " = mat4(";
        for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < this.config.temporalSamples ? "texelFetch(cacheId" + j + ", texel, 0)," : "vec4(0),") + newLine;
        this.#tempGlsl += (i + 3 < this.config.temporalSamples ? "texelFetch(cacheId" + (i + 3) + ", texel, 0) " + newLine + "); " : "vec4(0) " + newLine + "); ") + newLine;
        this.#tempGlsl += `
        for (int i = 0; i < 4; i++) if (id` + i + `[i].xyzw == id.xyzw) {
          color += c` + i + `[i].xyz + ip` + i + `[i].xyz * 256.0;
          counter ++;
        }
        `;
      }
      this.#tempGlsl += `
        color /= counter;
      
        if (hdr == 1) {
          // Apply Reinhard tone mapping
          color = color / (color + vec3(1));
          // Gamma correction
          // float gamma = 0.8;
          // color = pow(4.0 * color, vec3(1.0 / gamma)) / 4.0 * 1.3;
        }

        renderColor = vec4(color, 1.0);
      }`;
      this.#textureList = [];
      this.#pbrList = [];
      this.#translucencyList = [];
      const MAX_TRANSFORMS = Math.floor((Math.min(this.#gl.getParameter(this.#gl.MAX_VERTEX_UNIFORM_VECTORS), this.#gl.getParameter(this.#gl.MAX_FRAGMENT_UNIFORM_VECTORS)) - 16) * 0.25);
      console.log("MAX_TRANSFORMS evaluated to", MAX_TRANSFORMS);
      let vertexShader = GLLib.addCompileTimeConstant(pathtracer_vertex_default, "MAX_TRANSFORMS", MAX_TRANSFORMS);
      let fragmentShader = GLLib.addCompileTimeConstant(pathtracer_fragment_default, "MAX_TRANSFORMS", MAX_TRANSFORMS);
      Program = GLLib.compile(this.#gl, vertexShader, fragmentShader);
      TempProgram = GLLib.compile(this.#gl, GLLib.postVertex, this.#tempGlsl);
      this.#gl.bindVertexArray(Vao);
      this.#engineState.pathtracingUniformLocations = PathtracingUniformLocationIdentifiers.map((identifier) => this.#gl.getUniformLocation(Program, identifier));
      let BlockIndex = this.#gl.getUniformBlockIndex(Program, "transformMatrix");
      let BlockSize = this.#gl.getActiveUniformBlockParameter(Program, BlockIndex, this.#gl.UNIFORM_BLOCK_DATA_SIZE);
      UboBuffer = this.#gl.createBuffer();
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, UboBuffer);
      this.#gl.bufferData(this.#gl.UNIFORM_BUFFER, BlockSize, this.#gl.DYNAMIC_DRAW);
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, null);
      this.#gl.bindBufferBase(this.#gl.UNIFORM_BUFFER, 0, UboBuffer);
      UboVariableIndices = this.#gl.getUniformIndices(Program, ["rotation", "shift"]);
      UboVariableOffsets = this.#gl.getActiveUniforms(
        Program,
        UboVariableIndices,
        this.#gl.UNIFORM_OFFSET
      );
      let index = this.#gl.getUniformBlockIndex(Program, "transformMatrix");
      this.#gl.uniformBlockBinding(Program, index, 0);
      this.#gl.disable(this.#gl.BLEND);
      this.#gl.enable(this.#gl.DEPTH_TEST);
      this.#gl.depthMask(true);
      this.#gl.enable(this.#gl.CULL_FACE);
      this.#gl.clearColor(0, 0, 0, 0);
      this.#gl.useProgram(Program);
      this.#pbrAtlas = this.#gl.createTexture();
      this.#translucencyAtlas = this.#gl.createTexture();
      this.#textureAtlas = this.#gl.createTexture();
      this.#lightTexture = this.#gl.createTexture();
      this.#geometryTexture = this.#gl.createTexture();
      this.#sceneTexture = this.#gl.createTexture();
      [triangleIdBuffer, vertexIdBuffer] = [this.#gl.createBuffer(), this.#gl.createBuffer()];
      this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, triangleIdBuffer);
      this.#gl.enableVertexAttribArray(0);
      this.#gl.vertexAttribIPointer(0, 1, this.#gl.INT, false, 0, 0);
      this.#gl.vertexAttribDivisor(0, 1);
      this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, vertexIdBuffer);
      this.#gl.enableVertexAttribArray(1);
      this.#gl.vertexAttribIPointer(1, 1, this.#gl.INT, false, 0, 0);
      if (this.config.temporal) {
        TempTexture = new Array(this.config.temporalSamples);
        TempIpTexture = new Array(this.config.temporalSamples);
        TempIdTexture = new Array(this.config.temporalSamples);
        for (let i = 0; i < this.config.temporalSamples; i++) {
          TempTexture[i] = this.#gl.createTexture();
          TempIpTexture[i] = this.#gl.createTexture();
          TempIdTexture[i] = this.#gl.createTexture();
        }
        [Framebuffer] = [this.#gl.createFramebuffer()];
        this.#gl.bindVertexArray(TempVao);
        this.#gl.useProgram(TempProgram);
        TempHdrLocation = this.#gl.getUniformLocation(TempProgram, "hdr");
        TempTex = new Array(this.config.temporalSamples);
        TempIpTex = new Array(this.config.temporalSamples);
        TempIdTex = new Array(this.config.temporalSamples);
        for (let i = 0; i < this.config.temporalSamples; i++) {
          TempTex[i] = this.#gl.getUniformLocation(TempProgram, "cache" + i);
          TempIpTex[i] = this.#gl.getUniformLocation(TempProgram, "cacheIp" + i);
          TempIdTex[i] = this.#gl.getUniformLocation(TempProgram, "cacheId" + i);
        }
        let TempVertexBuffer = this.#gl.createBuffer();
        this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, TempVertexBuffer);
        this.#gl.enableVertexAttribArray(0);
        this.#gl.vertexAttribPointer(0, 2, this.#gl.FLOAT, false, 0, 0);
        this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, TempVertexBuffer);
        this.#gl.bufferData(this.#gl.ARRAY_BUFFER, Float32Array.from([0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0]), this.#gl.DYNAMIC_DRAW);
        TempFramebuffer = this.#gl.createFramebuffer();
      }
      renderTextureBuilder();
      this.updateScene();
      resize();
      this.#resizeEvent = window.addEventListener("resize", () => resize());
      requestAnimationFrame(() => frameCycle());
    };
    let renderTextureBuilder = () => {
      let textureList = [RenderTexture, IpRenderTexture, IdRenderTexture];
      if (this.config.temporal) textureList.push(...TempTexture, ...TempIpTexture, ...TempIdTexture);
      textureList.forEach((item) => {
        this.#gl.bindTexture(this.#gl.TEXTURE_2D, item);
        this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#gl.canvas.width, this.#gl.canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, null);
        GLLib.setTexParams(this.#gl);
      });
      this.#gl.bindTexture(this.#gl.TEXTURE_2D, DepthTexture);
      this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.DEPTH_COMPONENT24, this.#gl.canvas.width, this.#gl.canvas.height, 0, this.#gl.DEPTH_COMPONENT, this.#gl.UNSIGNED_INT, null);
      GLLib.setTexParams(this.#gl);
    };
    let resize = () => {
      this.canvas.width = this.canvas.clientWidth * this.config.renderQuality;
      this.canvas.height = this.canvas.clientHeight * this.config.renderQuality;
      this.#gl.viewport(0, 0, this.canvas.width, this.canvas.height);
      renderTextureBuilder();
      if (this.#AAObject) this.#AAObject.createTexture();
    };
    throw new Error("INITIALIZING ENGINE");
    prepareEngine();
  }
};

// src/flexlight/webgpu/renderer.js
var Renderer = class {
  device;
  scene;
  textureAtlas;
  pbrAtlas;
  translucencyAtlas;
  textureList = [];
  pbrList = [];
  translucencyList = [];
  textureGroupLayout;
  textureGroup;
  lightSourceLength = 0;
  lightBuffer;
  primaryLightSources;
  constructor(scene) {
    this.scene = scene;
  }
  async generateAtlasView(list) {
    let [width, height] = this.scene.standardTextureSizes;
    let textureWidth = Math.floor(2048 / width);
    let canvas = document.createElement("canvas");
    let ctx = canvas.getContext("2d");
    if (list.length === 0) {
      canvas.width = width;
      canvas.height = height;
      ctx.imageSmoothingEnabled = false;
      ctx.fillRect(0, 0, width, height);
    } else {
      canvas.width = Math.min(width * list.length, 2048);
      canvas.height = height * (Math.floor(width * list.length / 2048) + 1);
      console.log(canvas.width, canvas.height);
      ctx.imageSmoothingEnabled = false;
      list.forEach(async (texture, i) => ctx.drawImage(texture, width * (i % textureWidth), height * Math.floor(i / textureWidth), width, height));
    }
    let bitMap = await createImageBitmap(canvas);
    let atlasTexture = await this.device.createTexture({
      format: "rgba8unorm",
      size: [canvas.width, canvas.height],
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT
    });
    this.device.queue.copyExternalImageToTexture(
      { source: bitMap, flipY: true },
      { texture: atlasTexture },
      { width: canvas.width, height: canvas.height }
    );
    this.lightSourceLength = 0;
    this.lightBuffer = this.device.createBuffer({ size: Float32Array.BYTES_PER_ELEMENT * 8, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
    return atlasTexture.createView();
  }
  async updateTextureAtlas(forceUpload = false) {
    if (!forceUpload && this.scene.textures.length === this.textureList.length && this.scene.textures.every((e, i) => e === this.textureList[i])) return;
    this.textureList = this.scene.textures;
    this.textureAtlas = await this.generateAtlasView(this.scene.textures);
  }
  async updatePbrAtlas(forceUpload = false) {
    if (!forceUpload && this.scene.pbrTextures.length === this.pbrList.length && this.scene.pbrTextures.every((e, i) => e === this.pbrList[i])) return;
    this.pbrList = this.scene.pbrTextures;
    this.pbrAtlas = await this.generateAtlasView(this.scene.pbrTextures);
  }
  async updateTranslucencyAtlas(forceUpload = false) {
    if (!forceUpload && this.scene.translucencyTextures.length === this.translucencyList.length && this.scene.translucencyTextures.every((e, i) => e === this.translucencyList[i])) return;
    this.translucencyList = this.scene.translucencyTextures;
    this.translucencyAtlas = await this.generateAtlasView(this.scene.translucencyTextures);
  }
  async updateTextureGroup() {
    let objects = [
      this.textureAtlas,
      this.pbrAtlas,
      this.translucencyAtlas
    ];
    this.textureGroup = this.device.createBindGroup({
      label: "texture binding group",
      layout: this.textureGroupLayout,
      entries: objects.map((object, i) => ({ binding: i, resource: object }))
    });
  }
  // Functions to update vertex and light source data textures
  updatePrimaryLightSources() {
    var lightTexArray = [];
    if (this.scene.primaryLightSources.length === 0) {
      lightTexArray = [0, 0, 0, 0, 0, 0, 0, 0];
    } else {
      this.scene.primaryLightSources.forEach((lightSource) => {
        let intensity = Object.is(lightSource.intensity) ? this.scene.defaultLightIntensity : lightSource.intensity;
        let variation = Object.is(lightSource.variation) ? this.scene.defaultLightVariation : lightSource.variation;
        lightTexArray.push(lightSource[0], lightSource[1], lightSource[2], 0, intensity, variation, 0, 0);
      });
    }
    let lightArray = new Float32Array(lightTexArray);
    if (this.lightSourceLength !== lightArray.length) {
      this.lightSourceLength = lightArray.length;
      this.lightBuffer = this.device.createBuffer({ size: lightArray.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
    }
    this.device.queue.writeBuffer(this.lightBuffer, 0, lightArray);
  }
};

// src/flexlight/webgpu/shaders/fxaa.wgsl
var fxaa_default2 = "struct FXAAParams {\n    edge_threshold_min: f32,\n    edge_threshold_max: f32,\n    subpix_quality: f32,\n    _padding: f32\n};\n\n@group(0) @binding(0) var input_texture: texture_2d<f32>;\n@group(0) @binding(1) var output_texture: texture_storage_2d<rgba32float, write>;\n@group(0) @binding(2) var<uniform> params: FXAAParams;\n\n// Helper function to get luminance from RGB\nfn luminance(color: vec3<f32>) -> f32 {\n    return dot(color, vec3<f32>(0.299, 0.587, 0.114));\n}\n\n@compute @workgroup_size(8, 8)\nfn compute(@builtin(global_invocation_id) global_id: vec3<u32>) {\n    // Convert global_id to u32 for comparison with texture size\n    let screen_pos = vec2<u32>(global_id.xy);\n    let texture_size = textureDimensions(input_texture);\n    \n    // Early exit if outside render bounds\n    if (screen_pos.x >= texture_size.x || screen_pos.y >= texture_size.y) {\n        return;\n    }\n\n    // Convert to i32 for texture loading\n    let load_pos = vec2<i32>(screen_pos);\n    let texel_size = vec2<f32>(1.0) / vec2<f32>(texture_size);\n    \n    // Sample the 3x3 neighborhood\n    let center = textureLoad(input_texture, load_pos, 0);\n    let north = textureLoad(input_texture, load_pos + vec2<i32>(0, 1), 0);\n    let south = textureLoad(input_texture, load_pos + vec2<i32>(0, -1), 0);\n    let east = textureLoad(input_texture, load_pos + vec2<i32>(1, 0), 0);\n    let west = textureLoad(input_texture, load_pos + vec2<i32>(-1, 0), 0);\n    \n    // Get luminance values\n    let luma_center = luminance(center.rgb);\n    let luma_north = luminance(north.rgb);\n    let luma_south = luminance(south.rgb);\n    let luma_east = luminance(east.rgb);\n    let luma_west = luminance(west.rgb);\n    \n    // Find min and max luma in 3x3 neighborhood\n    let luma_min = min(luma_center, min(min(luma_north, luma_south), min(luma_east, luma_west)));\n    let luma_max = max(luma_center, max(max(luma_north, luma_south), max(luma_east, luma_west)));\n    \n    // Compute local contrast\n    let luma_range = luma_max - luma_min;\n    \n    // Early exit if contrast is lower than minimum\n    if (luma_range < max(params.edge_threshold_min, luma_max * params.edge_threshold_max)) {\n        textureStore(output_texture, load_pos, center);\n        return;\n    }\n    \n    // Compute horizontal and vertical gradients\n    let horizontal = abs(luma_west + luma_east - 2.0 * luma_center) * 2.0 +\n                    abs(luma_north + luma_south - 2.0 * luma_center);\n    let vertical = abs(luma_north + luma_south - 2.0 * luma_center) * 2.0 +\n                  abs(luma_west + luma_east - 2.0 * luma_center);\n    \n    // Determine edge direction\n    let is_horizontal = horizontal >= vertical;\n    \n    // Choose positive and negative endpoints\n    let gradient_step = select(vec2<f32>(0.0, texel_size.y), vec2<f32>(texel_size.x, 0.0), is_horizontal);\n    let pos_grad = select(luma_north, luma_east, is_horizontal);\n    let neg_grad = select(luma_south, luma_west, is_horizontal);\n    \n    // Compute local gradient\n    let gradient = max(\n        abs(pos_grad - luma_center),\n        abs(neg_grad - luma_center)\n    );\n    \n    // Calculate blend factor\n    let blend_factor = smoothstep(0.0, 1.0, gradient / luma_range);\n    let subpix_blend = clamp(blend_factor * params.subpix_quality, 0.0, 1.0);\n    \n    // Perform anti-aliasing blend\n    var result: vec4<f32>;\n    if (is_horizontal) {\n        let blend_color = mix(west, east, subpix_blend);\n        result = mix(center, blend_color, 0.5);\n    } else {\n        let blend_color = mix(south, north, subpix_blend);\n        result = mix(center, blend_color, 0.5);\n    }\n    \n    textureStore(output_texture, load_pos, result);\n}\n";

// src/flexlight/webgpu/fxaa.js
var FXAA2 = class {
  #pipeline;
  #texture;
  #device;
  #canvas;
  #bindGroupLayout;
  #bindGroup;
  #uniformBuffer;
  constructor(device, canvas) {
    this.#device = device;
    this.#canvas = canvas;
    this.#bindGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float" } },
        { binding: 1, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d" } },
        { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "uniform" } }
      ]
    });
    this.#uniformBuffer = device.createBuffer({
      size: 16,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST
    });
    this.createTexture();
  }
  get textureInView() {
    return this.#texture.createView({ dimension: "2d" });
  }
  get textureInView2dArray() {
    return this.#texture.createView({ dimension: "2d-array", arrayLayerCount: 1 });
  }
  createTexture = () => {
    try {
      this.#texture.destroy();
    } catch {
    }
    this.#texture = this.#device.createTexture({
      size: [this.#canvas.width, this.#canvas.height, 1],
      format: "rgba32float",
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.COPY_SRC
    });
  };
  createBindGroup = (textureOut) => {
    this.#bindGroup = this.#device.createBindGroup({
      layout: this.#bindGroupLayout,
      entries: [
        { binding: 0, resource: this.#texture.createView() },
        { binding: 1, resource: textureOut.createView() },
        { binding: 2, resource: { buffer: this.#uniformBuffer } }
      ]
    });
    this.#pipeline = this.#device.createComputePipeline({
      label: "fxaa pipeline",
      layout: this.#device.createPipelineLayout({ bindGroupLayouts: [this.#bindGroupLayout] }),
      compute: {
        module: this.#device.createShaderModule({ code: fxaa_default2 }),
        entryPoint: "compute"
      }
    });
    const fxaaParams = new Float32Array([
      1 / 16,
      1 / 4,
      1 / 4
    ]);
    this.#device.queue.writeBuffer(this.#uniformBuffer, 0, fxaaParams);
  };
  renderFrame = (commandEncoder) => {
    const computePass = commandEncoder.beginComputePass();
    computePass.setPipeline(this.#pipeline);
    computePass.setBindGroup(0, this.#bindGroup);
    const workgroupsX = Math.ceil(this.#canvas.width / 8);
    const workgroupsY = Math.ceil(this.#canvas.height / 8);
    computePass.dispatchWorkgroups(workgroupsX, workgroupsY);
    computePass.end();
  };
};

// src/flexlight/webgpu/shaders/taa.wgsl
var taa_default2 = "struct Uniforms {\n    frame_index: f32,\n    frames: f32,\n    random_vecs: vec2<f32>\n};\n\n@group(0) @binding(0) var input_texture: texture_2d_array<f32>;\n@group(0) @binding(1) var output_texture: texture_storage_2d<rgba32float, write>;\n@group(0) @binding(2) var<uniform> uniforms: Uniforms;\n\n// Helper function to calculate color variance\nfn calculate_neighborhood_bounds(center_pos: vec2<i32>) -> mat2x3<f32> {\n    var min_color = vec3<f32>(1.0f);\n    var max_color = vec3<f32>(0.0f);\n    var mean_color = vec3<f32>(0.0f);\n    var mean_sq_color = vec3<f32>(0.0f);\n    var sample_count = 0.0f;\n\n    // Sample 3x3 neighborhood with gaussian weights\n    for (var y = -1; y <= 1; y++) {\n        for (var x = -1; x <= 1; x++) {\n            let sample_pos = center_pos + vec2<i32>(x, y);\n            let weight = (1.0f - abs(f32(x)) * 0.5f) * (1.0f - abs(f32(y)) * 0.5f);\n            let sample = textureLoad(input_texture, sample_pos, u32(uniforms.frame_index), 0).xyz;\n            \n            mean_color += sample * weight;\n            mean_sq_color += sample * sample * weight;\n            min_color = min(min_color, sample);\n            max_color = max(max_color, sample);\n            sample_count += weight;\n        }\n    }\n\n    mean_color /= sample_count;\n    mean_sq_color /= sample_count;\n    \n    // Calculate variance and adjust bounds\n    let variance = max(mean_sq_color - mean_color * mean_color, vec3<f32>(0.0));\n    let std_dev = sqrt(variance);\n    \n    // Expand the color bounds based on local variance\n    let gamma = 1.25f;\n    min_color = max(min_color, mean_color - std_dev * gamma);\n    max_color = min(max_color, mean_color + std_dev * gamma);\n    \n    return mat2x3<f32>(min_color, max_color);\n}\n\n@compute @workgroup_size(8, 8)\nfn compute(@builtin(global_invocation_id) global_id: vec3<u32>) {\n    let screen_pos = global_id.xy;\n    let texture_size = textureDimensions(input_texture);\n    \n    if (screen_pos.x >= texture_size.x || screen_pos.y >= texture_size.y) {\n        return;\n    }\n\n    let center_pos = vec2<i32>(screen_pos);\n    let current_color = textureLoad(input_texture, center_pos, u32(uniforms.frame_index), 0).xyz;\n    \n    // Calculate color bounds\n    let bounds = calculate_neighborhood_bounds(center_pos);\n    let min_color = bounds[0];\n    let max_color = bounds[1];\n\n    // Accumulate history samples with improved clamping\n    var final_color = current_color;\n    var weight_sum = 1.0f;\n    \n    for (var i = 0; i < i32(uniforms.frames); i++) {\n        if (i == i32(uniforms.frame_index)) {\n            continue;\n        }\n        \n        let history_color = textureLoad(input_texture, center_pos, u32(i), 0).xyz;\n        \n        // Clamp history color to neighborhood bounds\n        let clamped_color = clamp(history_color, min_color, max_color);\n        \n        // Calculate confidence weight based on how much clamping was needed\n        let clamp_amount = length(history_color - clamped_color);\n        let confidence = 1.0f - smoothstep(0.0f, 0.1f, clamp_amount);\n        \n        final_color += clamped_color * confidence;\n        weight_sum += confidence;\n    }\n\n    final_color /= weight_sum;\n    textureStore(output_texture, screen_pos, vec4<f32>(final_color, 1.0f));\n}";

// src/flexlight/webgpu/taa.js
var FRAMES2 = 4;
var TAA2 = class {
  #pipeline;
  #texture;
  #device;
  #canvas;
  frameIndex = 0;
  #randomVecs;
  #bindGroupLayout;
  #bindGroup;
  #uniformBuffer;
  constructor(device, canvas) {
    this.#device = device;
    this.#canvas = canvas;
    this.#randomVecs = this.genPseudoRandomVecsWith0Sum(FRAMES2);
    this.#bindGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "rgba32float", sampleType: "unfilterable-float", viewDimension: "2d-array" } },
        { binding: 1, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d" } },
        { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "uniform" } }
      ]
    });
    this.#pipeline = device.createComputePipeline({
      label: "taa pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: [this.#bindGroupLayout] }),
      compute: {
        module: device.createShaderModule({ code: taa_default2 }),
        entryPoint: "compute"
      }
    });
    this.#uniformBuffer = device.createBuffer({
      size: 16,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST
    });
    this.createTexture();
  }
  get textureInView() {
    return this.#texture.createView({ dimension: "2d", baseArrayLayer: this.frameIndex, arrayLayerCount: 1 });
  }
  get textureInView2dArray() {
    return this.#texture.createView({ dimension: "2d-array", baseArrayLayer: this.frameIndex, arrayLayerCount: 1 });
  }
  createTexture = () => {
    this.#texture = this.#device.createTexture({
      size: [this.#canvas.width, this.#canvas.height, FRAMES2],
      format: "rgba32float",
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.COPY_SRC
    });
  };
  createBindGroup = (textureOut) => {
    this.#bindGroup = this.#device.createBindGroup({
      layout: this.#bindGroupLayout,
      entries: [
        { binding: 0, resource: this.#texture.createView({ dimension: "2d-array", arrayLayerCount: FRAMES2 }) },
        { binding: 1, resource: textureOut.createView() },
        { binding: 2, resource: { buffer: this.#uniformBuffer } }
      ]
    });
  };
  renderFrame = async (commandEncoder) => {
    this.frameIndex = (this.frameIndex + 1) % FRAMES2;
    const taaParams = new Float32Array([
      this.frameIndex,
      FRAMES2,
      this.#randomVecs[this.frameIndex][0],
      this.#randomVecs[this.frameIndex][1]
    ]);
    this.#device.queue.writeBuffer(this.#uniformBuffer, 0, taaParams);
    const computePass = commandEncoder.beginComputePass();
    computePass.setPipeline(this.#pipeline);
    computePass.setBindGroup(0, this.#bindGroup);
    const workgroupsX = Math.ceil(this.#canvas.width / 8);
    const workgroupsY = Math.ceil(this.#canvas.height / 8);
    computePass.dispatchWorkgroups(workgroupsX, workgroupsY);
    computePass.end();
  };
  // Jitter and genPseudoRandomVecsWith0Sum methods remain the same
  jitter = () => {
    let frameIndex = (this.frameIndex + 1) % FRAMES2;
    let scale = 0.3 / Math.min(this.#canvas.width, this.#canvas.height);
    return { x: this.#randomVecs[frameIndex][0] * scale, y: this.#randomVecs[frameIndex][1] * scale };
  };
  // Generate n d-dimensional pseudo random vectors that all add up to 0.
  genPseudoRandomVecsWith0Sum = (n) => {
    let vecs = new Array(n).fill(0).map(() => new Array(2));
    vecs[0] = [0, 1];
    vecs[1] = [1, 0];
    let combined = [1, 1];
    for (let i = 2; i < n; i++) {
      for (let j = 0; j < 2; j++) {
        let min = Math.max(-Math.min(i + 1, n - 1 - i), combined[j] - 1);
        let max = Math.min(Math.min(i + 1, n - 1 - i), combined[j] + 1);
        vecs[i][j] = 0.5 * (max + min + (max - min) * Math.sign(Math.random() - 0.5) * (Math.random() * 0.5) ** (1 / 2)) - combined[j];
        combined[j] += vecs[i][j];
      }
    }
    return vecs;
  };
};

// src/flexlight/webgpu/shaders/pathtracer-depth.wgsl
var pathtracer_depth_default = "const PI: f32 = 3.141592653589793;\nconst PHI: f32 = 1.61803398874989484820459;\nconst SQRT3: f32 = 1.7320508075688772;\nconst POW32: f32 = 4294967296.0;\nconst POW23M1: f32 = 8388607.0;\nconst POW23M1U: u32 = 8388607u;\nconst BIAS: f32 = 0.0000152587890625;\nconst INV_PI: f32 = 0.3183098861837907;\nconst INV_255: f32 = 0.00392156862745098;\n\nstruct Transform {\n    rotation: mat3x3<f32>,\n    shift: vec3<f32>,\n};\n\nstruct Uniforms {\n    view_matrix: mat3x3<f32>,\n    view_matrix_jitter: mat3x3<f32>,\n\n    camera_position: vec3<f32>,\n    ambient: vec3<f32>,\n\n    texture_size: vec2<f32>,\n    render_size: vec2<f32>,\n\n    samples: f32,\n    max_reflections: f32,\n    min_importancy: f32,\n    use_filter: f32,\n\n    tonemapping_operator: f32,\n    is_temporal: f32,\n    temporal_target: f32\n};\n\nstruct VertexOut {\n    @builtin(position) pos: vec4<f32>,\n    @location(0) absolute_position: vec3<f32>,\n    @location(1) uv: vec2<f32>,\n    @location(2) clip_space: vec3<f32>,\n    @location(3) @interpolate(flat) triangle_id: i32,\n};\n\n@group(0) @binding(0) var<storage, read_write> depth_buffer: array<atomic<u32>>;\n\n@group(1) @binding(0) var<storage, read> indices: array<i32>;\n@group(1) @binding(1) var<storage, read> geometry: array<f32>;\n\n@group(2) @binding(0) var<uniform> uniforms: Uniforms;\n@group(2) @binding(1) var<storage, read> transforms: array<Transform>;\n\n\nconst base_uvs: array<vec2<f32>, 3> = array(\n    vec2<f32>(1.0f, 0.0f),\n    vec2<f32>(0.0f, 1.0f),\n    vec2<f32>(0.0f, 0.0f)\n);\n\n@vertex\nfn vertex(\n    @builtin(vertex_index) vertex_index: u32,\n    @builtin(instance_index) instance_index: u32\n) -> VertexOut {\n    var out: VertexOut;\n\n    let vertex_num: i32 = i32(vertex_index) % 3;\n    out.triangle_id = indices[instance_index];\n    let geometry_index: i32 = out.triangle_id * 12;\n    let v_i: i32 = geometry_index + vertex_num * 3;\n    // Transform position\n    let relative_position: vec3<f32> = vec3<f32>(geometry[v_i], geometry[v_i + 1], geometry[v_i + 2]);\n    // Get transformation ID\n    let t_i: i32 = i32(geometry[geometry_index + 9]) << 1u;\n    // Trasform position\n    let transform: Transform = transforms[t_i];\n    out.absolute_position = (transform.rotation * relative_position) + transform.shift;\n    // Set uv to vertex uv and let the vertex interpolation generate the values in between\n    switch (vertex_num) {\n        case 0: {\n            out.uv = vec2<f32>(1.0f, 0.0f);\n        }\n        case 1: {\n            out.uv = vec2<f32>(0.0f, 1.0f);\n        }\n        case 2, default {\n            out.uv = vec2<f32>(0.0f, 0.0f);\n        }\n    }\n    out.clip_space = uniforms.view_matrix_jitter * (out.absolute_position - uniforms.camera_position);\n    // Set triangle position in clip space\n    out.pos = vec4<f32>(out.clip_space.xy, 0.0, out.clip_space.z);\n    return out;\n}\n\n// FRAGMENT SHADER ------------------------------------------------------------------------------------------------------------------------\n\n@fragment\nfn fragment(\n    @location(0) absolute_position: vec3<f32>,\n    @location(1) uv: vec2<f32>,\n    @location(2) clip_space: vec3<f32>,\n    @location(3) @interpolate(flat) triangle_id: i32\n) -> @location(0) vec4<f32> {\n\n    // Get canvas size\n    let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5 + 0.5;\n    let coord: vec2<u32> = vec2<u32>(\n        u32(uniforms.render_size.x * screen_space.x),\n        u32(uniforms.render_size.y  * (1.0 - screen_space.y))\n    );\n\n    let buffer_index: u32 = coord.x + u32(uniforms.render_size.x) * coord.y;\n    // Only save if texel is closer to camera then previously\n    let current_depth: u32 = POW23M1U - u32(POW23M1 / (1.0f + exp(- clip_space.z * INV_255)));\n    // Store in texture\n    atomicMax(&depth_buffer[buffer_index], current_depth);\n    return vec4<f32>(1.0f);\n}";

// src/flexlight/webgpu/shaders/pathtracer-raster.wgsl
var pathtracer_raster_default = "const PI: f32 = 3.141592653589793;\nconst PHI: f32 = 1.61803398874989484820459;\nconst SQRT3: f32 = 1.7320508075688772;\nconst POW32: f32 = 4294967296.0;\nconst POW32U: u32 = 4294967295u;\nconst POW23M1: f32 = 8388607.0;\nconst POW23M1U: u32 = 8388607u;\nconst BIAS: f32 = 0.0000152587890625;\nconst INV_PI: f32 = 0.3183098861837907;\nconst INV_255: f32 = 0.00392156862745098;\n\nstruct Transform {\n    rotation: mat3x3<f32>,\n    shift: vec3<f32>,\n};\n\nstruct Uniforms {\n    view_matrix: mat3x3<f32>,\n    view_matrix_jitter: mat3x3<f32>,\n\n    camera_position: vec3<f32>,\n    ambient: vec3<f32>,\n\n    texture_size: vec2<f32>,\n    render_size: vec2<f32>,\n\n    samples: f32,\n    max_reflections: f32,\n    min_importancy: f32,\n    use_filter: f32,\n\n    tonemapping_operator: f32,\n    is_temporal: f32,\n    temporal_target: f32\n};\n\nstruct VertexOut {\n    @builtin(position) pos: vec4<f32>,\n    @location(0) absolute_position: vec3<f32>,\n    @location(1) uv: vec2<f32>,\n    @location(2) clip_space: vec3<f32>,\n    @location(3) @interpolate(flat) triangle_id: i32,\n};\n\n\n@group(0) @binding(0) var<storage, read> depth_buffer: array<u32>;\n@group(0) @binding(1) var <storage, read_write> triangle_id_buffer: array<i32>;\n@group(0) @binding(2) var texture_absolute_position: texture_storage_2d<rgba32float, write>;\n@group(0) @binding(3) var texture_uv: texture_storage_2d<rg32float, write>;\n\n@group(1) @binding(0) var<storage, read> indices: array<i32>;\n@group(1) @binding(1) var<storage, read> geometry: array<f32>;\n\n@group(2) @binding(0) var<uniform> uniforms: Uniforms;\n@group(2) @binding(1) var<storage, read> transforms: array<Transform>;\n\n\n\n@vertex\nfn vertex(\n    @builtin(vertex_index) vertex_index : u32,\n    @builtin(instance_index) instance_index: u32\n) -> VertexOut {\n    var out: VertexOut;\n\n    let vertex_num: i32 = i32(vertex_index) % 3;\n    out.triangle_id = indices[instance_index];\n    let geometry_index: i32 = out.triangle_id * 12;\n    let v_i: i32 = geometry_index + vertex_num * 3;\n    // Transform position\n    let relative_position: vec3<f32> = vec3<f32>(geometry[v_i], geometry[v_i + 1], geometry[v_i + 2]);\n    // Get transformation ID\n    let t_i: i32 = i32(geometry[geometry_index + 9]) << 1u;\n    // Trasform position\n    let transform: Transform = transforms[t_i];\n    out.absolute_position = (transform.rotation * relative_position) + transform.shift;\n    // Set uv to vertex uv and let the vertex interpolation generate the values in between\n    switch (vertex_num) {\n        case 0: {\n            out.uv = vec2<f32>(1.0f, 0.0f);\n        }\n        case 1: {\n            out.uv = vec2<f32>(0.0f, 1.0f);\n        }\n        case 2, default {\n            out.uv = vec2<f32>(0.0f, 0.0f);\n        }\n    }\n    out.clip_space = uniforms.view_matrix_jitter * (out.absolute_position - uniforms.camera_position);\n    // Set triangle position in clip space\n    out.pos = vec4<f32>(out.clip_space.xy, 0.0f, out.clip_space.z);\n    return out;\n}\n\n// FRAGMENT SHADER ------------------------------------------------------------------------------------------------------------------------\n\n@fragment\nfn fragment(\n    @location(0) absolute_position: vec3<f32>,\n    @location(1) uv: vec2<f32>,\n    @location(2) clip_space: vec3<f32>,\n    @location(3) @interpolate(flat) triangle_id: i32\n) -> @location(0) vec4<f32> {\n\n    // Get canvas size\n    let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5f + 0.5f;\n    let coord: vec2<u32> = vec2<u32>(\n        u32(uniforms.render_size.x * screen_space.x),\n        u32(uniforms.render_size.y  * (1.0f - screen_space.y))\n    );\n\n    let buffer_index: u32 = coord.x + u32(uniforms.render_size.x) * coord.y;\n    // Only save if texel is closer to camera then previously\n    // let current_depth: u32 = u32(POW23M1 / (1.0f + exp(- clip_space.z * INV_255)));\n    let current_depth: u32 = POW23M1U - u32(POW23M1 / (1.0f + exp(- clip_space.z * INV_255)));\n\n    if (current_depth == depth_buffer[buffer_index]) {\n        // Save values for compute pass\n        textureStore(texture_absolute_position, coord, vec4<f32>(absolute_position, 0.0f));\n        textureStore(texture_uv, coord, vec4<f32>(uv, 0.0f, 0.0f));\n        triangle_id_buffer[buffer_index] = triangle_id;\n    }\n\n    return vec4<f32>(f32(triangle_id % 3) / 3.0f, f32(triangle_id % 2) / 2.0f, f32(triangle_id % 5) / 5.0f, 1.0f);\n}";

// src/flexlight/webgpu/shaders/pathtracer-shift.wgsl
var pathtracer_shift_default = "const POW32U: u32 = 4294967295u;\nconst POW23M1: f32 = 8388607.0;\nconst INV_255: f32 = 1.0f / 255.0f;\n\nstruct Uniforms {\n    view_matrix: mat3x3<f32>,\n    view_matrix_jitter: mat3x3<f32>,\n\n    camera_position: vec3<f32>,\n    ambient: vec3<f32>,\n\n    texture_size: vec2<f32>,\n    render_size: vec2<f32>,\n\n    samples: f32,\n    max_reflections: f32,\n    min_importancy: f32,\n    use_filter: f32,\n\n    tonemapping_operator: f32,\n    is_temporal: f32,\n    temporal_count: f32,\n    temporal_max: f32\n};\n\n@group(0) @binding(0) var accumulated: texture_2d_array<f32>;\n@group(0) @binding(1) var shift_out: texture_storage_2d_array<rgba32float, write>;\n@group(0) @binding(2) var<storage, read_write> shift_lock: array<atomic<u32>>;\n\n@group(1) @binding(0) var<uniform> uniforms: Uniforms;\n\n@compute\n@workgroup_size(8, 8)\nfn compute(\n    @builtin(workgroup_id) workgroup_id : vec3<u32>,\n    @builtin(local_invocation_id) local_invocation_id : vec3<u32>,\n    @builtin(global_invocation_id) global_invocation_id : vec3<u32>,\n    @builtin(local_invocation_index) local_invocation_index: u32,\n    @builtin(num_workgroups) num_workgroups: vec3<u32>\n) {\n    // Get texel position of screen\n    let screen_pos: vec2<u32> = global_invocation_id.xy;\n    \n    if (screen_pos.x > u32(uniforms.render_size.x) || screen_pos.y > u32(uniforms.render_size.y)) {\n        return;\n    }\n    \n    // Extract color value from old position\n    let fine_color_acc: vec4<f32> = textureLoad(accumulated, screen_pos, 0, 0);\n    let coarse_color_acc: vec4<f32> = textureLoad(accumulated, screen_pos, 1, 0);\n    let fine_color_low_variance_acc: vec4<f32> = textureLoad(accumulated, screen_pos, 2, 0);\n    let coarse_color_low_variance_acc: vec4<f32> = textureLoad(accumulated, screen_pos, 3, 0);\n    // Extract 3d position value\n    let position_old: vec4<f32> = textureLoad(accumulated, screen_pos, 4, 0);\n    \n    // Map postion according to current camera positon and view matrix to clip space\n    let relative_position: vec3<f32> = position_old.xyz - uniforms.camera_position;\n    let clip_space: vec3<f32> = uniforms.view_matrix * relative_position;\n    // Project onto screen and shift origin to the corner\n    let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5 + 0.5;\n    // Translate to texel value\n    let coord: vec2<u32> = vec2<u32>(\n        u32((uniforms.render_size.x * screen_space.x)),\n        u32((uniforms.render_size.y * (1.0f - screen_space.y)))\n    );\n\n    let last_frame = position_old.w == uniforms.temporal_count;\n    // Skip if data is not from last frame\n    if (!last_frame) {\n        return;\n    }\n\n    let buffer_index: u32 = coord.x + u32(uniforms.render_size.x) * coord.y;\n    // Attempt to acquire lock.\n    let lock: u32 = atomicOr(&shift_lock[buffer_index], 1u);\n    if (lock == 1u) {\n        // If lock is already set then another thread is already working on this pixel\n        return;\n    }\n    \n    // Write to shift buffer\n    textureStore(shift_out, coord, 0, fine_color_acc);\n    textureStore(shift_out, coord, 1, coarse_color_acc);\n    textureStore(shift_out, coord, 2, fine_color_low_variance_acc);\n    textureStore(shift_out, coord, 3, coarse_color_low_variance_acc);\n    textureStore(shift_out, coord, 4, position_old);\n\n\n    // Release lock.\n    atomicStore(&shift_lock[buffer_index], 0u);\n}";

// src/flexlight/webgpu/shaders/pathtracer-compute.wgsl
var pathtracer_compute_default = "const PI: f32 = 3.141592653589793;\nconst PHI: f32 = 1.61803398874989484820459;\nconst SQRT3: f32 = 1.7320508075688772;\nconst POW32: f32 = 4294967296.0;\nconst POW32U: u32 = 4294967295u;\nconst BIAS: f32 = 0.0000152587890625;\nconst INV_PI: f32 = 0.3183098861837907;\nconst INV_255: f32 = 0.00392156862745098;\nconst INV_65535: f32 = 0.000015259021896696422;\n\nstruct Transform {\n    rotation: mat3x3<f32>,\n    shift: vec3<f32>,\n};\n\nstruct Light {\n    position: vec3<f32>,\n    strength_variation: vec2<f32>,\n}\n\nstruct Uniforms {\n    view_matrix: mat3x3<f32>,\n    view_matrix_jitter: mat3x3<f32>,\n\n    camera_position: vec3<f32>,\n    ambient: vec3<f32>,\n\n    texture_size: vec2<f32>,\n    render_size: vec2<f32>,\n\n    samples: f32,\n    max_reflections: f32,\n    min_importancy: f32,\n    use_filter: f32,\n\n    tonemapping_operator: f32,\n    is_temporal: f32,\n    temporal_target: f32\n};\n\n@group(0) @binding(0) var compute_out: texture_storage_2d_array<rgba32float, write>;\n@group(0) @binding(1) var<storage, read> triangle_id_buffer: array<i32>;\n@group(0) @binding(2) var texture_absolute_position: texture_2d<f32>;\n@group(0) @binding(3) var texture_uv: texture_2d<f32>;\n\n@group(1) @binding(0) var texture_atlas: texture_2d<f32>;\n@group(1) @binding(1) var pbr_atlas: texture_2d<f32>;\n@group(1) @binding(2) var translucency_atlas: texture_2d<f32>;\n\n@group(2) @binding(0) var<storage, read> indices: array<i32>;\n@group(2) @binding(1) var<storage, read> geometry: array<f32>;\n@group(2) @binding(2) var<storage, read> scene: array<f32>;\n\n@group(3) @binding(0) var<uniform> uniforms: Uniforms;\n@group(3) @binding(1) var<storage, read> transforms: array<Transform>;\n@group(3) @binding(2) var<storage, read> lights: array<Light>;\n\nstruct Ray {\n    origin: vec3<f32>,\n    unit_direction: vec3<f32>,\n};\n\nstruct Material {\n    albedo: vec3<f32>,\n    rme: vec3<f32>,\n    tpo: vec3<f32>\n};\n\nstruct Hit {\n    suv: vec3<f32>,\n    triangle_id: i32\n};\n\nstruct Sample {\n    color: vec3<f32>,\n    render_id_w: f32\n}\n\n// var render_id: vec4<f32> = vec4<f32>(0.0f);\n// var render_original_id: vec4<f32> = vec4<f32>(0.0f);\n\n// Lookup values for texture atlases\nfn fetchTexVal(atlas: texture_2d<f32>, uv: vec2<f32>, tex_num: f32, default_val: vec3<f32>) -> vec3<f32> {\n    // Return default value if no texture is set\n    if (tex_num == - 1.0f) {\n        return default_val;\n    }\n    // Get dimensions of texture atlas\n    let atlas_size: vec2<f32> = vec2<f32>(textureDimensions(atlas));\n    let width: f32 = tex_num * uniforms.texture_size.x;\n    let offset: vec2<f32> = vec2<f32>(\n        width % atlas_size.x,\n        atlas_size.y - floor(width / atlas_size.x) * uniforms.texture_size.y\n    );\n    // WebGPU quirk of having upsidedown height for textures\n    let atlas_texel: vec2<i32> = vec2<i32>(offset + uv * uniforms.texture_size * vec2<f32>(1.0f, -1.0f));\n    // Fetch texel on requested coordinate\n    let tex_val: vec3<f32> = textureLoad(atlas, atlas_texel, 0).xyz;\n    return tex_val;\n}\n\nfn noise(n: vec2<f32>, seed: f32) -> vec4<f32> {\n    // let temp_component: vec2<f32> = fract(vec2<f32>(uniforms.temporal_target * PHI, cos(uniforms.temporal_target) + PHI));\n    // return fract(sin(dot(n.xy, vec2<f32>(12.9898f, 78.233f)) + vec4<f32>(53.0f, 59.0f, 61.0f, 67.0f) * seed) * 43758.5453f) * 2.0f - 1.0f;\n    return fract(sin(dot(n.xy, vec2<f32>(12.9898f, 78.233f)) + vec4<f32>(53.0f, 59.0f, 61.0f, 67.0f) * sin(seed + uniforms.temporal_target * PHI)) * 43758.5453f) * 2.0f - 1.0f;\n\n}\n\nfn moellerTrumbore(t: mat3x3<f32>, ray: Ray, l: f32) -> vec3<f32> {\n    let edge1: vec3<f32> = t[1] - t[0];\n    let edge2: vec3<f32> = t[2] - t[0];\n    let pvec: vec3<f32> = cross(ray.unit_direction, edge2);\n    let det: f32 = dot(edge1, pvec);\n    if(abs(det) < BIAS) {\n        return vec3<f32>(0.0f);\n    }\n    let inv_det: f32 = 1.0f / det;\n    let tvec: vec3<f32> = ray.origin - t[0];\n    let u: f32 = dot(tvec, pvec) * inv_det;\n    if(u < BIAS || u > 1.0f) {\n        return vec3<f32>(0.0f);\n    }\n    let qvec: vec3<f32> = cross(tvec, edge1);\n    let v: f32 = dot(ray.unit_direction, qvec) * inv_det;\n    let uv_sum: f32 = u + v;\n    if(v < BIAS || uv_sum > 1.0f) {\n        return vec3<f32>(0.0f);\n    }\n    let s: f32 = dot(edge2, qvec) * inv_det;\n    if(s > l || s <= BIAS) {\n        return vec3<f32>(0.0f);\n    }\n    return vec3<f32>(s, u, v);\n}\n\n// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles\nfn moellerTrumboreCull(t: mat3x3<f32>, ray: Ray, l: f32) -> bool {\n    let edge1 = t[1] - t[0];\n    let edge2 = t[2] - t[0];\n    let pvec = cross(ray.unit_direction, edge2);\n    let det = dot(edge1, pvec);\n    let inv_det = 1.0f / det;\n    if(det < BIAS) { \n        return false;\n    }\n    let tvec = ray.origin - t[0];\n    let u: f32 = dot(tvec, pvec) * inv_det;\n    if(u < BIAS || u > 1.0f) {\n        return false;\n    }\n    let qvec: vec3<f32> = cross(tvec, edge1);\n    let v: f32 = dot(ray.unit_direction, qvec) * inv_det;\n    if(v < BIAS || u + v > 1.0f) {\n        return false;\n    }\n    let s: f32 = dot(edge2, qvec) * inv_det;\n    return (s <= l && s > BIAS);\n}\n\n// Don't return intersection point, because we're looking for a specific triangle\nfn rayCuboid(min_corner: vec3<f32>, max_corner: vec3<f32>, ray: Ray, l: f32) -> bool {\n    let v0: vec3<f32> = (min_corner - ray.origin) / ray.unit_direction;\n    let v1: vec3<f32> = (max_corner - ray.origin) / ray.unit_direction;\n    let tmin: f32 = max(max(min(v0.x, v1.x), min(v0.y, v1.y)), min(v0.z, v1.z));\n    let tmax: f32 = min(min(max(v0.x, v1.x), max(v0.y, v1.y)), max(v0.z, v1.z));\n    return tmax >= max(tmin, BIAS) && tmin < l;\n}\n\n// Test for closest ray triangle intersection\n// return intersection position in world space and index of target triangle in geometryTex\n// plus triangle and transformation Id\nfn rayTracer(ray: Ray) -> Hit {\n    // Cache transformed ray attributes\n    var t_ray: Ray = Ray(ray.origin, ray.unit_direction);\n    // Inverse of transformed normalized ray\n    var cached_t_i: i32 = 0;\n    // Latest intersection which is now closest to origin\n    var hit: Hit = Hit(vec3(0.0f), - 1);\n    // Precomput max length\n    var min_len: f32 = POW32;\n    // Get texture size as max iteration value\n    let size: i32 = i32(arrayLength(&geometry)) / 12;\n    // Iterate through lines of texture\n    for (var i: i32 = 0; i < size; i++) {\n        // Get position of current triangle/vertex in geometryTex\n        let index: i32 = i * 12;\n        // Fetch triangle coordinates from scene graph\n        let a = vec3<f32>(geometry[index    ], geometry[index + 1], geometry[index + 2]);\n        let b = vec3<f32>(geometry[index + 3], geometry[index + 4], geometry[index + 5]);\n        let c = vec3<f32>(geometry[index + 6], geometry[index + 7], geometry[index + 8]);\n\n        let t_i: i32 = i32(geometry[index + 9]) << 1u;\n        // Test if cached transformed variables are still valid\n        if (t_i != cached_t_i) {\n            let i_i: i32 = t_i + 1;\n            cached_t_i = t_i;\n            let i_transform = transforms[i_i];\n            t_ray = Ray(\n                i_transform.rotation * (ray.origin + i_transform.shift),\n                i_transform.rotation * ray.unit_direction\n            );\n        }\n        // Three cases:\n        // indicator = 0        => end of list: stop loop\n        // indicator = 1        => is bounding volume: do AABB intersection test\n        // indicator = 2        => is triangle: do triangle intersection test\n        switch i32(geometry[index + 10]) {\n            case 0 {\n                return hit;\n            }\n            case 1: {\n                if(!rayCuboid(a, b, t_ray, min_len)) {\n                    i += i32(c.x);\n                }\n            }\n            case 2: {\n                let triangle: mat3x3<f32> = mat3x3<f32>(a, b, c);\n                 // Test if triangle intersects ray\n                let intersection: vec3<f32> = moellerTrumbore(triangle, t_ray, min_len);\n                // Test if ray even intersects\n                if(intersection.x != 0.0) {\n                    // Calculate intersection point\n                    hit = Hit(intersection, i);\n                    // Update maximum object distance for future rays\n                    min_len = intersection.x;\n                }\n            }\n            default: {\n                continue;\n            }\n        }\n    }\n    // Tested all triangles, but there is no intersection\n    return hit;\n}\n\n// Simplified rayTracer to only test if ray intersects anything\nfn shadowTest(ray: Ray, l: f32) -> bool {\n    // Cache transformed ray attributes\n    var t_ray: Ray = Ray(ray.origin, ray.unit_direction);\n    // Inverse of transformed normalized ray\n    var cached_t_i: i32 = 0;\n    // Precomput max length\n    let min_len: f32 = l;\n    // Get texture size as max iteration value\n    let size: i32 = i32(arrayLength(&geometry)) / 12;\n    // Iterate through lines of texture\n    for (var i: i32 = 0; i < size; i++) {\n        // Get position of current triangle/vertex in geometryTex\n        let index: i32 = i * 12;\n        // Fetch triangle coordinates from scene graph\n        let a = vec3<f32>(geometry[index    ], geometry[index + 1], geometry[index + 2]);\n        let b = vec3<f32>(geometry[index + 3], geometry[index + 4], geometry[index + 5]);\n        let c = vec3<f32>(geometry[index + 6], geometry[index + 7], geometry[index + 8]);\n\n        let t_i: i32 = i32(geometry[index + 9]) << 1u;\n        // Test if cached transformed variables are still valid\n        if (t_i != cached_t_i) {\n            let i_i: i32 = t_i + 1;\n            cached_t_i = t_i;\n            let i_transform = transforms[i_i];\n            t_ray = Ray(\n                i_transform.rotation * (ray.origin + i_transform.shift),\n                normalize(i_transform.rotation * ray.unit_direction)\n            );\n        }\n        // Three cases:\n        // indicator = 0        => end of list: stop loop\n        // indicator = 1        => is bounding volume: do AABB intersection test\n        // indicator = 2        => is triangle: do triangle intersection test\n        switch i32(geometry[index + 10]) {\n            case 0 {\n                return false;\n            }\n            case 1: {\n                if(!rayCuboid(a, b, t_ray, min_len)) {\n                    i += i32(c.x);\n                }\n            }\n            case 2: {\n                let triangle: mat3x3<f32> = mat3x3<f32>(a, b, c);\n                // Test for triangle intersection in positive light ray direction\n                if(moellerTrumboreCull(triangle, t_ray, min_len)) {\n                    return true;\n                }\n            }\n            default: {\n                continue;\n            }\n        }\n    }\n    // Tested all triangles, but there is no intersection\n    return false;\n}\n\nfn trowbridgeReitz(alpha: f32, n_dot_h: f32) -> f32 {\n    let numerator: f32 = alpha * alpha;\n    let denom: f32 = n_dot_h * n_dot_h * (numerator - 1.0f) + 1.0f;\n    return numerator / max(PI * denom * denom, BIAS);\n}\n\nfn schlickBeckmann(alpha: f32, n_dot_x: f32) -> f32 {\n    let k: f32 = alpha * 0.5f;\n    let denom: f32 = max(n_dot_x * (1.0f - k) + k, BIAS);\n    return n_dot_x / denom;\n}\n\nfn smith(alpha: f32, n_dot_v: f32, n_dot_l: f32) -> f32 {\n    return schlickBeckmann(alpha, n_dot_v) * schlickBeckmann(alpha, n_dot_l);\n}\n\nfn fresnel(f0: vec3<f32>, theta: f32) -> vec3<f32> {\n    // Use Schlick approximation\n    return f0 + (1.0f - f0) * pow(1.0f - theta, 5.0f);\n}\n\n\nfn forwardTrace(material: Material, light_dir: vec3<f32>, strength: f32, n: vec3<f32>, v: vec3<f32>) -> vec3<f32> {\n    let len_p1: f32 = 1.0f + length(light_dir);\n    // Apply inverse square law\n    let brightness: f32 = strength / (len_p1 * len_p1);\n\n    let l: vec3<f32> = normalize(light_dir);\n    let h: vec3<f32> = normalize(v + l);\n\n    let v_dot_h: f32 = max(dot(v, h), 0.0f);\n    let n_dot_l: f32 = max(dot(n, l), 0.0f);\n    let n_dot_h: f32 = max(dot(n, h), 0.0f);\n    let n_dot_v: f32 = max(dot(n, v), 0.0f);\n\n    let alpha: f32 = material.rme.x * material.rme.x;\n    let brdf: f32 = mix(1.0f, n_dot_v, material.rme.y);\n    let f0: vec3<f32> = material.albedo * brdf;\n\n    let ks: vec3<f32> = fresnel(f0, v_dot_h);\n    let kd: vec3<f32> = (1.0f - ks) * (1.0f - material.rme.y);\n    let lambert: vec3<f32> = material.albedo * INV_PI;\n\n    let cook_torrance_numerator: vec3<f32> = ks * trowbridgeReitz(alpha, n_dot_h) * smith(alpha, n_dot_v, n_dot_l);\n    let cook_torrance_denominator: f32 = max(4.0f * n_dot_v * n_dot_l, BIAS);\n\n    let cook_torrance: vec3<f32> = cook_torrance_numerator / cook_torrance_denominator;\n    let radiance: vec3<f32> = kd * lambert + cook_torrance;\n\n    // Outgoing light to camera\n    return radiance * n_dot_l * brightness;\n}\n\nfn reservoirSample(material: Material, ray: Ray, random_vec: vec4<f32>, rough_n: vec3<f32>, smooth_n: vec3<f32>, geometry_offset: f32, dont_filter: bool, i: i32) -> vec3<f32> {\n    var local_color: vec3<f32> = vec3<f32>(0.0f);\n    var reservoir_length: f32 = 0.0f;\n    var total_weight: f32 = 0.0f;\n    var reservoir_num: i32 = 0;\n    var reservoir_weight: f32 = 0.0f;\n    var reservoir_light_pos: vec3<f32>;\n    var reservoir_light_dir: vec3<f32>;\n    var last_random: vec2<f32> = noise(random_vec.zw, BIAS).xy;\n\n    let size: i32 = i32(arrayLength(&lights));\n    for (var j: i32 = 0; j < size; j++) {\n        // Read light from storage buffer\n        var light: Light = lights[j];\n        // Skip if strength is negative or zero\n        if (light.strength_variation.x <= 0.0f) {\n            continue;\n        }\n        // Increment light weight\n        reservoir_length += 1.0f;\n        // Alter light source position according to variation.\n        light.position += random_vec.xyz * light.strength_variation.y;\n        let dir: vec3<f32> = light.position - ray.origin;\n\n        let color_for_light: vec3<f32> = forwardTrace(material, dir, light.strength_variation.x, rough_n, - ray.unit_direction);\n\n        local_color += color_for_light;\n        let weight: f32 = length(color_for_light);\n\n        total_weight += weight;\n        if (abs(last_random.y) * total_weight <= weight) {\n            reservoir_num = j;\n            reservoir_weight = weight;\n            reservoir_light_pos = light.position;\n            reservoir_light_dir = dir;\n        }\n        // Update pseudo random variable.\n        last_random = noise(last_random, BIAS).zw;\n    }\n\n    let unit_light_dir: vec3<f32> = normalize(reservoir_light_dir);\n    // Compute quick exit criterion to potentially skip expensive shadow test\n    let show_color: bool = reservoir_length == 0.0f || reservoir_weight == 0.0f;\n    let show_shadow: bool = dot(smooth_n, unit_light_dir) <= BIAS;\n    // Apply emissive texture and ambient light\n    let base_luminance: vec3<f32> = vec3<f32>(material.rme.z) * material.albedo;\n    // Test if in shadow\n    if (show_color) {\n        return local_color + base_luminance;\n    }\n\n    if (show_shadow) {\n        return base_luminance;\n    }\n    // Apply geometry offset\n    let offset_target: vec3<f32> = ray.origin + geometry_offset * smooth_n;\n    let light_ray: Ray = Ray(offset_target, unit_light_dir);\n\n    if (shadowTest(light_ray, length(reservoir_light_dir))) {\n        return base_luminance;\n    } else {\n        return local_color + base_luminance;\n    }\n}\n\nfn lightTrace(init_hit: Hit, origin: vec3<f32>, camera: vec3<f32>, clip_space: vec2<f32>, cos_sample_n: f32, bounces: i32) -> vec3<f32> {\n    // Set bool to false when filter becomes necessary\n    var dont_filter: bool = true;\n    // Use additive color mixing technique, so start with black\n    var final_color: vec3<f32> = vec3<f32>(0.0f);\n    var importancy_factor: vec3<f32> = vec3(1.0f);\n    // originalColor = vec3(1.0f);\n    var hit: Hit = init_hit;\n    var ray: Ray = Ray(camera, normalize(origin - camera));\n    var last_hit_point: vec3<f32> = camera;\n    // Iterate over each bounce and modify color accordingly\n    for (var i: i32 = 0; i < bounces && length(importancy_factor/* * originalColor*/) >= uniforms.min_importancy * SQRT3; i++) {\n        let index_g: i32 = hit.triangle_id * 12;\n        // Fetch triangle coordinates from scene graph texture\n        let relative_t: mat3x3<f32> = mat3x3<f32>(\n            geometry[index_g    ], geometry[index_g + 1], geometry[index_g + 2],\n            geometry[index_g + 3], geometry[index_g + 4], geometry[index_g + 5],\n            geometry[index_g + 6], geometry[index_g + 7], geometry[index_g + 8]\n        );\n\n        let transform: Transform = transforms[i32(geometry[index_g + 9]) << 1];\n        // Transform triangle\n        let t: mat3x3<f32> = transform.rotation * relative_t;\n        // Transform hit point\n        ray.origin = hit.suv.x * ray.unit_direction + ray.origin;\n        let offset_ray_target: vec3<f32> = ray.origin - transform.shift;\n\n        let geometry_n: vec3<f32> = normalize(cross(t[0] - t[1], t[0] - t[2]));\n        let diffs: vec3<f32> = vec3<f32>(\n            distance(offset_ray_target, t[0]),\n            distance(offset_ray_target, t[1]),\n            distance(offset_ray_target, t[2])\n        );\n        // Fetch scene texture data\n        let index_s: i32 = hit.triangle_id * 28;\n        // Pull normals\n        let normals: mat3x3<f32> = transform.rotation * mat3x3<f32>(\n            scene[index_s    ], scene[index_s + 1], scene[index_s + 2],\n            scene[index_s + 3], scene[index_s + 4], scene[index_s + 5],\n            scene[index_s + 6], scene[index_s + 7], scene[index_s + 8]\n        );\n        // Calculate barycentric coordinates\n        let uvw: vec3<f32> = vec3(1.0 - hit.suv.y - hit.suv.z, hit.suv.y, hit.suv.z);\n        // Interpolate smooth normal\n        var smooth_n: vec3<f32> = normalize(normals * uvw);\n        // to prevent unnatural hard shadow / reflection borders due to the difference between the smooth normal and geometry\n        let angles: vec3<f32> = acos(abs(geometry_n * normals));\n        let angle_tan: vec3<f32> = clamp(tan(angles), vec3<f32>(0.0f), vec3<f32>(1.0f));\n        let geometry_offset: f32 = dot(diffs * angle_tan, uvw);\n        // Interpolate final barycentric texture coordinates between UV's of the respective vertices\n        let barycentric: vec2<f32> = mat3x2<f32>(\n            scene[index_s + 9 ], scene[index_s + 10], scene[index_s + 11],\n            scene[index_s + 12], scene[index_s + 13], scene[index_s + 14]\n        ) * uvw;\n        // Gather material attributes (albedo, roughness, metallicity, emissiveness, translucency, partical density and optical density aka. IOR) out of world texture\n        let tex_num: vec3<f32>          = vec3<f32>(scene[index_s + 15], scene[index_s + 16], scene[index_s + 17]);\n\n        let albedo_default: vec3<f32>   = vec3<f32>(scene[index_s + 18], scene[index_s + 19], scene[index_s + 20]);\n        let rme_default: vec3<f32>      = vec3<f32>(scene[index_s + 21], scene[index_s + 22], scene[index_s + 23]);\n        let tpo_default: vec3<f32>      = vec3<f32>(scene[index_s + 24], scene[index_s + 25], scene[index_s + 26]);\n\n        let material: Material = Material (\n            fetchTexVal(texture_atlas, barycentric, tex_num.x, albedo_default),\n            fetchTexVal(pbr_atlas, barycentric, tex_num.y, rme_default),\n            fetchTexVal(translucency_atlas, barycentric, tex_num.z, tpo_default),\n        );\n        \n        ray = Ray(ray.origin, normalize(ray.origin - last_hit_point));\n        // If ray reflects from inside or onto an transparent object,\n        // the surface faces in the opposite direction as usual\n        var sign_dir: f32 = sign(dot(ray.unit_direction, smooth_n));\n        smooth_n *= - sign_dir;\n\n        // Generate pseudo random vector\n        let fi: f32 = f32(i);\n        let random_vec: vec4<f32> = noise(clip_space.xy * length(ray.origin - last_hit_point), fi + cos_sample_n * PHI);\n        let random_spheare_vec: vec3<f32> = normalize(smooth_n + normalize(random_vec.xyz));\n        let brdf: f32 = mix(1.0f, abs(dot(smooth_n, ray.unit_direction)), material.rme.y);\n\n        // Alter normal according to roughness value\n        let roughness_brdf: f32 = material.rme.x * brdf;\n        let rough_n: vec3<f32> = normalize(mix(smooth_n, random_spheare_vec, roughness_brdf));\n\n        let h: vec3<f32> = normalize(rough_n - ray.unit_direction);\n        let v_dot_h = max(dot(- ray.unit_direction, h), 0.0f);\n        let f0: vec3<f32> = material.albedo * brdf;\n        let f: vec3<f32> = fresnel(f0, v_dot_h);\n\n        let fresnel_reflect: f32 = max(f.x, max(f.y, f.z));\n        // object is solid or translucent by chance because of the fresnel effect\n        let is_solid: bool = material.tpo.x * fresnel_reflect <= abs(random_vec.w);\n        // Test if filter is already necessary\n        // if (i == 1) firstRayLength = min(length(ray.origin - lastHitPoint) / length(lastHitPoint - camera), firstRayLength);\n        // Determine local color considering PBR attributes and lighting\n        let local_color: vec3<f32> = reservoirSample(material, ray, random_vec, - sign_dir * rough_n, - sign_dir * smooth_n, geometry_offset, dont_filter, i);\n        // Calculate primary light sources for this pass if ray hits non translucent object\n        final_color += local_color * importancy_factor;\n\n        // Multiply albedo with either absorption value or filter color\n        /*\n        if (dont_filter) {\n            // Update last used tpo.x value\n            // originalTPOx = material.tpo.x;\n            originalColor *= material.albedo;\n            // Add filtering intensity for respective surface\n            // originalRMEx += material.rme.x;\n            // Update render id\n            vec4 renderIdUpdate = pow(2.0f, - fi) * vec4(combineNormalRME(smoothNormal, material.rme), 0.0f);\n\n            renderId += renderIdUpdate;\n            if (i == 0) renderOriginalId += renderIdUpdate;\n            // Update dontFilter variable\n            dont_filter = (material.rme.x < 0.01f && isSolid) || !isSolid;\n\n            if(is_solid && material.tpo.x != 0.0f) {\n                // glassFilter += 1.0f;\n                dont_filter = false;\n            }\n        }\n        */\n        importancy_factor = importancy_factor * material.albedo;\n        // forwardTrace(material: Material, light_dir: vec3<f32>, strength: f32, n: vec3<f32>, v: vec3<f32>)\n        // importancy_factor = importancy_factor * forwardTrace(material, - old_ray_unit_dir, 4.0f, smooth_n, ray.unit_direction);\n        // Handle translucency and skip rest of light calculation\n        if(is_solid) {\n            // Calculate reflecting ray\n            ray.unit_direction = normalize(mix(reflect(ray.unit_direction, smooth_n), random_spheare_vec, roughness_brdf));\n        } else {\n            let eta: f32 = mix(1.0f / material.tpo.z, material.tpo.z, max(sign_dir, 0.0f));\n            // Refract ray depending on IOR (material.tpo.z)\n            ray.unit_direction = normalize(mix(refract(ray.unit_direction, smooth_n, eta), random_spheare_vec, roughness_brdf));\n        }\n        // Calculate next intersection\n        hit = rayTracer(ray);\n        // Stop loop if there is no intersection and ray goes in the void\n        if (hit.triangle_id == - 1) {\n            break;\n            // return final_color + importancy_factor * uniforms.ambient;\n        }\n        // Update other parameters\n        last_hit_point = ray.origin;\n    }\n    // Return final pixel color\n    return final_color + importancy_factor * uniforms.ambient;\n}\n\n@compute\n@workgroup_size(8, 8)\nfn compute(\n    @builtin(workgroup_id) workgroup_id : vec3<u32>,\n    @builtin(local_invocation_id) local_invocation_id : vec3<u32>,\n    @builtin(global_invocation_id) global_invocation_id : vec3<u32>,\n    @builtin(local_invocation_index) local_invocation_index: u32,\n    @builtin(num_workgroups) num_workgroups: vec3<u32>\n) {\n    // Get texel position of screen\n    let screen_pos: vec2<u32> = global_invocation_id.xy;//local_invocation_id.xy + (workgroup_id.xy * 16u);\n    let buffer_index: u32 = global_invocation_id.x + u32(uniforms.render_size.x) * global_invocation_id.y;\n    // Get based clip space coordinates (with 0.0 at upper left corner)\n    // Load attributes from fragment shader out ofad(texture_triangle_id, screen_pos).x;\n    let triangle_id: i32 = triangle_id_buffer[buffer_index];\n\n    if (triangle_id == 0) {\n        // If there is no triangle render ambient color \n        textureStore(compute_out, screen_pos, 0, vec4<f32>(uniforms.ambient, 1.0f));\n        // And overwrite position with 0 0 0 0\n        if (uniforms.is_temporal == 1.0f) {\n            // Amount of temporal passes\n            // let depth: u32 = textureNumLayers(compute_out) / 2;\n            // Store position in target\n            textureStore(compute_out, screen_pos, 1, vec4<f32>(0.0f));\n        }\n        return;\n    }\n\n    let absolute_position: vec3<f32> = textureLoad(texture_absolute_position, screen_pos, 0).xyz;\n    let uv: vec2<f32> = textureLoad(texture_uv, screen_pos, 0).xy;\n\n    let clip_space: vec2<f32> = vec2<f32>(screen_pos) / vec2<f32>(num_workgroups.xy * 8u);\n    \n    let uvw: vec3<f32> = vec3<f32>(uv, 1.0f - uv.x - uv.y);\n    // Generate hit struct for pathtracer\n    let init_hit: Hit = Hit(vec3<f32>(distance(absolute_position, uniforms.camera_position), uvw.yz), triangle_id);\n\n    var final_color = vec3<f32>(0.0f);\n    // Generate multiple samples\n    for(var i: i32 = 0; i < i32(uniforms.samples); i++) {\n        // Use cosine as noise in random coordinate picker\n        let cos_sample_n = cos(f32(i));\n        final_color += lightTrace(init_hit, absolute_position, uniforms.camera_position, clip_space, cos_sample_n, i32(uniforms.max_reflections));\n    }\n    // Average ray colors over samples.\n    let inv_samples: f32 = 1.0f / uniforms.samples;\n    final_color *= inv_samples;\n\n    // Write to additional textures for temporal pass\n    if (uniforms.is_temporal == 1.0f) {\n        // Render to compute target\n        textureStore(compute_out, screen_pos, 0, vec4<f32>(final_color, 1.0f));\n        // Store position in target\n        textureStore(compute_out, screen_pos, 1, vec4<f32>(absolute_position, 1.0f));\n    } else {\n        // Render to compute target\n        textureStore(compute_out, screen_pos, 0, vec4<f32>(final_color, 1.0f));\n    }\n}";

// src/flexlight/webgpu/shaders/pathtracer-selective-average.wgsl
var pathtracer_selective_average_default = "const PI: f32 = 3.141592653589793;\nconst POW32U: u32 = 4294967295u;\nconst SQRT3: f32 = 1.7320508075688772;\nconst BIAS: f32 = 0.0000152587890625;\nconst INV_1023: f32 = 0.0009775171065493646;\n\n/*\nconst YUV_MATRIX: mat3x3<f32> = mat3x3<f32>(\n    0.299,      0.587,     0.114,\n  - 0.14713,  - 0.28886,   0.436,\n    0.615,    - 0.51499, - 0.10001\n);\n*/\n\nstruct Uniforms {\n    view_matrix: mat3x3<f32>,\n    view_matrix_jitter: mat3x3<f32>,\n\n    camera_position: vec3<f32>,\n    ambient: vec3<f32>,\n\n    texture_size: vec2<f32>,\n    render_size: vec2<f32>,\n\n    samples: f32,\n    max_reflections: f32,\n    min_importancy: f32,\n    use_filter: f32,\n\n    tonemapping_operator: f32,\n    is_temporal: f32,\n    temporal_count: f32,\n    temporal_max: f32\n};\n\n@group(0) @binding(0) var compute_out: texture_2d_array<f32>;\n@group(0) @binding(1) var shift_out: texture_2d_array<f32>;\n@group(0) @binding(2) var accumulated: texture_storage_2d_array<rgba32float, write>;\n\n@group(1) @binding(0) var<uniform> uniforms: Uniforms;\n\n@compute\n@workgroup_size(8, 8)\nfn compute(\n    @builtin(workgroup_id) workgroup_id : vec3<u32>,\n    @builtin(local_invocation_id) local_invocation_id : vec3<u32>,\n    @builtin(global_invocation_id) global_invocation_id : vec3<u32>,\n    @builtin(local_invocation_index) local_invocation_index: u32,\n    @builtin(num_workgroups) num_workgroups: vec3<u32>\n) {\n    // Get texel position of screen\n    let screen_pos: vec2<u32> = global_invocation_id.xy;\n    if (screen_pos.x > u32(uniforms.render_size.x) || screen_pos.y > u32(uniforms.render_size.y)) {\n        return;\n    }\n\n    // Get current color and position.\n    let color_cur: vec4<f32> = textureLoad(compute_out, screen_pos, 0, 0);\n    let position_cur: vec4<f32> = textureLoad(compute_out, screen_pos, 1, 0);\n\n    // Map postion according to current camera positon and view matrix to clip space\n    let clip_space: vec3<f32> = uniforms.view_matrix * (position_cur.xyz - uniforms.camera_position);\n    // Project onto screen and shift origin to the corner\n    let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5 + 0.5;\n    // Translate to texel value\n    var coord: vec2<u32> = vec2<u32>(\n        u32((uniforms.render_size.x * screen_space.x)),\n        u32((uniforms.render_size.y * (1.0f - screen_space.y)))\n    );\n\n    // Extract 3d position value\n    let fine_color_acc: vec4<f32> = textureLoad(shift_out, coord, 0, 0);\n    let coarse_color_acc: vec4<f32> = textureLoad(shift_out, coord, 1, 0);\n    let fine_color_low_variance_acc: vec4<f32> = textureLoad(shift_out, coord, 2, 0);\n    let coarse_color_low_variance_acc: vec4<f32> = textureLoad(shift_out, coord, 3, 0);\n    let position_old: vec4<f32> = textureLoad(shift_out, coord, 4, 0);\n    \n    // If absolute position is all zeros then there is nothing to do\n    let dist: f32 = distance(position_cur.xyz, position_old.xyz);\n    let cur_depth: f32 = distance(position_cur.xyz, uniforms.camera_position.xyz);\n    // let norm_color_diff = dot(normalize(current_color.xyz), normalize(accumulated_color.xyz));\n\n    let croped_cur_color: vec3<f32> = min(color_cur.xyz, vec3<f32>(1.0f));\n\n    var fine_color: vec4<f32> = color_cur;\n    var fine_color_low_variance: vec3<f32> = croped_cur_color;\n    var fine_count: f32 = 0.0f;\n\n    var coarse_color: vec4<f32> = color_cur;\n    var coarse_color_low_variance: vec3<f32> = croped_cur_color;\n    var coarse_count: f32 = 0.0f;\n\n    let is_pos = position_cur.x != 0.0f || position_cur.y != 0.0f || position_cur.z != 0.0f || position_cur.w != 0.0f;\n\n    \n    let last_frame = position_old.w == uniforms.temporal_count;\n    \n    if (\n        dist <= cur_depth * 8.0f / uniforms.render_size.x\n        && last_frame \n        && is_pos \n    ) {\n        // Add color to total and increase counter by one\n        fine_count = min(fine_color_low_variance_acc.w + 1.0f, 32.0f);\n        fine_color = mix(fine_color_acc, color_cur, 1.0f / fine_count);\n        fine_color_low_variance = mix(fine_color_low_variance_acc.xyz, croped_cur_color, 1.0f / fine_count);\n        coarse_count = min(coarse_color_low_variance_acc.w + 1.0f, 4.0f);\n        coarse_color = mix(coarse_color_acc, color_cur, 1.0f / coarse_count);\n        coarse_color_low_variance = mix(coarse_color_low_variance_acc.xyz, croped_cur_color, 1.0f / coarse_count);\n\n\n        let low_variance_color_length: f32 = (length(fine_color_low_variance) + length(coarse_color_low_variance)) * 0.5f;\n\n        // If the color is not stable enough, use the coarse color\n        if (\n            dot(normalize(fine_color_low_variance + BIAS), normalize(coarse_color_low_variance + BIAS)) < cos(PI * 0.125)\n            || abs(length(fine_color_low_variance) - length(coarse_color_low_variance)) > low_variance_color_length\n        ) {\n            // If the color is not stable enough, use the coarse color\n            fine_color = coarse_color;\n            fine_color_low_variance = coarse_color_low_variance;\n            fine_count = coarse_count;\n        }\n        \n        \n    }\n\n    // Write to accumulated buffer\n    textureStore(accumulated, coord, 0, fine_color);\n    textureStore(accumulated, coord, 1, coarse_color);\n    textureStore(accumulated, coord, 2, vec4<f32>(fine_color_low_variance, fine_count));\n    textureStore(accumulated, coord, 3, vec4<f32>(coarse_color_low_variance, coarse_count));\n    textureStore(accumulated, coord, 4, vec4<f32>(position_cur.xyz, (uniforms.temporal_count + 1.0f) % uniforms.temporal_max));\n}";

// src/flexlight/webgpu/shaders/pathtracer-reproject.wgsl
var pathtracer_reproject_default = "const POW32U: u32 = 4294967295u;\nconst POW24F: f32 = 16777216.0f;\nconst SQRT2: f32 = 1.4142135623730951f;\n\nstruct Uniforms {\n    view_matrix: mat3x3<f32>,\n    view_matrix_jitter: mat3x3<f32>,\n\n    camera_position: vec3<f32>,\n    ambient: vec3<f32>,\n\n    texture_size: vec2<f32>,\n    render_size: vec2<f32>,\n\n    samples: f32,\n    max_reflections: f32,\n    min_importancy: f32,\n    use_filter: f32,\n\n    tonemapping_operator: f32,\n    is_temporal: f32,\n    temporal_count: f32,\n    temporal_max: f32\n};\n\n@group(0) @binding(0) var accumulated: texture_2d_array<f32>;\n@group(0) @binding(1) var canvas_in: texture_storage_2d<rgba32float, write>;\n// @group(0) @binding(1) var<storage, read_write> buffer_out: array<atomic<u32>>;\n\n@group(1) @binding(0) var<uniform> uniforms: Uniforms;\n\n// atomicStore(atomic_ptr: ptr<AS, atomic<T>, read_write>, v: T)\n\n/*\n\nfn store_atomic(pos: vec2<u32>, val: vec4<f32>) {\n    let b_pos: u32 = (pos.x + u32(uniforms.render_size.x) * pos.y) * 4u;\n    // Spread out the float values over the range of u32.\n    let u32vals: vec4<u32> = vec4<u32>(val * POW24F);\n    // Store the u32 values.\n    atomicStore(&buffer_out[b_pos], u32vals.x);\n    atomicStore(&buffer_out[b_pos + 1], u32vals.y);\n    atomicStore(&buffer_out[b_pos + 2], u32vals.z);\n    atomicStore(&buffer_out[b_pos + 3], u32vals.w);\n}\n\nfn add_atomic(pos: vec2<u32>, val: vec4<f32>) {\n    let b_pos: u32 = (pos.x + u32(uniforms.render_size.x) * pos.y) * 4u;\n    // Spread out the float values over the range of u32.\n    let u32vals: vec4<u32> = vec4<u32>(val * POW24F);\n    // Store the u32 values.\n    atomicAdd(&buffer_out[b_pos], u32vals.x);\n    atomicAdd(&buffer_out[b_pos + 1], u32vals.y);\n    atomicAdd(&buffer_out[b_pos + 2], u32vals.z);\n    atomicAdd(&buffer_out[b_pos + 3], u32vals.w);\n}\n\nfn interpolate_store(pos: vec2<f32>, val: vec4<f32>) {\n    let pos_fract: vec2<f32> = fract(pos);\n    let pos_u32: vec2<u32> = vec2<u32>(pos);\n\n    let offsets = mat4x2<f32>(\n        vec2<f32>(0.0f, 0.0f),\n        vec2<f32>(1.0f, 0.0f),\n        vec2<f32>(0.0f, 1.0f),\n        vec2<f32>(1.0f, 1.0f)\n    );\n\n    let distances: vec4<f32> = max(1.0f - vec4<f32>(\n        length(offsets[0] - pos_fract),\n        length(offsets[1] - pos_fract),\n        length(offsets[2] - pos_fract),\n        length(offsets[3] - pos_fract)\n    ), vec4<f32>(0.0f));\n\n    let weights: vec4<f32> = distances / (distances.x + distances.y + distances.z + distances.w);\n\n    // let positions: mat4x2<u32> = pos_u32 + mat4x2<u32>(offsets);\n\n    add_atomic(pos_u32 + vec2<u32>(offsets[0]), val * weights.x);\n    add_atomic(pos_u32 + vec2<u32>(offsets[1]), val * weights.y);\n    add_atomic(pos_u32 + vec2<u32>(offsets[2]), val * weights.z);\n    add_atomic(pos_u32 + vec2<u32>(offsets[3]), val * weights.w);\n}\n*/\n\n@compute\n@workgroup_size(8, 8)\nfn compute(\n    @builtin(workgroup_id) workgroup_id : vec3<u32>,\n    @builtin(local_invocation_id) local_invocation_id : vec3<u32>,\n    @builtin(global_invocation_id) global_invocation_id : vec3<u32>,\n    @builtin(local_invocation_index) local_invocation_index: u32,\n    @builtin(num_workgroups) num_workgroups: vec3<u32>\n) {\n    // Skip if texel is out of bounds\n    if (global_invocation_id.x > u32(uniforms.render_size.x) || global_invocation_id.y > u32(uniforms.render_size.y)) {\n        return;\n    }\n    \n    // Get texel position of screen\n    let screen_pos: vec2<u32> = global_invocation_id.xy;\n    // Extract color value from old position\n    var color: vec4<f32> = textureLoad(accumulated, screen_pos, 0, 0);\n    // Extract 3d position value\n    let position_cur: vec4<f32> = textureLoad(accumulated, screen_pos, 4, 0);\n    // If data is not from last frame write ambient color\n    if (position_cur.w != (uniforms.temporal_count + 1.0f) % uniforms.temporal_max) {\n        textureStore(canvas_in, screen_pos, vec4<f32>(uniforms.ambient, 1.0f));\n        return;\n    }\n\n    if (uniforms.is_temporal == 1.0f) {\n        // Reproject position to jitter if temporal is enabled\n        let clip_space: vec3<f32> = uniforms.view_matrix_jitter * (position_cur.xyz - uniforms.camera_position);\n        let screen_space: vec2<f32> = (clip_space.xy / clip_space.z) * 0.5 + 0.5;\n\n        let canvas_pos: vec2<u32> = vec2<u32>(\n            u32(uniforms.render_size.x * screen_space.x),\n            u32(uniforms.render_size.y * (1.0f - screen_space.y))\n        );\n\n        textureStore(canvas_in, canvas_pos, color);\n    } else {\n        // Write straight to canvas.\n        textureStore(canvas_in, screen_pos, color);\n    }\n}";

// src/flexlight/webgpu/shaders/canvas.wgsl
var canvas_default = "const POW32U: u32 = 4294967295u;\n\nstruct Uniforms {\n    view_matrix: mat3x3<f32>,\n    inv_view_matrix: mat3x3<f32>,\n\n    camera_position: vec3<f32>,\n    ambient: vec3<f32>,\n\n    texture_size: vec2<f32>,\n    render_size: vec2<f32>,\n\n    samples: f32,\n    max_reflections: f32,\n    min_importancy: f32,\n    use_filter: f32,\n\n    tonemapping_operator: f32,\n    is_temporal: f32,\n    temporal_target: f32\n};\n\n@group(0) @binding(0) var compute_out: texture_2d<f32>;\n@group(0) @binding(1) var canvas_out: texture_storage_2d<rgba8unorm, write>;\n\n@group(1) @binding(0) var<uniform> uniforms: Uniforms;\n\n@compute\n@workgroup_size(8, 8)\nfn compute(\n    @builtin(workgroup_id) workgroup_id : vec3<u32>,\n    @builtin(local_invocation_id) local_invocation_id : vec3<u32>,\n    @builtin(global_invocation_id) global_invocation_id : vec3<u32>,\n    @builtin(local_invocation_index) local_invocation_index: u32,\n    @builtin(num_workgroups) num_workgroups: vec3<u32>\n) {\n    // Get texel position of screen\n    let screen_pos: vec2<u32> = global_invocation_id.xy;\n    if (screen_pos.x > u32(uniforms.render_size.x) || screen_pos.y > u32(uniforms.render_size.y)) {\n        return;\n    }\n\n    let buffer_index: u32 = global_invocation_id.x + num_workgroups.x * 8u * global_invocation_id.y;\n\n    let compute_texel: vec4<f32> = textureLoad(compute_out, screen_pos, 0);\n    var compute_color: vec3<f32> = compute_texel.xyz;\n\n    if (uniforms.tonemapping_operator == 1.0f) {\n        // Apply Reinhard tone mapping\n        compute_color = compute_color / (compute_color + vec3<f32>(1.0f));\n        // Gamma correction\n        // let gamma: f32 = 0.8f;\n        // compute_color = pow(4.0f * compute_color, vec3<f32>(1.0f / gamma)) / 4.0f * 1.3f;\n    }\n\n    // Write final color to canvas\n    textureStore(canvas_out, screen_pos, vec4<f32>(compute_color, compute_texel.w));\n}";

// src/flexlight/webgpu/pathtracer.js
var rasterRenderFormats = ["rgba32float", "rg32float"];
var POW32U = 2 ** 32 - 1;
var TEMPORAL_MAX = 2 ** 23 - 1;
var PathTracerWGPU = class extends Renderer {
  type = "pathtracer";
  // Configurable runtime properties of the pathtracer (public attributes)
  config;
  // Performance metric
  fps = 0;
  fpsLimit = Infinity;
  // Make context object accessible for all functions
  #canvas;
  #context;
  #adapter;
  device;
  #preferedCanvasFormat;
  #depthPipeline;
  #rasterPipeline;
  #computePipeline;
  #shiftPipeline;
  #temporalPipeline;
  #reprojectPipeline;
  #canvasPipeline;
  #renderPassDescriptor;
  #staticBuffers;
  #dynamicBuffers;
  #uniformBuffer;
  #transformBuffer;
  #depthBuffer;
  #triangleIdBuffer;
  #rasterRenderTextures = [];
  #temporalIn;
  #shiftTarget;
  #accumulatedTarget;
  #shiftLock;
  #canvasIn;
  #depthGroupLayout;
  #rasterRenderGroupLayout;
  #computeRenderGroupLayout;
  #rasterDynamicGroupLayout;
  #computeDynamicGroupLayout;
  #rasterStaticGroupLayout;
  #computeStaticGroupLayout;
  #postDynamicGroupLayout;
  #shiftGroupLayout;
  #temporalGroupLayout;
  #reprojectGroupLayout;
  // #mapGroupLayout;
  #canvasGroupLayout;
  #depthGroup;
  #rasterRenderGroup;
  #computeRenderGroup;
  #rasterDynamicGroup;
  #computeDynamicGroup;
  #rasterStaticGroup;
  #computeStaticGroup;
  #postDynamicGroup;
  #shiftGroup;
  #temporalGroup;
  #canvasGroup;
  #reprojectGroup;
  #engineState = {};
  #resizeEvent;
  #halt = true;
  #antialiasing;
  #AAObject;
  // Create new PathTracer from canvas and setup movement
  constructor(canvas, scene, camera, config) {
    super(scene);
    this.#canvas = canvas;
    this.camera = camera;
    this.config = config;
    if (!navigator.gpu) return void 0;
  }
  halt = () => {
    this.#halt = true;
    window.removeEventListener("resize", this.#resizeEvent);
  };
  resize() {
    let width = Math.round(this.#canvas.clientWidth * this.config.renderQuality);
    let height = Math.round(this.#canvas.clientHeight * this.config.renderQuality);
    this.#canvas.width = width;
    this.#canvas.height = height;
    let allScreenTextures = [this.#canvasIn, ...this.#rasterRenderTextures];
    if (this.config.temporal) allScreenTextures.push(this.#shiftTarget, this.#temporalIn);
    allScreenTextures.forEach((texture) => {
      try {
        texture.destroy();
      } catch {
      }
    });
    this.#depthBuffer = this.device.createBuffer({ size: height * width * 4, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
    this.#triangleIdBuffer = this.device.createBuffer({ size: height * width * 4, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
    this.#rasterRenderTextures = rasterRenderFormats.map((format) => this.device.createTexture({
      size: [width, height],
      format,
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
    }));
    this.#canvasIn = this.device.createTexture({
      size: [width, height],
      format: "rgba32float",
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
    });
    if (this.config.temporal) {
      this.#temporalIn = this.device.createTexture({
        // dimension: "3d",
        size: [width, height, this.config.temporal ? (
          /*this.config.temporalSamples * 2*/
          2
        ) : 1],
        format: "rgba32float",
        usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
      });
      this.#shiftTarget = this.device.createTexture({
        // dimension: "3d",
        size: [width, height, 5],
        format: "rgba32float",
        usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
      });
      this.#accumulatedTarget = this.device.createTexture({
        // dimension: "3d",
        size: [width, height, 5],
        format: "rgba32float",
        usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
      });
      this.#shiftLock = this.device.createBuffer({ size: width * height * 4, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
      this.device.queue.writeBuffer(this.#shiftLock, 0, new Uint32Array(new Array(width * height).fill(POW32U)));
    }
    if (this.#AAObject) this.#AAObject.createTexture();
  }
  // Make canvas read only accessible
  get canvas() {
    return this.#canvas;
  }
  updateScene(device = this.device) {
    if (!device) return;
    let builtScene = this.scene.generateArraysFromGraph();
    this.#engineState.bufferLength = builtScene.bufferLength;
    let staticBufferArrays = [
      builtScene.idBuffer,
      builtScene.geometryBuffer,
      builtScene.sceneBuffer
    ];
    this.#staticBuffers = staticBufferArrays.map((array) => {
      let buffer = device.createBuffer({ size: array.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
      device.queue.writeBuffer(buffer, 0, array);
      return buffer;
    });
    let staticEntries = this.#staticBuffers.map((buffer, i) => ({ binding: i, resource: { buffer } }));
    this.#rasterStaticGroup = device.createBindGroup({
      label: "static binding group for raster pass",
      layout: this.#rasterStaticGroupLayout,
      entries: staticEntries.slice(0, 2)
    });
    this.#computeStaticGroup = device.createBindGroup({
      label: "static binding group for compute pass",
      layout: this.#computeStaticGroupLayout,
      entries: staticEntries
    });
  }
  async render() {
    if (!this.#halt) {
      console.warn("Renderer already up and running!");
      return;
    }
    this.#context = this.#canvas.getContext("webgpu");
    this.#adapter = await navigator.gpu.requestAdapter();
    this.device = await this.#adapter.requestDevice();
    this.#preferedCanvasFormat = "rgba8unorm";
    this.#context.configure({
      device: this.device,
      format: this.#preferedCanvasFormat,
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
    });
    this.#engineState.intermediateFrames = 0;
    this.#engineState.lastTimeStamp = performance.now();
    this.#engineState.temporalFrame = 0;
    await this.updateTextureAtlas(true);
    await this.updatePbrAtlas(true);
    await this.updateTranslucencyAtlas(true);
    this.#prepareEngine(this.device);
  }
  #prepareEngine(device) {
    this.halt();
    this.#halt = false;
    Object.assign(this.#engineState, {
      // Parameters to compare against current state of the engine and recompile shaders on change
      filter: this.config.filter,
      temporal: this.config.temporal,
      temporalSamples: this.config.temporalSamples,
      renderQuality: this.config.renderQuality,
      // New buffer length
      bufferLength: 0
    });
    this.#depthGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.FRAGMENT, buffer: { type: "storage" } }
        // depth
      ]
    });
    this.#rasterRenderGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.FRAGMENT, buffer: { type: "read-only-storage" } },
        // depth
        { binding: 1, visibility: GPUShaderStage.FRAGMENT, buffer: { type: "storage" } },
        // triangle index
        { binding: 2, visibility: GPUShaderStage.FRAGMENT, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d" } },
        // 3d positions
        { binding: 3, visibility: GPUShaderStage.FRAGMENT, storageTexture: { access: "write-only", format: "rg32float", viewDimension: "2d" } }
        // uvs
      ]
    });
    this.#computeRenderGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d-array" } },
        // output
        { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } },
        //storageTexture: { access: "read-only", format: "r32sint", viewDimension: "2d" } },            // triangle index
        { binding: 2, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float" } },
        //storageTexture: { access: "read-only", format: "rgba32float", viewDimension: "2d" } },        // 3d positions
        { binding: 3, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float" } }
        //storageTexture: { access: "read-only", format: "rg32float", viewDimension: "2d" } }           // uvs
      ]
    });
    this.#rasterStaticGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.VERTEX, buffer: { type: "read-only-storage" } },
        // indices
        { binding: 1, visibility: GPUShaderStage.VERTEX, buffer: { type: "read-only-storage" } }
        // geometry
      ]
    });
    this.#computeStaticGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } },
        // indices
        { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } },
        // geometry
        { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } }
        // scene
      ]
    });
    this.#rasterDynamicGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, buffer: { type: "uniform" } },
        // uniforms
        { binding: 1, visibility: GPUShaderStage.VERTEX, buffer: { type: "read-only-storage" } }
        // transforms
      ]
    });
    this.#computeDynamicGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: "uniform" } },
        // uniforms
        { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } },
        // transforms
        { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } }
        // light sources
      ]
    });
    this.textureGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "uint" } },
        // texture atlas
        { binding: 1, visibility: GPUShaderStage.COMPUTE, texture: { type: "uint" } },
        // pbr texture atlas
        { binding: 2, visibility: GPUShaderStage.COMPUTE, texture: { type: "uint" } }
        // translucency texture atlas
      ]
    });
    if (this.config.temporal) {
      this.#shiftGroupLayout = device.createBindGroupLayout({
        entries: [
          { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float", viewDimension: "2d-array" } },
          { binding: 1, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d-array" } },
          { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "storage" } }
        ]
      });
      this.#temporalGroupLayout = device.createBindGroupLayout({
        entries: [
          { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float", viewDimension: "2d-array" } },
          { binding: 1, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float", viewDimension: "2d-array" } },
          { binding: 2, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d-array" } }
        ]
      });
      this.#reprojectGroupLayout = device.createBindGroupLayout({
        entries: [
          { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float", viewDimension: "2d-array" } },
          { binding: 1, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d" } }
        ]
      });
    }
    this.#postDynamicGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: "uniform" } }
        // uniforms
      ]
    });
    this.#canvasGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float" } },
        //storageTexture: { access: "read-only", format: "rgba32float", viewDimension: "2d" } },  // compute output
        { binding: 1, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba8unorm", viewDimension: "2d" } }
        // canvas target
      ]
    });
    let depthShader = pathtracer_depth_default;
    let depthModule = device.createShaderModule({ code: depthShader });
    this.#depthPipeline = device.createRenderPipeline({
      label: "depth pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: [
        this.#depthGroupLayout,
        this.#rasterStaticGroupLayout,
        this.#rasterDynamicGroupLayout
      ] }),
      // Vertex shader
      vertex: {
        module: depthModule,
        entryPoint: "vertex"
      },
      // Fragment shader
      fragment: {
        module: depthModule,
        entryPoint: "fragment",
        targets: [{ format: "rgba8unorm" }]
      },
      // Culling config
      primitive: {
        topology: "triangle-list",
        cullMode: "back"
      }
    });
    let rasterShader = pathtracer_raster_default;
    let rasterModule = device.createShaderModule({ code: rasterShader });
    this.#rasterPipeline = device.createRenderPipeline({
      label: "raster pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: [
        this.#rasterRenderGroupLayout,
        this.#rasterStaticGroupLayout,
        this.#rasterDynamicGroupLayout
      ] }),
      // Vertex shader
      vertex: {
        module: rasterModule,
        entryPoint: "vertex"
      },
      // Fragment shader
      fragment: {
        module: rasterModule,
        entryPoint: "fragment",
        targets: [{ format: "rgba8unorm" }]
      },
      // Culling config
      primitive: {
        topology: "triangle-list",
        cullMode: "back"
      }
    });
    let computeShader = pathtracer_compute_default;
    let computeModule = device.createShaderModule({ code: computeShader });
    this.#computePipeline = device.createComputePipeline({
      label: "compute pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: [
        this.#computeRenderGroupLayout,
        this.textureGroupLayout,
        this.#computeStaticGroupLayout,
        this.#computeDynamicGroupLayout
      ] }),
      compute: {
        module: computeModule,
        entryPoint: "compute"
      }
    });
    if (this.config.temporal) {
      let shiftShader = pathtracer_shift_default;
      let shiftModule = device.createShaderModule({ code: shiftShader });
      this.#shiftPipeline = device.createComputePipeline({
        label: "shift pipeline",
        layout: device.createPipelineLayout({ bindGroupLayouts: [this.#shiftGroupLayout, this.#postDynamicGroupLayout] }),
        compute: { module: shiftModule, entryPoint: "compute" }
      });
      let selectiveAverageShader = pathtracer_selective_average_default;
      let selectiveAverageModule = device.createShaderModule({ code: selectiveAverageShader });
      this.#temporalPipeline = device.createComputePipeline({
        label: "selective average pipeline",
        layout: device.createPipelineLayout({ bindGroupLayouts: [this.#temporalGroupLayout, this.#postDynamicGroupLayout] }),
        compute: { module: selectiveAverageModule, entryPoint: "compute" }
      });
      let reprojectShader = pathtracer_reproject_default;
      let reprojectModule = device.createShaderModule({ code: reprojectShader });
      this.#reprojectPipeline = device.createComputePipeline({
        label: "reproject pipeline",
        layout: device.createPipelineLayout({ bindGroupLayouts: [this.#reprojectGroupLayout, this.#postDynamicGroupLayout] }),
        compute: { module: reprojectModule, entryPoint: "compute" }
      });
    }
    let canvasShader = canvas_default;
    let canvasModule = device.createShaderModule({ code: canvasShader });
    this.#canvasPipeline = device.createComputePipeline({
      label: "canvas pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: [this.#canvasGroupLayout, this.#postDynamicGroupLayout] }),
      compute: { module: canvasModule, entryPoint: "compute" }
    });
    this.#renderPassDescriptor = {
      // Render passes are given attachments to write into.
      colorAttachments: [{
        // The color the attachment will be cleared to.
        clearValue: [0, 0, 0, 0],
        // Clear the attachment when the render pass starts.
        loadOp: "clear",
        // When the pass is done, save the results in the attachment texture.
        storeOp: "store"
      }]
    };
    this.#uniformBuffer = device.createBuffer({ size: 128 + 4 * 4 * 3, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST });
    this.updateScene(device);
    this.resize();
    this.#resizeEvent = window.addEventListener("resize", () => this.resize());
    requestAnimationFrame(() => this.frameCycle(device));
  }
  // Internal render engine Functions
  frameCycle(device) {
    if (this.#halt) return;
    let timeStamp = performance.now();
    if (this.#engineState.temporal !== this.config.temporal || this.#engineState.temporalSamples !== this.config.temporalSamples || this.#engineState.renderQuality !== this.config.renderQuality) {
      requestAnimationFrame(() => this.#prepareEngine(device));
      return;
    }
    this.updateTextureAtlas();
    this.updatePbrAtlas();
    this.updateTranslucencyAtlas();
    this.updateTextureGroup();
    this.updatePrimaryLightSources();
    if (this.#engineState.antialiasing !== this.config.antialiasing) {
      this.#engineState.antialiasing = this.config.antialiasing;
      let val = this.config.antialiasing.toLowerCase();
      switch (val) {
        case "fxaa":
          this.#antialiasing = val;
          this.#AAObject = new FXAA2(this.device, this.#canvas);
          break;
        case "taa":
          this.#antialiasing = val;
          this.#AAObject = new TAA2(this.device, this.#canvas);
          break;
        default:
          this.#antialiasing = void 0;
          this.#AAObject = void 0;
      }
    }
    this.renderFrame();
    this.#engineState.intermediateFrames++;
    this.#engineState.temporalFrame = (this.#engineState.temporalFrame + 1) % TEMPORAL_MAX;
    let timeDifference = timeStamp - this.#engineState.lastTimeStamp;
    if (timeDifference > 500) {
      this.fps = (1e3 * this.#engineState.intermediateFrames / timeDifference).toFixed(0);
      this.#engineState.lastTimeStamp = timeStamp;
      this.#engineState.intermediateFrames = 0;
    }
    setTimeout(() => {
      requestAnimationFrame(() => this.frameCycle(device));
    }, 1e3 / this.fpsLimit);
  }
  async renderFrame() {
    let jitter = { x: 0, y: 0 };
    if (this.#AAObject && this.#antialiasing === "taa") jitter = this.#AAObject.jitter();
    let dir = { x: this.camera.direction.x, y: this.camera.direction.y };
    let dirJitter = { x: this.camera.direction.x + jitter.x, y: this.camera.direction.y + jitter.y };
    let canvasTarget = this.#context.getCurrentTexture();
    let depthBufferEntry = { binding: 0, resource: { buffer: this.#depthBuffer } };
    let computeTargetView = !this.config.temporal && !this.#AAObject ? this.#canvasIn.createView({ dimension: "2d-array", arrayLayerCount: 1 }) : !this.config.temporal && this.#AAObject ? this.#AAObject.textureInView2dArray : this.#temporalIn.createView({ dimension: "2d-array", arrayLayerCount: 2 });
    this.#depthGroup = this.device.createBindGroup({
      label: "depth buffer for depth testing raster pass",
      layout: this.#depthGroupLayout,
      entries: [depthBufferEntry]
    });
    this.#rasterRenderGroup = this.device.createBindGroup({
      label: "render output group for raster pass",
      layout: this.#rasterRenderGroupLayout,
      entries: [
        depthBufferEntry,
        { binding: 1, resource: { buffer: this.#triangleIdBuffer } },
        ...this.#rasterRenderTextures.map((texture, i) => ({ binding: i + 2, resource: texture.createView() }))
      ]
    });
    this.#computeRenderGroup = this.device.createBindGroup({
      label: "render input group for compute pass",
      layout: this.#computeRenderGroupLayout,
      entries: [
        { binding: 0, resource: computeTargetView },
        { binding: 1, resource: { buffer: this.#triangleIdBuffer } },
        ...this.#rasterRenderTextures.map((texture, i) => ({ binding: i + 2, resource: texture.createView() }))
      ]
    });
    if (this.config.temporal) {
      let temporalTargetView = this.#AAObject ? this.#AAObject.textureInView : this.#canvasIn.createView({ dimension: "2d" });
      this.#shiftGroup = this.device.createBindGroup({
        label: "bind group for motion correction pass",
        layout: this.#shiftGroupLayout,
        entries: [
          { binding: 0, resource: this.#accumulatedTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) },
          { binding: 1, resource: this.#shiftTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) },
          { binding: 2, resource: { buffer: this.#shiftLock } }
        ]
      });
      this.#temporalGroup = this.device.createBindGroup({
        label: "bind group accumulation pass",
        layout: this.#temporalGroupLayout,
        entries: [
          { binding: 0, resource: this.#temporalIn.createView({ dimension: "2d-array", arrayLayerCount: 2 }) },
          { binding: 1, resource: this.#shiftTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) },
          { binding: 2, resource: this.#accumulatedTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) }
        ]
      });
      this.#reprojectGroup = this.device.createBindGroup({
        label: "bind group for reprojection pass",
        layout: this.#reprojectGroupLayout,
        entries: [
          { binding: 0, resource: this.#accumulatedTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) },
          { binding: 1, resource: temporalTargetView }
        ]
      });
    }
    if (this.#AAObject) {
      this.#AAObject.createBindGroup(this.#canvasIn);
    }
    this.#canvasGroup = this.device.createBindGroup({
      label: "render input group for canvas pass",
      layout: this.#canvasGroupLayout,
      entries: [
        { binding: 0, resource: this.#canvasIn.createView({ dimension: "2d" }) },
        { binding: 1, resource: canvasTarget.createView() }
      ]
    });
    this.#renderPassDescriptor.colorAttachments[0].view = canvasTarget.createView();
    let invFov = 1 / this.camera.fov;
    let heightInvWidthFov = this.#canvas.height * invFov / this.#canvas.width;
    let viewMatrix = [
      [Math.cos(dir.x) * heightInvWidthFov, 0, Math.sin(dir.x) * heightInvWidthFov],
      [-Math.sin(dir.x) * Math.sin(dir.y) * invFov, Math.cos(dir.y) * invFov, Math.cos(dir.x) * Math.sin(dir.y) * invFov],
      [-Math.sin(dir.x) * Math.cos(dir.y), -Math.sin(dir.y), Math.cos(dir.x) * Math.cos(dir.y)]
    ];
    let viewMatrixJitter = [
      [Math.cos(dirJitter.x) * heightInvWidthFov, 0, Math.sin(dirJitter.x) * heightInvWidthFov],
      [-Math.sin(dirJitter.x) * Math.sin(dirJitter.y) * invFov, Math.cos(dirJitter.y) * invFov, Math.cos(dirJitter.x) * Math.sin(dirJitter.y) * invFov],
      [-Math.sin(dirJitter.x) * Math.cos(dirJitter.y), -Math.sin(dirJitter.y), Math.cos(dirJitter.x) * Math.cos(dirJitter.y)]
    ];
    if (!this.config.temporal) {
      viewMatrix = viewMatrixJitter;
    }
    let temporalCount = this.config.temporal ? this.#engineState.temporalFrame : 0;
    this.device.queue.writeBuffer(this.#uniformBuffer, 0, new Float32Array([
      // View matrix
      viewMatrix[0][0],
      viewMatrix[1][0],
      viewMatrix[2][0],
      0,
      viewMatrix[0][1],
      viewMatrix[1][1],
      viewMatrix[2][1],
      0,
      viewMatrix[0][2],
      viewMatrix[1][2],
      viewMatrix[2][2],
      0,
      // View matrix inverse
      viewMatrixJitter[0][0],
      viewMatrixJitter[1][0],
      viewMatrixJitter[2][0],
      0,
      viewMatrixJitter[0][1],
      viewMatrixJitter[1][1],
      viewMatrixJitter[2][1],
      0,
      viewMatrixJitter[0][2],
      viewMatrixJitter[1][2],
      viewMatrixJitter[2][2],
      0,
      // Camera
      this.camera.position.x,
      this.camera.position.y,
      this.camera.position.z,
      0,
      // Ambient light
      this.scene.ambientLight[0],
      this.scene.ambientLight[1],
      this.scene.ambientLight[2],
      0,
      // Texture size
      this.scene.standardTextureSizes[0],
      this.scene.standardTextureSizes[1],
      // Render size
      this.canvas.width,
      this.canvas.height,
      // amount of samples per ray
      this.config.samplesPerRay,
      // max reflections of ray
      this.config.maxReflections,
      // min importancy of light ray
      this.config.minImportancy,
      // render for filter or not
      this.config.filter,
      // Tonemapping operator
      this.config.hdr ? 1 : 0,
      // render for temporal or not
      this.config.temporal,
      // Temporal target
      temporalCount,
      // Temporal samples
      TEMPORAL_MAX
    ]));
    let transformArray = Transform.buildWGPUArray();
    this.#transformBuffer = this.device.createBuffer({ size: transformArray.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
    this.device.queue.writeBuffer(this.#transformBuffer, 0, transformArray);
    this.#dynamicBuffers = [this.#uniformBuffer, this.#transformBuffer, this.lightBuffer];
    let dynamicEntries = this.#dynamicBuffers.map((buffer, i) => ({ binding: i, resource: { buffer } }));
    this.#rasterDynamicGroup = this.device.createBindGroup({
      label: "dynamic binding group for raster pass",
      layout: this.#rasterDynamicGroupLayout,
      entries: dynamicEntries.slice(0, 2)
    });
    this.#computeDynamicGroup = this.device.createBindGroup({
      label: "dynamic binding group for compute pass",
      layout: this.#computeDynamicGroupLayout,
      entries: dynamicEntries
    });
    this.#postDynamicGroup = this.device.createBindGroup({
      label: "dynamic binding group for post processing passes",
      layout: this.#postDynamicGroupLayout,
      entries: dynamicEntries.slice(0, 1)
    });
    let screenClusterDims = [Math.ceil(this.canvas.width / 8), Math.ceil(this.canvas.height / 8)];
    let kernelClusterDims = [Math.ceil(this.canvas.width / 8), Math.ceil(this.canvas.height / 8)];
    let commandEncoder = this.device.createCommandEncoder();
    commandEncoder.clearBuffer(this.#depthBuffer);
    commandEncoder.clearBuffer(this.#triangleIdBuffer);
    let depthEncoder = commandEncoder.beginRenderPass(this.#renderPassDescriptor);
    depthEncoder.setPipeline(this.#depthPipeline);
    depthEncoder.setBindGroup(0, this.#depthGroup);
    depthEncoder.setBindGroup(1, this.#rasterStaticGroup);
    depthEncoder.setBindGroup(2, this.#rasterDynamicGroup);
    depthEncoder.draw(3, this.#engineState.bufferLength);
    depthEncoder.end();
    let renderEncoder = commandEncoder.beginRenderPass(this.#renderPassDescriptor);
    renderEncoder.setPipeline(this.#rasterPipeline);
    renderEncoder.setBindGroup(0, this.#rasterRenderGroup);
    renderEncoder.setBindGroup(1, this.#rasterStaticGroup);
    renderEncoder.setBindGroup(2, this.#rasterDynamicGroup);
    renderEncoder.draw(3, this.#engineState.bufferLength);
    renderEncoder.end();
    let computeEncoder = commandEncoder.beginComputePass();
    computeEncoder.setPipeline(this.#computePipeline);
    computeEncoder.setBindGroup(0, this.#computeRenderGroup);
    computeEncoder.setBindGroup(1, this.textureGroup);
    computeEncoder.setBindGroup(2, this.#computeStaticGroup);
    computeEncoder.setBindGroup(3, this.#computeDynamicGroup);
    computeEncoder.dispatchWorkgroups(kernelClusterDims[0], kernelClusterDims[1]);
    computeEncoder.end();
    if (this.config.temporal) {
      let shiftEncoder = commandEncoder.beginComputePass();
      shiftEncoder.setPipeline(this.#shiftPipeline);
      shiftEncoder.setBindGroup(0, this.#shiftGroup);
      shiftEncoder.setBindGroup(1, this.#postDynamicGroup);
      shiftEncoder.dispatchWorkgroups(screenClusterDims[0], screenClusterDims[1]);
      shiftEncoder.end();
      let selectiveAverageEncoder = commandEncoder.beginComputePass();
      selectiveAverageEncoder.setPipeline(this.#temporalPipeline);
      selectiveAverageEncoder.setBindGroup(0, this.#temporalGroup);
      selectiveAverageEncoder.setBindGroup(1, this.#postDynamicGroup);
      selectiveAverageEncoder.dispatchWorkgroups(screenClusterDims[0], screenClusterDims[1]);
      selectiveAverageEncoder.end();
      let reprojectEncoder = commandEncoder.beginComputePass();
      reprojectEncoder.setPipeline(this.#reprojectPipeline);
      reprojectEncoder.setBindGroup(0, this.#reprojectGroup);
      reprojectEncoder.setBindGroup(1, this.#postDynamicGroup);
      reprojectEncoder.dispatchWorkgroups(screenClusterDims[0], screenClusterDims[1]);
      reprojectEncoder.end();
    }
    if (this.#AAObject) {
      this.#AAObject.renderFrame(commandEncoder);
    }
    let canvasEncoder = commandEncoder.beginComputePass();
    canvasEncoder.setPipeline(this.#canvasPipeline);
    canvasEncoder.setBindGroup(0, this.#canvasGroup);
    canvasEncoder.setBindGroup(1, this.#postDynamicGroup);
    canvasEncoder.dispatchWorkgroups(screenClusterDims[0], screenClusterDims[1]);
    canvasEncoder.end();
    let commandBuffer = commandEncoder.finish();
    this.device.queue.submit([commandBuffer]);
  }
};

// src/flexlight/webgl2/shaders/rasterizer-vertex.glsl
var rasterizer_vertex_default = "#version 300 es\n#define TRIANGLES_PER_ROW_POWER 8\n#define TRIANGLES_PER_ROW 256\n#define INV_65536 0.00001525879\n\nprecision highp int;\nprecision highp float;\nprecision highp sampler2D;\n\nin int triangleId;\nin int vertexId;\n\nlayout (std140) uniform transformMatrix\n{\n    mat3 rotation[MAX_TRANSFORMS];\n    vec3 shift[MAX_TRANSFORMS];\n};\n\nuniform vec3 cameraPosition;\nuniform mat3 viewMatrix;\n\n// Texture with vertex information about all triangles in scene\nuniform sampler2D geometryTex;\n\nout vec3 position;\nout vec2 uv;\nout vec3 clipSpace;\n\nflat out vec3 camera;\nflat out int fragmentTriangleId;\nflat out int transformationId;\n\nconst vec2 baseUVs[3] = vec2[3](vec2(1, 0), vec2(0, 1), vec2(0, 0));\n\nvoid main() {\n    // Calculate vertex position in texture\n    int triangleColumn = triangleId >> TRIANGLES_PER_ROW_POWER;\n    ivec2 index = ivec2((triangleId - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);\n    vec4 t0 = texelFetch(geometryTex, index, 0);\n    vec4 t1 = texelFetch(geometryTex, index + ivec2(1, 0), 0);\n    vec4 t2 = texelFetch(geometryTex, index + ivec2(2, 0), 0);\n    // Combine vertex position\n    vec3 position3d;\n    switch (vertexId) {\n        case 0:\n            position3d = t0.xyz;\n            break;\n        case 1:\n            position3d = vec3(t0.w, t1.xy);\n            break;\n        case 2:\n            position3d = vec3(t1.zw, t2.x);\n            break;\n    }\n    transformationId = int(t2.y);\n    // Apply local geometry transform\n    int tI = transformationId << 1;\n    vec3 localGeometry = rotation[tI] * position3d + shift[tI];\n    vec3 move3d = localGeometry - cameraPosition;\n    clipSpace = viewMatrix * move3d;\n\n    // Set triangle position in clip space\n    gl_Position = vec4(clipSpace.xy, -1.0f / (1.0f + exp(- length(move3d * INV_65536))), clipSpace.z);\n    position = position3d;\n\n    uv = baseUVs[vertexId];\n    camera = cameraPosition;\n    fragmentTriangleId = triangleId;\n}\n";

// src/flexlight/webgl2/shaders/rasterizer-fragment.glsl
var rasterizer_fragment_default = "#version 300 es\n#define TRIANGLES_PER_ROW_POWER 8\n#define TRIANGLES_PER_ROW 256\n#define PI 3.141592653589793\n#define PHI 1.61803398874989484820459\n#define SQRT3 1.7320508075688772\n#define POW32 4294967296.0\n#define BIAS 0.0000152587890625\n#define THIRD 0.3333333333333333\n#define INV_PI 0.3183098861837907\n#define INV_256 0.00390625\n#define INV_255 0.00392156862745098\n#define INV_65536 0.0000152587890625\n\nprecision highp float;\nprecision highp sampler2D;\n\nstruct Ray {\n    vec3 origin;\n    vec3 unitDirection;\n};\n\nstruct Material {\n    vec3 albedo;\n    vec3 rme;\n    vec3 tpo;\n};\n\nin vec3 position;\nin vec2 uv;\nin vec3 clipSpace;\n\nflat in vec3 camera;\nflat in int fragmentTriangleId;\nflat in int transformationId;\n\nlayout (std140) uniform transformMatrix\n{\n    mat3 rotation[MAX_TRANSFORMS];\n    vec3 shift[MAX_TRANSFORMS];\n};\n// Get global illumination color, intensity\nuniform vec3 ambient;\n// Textures in parallel for texture atlas\nuniform vec2 textureDims;\nuniform int hdr;\n// Texture with information about all triangles in scene\nuniform sampler2D geometryTex;\nuniform sampler2D sceneTex;\n// Random texture to multiply with normal map to simulate rough surfaces\nuniform sampler2D translucencyTex;\nuniform sampler2D pbrTex;\nuniform sampler2D tex;\n// Texture with all primary light sources of scene\nuniform sampler2D lightTex;\n\nlayout(location = 0) out vec4 renderColor;\n\n\n// Lookup values for texture atlases\nvec3 lookup(sampler2D atlas, vec3 coords) {\n    vec2 atlasSize = vec2(textureSize(atlas, 0));\n    vec2 offset = vec2(\n        mod((textureDims.x * coords.z), atlasSize.x),\n        floor((textureDims.x * coords.z) / atlasSize.x) * textureDims.y\n    );\n    vec2 atlasCoords = (offset + coords.xy * textureDims) / atlasSize;\n    // Return texel on requested location\n    return texture(atlas, atlasCoords).xyz;\n}\n\n// Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles\nbool moellerTrumboreCull(mat3 t, Ray ray, float l) {\n    vec3 edge1 = t[1] - t[0];\n    vec3 edge2 = t[2] - t[0];\n    vec3 pvec = cross(ray.unitDirection, edge2);\n    float det = dot(edge1, pvec);\n    float invDet = 1.0f / det;\n    if(det < BIAS) return false;\n    vec3 tvec = ray.origin - t[0];\n    float u = dot(tvec, pvec) * invDet;\n    if(u < BIAS || u > 1.0f) return false;\n    vec3 qvec = cross(tvec, edge1);\n    float v = dot(ray.unitDirection, qvec) * invDet;\n    if(v < BIAS || u + v > 1.0f) return false;\n    float s = dot(edge2, qvec) * invDet;\n    return (s <= l && s > BIAS);\n}\n\n// Don't return intersection point, because we're looking for a specific triangle not bounding box\nbool rayCuboid(float l, Ray ray, vec3 minCorner, vec3 maxCorner) {\n    vec3 v0 = (minCorner - ray.origin) / ray.unitDirection;\n    vec3 v1 = (maxCorner - ray.origin) / ray.unitDirection;\n    float tmin = max(max(min(v0.x, v1.x), min(v0.y, v1.y)), min(v0.z, v1.z));\n    float tmax = min(min(max(v0.x, v1.x), max(v0.y, v1.y)), max(v0.z, v1.z));\n    return tmax >= max(tmin, BIAS) && tmin < l;\n}\n\n// Simplified rayTracer to only test if ray intersects anything\nbool shadowTest(Ray ray, float l) {\n    // Cache transformed ray attributes\n    Ray tR = Ray(ray.origin, ray.unitDirection);\n    int cachedTI = 0;\n    // Precompute max length\n    float minLen = l;\n    // Get texture size as max iteration value\n    int size = textureSize(geometryTex, 0).y * TRIANGLES_PER_ROW;\n    // Iterate through lines of texture\n    for(int i = 0; i < size; i++) {\n        // Get position of current triangle/vertex in geometryTex\n        int triangleColumn = i >> TRIANGLES_PER_ROW_POWER;\n        ivec2 index = ivec2((i - triangleColumn * TRIANGLES_PER_ROW) * 3, triangleColumn);\n        // Fetch triangle coordinates from scene graph\n        vec4 t0 = texelFetch(geometryTex, index, 0);\n        vec4 t1 = texelFetch(geometryTex, index + ivec2(1, 0), 0);\n        vec4 t2 = texelFetch(geometryTex, index + ivec2(2, 0), 0);\n\n        int tI = int(t2.y) << 1;\n        // Test if cached transformed variables are still valid\n        if (tI != cachedTI) {\n            int iI = tI + 1;\n            mat3 rotationII = rotation[iI];\n            cachedTI = tI;\n            tR = Ray(\n                rotationII * (ray.origin + shift[iI]),\n                normalize(rotationII * ray.unitDirection)\n            );\n        }\n        // Three cases:\n        // t2.z = 0        => end of list: stop loop\n        // t2.z = 1        => is bounding volume: do AABB intersection test\n        // t2.z = 2        => is triangle: do triangle intersection test\n        if (t2.z == 0.0) return false;\n\n        if (t2.z == 1.0) {\n            if (!rayCuboid(minLen, tR, t0.xyz, vec3(t0.w, t1.xy))) i += int(t1.z);\n        } else {\n            mat3 triangle = mat3 (t0, t1, t2.x);\n            // Test for triangle intersection in positive light ray direction\n            if (moellerTrumboreCull(triangle, tR, minLen)) return true;\n        }\n    }\n    // Tested all triangles, but there is no intersection\n    return false;\n}\n\nfloat trowbridgeReitz(float alpha, float NdotH) {\n    float numerator = alpha * alpha;\n    float denom = NdotH * NdotH * (numerator - 1.0f) + 1.0f;\n    return numerator / max(PI * denom * denom, BIAS);\n}\n\nfloat schlickBeckmann(float alpha, float NdotX) {\n    float k = alpha * 0.5f;\n    float denominator = NdotX * (1.0f - k) + k;\n    denominator = max(denominator, BIAS);\n    return NdotX / denominator;\n}\n\nfloat smith(float alpha, float NdotV, float NdotL) {\n    return schlickBeckmann(alpha, NdotV) * schlickBeckmann(alpha, NdotL);\n}\n\nvec3 fresnel(vec3 F0, float theta) {\n    // Use Schlick approximation\n    return F0 + (1.0f - F0) * pow(1.0f - theta, 5.0f);\n}\n\nvec3 forwardTrace(Material material, vec3 lightDir, float strength, vec3 N, vec3 V) {\n    float lenP1 = 1.0f + length(lightDir);\n    // Apply inverse square law\n    float brightness = strength / (lenP1 * lenP1);\n\n    vec3 L = normalize(lightDir);\n    vec3 H = normalize(V + L);\n\n    float VdotH = max(dot(V, H), 0.0f);\n    float NdotL = max(dot(N, L), 0.0f);\n    float NdotH = max(dot(N, H), 0.0f);\n    float NdotV = max(dot(N, V), 0.0f);\n\n    float alpha = material.rme.x * material.rme.x;\n    float BRDF = mix(1.0f, NdotV, material.rme.y);\n    vec3 F0 = material.albedo * BRDF;\n\n    vec3 Ks = fresnel(F0, VdotH);\n    vec3 Kd = (1.0f - Ks) * (1.0f - material.rme.y);\n    vec3 lambert = material.albedo * INV_PI;\n\n    vec3 cookTorranceNumerator = Ks * trowbridgeReitz(alpha, NdotH) * smith(alpha, NdotV, NdotL);\n    float cookTorranceDenominator = 4.0f * NdotV * NdotL;\n    cookTorranceDenominator = max(cookTorranceDenominator, BIAS);\n\n    vec3 cookTorrance = cookTorranceNumerator / cookTorranceDenominator;\n    vec3 radiance = Kd * lambert + cookTorrance;\n\n    // Outgoing light to camera\n    return radiance * NdotL * brightness;\n}\n\nvoid main() {\n\n    // Calculate vertex position in texture\n    int triangleColumn = fragmentTriangleId >> 8;\n    ivec2 index = ivec2((fragmentTriangleId - triangleColumn * TRIANGLES_PER_ROW) * 7, triangleColumn);\n\n    // Fetch texture data\n    vec4 t0 = texelFetch(sceneTex, index, 0);\n    vec4 t1 = texelFetch(sceneTex, index + ivec2(1, 0), 0);\n    vec4 t2 = texelFetch(sceneTex, index + ivec2(2, 0), 0);\n    vec4 t3 = texelFetch(sceneTex, index + ivec2(3, 0), 0);\n    vec4 t4 = texelFetch(sceneTex, index + ivec2(4, 0), 0);\n    vec4 t5 = texelFetch(sceneTex, index + ivec2(5, 0), 0);\n    vec4 t6 = texelFetch(sceneTex, index + ivec2(6, 0), 0);\n\n    // Calculate barycentric coordinates to map textures\n    // Assemble 3 vertex normals\n    mat3 normals = mat3 (\n        t0.xyz, \n        vec3(t0.w, t1.xy),\n        vec3(t1.zw, t2.x)\n    );\n    // Transform normal according to object transform\n    int tI = transformationId << 1;\n    vec3 absolutePosition = rotation[tI] * position + shift[tI];\n    // Transform normal with local transform\n    vec3 smoothNormal = normalize(rotation[tI] * (normals * vec3(uv, 1.0f - uv.x - uv.y)));\n    // Create 3 2-component vectors for the UV's of the respective vertex\n    mat3x2 vertexUVs = mat3x2(t2.yzw, t3.xyz);\n    // Interpolate final barycentric texture coordinates\n    vec2 barycentric = vertexUVs * vec3(uv, 1.0f - uv.x - uv.y);\n    // Read texture id's used as material\n    vec3 texNums = vec3(t3.w, t4.xy);\n    // Gather material attributes (albedo, roughness, metallicity, emissiveness, translucency, partical density and optical density aka. IOR) out of world texture\n    Material material = Material(\n        mix(\n            vec3(t4.zw, t5.x), \n            lookup(tex, vec3(barycentric, texNums.x)).xyz, \n            max(sign(texNums.x + 0.5f), 0.0f)\n        ),\n        mix(\n            t5.yzw, \n            lookup(pbrTex, vec3(barycentric, texNums.y)).xyz, \n            max(sign(texNums.y + 0.5f), 0.0f)\n        ),\n        mix(\n            t6.xyz, \n            lookup(translucencyTex, vec3(barycentric, texNums.z)).xyz, \n            max(sign(texNums.z + 0.5f), 0.0f)\n        )\n    );\n\n    vec3 finalColor = vec3(material.rme.z + ambient) * material.albedo;\n    // Calculate primary light sources for this pass if ray hits non translucent object\n    for(int j = 0; j < textureSize(lightTex, 0).y; j++) {\n        // Read light position\n        vec3 light = texelFetch(lightTex, ivec2(0, j), 0).xyz;\n        // Read light strength from texture\n        float strength = texelFetch(lightTex, ivec2(1, j), 0).x;\n        // Skip if strength is negative or zero\n        if(strength <= 0.0f) continue;\n\n        // Form light vector\n        vec3 dir = light - absolutePosition;\n        Ray lightRay = Ray(absolutePosition, normalize(dir));\n        vec3 localColor = forwardTrace(material, light - position, strength, smoothNormal, normalize(camera - position));\n        // Compute quick exit criterion to potentially skip expensive shadow test\n        bool showColor = length(localColor) == 0.0f;\n\n        // lightRay.origin += sin(acos(dot(smoothNormal, geometryNormal))) * smoothNormal;\n        // Update pixel color if coordinate is not in shadow\n        if(showColor || !shadowTest(lightRay, length(dir))) finalColor += localColor;\n    }\n\n    // finalColor *= material.albedo;\n\n    float translucencyFactor = min(1.0 + max(finalColor.x, max(finalColor.y, finalColor.z)) - material.tpo.x, 1.0);\n    finalColor = mix(material.albedo * material.albedo, finalColor, translucencyFactor);\n\n    if(hdr == 1) {\n        // Apply Reinhard tone mapping\n        finalColor = finalColor / (finalColor + vec3(1.0f));\n        // Gamma correction\n        // float gamma = 0.8f;\n        // finalColor = pow(4.0f * finalColor, vec3(1.0f / gamma)) / 4.0f * 1.3f;\n    }\n\n    renderColor = vec4(finalColor, 1.0f - (0.5 * material.tpo.x));\n}\n";

// src/flexlight/webgl2/rasterizer.js
var RasterizerWGL2 = class {
  type = "rasterizer";
  // Configurable runtime properties (public attributes)
  config;
  // Performance metric
  fps = 0;
  fpsLimit = Infinity;
  #antialiasing;
  #AAObject;
  // Make gl object inaccessible from outside the class
  #gl;
  #canvas;
  #halt = false;
  #geometryTexture;
  #sceneTexture;
  // Buffer arrays
  #triangleIdBufferArray;
  #bufferLength;
  // Internal gl texture variables of texture atlases
  #textureAtlas;
  #pbrAtlas;
  #translucencyAtlas;
  #textureList = [];
  #pbrList = [];
  #translucencyList = [];
  #lightTexture;
  // Create new raysterizer from canvas and setup movement
  constructor(canvas, scene, camera, config) {
    this.#canvas = canvas;
    this.camera = camera;
    this.config = config;
    this.scene = scene;
    this.#gl = canvas.getContext("webgl2");
  }
  halt = () => {
    try {
      this.#gl.loseContext();
    } catch (e) {
      console.warn("Unable to lose previous context, reload page in case of performance issue");
    }
    this.#halt = true;
  };
  // Make canvas read only accessible
  get canvas() {
    return this.#canvas;
  }
  // Functions to update texture atlases to add more textures during runtime
  async #updateAtlas(list) {
    if (list.length === 0) {
      this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, 1, 1, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, new Uint8Array(4));
      return;
    }
    const [width, height] = this.scene.standardTextureSizes;
    const textureWidth = Math.floor(2048 / width);
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    canvas.width = Math.min(width * list.length, 2048);
    canvas.height = height * (Math.floor(width * list.length / 2048) + 1);
    console.log(canvas.width, canvas.height);
    ctx.imageSmoothingEnabled = false;
    list.forEach(async (texture, i) => ctx.drawImage(texture, width * (i % textureWidth), height * Math.floor(i / textureWidth), width, height));
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, canvas);
  }
  async #updateTextureAtlas() {
    if (this.scene.textures.length === this.#textureList.length && this.scene.textures.every((e, i) => e === this.#textureList[i])) return;
    this.#textureList = this.scene.textures;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#textureAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    GLLib.setTexParams(this.#gl);
    this.#updateAtlas(this.scene.textures);
  }
  async #updatePbrAtlas() {
    if (this.scene.pbrTextures.length === this.#pbrList.length && this.scene.pbrTextures.every((e, i) => e === this.#pbrList[i])) return;
    this.#pbrList = this.scene.pbrTextures;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#pbrAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    GLLib.setTexParams(this.#gl);
    this.#updateAtlas(this.scene.pbrTextures);
  }
  async #updateTranslucencyAtlas() {
    if (this.scene.translucencyTextures.length === this.#translucencyList.length && this.scene.translucencyTextures.every((e, i) => e === this.#translucencyList[i])) return;
    this.#translucencyList = this.scene.translucencyTextures;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#translucencyAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    GLLib.setTexParams(this.#gl);
    this.#updateAtlas(this.scene.translucencyTextures);
  }
  // Functions to update vertex and light source data textures
  updatePrimaryLightSources() {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#lightTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    GLLib.setTexParams(this.#gl);
    if (this.scene.primaryLightSources.length === 0) {
      this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 1, 1, 0, this.#gl.RGB, this.#gl.FLOAT, new Float32Array(3));
      return;
    }
    var lightTexArray = [];
    this.scene.primaryLightSources.forEach((lightSource) => {
      const intensity = Object.is(lightSource.intensity) ? this.scene.defaultLightIntensity : lightSource.intensity;
      const variation = Object.is(lightSource.variation) ? this.scene.defaultLightVariation : lightSource.variation;
      lightTexArray.push(lightSource[0], lightSource[1], lightSource[2], intensity, variation, 0);
    });
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 2, this.scene.primaryLightSources.length, 0, this.#gl.RGB, this.#gl.FLOAT, Float32Array.from(lightTexArray));
  }
  async updateScene() {
    let builtScene = await this.scene.generateArraysFromGraph();
    this.#bufferLength = builtScene.bufferLength;
    this.#triangleIdBufferArray = builtScene.idBuffer;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#geometryTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    GLLib.setTexParams(this.#gl);
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA32F, 3 * 256, builtScene.geometryBufferHeight, 0, this.#gl.RGBA, this.#gl.FLOAT, builtScene.geometryBuffer);
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#sceneTexture);
    GLLib.setTexParams(this.#gl);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA32F, 7 * 256, builtScene.sceneBufferHeight, 0, this.#gl.RGBA, this.#gl.FLOAT, builtScene.sceneBuffer);
  }
  render() {
    let rt = this;
    rt.#halt = false;
    let triangleIdBuffer, vertexIdBuffer;
    let Program, CameraPosition, ViewMatrixLocation, AmbientLocation, TextureDims, HdrLocation, PbrTex, TranslucencyTex, Tex, LightTex;
    let UboBuffer, UboVariableIndices, UboVariableOffsets;
    let GeometryTex, SceneTex;
    let Framebuffer;
    let DepthTexture = this.#gl.createTexture();
    let Vao = this.#gl.createVertexArray();
    let renderTextureBuilder = () => {
      this.#gl.bindTexture(this.#gl.TEXTURE_2D, DepthTexture);
      this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.DEPTH_COMPONENT24, rt.canvas.width, rt.canvas.height, 0, this.#gl.DEPTH_COMPONENT, this.#gl.UNSIGNED_INT, null);
      GLLib.setTexParams(this.#gl);
    };
    let frameCycle = (engineState) => {
      if (this.#halt) return;
      let timeStamp = performance.now();
      this.#updateTextureAtlas();
      this.#updatePbrAtlas();
      this.#updateTranslucencyAtlas();
      this.updatePrimaryLightSources();
      if (engineState.renderQuality !== this.config.renderQuality) {
        resize();
        engineState = prepareEngine();
      }
      if (engineState.antialiasing !== this.config.antialiasing) {
        engineState.antialiasing = this.config.antialiasing;
        let val = this.config.antialiasing.toLowerCase();
        switch (val) {
          case "fxaa":
            this.#antialiasing = val;
            this.#AAObject = new FXAA(this.#gl, this.#canvas);
            break;
          case "taa":
            this.#antialiasing = val;
            this.#AAObject = new TAA(this.#gl, this.#canvas);
            break;
          default:
            this.#antialiasing = void 0;
            this.#AAObject = void 0;
        }
      }
      renderFrame(engineState);
      engineState.intermediateFrames++;
      engineState.temporalFrame = (engineState.temporalFrame + 1) % this.config.temporalSamples;
      let timeDifference = timeStamp - engineState.lastTimeStamp;
      if (timeDifference > 500) {
        this.fps = (1e3 * engineState.intermediateFrames / timeDifference).toFixed(0);
        engineState.lastTimeStamp = timeStamp;
        engineState.intermediateFrames = 0;
      }
      setTimeout(function() {
        requestAnimationFrame(() => frameCycle(engineState));
      }, 1e3 / this.fpsLimit);
    };
    let rasterizingPass = () => {
      let jitter = { x: 0, y: 0 };
      if (this.#antialiasing !== void 0 && this.#antialiasing.toLocaleLowerCase() === "taa") jitter = this.#AAObject.jitter();
      let dir = { x: this.camera.direction.x + jitter.x, y: this.camera.direction.y + jitter.y };
      let invFov = 1 / this.camera.fov;
      let heightInvWidthFov = this.#canvas.height * invFov / this.#canvas.width;
      let viewMatrix = [
        Math.cos(dir.x) * heightInvWidthFov,
        0,
        Math.sin(dir.x) * heightInvWidthFov,
        -Math.sin(dir.x) * Math.sin(dir.y) * invFov,
        Math.cos(dir.y) * invFov,
        Math.cos(dir.x) * Math.sin(dir.y) * invFov,
        -Math.sin(dir.x) * Math.cos(dir.y),
        -Math.sin(dir.y),
        Math.cos(dir.x) * Math.cos(dir.y)
      ];
      this.#gl.bindVertexArray(Vao);
      this.#gl.useProgram(Program);
      [this.#geometryTexture, this.#sceneTexture, this.#pbrAtlas, this.#translucencyAtlas, this.#textureAtlas, this.#lightTexture].forEach((texture, i) => {
        this.#gl.activeTexture(this.#gl.TEXTURE0 + i);
        this.#gl.bindTexture(this.#gl.TEXTURE_2D, texture);
      });
      this.#gl.uniform3f(CameraPosition, this.camera.position.x, this.camera.position.y, this.camera.position.z);
      this.#gl.uniformMatrix3fv(ViewMatrixLocation, true, viewMatrix);
      this.#gl.uniform3f(AmbientLocation, this.scene.ambientLight[0], this.scene.ambientLight[1], this.scene.ambientLight[2]);
      this.#gl.uniform2f(TextureDims, this.scene.standardTextureSizes[0], this.scene.standardTextureSizes[1]);
      this.#gl.uniform1i(HdrLocation, this.config.hdr);
      this.#gl.uniform1i(GeometryTex, 0);
      this.#gl.uniform1i(SceneTex, 1);
      this.#gl.uniform1i(PbrTex, 2);
      this.#gl.uniform1i(TranslucencyTex, 3);
      this.#gl.uniform1i(Tex, 4);
      this.#gl.uniform1i(LightTex, 5);
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, UboBuffer);
      let transformArrays = Transform.buildWGL2Arrays();
      this.#gl.bufferSubData(this.#gl.UNIFORM_BUFFER, UboVariableOffsets[0], transformArrays.rotationBuffer, 0);
      this.#gl.bufferSubData(this.#gl.UNIFORM_BUFFER, UboVariableOffsets[1], transformArrays.shiftBuffer, 0);
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, null);
      this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, triangleIdBuffer);
      this.#gl.bufferData(this.#gl.ARRAY_BUFFER, this.#triangleIdBufferArray, this.#gl.DYNAMIC_DRAW);
      this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, vertexIdBuffer);
      this.#gl.bufferData(this.#gl.ARRAY_BUFFER, new Int32Array([0, 1, 2]), this.#gl.STATIC_DRAW);
      this.#gl.drawArraysInstanced(this.#gl.TRIANGLES, 0, 3, this.#bufferLength);
    };
    let renderFrame = (engineState) => {
      if (this.#antialiasing !== void 0) {
        this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, Framebuffer);
        this.#gl.drawBuffers([
          this.#gl.COLOR_ATTACHMENT0
        ]);
        this.#gl.framebufferTexture2D(this.#gl.FRAMEBUFFER, this.#gl.COLOR_ATTACHMENT0, this.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
        this.#gl.framebufferTexture2D(this.#gl.FRAMEBUFFER, this.#gl.DEPTH_ATTACHMENT, this.#gl.TEXTURE_2D, DepthTexture, 0);
      } else {
        this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, null);
      }
      this.#gl.clear(this.#gl.COLOR_BUFFER_BIT | this.#gl.DEPTH_BUFFER_BIT);
      rasterizingPass();
      if (this.#AAObject !== void 0) this.#AAObject.renderFrame();
    };
    let prepareEngine = () => {
      let initialState = {
        // Attributes to meassure frames per second
        intermediateFrames: 0,
        lastTimeStamp: performance.now(),
        // Parameters to compare against current state of the engine and recompile shaders on change
        filter: this.config.filter,
        renderQuality: this.config.renderQuality
      };
      this.#textureList = [];
      this.#pbrList = [];
      this.#translucencyList = [];
      const MAX_TRANSFORMS = Math.floor((Math.min(this.#gl.getParameter(this.#gl.MAX_VERTEX_UNIFORM_VECTORS), this.#gl.getParameter(this.#gl.MAX_FRAGMENT_UNIFORM_VECTORS)) - 16) * 0.25);
      console.log("MAX_TRANSFORMS evaluated to", MAX_TRANSFORMS);
      let vertexShader = GLLib.addCompileTimeConstant(rasterizer_vertex_default, "MAX_TRANSFORMS", MAX_TRANSFORMS);
      let fragmentShader = GLLib.addCompileTimeConstant(rasterizer_fragment_default, "MAX_TRANSFORMS", MAX_TRANSFORMS);
      Program = GLLib.compile(this.#gl, vertexShader, fragmentShader);
      this.#gl.bindVertexArray(Vao);
      CameraPosition = this.#gl.getUniformLocation(Program, "cameraPosition");
      AmbientLocation = this.#gl.getUniformLocation(Program, "ambient");
      GeometryTex = this.#gl.getUniformLocation(Program, "geometryTex");
      SceneTex = this.#gl.getUniformLocation(Program, "sceneTex");
      TextureDims = this.#gl.getUniformLocation(Program, "textureDims");
      HdrLocation = this.#gl.getUniformLocation(Program, "hdr");
      ViewMatrixLocation = this.#gl.getUniformLocation(Program, "viewMatrix");
      let BlockIndex = this.#gl.getUniformBlockIndex(Program, "transformMatrix");
      let BlockSize = this.#gl.getActiveUniformBlockParameter(Program, BlockIndex, this.#gl.UNIFORM_BLOCK_DATA_SIZE);
      UboBuffer = this.#gl.createBuffer();
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, UboBuffer);
      this.#gl.bufferData(this.#gl.UNIFORM_BUFFER, BlockSize, this.#gl.DYNAMIC_DRAW);
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, null);
      this.#gl.bindBufferBase(this.#gl.UNIFORM_BUFFER, 0, UboBuffer);
      UboVariableIndices = this.#gl.getUniformIndices(Program, ["rotation", "shift"]);
      UboVariableOffsets = this.#gl.getActiveUniforms(
        Program,
        UboVariableIndices,
        this.#gl.UNIFORM_OFFSET
      );
      let index = this.#gl.getUniformBlockIndex(Program, "transformMatrix");
      this.#gl.uniformBlockBinding(Program, index, 0);
      LightTex = this.#gl.getUniformLocation(Program, "lightTex");
      PbrTex = this.#gl.getUniformLocation(Program, "pbrTex");
      TranslucencyTex = this.#gl.getUniformLocation(Program, "translucencyTex");
      Tex = this.#gl.getUniformLocation(Program, "tex");
      this.#gl.enable(this.#gl.BLEND);
      this.#gl.enable(this.#gl.DEPTH_TEST);
      this.#gl.blendEquation(this.#gl.FUNC_ADD);
      this.#gl.blendFuncSeparate(this.#gl.ONE, this.#gl.ONE_MINUS_SRC_ALPHA, this.#gl.ONE, this.#gl.ONE);
      this.#gl.depthMask(true);
      this.#gl.clearColor(0, 0, 0, 0);
      this.#gl.useProgram(Program);
      rt.#pbrAtlas = this.#gl.createTexture();
      rt.#translucencyAtlas = this.#gl.createTexture();
      rt.#textureAtlas = this.#gl.createTexture();
      rt.#lightTexture = this.#gl.createTexture();
      this.#geometryTexture = this.#gl.createTexture();
      this.#sceneTexture = this.#gl.createTexture();
      [triangleIdBuffer, vertexIdBuffer] = [this.#gl.createBuffer(), this.#gl.createBuffer()];
      this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, triangleIdBuffer);
      this.#gl.enableVertexAttribArray(0);
      this.#gl.vertexAttribIPointer(0, 1, this.#gl.INT, false, 0, 0);
      this.#gl.vertexAttribDivisor(0, 1);
      this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, vertexIdBuffer);
      this.#gl.enableVertexAttribArray(1);
      this.#gl.vertexAttribIPointer(1, 1, this.#gl.INT, false, 0, 0);
      Framebuffer = this.#gl.createFramebuffer();
      renderTextureBuilder();
      this.updateScene();
      return initialState;
    };
    let resize = () => {
      this.canvas.width = this.canvas.clientWidth * this.config.renderQuality;
      this.canvas.height = this.canvas.clientHeight * this.config.renderQuality;
      this.#gl.viewport(0, 0, this.canvas.width, this.canvas.height);
      renderTextureBuilder();
      if (this.#AAObject !== void 0) this.#AAObject.createTexture();
    };
    resize();
    window.addEventListener("resize", resize);
    prepareEngine();
    requestAnimationFrame(frameCycle);
  }
};

// src/flexlight/webgpu/rasterizer.js
var rasterRenderFormats2 = ["rgba32float", "rg32float"];
var POW32U2 = 2 ** 32 - 1;
var TEMPORAL_MAX2 = 2 ** 23 - 1;
var RasterizerWGPU = class extends Renderer {
  type = "rasterizer";
  // Configurable runtime properties of the pathtracer (public attributes)
  config;
  // Performance metric
  fps = 0;
  fpsLimit = Infinity;
  // Make context object accessible for all functions
  #canvas;
  #context;
  #adapter;
  device;
  #preferedCanvasFormat;
  #depthPipeline;
  #rasterPipeline;
  #computePipeline;
  #shiftPipeline;
  #temporalPipeline;
  #reprojectPipeline;
  #canvasPipeline;
  #renderPassDescriptor;
  #staticBuffers;
  #dynamicBuffers;
  #uniformBuffer;
  #transformBuffer;
  #depthBuffer;
  #triangleIdBuffer;
  #rasterRenderTextures = [];
  #temporalIn;
  #shiftTarget;
  #accumulatedTarget;
  #shiftLock;
  #canvasIn;
  #depthGroupLayout;
  #rasterRenderGroupLayout;
  #computeRenderGroupLayout;
  #rasterDynamicGroupLayout;
  #computeDynamicGroupLayout;
  #rasterStaticGroupLayout;
  #computeStaticGroupLayout;
  #postDynamicGroupLayout;
  #shiftGroupLayout;
  #temporalGroupLayout;
  #reprojectGroupLayout;
  // #mapGroupLayout;
  #canvasGroupLayout;
  #depthGroup;
  #rasterRenderGroup;
  #computeRenderGroup;
  #rasterDynamicGroup;
  #computeDynamicGroup;
  #rasterStaticGroup;
  #computeStaticGroup;
  #postDynamicGroup;
  #shiftGroup;
  #temporalGroup;
  #canvasGroup;
  #reprojectGroup;
  #engineState = {};
  #resizeEvent;
  #halt = true;
  #antialiasing;
  #AAObject;
  // Create new PathTracer from canvas and setup movement
  constructor(canvas, scene, camera, config) {
    super(scene);
    this.#canvas = canvas;
    this.camera = camera;
    this.config = config;
    if (!navigator.gpu) return void 0;
  }
  halt = () => {
    this.#halt = true;
    window.removeEventListener("resize", this.#resizeEvent);
  };
  resize() {
    let width = Math.round(this.#canvas.clientWidth * this.config.renderQuality);
    let height = Math.round(this.#canvas.clientHeight * this.config.renderQuality);
    this.#canvas.width = width;
    this.#canvas.height = height;
    let allScreenTextures = [this.#canvasIn, ...this.#rasterRenderTextures];
    if (this.config.temporal) allScreenTextures.push(this.#shiftTarget, this.#temporalIn);
    allScreenTextures.forEach((texture) => {
      try {
        texture.destroy();
      } catch {
      }
    });
    this.#depthBuffer = this.device.createBuffer({ size: height * width * 4, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
    this.#triangleIdBuffer = this.device.createBuffer({ size: height * width * 4, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
    this.#rasterRenderTextures = rasterRenderFormats2.map((format) => this.device.createTexture({
      size: [width, height],
      format,
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
    }));
    this.#canvasIn = this.device.createTexture({
      size: [width, height],
      format: "rgba32float",
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
    });
    if (this.config.temporal) {
      this.#temporalIn = this.device.createTexture({
        // dimension: "3d",
        size: [width, height, this.config.temporal ? (
          /*this.config.temporalSamples * 2*/
          2
        ) : 1],
        format: "rgba32float",
        usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
      });
      this.#shiftTarget = this.device.createTexture({
        // dimension: "3d",
        size: [width, height, 5],
        format: "rgba32float",
        usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
      });
      this.#accumulatedTarget = this.device.createTexture({
        // dimension: "3d",
        size: [width, height, 5],
        format: "rgba32float",
        usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
      });
      this.#shiftLock = this.device.createBuffer({ size: width * height * 4, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
      this.device.queue.writeBuffer(this.#shiftLock, 0, new Uint32Array(new Array(width * height).fill(POW32U2)));
    }
    if (this.#AAObject) this.#AAObject.createTexture();
  }
  // Make canvas read only accessible
  get canvas() {
    return this.#canvas;
  }
  updateScene(device = this.device) {
    if (!device) return;
    console.log(this.scene.queue);
    let builtScene = this.scene.generateArraysFromGraph();
    this.#engineState.bufferLength = builtScene.bufferLength;
    let staticBufferArrays = [
      builtScene.idBuffer,
      builtScene.geometryBuffer,
      builtScene.sceneBuffer
    ];
    this.#staticBuffers = staticBufferArrays.map((array) => {
      let buffer = device.createBuffer({ size: array.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
      device.queue.writeBuffer(buffer, 0, array);
      return buffer;
    });
    let staticEntries = this.#staticBuffers.map((buffer, i) => ({ binding: i, resource: { buffer } }));
    this.#rasterStaticGroup = device.createBindGroup({
      label: "static binding group for raster pass",
      layout: this.#rasterStaticGroupLayout,
      entries: staticEntries.slice(0, 2)
    });
    this.#computeStaticGroup = device.createBindGroup({
      label: "static binding group for compute pass",
      layout: this.#computeStaticGroupLayout,
      entries: staticEntries
    });
  }
  async render() {
    if (!this.#halt) {
      console.warn("Renderer already up and running!");
      return;
    }
    this.#context = this.#canvas.getContext("webgpu");
    this.#adapter = await navigator.gpu.requestAdapter();
    this.device = await this.#adapter.requestDevice();
    this.#preferedCanvasFormat = "rgba8unorm";
    this.#context.configure({
      device: this.device,
      format: this.#preferedCanvasFormat,
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING
    });
    this.#engineState.intermediateFrames = 0;
    this.#engineState.lastTimeStamp = performance.now();
    this.#engineState.temporalFrame = 0;
    await this.updateTextureAtlas(true);
    await this.updatePbrAtlas(true);
    await this.updateTranslucencyAtlas(true);
    this.#prepareEngine(this.device);
  }
  #prepareEngine(device) {
    this.halt();
    this.#halt = false;
    Object.assign(this.#engineState, {
      // Parameters to compare against current state of the engine and recompile shaders on change
      filter: this.config.filter,
      temporal: this.config.temporal,
      temporalSamples: this.config.temporalSamples,
      renderQuality: this.config.renderQuality,
      // New buffer length
      bufferLength: 0
    });
    this.#depthGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.FRAGMENT, buffer: { type: "storage" } }
        // depth
      ]
    });
    this.#rasterRenderGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.FRAGMENT, buffer: { type: "read-only-storage" } },
        // depth
        { binding: 1, visibility: GPUShaderStage.FRAGMENT, buffer: { type: "storage" } },
        // triangle index
        { binding: 2, visibility: GPUShaderStage.FRAGMENT, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d" } },
        // 3d positions
        { binding: 3, visibility: GPUShaderStage.FRAGMENT, storageTexture: { access: "write-only", format: "rg32float", viewDimension: "2d" } }
        // uvs
      ]
    });
    this.#computeRenderGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d-array" } },
        // output
        { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } },
        //storageTexture: { access: "read-only", format: "r32sint", viewDimension: "2d" } },            // triangle index
        { binding: 2, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float" } },
        //storageTexture: { access: "read-only", format: "rgba32float", viewDimension: "2d" } },        // 3d positions
        { binding: 3, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float" } }
        //storageTexture: { access: "read-only", format: "rg32float", viewDimension: "2d" } }           // uvs
      ]
    });
    this.#rasterStaticGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.VERTEX, buffer: { type: "read-only-storage" } },
        // indices
        { binding: 1, visibility: GPUShaderStage.VERTEX, buffer: { type: "read-only-storage" } }
        // geometry
      ]
    });
    this.#computeStaticGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } },
        // indices
        { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } },
        // geometry
        { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } }
        // scene
      ]
    });
    this.#rasterDynamicGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.VERTEX | GPUShaderStage.FRAGMENT, buffer: { type: "uniform" } },
        // uniforms
        { binding: 1, visibility: GPUShaderStage.VERTEX, buffer: { type: "read-only-storage" } }
        // transforms
      ]
    });
    this.#computeDynamicGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: "uniform" } },
        // uniforms
        { binding: 1, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } },
        // transforms
        { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "read-only-storage" } }
        // light sources
      ]
    });
    this.textureGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "uint" } },
        // texture atlas
        { binding: 1, visibility: GPUShaderStage.COMPUTE, texture: { type: "uint" } },
        // pbr texture atlas
        { binding: 2, visibility: GPUShaderStage.COMPUTE, texture: { type: "uint" } }
        // translucency texture atlas
      ]
    });
    if (this.config.temporal) {
      this.#shiftGroupLayout = device.createBindGroupLayout({
        entries: [
          { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float", viewDimension: "2d-array" } },
          { binding: 1, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d-array" } },
          { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "storage" } }
        ]
      });
      this.#temporalGroupLayout = device.createBindGroupLayout({
        entries: [
          { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float", viewDimension: "2d-array" } },
          { binding: 1, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float", viewDimension: "2d-array" } },
          { binding: 2, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d-array" } }
        ]
      });
      this.#reprojectGroupLayout = device.createBindGroupLayout({
        entries: [
          { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float", viewDimension: "2d-array" } },
          { binding: 1, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba32float", viewDimension: "2d" } }
        ]
      });
    }
    this.#postDynamicGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, buffer: { type: "uniform" } }
        // uniforms
      ]
    });
    this.#canvasGroupLayout = device.createBindGroupLayout({
      entries: [
        { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: "float", sampleType: "unfilterable-float" } },
        //storageTexture: { access: "read-only", format: "rgba32float", viewDimension: "2d" } },  // compute output
        { binding: 1, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: "write-only", format: "rgba8unorm", viewDimension: "2d" } }
        // canvas target
      ]
    });
    let depthShader = pathtracer_depth_default;
    let depthModule = device.createShaderModule({ code: depthShader });
    this.#depthPipeline = device.createRenderPipeline({
      label: "depth pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: [
        this.#depthGroupLayout,
        this.#rasterStaticGroupLayout,
        this.#rasterDynamicGroupLayout
      ] }),
      // Vertex shader
      vertex: {
        module: depthModule,
        entryPoint: "vertex"
      },
      // Fragment shader
      fragment: {
        module: depthModule,
        entryPoint: "fragment",
        targets: [{ format: "rgba8unorm" }]
      },
      // Culling config
      primitive: {
        topology: "triangle-list",
        cullMode: "back"
      }
    });
    let rasterShader = pathtracer_raster_default;
    let rasterModule = device.createShaderModule({ code: rasterShader });
    this.#rasterPipeline = device.createRenderPipeline({
      label: "raster pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: [
        this.#rasterRenderGroupLayout,
        this.#rasterStaticGroupLayout,
        this.#rasterDynamicGroupLayout
      ] }),
      // Vertex shader
      vertex: {
        module: rasterModule,
        entryPoint: "vertex"
      },
      // Fragment shader
      fragment: {
        module: rasterModule,
        entryPoint: "fragment",
        targets: [{ format: "rgba8unorm" }]
      },
      // Culling config
      primitive: {
        topology: "triangle-list",
        cullMode: "back"
      }
    });
    let computeShader = pathtracer_compute_default;
    let computeModule = device.createShaderModule({ code: computeShader });
    this.#computePipeline = device.createComputePipeline({
      label: "compute pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: [
        this.#computeRenderGroupLayout,
        this.textureGroupLayout,
        this.#computeStaticGroupLayout,
        this.#computeDynamicGroupLayout
      ] }),
      compute: {
        module: computeModule,
        entryPoint: "compute"
      }
    });
    if (this.config.temporal) {
      let shiftShader = pathtracer_shift_default;
      let shiftModule = device.createShaderModule({ code: shiftShader });
      this.#shiftPipeline = device.createComputePipeline({
        label: "shift pipeline",
        layout: device.createPipelineLayout({ bindGroupLayouts: [this.#shiftGroupLayout, this.#postDynamicGroupLayout] }),
        compute: { module: shiftModule, entryPoint: "compute" }
      });
      let selectiveAverageShader = pathtracer_selective_average_default;
      let selectiveAverageModule = device.createShaderModule({ code: selectiveAverageShader });
      this.#temporalPipeline = device.createComputePipeline({
        label: "selective average pipeline",
        layout: device.createPipelineLayout({ bindGroupLayouts: [this.#temporalGroupLayout, this.#postDynamicGroupLayout] }),
        compute: { module: selectiveAverageModule, entryPoint: "compute" }
      });
      let reprojectShader = pathtracer_reproject_default;
      let reprojectModule = device.createShaderModule({ code: reprojectShader });
      this.#reprojectPipeline = device.createComputePipeline({
        label: "reproject pipeline",
        layout: device.createPipelineLayout({ bindGroupLayouts: [this.#reprojectGroupLayout, this.#postDynamicGroupLayout] }),
        compute: { module: reprojectModule, entryPoint: "compute" }
      });
    }
    let canvasShader = canvas_default;
    let canvasModule = device.createShaderModule({ code: canvasShader });
    this.#canvasPipeline = device.createComputePipeline({
      label: "canvas pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: [this.#canvasGroupLayout, this.#postDynamicGroupLayout] }),
      compute: { module: canvasModule, entryPoint: "compute" }
    });
    this.#renderPassDescriptor = {
      // Render passes are given attachments to write into.
      colorAttachments: [{
        // The color the attachment will be cleared to.
        clearValue: [0, 0, 0, 0],
        // Clear the attachment when the render pass starts.
        loadOp: "clear",
        // When the pass is done, save the results in the attachment texture.
        storeOp: "store"
      }]
    };
    this.#uniformBuffer = device.createBuffer({ size: 128 + 4 * 4 * 3, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST });
    this.updateScene(device);
    this.resize();
    this.#resizeEvent = window.addEventListener("resize", () => this.resize());
    requestAnimationFrame(() => this.frameCycle(device));
  }
  // Internal render engine Functions
  frameCycle(device) {
    if (this.#halt) return;
    let timeStamp = performance.now();
    if (this.#engineState.temporal !== this.config.temporal || this.#engineState.temporalSamples !== this.config.temporalSamples || this.#engineState.renderQuality !== this.config.renderQuality) {
      requestAnimationFrame(() => this.#prepareEngine(device));
      return;
    }
    this.updateTextureAtlas();
    this.updatePbrAtlas();
    this.updateTranslucencyAtlas();
    this.updateTextureGroup();
    this.updatePrimaryLightSources();
    if (this.#engineState.antialiasing !== this.config.antialiasing) {
      this.#engineState.antialiasing = this.config.antialiasing;
      let val = this.config.antialiasing.toLowerCase();
      switch (val) {
        case "fxaa":
          this.#antialiasing = val;
          this.#AAObject = new FXAA2(this.device, this.#canvas);
          break;
        case "taa":
          this.#antialiasing = val;
          this.#AAObject = new TAA2(this.device, this.#canvas);
          break;
        default:
          this.#antialiasing = void 0;
          this.#AAObject = void 0;
      }
    }
    this.renderFrame();
    this.#engineState.intermediateFrames++;
    this.#engineState.temporalFrame = (this.#engineState.temporalFrame + 1) % TEMPORAL_MAX2;
    let timeDifference = timeStamp - this.#engineState.lastTimeStamp;
    if (timeDifference > 500) {
      this.fps = (1e3 * this.#engineState.intermediateFrames / timeDifference).toFixed(0);
      this.#engineState.lastTimeStamp = timeStamp;
      this.#engineState.intermediateFrames = 0;
    }
    setTimeout(() => {
      requestAnimationFrame(() => this.frameCycle(device));
    }, 1e3 / this.fpsLimit);
  }
  async renderFrame() {
    let jitter = { x: 0, y: 0 };
    if (this.#AAObject && this.#antialiasing === "taa") jitter = this.#AAObject.jitter();
    let dir = { x: this.camera.direction.x, y: this.camera.direction.y };
    let dirJitter = { x: this.camera.direction.x + jitter.x, y: this.camera.direction.y + jitter.y };
    let canvasTarget = this.#context.getCurrentTexture();
    let depthBufferEntry = { binding: 0, resource: { buffer: this.#depthBuffer } };
    let computeTargetView = !this.config.temporal && !this.#AAObject ? this.#canvasIn.createView({ dimension: "2d-array", arrayLayerCount: 1 }) : !this.config.temporal && this.#AAObject ? this.#AAObject.textureInView2dArray : this.#temporalIn.createView({ dimension: "2d-array", arrayLayerCount: 2 });
    this.#depthGroup = this.device.createBindGroup({
      label: "depth buffer for depth testing raster pass",
      layout: this.#depthGroupLayout,
      entries: [depthBufferEntry]
    });
    this.#rasterRenderGroup = this.device.createBindGroup({
      label: "render output group for raster pass",
      layout: this.#rasterRenderGroupLayout,
      entries: [
        depthBufferEntry,
        { binding: 1, resource: { buffer: this.#triangleIdBuffer } },
        ...this.#rasterRenderTextures.map((texture, i) => ({ binding: i + 2, resource: texture.createView() }))
      ]
    });
    this.#computeRenderGroup = this.device.createBindGroup({
      label: "render input group for compute pass",
      layout: this.#computeRenderGroupLayout,
      entries: [
        { binding: 0, resource: computeTargetView },
        { binding: 1, resource: { buffer: this.#triangleIdBuffer } },
        ...this.#rasterRenderTextures.map((texture, i) => ({ binding: i + 2, resource: texture.createView() }))
      ]
    });
    if (this.config.temporal) {
      let temporalTargetView = this.#AAObject ? this.#AAObject.textureInView : this.#canvasIn.createView({ dimension: "2d" });
      this.#shiftGroup = this.device.createBindGroup({
        label: "bind group for motion correction pass",
        layout: this.#shiftGroupLayout,
        entries: [
          { binding: 0, resource: this.#accumulatedTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) },
          { binding: 1, resource: this.#shiftTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) },
          { binding: 2, resource: { buffer: this.#shiftLock } }
        ]
      });
      this.#temporalGroup = this.device.createBindGroup({
        label: "bind group accumulation pass",
        layout: this.#temporalGroupLayout,
        entries: [
          { binding: 0, resource: this.#temporalIn.createView({ dimension: "2d-array", arrayLayerCount: 2 }) },
          { binding: 1, resource: this.#shiftTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) },
          { binding: 2, resource: this.#accumulatedTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) }
        ]
      });
      this.#reprojectGroup = this.device.createBindGroup({
        label: "bind group for reprojection pass",
        layout: this.#reprojectGroupLayout,
        entries: [
          { binding: 0, resource: this.#accumulatedTarget.createView({ dimension: "2d-array", arrayLayerCount: 5 }) },
          { binding: 1, resource: temporalTargetView }
        ]
      });
    }
    if (this.#AAObject) {
      this.#AAObject.createBindGroup(this.#canvasIn);
    }
    this.#canvasGroup = this.device.createBindGroup({
      label: "render input group for canvas pass",
      layout: this.#canvasGroupLayout,
      entries: [
        { binding: 0, resource: this.#canvasIn.createView({ dimension: "2d" }) },
        { binding: 1, resource: canvasTarget.createView() }
      ]
    });
    this.#renderPassDescriptor.colorAttachments[0].view = canvasTarget.createView();
    let invFov = 1 / this.camera.fov;
    let heightInvWidthFov = this.#canvas.height * invFov / this.#canvas.width;
    let viewMatrix = [
      [Math.cos(dir.x) * heightInvWidthFov, 0, Math.sin(dir.x) * heightInvWidthFov],
      [-Math.sin(dir.x) * Math.sin(dir.y) * invFov, Math.cos(dir.y) * invFov, Math.cos(dir.x) * Math.sin(dir.y) * invFov],
      [-Math.sin(dir.x) * Math.cos(dir.y), -Math.sin(dir.y), Math.cos(dir.x) * Math.cos(dir.y)]
    ];
    let viewMatrixJitter = [
      [Math.cos(dirJitter.x) * heightInvWidthFov, 0, Math.sin(dirJitter.x) * heightInvWidthFov],
      [-Math.sin(dirJitter.x) * Math.sin(dirJitter.y) * invFov, Math.cos(dirJitter.y) * invFov, Math.cos(dirJitter.x) * Math.sin(dirJitter.y) * invFov],
      [-Math.sin(dirJitter.x) * Math.cos(dirJitter.y), -Math.sin(dirJitter.y), Math.cos(dirJitter.x) * Math.cos(dirJitter.y)]
    ];
    if (!this.config.temporal) {
      viewMatrix = viewMatrixJitter;
    }
    let temporalCount = this.config.temporal ? this.#engineState.temporalFrame : 0;
    this.device.queue.writeBuffer(this.#uniformBuffer, 0, new Float32Array([
      // View matrix
      viewMatrix[0][0],
      viewMatrix[1][0],
      viewMatrix[2][0],
      0,
      viewMatrix[0][1],
      viewMatrix[1][1],
      viewMatrix[2][1],
      0,
      viewMatrix[0][2],
      viewMatrix[1][2],
      viewMatrix[2][2],
      0,
      // View matrix inverse
      viewMatrixJitter[0][0],
      viewMatrixJitter[1][0],
      viewMatrixJitter[2][0],
      0,
      viewMatrixJitter[0][1],
      viewMatrixJitter[1][1],
      viewMatrixJitter[2][1],
      0,
      viewMatrixJitter[0][2],
      viewMatrixJitter[1][2],
      viewMatrixJitter[2][2],
      0,
      // Camera
      this.camera.position.x,
      this.camera.position.y,
      this.camera.position.z,
      0,
      // Ambient light
      this.scene.ambientLight[0],
      this.scene.ambientLight[1],
      this.scene.ambientLight[2],
      0,
      // Texture size
      this.scene.standardTextureSizes[0],
      this.scene.standardTextureSizes[1],
      // Render size
      this.canvas.width,
      this.canvas.height,
      // amount of samples per ray
      this.config.samplesPerRay,
      // max reflections of ray
      this.config.maxReflections,
      // min importancy of light ray
      this.config.minImportancy,
      // render for filter or not
      this.config.filter,
      // Tonemapping operator
      this.config.hdr ? 1 : 0,
      // render for temporal or not
      this.config.temporal,
      // Temporal target
      temporalCount,
      // Temporal samples
      TEMPORAL_MAX2
    ]));
    let transformArray = Transform.buildWGPUArray();
    this.#transformBuffer = this.device.createBuffer({ size: transformArray.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST });
    this.device.queue.writeBuffer(this.#transformBuffer, 0, transformArray);
    this.#dynamicBuffers = [this.#uniformBuffer, this.#transformBuffer, this.lightBuffer];
    let dynamicEntries = this.#dynamicBuffers.map((buffer, i) => ({ binding: i, resource: { buffer } }));
    this.#rasterDynamicGroup = this.device.createBindGroup({
      label: "dynamic binding group for raster pass",
      layout: this.#rasterDynamicGroupLayout,
      entries: dynamicEntries.slice(0, 2)
    });
    this.#computeDynamicGroup = this.device.createBindGroup({
      label: "dynamic binding group for compute pass",
      layout: this.#computeDynamicGroupLayout,
      entries: dynamicEntries
    });
    this.#postDynamicGroup = this.device.createBindGroup({
      label: "dynamic binding group for post processing passes",
      layout: this.#postDynamicGroupLayout,
      entries: dynamicEntries.slice(0, 1)
    });
    let screenClusterDims = [Math.ceil(this.canvas.width / 8), Math.ceil(this.canvas.height / 8)];
    let kernelClusterDims = [Math.ceil(this.canvas.width / 8), Math.ceil(this.canvas.height / 8)];
    let commandEncoder = this.device.createCommandEncoder();
    commandEncoder.clearBuffer(this.#depthBuffer);
    commandEncoder.clearBuffer(this.#triangleIdBuffer);
    let depthEncoder = commandEncoder.beginRenderPass(this.#renderPassDescriptor);
    depthEncoder.setPipeline(this.#depthPipeline);
    depthEncoder.setBindGroup(0, this.#depthGroup);
    depthEncoder.setBindGroup(1, this.#rasterStaticGroup);
    depthEncoder.setBindGroup(2, this.#rasterDynamicGroup);
    depthEncoder.draw(3, this.#engineState.bufferLength);
    depthEncoder.end();
    let renderEncoder = commandEncoder.beginRenderPass(this.#renderPassDescriptor);
    renderEncoder.setPipeline(this.#rasterPipeline);
    renderEncoder.setBindGroup(0, this.#rasterRenderGroup);
    renderEncoder.setBindGroup(1, this.#rasterStaticGroup);
    renderEncoder.setBindGroup(2, this.#rasterDynamicGroup);
    renderEncoder.draw(3, this.#engineState.bufferLength);
    renderEncoder.end();
    let computeEncoder = commandEncoder.beginComputePass();
    computeEncoder.setPipeline(this.#computePipeline);
    computeEncoder.setBindGroup(0, this.#computeRenderGroup);
    computeEncoder.setBindGroup(1, this.textureGroup);
    computeEncoder.setBindGroup(2, this.#computeStaticGroup);
    computeEncoder.setBindGroup(3, this.#computeDynamicGroup);
    computeEncoder.dispatchWorkgroups(kernelClusterDims[0], kernelClusterDims[1]);
    computeEncoder.end();
    if (this.config.temporal) {
      let shiftEncoder = commandEncoder.beginComputePass();
      shiftEncoder.setPipeline(this.#shiftPipeline);
      shiftEncoder.setBindGroup(0, this.#shiftGroup);
      shiftEncoder.setBindGroup(1, this.#postDynamicGroup);
      shiftEncoder.dispatchWorkgroups(screenClusterDims[0], screenClusterDims[1]);
      shiftEncoder.end();
      let selectiveAverageEncoder = commandEncoder.beginComputePass();
      selectiveAverageEncoder.setPipeline(this.#temporalPipeline);
      selectiveAverageEncoder.setBindGroup(0, this.#temporalGroup);
      selectiveAverageEncoder.setBindGroup(1, this.#postDynamicGroup);
      selectiveAverageEncoder.dispatchWorkgroups(screenClusterDims[0], screenClusterDims[1]);
      selectiveAverageEncoder.end();
      let reprojectEncoder = commandEncoder.beginComputePass();
      reprojectEncoder.setPipeline(this.#reprojectPipeline);
      reprojectEncoder.setBindGroup(0, this.#reprojectGroup);
      reprojectEncoder.setBindGroup(1, this.#postDynamicGroup);
      reprojectEncoder.dispatchWorkgroups(screenClusterDims[0], screenClusterDims[1]);
      reprojectEncoder.end();
    }
    if (this.#AAObject) {
      this.#AAObject.renderFrame(commandEncoder);
    }
    let canvasEncoder = commandEncoder.beginComputePass();
    canvasEncoder.setPipeline(this.#canvasPipeline);
    canvasEncoder.setBindGroup(0, this.#canvasGroup);
    canvasEncoder.setBindGroup(1, this.#postDynamicGroup);
    canvasEncoder.dispatchWorkgroups(screenClusterDims[0], screenClusterDims[1]);
    canvasEncoder.end();
    let commandBuffer = commandEncoder.finish();
    this.device.queue.submit([commandBuffer]);
  }
};

// src/flexlight/common/io.js
var WebIo = class _WebIo {
  static #translationMap = {
    right: 1,
    left: -1,
    down: -2,
    up: 2,
    backward: -3,
    forward: 3
  };
  #isListening = false;
  #savedTime;
  #keyMap = {};
  #pressedKeys = {};
  #movement = [0, 0, 0];
  // movement sensitivity
  mouseX = 4;
  mouseY = 2;
  movementSpeed = 0.01;
  camera;
  renderer;
  constructor(canvas, renderer, camera) {
    this.registerKey("KeyW", "forward");
    this.registerKey("KeyA", "left");
    this.registerKey("KeyS", "backward");
    this.registerKey("KeyD", "right");
    this.registerKey("Space", "up");
    this.registerKey("ShiftLeft", "down");
    this.camera = camera;
    this.renderer = renderer;
    this.setupForCanvas(canvas);
    requestAnimationFrame(this.frame);
  }
  registerKey = (key, value) => {
    this.#keyMap[key] = _WebIo.#translationMap[value];
    this.#pressedKeys[key] = false;
  };
  frame = () => {
    this.update(performance.now());
    requestAnimationFrame(this.frame);
  };
  update = (time) => {
    if (!this.#isListening) return;
    const position = this.camera.position;
    const direction = this.camera.direction;
    const difference = (time - this.#savedTime) * this.movementSpeed;
    position.x += difference * (this.#movement[0] * Math.cos(direction.x) - this.#movement[2] * Math.sin(direction.x));
    position.y += difference * this.#movement[1];
    position.z += difference * (this.#movement[2] * Math.cos(direction.x) + this.#movement[0] * Math.sin(direction.x));
    this.#savedTime = time;
  };
  resetMovement = () => {
    for (const key in this.#pressedKeys) this.#pressedKeys[key] = false;
  };
  updateMovement = (value) => this.#movement[Math.abs(value) - 1] += Math.sign(value);
  setupForCanvas = (canvas) => {
    const io = this;
    canvas.tabIndex = 0;
    canvas.onfocus = () => {
      canvas.requestPointerLock();
    };
    document.onpointerlockchange = (event) => {
      io.#isListening = !io.#isListening;
      if (io.#isListening) io.#savedTime = event.timeStamp;
      else {
        io.resetMovement();
        canvas.blur();
      }
    };
    canvas.onkeydown = (event) => {
      if (event.code in io.#pressedKeys) {
        if (io.#pressedKeys[event.code]) return;
        io.update(event.timeStamp);
        io.#pressedKeys[event.code] = true;
        io.updateMovement(io.#keyMap[event.code]);
      }
    };
    canvas.onkeyup = (event) => {
      if (event.code in io.#pressedKeys && io.#pressedKeys[event.code]) {
        io.update(event.timeStamp);
        io.#pressedKeys[event.code] = false;
        io.updateMovement(-io.#keyMap[event.code]);
      }
    };
    canvas.onmousemove = (event) => {
      if (!io.#isListening) return;
      const speed = [io.mouseX / canvas.width, io.mouseY / canvas.height];
      var movement = [speed[0] * event.movementX, speed[1] * event.movementY];
      io.camera.direction.x -= movement[0];
      if (2 * Math.abs(io.camera.direction.y + movement[1]) < Math.PI) io.camera.direction.y += movement[1];
    };
  };
};

// src/flexlight/common/ui.js
var UI = class {
  selected = null;
  constructor(scene, camera) {
    this.scene = scene;
    this.camera = camera;
  }
  #runSelector = () => {
    setInterval(() => {
      let origin = [this.camera.x, this.camera.y, this.camera.z];
      let direction = [
        -Math.sin(this.camera.fx) * Math.cos(this.camera.fy),
        -Math.sin(this.camera.fy),
        Math.cos(this.camera.fx) * Math.cos(this.camera.fy)
      ];
      if (this.selected !== null) this.selected.selected = false;
      let c = this.getObjectInCenter(this.scene.queue, origin, direction);
      if (c.distance !== Infinity) {
        c.object.selected = true;
        this.selected = c.object;
      } else {
        this.selected = null;
      }
    }, 10);
  };
  getObjectInCenter = (part, o, dir) => {
    if (Array.isArray(part) || part.indexable) {
      if (part.length === 0) return;
      let least = this.getObjectInCenter(part[0], o, dir);
      for (let i = 1; i < part.length; i++) {
        let t = this.getObjectInCenter(part[i], o, dir);
        if (least.distance > t.distance) least = t;
      }
      return least;
    } else {
      if (part.length === 2) {
        let n = part.normal;
        let t0 = [part.vertices.slice(0, 3), part.vertices.slice(3, 6), part.vertices.slice(6, 9)];
        let t1 = [part.vertices.slice(9, 12), part.vertices.slice(12, 15), part.vertices.slice(15, 18)];
        return {
          distance: Math.min(Math.rayTriangle(o, dir, t0[0], t0[1], t0[2], n), Math.rayTriangle(o, dir, t1[0], t1[1], t1[2], n)),
          object: part
        };
      } else if (part.length === 1) {
        let n = part.normal;
        let t = [part.vertices.slice(0, 3), part.vertices.slice(3, 6), part.vertices.slice(6, 9)];
        return {
          distance: Math.rayTriangle(o, dir, t[0], t[1], t[2], n),
          object: part
        };
      }
    }
  };
};

// src/flexlight/flexlight.js
var FlexLight = class {
  #idRenderer;
  #idIo;
  #api;
  #canvas;
  #camera;
  #config;
  #scene;
  #renderer;
  #ui;
  #io;
  constructor(canvas) {
    this.#api = "webgl2";
    this.#canvas = canvas;
    this.#camera = new Camera();
    this.#config = new Config();
    this.#scene = new Scene();
    this.#renderer = new RasterizerWGL2(canvas, this.#scene, this.#camera, this.#config);
    this.#io = new WebIo(canvas, this.#renderer, this.#camera);
    this.#ui = new UI(this.#scene, this.#camera);
  }
  get canvas() {
    return this.#canvas;
  }
  get api() {
    return this.#api;
  }
  get camera() {
    return this.#camera;
  }
  get config() {
    return this.#config;
  }
  get scene() {
    return this.#scene;
  }
  get renderer() {
    return this.#renderer;
  }
  get io() {
    return this.#io;
  }
  set canvas(canvas) {
    if (canvas == this.#canvas) return;
    this.#canvas = canvas;
    this.renderer = this.#idRenderer;
    this.io = this.#idIo;
  }
  set api(api) {
    if (api == this.#api) return;
    this.#api = api;
    let newCanvas = document.createElement("canvas");
    console.log(this.#canvas.parentElement);
    this.#canvas.parentElement.replaceChild(newCanvas, this.#canvas);
    this.#canvas = newCanvas;
    this.renderer = this.#idRenderer;
    this.io = this.#idIo;
  }
  set config(config) {
    this.#config = config;
    this.#renderer.config = config;
  }
  set camera(camera) {
    this.#camera = camera;
    this.#renderer.camera = camera;
    this.#scene.camera = camera;
    this.#ui.camera = camera;
  }
  set scene(scene) {
    this.#scene = scene;
    this.#ui.scene = scene;
    this.#renderer.scene = scene;
  }
  set renderer(renderer) {
    this.#idRenderer = renderer;
    console.log(this.#idRenderer + this.#api);
    let wasRunning = this.#renderer.halt();
    switch (this.#idRenderer + this.#api) {
      case "pathtracerwebgl2":
        this.#renderer = new PathTracerWGL2(this.#canvas, this.#scene, this.#camera, this.#config);
        break;
      case "pathtracerwebgpu":
        this.#renderer = new PathTracerWGPU(this.#canvas, this.#scene, this.#camera, this.#config);
        break;
      case "rasterizerwebgl2":
        this.#renderer = new RasterizerWGL2(this.#canvas, this.#scene, this.#camera, this.#config);
        break;
      case "rasterizerwebgpu":
        this.#renderer = new RasterizerWGPU(this.#canvas, this.#scene, this.#camera, this.#config);
        break;
      default:
        console.error("Renderer option", this.#idRenderer, "on api", this.#api, "doesn't exist.");
    }
    if (wasRunning) this.#renderer.render();
  }
  set io(io) {
    this.#idIo = io ?? "web";
    switch (this.#idIo) {
      case "web":
        this.#io = new WebIo(this.#canvas, this.#renderer, this.camera);
        break;
      default:
        console.error("Io option", this.#idIo, "doesn't exist.");
    }
    this.#io.renderer = this.#renderer;
  }
  screenshot() {
    this.#canvas.toBlob((blob) => {
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = "screenshot.png";
      a.click();
    });
  }
};
export {
  Bounding,
  Camera,
  Config,
  Cuboid,
  FlexLight,
  HouseholderMatrix,
  IdentityMatrix,
  Matrix,
  Object3D,
  PathTracerWGL2,
  PathTracerWGPU,
  Plane,
  Primitive,
  RasterizerWGL2,
  RasterizerWGPU,
  Scene,
  Transform,
  Triangle,
  UI,
  Vector,
  WebIo,
  ZeroMatrix,
  ZeroVector
};
