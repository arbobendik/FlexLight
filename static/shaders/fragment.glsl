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


bool sameSide(vec3 p1, vec3 p2, vec3 a, vec3 b)
{
    vec3 cp1 = cross(b-a, p1-a);
    vec3 cp2 = cross(b-a, p2-a);
    return (dot(cp1, cp2) >= 0.0);
}

bool isPointInTriangle(vec3 p, vec3 a, vec3 b, vec3 c)
{
    return sameSide(p,a, b,c) && sameSide(p,b, a,c) && sameSide(p,c, a,b);
}

bool shadowTrace(vec3 n, vec3 l, vec3 p, mat3 t)
{
  vec3 r = normalize(l - p);
  if(dot(n, r) == 0.0)
  {
    return false;
  }
  vec3 a = t[0] - p;
  float s = (n.x * a.x + n.y * a.y + n.z * a.z) / (n.x * r.x + n.y * r.y + n.z * r.z);
  if (s > length(l - p))
  {
    return false;
  }
  vec3 c = p + s * r;
  return isPointInTriangle(c, t[0], t[1], t[2]);
}

void main()
{
  ivec2 size = textureSize(world_tex, 0);
  bool in_shadow = false;
  for(int i = 0; i < 12 && in_shadow == false; ++i)
  {
    mat3 t = mat3(
      texelFetch(world_tex, ivec2(0, i), 0).xyz,
      texelFetch(world_tex, ivec2(1, i), 0).xyz,
      texelFetch(world_tex, ivec2(2, i), 0).xyz
    );
    if(t!=triangle)
    {
      vec3 n = texelFetch(world_tex, ivec2(4, i), 0).xyz;
      in_shadow = shadowTrace(n, light, position, t);
    }
  }
  if (in_shadow)
  {
    outColor = vec4(0.3 * color.xyz, color.w);
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
