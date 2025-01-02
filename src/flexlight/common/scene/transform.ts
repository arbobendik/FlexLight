"use strict";


export class Transform {
    number = 0;
    #rotationMatrix;
    #position;
    #scale = 1;
    
    #transformedNodes = new Set();
  
    static used = [];
    static count = 0;
    static transformList = [];
  
    static buildWGL2Arrays = () => {
      // Create UBO buffer array
      let rotationBuffer = new Float32Array(24 * Transform.count);
      let shiftBuffer = new Float32Array(8 * Transform.count);
      // Iterate over set elements
      for (let i = 0; i < Transform.count; i++) {
        let matrix = this.transformList[i].matrix;
        let inverse = Math.moorePenrose(matrix);
        let pos = this.transformList[i].position;
        let invPos = Math.mul(- 1, this.transformList[i].position);
        rotationBuffer.set(new Float32Array(matrix[0]), i * 24);
        rotationBuffer.set(new Float32Array(matrix[1]), i * 24 + 4);
        rotationBuffer.set(new Float32Array(matrix[2]), i * 24 + 8);
        rotationBuffer.set(new Float32Array(inverse[0]), i * 24 + 12);
        rotationBuffer.set(new Float32Array(inverse[1]), i * 24 + 16);
        rotationBuffer.set(new Float32Array(inverse[2]), i * 24 + 20);
        shiftBuffer.set(new Float32Array(pos), i * 8);
        shiftBuffer.set(new Float32Array(invPos), i * 8 + 4);
      }
  
      return [rotationBuffer, shiftBuffer];
    }
  
    static buildWGPUArray = () => {
      // Create UBO buffer array
      let transfromBuffer = new Float32Array(32 * Transform.count);
      // Iterate over set elements
      for (let i = 0; i < Transform.count; i++) {
        let matrix = this.transformList[i].matrix;
        let inverse = Math.moorePenrose(matrix);
        let pos = this.transformList[i].position;
        let invPos = Math.mul(- 1, this.transformList[i].position);
        transfromBuffer.set(new Float32Array(matrix[0]), i * 32);
        transfromBuffer.set(new Float32Array(matrix[1]), i * 32 + 4);
        transfromBuffer.set(new Float32Array(matrix[2]), i * 32 + 8);
        transfromBuffer.set(new Float32Array(pos), i * 32 + 12);
        transfromBuffer.set(new Float32Array(inverse[0]), i * 32 + 16);
        transfromBuffer.set(new Float32Array(inverse[1]), i * 32 + 20);
        transfromBuffer.set(new Float32Array(inverse[2]), i * 32 + 24);
        transfromBuffer.set(new Float32Array(invPos), i * 32 + 28);
      }
  
      return transfromBuffer;
    }
  
    get matrix () {
      let scaledRotation = Math.mul(this.#scale, this.#rotationMatrix);
      return scaledRotation;
    }
  
    get position () {
      return this.#position;
    }
  
    move (x, y, z) {
      this.#position = [x, y, z];
    }
    
    rotateAxis (normal, theta) {
      let n = normal;
      let sT = Math.sin(theta);
      let cT = Math.cos(theta);
      let currentRotation = [
        [ n[0] * n[0] * (1 - cT) + cT,          n[0] * n[1] * (1 - cT) - n[2] * sT,   n[0] * n[2] * (1 - cT) + n[1] * sT  ],
        [ n[0] * n[1] * (1 - cT) + n[2] * sT,   n[1] * n[1] * (1 - cT) + cT,          n[1] * n[2] * (1 - cT) - n[0] * sT  ],
        [ n[0] * n[2] * (1 - cT) - n[1] * sT,   n[1] * n[2] * (1 - cT) + n[0] * sT,   n[2] * n[2] * (1- cT) + cT          ]  
      ];
      this.#rotationMatrix = currentRotation;
    }
  
    rotateSpherical (theta, psi) {
      let sT = Math.sin(theta);
      let cT = Math.cos(theta);
      let sP = Math.sin(psi);
      let cP = Math.cos(psi);
  
      let currentRotation = [
        [      cT,    0,      sT],
        [-sT * sP,   cP, cT * sP],
        [-sT * cP, - sP, cT * cP]
      ];
      
      this.#rotationMatrix = currentRotation;
    }
  
    scale (s) {
      this.#scale = s;
    }
  
    addNode (n) {
      this.#transformedNodes.add(n);
    }
  
    removeNode (n) {
      this.#transformedNodes.delete(n);
    }
  
    static classConstructor = (function() {
      // Add one identity matrix transform at position 0 to default to.
      new Transform();
    })();
  
    constructor () {
      // Default to identity matrix
      this.#rotationMatrix = Math.identity(3);
      this.#position = [0, 0, 0];
      // Assign next larger available number
      for (let i = 0; i < Infinity; i++) {
        if (Transform.used[i]) continue;
        Transform.used[i] = true;
        this.number = i;
        break;
      }
      // Update max index
      Transform.count = Math.max(Transform.count, this.number + 1);
      // Set in transform list
      Transform.transformList[this.number] = this;
    }
  }