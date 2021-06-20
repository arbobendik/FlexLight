"use strict";

async function initEngine()
{
	// Compile shaders and link them into Program global.
  await buildProgram([
    {source:await fetchShader("static/shaders/vertex.glsl"),type:Gl.VERTEX_SHADER},
    {source:await fetchShader("static/shaders/fragment.glsl"),type:Gl.FRAGMENT_SHADER}
  ]);
	// Bind Attribute varying to their respective shader locations.
	Gl.bindAttribLocation(Program, Position, "position_3d");
  Gl.bindAttribLocation(Program, Normal, "normal_3d");
  Gl.bindAttribLocation(Program, TexCoord, "tex_pos");
  Gl.bindAttribLocation(Program, Color, "color_3d");
  Gl.bindAttribLocation(Program, Triangle, "triangle_3d");
	// Bind uniforms to Program.
  PlayerPosition = Gl.getUniformLocation(Program, "player_position");
  Perspective = Gl.getUniformLocation(Program, "perspective");
  RenderConf = Gl.getUniformLocation(Program, "conf");
  WorldTex = Gl.getUniformLocation(Program, "world_tex");
  // Set texture
  worldTextureBuilder();
  // Set pixel density in canvas correctly.
  Gl.viewport(0, 0, Gl.canvas.width, Gl.canvas.height);
	// Enable depth buffer and therefore overlapping vertices.
  Gl.enable(Gl.DEPTH_TEST);
	// Cull (exclude from rendering) hidden vertices at the other side of objects.
  Gl.enable(Gl.CULL_FACE);
	// Define Program with its currently bound shaders as the program to use for the webgl2 context.
  Gl.useProgram(Program);
  // Create global vertex array object (VAO).
  VAO = Gl.createVertexArray();
  Gl.bindVertexArray(VAO);
  // Prepare position buffer for coordinates array.
  PositionBuffer = Gl.createBuffer();
  // Create a buffer for normals.
  NormalBuffer = Gl.createBuffer();
  // Create a buffer for tex_coords.
  //TexBuffer = Gl.createBuffer();
  // Create a buffer for colors.
  ColorBuffer = Gl.createBuffer();
  // Create a buffer for triangles.
  TriangleBuffer = Gl.createBuffer();
  // Begin frame cycle.
  frameCycle();
}

function frameCycle()
{
	// Clear Canvas after each frame.
	Gl.clearColor(0, 0, 0, 0);
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
  worldTextureBuilder();
  // Set uniforms for shaders.
  Gl.uniform3f(PlayerPosition, X, Y, Z);
  Gl.uniform2f(Perspective, Fx, Fy);
  Gl.uniform4f(RenderConf, Fov, Ratio, 0.05, 1);
  // Iterate through render queue and create frame.
  QUEUE.forEach((item, i) => {
    // Pass whole current world space as data structure to GPU.
    Gl.uniform1i(WorldTex, 0);
		// Pass the item itself to be able to access all the set properties correctly in the inner closure.
    // Set PositionBuffer.
    Gl.bindBuffer(Gl.ARRAY_BUFFER, PositionBuffer);
    Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(item.vertices), Gl.DYNAMIC_DRAW);
    Gl.enableVertexAttribArray(Position);
    Gl.vertexAttribPointer(Position, 3, Gl.FLOAT, false, 0, 0);
    Gl.bindVertexArray(VAO);
    // Set NormalBuffer.
    Gl.bindBuffer(Gl.ARRAY_BUFFER, NormalBuffer);
    Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(item.normals), Gl.DYNAMIC_DRAW);
    Gl.enableVertexAttribArray(Normal);
    Gl.vertexAttribPointer(Normal, 3, Gl.FLOAT, false, 0, 0);
    Gl.bindVertexArray(VAO);
    // Set ColorBuffer.
    Gl.bindBuffer(Gl.ARRAY_BUFFER, ColorBuffer);
    Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(item.colors), Gl.DYNAMIC_DRAW);
    Gl.enableVertexAttribArray(Color);
    Gl.vertexAttribPointer(Color, 4, Gl.FLOAT, false, 0, 0);
    Gl.bindVertexArray(VAO);
    // Set TriangleBuffer.
    Gl.bindBuffer(Gl.ARRAY_BUFFER, TriangleBuffer);
    Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(item.triangles), Gl.DYNAMIC_DRAW);
    Gl.enableVertexAttribArray(Triangle);
    Gl.vertexAttribPointer(Triangle, 3, Gl.FLOAT, false, 36, 0);
    /* Set TexBuffer
    Gl.bindBuffer(Gl.ARRAY_BUFFER, TexBuffer);
    Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(item.worldTex), Gl.STATIC_DRAW);
    Gl.enableVertexAttribArray(TexCoord);
    Gl.vertexAttribPointer(TexCoord, 2, Gl.FLOAT, true, 0, 0);
    */
    // Actual drawcall.
    Gl.drawArrays(Gl.TRIANGLES, 0, item.arrayLength);
  });
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
