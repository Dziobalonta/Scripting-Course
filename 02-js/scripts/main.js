import { world, system } from "@minecraft/server";

world.afterEvents.playerSpawn.subscribe((event) => {
    
    if (event.initialSpawn === true) {
        
        const player = event.player;

        system.run(() => {
            world.sendMessage(`[Castle Script] Hello World, ${player.name}!`);
        });
    }
});