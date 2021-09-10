#version 300 es

precision highp float;
in vec2 clip_space;

uniform sampler2D pre_render_color;
uniform sampler2D pre_render_normal;
uniform sampler2D pre_render_original_color;
uniform sampler2D pre_render_id;

out vec4 out_color;

void main(){

  // Get texture size.
  ivec2 texel = ivec2(vec2(textureSize(pre_render_color, 0)) * clip_space);

  vec4 center_color = texelFetch(pre_render_color, texel, 0);
  vec4 center_normal = texelFetch(pre_render_normal, texel, 0);
  vec4 center_original_color = texelFetch(pre_render_original_color, texel, 0);
  vec4 center_id = texelFetch(pre_render_id, texel, 0);

  vec4 color = center_color;
  float count = 1.0;
  int increment = 3;
  int max_radius = 6;
  int radius = 3 + int(sqrt(float(textureSize(pre_render_color, 0).x * textureSize(pre_render_color, 0).y)) * 0.02 * center_original_color.w);
  // Force max radius.
  if(radius > max_radius) radius = max_radius;

  // Apply blur filter on image.
  for(int i = 0; i < radius; i++){
    for(int j = 0; j < radius; j++){

      ivec2 coords = ivec2(vec2(texel) + vec2(i, j) * float(increment) - float(radius * increment / 2));
      vec4 next_color = texelFetch(pre_render_color, coords, 0);
      vec4 normal = texelFetch(pre_render_normal, coords, 0);
      vec4 original_color = texelFetch(pre_render_original_color, coords, 0);
      vec4 id = texelFetch(pre_render_id, coords, 0);

      if (normal == center_normal && center_id == id/*){ // Pixel effect : */&& original_color.xyzw == center_original_color.xyzw){
        color += next_color;
        count ++;
      }
    }
  }
  if (color.w > 0.0){
    // Set out color for render texture for the antialiasing filter.
    out_color = vec4(color.xyz / count, 1.0);
  }else{
    out_color = vec4(0.0, 0.0, 0.0, 0.0);
  }
}
