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
      return shader;
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
  if (Gl.getProgramParameter(Program, Gl.LINK_STATUS))
  {
    return;
  }
  // Log debug info and delete Program if Program fails to link.
  console.log(Gl.getProgramInfoLog(Program));
  Gl.deleteProgram(Program);
}

async function fetchShader(url)
{
  return await (await fetch(url)).text();
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
  }, 10);
