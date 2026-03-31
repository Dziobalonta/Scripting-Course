import { world, system } from "@minecraft/server";

const stone = "minecraft:stone";
const cobble = "minecraft:cobblestone";
const planks = "minecraft:oak_planks";
const fence = "minecraft:oak_fence";
const bars = "minecraft:iron_bars"

const water = "minecraft:water";
const air = "minecraft:air";

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

    const castle_width = 25;
    const castle_length = 20;
    const castle_hight = 7;

    const moat_width = 5;

    const bridge_width = 5;
    const bridge_center = Math.floor(castle_length / 2);
    const building_starting_point_x = bridge_center - Math.floor(bridge_width / 2);

    BuildFloor(dimension, player_x, player_y, player_z, castle_length, castle_width);
    BuildWalls(dimension, player_x, player_y, player_z, castle_length, castle_width, castle_hight);
    BuildCeiling(dimension, player_x, player_y, player_z, castle_length, castle_width, castle_hight);
    BuildMoat(dimension, player_x, player_y, player_z, castle_length, castle_width, moat_width);
    BuildBridge(dimension, player_x, player_y, player_z,building_starting_point_x, bridge_width, moat_width);
    BuildGate(dimension, player_x, player_y, player_z, building_starting_point_x, bridge_width);
    BuildTowers(dimension, player_x, player_y, player_z, castle_length, castle_width, castle_hight);
    BuildWindows(dimension, player_x, player_y, player_z, castle_length, castle_width);
    
}

function BuildFloor(dimension, px, py, pz, length, width) {
    for(let x = 0; x < length; x++) {
        for (let z = 0; z < width; z++) {
            dimension.getBlock({
                        x: px + x,
                        y: py - 1,
                        z: pz + z 
                    
            })?.setType(stone);
        }
    }
}

function BuildWalls(dimension, px, py, pz, length, width, height) {
    for (let y = 0; y <= height; y++) {
        for(let x = 0; x <= length; x++) {
            for (let z = 0; z <= width; z++) {

                dimension.getBlock({
                                x: px,
                                y: py + y,
                                z: pz + z
                })?.setType(cobble);

                dimension.getBlock({
                                x: px + length,
                                y: py + y,
                                z: pz + z
                })?.setType(cobble);
            }

            dimension.getBlock({
                            x: px + x,
                            y: py + y,
                            z: pz 
            })?.setType(cobble);

            dimension.getBlock({
                            x: px + x,
                            y: py + y,
                            z: pz + width
            })?.setType(cobble);
        }
    }
}

function BuildCeiling(dimension, px, py, pz, length, width, height) {
    const cobble = "minecraft:cobblestone";
    for(let x = 0; x <= length; x++) {
        for (let z = 0; z <= width; z++) {
            dimension.getBlock({
                            x: px + x,
                            y: py + height,
                            z: pz + z
            })?.setType(cobble);
        }
    }
}

function BuildMoat(dimension, px, py, pz, length, width, moat_width) {
    const moat_depth = 3;

    for (let x = -moat_width; x <= length + moat_width; x++) {
        for (let z = -moat_width; z <= width + moat_width; z++) {
            if (x < 0 || x > length || z < 0 || z > width) {
                dimension.getBlock({ 
                                x: px + x,
                                y: py,
                                z: pz + z
                })?.setType(air);

                for (let d = 0; d < moat_depth; d++) {
                    dimension.getBlock({
                                    x: px + x,
                                    y: py - d - 1,
                                    z: pz + z
                    })?.setType(water);
                }   
            } 
        }  
    }
}

function BuildBridge(dimension, px, py, pz, start_x, bridge_width, moat_width) {
    for (let z = -moat_width; z < 0; z++) {
        for (let w = 0; w < bridge_width; w++) {
            dimension.getBlock({
                            x: px + start_x + w,
                            y: py - 1,
                            z: pz + z
            })?.setType(planks);
        }
    } 
}

function BuildGate(dimension, px, py, pz, start_x, bridge_width) {
    const gate_height = 5;

    for (let y = 0; y < gate_height; y++) {
        for (let x = 0; x < bridge_width; x++) {

            let block = dimension.getBlock({
                                        x: px + start_x + x,
                                        y: py + y,
                                        z: pz
            });
            block?.setType(air);

            if (y === gate_height - 1) {
                if (x === 0 || x === bridge_width - 1) {
                    block?.setType(cobble); 
                } else {
                    block?.setType(fence);             
                }
            }
            if (y === gate_height - 2) {
                block?.setType(fence); 
            }
        }
    }
}

function BuildTowers(dimension, px, py, pz, length, width, height) {
    const tower_radius = 2; 
    const tower_height = Math.ceil(height / 2); 

    const corners = [
        { x: 0, z: 0 },
        { x: length, z: 0 },
        { x: 0, z: width },
        { x: length, z: width }
    ];

    for (const corner of corners) {
        for (let y = height - 1; y <= tower_height + height; y++) {
            for (let x = -tower_radius; x <= tower_radius; x++) {
                for (let z = -tower_radius; z <= tower_radius; z++) {

                    if (Math.abs(x) === tower_radius || Math.abs(z) === tower_radius) {
                        
                        dimension.getBlock({ x:
                                            px + corner.x + x,
                                            y: py + y,
                                            z: pz + corner.z + z
                        })?.setType(cobble);
                    }
                    // Add floor
                    if (y === height - 1) {
                        dimension.getBlock({
                                        x: px + corner.x + x,
                                        y: py + y,
                                        z: pz + corner.z + z
                        })?.setType(cobble);
                    }
                }
            }
        }
    }
}

function BuildWindows(dimension, px, py, pz, length, width) {
    const w_width = 2; 
    const w_height = 3; 
    const spacing = 2; 
    const min_margin = 2; 

    const wall_width = width + 1; 
    const space = wall_width - (2 * min_margin);
    const window_count = Math.floor((space + spacing) / (w_width + spacing));
    const used_space = (window_count * w_width) + ((window_count - 1) * spacing);
    
    const centered_margin = Math.floor((wall_width - used_space) / 2);

    for (let z = centered_margin; z < centered_margin + used_space; z += w_width + spacing) {
        for (let y = 0; y < w_height; y++) {
            for (let w = 0; w < w_width; w++) {

                // Left
                dimension.getBlock({
                                x: px,
                                y: py + 2 + y,
                                z: pz + z + w
                })?.setType(bars);

                // Right
                dimension.getBlock({
                                x: px + length,
                                y: py + 2 + y,
                                z: pz + z + w
                })?.setType(bars);
            }
        }
    }
}
