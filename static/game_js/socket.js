"use strict";

function initSocket() {
  // Initialize Socket.
  WS = new WebSocket("ws://" + document.location.host + "/ws");
  WS.event = [];

  WS.onopen = () => {
    // Send keys to server if they're available in local storage.
    if (localStorage.getItem("keys") !== null)
    {
      WS.send(JSON.stringify({
        event: "init",
        generate_new: false,
        name: localStorage.getItem("name"),
        keys: localStorage.getItem("keys")
      }));
    }
    else
    {
      console.log("generate new session keys");
      WS.send(JSON.stringify({
        event: "init",
        generate_new: true
      }));
    }
    // Allow other functions to send traffic over WebSocket
    WS.open = true;
  };

  WS.onmessage = (raw_package) => {
    // Parse package to JSON.
    let pkg = JSON.parse(raw_package.data)
    // Call event function depending on event key.
    WS.event[pkg.event](pkg);
  }

  WS.onclose = function(e) {
      console.log('Socket disconnected', e.reason);
      WS.open = false;
      //setTimeout(initSocket, 1000);
  };

  WS.event["init"] = async (pkg) => {
    // Save keys to global key variable.
    console.log(pkg);
    KEYS = pkg.keys;
    // TO:DO; localStorage.setItem('keys', pkg);
    initMovement(pkg.x, pkg.y);
    return false;
  };

  WS.event["add_player"] = async (pkg) => {
    console.log(pkg);
    return false;
  };

  WS.event["remove_player"] = async (pkg) => {
    console.log("remove: "+pkg.player);
    return false;
  };

  WS.event["sync_game"] = async (pkg) => {
    pkg.players.forEach((elem, i) => {
      // Don't update position if player is moving too prevent stuttering.
      /*if(elem.dx === 0 && elem.dy ===0 && elem.last_vector >= 0.5)
      {
        console.log(Players[i].transform.y - ((window.performance.now() - Players[i].meta.last_update) * (- Players[i].meta.dy)) / (100/6));
        Players[i].transform.x = - elem.x;
        Players[i].transform.y = - elem.y;
      }
      // Sync vector if vector is not too fast.
      let notTooFast = (x) => Math.abs(x) <= Speed;
      if (notTooFast(elem.dx) && notTooFast(elem.dy)) Players[i].meta = elem;
      Players[i].meta.last_update = window.performance.now();*/
    });
  };

  WS.event["player_vector_change"] = async (pkg) => {
    // If player is new or changed append it to Players.
    /*Players.forEach((item, i) => {
      if (item.meta.player === pkg.player)
      {
        // Sync vector if vector is not too fast.
        let notTooFast = (x) => Math.abs(x) <= Speed;
        if (notTooFast(pkg.dx) && notTooFast(pkg.dy)) Players[i].meta = pkg;
        Players[i].meta.last_update = window.performance.now();
      }
    });
    return false;*/
  };
}
