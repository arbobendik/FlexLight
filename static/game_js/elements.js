"use strict";

// Element facories that could be used for Text / Images / Objects, etc
const cuboid = new Element(function(item){
  // Test if all necessary arguments are provided.
  reqElem(item, {x: item.x}, {y: item.y}, {z: item.z});
  // Set default value for each optional argument if it isn't set.
  optElem(item, {height: 1, width: 1, depth: 1, textureNums: new Array(72).fill(-1), colors: new Array(144).fill(1)})
  // Set normals.
  item.normals = [0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0];
  // Predefine properties of vertices.
  let [x, y, z, x2, y2, z2] = [item.x, item.y, item.z, item.x + item.width, item.y + item.height, item.z + item.depth];
  // Set vertices.
  item.vertices = [x,y,z,x2,y,z,x,y2,z,x,y2,z,x2,y,z,x2,y2,z,x2,y,z,x2,y,z2,x2,y2,z,x2,y,z2,x2,y2,z2,x2,y2,z,x,y2,z,x2,y2,z,x,y2,z2,x2,y2,z,x2,y2,z2,x,y2,z2,x,y,z2,x,y2,z2,x2,y,z2,x,y2,z2,x2,y2,z2,x2,y,z2,x,y,z,x,y2,z,x,y,z2,x,y,z2,x,y2,z,x,y2,z2,x2,y,z,x,y,z,x,y,z2,x2,y,z,x,y,z2,x2,y,z2];
  // Set UVs.
  item.uvs = [0,0,0,1,1,0,1,0,0,1,1,1,0,0,0,1,1,0,0,1,1,1,1,0,0,0,0,1,1,0,0,1,1,1,1,0,0,1,1,1,0,0,1,1,1,0,0,0,1,0,1,1,0,0,0,0,1,1,0,1,1,0,0,0,0,1,1,0,0,1,1,1];
  // Define maximum bounding volume of cuboid.
  item.bounding = [x, x2, y, y2, z, z2];
  // Set default arrayLength for this object.
  item.arrayLength = 36;
  // Return itself.
  return item;
});

const surface = (c0, c1, c2, c3, normal) => {return {
  // Set normals.
  normals: new Array(6).fill(normal).flat(),
  // Set vertices.
  vertices: [c0,c1,c2,c2,c3,c0].flat(),
  // Default color to white.
  colors: new Array(24).fill(1).flat(),
  // Set UVs.
  uvs: [0,0,0,1,1,1,1,1,1,0,0,0],
  // Set used textures.
  textureNums: [-1, -1],
  // Define maximum bounding volume of cuboid.
  bounding: [Math.min(c0[0],c1[0],c2[0],c3[0]),
             Math.max(c0[0],c1[0],c2[0],c3[0]),
             Math.min(c0[1],c1[1],c2[1],c3[1]),
             Math.max(c0[1],c1[1],c2[1],c3[1]),
             Math.min(c0[2],c1[2],c2[2],c3[2]),
             Math.max(c0[2],c1[2],c2[2],c3[2])],
  // Set default arrayLength for this object.
  arrayLength: 6
}};

function optElem(object, defaults){
  Object.entries(defaults)
  // Set default value for each unset optional value.
  .forEach(function(entry){
    // Test if value is unset.
    if(object[entry[0]] === undefined){
      object[entry[0]] = entry[1];
    }
  });
}

function reqElem(item)
{
  // Test if all required arguments are there.
  for (let i = 1; i < arguments.length; i++)
  {
		// Test if value is unset.
    if(Object.values(arguments[i])[0] === undefined)
    {
      // Delete item to prevent harm for the render queue.
      throw "missingRequiredArgumentError: " + "ELEMENT" +"item."+Object.entries(arguments[i])[0][0];
      item.delete();
    }
  }
}

function Element(foo)
{
  return (x, y, z) => Object.assign(foo.bind({}), {
		x: x,
		y: y,
		z: z
	});
}
