#version 300 es

precision highp float;
in vec3 player;
in vec3 position;
in vec3 normal;
in vec2 tex_coord;
in vec4 color;
in vec3 clip_space;

// Declare null vector as constant.
const vec3 null = vec3(0.0, 0.0, 0.0);

vec3 light = vec3(0.0, 3.0, 0.0);
float strength = 3.0;
uniform sampler2D world_tex;

out vec4 outColor;


// light source, pixel position, triangle points a, b, c, normal.
bool rayTriangle(vec3 l, vec3 r, vec3 p, vec3 a, vec3 b, vec3 c, vec3 n){
  float dnr = dot(n, r);
  // Test if ray or surface face in same direction.
  if(sign(n) == sign(r)) return false;
  // Test if ray and plane are parallel.
  if(dnr == 0.0) return false;
  // Get distance to intersection point.
  float s = dot(n , a - p) / dnr;
  // Ensure that ray triangle intersection is between light source and texture.
  if(s > length(l - p) || s <= 0.0) return false;
  // Calculate intersection point.
  vec3 d = (s * r) + p;
  // Test if point on plane is in Triangle by looking for each edge if point is in or outside.
  vec3 v0 = c - a;
  vec3 v1 = b - a;
  vec3 v2 = d - a;
  // Precalculate dot products.
  float d00 = dot(v0, v0);
  float d01 = dot(v0, v1);
  float d02 = dot(v0, v2);
  float d11 = dot(v1, v1);
  float d12 = dot(v1, v2);
  // Compute coordinates.
  float i = 1.0 / (d00 * d11 - d01 * d01);
  float u = (d11 * d02 - d01 * d12) * i;
  float v = (d00 * d12 - d01 * d02) * i;
  // Return if ray intersects triangle or not.
  return (u > 0.0) && (v > 0.0) && (u + v < 1.0);
}

// Licht, Ray , Pixel-Position, x, x2,
bool rayCuboid(vec3 l, vec3 r, vec3 p, vec3 mini, vec3 maxi){
  // Calculate multiples of ray for each max and min value per dimension.
  /*
  r.x * s.lx = mini.x
  r.y * s.ly = mini.y
  r.z * s.lz = mini.z

  r.x * s.ux = max.x
  r.y * s.uy = max.y
  r.z * s.uz = max.z

  s.u > s.l

  */
  vec3 lower_s = (mini - p) / r;
  vec3 upper_s = (maxi - p) / r;
  // Test if ranges are overlapping.
  return true;
  return greaterThan(upper_s, lower_s) == bvec3(true, true, true); //&&
         //greaterThan(upper_s, lower_s.zzy) == bvec3(true, true, true) &&
         //greaterThan(lower_s, null) == bvec3(true, true, true) &&
         //greaterThan(l, lower_s) == bvec3(true, true, true);
}

bool lightTrace(sampler2D tex, vec3 ray, vec3 light){
  // Get texture size as max iteration value.
  ivec2 size = textureSize(world_tex, 0);
  // Test if pixel is in shadow or not.
  bool in_shadow = false;
  // Iterate through lines of texture.
  for(int i = 0; i < size.y && !in_shadow; i++){
    // Read point a and normal from traingle.
    vec3 n = texelFetch(tex, ivec2(4, i), 0).xyz;
    vec3 a = texelFetch(tex, ivec2(0, i), 0).xyz;
    // Fetch triangle coordinates from world texture.
    //  Three cases:
    //   - normal is not 0 0 0 --> normal vertex
    //   - normal is 0 0 0 --> beginning of new bounding volume
    if(n != null){
      vec3 b = texelFetch(tex, ivec2(1, i), 0).xyz;
      vec3 c = texelFetch(tex, ivec2(2, i), 0).xyz;
      // Test if triangle intersects ray.
      in_shadow = rayTriangle(light, ray, position, a, b, c, n);
    }else{
      vec3 b = texelFetch(tex, ivec2(1, i), 0).xyz;
      // Test if Ray intersects bounding volume.
      // a = x x2 y
      // b = y2 z z2
      if(!rayCuboid(light, ray, position, vec3(a.x, a.z, b.y), vec3(a.y, b.x, b.z))){
        vec3 c = texelFetch(tex, ivec2(2, i), 0).xyz;
        // If it doesn't intersect, skip ahadow test for all elements in bounding volume.
        i += 12;
      }
    }
  }
  // Return if bounding volume is partially in shadow or not.
  return in_shadow;
}

void main(){
  // Test if pixel is in shadow or not.
  bool in_shadow = false;
  if(clip_space.z < 0.0) return;
  vec3 ray = normalize(light - position);
  // Iterate over traingles in scene.
  if(dot(ray, normal) > 0.0){
    // Start hybrid ray tracing.
    in_shadow = lightTrace(world_tex, ray, light);
  }

  float intensity = strength / (1.0 + length(light - position) / strength);
  if(in_shadow){
    outColor = vec4(0.0 * color.xyz, color.w);
  }else{
    vec3 view = normalize(vec3(-player.x, player.yz) - position);
    vec3 halfVector = normalize(ray + view);
    float l = dot(normalize(vec3(-light.x - position.x, ray.y, -light.z + position.z)), normal);
    float specular = pow(dot(normal, halfVector), 50.0 * strength);
    outColor = vec4(color.xyz * l * intensity, color.w);
    if (specular > 0.0) outColor.rgb += specular * intensity;
  }
}
