'use strict';

import { Network } from './network.js';
import { GLLib } from './gllib.js';
import { FXAA } from './fxaa.js';
import { TAA } from './taa.js';
import { Transform } from './scene.js';
import { Arrays } from './arrays.js';

export class Rasterizer {
  type = 'rasterizer';
  // Configurable runtime properties (public attributes)
  // Quality settings
  renderQuality = 1;
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
        geometryTextureArray.set(item.geometryTextureArray, texturePos * 12);
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
        for (let i = 0; i < 6; i++) geometryTextureArray[oldTexturePos * 12 + i] = minMax[i];
        geometryTextureArray[oldTexturePos * 12 + 6] = texturePos - oldTexturePos - 1;
        geometryTextureArray[oldTexturePos * 12 + 9] = Array.isArray(item) ? -1 : item.transformNum;
        // console.log(item.transformNum);
      } else {
        // Item is dynamic and non-indexable.
        // a, b, c, color, normal, texture_nums, UVs1, UVs2 per triangle in item
        geometryTextureArray.set(item.geometryTextureArray, texturePos * 12);
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
    let geometryTexWidth = 4 * 3 * 256;
    let sceneTexWidth = 9 * 3 * 256;
    // Round up data to next higher multiple of (3 pixels * 3 values * 256 vertecies per line)
    let geometryTextureArray = new Float32Array(Math.ceil(textureLength * 12 / geometryTexWidth) * geometryTexWidth);
    // Round up data to next higher multiple of (7 pixels * 3 values * 256 vertecies per line)
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
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 4 * 256, geometryTextureArrayHeight, 0, this.#gl.RGB, this.#gl.FLOAT, geometryTextureArray);
    // this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB16F, 4 * 256, geometryTextureArrayHeight, 0, this.#gl.RGB, this.#gl.HALF_FLOAT, new Float16Array(geometryTextureArray));

    // Calculate DataHeight by dividing value count through (9 pixels * 3 values * 256 vertecies per line)
    let sceneTextureArrayHeight = sceneTextureArray.length / sceneTexWidth;
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#sceneTexture);
    GLLib.setTexParams(this.#gl);
    // Tell webgl to use 2 bytes per value for the 16 bit floats
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    // Set data texture details and tell webgl, that no mip maps are required
    
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 9 * 256, sceneTextureArrayHeight, 0, this.#gl.RGB, this.#gl.FLOAT, sceneTextureArray);
    // this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB16F, 1280, sceneTextureArrayHeight, 0, this.#gl.RGB, this.#gl.HALF_FLOAT, new Float16Array(sceneTextureArray));
    // this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.SRGB8, 1280, sceneDataHeight, 0, this.#gl.RGB, this.#gl.UNSIGNED_BYTE, new Uint8Array(sceneData));
  }

  render() {
    // start rendering
    let rt = this;
    // Allow frame rendering
    rt.#halt = false;
    // Init Buffers
    let triangleIdBuffer, vertexIdBuffer;
    // The millis variable is needed to calculate fps and movement speed
    let LastTimeStamp = performance.now();
    // Total frames calculated since last meassured
    let Frames = 0;
    // Internal GL objects
    let Program, CameraPosition, MatrixLocation, AmbientLocation, TextureWidth, HdrLocation, PbrTex, TranslucencyTex, Tex, LightTex;
    let UboBuffer, UboVariableOffsets;
    // Init Buffers
    let GeometryTex, SceneTex;
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
      if (!rt.#halt) setTimeout(function () {
        requestAnimationFrame(frameCycle)
      }, 1000 / rt.fpsLimit);
      // Update Textures
      rt.#updateTextureAtlas();
      rt.#updatePbrAtlas();
      rt.#updateTranslucencyAtlas();
      // Set scene graph
      // rt.updateScene();
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

    let texturesToGPU = () => {
      let jitter = {x: 0, y: 0};
      if (rt.#antialiasing !== null && (rt.#antialiasing.toLocaleLowerCase() === 'taa')) jitter = rt.#AAObject.jitter(rt.#canvas);
      // Calculate projection matrix
      let dir = {x: rt.camera.fx + jitter.x, y: rt.camera.fy + jitter.y};
      let matrix = [ 
        Math.cos(dir.x) * rt.#canvas.height / rt.#canvas.width / rt.camera.fov,  0,                               Math.sin(dir.x) * rt.#canvas.height / rt.#canvas.width / rt.camera.fov,
      - Math.sin(dir.x) * Math.sin(dir.y) / rt.camera.fov,                       Math.cos(dir.y) / rt.camera.fov,    Math.cos(dir.x) * Math.sin(dir.y) / rt.camera.fov,
      - Math.sin(dir.x) * Math.cos(dir.y),                                     - Math.sin(dir.y),                    Math.cos(dir.x) * Math.cos(dir.y)
      ];

      rt.#gl.bindVertexArray(Vao);
      rt.#gl.useProgram(Program);

      [this.#geometryTexture, this.#sceneTexture, this.#pbrAtlas, this.#translucencyAtlas, this.#textureAtlas, this.#lightTexture].forEach((texture, i) => {
        this.#gl.activeTexture(rt.#gl.TEXTURE0 + i);
        this.#gl.bindTexture(rt.#gl.TEXTURE_2D, texture);
      });
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
      // Pass current scene graph to GPU
      rt.#gl.uniform1i(GeometryTex, 0);
      // Pass additional datapoints for scene graph
      rt.#gl.uniform1i(SceneTex, 1);
      // Pass pbr texture to GPU
      rt.#gl.uniform1i(PbrTex, 2);
      // Pass pbr texture to GPU
      rt.#gl.uniform1i(TranslucencyTex, 3);
      // Pass texture to GPU
      rt.#gl.uniform1i(Tex, 4);
      // Pass texture with all primary light sources in the scene
      rt.#gl.uniform1i(LightTex, 5);
      // Fill UBO
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, UboBuffer);
      // console.log(UboVariableOffsets);
      
      let UboBufferArray = Transform.buildUBOArray();
      // console.log(UboBufferArray);
      // Push some data to our Uniform Buffer
      this.#gl.bufferSubData(
        this.#gl.UNIFORM_BUFFER,
        UboVariableOffsets[0],
        UboBufferArray,
        0
      );

      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, null);
      // Set buffers
      this.#gl.bindBuffer(this.#gl.ARRAY_BUFFER, triangleIdBuffer);
      this.#gl.bufferData(this.#gl.ARRAY_BUFFER, this.#triangleIdBufferArray, this.#gl.DYNAMIC_DRAW);
      // console.log(rt.#triangleIdBufferArray);
      this.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, vertexIdBuffer);
      this.#gl.bufferData(rt.#gl.ARRAY_BUFFER, new Int32Array([0, 1, 2]), rt.#gl.STATIC_DRAW);
      // Actual drawcall
      this.#gl.drawArraysInstanced(this.#gl.TRIANGLES, 0, 3, this.#bufferLength);
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
      // fillBuffers();
      // Apply antialiasing shader if enabled
      if (this.#AAObject != null) this.#AAObject.renderFrame();
    }

    let prepareEngine = () => {
      // Force update textures by resetting texture Lists
      this.#textureList = [];
      this.#pbrList = [];
      this.#translucencyList = [];
      // Compile shaders and link them into Program global
      let vertexShader = Network.fetchSync('shaders/rasterizer_vertex.glsl');
      let fragmentShader = Network.fetchSync('shaders/rasterizer_fragment.glsl');
      Program = GLLib.compile (rt.#gl, vertexShader, fragmentShader);
      // Create global vertex array object (Vao)
      this.#gl.bindVertexArray(Vao);
      // Bind uniforms to Program
      CameraPosition = this.#gl.getUniformLocation(Program, 'cameraPosition');
      MatrixLocation = this.#gl.getUniformLocation(Program, 'matrix');
      AmbientLocation = this.#gl.getUniformLocation(Program, 'ambient');
      GeometryTex = this.#gl.getUniformLocation(Program, 'geometryTex');
      SceneTex = this.#gl.getUniformLocation(Program, 'sceneTex');
      TextureWidth = this.#gl.getUniformLocation(Program, 'textureWidth');
      HdrLocation = this.#gl.getUniformLocation(Program, 'hdr');

      let BlockIndex = this.#gl.getUniformBlockIndex(Program, "transformMatrix");
      // Get the size of the Uniform Block in bytes
      let BlockSize = this.#gl.getActiveUniformBlockParameter(
        Program,
        BlockIndex,
        this.#gl.UNIFORM_BLOCK_DATA_SIZE
      );

      // Create Uniform Buffer to store our data
      UboBuffer = this.#gl.createBuffer();
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, UboBuffer);
      this.#gl.bufferData(this.#gl.UNIFORM_BUFFER, BlockSize, this.#gl.DYNAMIC_DRAW);
      this.#gl.bindBuffer(this.#gl.UNIFORM_BUFFER, null);
      this.#gl.bindBufferBase(this.#gl.UNIFORM_BUFFER, 0, UboBuffer);

      let UboVariableNames = ['transform'];
      // Get the respective index of the member variables inside our Uniform Block
      let UboVariableIndices = this.#gl.getUniformIndices( Program, UboVariableNames);
      // Get the offset of the member variables inside our Uniform Block in bytes
      UboVariableOffsets = this.#gl.getActiveUniforms(
        Program,
        UboVariableIndices,
        this.#gl.UNIFORM_OFFSET
      );

      let index = this.#gl.getUniformBlockIndex(Program, 'transformMatrix');
      this.#gl.uniformBlockBinding(Program, index, 0);


      LightTex = this.#gl.getUniformLocation(Program, 'lightTex');
      PbrTex = this.#gl.getUniformLocation(Program, 'pbrTex');
      TranslucencyTex = this.#gl.getUniformLocation(Program, 'translucencyTex');
      Tex = this.#gl.getUniformLocation(Program, 'tex');
      // Enable depth buffer and therefore overlapping vertices
      this.#gl.enable(this.#gl.BLEND);
      this.#gl.enable(this.#gl.DEPTH_TEST);
      this.#gl.blendEquation(this.#gl.FUNC_ADD);
      this.#gl.blendFuncSeparate(this.#gl.ONE, this.#gl.ONE_MINUS_SRC_ALPHA, this.#gl.ONE, this.#gl.ONE);
      this.#gl.depthMask(true);
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
      this.#geometryTexture = this.#gl.createTexture();
      this.#sceneTexture = this.#gl.createTexture();
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
      
      // Reload / Rebuild scene graph after resize or page reload
      this.updateScene();
    }
    // Prepare Renderengine
    prepareEngine();
    // Begin frame cycle
    requestAnimationFrame(frameCycle);
  }
}
