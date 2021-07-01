"use strict";

async function initEngine()
{
	// Compile shaders and link them into Program global.
  await buildProgram([
    {source:await fetchShader("static/shaders/vertex.glsl"),type:Gl.VERTEX_SHADER},
    {source:await fetchShader("static/shaders/fragment.glsl"),type:Gl.FRAGMENT_SHADER}
  ]);
    // Create global vertex array object (VAO).
  VAO = Gl.createVertexArray();
  Gl.bindVertexArray(VAO);
	// Bind Attribute varying to their respective shader locations.
	Gl.bindAttribLocation(Program, Position, "position_3d");
  Gl.bindAttribLocation(Program, Normal, "normal_3d");
  Gl.bindAttribLocation(Program, TexCoord, "tex_pos");
  Gl.bindAttribLocation(Program, Color, "color_3d");Gl.enableVertexAttribArray (Position);
	// Bind uniforms to Program.
  PlayerPosition = Gl.getUniformLocation(Program, "player_position");
  Perspective = Gl.getUniformLocation(Program, "perspective");
  RenderConf = Gl.getUniformLocation(Program, "conf");
  WorldTex = Gl.getUniformLocation(Program, "world_tex");
  WorldTexHeight = Gl.getUniformLocation(Program, "world_tex_height");
  // Set pixel density in canvas correctly.
  Gl.viewport(0, 0, Gl.canvas.width, Gl.canvas.height);
	// Enable depth buffer and therefore overlapping vertices.
  Gl.enable(Gl.DEPTH_TEST);
	// Cull (exclude from rendering) hidden vertices at the other side of objects.
  Gl.enable(Gl.CULL_FACE);
  // Set clear color for canvas.
	Gl.clearColor(0, 0, 0, 0);
	// Define Program with its currently bound shaders as the program to use for the webgl2 context.
  Gl.useProgram(Program);
  // Prepare position buffer for coordinates array.
  PositionBuffer = Gl.createBuffer();
  // Create a buffer for normals.
  NormalBuffer = Gl.createBuffer();
  // Create a buffer for tex_coords.
  //TexBuffer = Gl.createBuffer();
  // Create a buffer for colors.
  ColorBuffer = Gl.createBuffer();
  // Create a texture.
  WorldTexture = Gl.createTexture();
  Gl.activeTexture(Gl.TEXTURE0 + 0);
  Gl.bindTexture(Gl.TEXTURE_2D, WorldTexture);
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
  /* Set TexBuffer
  Gl.bindBuffer(Gl.ARRAY_BUFFER, TexBuffer);
  Gl.enableVertexAttribArray(TexCoord);
  Gl.vertexAttribPointer(TexCoord, 2, Gl.FLOAT, true, 0, 0);
  */
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
  // Set Texture.
  //worldTextureBuilder();
  // Set uniforms for shaders.
  Gl.uniform1i(WorldTexHeight, DataHeight);
  Gl.uniform3f(PlayerPosition, X, Y, Z);
  Gl.uniform2f(Perspective, Fx, Fy);
  Gl.uniform4f(RenderConf, Fov, Ratio, 1, 1);
  // Pass whole current world space as data structure to GPU.
  Gl.uniform1i(WorldTex, 0);
  var vertices = [];
  var normals = [];
  var colors = [];
  var length = 0;
  // Iterate through render queue and create frame.
  var flattenQUEUE = (elem) => {
    if (Array.isArray(elem))
    {
      elem.forEach((item, i) => {
        flattenQUEUE(item);
      });
    }
    else
    {
      vertices.push(elem.vertices);
      normals.push(elem.normals);
      colors.push(elem.colors);
      length += elem.arrayLength;
    }
  };
  // Start recursion.
  flattenQUEUE(QUEUE);
  // Pass the item itself to be able to access all the set properties correctly in the inner closure.
  // Set PositionBuffer.
  Gl.bindBuffer(Gl.ARRAY_BUFFER, PositionBuffer);
  Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(vertices.flat()), Gl.DYNAMIC_DRAW);
  // Set NormalBuffer.
  Gl.bindBuffer(Gl.ARRAY_BUFFER, NormalBuffer);
  Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(normals.flat()), Gl.DYNAMIC_DRAW);
  // Set ColorBuffer.
  Gl.bindBuffer(Gl.ARRAY_BUFFER, ColorBuffer);
  Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(colors.flat()), Gl.DYNAMIC_DRAW);
  /* Set TexBuffer.
  Gl.bindBuffer(Gl.ARRAY_BUFFER, TexBuffer);
  Gl.bufferData(Gl.ARRAY_BUFFER, new Float32Array(item.worldTex), Gl.STATIC_DRAW);*/
  // Actual drawcall.
  Gl.drawArrays(Gl.TRIANGLES, 0, length);
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
