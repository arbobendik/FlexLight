"use strict";

async function initEngine()
{
	// Compile shaders and link them into Program global.
  Program = await buildProgram([
    {source:await fetchShader("static/shaders/vertex.glsl"),type:Gl.VERTEX_SHADER},
    {source:await fetchShader("static/shaders/fragment.glsl"),type:Gl.FRAGMENT_SHADER}
  ]);
  // Compile shaders and link them into PostProgram global.
  PostProgram = await buildProgram([
    {source:await fetchShader("static/shaders/post_vertex.glsl"),type:Gl.VERTEX_SHADER},
    {source:await fetchShader("static/shaders/post_fragment.glsl"),type:Gl.FRAGMENT_SHADER}
  ]);
    // Create global vertex array object (VAO).
  Gl.bindVertexArray(VAO);
	// Bind Attribute varying to their respective shader locations.
	Gl.bindAttribLocation(Program, Position, "position_3d");
  Gl.bindAttribLocation(Program, Normal, "normal_3d");
  Gl.bindAttribLocation(Program, TexCoord, "tex_pos");
  Gl.bindAttribLocation(Program, Color, "color_3d");
	// Bind uniforms to Program.
  PlayerPosition = Gl.getUniformLocation(Program, "player_position");
  Perspective = Gl.getUniformLocation(Program, "perspective");
  RenderConf = Gl.getUniformLocation(Program, "conf");
  SamplesLocation = Gl.getUniformLocation(Program, "samples");
  ReflectionsLocation = Gl.getUniformLocation(Program, "reflections");
  WorldTex = Gl.getUniformLocation(Program, "world_tex");
  RandomTex = Gl.getUniformLocation(Program, "random");
  NormalTex = Gl.getUniformLocation(Program, "normal_tex");
  Tex = Gl.getUniformLocation(Program, "tex");
  // Set pixel density in canvas correctly.
  Gl.viewport(0, 0, Gl.canvas.width, Gl.canvas.height);
	// Enable depth buffer and therefore overlapping vertices.
  Gl.enable(Gl.DEPTH_TEST);
  Gl.depthMask(true);
	// Cull (exclude from rendering) hidden vertices at the other side of objects.
  Gl.enable(Gl.CULL_FACE);
  // Set clear color for framebuffer.
	Gl.clearColor(0, 0, 0, 0);
	// Define Program with its currently bound shaders as the program to use for the webgl2 context.
  Gl.useProgram(Program);
  // Prepare position buffer for coordinates array.
  PositionBuffer = Gl.createBuffer();
  // Create a buffer for normals.
  NormalBuffer = Gl.createBuffer();
  // Create a buffer for tex_coords.
  TexBuffer = Gl.createBuffer();
  // Create a buffer for colors.
  ColorBuffer = Gl.createBuffer();
  // Create a world texture containing all information about world space.
  WorldTexture = Gl.createTexture();
  // Create random texture.
  randomTextureBuilder();
  // Bind and set buffer parameters.
  // Bind position buffer.
  Gl.bindBuffer(Gl.ARRAY_BUFFER, PositionBuffer);
  Gl.enableVertexAttribArray(Position);
  Gl.vertexAttribPointer(Position, 3, Gl.FLOAT, false, 0, 0);
  // Bind normal buffer.
  Gl.bindBuffer(Gl.ARRAY_BUFFER, NormalBuffer);
  Gl.enableVertexAttribArray(Normal);
  Gl.vertexAttribPointer(Normal, 3, Gl.FLOAT, false, 0, 0);
  // Bind color buffer.
  Gl.bindBuffer(Gl.ARRAY_BUFFER, ColorBuffer);
  Gl.enableVertexAttribArray(Color);
  Gl.vertexAttribPointer(Color, 4, Gl.FLOAT, false, 0, 0);
  //Set TexBuffer
  Gl.bindBuffer(Gl.ARRAY_BUFFER, TexBuffer);
  Gl.enableVertexAttribArray(TexCoord);
  Gl.vertexAttribPointer(TexCoord, 2, Gl.FLOAT, true, 0, 0);

  // Create frame buffer and texteure to be rendered to.
  Framebuffer = Gl.createFramebuffer();
  renderTextureBuilder();
  // Create post program buffers and uniforms.
  Gl.bindVertexArray(POST_VAO);
  Gl.useProgram(PostProgram);

  PostVertexBuffer = Gl.createBuffer();

  Gl.bindBuffer(Gl.ARRAY_BUFFER, PostVertexBuffer);
  Gl.enableVertexAttribArray(PostPosition);
  Gl.vertexAttribPointer(PostPosition, 2, Gl.FLOAT, false, 0, 0);
  // Fill buffer with data for two verices.
  Gl.bindBuffer(Gl.ARRAY_BUFFER, PostVertexBuffer);
  Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array([0,0,1,0,0,1,1,1,0,1,1,0]), Gl.DYNAMIC_DRAW);

  // Begin frame cycle.
  frameCycle();
}

function frameCycle()
{
  Gl.clear(Gl.COLOR_BUFFER_BIT | Gl.DEPTH_BUFFER_BIT);
	// Render new Image, work through QUEUE.
	renderFrame();
  // Calculate fps by measuring the time it takes to render 30 frames.
  Frame++;
  if (Frame >= 30)
  {
		Frame = 0;
		// Calculate Fps.
    Fps = 30000 / (performance.now() - Micros);
		// Update FpsCounter.
		FpsCounter.innerHTML = Math.round(Fps);
		Micros = window.performance.now();
  }
	// Request the browser to render frame with hardware accelerated rendering.
	requestAnimationFrame(frameCycle);
}

function renderFrame()
{
  {
    // Configure where the final image should go.
    Gl.bindFramebuffer(Gl.FRAMEBUFFER, Framebuffer);
    // Configure framebuffer for color and depth.
    Gl.framebufferTexture2D(Gl.FRAMEBUFFER, Gl.COLOR_ATTACHMENT0, Gl.TEXTURE_2D, RenderTexture, 0);
    Gl.framebufferTexture2D(Gl.FRAMEBUFFER, Gl.DEPTH_ATTACHMENT, Gl.TEXTURE_2D, DepthTexture, 0);
    // Clear depth and color buffers from last frame.
    Gl.clear(Gl.COLOR_BUFFER_BIT | Gl.DEPTH_BUFFER_BIT);

    Gl.bindVertexArray(VAO);
    Gl.useProgram(Program);
    // Set world-texture.
    worldTextureBuilder();

    Gl.activeTexture(Gl.TEXTURE0);
    Gl.bindTexture(Gl.TEXTURE_2D, WorldTexture);
    Gl.activeTexture(Gl.TEXTURE1);
    Gl.bindTexture(Gl.TEXTURE_2D, RandomTexture);
    Gl.activeTexture(Gl.TEXTURE2);
    Gl.bindTexture(Gl.TEXTURE_2D, NormalTexture);
    Gl.activeTexture(Gl.TEXTURE3);
    Gl.bindTexture(Gl.TEXTURE_2D, Texture);
    // Set uniforms for shaders.
    // Set 3d camera position.
    Gl.uniform3f(PlayerPosition, X, Y, Z);
    // Set x and y rotation of camera.
    Gl.uniform2f(Perspective, Fx, Fy);
    // Set fov and X/Y ratio of screen.
    Gl.uniform4f(RenderConf, Fov, Ratio, 1, 1);
    // Set amount of samples per ray.
    Gl.uniform1i(SamplesLocation, Samples);
    // Set max reflections per ray.
    Gl.uniform1i(ReflectionsLocation, Reflections);
    // Pass whole current world space as data structure to GPU.
    Gl.uniform1i(WorldTex, 0);
    // Pass random texture to GPU.
    Gl.uniform1i(RandomTex, 1);
    // Pass normal texture to GPU.
    Gl.uniform1i(NormalTex, 2);
    // Pass texture to GPU.
    Gl.uniform1i(Tex, 3);
    var vertices = [];
    var normals = [];
    var colors = [];
    var textureCoords = [];
    var length = 0;
    // Iterate through render queue and build arrays for GPU.
    var flattenQUEUE = (item) => {
      if (Array.isArray(item))
      {
        // Iterate over all sub elements and skip bounding (item[0]).
        for (let i = 1; i < item.length; i++){
          // flatten sub element of QUEUE.
          flattenQUEUE(item[i]);
        }
      }
      else
      {
        vertices.push(item.vertices);
        normals.push(item.normals);
        colors.push(item.colors);
        textureCoords.push(item.texCorners)
        normalTextureBuilder(item);
        textureBuilder(item);
        length += item.arrayLength;
      }
    };
    // Start recursion.
    QUEUE.forEach((item, i) => {flattenQUEUE(item)});
    // Set PositionBuffer.
    Gl.bindBuffer(Gl.ARRAY_BUFFER, PositionBuffer);
    Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(vertices.flat()), Gl.DYNAMIC_DRAW);
    // Set NormalBuffer.
    Gl.bindBuffer(Gl.ARRAY_BUFFER, NormalBuffer);
    Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(normals.flat()), Gl.DYNAMIC_DRAW);
    // Set ColorBuffer.
    Gl.bindBuffer(Gl.ARRAY_BUFFER, ColorBuffer);
    Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(colors.flat()), Gl.DYNAMIC_DRAW);
    // Set TexBuffer.
    Gl.bindBuffer(Gl.ARRAY_BUFFER, TexBuffer);
    Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(textureCoords.flat()), Gl.STATIC_DRAW);
    // Actual drawcall.
    Gl.drawArrays(Gl.TRIANGLES, 0, length);
  }
  // Apply post processing.
  {
    // Render to canvas now.
    Gl.bindFramebuffer(Gl.FRAMEBUFFER, null);
    // Make pre rendered texture TEXTURE0.
    Gl.activeTexture(Gl.TEXTURE0);
    Gl.bindTexture(Gl.TEXTURE_2D, RenderTexture);
    // Switch program and VAO.
    Gl.useProgram(PostProgram);
    Gl.bindVertexArray(POST_VAO);
    // Pass pre rendered texture to shader.
    Gl.uniform1i(RenderTex, 0);
    // Pass random texture to GPU.
    // Gl.uniform1i(PostRandomTex, 1);
    // Post processing drawcall.
    Gl.drawArrays(Gl.TRIANGLES, 0, 6);
  }
}

// General purpose element prototype.
function Element(foo)
{
  return (x, y, z) => Object.assign(foo.bind({}), {
		x: x,
		y: y,
		z: z
	});
}
