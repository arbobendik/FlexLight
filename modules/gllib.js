'use strict';

export class GLLib {

  static blankGlsl = `#version 300 es
  in vec2 position_2d;
  // Pass clip space position to fragment shader
  out vec2 clip_space;
  void main() {
    vec2 pos = position_2d * 2.0 - 1.0;
    // Set final clip space position
    gl_Position = vec4(pos, 0, 1);
    clip_space = position_2d;
  }
  `;

  static buildProgram = (gl, shaders) => {
    // Create Program, compile and append vertex and fragment shader to it
    let program = gl.createProgram();
    // Compile GLSL shaders
    shaders.forEach((item, i) => {
      let shader = gl.createShader(item.type);
      gl.shaderSource(shader, item.source);
      gl.compileShader(shader);
      // Append shader to Program if GLSL compiled successfully
      if (gl.getShaderParameter(shader, gl.COMPILE_STATUS)){
        gl.attachShader(program, shader);
      }else{
        // Log debug info and delete shader if shader fails to compile
        console.warn(gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
      }
    });
    gl.linkProgram(program);
    // Return Program if it links successfully
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)){
      console.log(shaders);
      // Log debug info and delete Program if Program fails to link
      console.warn(gl.getProgramInfoLog(program));
      gl.deleteProgram(program);
    }else{
      return program;
    }
  };

  static setTexParams = (gl) => {
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  };
}