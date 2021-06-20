"use strict";

async function buildProgram(shaders)
{
  // Create Program, compile and append vertex and fragment shader to it.
  Program = Gl.createProgram();
  // Compile GLSL shaders.
  await shaders.forEach(async (item, i) => {
    let shader = Gl.createShader(item.type);
    Gl.shaderSource(shader, item.source);
    Gl.compileShader(shader);
    // Append shader to Program if GLSL compiled successfully.
    if (Gl.getShaderParameter(shader, Gl.COMPILE_STATUS))
    {
      Gl.attachShader(Program, shader);
    }
    else
    {
      // Log debug info and delete shader if shader fails to compile.
      console.log(Gl.getShaderInfoLog(shader));
      Gl.deleteShader(shader);
    }
  });
  Gl.linkProgram(Program);
  // Return Program if it links successfully.
  if (!Gl.getProgramParameter(Program, Gl.LINK_STATUS))
  {
    // Log debug info and delete Program if Program fails to link.
    console.log(Gl.getProgramInfoLog(Program));
    Gl.deleteProgram(Program);
  }
}

async function fetchShader(url)
{
  return await (await fetch(url)).text();
}

function worldTextureBuilder()
{
  // Reset old world space texture.
  Data = [];
  // Fill texture with data pixels.
  for(let q = 0; q < QUEUE.length; q++)fillData(QUEUE[q]);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);

  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGB32F, 5, Data.length / 15, 0, Gl.RGB, Gl.FLOAT, new Float32Array(Data));
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);
}
/*
// Create a texture.
var texture = Gl.createTexture();
// use texture unit 0
Gl.activeTexture(Gl.TEXTURE0 + 0);
// bind to the TEXTURE_2D bind point of texture unit 0
Gl.bindTexture(Gl.TEXTURE_2D, texture);
// fill texture with 3x2 pixels
{
  const level = 0;
  const internalFormat = Gl.RGBA8;
  const width = 3;
  const height = 2;
  const border = 0;
  const format = Gl.RGBA;
  const type = Gl.UNSIGNED_BYTE;
  const data = new Uint8Array([
    128, 128, 128, 255,
    64, 64, 64, 255,
    128, 128, 128, 255,
    0, 0, 0, 255,
    192, 192, 192, 255,
    0, 0, 0, 255
  ]);
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);
  Gl.texImage2D(Gl.TEXTURE_2D, level, internalFormat, width, height, border, format, type, data);
  // set the filtering so we don't need mips
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);
}
*/
async function fillData(item)
{
  let v = item.vertices;
  let c = item.colors;
  let n = item.normals;
  let len = item.arrayLength * 3;
  for(let i = 0; i < len; i += 9){
    Data.push(v[i],v[i+1],v[i+2],v[i+3],v[i+4],v[i+5],v[i+6],v[i+7],v[i+8],c[i],c[i+1],c[i+2],n[i],n[i+1],n[i+2]);
  }
}

  setInterval(function()
  {
    let rand = () => 1 - 2 * Math.random();
    let rect = rect_prism(rand(), rand(), rand());
    rect.width = 0.5 * Math.random();
    rect.height = 0.5 * Math.random();
    rect.depth = 0.5 * Math.random();
    rect = rect(rect);
    QUEUE.push(rect);
    // Remove first element if there are more or equal then 250.
    if (QUEUE.length > 100) QUEUE.shift();
  }, 1000);
