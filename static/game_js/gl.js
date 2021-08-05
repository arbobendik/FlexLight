"use strict";

async function buildProgram(shaders)
{
  // Create Program, compile and append vertex and fragment shader to it.
  let program = Gl.createProgram();
  // Compile GLSL shaders.
  await shaders.forEach(async (item, i) => {
    let shader = Gl.createShader(item.type);
    Gl.shaderSource(shader, item.source);
    Gl.compileShader(shader);
    // Append shader to Program if GLSL compiled successfully.
    if (Gl.getShaderParameter(shader, Gl.COMPILE_STATUS))
    {
      Gl.attachShader(program, shader);
    }
    else
    {
      // Log debug info and delete shader if shader fails to compile.
      console.warn(Gl.getShaderInfoLog(shader));
      Gl.deleteShader(shader);
    }
  });
  Gl.linkProgram(program);
  // Return Program if it links successfully.
  if (!Gl.getProgramParameter(program, Gl.LINK_STATUS))
  {
    // Log debug info and delete Program if Program fails to link.
    console.warn(Gl.getProgramInfoLog(program));
    Gl.deleteProgram(program);
  }
  else
  {
    return program;
  }
}

async function fetchShader(url)
{
  return await (await fetch(url)).text();
}

function worldTextureBuilder()
{

  Gl.bindTexture(Gl.TEXTURE_2D, WorldTexture);
  // Reset old world space texture.
  Data = [];
  // Fill texture with data pixels.
  for(let i = 0; i < QUEUE.length; i++)fillData(QUEUE[i]);
  // Calculate DataHeight.
  DataHeight = Data.length / 15;
  // Tell webgl to use 4 bytes per value for the 32 bit floats.
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 4);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGB32F, 5, DataHeight, 0, Gl.RGB, Gl.FLOAT, new Float32Array(Data));
}

function randomTextureBuilder()
{
  RandomTexture = Gl.createTexture();
  Gl.bindTexture(Gl.TEXTURE_2D, RandomTexture);
  // Build random texture.
  // Fill texture with pseudo random pixels.
  let Random = [ 255, 255,   0,   0,   0, 255,   0, 255,   0,
                   0, 255, 255, 255,   0,   0,   0,   0,   0,
                 255,   0,   0,   0,   0,   0, 0, 255, 255,
                   0,   0,   0, 255, 255, 255, 255,   0, 255,
                   0, 255, 255, 255,   0,   0,   0,   0,   0,
                   0,   0,   0, 255, 255, 255, 255,   0, 255,
                 255, 255,   0,   0,   0, 255,   0, 255,   0,
                   0,   0,   0, 255, 255, 255, 255,   0, 255,
                 255, 255,   0,   0,   0, 255,   0, 255,   0,
                   0, 255, 255,  255, 255, 255,  0,   0,   0,
                   0,   0,   0, 255,   0,   0, 255,   0, 255,
                 255, 255,   0,   0,   0, 255,   0, 255,   0,
                   0, 255, 255, 255,   0,   0,   0,   0,   0,
                   0,   0, 255,   0, 255,   0, 255, 255,   0,
                   0,   0,   0, 255, 255, 255, 255,   0, 255,
                 255, 255,   0,   0,   0, 255,   0, 255,   0,
                   0,   0,   0, 255,   0,   0, 255,   0, 255,
                   0, 255, 255,  255, 255, 255,  0,   0,   0,
                 255,   0,   0,   0,   0,   0,   0, 255, 255,
                   0,   0,   0, 255, 255, 255, 255,   0, 255,
                   0, 255, 255, 255,   0,   0,   0,   0,   0,
                   0,   0,   0, 255, 255, 255, 255,   0, 255,
                   0, 255, 255, 255,   0,   0,   0,   0,   0,
                   0,   0,   0, 255, 255, 255, 255,   0, 255,
                   0, 255, 255, 255,   0,   0,   0,   0,   0,
                 255, 255,   0,   0,   0, 255,   0, 255,   0,
                   0,   0,   0, 255, 255, 255, 255,   0, 255 ];
  // Tell webgl to use 4 bytes per value for the 32 bit floats.
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.LINEAR_MIPMAP_LINEAR);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.LINEAR);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGB8, 9, 9, 0, Gl.RGB, Gl.UNSIGNED_BYTE, new Uint8Array(Random));
  Gl.generateMipmap(Gl.TEXTURE_2D);
}

function normalTextureBuilder(item)
{
  NormalTexture = Gl.createTexture();
  Gl.bindTexture(Gl.TEXTURE_2D, NormalTexture);
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.R8, item.normalTextureWidth, item.normalTextureHeight, 0, Gl.RED, Gl.UNSIGNED_BYTE, new Uint8Array(item.normalTexture));
  //Gl.generateMipmap(Gl.TEXTURE_2D);
}

function textureBuilder(item)
{
  Texture = Gl.createTexture();
  Gl.bindTexture(Gl.TEXTURE_2D, Texture);
  Gl.pixelStorei(Gl.UNPACK_ALIGNMENT, 1);
  // Set data texture details and tell webgl, that no mip maps are required.
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MIN_FILTER, Gl.NEAREST);
  Gl.texParameteri(Gl.TEXTURE_2D, Gl.TEXTURE_MAG_FILTER, Gl.NEAREST);
  Gl.texImage2D(Gl.TEXTURE_2D, 0, Gl.RGB8, item.textureWidth, item.textureHeight, 0, Gl.RGB, Gl.UNSIGNED_BYTE, new Uint8Array(item.texture));
  Gl.generateMipmap(Gl.TEXTURE_2D);
}

// Build simple AABB tree (Axis aligned bounding box).
async function fillData(item)
{
  let b = item.bounding;
  if(Array.isArray(item))
  {
    // Save position of len variable in array.
    let len_pos = Data.length;
    // Begin bounding volume array.
    Data.push(b[0],b[1],b[2],b[3],b[4],b[5],0,0,0,0,0,0,0,0,0);
    // Iterate over all sub elements.
    item.forEach((item, i) => {
      // Push sub elements in QUEUE.
      fillData(item);
    });
    let len = Data.length - len_pos;
    // Set now calculated vertices length of bounding box
    // to skip if ray doesn't intersect with it.
    Data[len_pos] = len;
  }
  else
  {
    // Create extra bounding volume for each object.
    let v = item.vertices;
    let c = item.colors;
    let n = item.normals;
    let len = item.arrayLength;
    // Declare bounding volume of object.
    Data.push(b[0],b[1],b[2],b[3],b[4],b[5],len/3,0,0,0,0,0,0,0,0);
    for(let i = 0; i < len * 3; i += 9){
      // a, b, c, color, normal
      Data.push(v[i],v[i+1],v[i+2],v[i+3],v[i+4],v[i+5],v[i+6],v[i+7],v[i+8],c[i/9*4],c[i/9*4+1],c[i/9*4+2],n[i],n[i+1],n[i+2]);
    }
  }
}

setTimeout(function(){
  let surface = [[],[],[],[],[]];
  for (let i = 0; i < 25; i++)
  {
    let plane = cuboid(-10 + 4*(i%5), -1, -10 + 4*Math.floor(i / 5));
    plane.width = 4;
    plane.height = 0.1;
    plane.depth = 4;
    plane = plane(plane);
    surface[i%5].push(plane);
  }

  surface.bounding = [-10, 10, -1, -0.9, -10, 10];
  surface[0].bounding = [-10 , -6, -1, 0.9, -10, 10];
  surface[1].bounding = [-6 , -2, -1, 0.9, -10, 10];
  surface[2].bounding = [-2 , 2, -1, 0.9, -10, 10];
  surface[3].bounding = [2 , 6, -1, 0.9, -10, 10];
  surface[4].bounding = [6 , 10, -1, 0.9, -10, 10];
  QUEUE.push(surface);

  let room = [];
  let rect0 = cuboid(-1.5, -1, 1.5);
  rect0.width = 3;
  rect0.height = 3;
  rect0.depth = 1;
  rect0 = rect0(rect0);
  room.push(rect0);
  let rect1 = cuboid(-1.5, -1, -2);
  rect1.width = 3;
  rect1.height = 3;
  rect1.depth = 1;
  rect1 = rect1(rect1);
  room.push(rect1);
  let rect2 = cuboid(0.5, -1, -1);
  rect2.width = 1;
  rect2.height = 3;
  rect2.depth = 1;
  rect2 = rect2(rect2);
  room.push(rect2);
  let rect3 = cuboid(-1.5, -1, - 1);
  rect3.width = 1;
  rect3.height = 3;
  rect3.depth = 1;
  rect3 = rect3(rect3);
  room.push(rect3);
  room.bounding = [-1.5, -1, -2, 3, 2, 2.5];
  QUEUE.push(room);

  let re = cuboid(5.5, 1.5, 5.5);
  re.width = 1;
  re.height = 1;
  re.depth = 1;
  re = re(re);
  QUEUE.push(re);

  worldTextureBuilder();

  var c=[{v:255,n:0.3},{v:255,n:0.3},{v:255,n:0.3}];
    setInterval(function(){
      c.forEach((e,i)=>{
        if(e.v+e.n>255||e.v+e.n<0)
        {
          e.n=((Math.random()**2+1.1)*-20*e.n/Math.abs(e.n))/10;
        }
        e.v+=e.n*0.7;
      });
      let color =[];
      let co = [c[0].v/255, c[1].v/255, c[2].v/255, 1];
      for(let i = 0; i < 36; i++) color.push(co);
      QUEUE[1][0].colors = color.flat();
      let [x, y, z] = [QUEUE[1][0].x, QUEUE[1][0].y, QUEUE[1][0].z];
      let [x2, y2, z2] = [x + 1 + c[0].v/32, y + QUEUE[1][0].height, z + QUEUE[1][0].depth];
      // Set vertices.
      QUEUE[1][0].vertices = [x,y,z,x2,y,z,x,y2,z,x,y2,z,x2,y,z,x2,y2,z,x2,y,z,x2,y,z2,x2,y2,z,x2,y,z2,x2,y2,z2,x2,y2,z,x,y2,z,x2,y2,z,x,y2,z2,x2,y2,z,x2,y2,z2,x,y2,z2,x,y,z2,x,y2,z2,x2,y,z2,x,y2,z2,x2,y2,z2,x2,y,z2,x,y,z,x,y2,z,x,y,z2,x,y,z2,x,y2,z,x,y2,z2,x2,y,z,x,y,z,x,y,z2,x2,y,z,x,y,z2,x2,y,z2];
      QUEUE[1][0].bounding = [x, x2, y, y2, z, z2];
    },(100/6));
},1000);
