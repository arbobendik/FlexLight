'use strict';

import { GLLib } from './gllib.js';
import { FXAA } from './fxaa.js';
import { TAA } from './taa.js';
import { Arrays } from './arrays.js';

export class Rasterizer {
  type = 'rasterizer';
  // Configurable runtime properties (public attributes)
  // Quality settings
  renderQuality = 1;
  hdr = true;
  // Performance metric
  fps = 0;

  #antialiasing = 'taa';
  #AAObject;
  // Make gl object inaccessible from outside the class
  #gl;
  #canvas;

  #halt = false;
  #geometryTexture;
  // Buffer arrays
  #positionBufferArray;
  #normalBufferArray;
  #numBufferArray;
  #colorBufferArray;
  #uvBufferArray;
  #bufferLength;
  
  // Internal gl texture variables of texture atlases
  #textureAtlas;
  #pbrAtlas;
  #translucencyAtlas;

  #textureList = [];
  #pbrList = [];
  #translucencyList = [];

  #lightTexture;
  // Shader sources in glsl 3.0.0 es
  #vertexGlsl = `#version 300 es
  #define INV_65536 0.00001525879
  precision highp float;

  in vec3 position3d;
  in vec2 texPos;

  in vec3 inNormal;
  in vec3 inNums;
  in vec3 inColor;

  uniform vec3 cameraPosition;
  uniform mat3 matrix;

  out vec3 position;
  out vec2 texCoord;
  out vec3 clipSpace;

  out vec3 normal;
  out vec3 textureNums;
  out vec3 baseColor;

  flat out vec3 camera;

  void main(){
    vec3 move3d = position3d - cameraPosition;

    clipSpace = matrix * move3d;
    
    // Set triangle position in clip space
    gl_Position = vec4(clipSpace.xy, - 1.0 / (1.0 + exp(- length(move3d) * INV_65536)), clipSpace.z);

    position = position3d;
    texCoord = texPos;

    normal = inNormal;
    textureNums = inNums;
    baseColor = inColor;

    camera = cameraPosition;
  }
  `;
  #fragmentGlsl = `#version 300 es
  #define PI 3.141592653589793
  #define SQRT3 1.73205
  #define BIAS 0.00001525879
  #define INV_TRIANGLES_PER_ROW 0.00390625
  #define TRIANGLES_PER_ROW 256.0
  #define INV_256 0.00390625
  #define INV_65536 0.00001525879
  #define THIRD 0.333333

  precision highp float;
  precision highp sampler2D;

  float inv_texture_width = 1.0;

  struct Ray {
    vec3 direction;
    vec3 unitDirection;
    vec3 origin;
    vec3 normal;
  };

  struct Material {
    vec3 albedo;
    vec3 rme;
    vec3 tpo;
  };

  struct Light {
    vec3 origin;
    float strength;
    float variance;
  };

  in vec3 position;
  in vec2 texCoord;
  in vec3 clipSpace;

  in vec3 normal;
  in vec3 textureNums;
  in vec3 baseColor;

  flat in vec3 camera;

  // Get global illumination color, intensity
  uniform vec3 ambient;
  // Textures in parallel for texture atlas
  uniform int textureWidth;
  uniform int hdr;
  // Random texture to multiply with normal map to simulate rough surfaces
  uniform sampler2D translucencyTex;
  uniform sampler2D pbrTex;
  uniform sampler2D tex;
  // Texture with all primary light sources of scene
  uniform sampler2D lightTex;
  
  layout(location = 0) out vec4 renderColor;

  float invTextureWidth = 1.0;

  // Lookup values for texture atlases
  vec4 lookup(sampler2D atlas, vec3 coords) {
    float atlasHeightFactor = float(textureSize(atlas, 0).x) / float(textureSize(atlas, 0).y) * invTextureWidth;
    vec2 atlasCoords = vec2(
      (coords.x + mod(coords.z, float(textureWidth))) * invTextureWidth,
      (coords.y + floor(coords.z * invTextureWidth)) * atlasHeightFactor
    );
    // Return texel on requested location
    return texture(atlas, atlasCoords);
  }

  float trowbridgeReitz (float alpha, float NdotH) {
    float numerator = alpha * alpha;
    float denom = NdotH * NdotH * (alpha * alpha - 1.0) + 1.0;
    return numerator / max(PI * denom * denom, BIAS);
  }

  float schlickBeckmann (float alpha, float NdotX) {
    float k = alpha / 2.0;
    float denominator = NdotX * (1.0 - k) + k;
    denominator = max(denominator, BIAS);
    return NdotX / denominator;
  }

  float smith (float alpha, float NdotV, float NdotL) {
    return schlickBeckmann(alpha, NdotV) * schlickBeckmann(alpha, NdotL);
  }

  vec3 fresnel(vec3 F0, float VdotH) {
    // Use Schlick approximation
    return F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0);
  }

  vec3 forwardTrace (vec3 lightDir, vec3 N, vec3 V, Material material, float strength) {
    float lenP1 = 1.0 + length(lightDir);
    // Apply inverse square law
    float brightness = strength / (lenP1 * lenP1);

    float alpha = material.rme.x * material.rme.x;
    vec3 F0 = material.albedo * material.rme.y;
    vec3 L = normalize(lightDir);
    vec3 H = normalize(V + L);
    
    float VdotH = max(dot(V, H), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float NdotH = max(dot(N, H), 0.0);
    float NdotV = max(dot(N, V), 0.0);

    vec3 fresnelFactor = fresnel(F0, VdotH);
    vec3 Ks = fresnelFactor;
    vec3 Kd = (1.0 - Ks) * (1.0 - material.rme.y);
    vec3 lambert = material.albedo / PI;

    vec3 cookTorranceNumerator = trowbridgeReitz(alpha, NdotH) * smith(alpha, NdotV, NdotL) * fresnelFactor;
    float cookTorranceDenominator = 4.0 * NdotV * NdotL;
    cookTorranceDenominator = max(cookTorranceDenominator, BIAS);

    vec3 cookTorrance = cookTorranceNumerator / cookTorranceDenominator;
    vec3 BRDF = Kd * lambert + cookTorrance;

    // Outgoing light to camera
    return BRDF * NdotL * brightness;
  }

  void main() {
    // Calculate constant for this pass
    invTextureWidth = 1.0 / float(textureWidth);
    // Read base attributes from world texture.
    vec3 color = mix(baseColor, lookup(tex, vec3(texCoord, textureNums.x)).xyz, max(sign(textureNums.x + 0.5), 0.0));
    
    // Test if pixel is in frustum or not
    if (clipSpace.z < 0.0) return;
    // Alter normal and color according to texture and normal texture
    // Test if textures are even set otherwise use defaults.
    // Default texColor to color
    Material material = Material (
      mix(color, lookup(tex, vec3(texCoord, textureNums.x)).xyz, max(sign(textureNums.x + 0.5), 0.0)),
      mix(vec3(0.5, 0.0, 0.0), lookup(pbrTex, vec3(texCoord, textureNums.y)).xyz * vec3(1.0, 1.0, 4.0), max(sign(textureNums.y + 0.5), 0.0)),
      mix(vec3(0.0, 0.0, 0.25), lookup(translucencyTex, vec3(texCoord, textureNums.z)).xyz, max(sign(textureNums.z + 0.5), 0.0))
    );

    
    vec3 finalColor = vec3(material.rme.z);
    // Calculate primary light sources for this pass if ray hits non translucent object
    for (int j = 0; j < textureSize(lightTex, 0).y; j++) {
      // Read light position
      vec3 light = texelFetch(lightTex, ivec2(0, j), 0).xyz;
      // Read light strength from texture
      float strength = texelFetch(lightTex, ivec2(1, j), 0).x;
      // Skip if strength is negative or zero
      if (strength <= 0.0) continue;

      // Form light vector
      vec3 dir = light - position;
      Ray lightRay = Ray (dir, normalize(dir), position, normal);

      vec3 localColor = forwardTrace(dir, normal, normalize(camera - position), material, strength);

      // Compute quick exit criterion to potentially skip expensive shadow test
      bool quickExitCriterion = length(localColor) == 0.0 || dot(lightRay.unitDirection, normal) <= BIAS;

      // Update pixel color if coordinate is not in shadow
      if (!quickExitCriterion) finalColor += localColor;
    }
    
    finalColor *= color;

    if (hdr == 1) {
      // Apply Reinhard tone mapping
      finalColor = finalColor / (finalColor + vec3(1.0));
      // Gamma correction
      float gamma = 0.8;
      finalColor = pow(4.0 * finalColor, vec3(1.0 / gamma)) / 4.0 * 1.3;
    }
    renderColor = vec4(finalColor, 1.0 - material.tpo.x * 0.3);
  }
  `;
  // Create new raysterizer from canvas and setup movement
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
        this.#AAObject = new TAA(this.#gl, this);
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
		list.forEach(async (texture, i) => {
			// textureWidth for third argument was 3 for regular textures
			ctx.drawImage(texture, width * (i % textureWidth), height * Math.floor(i / textureWidth), width, height);
		});

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
  updatePrimaryLightSources () {
		// Don't update light sources if there are or no changes
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#lightTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
    // Skip processing if there are no light sources
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
  
  updateScene () {
    // Build unordered triangle list using recursion
    let objList = [];

    let bufferLength = 0;
    // Build simple AABB tree (Axis aligned bounding box)
    let fillData = (item) => {
      if (item.static) {
        // Item is static and precaluculated values can just be used.
        objList.push(item);
        bufferLength += item.bufferLength;
      } else if (Array.isArray(item) || item.indexable) {
        // Iterate over all sub elements
        for (let i = 0; i < item.length; i++) fillData (item[i]);
      } else {
        objList.push(item);
        bufferLength += item.length;
      }
    }
    // Fill scene describing texture with data pixels
    fillData(this.scene.queue);
    
    // Set buffer attributes
    this.#positionBufferArray = new Float32Array(bufferLength * 3);
    this.#uvBufferArray =  new Float32Array(bufferLength * 2);
    this.#normalBufferArray =  new Float32Array(bufferLength * 3);
    this.#numBufferArray =  new Float32Array(bufferLength * 3);
    this.#colorBufferArray =  new Float32Array(bufferLength * 3);

    let objIterator = 0;
    for (let i = 0; i < objList.length; i ++) {
      let item = objList[i];
      this.#positionBufferArray.set(item.vertices, objIterator * 3);
      this.#uvBufferArray.set(item.uvs, objIterator * 2);
      this.#normalBufferArray.set(item.normals, objIterator * 3);
      this.#colorBufferArray.set(item.colors, objIterator * 3);
      if (item.static) {
        this.#numBufferArray.set(item.cachedTextureNums, objIterator * 3);
        objIterator += item.bufferLength;
      } else {
        this.#numBufferArray.set(item.textureNums, objIterator * 3);
        objIterator += item.length;
      }
    }
    this.#bufferLength = bufferLength;
  }

  render() {
    // start rendering
    let rt = this;
    // Allow frame rendering
    rt.#halt = false;
    // Initialize internal globals of render functiod
    // The millis variable is needed to calculate fps and movement speed
    let LastTimeStamp = performance.now();
    // Total frames calculated since last meassured
    let Frames = 0;
    // Internal GL objects
    let Program, CameraPosition, MatrixLocation, AmbientLocation, TextureWidth, HdrLocation, GeometryTex, PbrTex, TranslucencyTex, Tex, LightTex;
    // Init Buffers
    let PositionBuffer, NormalBuffer, NumBuffer, ColorBuffer,  UvBuffer;
    // Framebuffer, other buffers and textures
    let Framebuffer;
    let DepthTexture = this.#gl.createTexture();
    // Create different Vaos for different rendering/filtering steps in pipeline
    let Vao = this.#gl.createVertexArray();

    // Check if recompile is needed
    let State = this.renderQuality;

    // Function to handle canvas resize
    let resize = () => {
    	rt.canvas.width = rt.canvas.clientWidth * rt.renderQuality;
    	rt.canvas.height = rt.canvas.clientHeight * rt.renderQuality;
    	rt.#gl.viewport(0, 0, rt.canvas.width, rt.canvas.height);
      // Rebuild textures with every resize
      renderTextureBuilder();
      // rt.updatePrimaryLightSources();
      if (this.#AAObject != null) this.#AAObject.buildTexture();
    }
    // Init canvas parameters and textures with resize
    resize();
    // Handle canvas resize
    window.addEventListener('resize', resize);

    function renderTextureBuilder() {
      // Init single channel depth texture
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, DepthTexture);
      rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.DEPTH_COMPONENT24, rt.canvas.width, rt.canvas.height, 0, rt.#gl.DEPTH_COMPONENT, rt.#gl.UNSIGNED_INT, null);
      GLLib.setTexParams(rt.#gl);
    }

    // Internal render engine Functions
    function frameCycle () {
      let timeStamp = performance.now();
      // Request the browser to render frame with hardware acceleration
      if (!rt.#halt) requestAnimationFrame(frameCycle);
      // Update Textures
      rt.#updateTextureAtlas();
      rt.#updatePbrAtlas();
      rt.#updateTranslucencyAtlas();
      // Set scene graph
      rt.updateScene();
      // build bounding boxes for scene first
      rt.updatePrimaryLightSources();
      // Check if recompile is required
      if (State !== rt.renderQuality) {
        resize();
        prepareEngine();
        State = rt.renderQuality;
      }

      // Update frame counter
      Frames ++;
      // Render new Image, work through queue
      renderFrame();
      // Calculate Fps
			const timeDifference = timeStamp - LastTimeStamp;
      if (timeDifference > 500) {
        rt.fps = (1000 * Frames / timeDifference).toFixed(0);
        [LastTimeStamp, Frames] = [timeStamp, 0];
      }
    }

    function texturesToGPU() {
      let jitter = {x: 0, y: 0};
      if (rt.#antialiasing !== null && (rt.#antialiasing.toLocaleLowerCase() === 'taa')) jitter = rt.#AAObject.jitter(rt.#canvas);
      // Calculate projection matrix
      let dir = {x: rt.camera.fx + jitter.x, y: rt.camera.fy + jitter.y};
      let matrix = [ 
        Math.cos(dir.x) * rt.#canvas.height / rt.#canvas.width / rt.camera.fov,  0,                              Math.sin(dir.x) * rt.#canvas.height / rt.#canvas.width / rt.camera.fov,
        - Math.sin(dir.x) * Math.sin(dir.y) / rt.camera.fov,                    Math.cos(dir.y) / rt.camera.fov, Math.cos(dir.x) * Math.sin(dir.y) / rt.camera.fov,
        - Math.sin(dir.x) * Math.cos(dir.y),                                    - Math.sin(dir.y),               Math.cos(dir.x) * Math.cos(dir.y)
      ];

      rt.#gl.bindVertexArray(Vao);
      rt.#gl.useProgram(Program);

      rt.#gl.activeTexture(rt.#gl.TEXTURE1);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#pbrAtlas);
      rt.#gl.activeTexture(rt.#gl.TEXTURE2);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#translucencyAtlas);
      rt.#gl.activeTexture(rt.#gl.TEXTURE3);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#textureAtlas);
      rt.#gl.activeTexture(rt.#gl.TEXTURE4);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#lightTexture);
      // Set uniforms for shaders
      // Set 3d camera position
      rt.#gl.uniform3f(CameraPosition, rt.camera.x, rt.camera.y, rt.camera.z);
      // Set projection matrix
      rt.#gl.uniformMatrix3fv(MatrixLocation, true, matrix);
      // Set global illumination
      rt.#gl.uniform3f(AmbientLocation, rt.scene.ambientLight[0], rt.scene.ambientLight[1], rt.scene.ambientLight[2]);
      // Set width of height and normal texture
      rt.#gl.uniform1i(TextureWidth, Math.floor(2048 / rt.scene.standardTextureSizes[0]));
      // Enable or disable hdr
      rt.#gl.uniform1i(HdrLocation, rt.hdr);
      // Pass whole current world space as data structure to GPU
      rt.#gl.uniform1i(GeometryTex, 0);
      // Pass pbr texture to GPU
      rt.#gl.uniform1i(PbrTex, 1);
      // Pass pbr texture to GPU
      rt.#gl.uniform1i(TranslucencyTex, 2);
      // Pass texture to GPU
      rt.#gl.uniform1i(Tex, 3);
      // Pass texture with all primary light sources in the scene
      rt.#gl.uniform1i(LightTex, 4);
    }

    function fillBuffers() {
      // Set buffers
      [
        [PositionBuffer, rt.#positionBufferArray],
        [UvBuffer, rt.#uvBufferArray],

        [NormalBuffer, rt.#normalBufferArray],
        [NumBuffer, rt.#numBufferArray],
        [ColorBuffer, rt.#colorBufferArray]
      ].forEach((item, i) => {
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, item[0]);
        rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, item[1], rt.#gl.DYNAMIC_DRAW);
      });
      // Actual drawcall
      // rt.#gl.drawArraysInstanced(rt.#gl.TRIANGLES, 0, rt.#bufferLength / 3, rt.#bufferLength);
      rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, rt.#bufferLength);
    }

    let renderFrame = () => {
      // Configure where the final image should go
      if (this.#antialiasing !== null) {
        // Configure framebuffer for color and depth
        rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, Framebuffer);
        rt.#gl.drawBuffers([
          rt.#gl.COLOR_ATTACHMENT0
        ]);
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.COLOR_ATTACHMENT0, rt.#gl.TEXTURE_2D, this.#AAObject.textureIn, 0);
        rt.#gl.framebufferTexture2D(rt.#gl.FRAMEBUFFER, rt.#gl.DEPTH_ATTACHMENT, rt.#gl.TEXTURE_2D, DepthTexture, 0);
      } else {
        rt.#gl.bindFramebuffer(rt.#gl.FRAMEBUFFER, null);
      }
      // Clear depth and color buffers from last frame
      rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);
      texturesToGPU();
      fillBuffers();
      // Apply antialiasing shader if enabled
      if (this.#AAObject != null) this.#AAObject.renderFrame();
    }

    let prepareEngine = () => {
      // Force update textures by resetting texture Lists
      rt.#textureList = [];
      rt.#pbrList = [];
      rt.#translucencyList = [];
      // Compile shaders and link them into Program global
      Program = GLLib.compile (rt.#gl, rt.#vertexGlsl, rt.#fragmentGlsl);
      // Create global vertex array object (Vao)
      rt.#gl.bindVertexArray(Vao);
      // Bind uniforms to Program
      CameraPosition = rt.#gl.getUniformLocation(Program, 'cameraPosition');
      MatrixLocation = rt.#gl.getUniformLocation(Program, 'matrix');
      AmbientLocation = rt.#gl.getUniformLocation(Program, 'ambient');
      GeometryTex = rt.#gl.getUniformLocation(Program, 'geometryTex');
      TextureWidth = rt.#gl.getUniformLocation(Program, 'textureWidth');
      HdrLocation = rt.#gl.getUniformLocation(Program, 'hdr');

      LightTex = rt.#gl.getUniformLocation(Program, 'lightTex');
      PbrTex = rt.#gl.getUniformLocation(Program, 'pbrTex');
      TranslucencyTex = rt.#gl.getUniformLocation(Program, 'translucencyTex');
      Tex = rt.#gl.getUniformLocation(Program, 'tex');
      // Enable depth buffer and therefore overlapping vertices
      rt.#gl.enable(rt.#gl.BLEND);
      rt.#gl.enable(rt.#gl.DEPTH_TEST);
      rt.#gl.blendEquation(rt.#gl.FUNC_ADD);
      rt.#gl.blendFuncSeparate(rt.#gl.ONE, rt.#gl.ONE_MINUS_SRC_ALPHA, rt.#gl.ONE, rt.#gl.ONE);
      rt.#gl.depthMask(true);
      // Set clear color for framebuffer
      rt.#gl.clearColor(0, 0, 0, 0);
      // Define Program with its currently bound shaders as the program to use for the webgl2 context
      rt.#gl.useProgram(Program);
      // Create Textures for primary render
      rt.#pbrAtlas = rt.#gl.createTexture();
      rt.#translucencyAtlas = rt.#gl.createTexture();
      rt.#textureAtlas = rt.#gl.createTexture();
      // Create texture for all primary light sources in scene
      rt.#lightTexture = rt.#gl.createTexture();
      // Init a world texture containing all information about world space
      rt.#geometryTexture = rt.#gl.createTexture();
      // Create buffers
      [PositionBuffer, UvBuffer, NormalBuffer, NumBuffer, ColorBuffer] = [rt.#gl.createBuffer(), rt.#gl.createBuffer(), rt.#gl.createBuffer(), rt.#gl.createBuffer(), rt.#gl.createBuffer()];
      [
        // Bind world space position buffer
        [PositionBuffer, 3, false],
        // Set barycentric texture coordinates
        [UvBuffer, 2, true],
        // Surface normal buffer
        [NormalBuffer, 3, true],
        [NumBuffer, 3, false],
        [ColorBuffer, 3, false]
      ].forEach((item, i) => {
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, item[0]);
        rt.#gl.enableVertexAttribArray(i);
        rt.#gl.vertexAttribPointer(i, item[1], rt.#gl.FLOAT, item[2], 0, 0);
      });
      // Create frame buffers and textures to be rendered to
      Framebuffer = rt.#gl.createFramebuffer();
      renderTextureBuilder();

      // Post processing (end of render pipeline)
      if (rt.#antialiasing !== null) {
        switch (this.#antialiasing.toLowerCase()) {
          case "fxaa":
            this.#AAObject = new FXAA(rt.#gl);
            break;
          case "taa":
            this.#AAObject = new TAA(rt.#gl, rt);
            break;
          default:
            this.#AAObject = null;
        }
      } else {
        this.#AAObject = null;
      }
      
    }
    // Prepare Renderengine
    prepareEngine();
    // Begin frame cycle
    requestAnimationFrame(frameCycle);
  }
}
