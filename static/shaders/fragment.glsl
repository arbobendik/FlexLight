#version 300 es

precision highp float;
in vec3 player;
in vec3 position;
in vec3 normal;
in vec2 tex_coord;
in vec4 color;
in mat3 triangle;

vec3 light = vec3(1.0, 2.0, 3.0);
uniform sampler2D world_tex;

out vec4 outColor;

bool shadowTrace(vec3 n, vec3 l, vec3 p, mat3 t)
{
  r = normalize(l - p);
  if(dot(n, r) == 0.0)
  {
    return false;
  }
  s = (n.x * t[0].x + n.y * t[0].y + n.z * t[0].z) / (n.x * r.x + n.y * r.y + n.z * r.z);
  d = s * r;
  return true;
}

void main()
{
  outColor = vec4(
    dot(
      normalize(vec3(-1.0, -1.0, 1.0) * position + vec3(-1.0, 1.0, -1.0) * light),
      normal
    ) * color.xyz, color.w
  );
}
