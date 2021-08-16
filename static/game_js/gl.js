"use strict";

async function buildProgram(shaders)
{
  // Create Program, compile and append vertex and fragment shader to it.
  let program = Gl.createProgram();
  // Compile GLSL shaders.
  await shaders.forEach(async (item, i) => {
    let shader = Gl.createShader(item.type);
    Gl.shaderSource(shader, item.source);
    Gl.compileShader(shader);
    // Append shader to Program if GLSL compiled successfully.
    if (Gl.getShaderParameter(shader, Gl.COMPILE_STATUS))
    {
      Gl.attachShader(program, shader);
    }
    else
    {
      // Log debug info and delete shader if shader fails to compile.
      console.warn(Gl.getShaderInfoLog(shader));
      Gl.deleteShader(shader);
    }
  });
  Gl.linkProgram(program);
  // Return Program if it links successfully.
  if (!Gl.getProgramParameter(program, Gl.LINK_STATUS))
  {
    // Log debug info and delete Program if Program fails to link.
    console.warn(Gl.getProgramInfoLog(program));
    Gl.deleteProgram(program);
  }
  else
  {
    return program;
  }
}

async function fetchShader(url)
{
  return await (await fetch(url)).text();
}

function worldTextureBuilder()
{

  Gl.bindTexture(Gl.TEXTURE_2D, WorldTexture);
  // Reset old world space texture.
  Data = [];
  // Fill texture with data pixels.
  for(let i = 0; i < QUEUE.length; i++) fillData(QUEUE[i]);
  // Calculate DataHeight.
  DataHeight = Data.length / 15;
  // Tell webgl to use 4 bytes per value for the 32 bit floats.
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 4);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGB32F, 5, DataHeight, 0, Gl.RGB, Gl.FLOAT, new Float32Array(Data));
}

function randomTextureBuilder()
{
  RandomTexture = Gl.createTexture();
  Gl.bindTexture(Gl.TEXTURE_2D, RandomTexture);
  // Fill texture with pseudo random pixels.
  // Tell webgl to use 4 bytes per value for the 32 bit floats.
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.LINEAR_MIPMAP_LINEAR);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.LINEAR);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGB8, Gl.canvas.width, Gl.canvas.height, 0, Gl.RGB, Gl.UNSIGNED_BYTE, new Uint8Array(Random));
  Gl.generateMipmap(Gl.TEXTURE_2D);
}

function normalTextureBuilder(item)
{
  NormalTexture = Gl.createTexture();
  Gl.bindTexture(Gl.TEXTURE_2D, NormalTexture);
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.R8, item.normalTextureWidth, item.normalTextureHeight, 0, Gl.RED, Gl.UNSIGNED_BYTE, new Uint8Array(item.normalTexture));
  //Gl.generateMipmap(Gl.TEXTURE_2D);
}

function textureBuilder(item)
{
  Texture = Gl.createTexture();
  Gl.bindTexture(Gl.TEXTURE_2D, Texture);
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGB8, item.textureWidth, item.textureHeight, 0, Gl.RGB, Gl.UNSIGNED_BYTE, new Uint8Array(item.texture));
  //Gl.generateMipmap(Gl.TEXTURE_2D);
}

function renderTextureBuilder(){
  RenderTexture = Gl.createTexture();
  Gl.bindTexture(Gl.TEXTURE_2D, RenderTexture);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGBA, Gl.canvas.width, Gl.canvas.height, 0, Gl.RGBA, Gl.UNSIGNED_BYTE, null);

  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.LINEAR);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);

  DepthTexture = Gl.createTexture();
  Gl.bindTexture(Gl.TEXTURE_2D, DepthTexture);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.DEPTH_COMPONENT24, Gl.canvas.width, Gl.canvas.height, 0, Gl.DEPTH_COMPONENT, Gl.UNSIGNED_INT, null);

  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);
}
// Build simple AABB tree (Axis aligned bounding box).
async function fillData(item)
{
  if(Array.isArray(item))
  {
    let b = item[0];
    // Save position of len variable in array.
    let len_pos = Data.length;
    // Begin bounding volume array.
    Data.push(b[0],b[1],b[2],b[3],b[4],b[5],0,0,0,0,0,0,0,0,0);
    // Iterate over all sub elements and skip bounding (item[0]).
    for (let i = 1; i < item.length; i++){
      // Push sub elements in QUEUE.
      fillData(item[i]);
    }
    let len = Math.floor((Data.length - len_pos) / 15);
    // console.log(len);
    // Set now calculated vertices length of bounding box
    // to skip if ray doesn't intersect with it.
    Data[len_pos + 6] = len;
    // console.log(item.slice(1));
  }
  else
  {
    let b = item.bounding;
    // Create extra bounding volume for each object.
    let v = item.vertices;
    let c = item.colors;
    let n = item.normals;
    let len = item.arrayLength;
    // console.log(b);
    // Declare bounding volume of object.
    Data.push(b[0],b[1],b[2],b[3],b[4],b[5],len/3,0,0,0,0,0,0,0,0);
    for(let i = 0; i < len * 3; i += 9){
      // a, b, c, color, normal
      Data.push(v[i],v[i+1],v[i+2],v[i+3],v[i+4],v[i+5],v[i+6],v[i+7],v[i+8],c[i/9*4],c[i/9*4+1],c[i/9*4+2],n[i],n[i+1],n[i+2]);
    }
  }
}

setTimeout(function(){
  // Init surface element.
  let surface = [[-10, 10, -1, -0.9, -10, 10], [],[],[],[],[]];
  // Create 25 surface elements automatically.
  for (let i = 0; i < 25; i++)
  {
    let plane = cuboid(-10 + 4*(i%5), -1, -10 + 4*Math.floor(i / 5));
    plane.width = 4;
    plane.height = 0.1;
    plane.depth = 4;
    plane = plane(plane);
    // Push bounding volume.
    if(i < 5) surface[i%5 + 1].push([-10 + 4*(i%5), -10 + 4*(i%5 + 1), -1, -0.9, -10, 10]);
    // Push vertices.
    surface[i%5 + 1].push(plane);
  }

  // Generate a few cuboids on surface.
  let r0 = cuboid(-1.5, -1, 1.5);
  r0.width = 6;
  r0.height = 3;
  r0 = r0(r0);
  let r1 = cuboid(-1.5, -1, -2);
  r1.width = 3;
  r1.height = 3;
  r1 = r1(r1);
  let r2 = cuboid(0.5, -1, -1);
  r2.height = 3;
  r2 = r2(r2);
  let r3 = cuboid(-1.5, -1, - 1);
  r3.height = 3;
  r3 = r3(r3);
  // And a floating dice.
  let dice = cuboid(5.5, 1.5, 5.5);
  dice = dice(dice);
  // Pack objects on surface together in some bounding structure.
  let objects = [
    [-1.5, 6.5, -1, 2.5, -2, 6.5],
    [[-1.5, 4.5, -1, 2, -2, 2], r0, r1, r2, r3],
    dice
  ];
  // Append surface and objects to QUEUE.
  QUEUE.push(surface, objects);

  worldTextureBuilder();
},1000);
