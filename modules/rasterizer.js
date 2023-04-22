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

  halt = () => this.#halt = true;
  #halt = false;
  // Make gl object inaccessible from outside the class
  #gl;
  #canvas;
  // Internal gl texture variables of texture atlases
  #worldTexture = null;
  #pbrTexture = null;
  #translucencyTexture = null;
  #texture = null;
  #lightTexture = null;
  // Shader sources in glsl 3.0.0 es
  #vertexGlsl = `#version 300 es
  precision highp float;
  in vec3 position_3d;
  in vec4 id;
  in vec2 tex_pos;
  uniform vec3 camera_position;
  uniform vec2 perspective;
  uniform vec4 conf;
  out vec3 position;
  out vec2 tex_coord;
  out vec3 clip_space;
  flat out vec4 vertex_id;
  flat out vec3 player;
  void main(){
    vec3 move_3d = position_3d + vec3(camera_position.x, - camera_position.yz) * vec3(-1.0, 1.0, 1.0);
    vec2 translate_px = vec2(
      move_3d.x * cos(perspective.x) + move_3d.z * sin(perspective.x),
      move_3d.z * cos(perspective.x) - move_3d.x * sin(perspective.x)
    );
    vec2 translate_py = vec2(
      move_3d.y * cos(perspective.y) + translate_px.y * sin(perspective.y),
      translate_px.y * cos(perspective.y) - move_3d.y * sin(perspective.y)
    );
    vec2 translate_2d = vec2(translate_px.x / conf.y, translate_py.x) / conf.x;
    // Set final clip space position
    gl_Position = vec4(translate_2d, - 1.0 / (1.0 + exp(- length(move_3d / 1048576.0))), translate_py.y);
    position = position_3d;
    tex_coord = tex_pos;
    clip_space = vec3(translate_2d, translate_py.y);
    vertex_id = id;
    player = camera_position;
  }
  `;
  #fragmentGlsl = `#version 300 es
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
    vec3 origin;
    vec3 normal;
  };

  struct Material {
    vec3 color;
    vec3 rme;
    vec3 tpo;
  };

  struct Light {
    vec3 origin;
    float strength;
    float variance;
  };

  in vec3 position;
  in vec2 tex_coord;
  in vec3 clip_space;
  flat in vec4 vertex_id;
  flat in vec3 player;
  // Get global illumination color, intensity
  uniform vec3 ambient;
  // Textures in parallel for texture atlas
  uniform int texture_width;
  uniform int hdr;
  // Texture with information about all triangles in scene
  uniform sampler2D world_tex;
  // Random texture to multiply with normal map to simulate rough surfaces
  uniform sampler2D translucency_tex;
  uniform sampler2D pbr_tex;
  uniform sampler2D tex;
  // Texture with all primary light sources of scene
  uniform sampler2D light_tex;
  layout(location = 0) out vec4 render_color;
  // Prevent blur over shadow border or over (close to) perfect reflections
  float first_ray_length = 1.0;
  // Accumulate color of mirror reflections
  float original_rmex = 0.0;
  vec3 original_color = vec3(1.0);

  // Lookup values for texture atlases
  vec4 lookup(sampler2D atlas, vec3 coords) {
    float atlas_height_factor = float(textureSize(atlas, 0).x) / float(textureSize(atlas, 0).y) * inv_texture_width;
    vec2 atlas_coords = vec2(
      (coords.x + mod(coords.z, float(texture_width))) * inv_texture_width,
      (coords.y + floor(coords.z * inv_texture_width)) * atlas_height_factor
    );
    // Return texel on requested location
    return texture(atlas, atlas_coords);
  }

  // Test if ray intersects triangle and return intersection
  mat2x4 rayTriangle(float l, Ray ray, mat3 t, vec3 n) {
    // Can't intersect with triangle with the same normal as the origin
    if (n == ray.normal) return mat2x4(0);
    // Get distance to intersection point
    float s = dot(n, t[0] - ray.origin) / dot(n, normalize(ray.direction));
    // Ensure that ray triangle intersection is between light source and texture
    if (s > l || s <= BIAS) return mat2x4(0);
    // Calculate intersection point
    vec3 d = (s * normalize(ray.direction)) + ray.origin;
    // Test if point on plane is in Triangle by looking for each edge if point is in or outside
    vec3 v0 = t[1] - t[0];
    vec3 v1 = t[2] - t[0];
    vec3 v2 = d - t[0];
    float d00 = dot(v0, v0);
    float d01 = dot(v0, v1);
    float d11 = dot(v1, v1);
    float d20 = dot(v2, v0);
    float d21 = dot(v2, v1);
    float denom = 1.0 / (d00 * d11 - d01 * d01);
    float v = (d11 * d20 - d01 * d21) * denom;
    float w = (d00 * d21 - d01 * d20) * denom;
    float u = 1.0 - v - w;
    if (min(u, v) <= BIAS || u + v >= 1.0 - BIAS) return mat2x4(0);
    // Return uvw and intersection point on triangle.
    return mat2x4(vec4(d, s), vec4(u, v, w, 0));
  }

  // Don't return intersection point, because we're looking for a specific triangle
  bool rayCuboid(vec3 inv_ray, vec3 p, vec3 min_corner, vec3 max_corner) {
    mat2x3 v = matrixCompMult(mat2x3(min_corner, max_corner) - mat2x3(p, p), mat2x3(inv_ray, inv_ray));
    float lowest = max(max(min(v[0].x, v[1].x), min(v[0].y, v[1].y)), min(v[0].z, v[1].z));
    float highest = min(min(max(v[0].x, v[1].x), max(v[0].y, v[1].y)), max(v[0].z, v[1].z));
    // Cuboid is behind ray
    // Ray points in cuboid direction, but doesn't intersect
    return max(lowest, BIAS) <= highest;
  }

  // Simplified rayTracer test only if ray intersects anything
  bool shadowTest(Ray ray, vec3 light){
    // Precompute inverse of ray for AABB cuboid intersection test
    vec3 inv_ray = 1.0 / normalize(ray.direction);
    // Get texture size as max iteration value
    int size = textureSize(world_tex, 0).y * int(TRIANGLES_PER_ROW);
    // Iterate through lines of texture
    for (int i = 0; i < size; i++){
      // Get position of current triangle/vertex in world_tex
      ivec2 index = ivec2(mod(float(i), TRIANGLES_PER_ROW) * 8.0, float(i) * INV_TRIANGLES_PER_ROW);
      // Read normal and triangle from world_tex
      vec3 n = texelFetch(world_tex, index + ivec2(4, 0), 0).xyz;
      // Fetch triangle coordinates from world texture
      mat3 t = mat3(
        texelFetch(world_tex, index, 0).xyz,
        texelFetch(world_tex, index + ivec2(1, 0), 0).xyz,
        texelFetch(world_tex, index + ivec2(2, 0), 0).xyz
      );
      //  Three cases:
      //   - normal is not 0 0 0 --> normal vertex
      //   - normal is 0 0 0 --> beginning of new bounding volume
      if (n != vec3(0)) {
        // Test if triangle intersects ray and return true if there is shadow
        if (rayTriangle(length(light - ray.origin), ray, t, normalize(cross(t[0] - t[2], t[0] - t[1])))[0].xyz != vec3(0)) return true;
      } else if (t == mat3(0)) {
        // Break if all values are zero and texture already ended
        break;
      } else if (!rayCuboid(inv_ray, ray.origin, vec3(t[0].x, t[0].z, t[1].y), vec3(t[0].y, t[1].x, t[1].z))){
        // Test if Ray intersects bounding volume
        // t[0] = x x2 y
        // t[1] = y2 z z2
        // If it doesn't intersect, skip shadow test for all elements in bounding volume
        i += int(t[2].x);
      }
    }
    // Tested all triangles, but there is no intersection
    return false;
  }

  float forwardTrace (Ray ray, vec3 origin, float metallicity, float strength) {
    float lenP1 = 1.0 + length(ray.direction);
    vec3 normalDir = normalize(ray.direction);

    // Calculate intensity of light reflection, which decreases squared over distance
    float intensity = strength / (lenP1 * lenP1);
    // Process specularity of ray in view from origin's perspective
    vec3 halfVector = normalize(normalDir + normalize(origin - ray.origin));
    float brightness = abs(dot(normalDir, ray.normal));
    float specular = pow(max(dot(normalize(- ray.origin), normalDir), 0.0), metallicity);
    // Determine final color and return it
    return mix(brightness, max(specular, 0.0), metallicity) * intensity;
  }

  float fresnel(vec3 normal, vec3 lightDir) {
    // Apply fresnel effect
    return dot(normal, lightDir);
  }

  void main(){
    // Calculate constant for this pass
    inv_texture_width = 1.0 / float(texture_width);

    float id = vertex_id.x * 65535.0 + vertex_id.y;
    ivec2 index = ivec2(mod(id, TRIANGLES_PER_ROW) * 8.0, id * INV_TRIANGLES_PER_ROW);
    // Read base attributes from world texture.
    vec3 texture_nums = texelFetch(world_tex, index + ivec2(5, 0), 0).xyz;
    // Default tex_color to color
    vec3 color = mix(texelFetch(world_tex, index + ivec2(3, 0), 0).xyz, lookup(tex, vec3(tex_coord, texture_nums.x)).xyz, sign(texture_nums.x + 1.0));
    vec3 normal = normalize(texelFetch(world_tex, index + ivec2(4, 0), 0).xyz);
    
    // Test if pixel is in frustum or not
    if (clip_space.z < 0.0) return;
    // Alter normal and color according to texture and normal texture
    // Test if textures are even set otherwise use defaults.
    // Default tex_color to color
    Material material = Material (
      mix(color, lookup(tex, vec3(tex_coord, texture_nums.x)).xyz, sign(texture_nums.x + 1.0)),
      mix(vec3(0.5, 0.0, 0.0), lookup(pbr_tex, vec3(tex_coord, texture_nums.y)).xyz * vec3(1.0, 1.0, 4.0), sign(texture_nums.y + 1.0)),
      mix(vec3(0.0, 0.0, 0.25), lookup(translucency_tex, vec3(tex_coord, texture_nums.z)).xyz, sign(texture_nums.z + 1.0))
    );
    // Fresnel effect
    material.rme.x = material.rme.x * mix(1.0, fresnel(normal, player - position), material.rme.y);

    float brightness = 0.0;
    // Calculate primary light sources for this pass if ray hits non translucent object
    for (int j = 0; j < textureSize(light_tex, 0).y; j++) {
      // Read light position
      vec3 light = texelFetch(light_tex, ivec2(0, j), 0).xyz;
      // Read light strength from texture
      float strength = texelFetch(light_tex, ivec2(1, j), 0).x;
      // Skip if strength is negative or zero
      if (strength <= 0.0) continue;
      // Recalculate position -> light vector
      Ray light_ray = Ray (light - position, position, normal);
      // Update pixel color if coordinate is not in shadow
      if (!shadowTest(light_ray, light)) brightness += forwardTrace(light_ray, player, material.rme.y, strength);
    }
    brightness = max(material.rme.z + 0.5 * material.tpo.x, brightness);

    vec3 final_color = brightness * color;

    if (hdr == 1) {
      // Apply Reinhard tone mapping
      final_color = final_color / (final_color + vec3(1.0));
      // Gamma correction
      float gamma = 0.8;
      final_color = pow(4.0 * final_color, vec3(1.0 / gamma)) / 4.0 * 1.3;
    }
    render_color = vec4(final_color, 1.0 - material.tpo.x * 0.3);
  }
  `;
  // Create new raysterizer from canvas and setup movement
  constructor (canvas, camera, scene) {
    this.#canvas = canvas;
    this.camera = camera;
    this.scene = scene;
    this.#gl = canvas.getContext('webgl2');
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
	#updateTextureType (type) {
		// Test if there is even a texture
		if (type.length === 0) {
			this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, 1, 1, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, new Uint8Array(4));
			return;
		}

		const [width, height] = this.scene.standardTextureSizes;
		const textureWidth = Math.floor(2048 / width);

		const canvas = document.createElement('canvas');
		const ctx = canvas.getContext('2d');

		canvas.width = width * textureWidth;
		canvas.height = height * type.length;
		ctx.imageSmoothingEnabled = false;

		type.forEach(async (texture, i) => {
			// textureWidth for third argument was 3 for regular textures
			ctx.drawImage(texture, width * (i % textureWidth), height * Math.floor(i / textureWidth), width, height);
		});
		this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, canvas.width, canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, Uint8Array.from(ctx.getImageData(0, 0, canvas.width, canvas.height).data));
	}
  updatePbrTextures () {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#pbrTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);

		this.#updateTextureType(this.scene.pbrTextures);
  }
  updateTranslucencyTextures () {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#translucencyTexture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);

		this.#updateTextureType(this.scene.translucencyTextures);
  }
  updateTextures () {
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#texture);
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 1);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_S, this.#gl.CLAMP_TO_EDGE);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_T, this.#gl.CLAMP_TO_EDGE);

		this.#updateTextureType(this.scene.textures);
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
  updateScene () {
    let id = 0;
    // Set data variable for texels in world space texture
    var data = [];
    // Build simple AABB tree (Axis aligned bounding box)
    var fillData = async (item) => {
      if (Array.isArray(item) || item.indexable) {
        let b = item.bounding;
        // Save position of len variable in array
        let len_pos = data.length;
        // Begin bounding volume array
        data.push(b[0],b[1],b[2],b[3],b[4],b[5],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
        id++;
        // Iterate over all sub elements and skip bounding (item[0])
        for (let i = 0; i < item.length; i++) {
          // Push sub elements in queue
          fillData(item[i]);
        }
        let len = Math.floor((data.length - len_pos) / 24);
        // Set now calculated vertices length of bounding box
        // to skip if ray doesn't intersect with it
        data[len_pos + 6] = len;
      } else {
        // Alias object properties to simplify data texture assembly
        let v = item.vertices;
        let c = item.colors;
        let n = item.normals;
        let t = item.textureNums;
        let uv = item.uvs;
        let len = item.length;

        //console.log(n[1]);
        // transform normal vectors to unit vectors
        let unitN = [];
        for (let i = 0; i < n.length; i+=3) {
          let v = [n[i], n[i+1], n[i+2]];
          // get length
          let length = Math.sqrt(v[0] ** 2 + v[1] ** 2 + v[2] ** 2);
          // devide by length
          unitN.push(v[0] / length, v[1] / length, v[2] / length);
        }
        // replace n with n as unit vectors
        n = unitN.flat();
        
        // Test if bounding volume is set
        if (item.bounding !== undefined) {
          // Declare bounding volume of object
          let b = item.bounding;
          data.push(b[0],b[1],b[2],b[3],b[4],b[5],len/3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
          id++;
        } else if (item.length > 3) {
          // Warn if length is greater than 3
          console.warn(item);
          // A single triangle needs no bounding voume, so nothing happens in this case
        }
        // Give item new id property to identify vertex in fragment shader
        item.ids = [];
        for (let i = 0; i < len * 3; i += 9){
          let j = i/3*2;
          // 1 vertex = 1 line in world texture
          // a, b, c, color, normal, texture_nums, UVs1, UVs2
          data.push(v[i],v[i+1],v[i+2],v[i+3],v[i+4],v[i+5],v[i+6],v[i+7],v[i+8],c[i/3],c[i/3+1],c[i/3+2],n[i],n[i+1],n[i+2],t[j],t[j+1],t[j+2],uv[j],uv[j+1],uv[j+2],uv[j+3],uv[j+4],uv[j+5]);
          item.ids.push(Math.floor(id / 65535), id % 65535, Math.floor(id / 65535), id % 65535, Math.floor(id / 65535), id % 65535);
          id++;
        }
      }
    }
    // Fill texture with data pixels
    for (let i = 0; i < this.scene.queue.length; i++) fillData(this.scene.queue[i]);
    // Round up data to next higher multiple of 6144 (8 pixels * 3 values * 256 vertecies per line)
    data.push(new Array(6144 - data.length % 6144).fill(0));
    data = data.flat();
    // Calculate DataHeight by dividing value count through 6144 (8 pixels * 3 values * 256 vertecies per line)
    var dataHeight = data.length / 6144;
    // Manipulate actual webgl texture
    this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#worldTexture);
    // Tell webgl to use 4 bytes per value for the 32 bit floats
    this.#gl.pixelStorei(this.#gl.UNPACK_ALIGNMENT, 4);
    // Set data texture details and tell webgl, that no mip maps are required
    this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGB32F, 2048, dataHeight, 0, this.#gl.RGB, this.#gl.FLOAT, new Float32Array(data));
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
    this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);
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
    let PositionBuffer, IdBuffer, TexBuffer;
    // Framebuffer, other buffers and textures
    let Framebuffer;
    let DepthTexture = this.#gl.createTexture();
    // Create different Vaos for different rendering/filtering steps in pipeline
    let Vao = this.#gl.createVertexArray();

    // Check if recompile is needed
    let State = this.renderQuality;

    // Detect mouse movements
    // Handle canvas resize
    window.addEventListener('resize', function(){
    	resize();
    });
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

    function renderTextureBuilder() {
      // Init single channel depth texture
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, DepthTexture);
      rt.#gl.texImage2D(rt.#gl.TEXTURE_2D, 0, rt.#gl.DEPTH_COMPONENT24, rt.#gl.canvas.width, rt.#gl.canvas.height, 0, rt.#gl.DEPTH_COMPONENT, rt.#gl.UNSIGNED_INT, null);
      GLLib.setTexParams(rt.#gl);
    }

    // Internal render engine Functions
    function frameCycle (Millis) {
      // generate bounding volumes
      rt.scene.updateBoundings();
			// Clear screen
      rt.#gl.clear(rt.#gl.COLOR_BUFFER_BIT | rt.#gl.DEPTH_BUFFER_BIT);
      // Check if recompile is required
      if (State !== rt.renderQuality) {
        resize();
        prepareEngine();
        State = rt.renderQuality;
      }
      // Request the browser to render frame with hardware acceleration
      if (!rt.#halt) requestAnimationFrame(frameCycle);
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
      rt.#gl.bindVertexArray(Vao);
      rt.#gl.useProgram(Program);
      // Set world-texture
      rt.updateScene();
      rt.updatePrimaryLightSources();

      rt.#gl.activeTexture(rt.#gl.TEXTURE0);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#worldTexture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE1);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#pbrTexture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE2);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#translucencyTexture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE3);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#texture);
      rt.#gl.activeTexture(rt.#gl.TEXTURE4);
      rt.#gl.bindTexture(rt.#gl.TEXTURE_2D, rt.#lightTexture);
      // Set uniforms for shaders
      // Set 3d camera position
      rt.#gl.uniform3f(CameraPosition, rt.camera.x, rt.camera.y, rt.camera.z);
      // Set x and y rotation of camera
      // Randomize camera position if Taa is enabled
      if (rt.#antialiasing !== null && rt.#antialiasing.toLocaleLowerCase() === 'taa') {
        let jitter = rt.#AAObject.jitter(rt.#canvas);
        rt.#gl.uniform2f(Perspective, rt.camera.fx + jitter.x, rt.camera.fy + jitter.y);
      } else  {
        rt.#gl.uniform2f(Perspective, rt.camera.fx, rt.camera.fy);
      }
      // Set fov and X/Y ratio of screen
      rt.#gl.uniform4f(RenderConf, rt.camera.fov, rt.#gl.canvas.width / rt.#gl.canvas.height, 1, 1);
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
      let vertices = [];
      let ids = [];
      let uvs = [];
      let id = 0;
      let length = 0;
      // Iterate through render queue and build arrays for GPU
      var flattenQUEUE = (item) => {
        if (Array.isArray(item) || item.indexable){
          // Iterate over all sub elements
          for (let i = 0; i < item.length; i++){
            // flatten sub element of queue
            flattenQUEUE(item[i]);
          }
        } else {
					id ++;
          for(let i = 0; i < item.ids.length; i+=2) {
            ids.push(item.ids[i], item.ids[i + 1], id / 65535, id / 256);
          }
					vertices.push(item.vertices);
          uvs.push(item.uvs);
          length += item.length;
        }
      };
      // Start recursion
      rt.scene.queue.forEach(item => flattenQUEUE(item));
      // Set buffers
      [
        [PositionBuffer, vertices],
        [IdBuffer, ids],
        [TexBuffer, uvs]
      ].forEach(function(item) {
        rt.#gl.bindBuffer(rt.#gl.ARRAY_BUFFER, item[0]);
        rt.#gl.bufferData(rt.#gl.ARRAY_BUFFER, new Float32Array(item[1].flat()), rt.#gl.DYNAMIC_DRAW);
      });
      // Actual drawcall
      rt.#gl.drawArrays(rt.#gl.TRIANGLES, 0, length);
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
      rt.updateTextures();
      rt.updatePbrTextures();
      rt.updateTranslucencyTextures();
      // Compile shaders and link them into Program global
      Program = GLLib.compile (rt.#gl, rt.#vertexGlsl, rt.#fragmentGlsl);
      // Create global vertex array object (Vao)
      rt.#gl.bindVertexArray(Vao);
      // Bind uniforms to Program
      CameraPosition = rt.#gl.getUniformLocation(Program, 'camera_position');
      Perspective = rt.#gl.getUniformLocation(Program, 'perspective');
      RenderConf = rt.#gl.getUniformLocation(Program, 'conf');
      AmbientLocation = rt.#gl.getUniformLocation(Program, 'ambient');
      WorldTex = rt.#gl.getUniformLocation(Program, 'world_tex');
      TextureWidth = rt.#gl.getUniformLocation(Program, 'texture_width');
      HdrLocation = rt.#gl.getUniformLocation(Program, 'hdr');

      LightTex = rt.#gl.getUniformLocation(Program, 'light_tex');
      PbrTex = rt.#gl.getUniformLocation(Program, 'pbr_tex');
      TranslucencyTex = rt.#gl.getUniformLocation(Program, 'translucency_tex');
      Tex = rt.#gl.getUniformLocation(Program, 'tex');
      // Enable depth buffer and therefore overlapping vertices
      rt.#gl.enable(rt.#gl.BLEND);
      rt.#gl.enable(rt.#gl.DEPTH_TEST);
      rt.#gl.blendEquation(rt.#gl.FUNC_ADD);
      rt.#gl.blendFuncSeparate(rt.#gl.ONE, rt.#gl.ONE_MINUS_SRC_ALPHA, rt.#gl.ONE, rt.#gl.ONE);
      rt.#gl.depthMask(true);
      // Cull (exclude from rendering) hidden vertices at the other side of objects
      // rt.#gl.enable(rt.#gl.CULL_FACE);
      // Set clear color for framebuffer
      rt.#gl.clearColor(0, 0, 0, 0);
      // Define Program with its currently bound shaders as the program to use for the webgl2 context
      rt.#gl.useProgram(Program);
      // Create Textures for primary render
      rt.#pbrTexture = rt.#gl.createTexture();
      rt.#translucencyTexture = rt.#gl.createTexture();
      rt.#texture = rt.#gl.createTexture();
      // Create texture for all primary light sources in scene
      rt.#lightTexture = rt.#gl.createTexture();
      // Init a world texture containing all information about world space
      rt.#worldTexture = rt.#gl.createTexture();
      // Create buffers
      [PositionBuffer, IdBuffer, TexBuffer] = [rt.#gl.createBuffer(), rt.#gl.createBuffer(), rt.#gl.createBuffer()];
      [
        // Bind world space position buffer
        [PositionBuffer, 3, false],
        // Surface id buffer
        [IdBuffer, 4, false],
        // Set barycentric texture coordinates
        [TexBuffer, 2, true]
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
