#version 300 es

precision highp float;
in vec3 player;
in vec3 position;
in vec3 normal;
in vec2 tex_coord;
in vec4 color;
in mat3 triangle;

vec3 light = vec3(0.0, 3.0, 0.0);
uniform sampler2D world_tex;
uniform int world_tex_height;

out vec4 outColor;

bool shadowTrace(vec3 n, vec3 l, vec3 p, mat3 t) // normal, light source, pixel position, triangle.
{
  vec3 r = normalize(l - p);
  // Test if ray and plane are parallel.
  if(dot(n, r) == 0.0) return false;
  float s = dot(n , t[0] - p) / dot(n, r);
  // Ensure that ray triangle intersection is between light source and texture.
  if (s > length(l - p) || s <= 0.0) return false;
  // Calculate intersection point.
  vec3 c = s * r + p;
  // Pre calculate differences.
  vec3 t10 = t[1] - t[0];
  vec3 t20 = t[2] - t[0];
  vec3 t21 = t[2] - t[1];
  vec3 ct0 = c - t[0];
  // Test if point on plane is in Triangle by looking for each edge if point is in or outside.
  if (dot(cross(t21, c-t[1]), cross(t21, -t10)) < 0.0) return false;
  if (dot(cross(t20, ct0), cross(t20, t10)) < 0.0) return false;
  if (dot(cross(t10, ct0), cross(t10, t20)) < 0.0) return false;
  return true;
}

void main()
{
  ivec2 size = textureSize(world_tex, 0);
  bool in_shadow = false;
  for(int i = 0; i < size.y && in_shadow == false; i++)
  {
    mat3 t = mat3(
      texelFetch(world_tex, ivec2(0, i), 0).xyz,
      texelFetch(world_tex, ivec2(1, i), 0).xyz,
      texelFetch(world_tex, ivec2(2, i), 0).xyz
    );
    vec3 n = texelFetch(world_tex, ivec2(4, i), 0).xyz;
    in_shadow = shadowTrace(n, light, position, t);
  }

  if (in_shadow)
  {
    outColor = vec4(0.2 * color.xyz, color.w);
  }
  else
  {
    outColor = vec4(
      dot(
        normalize(vec3(-1.0, -1.0, 1.0) * position + vec3(-1.0, 1.0, -1.0) * light),
        normal
      ) * color.xyz, color.w
    );
  }
}
