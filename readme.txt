Installation instructions:
1. Download the GodotModLoader zip from https://github.com/GodotModding/godot-mod-loader/releases if you haven't already
2. Download the 'mods_unpacked' folder as a zip file
3. Create a folder called "mods" in your game directory (next to RAM.exe and RAM.pck) and place the mod zip in the mods folder

EM1 CPU Changes:
- Health increased from 3000 to 5000 and CPU will perform 4 "super moves" instead of 2
- Ram attack has increased speed and acceleration, and no longer provides a damage multiplier
- Explosion waves travel twice as quickly
- Laser attack turns more quickly, extends further, and is done twice 
- CPU can no longer be moved when standing in the middle of the arena for certain moves
- Homing pound attack can no longer be interrupted
- Summons 4/6 enemies at once instead of 2
- NEW MOVE: CPU sends an explosion wave directly towards the player
- NEW SUPER MOVE: CPU moves to the center, then creates 3 waves of 6 telegraphed shockwaves

EM2 Heap Changes:
- Health increased from 3500 to 5000 
- Shield now covers the Heap from all directions
- Shield does not go down until all orbs are detached
- Heap is invincible untli shield goes down
- All laser attacks deal increased damage
- All bullet attacks fire more bullets

EM2 Heap Orb Changes (tethered):
- Attack cooldown is halved
- When an orb's shield is broken, it will regenerate its shield partially after 2 seconds if it is still tethered
- Single Orb: decreased telegraph on laser snipe
- Double Orb: decreased telegraph on laser wall
- Double Orb: increased laser swing speed
- Triple Orb: laser cage moves more quickly
- Triple Orb: laser disc moves more quickly and slightly homes in on the player
- NEW MOVE: one orb activates its laser and swipes at the player
- NEW MOVE: two orbs fire a laser at the player in a cross/X pattern
- NEW MOVE: two orbs move to either side of the arena and fire spiraling bullets
- NEW MOVE: three orbs rapidly fire lasers at the player
- NEW MOVE: two orbs cage the player with bullets before the third orb fires a laser

EM2 Heap Orb Changes (untethered):
- Orbs cannot be killed
- Orb moves significantly faster during blast attack
- Orb tracks the player better during persistent laser attack
- NEW MOVE: orb releases a shockwave of bullets

EM3 GOLEM Changes:
- GOLEM Boss regenerates Local Energy at a rate of 1 swap every 30 seconds
- Post-mortem cost decreased from 2 to 1.5
- When transitioning to phase 2, the boss will receive 2-3 GOLEM Upgrades
- GOLEM Boss always knows the player's true host (no post-swap confusion)
- GOLEM Boss can swap into the player if it has enough Local Energy or certain conditions are met
- GOLEM Boss will swap out of the player before dying, avoiding the post-mortem penalty
- GOLEM Boss will no longer be stunned when its swap target is killed or possessed by the player, and will switch to a different target after a short cooldown
- Swap telegraph duration halved
- GOLEM Boss has a swap variety bonus applied to its kills (yippie)

EM3 Steeltoe Changes:
- Steeltoe will fire as soon as its attack cooldown is over (usually)
- Steeltoe will perform Nail Drivers more often

EM3 Router Changes:
- Router has increased base dash strength (similar effect to Preheated Tires)
- If charging dash, Router will react to incoming damage by releasing dash and throwing a grenade

EM3 Aphid Changes:
- Slightly increased flame output
- Aphid will sometimes pan-sear the player instead of an ally if its swap shield health is above 40%

EM3 Deadlift Changes:
- 33% increased grapple strength
- Grapple cannot be dislodged by taking damage

EM3 Collider Changes:
- Significantly improved aim
- Collider will not be stunned when taking damage mid-tackle
- 33% increased resting orbital velocity

EM3 Tachi Changes:
- Tachi will attempt to deflect projectiles if the saber is idle
- Tachi has a chance to activate KILL MODE when the player is in range
- 33% increased KILL MODE dash speed

EM3 Thistle Changes:
- Thistle will attempt to hit the player with suspended lasers during a bomb boost (it is not very good at it)
- Thistle retains 10% movement speed while charging a laser

EM3 Epitaph Changes:
- 25% increased bat knockback
- Epitaph has a chance to perform multiple melee swings in quick succession in order to reach the player

EM3 GOLEM Upgrade Notes:
- All 15 GOLEM Upgrades are compatible with the GOLEM AI, if an upgrade does not appear in the list, it probably just works how you would expect
- Upgrades can be toggled with the 'activate' and 'deactivate' debug commands (e.g. 'deactivate deviance', 'activate all'
- Deviance: only doubles incoming damage when the swap shield is down
- Doubt: works how you would expect, but it is worth noting that Doubt enables the boss to swap into the player at will, as the cost will be refunded upon swapping out
- Euphoria: instead of slowing time, the GOLEM will speed up by a factor of 2 similarly to max Perceptual Downsampling
- Hubris: when its swap shield is low, the GOLEM will attempt to swap early in order to avoid a post-mortem
- Hyperopia: replaces the normal upgrade presets with new, better upgrade presets that it gives to every bot except the current type
- Indulgence: if certain conditions are met and the GOLEM has enough energy, it will perform a chain swap like it does in phase 2
- Obsession: the set of upgrades given to the chosen host is randomly selected from preset upgrade builds, they are not truly random
