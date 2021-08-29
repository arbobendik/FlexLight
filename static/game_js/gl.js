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
  DataHeight = Data.length / 24;
  // Tell webgl to use 4 bytes per value for the 32 bit floats.
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 4);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGB32F, 8, DataHeight, 0, Gl.RGB, Gl.FLOAT, new Float32Array(Data));
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
}

function randomTextureBuilder()
{
  Gl.bindTexture(Gl.TEXTURE_2D, RandomTexture);
  // Fill texture with pseudo random pixels.
  // Tell webgl to use 1 byte per value for the 8 bit ints.
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.LINEAR_MIPMAP_LINEAR);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.LINEAR);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGB8, Gl.canvas.width, Gl.canvas.height, 0, Gl.RGB, Gl.UNSIGNED_BYTE, new Uint8Array(Random));
  Gl.generateMipmap(Gl.TEXTURE_2D);
}

function updateNormal()
{
  Gl.bindTexture(Gl.TEXTURE_2D, NormalTexture);
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);

  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);

  let [width, height] = TEXTURE_SIZES;
  var ScaledTextures = [];

  NORMAL_TEXTURE.forEach(async (item, i) => {
    if(Array.isArray(item))
    {
      ScaledTextures.push(new Array(width * height).fill(item).flat());
    }
    else
    {
      var canvas = document.createElement('canvas');
      var ctx = canvas.getContext('2d');
      canvas.width = width;
      canvas.height = height;
      ctx.drawImage(item, 0, 0, width, height);
      let array = Array.from(ctx.getImageData(0, 0, width, height).data);
      for (let i = 0; i < array.length; i++)
      {
        if (i%4 === 0) ScaledTextures.push(array[i]);
      }
    }
  });

  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.R8, width, height * NORMAL_TEXTURE.length, 0, Gl.RED, Gl.UNSIGNED_BYTE, new Uint8Array(ScaledTextures.flat()));
}

function updateTexture()
{
  Gl.bindTexture(Gl.TEXTURE_2D, ColorTexture);
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);

  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);

  let [width, height] = TEXTURE_SIZES;
  var ScaledTextures = [];

  TEXTURE.forEach(async (item, i) => {
      //var newImg = document.createElement('img');
      var canvas = document.createElement('canvas');
      var ctx = canvas.getContext('2d');
      canvas.width = width;
      canvas.height = height;
      ctx.drawImage(item, 0, 0, width, height);
      ScaledTextures.push(Array.from(ctx.getImageData(0, 0, width, height).data));
  });

  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGBA, width, height * TEXTURE.length, 0, Gl.RGBA, Gl.UNSIGNED_BYTE, new Uint8Array(ScaledTextures.flat()));
}

function renderTextureBuilder(){
  Gl.bindTexture(Gl.TEXTURE_2D, ColorRenderTexture);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGBA, Gl.canvas.width, Gl.canvas.height, 0, Gl.RGBA, Gl.UNSIGNED_BYTE, null);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);

  Gl.bindTexture(Gl.TEXTURE_2D, NormalRenderTexture);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGBA, Gl.canvas.width, Gl.canvas.height, 0, Gl.RGBA, Gl.UNSIGNED_BYTE, null);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);

  Gl.bindTexture(Gl.TEXTURE_2D, OriginalRenderTexture);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGBA, Gl.canvas.width, Gl.canvas.height, 0, Gl.RGBA, Gl.UNSIGNED_BYTE, null);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);

  Gl.bindTexture(Gl.TEXTURE_2D, IdRenderTexture);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGBA, Gl.canvas.width, Gl.canvas.height, 0, Gl.RGBA, Gl.UNSIGNED_BYTE, null);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);

  Gl.bindTexture(Gl.TEXTURE_2D, DepthTexture);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.DEPTH_COMPONENT24, Gl.canvas.width, Gl.canvas.height, 0, Gl.DEPTH_COMPONENT, Gl.UNSIGNED_INT, null);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);
}

function postRenderTextureBuilder(){
  Gl.bindTexture(Gl.TEXTURE_2D, KernelTexture);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGBA, Gl.canvas.width, Gl.canvas.height, 0, Gl.RGBA, Gl.UNSIGNED_BYTE, null);

  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
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
    Data.push(b[0],b[1],b[2],b[3],b[4],b[5],0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    // Iterate over all sub elements and skip bounding (item[0]).
    for (let i = 1; i < item.length; i++){
      // Push sub elements in QUEUE.
      fillData(item[i]);
    }
    let len = Math.floor((Data.length - len_pos) / 24);
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
    let t = item.textureNums;
    let uv = item.uvs;
    let len = item.arrayLength;
    // Declare bounding volume of object.
    try{
      Data.push(b[0],b[1],b[2],b[3],b[4],b[5],len/3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    }catch{
      console.warn(item);
    }
    // Data.push(b[0],b[1],b[2],b[3],b[4],b[5],len/3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    for(let i = 0; i < len * 3; i += 9){
      let j = i/3*2
      // 1 vertex = 1 line in world texture.
      // a, b, c, color, normal, texture_nums, UVs1, UVs2.
      Data.push(v[i],v[i+1],v[i+2],v[i+3],v[i+4],v[i+5],v[i+6],v[i+7],v[i+8],c[i/9*4],c[i/9*4+1],c[i/9*4+2],n[i],n[i+1],n[i+2],t[j],t[j+1],0,uv[j],uv[j+1],uv[j+2],uv[j+3],uv[j+4],uv[j+5]);
    }
  }
}
