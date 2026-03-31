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

    const player_x = Math.floor(player.location.x)
    const player_y = Math.floor(player.location.y)
    const player_z = Math.floor(player.location.z)

    world.sendMessage(`Player stands at (${player_x}, ${player_y}, ${player_z})`)
}