#define SHIELD_BASH		/datum/intent/shield/bash
#define SHIELD_BLOCK		/datum/intent/shield/block
#define SHIELD_BANG_COOLDOWN (3 SECONDS)

/obj/item/rogueweapon/shield
	name = ""
	desc = ""
	icon_state = ""
	icon = 'icons/roguetown/weapons/32.dmi'
	slot_flags = ITEM_SLOT_BACK
	flags_1 = null
	force = 10
	throwforce = 5
	throw_speed = 1
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	possible_item_intents = list(SHIELD_BASH, SHIELD_BLOCK)
	block_chance = 0
	sharpness = IS_BLUNT
	wlength = WLENGTH_SHORT
	resistance_flags = FLAMMABLE
	can_parry = TRUE
	associated_skill = /datum/skill/combat/shields
	destroy_sound = 'sound/foley/shielddestroy.ogg'
	wdefense = 5
	var/coverage = 90
	parrysound = "parrywood"
	attacked_sound = "parrywood"
	max_integrity = 100
	blade_dulling = DULLING_BASHCHOP
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ash
	COOLDOWN_DECLARE(shield_bang)

// Shield banging
/obj/item/rogueweapon/shield/attackby(obj/item/attackby_item, mob/user, params)
	if(istype(attackby_item, /obj/item/rogueweapon) && !istype(attackby_item, /obj/item/rogueweapon/hammer))
		if(!COOLDOWN_FINISHED(src, shield_bang))
			return
		user.visible_message("<span class='danger'>[user] bangs [src] with [attackby_item]!</span>")
		playsound(user.loc, 'sound/combat/shieldbang.ogg', 50, TRUE)
		COOLDOWN_START(src, shield_bang, SHIELD_BANG_COOLDOWN)
		return

	return ..()

/obj/item/rogueweapon/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the projectile", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, args)
	if(attack_type == THROWN_PROJECTILE_ATTACK || attack_type == PROJECTILE_ATTACK)
		if(istype(hitby, /obj/projectile))
			var/obj/projectile/P = hitby
			if(P.armor_penetration >= 80)
				owner.visible_message("<span class='danger'>The [hitby] pierces [owner]'s [src]!</span>")
				return 0
		if(owner.client?.chargedprog == 100 && owner.used_intent?.tranged)
			owner.visible_message("<span class='danger'>[owner] blocks [hitby] with [src]!</span>")
			return 1
		else
			if(prob(coverage))
				owner.visible_message("<span class='danger'>[owner] blocks [hitby] with [src]!</span>")
				return 1
	return 0

/datum/intent/shield/bash
	name = "bash"
	icon_state = "inbash"
	hitsound = list('sound/combat/shieldbash_wood.ogg')
	chargetime = 0
	item_damage_type = "blunt"

/datum/intent/shield/bash/metal
	hitsound = list('sound/combat/shieldbash_metal.ogg')

/datum/intent/shield/block
	name = "block"
	icon_state = "inblock"
	tranged = 1 //we can't attack directly with this intent, but we can charge it
	tshield = 1
	chargetime = 5
	hitsound = list('sound/combat/shieldbash_wood.ogg')
	warnie = "shieldwarn"
	item_damage_type = "blunt"

/datum/intent/shield/block/metal
	hitsound = list('sound/combat/shieldbash_metal.ogg')

/obj/item/rogueweapon/shield/wood
	name = "wooden shield"
	desc = "A simple, emblazoned round wooden shield with leather padding. \nCan exceptionally block attacks, but is more brittle than metal ones."
	icon_state = "woodsh"
	dropshrink = 0.8
	coverage = 50
	max_integrity = 150

/obj/item/rogueweapon/shield/wood/attack_right(mob/user)
	if(!overlays.len)
		if(!('icons/roguetown/weapons/wood_heraldry.dmi' in GLOB.IconStates_cache))
			var/icon/J = new('icons/roguetown/weapons/wood_heraldry.dmi')
			var/list/istates = J.IconStates()
			GLOB.IconStates_cache |= icon
			GLOB.IconStates_cache['icons/roguetown/weapons/wood_heraldry.dmi'] = istates

		var/picked_name = input(user, "Choose a Heraldry", "VANDERLIN", name) as null|anything in sortList(GLOB.IconStates_cache['icons/roguetown/weapons/wood_heraldry.dmi'])
		if(!picked_name)
			picked_name = "none"
		var/mutable_appearance/M = mutable_appearance('icons/roguetown/weapons/wood_heraldry.dmi', picked_name)
		M.alpha = 178
		add_overlay(M)
		var/mutable_appearance/MU = mutable_appearance(icon, "woodsh_detail")
		MU.alpha = 114
		add_overlay(MU)
		if(alert("Are you pleased with your heraldry?", "Heraldry", "Yes", "No") != "Yes")
			cut_overlays()
	else
		..()

/obj/item/rogueweapon/shield/wood/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -5,"sy" = -1,"nx" = 6,"ny" = -1,"wx" = 0,"wy" = -2,"ex" = 0,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 1,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.6,"sx" = 1,"sy" = 4,"nx" = 1,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = 0,"ey" = 2,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/obj/item/rogueweapon/shield/wood/adept

/obj/item/rogueweapon/shield/wood/adept/Initialize()
	..()
	if(!overlays.len)
		if(!('icons/roguetown/weapons/wood_heraldry.dmi' in GLOB.IconStates_cache))
			var/icon/J = new('icons/roguetown/weapons/wood_heraldry.dmi')
			var/list/istates = J.IconStates()
			GLOB.IconStates_cache |= icon
			GLOB.IconStates_cache['icons/roguetown/weapons/wood_heraldry.dmi'] = istates
		if("Psydon" in GLOB.IconStates_cache['icons/roguetown/weapons/wood_heraldry.dmi'])
			var/picked_name = "Psydon"
			var/mutable_appearance/M = mutable_appearance('icons/roguetown/weapons/wood_heraldry.dmi', picked_name)
			M.alpha = 178
			add_overlay(M)
			var/mutable_appearance/MU = mutable_appearance(icon, "woodsh_detail")
			MU.alpha = 114
			add_overlay(MU)
			update_icon()
		else
			return

/obj/item/rogueweapon/shield/tower
	name = "tower shield"
	desc = "A gigantic, iron reinforced shield that covers the entire body, a design-copy of the Aasimar shields of an era gone by."
	icon_state = "shield_tower"
	force = 15
	throwforce = 10
	throw_speed = 1
	throw_range = 3
	wlength = WLENGTH_NORMAL
	wbalance = -1 // Heavy, big shield
	resistance_flags = FLAMMABLE
	wdefense = 6
	coverage = 65
	parrysound = list('sound/combat/parry/shield/towershield (1).ogg','sound/combat/parry/shield/towershield (2).ogg','sound/combat/parry/shield/towershield (3).ogg')
	max_integrity = 300
	smeltresult = /obj/item/ingot/iron // Made with an iron ingot, let us recover it

/obj/item/rogueweapon/shield/tower/spidershield
	name = "spider shield"
	desc = "A bulky shield of spike-like lengths molten together. The motifs evoke anything but safety and protection."
	icon_state = "spidershield"
	coverage = 55

/obj/item/rogueweapon/shield/tower/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -5,"sy" = -1,"nx" = 6,"ny" = -1,"wx" = 0,"wy" = -2,"ex" = 0,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 1,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.6,"sx" = 1,"sy" = 4,"nx" = 1,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = 0,"ey" = 2,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/obj/item/rogueweapon/shield/tower/hoplite
	name = "ancient shield"
	desc = "A gigantic, bronze reinforced shield that covers the entire body. An aasimar relic from an era long past."
	icon_state = "boeotian"
	possible_item_intents = list(/datum/intent/shield/bash/metal, /datum/intent/shield/block/metal)
	force = 20
	throwforce = 10
	throw_speed = 1
	throw_range = 3
	wlength = WLENGTH_NORMAL
	wbalance = -1 // Heavy, big shield
	resistance_flags = null
	flags_1 = CONDUCT_1
	wdefense = 8
	coverage = 75 // Rare shield from unique job, gets a tiny bit of additional coverage
	attacked_sound = list('sound/combat/parry/shield/metalshield (1).ogg','sound/combat/parry/shield/metalshield (2).ogg','sound/combat/parry/shield/metalshield (3).ogg')
	parrysound = list('sound/combat/parry/shield/metalshield (1).ogg','sound/combat/parry/shield/metalshield (2).ogg','sound/combat/parry/shield/metalshield (3).ogg')
	max_integrity = 500
	blade_dulling = DULLING_BASH
	sellprice = 150 // A noble collector would love to get their hands on one of these
	smeltresult = null // No bronze ingots yet

/obj/item/rogueweapon/shield/tower/hoplite/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -5,"sy" = -1,"nx" = 6,"ny" = -1,"wx" = 0,"wy" = -2,"ex" = 0,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 1,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.6,"sx" = 1,"sy" = 4,"nx" = 1,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = 0,"ey" = 2,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/obj/item/rogueweapon/shield/tower/metal
	name = "kite shield"
	desc = "A knightly, kite shaped steel shield, emblazoned with heraldry. \nBoasts superior coverage and durability, owed to its exquisite craftsmanship."
	icon_state = "ironsh"
	possible_item_intents = list(/datum/intent/shield/bash/metal, /datum/intent/shield/block/metal)
	force = 20
	throwforce = 10
	throw_speed = 1
	throw_range = 3
	wlength = WLENGTH_NORMAL
	resistance_flags = null
	flags_1 = CONDUCT_1
	wdefense = 7
	coverage = 70
	attacked_sound = list('sound/combat/parry/shield/metalshield (1).ogg','sound/combat/parry/shield/metalshield (2).ogg','sound/combat/parry/shield/metalshield (3).ogg')
	parrysound = list('sound/combat/parry/shield/metalshield (1).ogg','sound/combat/parry/shield/metalshield (2).ogg','sound/combat/parry/shield/metalshield (3).ogg')
	max_integrity = 500
	blade_dulling = DULLING_BASH
	sellprice = 30
	smeltresult = /obj/item/ingot/steel // Made with steel, let us repurpose it

/obj/item/rogueweapon/shield/tower/metal/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -5,"sy" = -1,"nx" = 6,"ny" = -1,"wx" = 0,"wy" = -2,"ex" = 0,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 1,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.6,"sx" = 1,"sy" = 4,"nx" = 1,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = 0,"ey" = 2,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)
	return ..()

/obj/item/rogueweapon/shield/tower/metal/attack_right(mob/user)
	if(!overlays.len)
		if(!('icons/roguetown/weapons/shield_heraldry.dmi' in GLOB.IconStates_cache))
			var/icon/J = new('icons/roguetown/weapons/shield_heraldry.dmi')
			var/list/istates = J.IconStates()
			GLOB.IconStates_cache |= icon
			GLOB.IconStates_cache['icons/roguetown/weapons/shield_heraldry.dmi'] = istates
		var/picked_name = input(user, "Choose a Heraldry", "VANDERLIN", name) as null|anything in sortList(GLOB.IconStates_cache['icons/roguetown/weapons/shield_heraldry.dmi'])
		if(!picked_name)
			picked_name = "none"
		var/mutable_appearance/M = mutable_appearance('icons/roguetown/weapons/shield_heraldry.dmi', picked_name)
		M.alpha = 190
		add_overlay(M)
		var/mutable_appearance/MU = mutable_appearance(icon, "ironsh_detail")
		MU.alpha = 90
		add_overlay(MU)
		if(alert("Are you pleased with your heraldry?", "Heraldry", "Yes", "No") != "Yes")
			cut_overlays()
	else
		..()

#undef SHIELD_BANG_COOLDOWN


/obj/item/rogueweapon/shield/tower/buckleriron
	name = "iron buckler"
	desc = "A small sized iron shield, popular among mercenaries due to it's light weight and ease of mobility."
	icon_state = "ironbuckler"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_BACK
	force = 10
	throwforce = 10
	dropshrink = 0.75
	throw_speed = 1
	throw_range = 3
	wlength = WLENGTH_NORMAL
	wbalance = 1 // small, tiny shield
	resistance_flags = FIRE_PROOF
	wdefense = 4
	coverage = 45
	attacked_sound = list('sound/combat/parry/shield/metalshield (1).ogg','sound/combat/parry/shield/metalshield (2).ogg','sound/combat/parry/shield/metalshield (3).ogg')
	parrysound = list('sound/combat/parry/shield/metalshield (1).ogg','sound/combat/parry/shield/metalshield (2).ogg','sound/combat/parry/shield/metalshield (3).ogg')
	max_integrity = 250
	smeltresult = /obj/item/ingot/iron // Made with an iron ingot, let us recover it

/obj/item/rogueweapon/shield/tower/buckleriron/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -5,"sy" = -1,"nx" = 6,"ny" = -1,"wx" = 0,"wy" = -2,"ex" = 0,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 1,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.6,"sx" = 1,"sy" = 4,"nx" = 1,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = 0,"ey" = 2,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/rogueweapon/shield/heater
	name = "heater shield"
	desc = "A sturdy wood and leather shield. Made to not be too encumbering while still providing good protection."
	icon_state = "heatershield"
	force = 15
	throwforce = 10
	dropshrink = 0.8
	coverage = 60
	attacked_sound = list('sound/combat/parry/shield/towershield (1).ogg','sound/combat/parry/shield/towershield (2).ogg','sound/combat/parry/shield/towershield (3).ogg')
	parrysound = list('sound/combat/parry/shield/towershield (1).ogg','sound/combat/parry/shield/towershield (2).ogg','sound/combat/parry/shield/towershield (3).ogg')
	max_integrity = 200

/obj/item/rogueweapon/shield/heater/attack_right(mob/user)
	if(!overlays.len)
		var/icon/J = new('icons/roguetown/weapons/heater_heraldry.dmi')
		var/list/istates = J.IconStates()
		var/picked_name = input(user, "Choose a Heraldry", "ROGUETOWN", name) as null|anything in sortList(istates)
		if(!picked_name)
			picked_name = "none"
		var/mutable_appearance/M = mutable_appearance('icons/roguetown/weapons/heater_heraldry.dmi', picked_name)
		M.alpha = 178
		add_overlay(M)
		var/mutable_appearance/MU = mutable_appearance(icon, "heatershield_detail")
		MU.alpha = 114
		add_overlay(MU)
		if(alert("Are you pleased with your heraldry?", "Heraldry", "Yes", "No") != "Yes")
			cut_overlays()
	else
		..()

/obj/item/rogueweapon/shield/heater/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -5,"sy" = -1,"nx" = 6,"ny" = -1,"wx" = 0,"wy" = -2,"ex" = 0,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.6,"sx" = 1,"sy" = 4,"nx" = 1,"ny" = 2,"wx" = 3,"wy" = 3,"ex" = 0,"ey" = 2,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)
