"use strict";

// Element facories that could be used for Text / Images / Objects, etc
const cuboid = new Element(function(item){
  // Test if all necessary arguments are provided.
  reqArgs(item, {x: item.x}, {y: item.y}, {z: item.z});
  // Set default value for each optional argument if it isn't set.
  optArgs(item, {height: 1, width: 1, depth: 1, color: [1, 1, 1, 1]})
  // Set normals.
  item.normals = [0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0];
  // Predefine properties of vertices.
  let [x, y, z] = [item.x, item.y, item.z];
  let [x2, y2, z2] = [x + item.width, y + item.height, z + item.depth];
  // Set vertices.
  item.vertices = [x,y,z,x2,y,z,x,y2,z,x,y2,z,x2,y,z,x2,y2,z,x2,y,z,x2,y,z2,x2,y2,z,x2,y,z2,x2,y2,z2,x2,y2,z,x,y2,z,x2,y2,z,x,y2,z2,x2,y2,z,x2,y2,z2,x,y2,z2,x,y,z2,x,y2,z2,x2,y,z2,x,y2,z2,x2,y2,z2,x2,y,z2,x,y,z,x,y2,z,x,y,z2,x,y,z2,x,y2,z,x,y2,z2,x2,y,z,x,y,z,x,y,z2,x2,y,z,x,y,z2,x2,y,z2];
  // Define maximum bounding volume of cuboid.
  item.bounding = [x, x2, y, y2, z, z2];
  // Set color.
  let c = [0, 0, 0].map((item) => Math.random()).concat([1]);
  item.colors = [];
  for(let i = 0; i < 36; i++) item.colors.push(c);
  item.colors = item.colors.flat();
  // Set default arrayLength for this object.
  item.arrayLength = 36;
  // Return itself.
  return item;
});

function optArgs(object, defaults){
  Object.entries(defaults)
  // Set default value for each unset optional value.
  .forEach(function(entry){
    // Test if value is unset.
    if(object[entry[0]] === undefined){
      object[entry[0]] = entry[1];
    }
  });
}

function reqArgs(item)
{
  // Test if all required arguments are there.
  for (let i = 1; i < arguments.length; i++)
  {
		// Test if value is unset.
    if(Object.values(arguments[i])[0] === undefined)
    {
      // Delete item to prevent harm for the render queue.
      throw "missingRequiredArgumentError: " + "item."+Object.entries(arguments[i])[0][0];
      item.delete();
    }
  }
}
