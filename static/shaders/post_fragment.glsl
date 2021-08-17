#version 300 es

precision highp float;
in vec2 clip_space;
uniform sampler2D pre_render;
out vec4 out_color;

void main(){

  // Get texture size.
  vec2 texel = vec2(textureSize(pre_render, 0)) * clip_space;

  vec4 original_color = texelFetch(pre_render, ivec2(texel), 0);
  vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
  float count = 0.0;
  int increment = 1;
  int radius = 1 + int(float(textureSize(pre_render, 0).x) * 0.08 * original_color.w);

  // Apply 3x3 kernel on image.
  for(int i = 0; i < radius; i++){
    for(int j = 0; j < radius; j++){
      vec4 next_color = texelFetch(pre_render, ivec2(texel + vec2(i, j) * float(increment) - float(radius * increment / 2)), 0);
      if (original_color.w == next_color.w){
        color += next_color;
        count ++;
      }
    }
  }
  if (color.w > 0.0){
    out_color = vec4((color.xyz / count), 1.0);
  }else{
    out_color = vec4(0.0, 0.0, 0.0, 0.0);
  }
}
