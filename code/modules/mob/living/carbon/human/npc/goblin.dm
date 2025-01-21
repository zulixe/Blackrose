/mob/living/carbon/human/species/goblin
	name = "goblin"

	icon = 'icons/roguetown/mob/monster/goblins.dmi'
	icon_state = "goblin"
	race = /datum/species/goblin
	gender = MALE
	bodyparts = list(/obj/item/bodypart/chest/goblin, /obj/item/bodypart/head/goblin, /obj/item/bodypart/l_arm/goblin,
					/obj/item/bodypart/r_arm/goblin, /obj/item/bodypart/r_leg/goblin, /obj/item/bodypart/l_leg/goblin)
	rot_type = /datum/component/rot/corpse/goblin
	var/gob_outfit = /datum/outfit/job/roguetown/npc/goblin
	ambushable = FALSE
	base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, /datum/intent/unarmed/claw)
	a_intent = INTENT_HELP
	possible_mmb_intents = list(INTENT_STEAL, INTENT_JUMP, INTENT_KICK, INTENT_BITE)
	possible_rmb_intents = list(/datum/rmb_intent/feint, /datum/rmb_intent/swift, /datum/rmb_intent/riposte, /datum/rmb_intent/weak)
	flee_in_pain = TRUE
	stand_attempts = 6
	vitae_pool = 250 // Small, frail creechers with not so much vitality to gain from.

/mob/living/carbon/human/species/goblin/npc
	aggressive=1
	mode = AI_IDLE
	dodgetime = 30 //they can dodge easily, but have a cooldown on it
	flee_in_pain = TRUE

	wander = FALSE

/mob/living/carbon/human/species/goblin/npc/ambush
	simpmob_attack = 35
	simpmob_defend = 25
	wander = TRUE
	attack_speed = 2

/mob/living/carbon/human/species/goblin/hell
	name = "hell goblin"
	race = /datum/species/goblin/hell

/mob/living/carbon/human/species/goblin/npc/hell
	race = /datum/species/goblin/hell

/mob/living/carbon/human/species/goblin/npc/ambush/hell
	race = /datum/species/goblin/hell

/datum/species/goblin/hell
	name = "hell goblin"
	id = "goblin_hell"
	raceicon = "goblin_hell"

/mob/living/carbon/human/species/goblin/cave
	name = "cave goblin"
	race = /datum/species/goblin/cave

/mob/living/carbon/human/species/goblin/npc/cave
	race = /datum/species/goblin/cave

/mob/living/carbon/human/species/goblin/npc/ambush/cave
	race = /datum/species/goblin/cave

/datum/species/goblin/cave
	id = "goblin_cave"
	raceicon = "goblin_cave"

/mob/living/carbon/human/species/goblin/sea
	name = "sea goblin"
	race = /datum/species/goblin/sea
/mob/living/carbon/human/species/goblin/npc/sea
	race = /datum/species/goblin/sea
/mob/living/carbon/human/species/goblin/npc/ambush/sea
	race = /datum/species/goblin/sea
/datum/species/goblin/sea
	raceicon = "goblin_sea"
	id = "goblin_sea"

/mob/living/carbon/human/species/goblin/moon
	name = "moon goblin"
	race = /datum/species/goblin/moon
/mob/living/carbon/human/species/goblin/npc/moon
	race = /datum/species/goblin/moon
/mob/living/carbon/human/species/goblin/npc/ambush/moon
	race = /datum/species/goblin/moon
/datum/species/goblin/moon
	id = "goblin_moon"
	raceicon = "goblin_moon"

/datum/species/goblin/moon/spec_death(gibbed, mob/living/carbon/human/H)
	new /obj/item/reagent_containers/powder/moondust_purest(get_turf(H))
	H.visible_message("<span class='blue'>Moondust falls from [H]!</span>")
//	qdel(H)

/obj/item/bodypart/chest/goblin
	dismemberable = 0
/obj/item/bodypart/l_arm/goblin
	dismemberable = 0
/obj/item/bodypart/r_arm/goblin
	dismemberable = 0
/obj/item/bodypart/r_leg/goblin
	dismemberable = 0
/obj/item/bodypart/l_leg/goblin
	dismemberable = 0

/obj/item/bodypart/head/goblin/update_icon_dropped()
	return

/obj/item/bodypart/head/goblin/get_limb_icon(dropped, hideaux = FALSE)
	return

/obj/item/bodypart/head/goblin/skeletonize()
	. = ..()
	icon_state = "goblin_skel_head"
	sellprice = 2



/datum/species/goblin
	name = "goblin"
	id = "goblin"
	species_traits = list(NO_UNDERWEAR,NOEYESPRITES)
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE, TRAIT_EASYDISMEMBER, TRAIT_CRITICAL_WEAKNESS, TRAIT_NASTY_EATER, TRAIT_LEECHIMMUNE, TRAIT_INHUMENCAMP)
	no_equip = list(SLOT_SHIRT, SLOT_WEAR_MASK, SLOT_GLOVES, SLOT_SHOES, SLOT_PANTS, SLOT_S_STORE)
	nojumpsuit = 1
	sexes = 1
	offset_features = list(OFFSET_HANDS = list(0,-4), OFFSET_HANDS_F = list(0,-4))
	damage_overlay_type = ""
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	var/raceicon = "goblin"

/datum/species/goblin/regenerate_icons(mob/living/carbon/human/H)
//	H.cut_overlays()
	H.icon_state = ""
	if(H.notransform)
		return 1
	H.update_inv_hands()
	H.update_inv_handcuffed()
	H.update_inv_legcuffed()
	H.update_fire()
	H.update_body()
	var/mob/living/carbon/human/species/goblin/G = H
	G.update_wearable()
	H.update_transform()
	return TRUE

/mob/living/carbon/human/species/goblin/update_body()
	remove_overlay(BODY_LAYER)
	if(!dna || !dna.species)
		return
	var/datum/species/goblin/G = dna.species
	if(!istype(G))
		return
	icon_state = ""
	var/list/standing = list()
	var/mutable_appearance/body_overlay
	var/obj/item/bodypart/chesty = get_bodypart("chest")
	var/obj/item/bodypart/headdy = get_bodypart("head")
	if(!headdy)
		if(chesty && chesty.skeletonized)
			body_overlay = mutable_appearance(icon, "goblin_skel_decap", -BODY_LAYER)
		else
			body_overlay = mutable_appearance(icon, "[G.raceicon]_decap", -BODY_LAYER)
	else
		if(chesty && chesty.skeletonized)
			body_overlay = mutable_appearance(icon, "goblin_skel", -BODY_LAYER)
		else
			body_overlay = mutable_appearance(icon, "[G.raceicon]", -BODY_LAYER)

	if(body_overlay)
		standing += body_overlay
	if(standing.len)
		overlays_standing[BODY_LAYER] = standing

	apply_overlay(BODY_LAYER)
	dna.species.update_damage_overlays()

/mob/living/carbon/human/species/goblin/proc/update_wearable()
	remove_overlay(ARMOR_LAYER)

	var/list/standing = list()
	var/mutable_appearance/body_overlay
	if(wear_armor)
		body_overlay = mutable_appearance(icon, "[wear_armor.item_state]", -ARMOR_LAYER)
		if(body_overlay)
			standing += body_overlay
	if(head)
		body_overlay = mutable_appearance(icon, "[head.item_state]", -ARMOR_LAYER)
		if(body_overlay)
			standing += body_overlay
	if(standing.len)
		overlays_standing[ARMOR_LAYER] = standing

	apply_overlay(ARMOR_LAYER)

/mob/living/carbon/human/species/goblin/update_inv_head()
	update_wearable()
/mob/living/carbon/human/species/goblin/update_inv_armor()
	update_wearable()

/datum/species/goblin/update_damage_overlays(mob/living/carbon/human/H)
	return

/mob/living/carbon/human/species/goblin/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)

/mob/living/carbon/human/species/goblin/handle_combat()
	if(mode == AI_HUNT)
		if(prob(2))
			emote("laugh")
	. = ..()

/mob/living/carbon/human/species/goblin/after_creation()
	..()
	gender = MALE
	if(src.dna && src.dna.species)
		src.dna.species.soundpack_m = new /datum/voicepack/goblin()
		src.dna.species.soundpack_f = new /datum/voicepack/goblin()
		var/obj/item/headdy = get_bodypart("head")
		if(headdy)
			headdy.icon = 'icons/roguetown/mob/monster/goblins.dmi'
			headdy.icon_state = "[src.dna.species.id]_head"
			headdy.sellprice = rand(7,20)
	var/obj/item/organ/eyes/eyes = src.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.Remove(src,1)
		QDEL_NULL(eyes)
	eyes = new /obj/item/organ/eyes/night_vision/nightmare
	eyes.Insert(src)
	src.underwear = "Nude"
	if(src.charflaw)
		QDEL_NULL(src.charflaw)
	update_body()
	faction = list("orcs")
	name = "goblin"
	real_name = "goblin"
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_CRITICAL_WEAKNESS, TRAIT_GENERIC)
//	ADD_TRAIT(src, TRAIT_NOBREATH, TRAIT_GENERIC)
//	blue breathes underwater, need a new specific one for this maybe organ cheque
//	ADD_TRAIT(src, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	if(gob_outfit)
		var/datum/outfit/O = new gob_outfit
		if(O)
			equipOutfit(O)

/datum/component/rot/corpse/goblin/process()
	var/amt2add = 10 //1 second
	if(last_process)
		amt2add = ((world.time - last_process)/10) * amt2add
	last_process = world.time
	amount += amt2add
	var/mob/living/carbon/C = parent
	if(!C)
		qdel(src)
		return
	if(C.stat != DEAD)
		qdel(src)
		return
	var/should_update = FALSE
	if(amount > 20 MINUTES)
		for(var/obj/item/bodypart/B in C.bodyparts)
			if(!B.skeletonized)
				B.skeletonized = TRUE
				should_update = TRUE
	else if(amount > 12 MINUTES)
		for(var/obj/item/bodypart/B in C.bodyparts)
			if(!B.rotted)
				B.rotted = TRUE
				should_update = TRUE
			if(B.rotted && amount < 16 MINUTES)
				var/turf/open/T = C.loc
				if(istype(T))
					T.pollute_turf(/datum/pollutant/rot, 10)
	if(should_update)
		if(amount > 20 MINUTES)
			C.update_body()
			qdel(src)
			return
		else if(amount > 12 MINUTES)
			C.update_body()

/////
////
////
//// OUTFGITS						//////////////////
////
///

/datum/outfit/job/roguetown/npc/goblin/pre_equip(mob/living/carbon/human/H)
	..()
	H.TOTALSTR = rand(6, 10)
	H.TOTALPER = rand(5, 10)
	H.TOTALINT = rand(1, 4)
	H.TOTALCON = rand(4, 8)
	H.TOTALEND = rand(8, 12)
	H.TOTALSPD = rand(8, 14)
	if(is_species(H, /datum/species/goblin/hell))
		H.STASTR += 6
		H.STACON += 6
		H.STASPD -= 4
		H.simpmob_attack += 10
		H.simpmob_defend += 15
	if(is_species(H, /datum/species/goblin/cave))
		H.STAPER += 6
		H.STAEND += 2
	if(is_species(H, /datum/species/goblin/sea))
		H.STAINT += 6
		H.STAEND += 2
	if(is_species(H, /datum/species/goblin/moon))
		H.STAINT += 4
		H.STASPD += 4
		H.simpmob_attack += 10
		H.simpmob_defend += 25
	var/loadout = rand(1,5)
	switch(loadout)
		if(1) //tribal spear
			r_hand = /obj/item/rogueweapon/polearm/spear/stone
			armor = /obj/item/clothing/suit/roguetown/armor/leather/hide/goblin
		if(2) //tribal axe
			r_hand = /obj/item/rogueweapon/axe/stone
			armor = /obj/item/clothing/suit/roguetown/armor/leather/hide/goblin
		if(3) //tribal club
			r_hand = /obj/item/rogueweapon/mace/woodclub
			armor = /obj/item/clothing/suit/roguetown/armor/leather/hide/goblin
			if(prob(10))
				head = /obj/item/clothing/head/roguetown/helmet/leather/goblin
		if(4) //lightly armored sword/flail/daggers
			H.simpmob_attack += 25
			H.simpmob_defend += 10
			if(prob(50))
				r_hand = /obj/item/rogueweapon/sword/iron
			else
				r_hand = /obj/item/rogueweapon/mace/spiked
			if(prob(30))
				l_hand = /obj/item/rogueweapon/shield/wood
			if(prob(23))
				r_hand = /obj/item/rogueweapon/knife/stone
				l_hand = /obj/item/rogueweapon/knife/stone
			armor = /obj/item/clothing/suit/roguetown/armor/leather/goblin
			if(prob(80))
				head = /obj/item/clothing/head/roguetown/helmet/leather/goblin
		if(5) //heavy armored sword/flail/shields
			H.simpmob_attack += 45
			H.simpmob_defend += 25
			ADD_TRAIT(src, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
			if(prob(30))
				armor = /obj/item/clothing/suit/roguetown/armor/cuirass/iron/goblin
			else
				armor = /obj/item/clothing/suit/roguetown/armor/leather/goblin
			if(prob(80))
				head = /obj/item/clothing/head/roguetown/helmet/goblin
			else
				head = /obj/item/clothing/head/roguetown/helmet/leather/goblin
			if(prob(50))
				r_hand = /obj/item/rogueweapon/sword/iron
			else
				r_hand = /obj/item/rogueweapon/mace/spiked
			if(prob(20))
				r_hand = /obj/item/rogueweapon/flail
			l_hand = /obj/item/rogueweapon/shield/wood


////
////
/// INVADER ZIM
///
///
///


/obj/structure/gob_portal
	name = "Gob Portal"
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "shitportal"
	max_integrity = 200
	anchored = TRUE
	density = FALSE
	layer = BELOW_OBJ_LAYER
	var/gobs = 0
	var/maxgobs = 3
	var/datum/looping_sound/boneloop/soundloop
	var/spawning = FALSE
	var/moon_goblins = 0
	attacked_sound = 'sound/vo/mobs/ghost/skullpile_hit.ogg'

/obj/structure/gob_portal/Initialize()
	. = ..()
	soundloop = new(src, FALSE)
	soundloop.start()
	spawn_gob()

/obj/structure/gob_portal/attack_ghost(mob/dead/observer/user)
	if(QDELETED(user))
		return
	if(!in_range(src, user))
		return
	if(gobs >= (maxgobs+1))
		to_chat(user, "<span class='danger'>Too many Gobs.</span>")
		return
	gobs++
	var/mob/living/carbon/human/species/goblin/npc/N = new (get_turf(src))
	N.key = user.key
	qdel(user)


/obj/structure/gob_portal/proc/creategob()
	if(QDELETED(src))
		return
	if(!spawning)
		return
	spawning = FALSE
	if(moon_goblins == 0)
		if(GLOB.tod == "night")
			if(prob(30))
				moon_goblins = 1
			else
				moon_goblins = 2
	if(moon_goblins == 1)
		new /mob/living/carbon/human/species/goblin/npc/moon(get_turf(src))
	else
		new /mob/living/carbon/human/species/goblin/npc(get_turf(src))
	gobs++
	update_icon()
	if(living_player_count() < 10)
		maxgobs = 1
	if(gobs < maxgobs)
		spawn_gob()

/obj/structure/gob_portal/proc/spawn_gob()
	if(QDELETED(src))
		return
	if(spawning)
		return
	spawning = TRUE
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(creategob)), 2 SECONDS)

/obj/structure/gob_portal/Destroy()
	soundloop.stop()
	. = ..()
