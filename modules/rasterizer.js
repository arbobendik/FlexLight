'use strict';

import { GLLib } from './gllib.js';
import { FXAA } from './fxaa.js';
import { TAA } from './taa.js';

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
  #worldTexture;
  // Buffer arrays
  #positionBufferArray;
  #idBufferArray;
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
  precision highp float;
  in vec3 position3d;
  in vec4 id;
  in vec2 texPos;

  uniform vec3 cameraPosition;
  uniform vec2 perspective;
  uniform vec4 conf;

  out vec3 position;
  out vec2 texCoord;
  out vec3 clipSpace;
  flat out vec4 vertexId;
  flat out vec3 camera;

  vec3 clipPosition (vec3 pos, vec2 dir) {
    vec2 translatePX = vec2(
      pos.x * cos(dir.x) + pos.z * sin(dir.x),
      pos.z * cos(dir.x) - pos.x * sin(dir.x)
    );

    vec2 translatePY = vec2(
      pos.y * cos(dir.y) + translatePX.y * sin(dir.y),
      translatePX.y * cos(dir.y) - pos.y * sin(dir.y)
    );

    vec2 translate2d = vec2(translatePX.x / conf.y, translatePY.x) / conf.x;
    return vec3(translate2d, translatePY.y);
  }

  void main(){
    vec3 move3d = position3d + vec3(cameraPosition.x, - cameraPosition.yz) * vec3(-1.0, 1.0, 1.0);

    clipSpace = clipPosition (move3d, perspective + conf.zw);
    
    // Set triangle position in clip space
    gl_Position = vec4(clipSpace.xy, - 1.0 / (1.0 + exp(- length(move3d / 1048576.0))), clipSpace.z);

    position = position3d;
    texCoord = texPos;
    vertexId = id;
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
  flat in vec4 vertexId;
  flat in vec3 camera;

  // Get global illumination color, intensity
  uniform vec3 ambient;
  // Textures in parallel for texture atlas
  uniform int textureWidth;
  uniform int hdr;
  // Texture with information about all triangles in scene
  uniform sampler2D worldTex;
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

  // Simplified Moeller-Trumbore algorithm for detecting only forward facing triangles
  bool moellerTrumboreCull (float l, Ray ray, mat3 t) {
    vec3 edge1 = t[1] - t[0];
    vec3 edge2 = t[2] - t[0];
    vec3 pvec = cross(ray.unitDirection, edge2);
    float det = dot(edge1, pvec);
    float invDet = 1.0 / det;
    if (det < BIAS) return false;
    vec3 tvec = ray.origin - t[0];
    float u = dot(tvec, pvec) * invDet;
    if (u < BIAS || u > 1.0) return false;
    vec3 qvec = cross(tvec, edge1);
    float v = dot(ray.unitDirection, qvec) * invDet;
    if (v < 0.0 || u + v > 1.0) return false;
    float s = dot(edge2, qvec) * invDet;
    return (s <= l && s > BIAS);
  }

  // Don't return intersection point, because we're looking for a specific triangle
  bool rayCuboid(float l, vec3 invRay, vec3 p, vec3 minCorner, vec3 maxCorner) {
    vec3 v0 = (minCorner - p) * invRay;
    vec3 v1 = (maxCorner - p) * invRay;
    float tmin = max(max(min(v0.x, v1.x), min(v0.y, v1.y)), min(v0.z, v1.z));
    float tmax = min(min(max(v0.x, v1.x), max(v0.y, v1.y)), max(v0.z, v1.z));
    return tmax >= max(tmin, BIAS) && tmin < l;
  }

  // Simplified rayTracer to only test if ray intersects anything
  bool shadowTest(Ray ray) {
    // Precompute inverse of ray for AABB cuboid intersection test
    vec3 invRay = 1.0 / ray.unitDirection;
    // Precomput max length
    float minLen = length(ray.direction);
    // Get texture size as max iteration value
    int size = textureSize(worldTex, 0).y * int(TRIANGLES_PER_ROW);
    // Iterate through lines of texture
    for (int i = 0; i < size; i++) {
      // Get position of current triangle/vertex in worldTex
      ivec2 index = ivec2(mod(float(i), TRIANGLES_PER_ROW) * 8.0, float(i) * INV_TRIANGLES_PER_ROW);
      // Fetch triangle coordinates from scene graph
      mat3 t = mat3(
        texelFetch(worldTex, index, 0).xyz,
        texelFetch(worldTex, index + ivec2(1, 0), 0).xyz,
        texelFetch(worldTex, index + ivec2(2, 0), 0).xyz
      );
      // Read normal from scene graph
      vec3 n = texelFetch(worldTex, index + ivec2(4, 0), 0).xyz;
      // Three cases:
      // normal is not 0 0 0    => is triangle: if ray intersects triangle, return true
      // all vertices are 0 0 0 => end of list: return false
      // normal is 0 0 0        => beginning of bounding volume: if ray intersects bounding, skip all triangles in boundingvolume
      if (n == vec3(0)) {
        if (t[2] == vec3(0)) break;
        if (!rayCuboid(minLen, invRay, ray.origin, t[0], t[1])) i += int(t[2].x);
      } else {
        if (moellerTrumboreCull(minLen, ray, t)) return true;
      }
    }
    // Tested all triangles, but there is no intersection
    return false;
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

  void main(){
    // Calculate constant for this pass
    invTextureWidth = 1.0 / float(textureWidth);

    float id = vertexId.x * 65536.0 + vertexId.y;
    ivec2 index = ivec2(mod(id, TRIANGLES_PER_ROW) * 8.0, id * INV_TRIANGLES_PER_ROW);
    // Read base attributes from world texture.
    vec3 textureNums = texelFetch(worldTex, index + ivec2(5, 0), 0).xyz;
    // Default texColor to color
    vec3 color = mix(texelFetch(worldTex, index + ivec2(3, 0), 0).xyz, lookup(tex, vec3(texCoord, textureNums.x)).xyz, sign(textureNums.x + 1.0));
    vec3 normal = normalize(texelFetch(worldTex, index + ivec2(4, 0), 0).xyz);
    
    // Test if pixel is in frustum or not
    if (clipSpace.z < 0.0) return;
    // Alter normal and color according to texture and normal texture
    // Test if textures are even set otherwise use defaults.
    // Default texColor to color
    Material material = Material (
      mix(color, lookup(tex, vec3(texCoord, textureNums.x)).xyz, sign(textureNums.x + 1.0)),
      mix(vec3(0.5, 0.0, 0.0), lookup(pbrTex, vec3(texCoord, textureNums.y)).xyz * vec3(1.0, 1.0, 4.0), sign(textureNums.y + 1.0)),
      mix(vec3(0.0, 0.0, 0.25), lookup(translucencyTex, vec3(texCoord, textureNums.z)).xyz, sign(textureNums.z + 1.0))
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

      // Update pixel color if coordinate is not in shadow
      if (!shadowTest(lightRay)) finalColor += forwardTrace(dir, normal, normalize(camera - position), material, strength);
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
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#lightTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_S, this.#gl.CLAMP_TO_EDGE);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_T, this.#gl.CLAMP_TO_EDGE);

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
    // Bias of 2^(-16)
    const BIAS = 0.00152587890625;
    // Object ids to keep track of
    let id = 0;
    let bufferId = 0;
    // build buffer Arrays
    let [positions, ids, uvs] = [[], [], []];
    let bufferLength = 0;
    // Set data variable for texels in world space texture
    var data = [];
    
    // Build simple AABB tree (Axis aligned bounding box)
    let fillData = (item) => {
      let minMax = [];
      if (Array.isArray(item) || item.indexable) {
        if (item.length === 0) return [];
        let dataPos = data.length;
        // Begin bounding volume array
        data.push.apply(data, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
        id ++;
        // Iterate over all sub elements
        minMax = fillData (item[0]);
        for (let i = 1; i < item.length; i++) {
          // get updated bounding of lower element
          let b = fillData (item[i]);
          // update maximums and minimums
          minMax = minMax.map((e, i) => (i < 3) ? Math.min(e, b[i] - BIAS) : Math.max(e, b[i] + BIAS));
        }

        let len = Math.floor((data.length - dataPos) / 24);
        // Set now calculated vertices length of bounding box
        // to skip if ray doesn't intersect with it
        for (let i = 0; i < 6; i++) data[dataPos + i] = minMax[i];
        // for (let i = 3; i < 6; i++) data[dataPos + i] = minMax[(i % 3) * 2 + 1];
        data[dataPos + 6] = len - 1;

      } else {
        let len = item.length;
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
        // a, b, c, color, normal, texture_nums, UVs1, UVs2 per triangle in item
        data.push.apply(data, item.textureArray);
        // Increase object id
        bufferId ++;

        let bufferIdHigh = (bufferId % 65536) / 65535;
        let bufferIdLow = (bufferId % 256) / 255;
        // Give item new id property to identify vertex in fragment shader
        for (let i = 0; i < len * 3; i += 9) {
          let idHigh = Math.floor(id >> 16);
          let idLow = id % 65536;
          // 1 vertex = 1 line in world texture
          // Fill id buffer
          ids.push.apply(ids, [idHigh, idLow, bufferIdHigh, bufferIdLow, idHigh, idLow, bufferIdHigh, bufferIdLow, idHigh, idLow, bufferIdHigh, bufferIdLow]);
          id ++;
        }
        // Fill buffers
        positions.push.apply(positions, item.vertices);
        uvs.push.apply(uvs, item.uvs);
        bufferLength += item.length;
      }
      return minMax;
    }
    // Fill scene describing texture with data pixels
    for (let i = 0; i < this.scene.queue.length; i++) fillData(this.scene.queue[i]);
    // Set buffer attributes
    this.#positionBufferArray = new Float32Array(positions);
    this.#idBufferArray =  new Float32Array(ids);
    this.#uvBufferArray =  new Float32Array(uvs);
    this.#bufferLength = bufferLength;
    // Round up data to next higher multiple of 6144 (8 pixels * 3 values * 256 vertecies per line)
    data.push.apply(data, new Array(6144 - data.length % 6144).fill(0));
    // Calculate DataHeight by dividing value count through 6144 (8 pixels * 3 values * 256 vertecies per line)
    var dataHeight = data.length / 6144;
    // Manipulate actual webglfor (int i = 0; i < 4; i++) out_color += min(max(c[i], minRGB), maxRGB); texture
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#worldTexture);
    // Tell webgl to use 4 bytes per value for the 32 bit floats
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    // Set data texture details and tell webgl, that no mip maps are required
    GLLib.setTexParams(this.#gl);
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 2048, dataHeight, 0, this.#gl.RGB, this.#gl.FLOAT, new Float32Array(data));
    // this.#gl.texStorage2D(this.#gl.TEXTURE_2D, 1, this.#gl.RGB32F, 2048, dataHeight);
    // this.#gl.texSubImage2D(this.#gl.TEXTURE_2D, 0, 0, 0, 2048, dataHeight, this.#gl.RGB, this.#gl.FLOAT, new Float32Array(data));
  }

  async render() {
    // start rendering
    let rt = this;
    // Allow frame rendering
    rt.#halt = false;
    // Initialize internal globals of render functiod
    // The millis variable is needed to calculate fps and movement speed
    let TimeElapsed = performance.now();
    // Total frames calculated since last meassured
    let Frames = 0;
    // Internal GL objects
    let Program, CameraPosition, Perspective, RenderConf, AmbientLocation, TextureWidth, HdrLocation, WorldTex, PbrTex, TranslucencyTex, Tex, LightTex;
    // Init Buffers
    let PositionBuffer, IdBuffer, UvBuffer;
    // Framebuffer, other buffers and textures
    let Framebuffer;
    let DepthTexture = this.#gl.createTexture();
    // Create different Vaos for different rendering/filtering steps in pipeline
    let Vao = this.#gl.createVertexArray();

    // Check if recompile is needed
    let State = this.renderQuality;

    // Function to handle canvas resize
    let resize = () => {
			const canvas = rt.canvas;
    	canvas.width = canvas.clientWidth * rt.renderQuality;
    	canvas.height = canvas.clientHeight * rt.renderQuality;
    	rt.#gl.viewport(0, 0, canvas.width, canvas.height);
      // Rebuild textures with every resize
      renderTextureBuilder();
      if (this.#AAObject != null) this.#AAObject.buildTexture();
    }
    // Init canvas parameters and textures with resize
    resize();
    // Handle canvas resize
    window.addEventListener('resize', resize);

    function renderTextureBuilder() {
      // Init single channel depth texture
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, DepthTexture);
      rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.DEPTH_COMPONENT24, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.DEPTH_COMPONENT, rt.#gl.UNSIGNED_INT, null);
      GLLib.setTexParams(rt.#gl);
    }

    // Internal render engine Functions
    function frameCycle (Millis) {
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
			// Clear screen
      rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);
      // Check if recompile is required
      if (State !== rt.renderQuality) {
        resize();
        prepareEngine();
        State = rt.renderQuality;
      }
      // Render new Image, work through queue
      renderFrame();
      // Update frame counter
      Frames ++;
      // Calculate Fps
			const timeDifference = Millis - TimeElapsed;
      if (timeDifference > 500) {
        rt.fps = (1000 * Frames / timeDifference).toFixed(0);
        [TimeElapsed, Frames] = [Millis, 0];
      }
    }

    function texturesToGPU() {
      let [jitterX, jitterY] = [0, 0];
      if (rt.#antialiasing !== null && (rt.#antialiasing.toLocaleLowerCase() === 'taa')) {
        let jitter = rt.#AAObject.jitter(rt.#canvas);
        [jitterX, jitterY] = [jitter.x, jitter.y];
      }

      rt.#gl.bindVertexArray(Vao);
      rt.#gl.useProgram(Program);

      rt.#gl.activeTexture(rt.#gl.TEXTURE0);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#worldTexture);
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
      // Set x and y rotation of camera
      rt.#gl.uniform2f(Perspective, rt.camera.fx, rt.camera.fy);
      // Set fov and X/Y ratio of screen
      rt.#gl.uniform4f(RenderConf, rt.camera.fov, rt.#gl.canvas.width / rt.#gl.canvas.height, jitterX, jitterY);
      // Set global illumination
      rt.#gl.uniform3f(AmbientLocation, rt.scene.ambientLight[0], rt.scene.ambientLight[1], rt.scene.ambientLight[2]);
      // Set width of height and normal texture
      rt.#gl.uniform1i(TextureWidth, Math.floor(2048 / rt.scene.standardTextureSizes[0]));
      // Enable or disable hdr
      rt.#gl.uniform1i(HdrLocation, rt.hdr);
      // Pass whole current world space as data structure to GPU
      rt.#gl.uniform1i(WorldTex, 0);
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
        [IdBuffer, rt.#idBufferArray],
        [UvBuffer, rt.#uvBufferArray]
      ].forEach(function(item) {
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, item[0]);
        rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, item[1], rt.#gl.DYNAMIC_DRAW);
      });
      // Actual drawcall
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
      Perspective = rt.#gl.getUniformLocation(Program, 'perspective');
      RenderConf = rt.#gl.getUniformLocation(Program, 'conf');
      AmbientLocation = rt.#gl.getUniformLocation(Program, 'ambient');
      WorldTex = rt.#gl.getUniformLocation(Program, 'worldTex');
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
      rt.#worldTexture = rt.#gl.createTexture();
      // Create buffers
      [PositionBuffer, IdBuffer, UvBuffer] = [rt.#gl.createBuffer(), rt.#gl.createBuffer(), rt.#gl.createBuffer()];
      [
        // Bind world space position buffer
        [PositionBuffer, 3, false],
        // Surface id buffer
        [IdBuffer, 4, false],
        // Set barycentric texture coordinates
        [UvBuffer, 2, true]
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
    frameCycle();
  }
}
