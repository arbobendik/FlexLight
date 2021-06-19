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
  // Create a texture.
  var texture = Gl.createTexture();
  // use texture unit 0
  Gl.activeTexture(Gl.TEXTURE0 + 0);
  // bind to the TEXTURE_2D bind point of texture unit 0
  Gl.bindTexture(Gl.TEXTURE_2D, texture);
  // fill texture with 3x2 pixels
  {
    const level = 0;
    const internalFormat = Gl.R8;
    const width = 3;
    const height = 2;
    const border = 0;
    const format = Gl.RED;
    const type = Gl.UNSIGNED_BYTE;
    const data = new Uint8Array([
      128,  64, 128,
        0, 192,   0,
    ]);
    Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);
    Gl.texImage2D(Gl.TEXTURE_2D, level, internalFormat, width, height, border, format, type, data);
    // set the filtering so we don't need mips
    Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
    Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
    Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_S, Gl.CLAMP_TO_EDGE);
    Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_WRAP_T, Gl.CLAMP_TO_EDGE);
  }
}

  setInterval(function()
  {
    let rand = () => 1 - 2 * Math.random();
    let rect = rect_prism(rand(), rand(), rand());
    rect.width = 0.5 * Math.random();
    rect.height = 0.5 * Math.random();
    rect.depth = 0.5 * Math.random();
    rect.color = [0, 0, 0].map((item) => Math.random()).concat([1]);
    rect = rect(rect);
    QUEUE.push(rect);
    // Remove first element if there are more or equal then 250.
    if (QUEUE.length > 100) QUEUE.shift();
  }, 1000);
