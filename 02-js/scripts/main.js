import { world, system, BlockPermutation } from "@minecraft/server";

const stone = "minecraft:stone";
const cobble = "minecraft:cobblestone";
const planks = "minecraft:oak_planks";
const fence = "minecraft:oak_fence";
const bars = "minecraft:iron_bars"
const stairs = "minecraft:oak_stairs"

const water = "minecraft:water";
const air = "minecraft:air";

world.afterEvents.playerSpawn.subscribe((event) => {
    
    if (event.initialSpawn === true) {
        
        const player = event.player;

        system.run(() => {
            world.sendMessage(`[Castle Script] Hello World, ${player.name}!`);
            world.sendMessage(`Type !castle [width] [length] [floors] to run the script.`)
        });
    }
}); 

world.afterEvents.chatSend.subscribe((event) => {
    const parts = event.message.trim().split(/\s+/);

    if (parts[0] === "!castle") {
        const player = event.sender;

        const width = parts[1] ? parseInt(parts[1]) : 25;
        const length = parts[2] ? parseInt(parts[2]) : 20;
        const floors = parts[3] ? parseInt(parts[3]) : 2;

        // Validate
        if (isNaN(width) || isNaN(length) || isNaN(floors)) {
            world.sendMessage(`[Castle Script] Invalid args. Usage: !castle [width] [length] [floors]`);
            return;
        }

        system.run(() => {
            world.sendMessage(`[Castle Script] Starting build for ${player.name}...`);

            BuildCastle(player, width, length, floors);

        });
    }
});


function BuildCastle(player, castle_width = 25, castle_length = 20, floors = 2) {
    const dimension = player.dimension;

    const player_x = Math.floor(player.location.x) + 10;
    const player_y = Math.floor(player.location.y);
    const player_z = Math.floor(player.location.z);

    const castle_hight = 7;
    const moat_width = 5;
    const bridge_width = 5;
    const tower_radius = 2;

    const bridge_center = Math.floor(castle_length / 2);
    const building_starting_point_x = bridge_center - Math.floor(bridge_width / 2);

    BuildFloor(dimension, player_x, player_y, player_z, castle_length, castle_width);
    BuildWalls(dimension, player_x, player_y, player_z, castle_length, castle_width, castle_hight);

    for (let f = 1; f <= floors; f++) {
        const isTop = f === floors;
        BuildNextFloor(dimension, player_x, player_y + (castle_hight * f), player_z, castle_length, castle_width, castle_hight, isTop, tower_radius);
    }

    BuildCeiling(dimension, player_x, player_y, player_z, castle_length, castle_width, castle_hight * (floors + 1));
    BuildMoat(dimension, player_x, player_y, player_z, castle_length, castle_width, moat_width);
    BuildBridge(dimension, player_x, player_y, player_z, building_starting_point_x, bridge_width, moat_width);
    BuildGate(dimension, player_x, player_y, player_z, building_starting_point_x, bridge_width);
    BuildTowers(dimension, player_x, player_y, player_z, castle_length, castle_width, castle_hight * (floors + 1), tower_radius);
    BuildWindows(dimension, player_x, player_y, player_z, castle_length, castle_width, 0, tower_radius, false);
    BuildStairs(dimension, player_x, player_y, player_z, castle_length, castle_width, castle_hight, floors + 1);
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

function BuildTowers(dimension, px, py, pz, length, width, height, tower_radius) {
    const tower_height = Math.ceil(height / 2);
    const overlap = Math.ceil(height / 4);

    const corners = [
        { x: 0, z: 0 },
        { x: length, z: 0 },
        { x: 0, z: width },
        { x: length, z: width }
    ];

    for (const corner of corners) {
        for (let y = height - overlap; y <= tower_height + height; y++) {
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
                    if (y === height - overlap) {
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

function BuildWindows(dimension, px, py, pz, length, width, height, tower_radius, isTop) {
    const w_width = 2; 
    const w_height = 3; 
    const spacing = 2; 
    const min_margin = 2; 

    const wall_width = width + 1; 
    const space = wall_width - (2 * min_margin);
    const window_count = Math.floor((space + spacing) / (w_width + spacing));
    const used_space = (window_count * w_width) + ((window_count - 1) * spacing);
    
    const centered_margin = Math.floor((wall_width - used_space) / 2);
    const padding = tower_radius + 1;

    for (let z = centered_margin; z < centered_margin + used_space; z += w_width + spacing) {

        // Check if overlaps the tower + padding
        if (isTop) {
            const slotStart = z;
            const slotEnd = z + w_width - 1;
            const nearStart = slotStart <= padding;
            const nearEnd = slotEnd >= width - padding;
            if (nearStart || nearEnd) continue; // skip 
        }

        for (let w = 0; w < w_width; w++) {
            for (let y = 0; y < w_height; y++) {
                dimension.getBlock({
                    x: px,
                    y: py + height + 2 + y,
                    z: pz + z + w
                })?.setType(bars);

                dimension.getBlock({
                    x: px + length,
                    y: py + height + 2 + y,
                    z: pz + z + w
                })?.setType(bars);
            }
        }
    }
}

function BuildNextFloor(dimension, px, py, pz, length, width, height, isTop, tower_radius) {

    for (let x = 0; x <= length; x++) {
        for (let z = 0; z <= width; z++) {

            const isEdge = x === 0 || x === length || z === 0 || z === width;

            if (isEdge) {
                dimension.getBlock({
                            x: px + x,
                            y: py,
                            z: pz + z
                })?.setType(cobble);
            } else {
                dimension.getBlock({
                                x: px + x,
                                y: py,
                                z: pz + z
                })?.setType(planks);
            }
        }

    }

    for (let y = 0; y <= height; y++) {
        for (let x = 0; x <= length; x++) {
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
    }
    if (isTop) {
       BuildWindows(dimension, px, py, pz, length, width, 0, tower_radius, true); 
    } else {
        BuildWindows(dimension, px, py, pz, length, width, 0, tower_radius, false); 
    }
    
}

function BuildStairs(dimension, px, py, pz, length, width, height, floors) {
    const stair_width = 2;       
    const stair_offset = 2;

    const center_x = Math.floor(length / 2);
    const center_z = Math.floor(width / 2);

    let floor_y = 0;
    let start_z = center_z;

    for (let floor = 0; floor < floors; floor++) {
        
        let height_adj = height;
        if (floor === 0) {
           height_adj = height + 1;
        }

        // Flip side and direction every floor
        const side   = floor % 2 === 0 ? -stair_offset : stair_offset;
        const dir    = floor % 2 === 0 ? 1 : -1;
        const facing = floor % 2 === 0 ? 2 : 3;
        const adj = floor % 2 === 0 ? -2 : 2;

        for (let step = 0; step < height_adj; step++) {

            const stair_z = pz + start_z + (dir * step);
            const stair_y = py + floor_y + step;

            for (let w = 0; w <= stair_width + 1; w++) {
                const stair_x = px + center_x + side + w;

                // Clear 4 blocks of headroom
                dimension.getBlock({ x: stair_x, y: stair_y + 1, z: stair_z })?.setType(air);
                dimension.getBlock({ x: stair_x, y: stair_y + 2, z: stair_z })?.setType(air);
                dimension.getBlock({ x: stair_x, y: stair_y + 3, z: stair_z })?.setType(air);
                dimension.getBlock({ x: stair_x, y: stair_y + 4, z: stair_z })?.setType(air);

                // Place stair facing gate direction
                dimension.getBlock({ x: stair_x, y: stair_y, z: stair_z })
                    ?.setPermutation(BlockPermutation.resolve(stairs, {
                        weirdo_direction: facing,
                        upside_down_bit: false
                    }));
            }
        }

        start_z += dir * height_adj + adj;
        floor_y += height_adj;
    }
}