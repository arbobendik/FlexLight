'use strict';

import { Network } from './network.js';
import { GLLib } from './gllib.js';
import { FXAA } from './fxaa.js';
import { TAA } from './taa.js';
import { Arrays, Float16Array } from './arrays.js';


const PathtracingUniformLocationIdentifiers = [
  'cameraPosition', 'perspective', 'conf',
  'samples', 'maxReflections', 'minImportancy', 'useFilter', 'isTemporal',
  'ambient', 'randomSeed', 'textureWidth',
  'geometryTex', 'sceneTex', 'pbrTex', 'translucencyTex', 'tex', 'lightTex'
];

const PathtracingUniformFunctionTypes = [
  'uniform3f', 'uniform2f', 'uniform4f',
  'uniform1i', 'uniform1i', 'uniform1f', 'uniform1i', 'uniform1i',
  'uniform3f', 'uniform1f', 'uniform1i',
  'uniform1i', 'uniform1i', 'uniform1i', 'uniform1i', 'uniform1i', 'uniform1i'
];

export class PathTracer {
  type = 'pathtracer';
  // Configurable runtime properties of the pathtracer (public attributes)
  // Quality settings
  samplesPerRay = 1;
  renderQuality = 1;
  maxReflections = 5;
  minImportancy = 0.3;
  firstPasses = 0;
  secondPasses = 0;
  temporal = true;
  temporalSamples = 8;
  filter = true;
  hdr = true;
  // Performance metric
  fps = 0;
  fpsLimit = Infinity;

  #antialiasing = 'taa';
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
  // Shader source will be generated later
  #tempGlsl;
  // Shader sources in glsl 3.0.0 es
  #firstFilterGlsl = `#version 300 es
  #define INV_256 0.00390625

  precision highp float;
  in vec2 clipSpace;
  
  uniform sampler2D preRenderColor;
  uniform sampler2D preRenderColorIp;
  uniform sampler2D preRenderNormal;
  uniform sampler2D preRenderOriginalColor;
  uniform sampler2D preRenderId;
  uniform sampler2D preRenderOriginalId;

  layout(location = 0) out vec4 renderColor;
  layout(location = 1) out vec4 renderColorIp;
  layout(location = 2) out vec4 renderId;

  void main() {
    // Get texture size
    ivec2 texel = ivec2(vec2(textureSize(preRenderColor, 0)) * clipSpace);
    vec4 centerColor = texelFetch(preRenderColor, texel, 0);
    vec4 centerColorIp = texelFetch(preRenderColorIp, texel, 0);
    vec4 centerOColor = texelFetch(preRenderOriginalColor, texel, 0);
    vec4 centerId = texelFetch(preRenderId, texel, 0);

    int centerIdw = int(centerId.w * 255.0);
    int centerLightNum = centerIdw / 2;
    int centerShadow = centerIdw % 2;

    renderId = centerId;

    vec4 centerOId = texelFetch(preRenderOriginalId, texel, 0);
    vec4 color = vec4(0);
    float count = 0.0;

    const ivec2 stencil1[4] = ivec2[4](
                     ivec2(-1, 0), 
      ivec2( 0, -1),              ivec2( 0, 1),
                     ivec2( 1, 0)
    );
    
    const vec2 stencil2[21] = vec2[21](
                  vec2(-2, -1), vec2(-2, 0), vec2(-2, 1),
    vec2(-1, -2), vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(-1, 2),
    vec2( 0, -2), vec2( 0, -1), vec2( 0, 0), vec2( 0, 1), vec2( 0, 2),
    vec2( 1, -2), vec2( 1, -1), vec2( 1, 0), vec2( 1, 1), vec2( 1, 2),
                  vec2( 2, -1), vec2( 2, 0), vec2( 2, 1)
    );

    const vec2 stencil3[37] = vec2[37](
                                  vec2(-3, -1), vec2(-3, 0), vec2(-3, 1), 
                    vec2(-2, -2), vec2(-2, -1), vec2(-2, 0), vec2(-2, 1), vec2(-2, 2),
      vec2(-1, -3), vec2(-1, -2), vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(-1, 2), vec2(-1, 3),
      vec2( 0, -3), vec2( 0, -2), vec2( 0, -1), vec2( 0, 0), vec2( 0, 1), vec2( 0, 2), vec2( 0, 3),
      vec2( 1, -3), vec2( 1, -2), vec2( 1, -1), vec2( 1, 0), vec2( 1, 1), vec2( 1, 2), vec2( 1, 3),
                    vec2( 2, -2), vec2( 2, -1), vec2( 2, 0), vec2( 2, 1), vec2( 2, 2),
                                  vec2( 3, -1), vec2( 3, 0), vec2( 3, 1)
    );
    
    if (centerOId.w != 0.0 && centerColorIp.w != 0.0) {
      vec4 id = centerId;

      mat4 ids = mat4(0);
      mat4 oIds = mat4(0);

      vec4 ipws = vec4(0);
      for (int i = 0; i < 4; i++) {
        ids[i] = texelFetch(preRenderId, texel + stencil1[i], 0);
        oIds[i] = texelFetch(preRenderOriginalId, texel + stencil1[i], 0);
        ipws[i] = texelFetch(preRenderColorIp, texel + stencil1[i], 0).w;
      }

      ivec4 vote = ivec4(0);
      for (int i = 0; i < 4; i++) {
        if (ipws[i] == 0.0) {
          vote[i] = 1;
          if (ids[i].xyz == id.xyz && oIds[i] == centerOId) vote[i] ++;
          for (int j = i + 1; j < 4; j++) if (ids[i].xyz == ids[j].xyz && oIds[i] == oIds[j]) vote[i] ++;
        }
      }

      int maxVote = vote[0];
      int idNumber = 0;

      for (int i = 1; i < 4; i++) {
        if (vote[i] >= maxVote) {
          maxVote = vote[i];
          idNumber = i;
        }
      }
      
      renderId = ids[idNumber];
      renderColorIp.w = max(1.0 - sign(float(maxVote)), 0.0);
    }

    if (centerOColor.w == 0.0) {
      color = centerColor;
      count = 1.0;
    } else {
      for (int i = 0; i < 37; i++) {
        ivec2 coord = texel + ivec2(stencil3[i] * (1.0 + centerOColor.w) * (1.0 + centerOColor.w) * 3.5);
        
        vec4 id = texelFetch(preRenderId, coord, 0);
        vec4 originalId = texelFetch(preRenderOriginalId, coord, 0);

        int idW = int(id.w * 255.0);
        int lightNum = idW / 2;
        int shadow = idW % 2;    

        vec4 nextColor = texelFetch(preRenderColor, coord, 0);
        vec4 nextColorIp = texelFetch(preRenderColorIp, coord, 0);
        if (centerId.xyz == id.xyz && centerOId == originalId && (centerLightNum != lightNum || centerShadow == shadow)) {
          color += nextColor + nextColorIp * 256.0;
          count ++;
        }
      }
    }
    
    
    float invCount = 1.0 / count;
    renderColor = sign(centerColor.w) * vec4(mod(color.xyz * invCount, 1.0), centerColor.w);
    // Set out color for render texture for the antialiasing filter
    renderColorIp = sign(centerColor.w) * vec4(floor(color.xyz * invCount) * INV_256, renderColorIp.w);
  }
  `;
  #secondFilterGlsl = `#version 300 es
  #define INV_256 0.00390625
  
  precision highp float;
  in vec2 clipSpace;

  uniform sampler2D preRenderColor;
  uniform sampler2D preRenderColorIp;
  uniform sampler2D preRenderOriginalColor;
  uniform sampler2D preRenderId;
  uniform sampler2D preRenderOriginalId;

  layout(location = 0) out vec4 renderColor;
  layout(location = 1) out vec4 renderColorIp;
  layout(location = 2) out vec4 renderOriginalColor;

  void main(){
    // Get texture size
    ivec2 texel = ivec2(vec2(textureSize(preRenderColor, 0)) * clipSpace);
    vec4 centerColor = texelFetch(preRenderColor, texel, 0);
    vec4 centerColorIp = texelFetch(preRenderColorIp, texel, 0);
    vec4 centerOColor = texelFetch(preRenderOriginalColor, texel, 0);
    vec4 centerId = texelFetch(preRenderId, texel, 0);
    vec4 centerOId = texelFetch(preRenderOriginalId, texel, 0);
    vec4 color = centerColor + vec4(centerColorIp.xyz, 0.0) * 256.0;;
    vec4 oColor = centerOColor;
    float ipw = centerColorIp.w;
    float count = 1.0;
    float oCount = 1.0;


    const vec2 stencil2[20] = vec2[20](
                  vec2(-2, -1), vec2(-2, 0), vec2(-2, 1),
    vec2(-1, -2), vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(-1, 2),
    vec2( 0, -2), vec2( 0, -1),              vec2( 0, 1), vec2( 0, 2),
    vec2( 1, -2), vec2( 1, -1), vec2( 1, 0), vec2( 1, 1), vec2( 1, 2),
                  vec2( 2, -1), vec2( 2, 0), vec2( 2, 1)
    );

    const vec2 stencil3[36] = vec2[36](
                                vec2(-3, -1), vec2(-3, 0), vec2(-3, 1), 
                  vec2(-2, -2), vec2(-2, -1), vec2(-2, 0), vec2(-2, 1), vec2(-2, 2),
    vec2(-1, -3), vec2(-1, -2), vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(-1, 2), vec2(-1, 3),
    vec2( 0, -3), vec2( 0, -2), vec2( 0, -1),              vec2( 0, 1), vec2( 0, 2), vec2( 0, 3),
    vec2( 1, -3), vec2( 1, -2), vec2( 1, -1), vec2( 1, 0), vec2( 1, 1), vec2( 1, 2), vec2( 1, 3),
                  vec2( 2, -2), vec2( 2, -1), vec2( 2, 0), vec2( 2, 1), vec2( 2, 2),
                                vec2( 3, -1), vec2( 3, 0), vec2( 3, 1)
    );
    
    // Apply blur filter on image
    for (int i = 0; i < 36; i++) {
      ivec2 coord = texel + ivec2(stencil3[i] * (1.0 + 2.0 * tanh(centerOColor.w + centerOId.w * 4.0)));
      vec4 id = texelFetch(preRenderId, coord, 0);
      vec4 nextOId = texelFetch(preRenderOriginalId, coord, 0);
      vec4 nextColor = texelFetch(preRenderColor, coord, 0);
      vec4 nextColorIp = texelFetch(preRenderColorIp, coord, 0);
      vec4 nextOColor = texelFetch(preRenderOriginalColor, coord, 0);

      if (centerOId.xyz == nextOId.xyz) {
        if (min(centerOId.w, nextOId.w) > 0.1 && (id == centerId || max(nextColorIp.w, centerColorIp.w) >= 0.1)) {
            color += nextColor + vec4(nextColorIp.xyz, 0.0) * 256.0;
            count ++;
            ipw += nextColorIp.w;
            oColor += nextOColor;
            oCount ++;
        } else if (id.xyz == centerId.xyz) {
          color += nextColor + vec4(nextColorIp.xyz, 0.0) * 256.0;
          count ++;
        }
      }

      
    }

    float invCount = 1.0 / count;
    renderColor = centerColor.w * vec4(mod(color.xyz * invCount, 1.0), color.w * invCount);
    // Set out color for render texture for the antialiasing filter
    renderColorIp =  centerColor.w * vec4(floor(color.xyz * invCount) * INV_256, ipw);
    renderOriginalColor = centerColor.w * oColor / oCount;
  }
  `;
  #finalFilterGlsl = `#version 300 es
  precision highp float;
  in vec2 clipSpace;
  uniform sampler2D preRenderColor;
  uniform sampler2D preRenderColorIp;
  uniform sampler2D preRenderOriginalColor;
  uniform sampler2D preRenderId;
  uniform sampler2D preRenderOriginalId;
  uniform int hdr;
  out vec4 outColor;
  void main(){
    // Get texture size
    ivec2 texel = ivec2(vec2(textureSize(preRenderColor, 0)) * clipSpace);
    vec4 centerColor = texelFetch(preRenderColor, texel, 0);
    vec4 centerColorIp = texelFetch(preRenderColorIp, texel, 0);
    vec4 centerOColor = texelFetch(preRenderOriginalColor, texel, 0);
    vec4 centerId = texelFetch(preRenderId, texel, 0);
    vec4 centerOId = texelFetch(preRenderOriginalId, texel, 0);
    vec4 color = vec4(0);
    vec4 oColor = vec4(0);
    float count = 0.0;
    float oCount = 0.0;

    const vec2 stencil3[37] = vec2[37](
                                vec2(-3, -1), vec2(-3, 0), vec2(-3, 1), 
                  vec2(-2, -2), vec2(-2, -1), vec2(-2, 0), vec2(-2, 1), vec2(-2, 2),
    vec2(-1, -3), vec2(-1, -2), vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(-1, 2), vec2(-1, 3),
    vec2( 0, -3), vec2( 0, -2), vec2( 0, -1), vec2( 0, 0), vec2( 0, 1), vec2( 0, 2), vec2( 0, 3),
    vec2( 1, -3), vec2( 1, -2), vec2( 1, -1), vec2( 1, 0), vec2( 1, 1), vec2( 1, 2), vec2( 1, 3),
                  vec2( 2, -2), vec2( 2, -1), vec2( 2, 0), vec2( 2, 1), vec2( 2, 2),
                                vec2( 3, -1), vec2( 3, 0), vec2( 3, 1)
    );

    // Apply blur filter on image
    for (int i = 0; i < 37; i++) {
      ivec2 coord = texel + ivec2(stencil3[i] * (0.7 + 2.0 * tanh(centerOColor.w + centerOId.w * 4.0)));
      vec4 id = texelFetch(preRenderId, coord, 0);
      vec4 nextOId = texelFetch(preRenderOriginalId, coord, 0);
      vec4 nextColor = texelFetch(preRenderColor, coord, 0);
      vec4 nextColorIp = texelFetch(preRenderColorIp, coord, 0);
      vec4 nextOColor = texelFetch(preRenderOriginalColor, coord, 0);

      // Test if at least one pixel is translucent and they are pixels of the same object.
      bool blurTranslucent = max(nextColorIp.w, centerColorIp.w) != 0.0 && min(centerOId.w, nextOId.w) > 0.0;
      if (blurTranslucent && centerOId.xyz == nextOId.xyz) {
        oColor += nextOColor;
        oCount ++;
      }
      
      if ((blurTranslucent || centerId.xyz == id.xyz) && centerOId.xyz == nextOId.xyz) {
        color += nextColor + nextColorIp * 255.0;
        count ++;
      }
    }
    
    if (centerColor.w > 0.0) {
      // Set out targetColor for render texture for the antialiasing filter
      vec3 finalColor = color.xyz / count;
      finalColor *= (oCount == 0.0) ? centerOColor.xyz : oColor.xyz / oCount;

      if (hdr == 1) {
        // Apply Reinhard tone mapping
        finalColor = finalColor / (finalColor + vec3(1.0));
        // Gamma correction
        float gamma = 0.8;
        finalColor = pow(4.0 * finalColor, vec3(1.0 / gamma)) / 4.0 * 1.3;
      }
      outColor = vec4(finalColor, 1.0);
    } else {
      outColor = vec4(0);
    }
    // outColor = vec4(centerId.xyz, 0.0);
  }
  `;
  // Create new PathTracer from canvas and setup movement
  constructor (canvas, camera, scene) {
    this.#canvas = canvas;
    this.camera = camera;
    this.scene = scene;
    this.#gl = canvas.getContext('webgl2');


    
    this.halt = () => {
      try {
        this.#gl.loseContext();
      } catch (e) {
        console.warn("Unable to lose previous context, reload page in case of performance issue");
      }
      this.#halt = true;
    }
    this.#antialiasing = 'taa';
  }
  
  // Make canvas read only accessible
  get canvas () {
    return this.#canvas;
  }

  get antialiasing () {
    if (this.#antialiasing === null) return 'none';
    return this.#antialiasing;
  }

  set antialiasing (val) {
    switch (val.toLowerCase()) {
      case 'fxaa':
        this.#antialiasing = val;
        this.#AAObject = new FXAA(this.#gl);
        break;
      case 'taa':
        this.#antialiasing = val;
        this.#AAObject = new TAA(this.#gl);
        break;
      default:
        this.#antialiasing = null;
        this.#AAObject = null;
    }
  }

  // Functions to update texture atlases to add more textures during runtime
	async #updateAtlas (list) {
		// Test if there is even a texture
		if (list.length === 0) {
			this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, 1, 1, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, new Uint8Array(4));
			return;
		}

		const [width, height] = this.scene.standardTextureSizes;
		const textureWidth = Math.floor(2048 / width);
		const canvas = document.createElement('canvas');
		const ctx = canvas.getContext('2d');

		canvas.width = width * textureWidth;
		canvas.height = height * list.length;
		ctx.imageSmoothingEnabled = false;
    // TextureWidth for third argument was 3 for regular textures
		list.forEach(async (texture, i) => ctx.drawImage(texture, width * (i % textureWidth), height * Math.floor(i / textureWidth), width, height));

    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, canvas);
	}

  async #updateTextureAtlas () {
    // Don't build texture atlas if there are no changes.
    if (this.scene.textures.length === this.#textureList.length && this.scene.textures.every((e, i) => e === this.#textureList[i])) return;
    this.#textureList = this.scene.textures;

    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#textureAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
		this.#updateAtlas(this.scene.textures);
  }

  async #updatePbrAtlas () {
    // Don't build texture atlas if there are no changes.
    if (this.scene.pbrTextures.length === this.#pbrList.length && this.scene.pbrTextures.every((e, i) => e === this.#pbrList[i])) return;
    this.#pbrList = this.scene.pbrTextures;

    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#pbrAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
		this.#updateAtlas(this.scene.pbrTextures);
  }

  async #updateTranslucencyAtlas () {
    // Don't build texture atlas if there are no changes.
    if (this.scene.translucencyTextures.length === this.#translucencyList.length && this.scene.translucencyTextures.every((e, i) => e === this.#translucencyList[i])) return;
    this.#translucencyList = this.scene.translucencyTextures;

    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#translucencyAtlas);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
		this.#updateAtlas(this.scene.translucencyTextures);
  }

  // Functions to update vertex and light source data textures
  async updatePrimaryLightSources () {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#lightTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
		// Don't update light sources if there is none
		if (this.scene.primaryLightSources.length === 0) {
			this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 1, 1, 0, this.#gl.RGB, this.#gl.FLOAT, new Float32Array(3));
			return;
		}

    var lightTexArray = [];
    // Iterate over light sources
		this.scene.primaryLightSources.forEach(lightSource => {
			// Set intensity to lightSource intensity or default if not specified
			const intensity = Object.is(lightSource.intensity)? this.scene.defaultLightIntensity : lightSource.intensity;
			const variation = Object.is(lightSource.variation)? this.scene.defaultLightVariation : lightSource.variation;
			// push location of lightSource and intensity to texture, value count has to be a multiple of 3 rgb format
			lightTexArray.push(lightSource[0], lightSource[1], lightSource[2], intensity, variation, 0);
		});

    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 2, this.scene.primaryLightSources.length, 0, this.#gl.RGB, this.#gl.FLOAT, Float32Array.from(lightTexArray));
  }

  async updateScene () {
    // Track ids
    let walkGraph = (item) => {
      if (item.static) {
        // Adjust id that wasn't increased so far due to bounding boxes missing in the objectLength array
        textureLength += item.textureLength;
        this.#bufferLength += item.bufferLength;
      } else if (Array.isArray(item) || item.indexable) {
        // Item is dynamic and indexable, recursion continues
        if (item.length === 0) return 0;
        textureLength ++;
        // Iterate over all sub elements
        for (let i = 0; i < item.length; i++) walkGraph(item[i]);
      } else {
        // Give item new id property to identify vertex in fragment shader
        textureLength += item.length;
        this.#bufferLength += item.length;
      }
    }
    
    // Build simple AABB tree (Axis aligned bounding box)
    let fillData = (item) => {
      let minMax = [];
      if (item.static) {
        // Item is static and precaluculated values can just be used
        geometryTextureArray.set(item.geometryTextureArray, texturePos * 9);
        sceneTextureArray.set(item.sceneTextureArray, texturePos * 27);
        // Update id buffer
        for (let i = 0; i < item.bufferLength; i++) this.#triangleIdBufferArray[bufferPos + i] = texturePos + item.idBuffer[i];
        // Adjust id that wasn't increased so far due to bounding boxes missing in the objectLength array
        texturePos += item.textureLength;
        bufferPos += item.bufferLength;
        minMax = item.minMax;
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
        for (let i = 0; i < 6; i++) geometryTextureArray[oldTexturePos * 9 + i] = minMax[i];
        geometryTextureArray[oldTexturePos * 9 + 6] = texturePos - oldTexturePos - 1;
      } else {
        // Item is dynamic and non-indexable.
        // a, b, c, color, normal, texture_nums, UVs1, UVs2 per triangle in item
        geometryTextureArray.set(item.geometryTextureArray, texturePos * 9);
        sceneTextureArray.set(item.sceneTextureArray, texturePos * 27);
        // Push texture positions of triangles into triangle id array
        for (let i = 0; i < item.length; i ++) this.#triangleIdBufferArray[bufferPos ++] = texturePos ++;
        // Declare bounding volume of object
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

    // Lengths that will be probed by the walkGraph method
    let textureLength = 0;
    this.#bufferLength = 0;

    // Walk entire scene graph to receive array sizes and preallocate
    walkGraph(this.scene.queue);
    // Triangle id in texture
    let texturePos = 0;
    let bufferPos = 0;
    // Preallocate arrays for scene graph as a texture
    let geometryTexWidth = 3 * 3 * 256;
    let sceneTexWidth = 9 * 3 * 256;
    // Round up data to next higher multiple of 2304 (3 pixels * 3 values * 256 vertecies per line)
    let geometryTextureArray = new Float32Array(Math.ceil(textureLength * 9 / geometryTexWidth) * geometryTexWidth);
    // Round up data to next higher multiple of 5376 (9 pixels * 3 values * 256 vertecies per line)
    let sceneTextureArray = new Float32Array(Math.ceil(textureLength * 27 / sceneTexWidth) * sceneTexWidth);
    // Create new id buffer array
    this.#triangleIdBufferArray = new Int32Array(this.#bufferLength);
    // Fill scene describing texture with data pixels
    fillData(this.scene.queue);
    // Calculate DataHeight by dividing value count through 2304 (3 pixels * 3 values * 256 vertecies per line)
    var geometryTextureArrayHeight = geometryTextureArray.length / geometryTexWidth;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#geometryTexture);
    // Tell webgl to use 4 bytes per value for the 32 bit floats
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 3 * 256, geometryTextureArrayHeight, 0, this.#gl.RGB, this.#gl.FLOAT, geometryTextureArray);
    // this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB16F, 3 * 256, geometryTextureArrayHeight, 0, this.#gl.RGB, this.#gl.HALF_FLOAT, new Float16Array(geometryTextureArray));

    // Calculate DataHeight by dividing value count through 5376 (9 pixels * 3 values * 256 vertecies per line)
    let sceneTextureArrayHeight = sceneTextureArray.length / sceneTexWidth;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#sceneTexture);
    GLLib.setTexParams(this.#gl);
    // Tell webgl to use 2 bytes per value for the 16 bit floats
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    // Set data texture details and tell webgl, that no mip maps are required
    
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 9 * 256, sceneTextureArrayHeight, 0, this.#gl.RGB, this.#gl.FLOAT, sceneTextureArray);
    // this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB16F, 7 * 256, sceneTextureArrayHeight, 0, this.#gl.RGB, this.#gl.HALF_FLOAT, new Float16Array(sceneTextureArray));
    // this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.SRGB8, 1280, sceneDataHeight, 0, this.#gl.RGB, this.#gl.UNSIGNED_BYTE, new Uint8Array(sceneData));
  }

  async render() {
    // start rendering
    let rt = this;
    // Allow frame rendering
    rt.#halt = false;
    // Internal GL objects
    let Program;
    let TempProgram, TempHdrLocation;
    // Init Buffers
    let triangleIdBuffer, vertexIdBuffer;
    // Framebuffer, Post Program buffers and textures
    let Framebuffer, TempFramebuffer, OriginalIdRenderTexture;
    let HdrLocation;
    // Set post program array
    let PostProgram = [];
    // Create textures for Framebuffers in PostPrograms
    let RenderTexture = new Array(5);
    let IpRenderTexture = new Array(5);
    let DepthTexture = new Array(5);
    let OriginalRenderTexture = new Array(2);
    let IdRenderTexture = new Array(2);

    let TempTexture = new Array(this.temporalSamples);
    let TempIpTexture = new Array(this.temporalSamples);
    let TempIdTexture = new Array(this.temporalSamples);
    let TempOriginalIdTexture = new Array(this.temporalSamples);
    
    let TempTex = new Array(this.temporalSamples);
    let TempIpTex = new Array(this.temporalSamples);
    let TempIdTex = new Array(this.temporalSamples);
    let TempOriginalIdTex = new Array(this.temporalSamples);

    for (let i = 0; i < this.temporalSamples; i++) {
      TempTexture[i] = this.#gl.createTexture();
      TempIpTexture[i] = this.#gl.createTexture();
      TempIdTexture[i] = this.#gl.createTexture();
      TempOriginalIdTexture[i] = this.#gl.createTexture();
    }

    let RenderTex = new Array(5);
    let IpRenderTex = new Array(5);
    let OriginalRenderTex = new Array(5);
    let IdRenderTex = new Array(5);
    let OriginalIdRenderTex = new Array(5);
    // Create caching textures for denoising
		for (let i = 0; i < 5; i ++) {
				RenderTexture[i] = this.#gl.createTexture();
				IpRenderTexture[i] = this.#gl.createTexture();
        if (i < 2) OriginalRenderTexture[i] = this.#gl.createTexture();
        if (i < 2) IdRenderTexture[i] = this.#gl.createTexture();
				DepthTexture[i] = this.#gl.createTexture();
    }
    // Create buffers for vertices in PostPrograms
    let PostVertexBuffer = new Array(5);
    let PostFramebuffer = new Array(5);
    // Create different Vaos for different rendering/filtering steps in pipeline
    let Vao = this.#gl.createVertexArray();

    let TempVao = this.#gl.createVertexArray();
		// Generate enough Vaos for each denoise pass
    let PostVao = new Array(5).map(() => this.#gl.createVertexArray());
    // Function to handle canvas resize
    let resize = () => {
			const canvas = rt.canvas;
    	canvas.width = canvas.clientWidth * rt.renderQuality;
    	canvas.height = canvas.clientHeight * rt.renderQuality;
    	rt.#gl.viewport(0, 0, canvas.width, canvas.height);
      // Rebuild textures with every resize
      renderTextureBuilder();
      if (rt.#AAObject != null) this.#AAObject.buildTexture();

      rt.firstPasses = 3;//Math.max(Math.round(Math.min(canvas.width, canvas.height) / 600), 3);
      rt.secondPasses = 3;//Math.max(Math.round(Math.min(canvas.width, canvas.height) / 500), 3);
    }
    // Init canvas parameters and textures with resize
    resize();
    // Handle canvas resize
    window.addEventListener('resize', resize);

    // Internal render engine Functions
    let frameCycle = engineState => {
      let timeStamp = performance.now();
      // Update Textures
      rt.#updateTextureAtlas();
      rt.#updatePbrAtlas();
      rt.#updateTranslucencyAtlas();
      // Set scene graph
      rt.updateScene();
      // build bounding boxes for scene first
      rt.updatePrimaryLightSources();
      // Check if recompile is required
      if (engineState.filter !== rt.filter || engineState.renderQuality !== rt.renderQuality) {
        resize();
        engineState = prepareEngine();
      }
      // Render new Image, work through queue
      renderFrame(engineState);
      // Update frame counter
      engineState.intermediateFrames ++;
      engineState.temporalFrame = (engineState.temporalFrame + 1) % this.temporalSamples;
      // Calculate Fps
			let timeDifference = timeStamp - engineState.lastTimeStamp;
      if (timeDifference > 500) {
        rt.fps = (1000 * engineState.intermediateFrames / timeDifference).toFixed(0);
        engineState.lastTimeStamp = timeStamp;
        engineState.intermediateFrames = 0;
      }
      // Request browser to render frame with hardware acceleration
      if (!rt.#halt) setTimeout(function () {
        requestAnimationFrame(() => frameCycle(engineState))
      }, 1000 / rt.fpsLimit);
    }

    let pathtracingPass = engineState => {
      // console.log(uniformLocations);
      let jitter = {x: 0, y: 0};
      if (this.#antialiasing !== null && (this.#antialiasing.toLocaleLowerCase() === 'taa')) jitter = this.#AAObject.jitter(rt.#canvas);

      this.#gl.bindVertexArray(Vao);
      this.#gl.useProgram(Program);

      [this.#geometryTexture, this.#sceneTexture, this.#pbrAtlas, this.#translucencyAtlas, this.#textureAtlas, this.#lightTexture].forEach((texture, i) => {
        this.#gl.activeTexture(rt.#gl.TEXTURE0 + i);
        this.#gl.bindTexture(rt.#gl.TEXTURE_2D, texture);
      });
      // Set uniforms for shaders
      // console.log(engineState.intermediateFrames);
      let uniformValues = [
        // 3d position of camera
        [this.camera.x, this.camera.y, this.camera.z],
        // sphearical rotation of camera
        [this.camera.fx, this.camera.fy],
        // fov and X/Y ratio of screen
        [this.camera.fov, this.#gl.canvas.width / this.#gl.canvas.height, jitter.x, jitter.y],
        // amount of samples per ray
        [this.samplesPerRay],
        // max reflections of ray
        [this.maxReflections],
        // min importancy of light ray
        [this.minImportancy],
        // render for filter or not
        [this.filter],
        // render for temporal or not
        [this.temporal],
        // ambient background color
        [this.scene.ambientLight[0], this.scene.ambientLight[1], this.scene.ambientLight[2]],
        // random seed for monte carlo pathtracing
        [this.temporal ? engineState.temporalFrame : 0],
        // width of textures
        [Math.floor(2048 / this.scene.standardTextureSizes[0])],
        // whole triangle based geometry scene graph, triangle attributes for scene graph
        [0], [1],
        // pbr texture, translucency texture, texture
        [2], [3], [4],
        // data texture of all primary light sources
        [5]
      ];

      PathtracingUniformFunctionTypes.forEach((functionType, i) => this.#gl[functionType](engineState.pathtracingUniformLocations[i], ... uniformValues[i]));
      
      // Set buffers
      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, triangleIdBuffer);
      rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, rt.#triangleIdBufferArray, rt.#gl.DYNAMIC_DRAW);
      // console.log(rt.#triangleIdBufferArray);
      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, vertexIdBuffer);
      rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, new Int32Array([0, 1, 2]), rt.#gl.STATIC_DRAW);
      // Actual drawcall
      rt.#gl.drawArraysInstanced(rt.#gl.TRIANGLES, 0, 3, rt.#bufferLength);
    }

    let renderFrame = engineState => {
      // Configure where the final image should go
      if (rt.temporal || rt.filter || rt.#antialiasing) {
        rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, Framebuffer);
        rt.#gl.drawBuffers([
          rt.#gl.COLOR_ATTACHMENT0,
          rt.#gl.COLOR_ATTACHMENT1,
          rt.#gl.COLOR_ATTACHMENT2,
          rt.#gl.COLOR_ATTACHMENT3,
          rt.#gl.COLOR_ATTACHMENT4,
          rt.#gl.COLOR_ATTACHMENT5
        ]);
  
        // Configure framebuffer for color and depth
        if (rt.temporal) {
          // Rotate textures for temporal filter
          TempTexture.unshift(TempTexture.pop());
          TempIpTexture.unshift(TempIpTexture.pop());
          TempIdTexture.unshift(TempIdTexture.pop());
          TempOriginalIdTexture.unshift(TempOriginalIdTexture.pop());

          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, TempTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT1, rt.#gl.TEXTURE_2D, TempIpTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, OriginalRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT3, rt.#gl.TEXTURE_2D, IdRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT4, rt.#gl.TEXTURE_2D, TempOriginalIdTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT5, rt.#gl.TEXTURE_2D, TempIdTexture[0], 0);

          OriginalIdRenderTexture = TempOriginalIdTexture[0];
        } else if (rt.filter) {
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, RenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT1, rt.#gl.TEXTURE_2D, IpRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, OriginalRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT3, rt.#gl.TEXTURE_2D, IdRenderTexture[0], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT4, rt.#gl.TEXTURE_2D, OriginalIdRenderTexture, 0);
        } else if (rt.#antialiasing) {
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
        }
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.DEPTH_ATTACHMENT, rt.#gl.TEXTURE_2D, DepthTexture[0], 0);
      }

      // Clear depth and color buffers from last frame
      rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);
      pathtracingPass(engineState);

      if (rt.temporal) {
        if (rt.filter || rt.#antialiasing) {
            // Temporal sample averaging
          rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, TempFramebuffer);
          // Set attachments to use for framebuffer
          rt.#gl.drawBuffers([
            rt.#gl.COLOR_ATTACHMENT0,
            rt.#gl.COLOR_ATTACHMENT1
          ]);

          // Configure framebuffer for color and depth
          if (rt.filter) {
            rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, RenderTexture[0], 0);
            rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT1, rt.#gl.TEXTURE_2D, IpRenderTexture[0], 0);
          } else if (rt.#antialiasing) {
            rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
          }
        } else {
          // Render to canvas now
          this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, null);
        }

        [TempTexture, TempIpTexture, TempIdTexture, TempOriginalIdTexture].flat().forEach(function(item, i){
          rt.#gl.activeTexture(rt.#gl.TEXTURE0 + i);
          rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
        });

        rt.#gl.bindVertexArray(TempVao);
        rt.#gl.useProgram(TempProgram);

        rt.#gl.uniform1i(TempHdrLocation, rt.hdr);

        for (let i = 0; i < rt.temporalSamples; i++) {
          rt.#gl.uniform1i(TempTex[i], i);
          rt.#gl.uniform1i(TempIpTex[i], rt.temporalSamples + i);
          rt.#gl.uniform1i(TempIdTex[i], 2 * rt.temporalSamples + i);
          rt.#gl.uniform1i(TempOriginalIdTex[i], 3 * rt.temporalSamples + i);
        }
        
        // PostTemporal averaging processing drawcall
        rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, 6);
      }

      if (rt.filter) {
        // Apply post processing filter
        let n = 0;
        let nId = 0;
        let nOriginal = 0;
        for (let i = 0; i < rt.firstPasses + rt.secondPasses; i++) {
          // Look for next free compatible program slot
          let np = (i % 2) ^ 1;
          let npOriginal = ((i - rt.firstPasses) % 2) ^ 1;
          if (rt.firstPasses <= i) np += 2;
          // Configure where the final image should go
          rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, PostFramebuffer[n]);
          // Set attachments to use for framebuffer
          rt.#gl.drawBuffers([
            rt.#gl.COLOR_ATTACHMENT0,
            rt.#gl.COLOR_ATTACHMENT1,
            rt.#gl.COLOR_ATTACHMENT2
          ]);
          // Configure framebuffer for color and depth
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, RenderTexture[np], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT1, rt.#gl.TEXTURE_2D, IpRenderTexture[np], 0);
          if (rt.firstPasses <= i - 2) rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, OriginalRenderTexture[npOriginal], 0);
          else rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT2, rt.#gl.TEXTURE_2D, IdRenderTexture[np], 0);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.DEPTH_ATTACHMENT, rt.#gl.TEXTURE_2D, DepthTexture[np], 0);
          // Clear depth and color buffers from last frame
          rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);
          // Push pre rendered textures to next shader (post processing)
          [RenderTexture[n], IpRenderTexture[n], OriginalRenderTexture[nOriginal], IdRenderTexture[nId], OriginalIdRenderTexture].forEach(function(item, i){
            rt.#gl.activeTexture(rt.#gl.TEXTURE0 + i);
            rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
          });
          // Switch program and Vao
          rt.#gl.useProgram(PostProgram[n]);
          rt.#gl.bindVertexArray(PostVao[n]);
          // Pass pre rendered texture to shader
          rt.#gl.uniform1i(RenderTex[n], 0);
          rt.#gl.uniform1i(IpRenderTex[n], 1);
          // Pass original color texture to GPU
          rt.#gl.uniform1i(OriginalRenderTex[n], 2);
          // Pass vertex_id texture to GPU
          rt.#gl.uniform1i(IdRenderTex[n], 3);
          // Pass vertex_id of original vertex as a texture to GPU
          rt.#gl.uniform1i(OriginalIdRenderTex[n], 4);
          // Post processing drawcall
          rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, 6);
          // Save current program slot in n for next pass
          n = np;

          if (rt.firstPasses <= i) nOriginal = npOriginal;
          else nId = np;
        }

        // Last denoise pass
        rt.#gl.drawBuffers([rt.#gl.COLOR_ATTACHMENT0, rt.#gl.COLOR_ATTACHMENT1]);
        // Configure framebuffer for color and depth
        if (rt.#antialiasing) {
          // Configure where the final image should go
          rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, PostFramebuffer[4]);
          rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
        } else {
          // Render to canvas now
          this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, null);
        }

        let index = 2 + (rt.firstPasses + rt.secondPasses) % 2;
        let indexId = rt.firstPasses % 2;
        let indexOriginal = rt.secondPasses % 2;
        // Push pre rendered textures to next shader (post processing)
        [RenderTexture[index], IpRenderTexture[index], OriginalRenderTexture[indexOriginal], IdRenderTexture[indexId], OriginalIdRenderTexture].forEach(function(item, i){
          rt.#gl.activeTexture(rt.#gl.TEXTURE0 + i);
          rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
        });
        // Switch program and VAO
        rt.#gl.useProgram(PostProgram[4]);
        rt.#gl.bindVertexArray(PostVao[4]);
        // Pass pre rendered texture to shader
        rt.#gl.uniform1i(RenderTex[4], 0);
        rt.#gl.uniform1i(IpRenderTex[4], 1);
        // Pass original color texture to GPU
        rt.#gl.uniform1i(OriginalRenderTex[4], 2);
        // Pass vertex_id texture to GPU
        rt.#gl.uniform1i(IdRenderTex[4], 3);
        // Pass vertex_id of original vertex as a texture to GPU
        rt.#gl.uniform1i(OriginalIdRenderTex[4], 4);
        // Pass hdr variable to last post processing shader
        rt.#gl.uniform1i(HdrLocation, rt.hdr);
        // Post processing drawcall
        rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, 6);
      }

      // Apply antialiasing shader if enabled
      if (rt.#antialiasing) this.#AAObject.renderFrame();
    }


    function renderTextureBuilder () {
      // Init textures for denoiser
      [TempTexture, TempIpTexture, TempIdTexture, TempOriginalIdTexture, RenderTexture, IpRenderTexture, OriginalRenderTexture, IdRenderTexture, [OriginalIdRenderTexture]].forEach((parent) => {
        parent.forEach(function(item){
          rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
          rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.RGBA, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.RGBA, rt.#gl.UNSIGNED_BYTE, null);
          GLLib.setTexParams(rt.#gl);
        });
      });
      // Init single channel depth textures
      DepthTexture.forEach((item) => {
        rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, item);
        rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.DEPTH_COMPONENT24, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.DEPTH_COMPONENT, rt.#gl.UNSIGNED_INT, null);
        GLLib.setTexParams(rt.#gl);
      });
    }

    let prepareEngine = () => {
      let initialState = {
        // Attributes to meassure frames per second
        intermediateFrames: 0,
        lastTimeStamp: performance.now(),
        // Count frames to match with temporal accumulation
        temporalFrame: 0,
        // Parameters to compare against current state of the engine and recompile shaders on change
        filter: rt.filter,
        renderQuality: rt.renderQuality
      };

      let newLine = `
      `;
      // Build tempShader
      this.#tempGlsl = `#version 300 es
      precision highp float;
      in vec2 clipSpace;
      uniform int hdr;
      `;

      for (let i = 0; i < rt.temporalSamples; i++) {
        this.#tempGlsl += 'uniform sampler2D cache' + i + ';' + newLine;
        this.#tempGlsl += 'uniform sampler2D cacheIp' + i + ';' + newLine;
        this.#tempGlsl += 'uniform sampler2D cacheId' + i + ';' + newLine;
        this.#tempGlsl += 'uniform sampler2D cacheOriginalId' + i + ';' + newLine;
      }

      if (rt.filter) {
        this.#tempGlsl += `
        layout(location = 0) out vec4 renderColor;
        layout(location = 1) out vec4 renderColorIp;
        `;
      } else {
        this.#tempGlsl += `
        layout(location = 0) out vec4 renderColor;
        `;
      }

      this.#tempGlsl += `void main () {
        ivec2 texel = ivec2(vec2(textureSize(cache0, 0)) * clipSpace);
        vec4 id = texelFetch(cacheId0, texel, 0);
        vec4 originalId = texelFetch(cacheOriginalId0, texel, 0);
        float counter = 1.0;
        float glassCounter = 1.0;
        
        float centerW = texelFetch(cache0, texel, 0).w;
        vec3 color = texelFetch(cache0, texel, 0).xyz + texelFetch(cacheIp0, texel, 0).xyz * 256.0;
        float glassFilter = texelFetch(cacheIp0, texel, 0).w;
      `;

      for (let i = 1; i < rt.temporalSamples; i += 4) {
        this.#tempGlsl += 'mat4 c' + i + ' = mat4(';
        for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < rt.temporalSamples ? 'texelFetch(cache' + j + ', texel, 0),' : 'vec4(0),') + newLine;
        this.#tempGlsl += (i + 3 < rt.temporalSamples ? 'texelFetch(cache' + (i + 3) + ', texel, 0) ' + newLine + ' ); ' : 'vec4(0) ' + newLine + '); ') + newLine;

        this.#tempGlsl += 'mat4 ip' + i + ' = mat4(';
        for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < rt.temporalSamples ? 'texelFetch(cacheIp' + j + ', texel, 0),' : 'vec4(0),') + newLine;
        this.#tempGlsl += (i + 3 < rt.temporalSamples ? 'texelFetch(cacheIp' + (i + 3) + ', texel, 0) ' + newLine + '); ' : 'vec4(0) ' + newLine + '); ') + newLine;

        this.#tempGlsl += 'mat4 id' + i + ' = mat4(';
        for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < rt.temporalSamples ? 'texelFetch(cacheId' + j + ', texel, 0),' : 'vec4(0),') + newLine;
        this.#tempGlsl += (i + 3 < rt.temporalSamples ? 'texelFetch(cacheId' + (i + 3) + ', texel, 0) ' + newLine + '); ' : 'vec4(0) ' + newLine + '); ') + newLine;

        this.#tempGlsl += 'mat4 originalId' + i + ' = mat4(';
        for (let j = i; j < i + 3; j++) this.#tempGlsl += (j < rt.temporalSamples ? 'texelFetch(cacheOriginalId' + j + ', texel, 0),' : 'vec4(0),') + newLine;
        this.#tempGlsl += (i + 3 < rt.temporalSamples ? 'texelFetch(cacheOriginalId' + (i + 3) + ', texel, 0) ' + newLine + '); ' : 'vec4(0) ' + newLine + '); ') + newLine;

        this.#tempGlsl += `
        for (int i = 0; i < 4; i++) if (id` + i + `[i].xyzw == id.xyzw) {
          color += c` + i + `[i].xyz + ip` + i + `[i].xyz * 256.0;
          counter ++;
        }
        for (int i = 0; i < 4; i++) if (originalId` + i + `[i].xyzw == originalId.xyzw) {
          glassFilter += ip` + i + `[i].w;
          glassCounter ++;
        }
        `;
      }

      this.#tempGlsl += `
      color /= counter;
      glassFilter /= glassCounter;
      `;

      if (rt.filter) {
        this.#tempGlsl += `
          renderColor = vec4(mod(color, 1.0), centerW);
          // 16 bit HDR for improved filtering
          renderColorIp = vec4(floor(color) / 256.0, glassFilter);
        }`;
      } else {
        this.#tempGlsl += `
          if (hdr == 1) {
            // Apply Reinhard tone mapping
            color = color / (color + vec3(1));
            // Gamma correction
            float gamma = 0.8;
            color = pow(4.0 * color, vec3(1.0 / gamma)) / 4.0 * 1.3;
            renderColor = vec4(color, centerW);
          } else {
            // Set color of object itself
            renderColor = vec4(color, centerW);
          }
          renderColor = vec4(color, centerW);
        }`;
      }
      // Force update textures by resetting texture Lists
      rt.#textureList = [];
      rt.#pbrList = [];
      rt.#translucencyList = [];
      // Compile shaders and link them into Program global
      let vertexShader = Network.fetchSync('shaders/pathtracer_vertex.glsl');
      let fragmentShader = Network.fetchSync('shaders/pathtracer_fragment.glsl');
      Program = GLLib.compile (this.#gl, vertexShader, fragmentShader);
      TempProgram = GLLib.compile (this.#gl, GLLib.postVertex, rt.#tempGlsl);
      // Compile shaders and link them into PostProgram global
      for (let i = 0; i < 2; i++) PostProgram[i] = GLLib.compile (rt.#gl, GLLib.postVertex, rt.#firstFilterGlsl);
      // Compile shaders and link them into PostProgram global
      for (let i = 2; i < 4; i++) PostProgram[i] = GLLib.compile (rt.#gl, GLLib.postVertex, rt.#secondFilterGlsl);
      // Compile shaders and link them into PostProgram global
      PostProgram[4] = GLLib.compile (rt.#gl, GLLib.postVertex, rt.#finalFilterGlsl);
      // Create global vertex array object (Vao)
      rt.#gl.bindVertexArray(Vao);
      // Bind uniforms to Program
      initialState.pathtracingUniformLocations = PathtracingUniformLocationIdentifiers.map(identifier => rt.#gl.getUniformLocation(Program, identifier));
      // Enable depth buffer and therefore overlapping vertices
      rt.#gl.disable(rt.#gl.BLEND);
      rt.#gl.enable(rt.#gl.DEPTH_TEST);
      rt.#gl.depthMask(true);
      // Cull (exclude from rendering) hidden vertices at the other side of objects
      rt.#gl.enable(rt.#gl.CULL_FACE);
      // Set clear color for framebuffer
      rt.#gl.clearColor(0, 0, 0, 0);
      // Define Program with its currently bound shaders as the program to use for the webgl2 context
      rt.#gl.useProgram(Program);
      rt.#pbrAtlas = rt.#gl.createTexture();
      rt.#translucencyAtlas = rt.#gl.createTexture();
      rt.#textureAtlas = rt.#gl.createTexture();
      // Create texture for all primary light sources in scene
      rt.#lightTexture = rt.#gl.createTexture();
      // Init textures containing all information about the scene to enable pathtracing
      rt.#geometryTexture = rt.#gl.createTexture();
      rt.#sceneTexture = rt.#gl.createTexture();
      // Create buffers
      [triangleIdBuffer, vertexIdBuffer] = [rt.#gl.createBuffer(), rt.#gl.createBuffer()];
      
      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, triangleIdBuffer);
      rt.#gl.enableVertexAttribArray(0);
      rt.#gl.vertexAttribIPointer(0, 1, rt.#gl.INT, false, 0, 0);
      rt.#gl.vertexAttribDivisor(0, 1);

      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, vertexIdBuffer);
      rt.#gl.enableVertexAttribArray(1);
      rt.#gl.vertexAttribIPointer(1, 1, rt.#gl.INT, false, 0, 0);
      // Create frame buffers and textures to be rendered to
      [Framebuffer, OriginalIdRenderTexture] = [rt.#gl.createFramebuffer(), rt.#gl.createTexture()];

      renderTextureBuilder();

      rt.#gl.bindVertexArray(TempVao);
      rt.#gl.useProgram(TempProgram);
      TempHdrLocation = rt.#gl.getUniformLocation(TempProgram, 'hdr');

      for (let i = 0; i < rt.temporalSamples; i++) {
        TempTex[i] = rt.#gl.getUniformLocation(TempProgram, 'cache' + i);
        TempIpTex[i] = rt.#gl.getUniformLocation(TempProgram, 'cacheIp' + i);
        TempIdTex[i] = rt.#gl.getUniformLocation(TempProgram, 'cacheId' + i);
        TempOriginalIdTex[i] = rt.#gl.getUniformLocation(TempProgram, 'cacheOriginalId' + i);
      }
      
      let TempVertexBuffer = rt.#gl.createBuffer();
      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, TempVertexBuffer);
      rt.#gl.enableVertexAttribArray(0);
      rt.#gl.vertexAttribPointer(0, 2, rt.#gl.FLOAT, false, 0, 0);
      // Fill buffer with data for two verices
      rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, TempVertexBuffer);
      rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, Float32Array.from([0,0,1,0,0,1,1,1,0,1,1,0]), rt.#gl.DYNAMIC_DRAW);
      TempFramebuffer = rt.#gl.createFramebuffer();

      for (let i = 0; i < 5; i++){
        // Create post program buffers and uniforms
        rt.#gl.bindVertexArray(PostVao[i]);
        rt.#gl.useProgram(PostProgram[i]);
        // Bind uniforms
        RenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'preRenderColor');
        IpRenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'preRenderColorIp');
        OriginalRenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'preRenderOriginalColor');
        IdRenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'preRenderId');
        OriginalIdRenderTex[i] = rt.#gl.getUniformLocation(PostProgram[i], 'preRenderOriginalId');
        if (i === 4) HdrLocation = rt.#gl.getUniformLocation(PostProgram[i], 'hdr');
        PostVertexBuffer[i] = rt.#gl.createBuffer();
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, PostVertexBuffer[i]);
        rt.#gl.enableVertexAttribArray(0);
        rt.#gl.vertexAttribPointer(0, 2, rt.#gl.FLOAT, false, 0, 0);
        // Fill buffer with data for two verices
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, PostVertexBuffer[i]);
        rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, Float32Array.from([0,0,1,0,0,1,1,1,0,1,1,0]), rt.#gl.DYNAMIC_DRAW);
        PostFramebuffer[i] = rt.#gl.createFramebuffer();
      }

      // Post processing (end of render pipeline)
      if (rt.#antialiasing !== null) {
        switch (this.#antialiasing.toLowerCase()) {
          case "fxaa":
            this.#AAObject = new FXAA(rt.#gl);
            break;
          case "taa":
            this.#AAObject = new TAA(rt.#gl);
            break;
          default:
            this.#AAObject = null;
        }
      } else {
        this.#AAObject = null;
      }
      // Return initialized objects for engine.
      return initialState;
    }
    // Prepare Renderengine
    let engineState = prepareEngine();
    // Begin frame cycle
    requestAnimationFrame(() => frameCycle(engineState));
  }
}
