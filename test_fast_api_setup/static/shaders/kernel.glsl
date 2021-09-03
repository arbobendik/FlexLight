#version 300 es

precision highp float;
in vec2 clip_space;
uniform sampler2D pre_render;
out vec4 out_color;

void main(){

  int kernel[12] = int[12](
       1, 2, 1,
       2, 4, 2,
       1, 2, 1,
       0, 0, 0
  );

  // Get texture size.
  vec2 texel = vec2(textureSize(pre_render, 0)) * clip_space;

  vec4 original_color = texelFetch(pre_render, ivec2(texel), 0);
  vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
  float count = 0.0;
  int increment = 1;
  int radius = 3;

  // Apply 3x3 kernel on image.
  for(int i = 0; i < radius; i++){
    for(int j = 0; j < radius; j++){
      vec4 next_color = texelFetch(pre_render, ivec2(texel + vec2(i, j) - float(radius/2)), 0);
        color += next_color * float(kernel[i%3+j]);
        count += float(kernel[i%3+j]);
    }
  }
  if(original_color.w != 0.0){
    out_color = color / count;
  }else{
    out_color = vec4(0.0, 0.0, 0.0, 0.0);
  }
}
