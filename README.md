## Setup + Goal

With the discovery of adamantium in the deepest reaches of the solar system, every mining company is looking to be the first to get their hands on it. However, the expedition is too risky and dangerous to take alone. You play members of the newly founded Astral Initiative, a joint effort between almost every mining company in the solar system with the goal of finding and taking home the legendary metal.

You each launch a colony bubble onto a different key area of an adamantite asteroid, and you must work together to sustain each other and breach the depths of the asteroid.

## Game Pieces
### Main
- **Colony**: What you are trying to protect. Damage that isn't protected against by the energy shield will inflict permanent damage to the colony. If the colony runs out of HP, your colony explodes and everyone loses.
- **Energy Shield**: Protects the colony from ion storms, and provides limited protection against asteroids. To keep it online, it must be fed energy. It can be upgraded to give it higher capacity, which is needed to protect against more dangerous events.
- **Research Lab**: Unlocks new buildings and upgrades existing buildings to allow you to survive more deadly waves and dig deeper into the asteroid. The research lab uses power to generate research points, which are used to purchase researches in the tech tree. The more manpower you have, the faster the research lab works. Each research point requires increasingly more time and power to acquire.  Once a research has been unlocked, it can't be undone, and doesn't apply to other players: only you. Research points can't be traded, but the power required for it can be traded. 
- **Trade Hub**: Allows you to set up trade routes between players. You may sacrifice some of your production of a resource in order to send it to another player who needs it. The rate at which you can send resources to another player is capped to keep design interesting, and this cap can be upgraded to allow faster trade.
- **Upgrade Screen**: A menu that shows all available upgrades that can be purchased. All upgrades are available to everyone, and cost resources you either purchase or produce in order to apply its effect. Upgrades take time to come into effect once you purchase them, and they are again sped up by manpower. Upgrades again only apply to you, but the resources they require can be traded to skip possible prerequisites.
- **Building Screen**: A menu that shows all available buildings that can be purchased. Buildings cost resources much like the upgrade screen, and take time to build before they become active. Having more manpower means buildings are built faster.
### Parts of Screen
- **Sky**: Shows the incoming threat that the players face, details on what is required to defeat it, and how long until the next threat arrives.
- **Defense Dome**: Shows the dome and turrets that the colony has. Initially contains the 2 starting gun turrets that every player starts the game with, and is where new turrets are placed.
- **Building Floor**: A grid that contains all energy producing and material processing buildings. Initially contains the solar array that every player starts the game with, and is where new non-mining buildings are placed.
- **Asteroid Depths**: A grid that contains all of the asteroid's resources. Is separate per player, and each player has access to different resources. Mining buildings are placed here to extract resources.
### Buildings

All buildings take time to construct. The more manpower you have, the faster buildings are constructed.
#### Defense
All turrets can have the base damage and firing speed upgraded. Some turrets have specific upgrades associated with them.
- Gun Turrets: Eat 1 metal to shoot a bullet that deals damage to asteroids. Higher tier metals deal more damage.
	- Cost:
	- Ammo: iron, steel, tungsten carbide
- Tesla Turret: Eat energy to shoot a chaining lightning bolt that hits lots of asteroids.
	- Cost:
	- Ammo: energy
	- Upgrades: Energy used per firing (more energy = more damage), lightning bolt chain length
- Flak Turret: Eat lots of metal to shoot a barrage of flak that can hit lots of asteroids at once. Higher tier metals deal more damage.
	- Cost:
	- Ammo: iron, steel, tungsten carbide
	- Upgrades: Flak count (uses more ammo to fire more bullets)
- Laser Turret: Eat batteries to shoot a high-power piercing laser that deals insane damage to a single target.
	- Cost: 
	- Ammo: batteries
	- Upgrades: Laser width (uses more batteries to fire a wider laser)
#### Energy Production
- Solar Panel: Passively generates energy.
	- Cost: ? silicon
	- Stats: 1 energy/s
- Carbon Generator: Consumes carbon to generate energy.
	- Cost:
	- Stats:
- Steam Generator: Consumes carbon and ice to generate energy.
	- Cost:
	- Stats:
#### Resource Processing
- Rock Crusher: Consumes rocks to produce tier 1 metals rarely.
	- Cost: ? iron + ? silicon
	- Recipes: rock -> tier 1 metals, voidstone -> tier 2/3 metals
- Steel Foundry: Consumes iron and carbon to produce steel.
	- Cost: ? iron + ? copper circuits
	- Recipes: ? iron + ? carbon -> 1 steel
- Circuit Processor: Consumes various circuit components to produce circuits.
	- Cost: 
		- ? copper + ? silicon (tier 1) 
		- ? gold + ? copper circuits (tier 2) 
		- ? platinum + ? gold circuits (tier 3)
	- Recipes: 
		- ? silicon + ? copper -> 1 copper circuit (tier 1) 
		- ? silicon + ? gold -> 1 gold circuit (tier 2) 
		- ? silicon + ? gold + ? platinum -> 1 platinum circuit (tier 3)
- Battery Factory: Consumes battery components to produce batteries.
	- Cost: ? nickel + ? gold circuits
	- Recipes: ? nickel + ? copper -> 1 battery
- Sinterer: High-tier processor that produces tungsten carbide and silicon carbide.
	- Cost: ? tungsten + ? platinum circuits
	- Recipes:
		- ? tungsten + ? carbon -> 1 tungsten carbide
		- ? silicon + ? carbon -> 1 silicon carbide
#### Mining
- Miner: Mines the resource under the tile it's placed on. Miners generate heat while mining, and have a passive cool-off rate for that heat. The base miner generates 2 heat/s, but passively cools off 1 heat/s. Miners also have a heat capacity: if the miner hits its heat capacity, it stops working until it cools off completely, at which point it starts working again.
	- Cost: 
		- ? iron (tier 1) 
		- ? steel + ? copper circuits (tier 2) 
		- ? tungsten carbide + ? gold circuits (tier 3)
	- Stats: 
		- mines 1 ore/s, generates 2 heat/s, cools 1 heat/s, 10 heat capacity (tier 1)
		- ??? (tier 2)
		- ??? (tier 3)
- Coolant Cell: Takes heat from surrounding objects and absorbs it into itself. It has a heat capacity that when reached, it becomes useless and can no longer absorb heat until it is replaced.
	- Cost: ? ice
	- Stats: 300 heat capacity (4 miners take ~1:15 to deplete the cell)
- Heat Pipe: Placed on top of other objects on a second layer, and transfers heat between them. It absorbs heat from all heat producers like miners up to a certain cap, and then transfers that heat to heat consumers like radiators. If the heat produced by the buildings it's on top of exceeds the cap, it redistributes heat above the cap evenly back to the heat producers. This also happens if there is heat left over from not having enough heat consumers.
	- Cost: ? copper, ? ice
	- Stats: 10 heat capacity
- Radiator: Takes heat and radiates it out to space, getting rid of it. Does not take energy to function.
	- Cost: ? copper
	- Stats:
- Amplifier: Makes buildings more powerful by consuming energy. Buildings next to amplifiers have their effects like ore produced and heat dispersed increased. Tier 1 amplifiers cannot affect other amplifiers, but tier 2 amplifiers can.
	- Cost:
	- Stats:
- Veil Piercer: End game building that pierces the veil shrouding adamantium. The veil has HP that ticks down the more veil piercers are next to it. Once it is depleted, the veil moves 1 tile downwards and reveals adamantium. The veil piercers must then be moved one tile downwards if you are to continue pushing the veil downwards.
	- Cost: 
	- Stats:
## Resources

Resources are stored individually per player. Once you obtain a resource, it becomes part of your resource pool immediately, and there is no need to transfer or transport it anywhere. Resources can be traded at a limited rate through the Trade Hub.
### Key Resources

- **Energy**: All buildings are powered by energy. Each colony comes with a starting solar array to sustain itself, but additional energy sources must be built if you are to mine into the asteroid. Energy keeps the energy shield up and progresses research.
- **Manpower**: The people living in the colony, which construct buildings and conduct research for you. The more manpower you have, the quicker tasks are finished. Manpower can be purchased with money, which can be done by selling materials. Manpower cannot be traded, due to the idea that these are still technically competing companies.
- **Money**: Generated by selling materials that are mined. More valuable materials are worth more money, but materials sold can't be used to make buildings. Used to purchase additional manpower. Money cannot be traded, due to the idea that these are still technically competing companies.
- **Research Points**: Used to purchase upgrades from the tech tree. Generated from the research lab by providing it power.
### Minable Materials

#### Layer 1
- Rock: Not useful for much, can be mined as a last resort if there is nothing else to mine. Can be reprocessed to yield more layer 1 metals. Sells for $1.
- Iron: Used in lots of mining equipment. Sells for $2.
- Copper: Used in heat pipes, radiators, and circuits. Sells for $2.
- Silicon: The basis for circuits and solar panels. Sells for $2.
- Ice: Used for cooling systems. Sells for $1.
#### Layer 2
- Gold: Valuable metal that is used for higher tier electronics and sells for a lot. Sells for $10.
	- Cobalt?: Hard metal used for stronger mining equipment and also batteries. Sells for $5.
- Carbon: Used for fueling generators, creating steel. Sells for $2.
- Nickel: Used in batteries for shields and some defenses. Sells for $5.
#### Layer 3
- Platinum: Valuable metal used in even higher tier electronics. Sells for $20.
- Tungsten: Used in tungsten carbide for powerful mining equipment. Sells for $15.
	- Palladium?:
#### Layer 4
- Voidstone: Corrupted stone formed by the presence of adamantium at the core.
- Neutronflux:
- Stellarium:
- Plasmite:
#### Layer 5
- Adamantium: The target of the mining expedition. Before mining it, you must pierce the mysterious veil shrouding the adamantium, as otherwise it is shrouded and inaccessible. The moment you start mining it, all outside threats significantly intensify and the asteroid starts self-destructing, as the asteroid really does not want you to mine it. You must escape with as much adamantium as possible before the asteroid completely collapses, or you are overwhelmed by the increased threats.
## Upgrades

Upgrades are different from researches in that they cost resources instead of research points, and they are meant to be available to everyone instead of having players specialize in one field. They also target buildings you have unlocked, rather than unlocking new buildings.
- drill yield multiplier
- heat caps
- 
## Research Paths

Researches are meant to unlock new buildings, enabling alternate ways of playing the game. The goal is to have it so that players need to specialize in different things, as they don't have enough research points to do everything they want. This naturally means that things that every player would want should stay out of the research tree and just be upgrades instead.
### General
- 
### Miner
- Unlock rock crusher
- Unlock heat pipes/radiators
- Unlock Amplifier tier 1/tier 2
- Drill increased yield + increased heat
### Defender
- Unlock 
### Researcher
- 
### Entrepreneur
- Increased sell value for resources
## Threats
- **Asteroids**: 
- **Ion Storms**:

## Verbs (what can the player do)

