"use strict";

async function initMovement()
{
  // Listen for keyboard input.
  window.addEventListener("keydown", function(event){
    if(!KeysPressed.includes(event.key.toLowerCase()))
    {
      KeysPressed.push(event.key.toLowerCase());
      evalKeys();
    }
  });
  // Remove keys from list if they are not longer pressed.
  window.addEventListener("keyup", function(event){
    KeysPressed.forEach((item, i) => {
      if (item === event.key.toLowerCase())
      {
        KeysPressed.splice(i, 1);
        evalKeys();
      }
    });
  });

  // Change perspective on mouse movement and lock pointer to screen.
  document.addEventListener('pointerlockchange', function(){
    PointerLocked = !PointerLocked;
    KeysPressed = [];
  });

  document.body.addEventListener("click", function (event) {
      event.target.requestPointerLock();
  });

  document.addEventListener("pointermove", function (event) {
      if (PointerLocked)
      {
        Fx -= Mouse_x * event.movementX;
        if (Math.abs(Fy + Mouse_y * event.movementY) < Math.PI / 2) Fy += Mouse_y * event.movementY;
      }
  });

  // Update client side movement with 60Hz.
  setInterval(async function(){
    Players.forEach((item, i) => {
      item.transform.x -= item.meta.dx;
      item.transform.y -= item.meta.dy;
    });
    X += DeltaX * Math.cos(Fx) + DeltaZ * Math.sin(Fx);
    Y += DeltaY;
    Z += DeltaZ * Math.cos(Fx) - DeltaX * Math.sin(Fx);
  }, 100/6);
  // Send actual possition to server with 2Hz. Vector motion is reported event based.
  // This function is used to measure the client-server-client latency in ms either.
  setInterval(async function(){
    // Test if socket is still open.
    if (WS.open) {
      WS.send(JSON.stringify({event: "sync_game", keys: KEYS, x: X, y: Y, dx: DeltaX, dy: DeltaY}));
    }
  }, 500);
}

async function evalKeys()
{
  if (PointerLocked)
  {
    let [x, y, z] = [0, 0, 0];
    KeyMap.forEach((item, i) => {
      if (KeysPressed.includes(item[0]))
      {
        x += item[1] * Speed;
        y += item[2] * Speed;
        z += item[3] * Speed;
      }
    });
    if (x !== DeltaX || y !== DeltaY || z !== DeltaZ)
    {
      DeltaX = x;
      DeltaY = y;
      DeltaZ = z;
      // Test if socket is still open.
      if (WS.open) {
        WS.send(JSON.stringify({event: "vector", keys: KEYS, dx: DeltaX, dy: DeltaY, x: X, y: Y}));
      }
    }
  }
}
