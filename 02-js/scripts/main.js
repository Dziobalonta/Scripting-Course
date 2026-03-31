import { world, system } from "@minecraft/server";

world.afterEvents.playerSpawn.subscribe((event) => {
    
    if (event.initialSpawn === true) {
        
        const player = event.player;

        system.run(() => {
            world.sendMessage(`[Castle Script] Hello World, ${player.name}!`);
            world.sendMessage(`Type !castle to run the script.`)
        });
    }
}); 

world.afterEvents.chatSend.subscribe((event) => {
    if (event.message === "!castle") {
        const player = event.sender;

        system.run(() => {
            world.sendMessage(`[Castle Script] Starting build for ${player.name}...`);

            BuildCastle(player);

        });
    }
});

function BuildCastle(player) {
    // could be normal World, Nether or End
    const dimension = player.dimension;

    const player_x = Math.floor(player.location.x) + 10; // castle spawns in front of the player 
    const player_y = Math.floor(player.location.y);
    const player_z = Math.floor(player.location.z);

    world.sendMessage(`Player stands at (${player_x}, ${player_y}, ${player_z})`);

    const castle_width = 25;
    const castle_length = 20;
    const castle_hight = 7;

    const cobble = "minecraft:cobblestone";
    const stone = "minecraft:stone";

    // Floor
    for(let x = 0;  x < castle_length; x++) {
        for (let z = 0; z < castle_width; z++) {
            let floor_block = dimension.getBlock({
                                            x:player_x + x,
                                            y: player_y - 1,
                                            z: player_z + z});

            if (floor_block) floor_block.setType(stone);
            
        }
    }
    // Walls 
    for (let y = 0; y <= castle_hight; y++) {
            for(let x = 0;  x <= castle_length; x++) {
                for (let z = 0; z <= castle_width; z++) {
                    dimension.getBlock({
                                    x:player_x,
                                    y:player_y + y,
                                    z:player_z + z}
                    )?.setType(cobble);

                    dimension.getBlock({
                                    x:player_x + castle_length,
                                    y:player_y + y,
                                    z:player_z + z}
                    )?.setType(cobble);
            }
            dimension.getBlock({
                            x:player_x + x,
                            y:player_y + y,
                            z:player_z}
            )?.setType(cobble);

            dimension.getBlock({
                            x:player_x + x,
                            y:player_y + y,
                            z:player_z + castle_width}
            )?.setType(cobble);
        }
        
    }
    // Ceiling
    for(let x = 0;  x <= castle_length; x++) {
        for (let z = 0; z <= castle_width; z++) {
            let floor_block = dimension.getBlock({
                                            x:player_x + x,
                                            y: player_y + castle_hight,
                                            z: player_z + z});

            if (floor_block) floor_block.setType(cobble);
            
        }
    }
    // Moat
    const moat_width = 5;
    const moat_depth = 3;

    const water = "minecraft:water";
    const air = "minecraft:air";

    for (let x = -moat_width; x <= castle_length + moat_width; x++) {
        for (let z = -moat_width; z <= castle_width + moat_width; z++) {

            if (x < 0 || x > castle_length || z < 0 || z > castle_width) {
                
                // clear above the moat
                dimension.getBlock({
                    x: player_x + x,
                    y: player_y,
                    z: player_z + z
               })?.setType(air);

               for (let d = 0; d < moat_depth; d++) {
                    dimension.getBlock({
                        x: player_x + x,
                        y: player_y - d - 1,
                        z: player_z + z
                    })?.setType(water);
               }   
            } 
        }  
    }

    // Bridge
    const bridge_width = 5;
    const planks = "minecraft:oak_planks";
    const bridge_center = Math.floor(castle_length / 2);
    const building_starting_point_x = bridge_center - Math.floor(bridge_width / 2);

    for (let z = -moat_width; z < 0; z++) {
        
        for (let w = 0; w < bridge_width; w++) {
            dimension.getBlock({
                        x: player_x + building_starting_point_x + w,
                        y: player_y - 1,
                        z: player_z + z
            })?.setType(planks);
        }
        
    } 
    
    // Gate
    const gate_height = 5;
    const bars = "minecraft:iron_bars"

    for (let y = 0; y < gate_height; y++) {
        
        for (let x = 0; x < bridge_width; x++) {
            let block = dimension.getBlock({
                        x: player_x + building_starting_point_x + x,
                        y: player_y + y,
                        z: player_z
            })
            block.setType(air);

            if (y === gate_height - 1) {
                if (x === 0 || x === bridge_width - 1) {
                    block?.setType(cobble); 
                } else {
                    block?.setType(bars);             
                }
            }

            if (y === gate_height - 2) {
                    block?.setType(bars); 
            }

        }
        
    }

    // Towers
    const tower_radius = 2; 
    const tower_height = Math.ceil(castle_hight / 2); 

    const corners = [
        { x: 0, z: 0 },
        { x: castle_length, z: 0 },
        { x: 0, z: castle_width },
        { x: castle_length, z: castle_width }
    ];

    for (const corner of corners) {
        for (let y = castle_hight - 1; y <= tower_height + castle_hight; y++) {

            for (let x = -tower_radius; x <= tower_radius; x++) {
                for (let z = -tower_radius; z <= tower_radius; z++) {
                    

                    if (Math.abs(x) === tower_radius || Math.abs(z) === tower_radius) {
                        dimension.getBlock({
                            x: player_x + corner.x + x,
                            y: player_y + y,
                            z: player_z + corner.z + z
                        })?.setType(cobble);
                    }

                    if (y === castle_hight - 1) {
                        dimension.getBlock({
                            x: player_x + corner.x + x,
                            y: player_y + y,
                            z: player_z + corner.z + z
                        })?.setType(cobble);
                    }
                }
            }
        }
    }


    // Windows
    const w_width = 2; 
    const w_height = 3; 
    const w_spacing = 2; 
    const min_margin = 2; 

    const wall_width = castle_width + 1; 

    const space = wall_width - (2 * min_margin);
    const window_count = Math.floor((space + w_spacing) / (w_width + w_spacing));
    const used_space = (window_count * w_width) + ((window_count - 1) * w_spacing);
    
    const centered_margin = Math.floor((wall_width - used_space) / 2);

    for (let z = centered_margin; z < centered_margin + used_space; z += w_width + w_spacing) {
        for (let y = 0; y < w_height; y++) {
            for (let w = 0; w < w_width; w++) {
                // Lewa ściana
                dimension.getBlock({
                                x: player_x,
                                y: player_y + 2 + y,
                                z: player_z + z + w
                })?.setType(bars);
                // Prawa ściana
                dimension.getBlock({ 
                                x: player_x + castle_length,
                                y: player_y + 2 + y,
                                z: player_z + z + w
                })?.setType(bars);
            }
        }
    }
}
