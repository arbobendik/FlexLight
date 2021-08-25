"use strict";

const normals_test = {
  normals: [200,200,200,200,200,
            200,100,100,100,200,
            200,100, 30,100,200,
            200,100,100,100,200,
            200,200,200,200,200],
  width: 5,
  height: 5,
};

// Init surface element.
let test_surface = [[-10, 10, -1, -0.9, -10, 10], [],[],[],[],[]];
// Create 25 surface elements automatically.
for (let i = 0; i < 25; i++)
{
  let plane = cuboid(-10 + 4*(i%5), -1, -10 + 4*Math.floor(i / 5));
  plane.width = 4;
  plane.height = 0.1;
  plane.depth = 4;
  plane = plane(plane);
  plane.textureNums = new Array(36).fill([-1,0]).flat();
  // Push bounding volume.
  if (i < 5) test_surface[i%5 + 1].push([-10 + 4*(i%5), -10 + 4*(i%5 + 1), -1, -0.9, -10, 10]);
  // Push vertices.
  test_surface[i%5 + 1].push(plane);
}
// Generate a few cuboids on surface.
let r = [];
r[0] = cuboid(-1.5, -1, 1.5);
r[0].width = 6;
r[0].height = 3;
r[1] = cuboid(-1.5, -1, -2);
r[1].width = 3;
r[1].height = 3;
r[2] = cuboid(0.5, -1, -1);
r[2].height = 3;
r[3] = cuboid(-1.5, -1, - 1);
r[3].height = 3;
// Activate cuboids.
r.forEach((item, i) => {
  item = item(item);
  item.textureNums = new Array(36).fill([0,-1]).flat();
  //item.colors = new Array(36).fill([Math.random(),Math.random(),Math.random(),1]).flat();
});
// And a floating dice.
let dice = cuboid(5.5, 1.5, 5.5);
dice = dice(dice);
dice.textureNums = new Array(36).fill([0,-1]).flat();
// Pack objects on surface together in some bounding structure.
let objects = [
  [-1.5, 6.5, -1, 2.5, -2, 6.5],
  [[-1.5, 4.5, -1, 2, -2, 2.5], r[0], r[1], r[2], r[3]],
  dice
];

// let plane = surface([-20,-10,-20],[20,-10,-20],[20,-10,20],[-20,-10,20],[0,1,0]);
// Append surface and objects to QUEUE.
QUEUE.push(test_surface, objects);

NORMAL_TEXTURE.push(normals_test);
/*
let target = QUEUE[1][2];
var c=[{v:0,n:3},{v:0,n:3},{v:0,n:3}];
setInterval(function(){
  c.forEach((e,i)=>{
    if(e.v+e.n*0.001>=1||e.v+e.n*0.001<=0)
    {
      e.n=(Math.random()**2+1.1)*-20*e.n/Math.abs(e.n);
    }
    e.v+=e.n * 0.001;
  });
  let colors = [];
  for(let i = 0; i < target.arrayLength; i++) colors.push([c[0].v,c[1].v,c[2].v,1]);
  target.colors=colors.flat();
},(100/6));
*/
