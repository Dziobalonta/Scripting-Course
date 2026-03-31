import { world, system } from "@minecraft/server";

world.afterEvents.playerSpawn.subscribe((event) => {
    
    if (event.initialSpawn === true) {
        
        const player = event.player;

        system.run(() => {
            world.sendMessage(`[Castle Script] Hello World, ${player.name}!
                Type !castle to run the script.`);
        });
    }
}); 

world.afterEvents.chatSend.subscribe((event) => {
    if (event.message === "!castle") {
        const player = event.sender;

        system.run(() => {
            BuildCastle(player);
            world.sendMessage(`[Castle Script] Starting build for ${player.name}...`);
        });
    }
});

function BuildCastle(player) {
    // could be normal World, Nether or End
    const dimension = player.dimension;

    const player_x = Math.floor(player.location.x) + 10 // castle spawns in front of the player 
    const player_y = Math.floor(player.location.y)
    const player_z = Math.floor(player.location.z)

    world.sendMessage(`Player stands at (${player_x}, ${player_y}, ${player_z})`)

    const castle_width = 10 
    const castle_length = 10
    const castle_hight = 5

    const cobble = "minecraft:cobblestone"
    const stone = "minecraft:stone"

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
    
}
