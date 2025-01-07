//used in various places
#define ALL_RACES_LIST			list("human", "dwarf", "elf", "tiefling", "aasimar", "halforc", "orc", "zizombie")

#define ALL_PLAYER_RACES_BY_NAME		list("Humen", "Half-Elf", "Dark Elf", "Elf", "Dwarf","Tiefling", "Half-Orc", "Aasimar")

#define ALL_TEMPLE_PATRONS 		list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/necra, /datum/patron/divine/ravox, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora)
#define ALL_CLERIC_PATRONS 		list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/necra, /datum/patron/divine/ravox, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora)
#define ALL_TEMPLAR_PATRONS 	list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/eora, /datum/patron/divine/necra, /datum/patron/divine/pestra, /datum/patron/divine/dendor, /datum/patron/divine/abyssor)

GLOBAL_LIST_INIT(curse_names, list())

#define TEN_CURSES list(\
	/datum/curse/astrata,\
	/datum/curse/noc,\
	/datum/curse/ravox,\
	/datum/curse/necra,\
	/datum/curse/xylix,\
	/datum/curse/pestra,\
	/datum/curse/eora\
)

#define INHUMEN_CURSES list(\
	/datum/curse/zizo,\
	/datum/curse/graggar,\
	/datum/curse/matthios,\
	/datum/curse/baotha\
)
#define SPECIAL_CURSES list(\
	/datum/curse/atheism\
)
#define ALL_CURSES list(\
	SPECIAL_CURSES,\
	TEN_CURSES,\
	INHUMEN_CURSES\
)

#define PLATEHIT "plate"
#define CHAINHIT "chain"
#define SOFTHIT "soft"
#define SOFTUNDERHIT "softunder"

/proc/get_armor_sound(blocksound, blade_dulling)
	switch(blocksound)
		if(PLATEHIT)
			if(blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/plate_slashed (1).ogg','sound/combat/hits/armor/plate_slashed (2).ogg','sound/combat/hits/armor/plate_slashed (3).ogg','sound/combat/hits/armor/plate_slashed (4).ogg')
			if(blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_BITE)
				return pick('sound/combat/hits/armor/plate_stabbed (1).ogg','sound/combat/hits/armor/plate_stabbed (2).ogg','sound/combat/hits/armor/plate_stabbed (3).ogg')
			else
				return pick('sound/combat/hits/armor/plate_blunt (1).ogg','sound/combat/hits/armor/plate_blunt (2).ogg','sound/combat/hits/armor/plate_blunt (3).ogg')
		if(CHAINHIT)
			if(blade_dulling == BCLASS_BITE||blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/chain_slashed (1).ogg','sound/combat/hits/armor/chain_slashed (2).ogg','sound/combat/hits/armor/chain_slashed (3).ogg','sound/combat/hits/armor/chain_slashed (4).ogg')
			else
				return pick('sound/combat/hits/armor/chain_blunt (1).ogg','sound/combat/hits/armor/chain_blunt (2).ogg','sound/combat/hits/armor/chain_blunt (3).ogg')
		if(SOFTHIT)
			if(blade_dulling == BCLASS_BITE||blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/light_stabbed (1).ogg','sound/combat/hits/armor/light_stabbed (2).ogg','sound/combat/hits/armor/light_stabbed (3).ogg')
			else
				return pick('sound/combat/hits/armor/light_blunt (1).ogg','sound/combat/hits/armor/light_blunt (2).ogg','sound/combat/hits/armor/light_blunt (3).ogg')
		if(SOFTUNDERHIT)
			if(blade_dulling == BCLASS_BITE||blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/light_stabbed (1).ogg','sound/combat/hits/armor/light_stabbed (2).ogg','sound/combat/hits/armor/light_stabbed (3).ogg')
			else
				return pick('sound/combat/hits/armor/light_blunt (1).ogg','sound/combat/hits/armor/light_blunt (2).ogg','sound/combat/hits/armor/light_blunt (3).ogg')

GLOBAL_LIST_INIT(lockhashes, list())
GLOBAL_LIST_INIT(lockids, list())
GLOBAL_LIST_EMPTY(credits_icons)
GLOBAL_LIST_EMPTY(confessors)

GLOBAL_LIST_INIT(wolf_prefixes, list("Red", "Moon", "Bloody", "Hairy", "Eager", "Sharp"))
GLOBAL_LIST_INIT(wolf_suffixes, list("Fang", "Claw", "Stalker", "Prowler", "Roar", "Ripper"))
//preference stuff
#define FAMILY_NONE "None"
#define FAMILY_PARTIAL "Siblings"
#define FAMILY_NEWLYWED "Newlywed"
#define FAMILY_FULL "Parent"

#define FAMILY_FATHER "Father"
#define FAMILY_MOTHER "Mother"
#define FAMILY_PROGENY "Progeny"
#define FAMILY_ADOPTED "Adoptive Progeny"
#define FAMILY_OMMER "Parents Sibling"
#define FAMILY_INLAW "In Law"

GLOBAL_LIST_EMPTY(job_respawn_delays)

//stress levels
#define STRESS_MAX 30
#define STRESS_INSANE 7
#define STRESS_VBAD 5
#define STRESS_BAD 3
#define STRESS_NEUTRAL 2
#define STRESS_GOOD 1
#define STRESS_VGOOD 0

/*	........   Nutrition defines   ................ */
#define MEAL_FILLING 30
#define MEAL_GOOD 24
#define MEAL_AVERAGE 18
#define MEAL_MEAGRE 15
#define SNACK_CHUNKY 12
#define SNACK_NUTRITIOUS 9
#define SNACK_DECENT 6
#define SNACK_POOR 3

#define DOUGH_NUTRITION MEAL_MEAGRE
#define SMALLDOUGH_NUTRITION MEAL_MEAGRE/2
#define BUTTERDOUGH_NUTRITION DOUGH_NUTRITION+3
#define BUTTERDOUGHSLICE_NUTRITION BUTTERDOUGH_NUTRITION/2
#define BUTTER_NUTRITION SNACK_POOR
#define MEATSLAB_NUTRITION SNACK_NUTRITIOUS
#define SAUSAGE_NUTRITION SNACK_NUTRITIOUS
#define MINCE_NUTRITION MEATSLAB_NUTRITION/2
#define FRESHCHEESE_NUTRITION SNACK_DECENT

/*	........   Rotting Food defines   ................ */
#define SHELFLIFE_EXTREME 90 MINUTES
#define SHELFLIFE_LONG 50 MINUTES
#define SHELFLIFE_DECENT 30 MINUTES
#define SHELFLIFE_SHORT 20 MINUTES
#define SHELFLIFE_TINY 12 MINUTES

/*
	Formerly bitflags, now we are strings
	Currently used for classes, I could have used these for drifters tho
*/

#define CTAG_ALLCLASS		"CAT_ALLCLASS"		// jus a define for allclass to not deal with actively typing strings
#define CTAG_DISABLED 		"CAT_DISABLED" 		// Disabled, aka don't make it fuckin APPEAR
#define CTAG_PILGRIM 		"CAT_PILGRIM"  		// Pilgrim classes
#define CTAG_ADVENTURER 	"CAT_ADVENTURER"  	// Adventurer classes
#define CTAG_TOWNER 		"CAT_TOWNER"  		// Villager class - Villagers can use it
#define CTAG_ANTAG 			"CAT_ANTAG"  		// Antag class - results in an antag
#define CTAG_BANDIT			"CAT_BANDIT"		// Bandit class - Tied to the bandit antag really	<- Disabled; bandits got stuck with class selection
#define CTAG_CHALLENGE 		"CAT_CHALLENGE"  	// Challenge class - Meant to be free for everyone
#define CTAG_MERCENARY		"CAT_MERCENARY"
#define CTAG_GARRISON		"CAT_GARRISON"
#define CTAG_ADEPT			"CAT_ADEPT" // Used for Adept class selection
#define CTAG_SQUIRE 		"CAT_SQUIRE" // Squire Love, Classes, as above.
#define CTAG_HEIR			"CAT_HEIR"
#define CTAG_HAND			"CAT_HAND"			// Hand class - Handles Hand class selector
#define CTAG_CONSORT 		"CAT_CONSORT" 		// Consort classes
#define CTAG_VETERAN		"CAT_VETERAN"		// Veteran class - Handles Veteran class selector
/*
	Defines for the triumph buy datum categories
*/
#define TRIUMPH_CAT_ROUND_EFX "ROUND-EFX"
#define TRIUMPH_CAT_CHARACTER "CHARACTER"
#define TRIUMPH_CAT_MISC "MISC!"
#define TRIUMPH_CAT_ACTIVE_DATUMS "ACTIVE"


// .............. SELLPRICE/VALUE DEFINES ..................... //
// Basicallly material cost + work cost will be the value from now on. Needs work to value these things in comparison but its a simple way to get some consistency to it
// The material cost, work cost and bonus value should mostly be a under the hood thing so its easy to parse. Adjusting them will obviously affect end user costs.
// Keep values divisible by 2 and 3 and 4 without fractions, lets avoid money fractions guys.

// Material costs.
// theres two parts of what a material is worth, how hard is it to find it and how painful is it to collect, and how useful is it.
#define VALUE_OF_A_SIMPLE_MEAL 6	// some sort of base value, usually whats charged for a basic meal in the inn. Good measure to work from. Its comically low valued when looking at the actual invested material + effort vs smithing or crafting though
#define VALUE_OF_A_MUG_OF_ALE 2
#define M_MISC		1	// random stuff like stones or fibres I guess
#define M_WOOD		2	// one small log.
#define M_CLOTH		2	// one cloth piece
#define M_GRAIN		1	// one threshed wheat grain
#define M_FUR		M_CLOTH * 2
#define M_SILK		M_CLOTH * 2	// one silk thread
#define M_SALT		4	// one salt, or raw ore, or coal
#define M_LEATHER	M_CLOTH * 2 // one hide
#define M_IRON		12	// one iron bar  Twelve is a good number for it can be halved, cut in three and four without fractions. Multiples of 6
#define M_STEEL		M_IRON+W_MODERATE	// one steel bar
#define M_SILVER	M_IRON*3	// one silver bar
#define M_GOLD		M_IRON*5	// one gold bar

// Skill costs - a rarity value add, items requiring a high skill to produce are rarer and has more intrinsic value. So craftsmen can make a profit.
#define SKILL_1		2
#define SKILL_2		4
#define SKILL_3		6
#define SKILL_4		8
#define SKILL_5		10

// Work costs - valued VERY low compared to raw materials, this is a problem but at least its systemic and visible now and can be adjusted. Very rough, time to gather stuff, refine it etc etc as well as crafting time itself.
#define W_MINOR		2				// Less than 10 seconds of work
#define W_MODERATE	W_MINOR * 3		// Less than 1 minute of work, high skill required
#define W_MAJOR		W_MINOR * 6		// Less than 3 minutes of work

// Bonus value - totally arbitrary bonus slapped on. For magic items, unique stuff you want people to steal/plunder etc
#define BONUS_VALUE_TINY		6
#define BONUS_VALUE_SMALL		12
#define BONUS_VALUE_MODEST		BONUS_VALUE_SMALL * 2
#define BONUS_VALUE_BIG			BONUS_VALUE_SMALL * 4

#define GREED_SMALL_POTATO		BONUS_VALUE_TINY	// to get some profit margin to the offmap trading company and make economy make sense
#define GREEDY_TRADER			BONUS_VALUE_SMALL	// slap this on most stuff the trader imports (its the markup they pay their supplier, or just double value for stuff you want to keep rare)

/*--------------\
| VALUE DEFINES |	- If you find this confusing focus on this bit. Just use the value define below you think seems reasonable, done.
\--------------*/
// TINY is 1/3 of a bar, SMALL is 1/2
#define NO_MARKET_VALUE			null
#define VALUE_CHEAP_CLOTHING	M_CLOTH+W_MINOR
#define VALUE_FINE_CLOTHING		M_CLOTH+M_SILK+W_MINOR
#define VALUE_FANCY_HAT			M_SILK+W_MINOR+BONUS_VALUE_SMALL
#define VALUE_IRON_SMALL_ITEM	VALUE_IRON_ITEM/2
#define VALUE_IRON_ITEM			M_IRON+W_MINOR
#define VALUE_STEEL_SMALL_ITEM	VALUE_STEEL_ITEM/2
#define VALUE_STEEL_ITEM		M_STEEL+W_MINOR
#define VALUE_SILVER_TINY_ITEM	M_SILVER/3+W_MODERATE/3
#define VALUE_SILVER_ITEM		M_SILVER+W_MODERATE
#define VALUE_GOLD_TINY_ITEM	M_GOLD/3+W_MODERATE/3
#define VALUE_GOLD_ITEM			M_GOLD+W_MODERATE
#define VALUE_GOLD_RARE_ITEM	VALUE_GOLD_ITEM+BONUS_VALUE_MODEST

#define VALUE_PADDED_DRESS			M_SILK*5+W_MODERATE+BONUS_VALUE_TINY
#define VALUE_SMALL_LEATHER			M_LEATHER+W_MINOR
#define VALUE_MEDIUM_LEATHER		M_LEATHER*2+W_MINOR
#define VALUE_BIG_LEATHER			M_LEATHER*3+W_MINOR
#define VALUE_SMALL_FUR				M_FUR+M_MISC*2+W_MINOR

#define VALUE_LIGHT_GAMBESSON		M_CLOTH*2+M_MISC+W_MINOR
#define VALUE_GAMBESSON				M_CLOTH*4+M_MISC+W_MINOR
#define VALUE_HEAVY_GAMBESSON		M_CLOTH*6+M_MISC*4+W_MODERATE
#define VALUE_FUR_ARMOR				M_LEATHER*2+M_FUR+W_MINOR
#define VALUE_LEATHER_ARMOR			M_LEATHER*2+W_MINOR
#define VALUE_LEATHER_ARMOR_FUR		VALUE_LEATHER_ARMOR+M_SALT
#define VALUE_LEATHER_ARMOR_PLUS	VALUE_STEEL_SMALL_ITEM+M_LEATHER
#define VALUE_LEATHER_ARMOR_LORD	VALUE_LEATHER_ARMOR+BONUS_VALUE_MODEST
#define VALUE_IRON_ARMOR			VALUE_IRON_ITEM
#define VALUE_IRON_ARMOR_UNUSUAL	VALUE_IRON_ITEM+BONUS_VALUE_TINY
#define VALUE_STEEL_ARMOR			VALUE_STEEL_ITEM
#define VALUE_STEEL_ARMOR_FINE		VALUE_STEEL_ITEM+BONUS_VALUE_TINY
#define VALUE_BRIGANDINE			VALUE_STEEL_ITEM*2+M_CLOTH+BONUS_VALUE_TINY
#define VALUE_FULL_PLATE			VALUE_STEEL_ITEM*3
#define VALUE_SNOWFLAKE_STEEL		VALUE_STEEL_ARMOR+BONUS_VALUE_MODEST

#define VALUE_LEATHER_HELMET		M_LEATHER*2+W_MINOR
#define VALUE_CHEAP_IRON_HELMET		VALUE_IRON_SMALL_ITEM
#define VALUE_IRON_HELMET			VALUE_IRON_ITEM
#define VALUE_CHEAP_STEEL_HELMET 	VALUE_STEEL_SMALL_ITEM
#define VALUE_STEEL_HELMET			VALUE_STEEL_ITEM
#define VALUE_SILVER_RING			VALUE_SILVER_TINY_ITEM
#define VALUE_GOLD_RING				VALUE_GOLD_TINY_ITEM
#define VALUE_MUSC_INSTRUMENT		VALUE_COMMON_GOODS
#define VALUE_RARE_MUSIC_INSTRUMENT	VALUE_COSTLY_THING


// Generic values - a lot of items lack materials for the above calculations so this is a super basic template to assign value to misc items
#define VALUE_DIRT_CHEAP	6
#define VALUE_COMMON_GOODS	VALUE_DIRT_CHEAP * 2		// so 12
#define VALUE_COSTLY_THING	VALUE_COMMON_GOODS * 3		// 36
#define VALUE_LUXURY_THING	VALUE_COSTLY_THING * 2		// and 72
#define VALUE_EXTREME		VALUE_LUXURY_THING * 4		// and 288

#define VALUE_MAGIC_ITEM_WEAK	VALUE_COSTLY_THING+BONUS_VALUE_MODEST
#define VALUE_MAGIC_ITEM_STRONG	VALUE_MAGIC_ITEM_WEAK+BONUS_VALUE_BIG






/*--------------------\
| ARMOR BASIC CONCEPT |
\--------------------*/
/*
Valid until the day someoen adds blunt/stab/cut damage defines from Blackstone

Five general types of armor with some general outlines.
*With current system armor less than 25 vs arrows is pretty much zero.
Armor values aren´t %
Differences between similar armorsets mostly about coverage or crit, small variation in armor value for non-smithed ones

Type					Melee/Arrow		Integrity		AC
Minor					10/0*			varies			varies (light)
Padded					25/30			low  			light
Leather					35/0*			medium			light
Mail/Scale/Medium		60/35			medium 			medium
Heavy Plate/Layered		90/70			good			heavy

Thing can move up or down an armor class by significant changes to coverage & crit protection. Like cuirass gets plate, but only covers torso, gets Medium AC instead of Heavy AC.
*/

/*------------------------\
| ARMOR INTEGRITY DEFINES |	- So armor makes sense
\------------------------*/

#define INTEGRITY_STRONGEST		500		// STEEL
#define INTEGRITY_STRONG		300		// IRON
#define INTEGRITY_STANDARD		200		// LEATHER
#define INTEGRITY_POOR			150		// GAMBESON, COPPER
#define INTEGRITY_WORST			100


/*--------------------\
| ARMOR VALUE DEFINES |	- So armor makes sense. Basic arrow got 25 AP so less than 25 "piercing" does nothing vs arrows generally
\--------------------*/

// Light AC
#define ARMOR_MINIMAL		list("blunt" = 5, "slash" = 5, "stab" = 5, "piercing" = 0, "fire" = 0, "acid" = 0)
#define ARMOR_WEAK			list("blunt" = 10, "slash" = 10, "stab" = 10, "piercing" = 5, "fire" = 0, "acid" = 0)

#define ARMOR_PADDED_BAD	list("blunt" = 15, "slash" = 15, "stab" = 15, "piercing" = 15, "fire" = 0, "acid" = 0)
#define ARMOR_PADDED		list("blunt" = 25, "slash" = 25, "stab" = 25, "piercing" = 30, "fire" = 0, "acid" = 0)
#define ARMOR_PADDED_GOOD	list("blunt" = 30, "slash" = 30, "stab" = 30, "piercing" = 35, "fire" = 0, "acid" = 0)

#define ARMOR_LEATHER_BAD	list("blunt" = 30, "slash" = 30, "stab" = 30, "piercing" = 10, "fire" = 0, "acid" = 0)
#define ARMOR_LEATHER		list("blunt" = 35, "slash" = 35, "stab" = 35, "piercing" = 15, "fire" = 0, "acid" = 0)
#define	ARMOR_LEATHER_GOOD	list("blunt" = 40, "slash" = 40, "stab" = 40, "piercing" = 20, "fire" = 0, "acid" = 0)

// Medium AC
#define ARMOR_MAILLE_IRON	list("blunt" = 5, "slash" = 5, "stab" = 50, "piercing" = 30, "fire" = 0, "acid" = 0)
#define ARMOR_MAILLE		list("blunt" = 5, "slash" = 5, "stab" = 55, "piercing" = 40, "fire" = 0, "acid" = 0)
#define ARMOR_MAILLE_GOOD	list("blunt" = 60, "slash" = 60, "stab" = 60, "piercing" = 45, "fire" = 0, "acid" = 0)

#define ARMOR_SCALE			list("blunt" = 65, "slash" = 65, "stab" = 65, "piercing" = 65, "fire" = 0, "acid" = 0)

// Heavy AC
#define ARMOR_PLATE_BAD		list("blunt" = 70, "slash" = 70, "stab" = 70, "piercing" = 50, "fire" = 0, "acid" = 0)
#define ARMOR_PLATE			list("blunt" = 85, "slash" = 85, "stab" = 85, "piercing" = 70, "fire" = 0, "acid" = 0)
#define ARMOR_PLATE_GOOD	list("blunt" = 90, "slash" = 90, "stab" = 90, "piercing" = 85, "fire" = 0, "acid" = 0)


/*-----------------------\
| COVERAGE ARMOR DEFINES |
\-----------------------*/

#define COVERAGE_HEAD_NOSE		( HEAD | HAIR | EARS | NOSE )
#define COVERAGE_HEAD			( HEAD | HAIR | EARS )
#define COVERAGE_NASAL			( HEAD | HAIR | NOSE )
#define COVERAGE_SKULL			( HEAD | HAIR )

#define COVERAGE_VEST			( CHEST | VITALS )
#define COVERAGE_SHIRT			( CHEST | VITALS | ARMS )
#define COVERAGE_TORSO			( CHEST | GROIN | VITALS )
#define COVERAGE_ALL_BUT_ARMS	( CHEST | GROIN | VITALS | LEGS )
#define COVERAGE_ALL_BUT_LEGS	( CHEST | GROIN | VITALS | ARMS )
#define COVERAGE_FULL			( CHEST | GROIN | VITALS | LEGS | ARMS )

#define COVERAGE_PANTS			( GROIN | LEGS )
#define COVERAGE_FULL_LEG		( LEGS | FEET )

/*-----------------------------\
| CRITICAL HIT DEFENSE DEFINES |
\-----------------------------*/

#define ALL_CRITICAL_HITS list(\
BCLASS_CUT, \
BCLASS_CHOP, \
BCLASS_BLUNT, \
BCLASS_STAB, \
BCLASS_LASHING, \
BCLASS_BITE, \
BCLASS_TWIST)

// Vampire heavy armor, always vulnerable to whips
#define ALL_CRITICAL_HITS_VAMP list(\
BCLASS_CUT, \
BCLASS_CHOP, \
BCLASS_BLUNT, \
BCLASS_STAB, \
BCLASS_BITE, \
BCLASS_TWIST)

#define ALL_EXCEPT_STAB list(\
BCLASS_CUT, \
BCLASS_CHOP, \
BCLASS_BLUNT, \
BCLASS_LASHING, \
BCLASS_BITE, \
BCLASS_TWIST)

// Typical maille
#define ALL_EXCEPT_BLUNT list(\
BCLASS_CUT, \
BCLASS_CHOP, \
BCLASS_STAB, \
BCLASS_LASHING, \
BCLASS_BITE, \
BCLASS_TWIST)

// Plates cover only a few organs and bones
#define ONLY_VITAL_ORGANS list(\
BCLASS_CHOP, \
BCLASS_BLUNT)

#define ALL_EXCEPT_CHOP_AND_STAB list(\
BCLASS_CUT, \
BCLASS_BLUNT, \
BCLASS_LASHING, \
BCLASS_BITE, \
BCLASS_TWIST)

#define ALL_EXCEPT_BLUNT_AND_STAB list(\
BCLASS_CUT, \
BCLASS_CHOP, \
BCLASS_LASHING, \
BCLASS_BITE, \
BCLASS_TWIST)

#define CUT_AND_MINOR_CRITS list(\
BCLASS_CUT, \
BCLASS_LASHING, \
BCLASS_BITE, \
BCLASS_TWIST)

#define BLUNT_AND_MINOR_CRITS list(\
BCLASS_BLUNT, \
BCLASS_LASHING, \
BCLASS_BITE, \
BCLASS_TWIST)

#define MINOR_CRITICALS list(\
BCLASS_LASHING, \
BCLASS_BITE, \
BCLASS_TWIST)



/*-----------------------\
| Decorated Helmet Lists |
\-----------------------*/

#define HELMET_KNIGHT_DECORATIONS list(\
		"Basic"="basic_decoration",\
		"Blue"="blue_decoration",\
		"Stripes"="stripes_decoration",\
		"Red Castle"="castle_red_decoration",\
		"White Castle"="castle_white_decoration",\
		"Graggar"="graggar_decoration",\
		"Efreet"="efreet_decoration",\
		"Sun"="sun_decoration",\
		"Peace"="peace_decoration",\
		"Feathers"="feathers_decoration",\
		"Lion"="lion_decoration",\
		"Red Dragon"="dragon_red_decoration",\
		"Green Dragon"="dragon_green_decoration",\
		"Horns"="horns_decoration",\
		"Swan"="swan_decoration",\
		"Fish"="fish_decoration",\
		"Windmill"="windmill_decoration", \
		"Oathtaker"="oathtaker_decoration",\
		"Skull"="skull_decoration")

#define HELMET_HOUNSKULL_DECORATIONS list(\
		"Basic"="basic_houndecoration",\
		"Blue"="blue_houndecoration",\
		"Stripes"="stripes_houndecoration",\
		"Red Castle"="castle_red_houndecoration",\
		"White Castle"="castle_white_houndecoration",\
		"Graggar"="graggar_houndecoration",\
		"Efreet"="efreet_houndecoration",\
		"Peace"="peace_houndecoration",\
		"Sun"="sun_houndecoration",\
		"Feathers"="feathers_houndecoration",\
		"Lion"="lion_houndecoration",\
		"Red Dragon"="dragon_red_houndecoration",\
		"Green Dragon"="dragon_green_houndecoration",\
		"Horns"="horns_houndecoration",\
		"Swan"="swan_houndecoration",\
		"Fish"="fish_houndecoration",\
		"Windmill"="peace_houndecoration",\
		"Oathtaker"="oathtaker_houndecoration",\
		"Skull"="skull_houndecoration")

#define HELMET_BUCKET_DECORATIONS list(\
		"Basic"="basic_bucket",\
		"Blue"="blue_bucket",\
		"Stripes"="stripes_bucket",\
		"Red Castle"="castle_red_bucket",\
		"White Castle"="castle_white_bucket",\
		"Graggar"="graggar_bucket",\
		"Efreet"="efreet_bucket",\
		"Peace"="peace_bucket",\
		"Sun"="sun_bucket",\
		"Feathers"="feathers_bucket",\
		"Lion"="lion_bucket",\
		"Red Dragon"="dragon_red_bucket",\
		"Green Dragon"="dragon_green_bucket",\
		"Horns"="horns_bucket",\
		"Swan"="swan_bucket",\
		"Fish"="fish_bucket",\
		"Windmill"="windmill_bucket",\
		"Oathtaker"="oathtaker_bucket",\
		"Skull"="skull_bucket")

#define HELMET_GOLD_DECORATIONS list(\
		"Basic"="basic_gbucket",\
		"Blue"="blue_gbucket",\
		"Stripes"="stripes_gbucket",\
		"Red Castle"="castle_red_gbucket",\
		"White Castle"="castle_white_gbucket",\
		"Graggar"="graggar_gbucket",\
		"Efreet"="efreet_gbucket",\
		"Peace"="peace_gbucket",\
		"Sun"="sun_gbucket",\
		"Feathers"="feathers_gbucket",\
		"Lion"="lion_gbucket",\
		"Red Dragon"="dragon_red_gbucket",\
		"Green Dragon"="dragon_green_gbucket",\
		"Horns"="horns_gbucket",\
		"Swan"="swan_gbucket",\
		"Fish"="fish_gbucket",\
		"Windmill"="windmill_gbucket",\
		"Oathtaker"="oathtaker_gbucket",\
		"Skull"="skull_gbucket")

#define BASCINET_DECORATIONS list(\
		"Basic"="basic_bascinet",\
		"Blue"="blue_bascinet",\
		"Stripes"="stripes_bascinet",\
		"Red Castle"="castle_red_bascinet",\
		"White Castle"="castle_white_bascinet",\
		"Graggar"="graggar_bascinet",\
		"Efreet"="efreet_bascinet",\
		"Sun"="sun_bascinet",\
		"Peace"="peace_bascinet",\
		"Feathers"="feathers_bascinet",\
		"Lion"="lion_bascinet",\
		"Red Dragon"="dragon_red_bascinet",\
		"Green Dragon"="dragon_green_bascinet",\
		"Horns"="horns_bascinet",\
		"Swan"="swan_bascinet",\
		"Fish"="fish_bascinet",\
		"Windmill"="windmill_bascinet",\
		"Oathtaker"="oathtaker_bascinet",\
		"Skull"="skull_bascinet")
