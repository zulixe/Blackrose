/datum/antagonist/zombie
	name = "Zombie"	// Deadite plague of Zizo
	antagpanel_category = "Zombie"
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "zombie"
	show_in_roundend = FALSE
	/// SET TO FALSE IF WE DON'T TURN INTO ROTMEN WHEN REMOVED
	var/become_rotman = FALSE
	var/zombie_start
	var/revived = FALSE
	var/next_idle_sound
	// CACHE VARIABLES SO ZOMBIFICATION CAN BE CURED
	var/was_i_undead = FALSE
	var/special_role
	var/ambushable = TRUE
	var/soundpack_m
	var/soundpack_f
	var/oldSTASTR
	var/oldSTASPD
	var/oldSTAINT
	var/oldSTACON
	var/old_cmode_music
	var/list/base_intents
	var/datum/language_holder/prev_language
	var/datum/patron/patron
	var/stored_skills
	var/stored_experience
	/// Whether or not we have been turned
	var/has_turned = FALSE
	/// Traits applied to the owner mob when we turn into a zombie
	var/static/list/traits_zombie = list(
		TRAIT_NOSTAMINA,
		TRAIT_NOMOOD,
		TRAIT_NOLIMBDISABLE,
		TRAIT_NOHUNGER,
		TRAIT_EASYDISMEMBER,
		TRAIT_CRITICAL_WEAKNESS,
		TRAIT_NOPAIN,
		TRAIT_NOBREATH,
		TRAIT_TOXIMMUNE,
		TRAIT_CHUNKYFINGERS,
		TRAIT_NOSLEEP,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SPELLBLOCK,
		TRAIT_BLOODLOSS_IMMUNE,
		TRAIT_ZOMBIE_SPEECH,
		TRAIT_ZOMBIE_IMMUNE,
		TRAIT_ROTMAN,
	)
	/// Traits applied to the owner when we are cured and turn into just "rotmen"
	var/static/list/traits_rotman = list(
		TRAIT_EASYDISMEMBER,
		TRAIT_CRITICAL_WEAKNESS,
		TRAIT_NOPAIN,
		TRAIT_NOPAINSTUN,
		TRAIT_NOBREATH,
		TRAIT_TOXIMMUNE,
		TRAIT_ZOMBIE_IMMUNE,
		TRAIT_ROTMAN,
	)
	var/mutable_appearance/rotflies

/datum/antagonist/zombie/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/vampirelord))
		var/datum/antagonist/vampirelord/V = examined_datum
		if(!V.disguised)
			return "<span class='boldnotice'>Another kind of deadite.</span>"
	if(istype(examined_datum, /datum/antagonist/zombie))
		return "<span class='boldnotice'>Another deadite. My ally.</span>"
	if(istype(examined_datum, /datum/antagonist/skeleton))
		return "<span class='boldnotice'>Another kind of deadite.</span>"

/datum/antagonist/zombie/on_gain()
	var/mob/living/carbon/human/zombie = owner?.current
	if(zombie)
		var/obj/item/bodypart/head = zombie.get_bodypart(BODY_ZONE_HEAD)
		if(!head)
			qdel(src)
			return
	zombie_start = world.time
	was_i_undead = zombie.mob_biotypes & MOB_UNDEAD
	special_role = zombie.mind?.special_role
	ambushable = zombie.ambushable
	if(zombie.dna?.species)
		soundpack_m = zombie.dna.species.soundpack_m
		soundpack_f = zombie.dna.species.soundpack_f
		rotflies = mutable_appearance('icons/roguetown/mob/rotten.dmi', "deadite")
		zombie.add_overlay(rotflies)
	base_intents = zombie.base_intents
	oldSTASTR = zombie.STASTR
	oldSTASPD = zombie.STASPD
	oldSTAINT = zombie.STAINT
	oldSTACON = zombie.STACON
	zombie.change_stat(STATKEY_STR, 7, TRUE)
	zombie.change_stat(STATKEY_SPD, 2, TRUE)
	zombie.change_stat(STATKEY_INT, 1, TRUE)
	zombie.change_stat(STATKEY_CON, 5, TRUE)
	old_cmode_music = zombie.cmode_music
	patron = zombie.patron
	stored_skills = owner.known_skills.Copy()
	stored_experience = owner.skill_experience.Copy()
	owner.known_skills = list()
	owner.skill_experience = list()
	zombie.cmode_music ='sound/music/cmode/combat_weird.ogg'
	zombie.vitae_pool = 0 // Deadites have no vitae to drain from
	var/datum/language_holder/mob_language = zombie.get_language_holder()
	prev_language = mob_language.copy()
	zombie.remove_all_languages()
	zombie.grant_language(/datum/language/hellspeak)

	return ..()

/datum/antagonist/zombie/on_removal()
	var/mob/living/carbon/human/zombie = owner?.current
	if(!zombie)
		return

	zombie.cut_overlay(rotflies)
	zombie.verbs -= /mob/living/carbon/human/proc/zombie_seek
	zombie.mind?.special_role = special_role
	zombie.ambushable = ambushable
	if(zombie.dna?.species)
		zombie.dna.species.soundpack_m = soundpack_m
		zombie.dna.species.soundpack_f = soundpack_f
	zombie.base_intents = base_intents
	zombie.update_a_intents()
	zombie.aggressive = FALSE
	zombie.mode = AI_OFF
	if(zombie.charflaw)
		zombie.charflaw.ephemeral = FALSE
	zombie.update_body()
	zombie.change_stat(STATKEY_STR, oldSTASTR - 6)
	zombie.change_stat(STATKEY_SPD, oldSTASPD - 2)
	zombie.change_stat(STATKEY_INT, oldSTAINT - 1)
	zombie.change_stat(STATKEY_CON, oldSTACON - 5)
	zombie.cmode_music = old_cmode_music
	zombie.set_patron(patron)
	owner.known_skills = stored_skills
	owner.skill_experience = stored_experience
	for(var/trait in traits_zombie)
		REMOVE_TRAIT(zombie, trait, "[type]")
	zombie.remove_client_colour(/datum/client_colour/monochrome)
	if(has_turned && become_rotman)
		zombie.change_stat(STATKEY_CON, -5)
		zombie.change_stat(STATKEY_SPD, -5)
		zombie.change_stat(STATKEY_INT, -3)
		for(var/trait in traits_rotman)
			ADD_TRAIT(zombie, trait, "[type]")
		to_chat(zombie, "<span class='green'>I no longer crave for flesh... <i>But I still feel ill.</i></span>")
	else
		if(!was_i_undead)
			zombie.mob_biotypes &= ~MOB_UNDEAD
		zombie.faction -= "undead"
		zombie.faction += "station"
		zombie.faction += "neutral"
		zombie.regenerate_organs()
		if(has_turned)
			to_chat(zombie, "<span class='green'>I no longer crave for flesh...</span>")
	for(var/obj/item/bodypart/zombie_part as anything in zombie.bodyparts)
		zombie_part.rotted = FALSE
		zombie_part.update_disabled()
		zombie_part.update_limb()
	zombie.update_body()
	zombie.remove_language(/datum/language/hellspeak)
	zombie.copy_known_languages_from(prev_language)

	// Bandaid to fix the zombie ghostizing not allowing you to re-enter
	var/mob/dead/observer/ghost = zombie.get_ghost(TRUE)
	if(ghost)
		ghost.can_reenter_corpse = TRUE
	return ..()

/datum/antagonist/zombie/proc/transform_zombie()
	var/mob/living/carbon/human/zombie = owner.current
	if(!zombie)
		qdel(src)
		return
	var/obj/item/bodypart/head = zombie.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		qdel(src)
		return
	revived = TRUE //so we can die for real later
	zombie.add_client_colour(/datum/client_colour/monochrome)
	for(var/trait_applied in traits_zombie)
		ADD_TRAIT(zombie, trait_applied, "[type]")
	if(HAS_TRAIT(zombie, TRAIT_DODGEEXPERT))
		REMOVE_TRAIT(zombie, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	if(zombie.mind)
		special_role = zombie.mind.special_role
		zombie.mind.special_role = name
	if(zombie.dna?.species)
		soundpack_m = zombie.dna.species.soundpack_m
		soundpack_f = zombie.dna.species.soundpack_f
		zombie.dna.species.soundpack_m = new /datum/voicepack/zombie/m()
		zombie.dna.species.soundpack_f = new /datum/voicepack/zombie/f()
	base_intents = zombie.base_intents
	zombie.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, /datum/intent/unarmed/claw)
	zombie.update_a_intents()
	zombie.aggressive = TRUE
	zombie.mode = AI_IDLE

	var/obj/item/organ/eyes/eyes = new /obj/item/organ/eyes/night_vision/zombie
	eyes.Insert(zombie, drop_if_replaced = FALSE)
	ambushable = zombie.ambushable
	zombie.ambushable = FALSE

	if(zombie.charflaw)
		zombie.charflaw.ephemeral = TRUE
	zombie.mob_biotypes |= MOB_UNDEAD
	zombie.faction += "undead"
	zombie.faction -= "station"
	zombie.faction -= "neutral"
	zombie.verbs |= /mob/living/carbon/human/proc/zombie_seek
	for(var/obj/item/bodypart/zombie_part as anything in zombie.bodyparts)
		if(!zombie_part.rotted && !zombie_part.skeletonized)
			zombie_part.rotted = TRUE
		zombie_part.update_disabled()
	zombie.update_body()
	zombie.cmode_music = 'sound/music/cmode/combat_weird.ogg'
	zombie.set_patron(/datum/patron/inhumen/zizo)

	zombie.vitae_pool = 0 // Again, just in case.

	// zombies cant rp, thus shouldnt be playable for most people
	zombie.ghostize()

/datum/antagonist/zombie/greet()
	to_chat(owner.current, "<span class='userdanger'>Death is not the end...</span>")
	return ..()

/datum/antagonist/zombie/on_life(mob/user)
	if(!user)
		return
	if(user.stat == DEAD)
		return
	var/mob/living/carbon/human/zombie = user
	if(world.time > next_idle_sound)
		zombie.emote("zmoan")
		next_idle_sound = world.time + rand(20 SECONDS, 40 SECONDS)

//Infected wake param is just a transition from living to zombie, via zombie_infect()
//Previously you just died without warning in 3 minutes, now you just become an antag
/datum/antagonist/zombie/proc/wake_zombie(infected_wake = FALSE)
	testing("WAKEZOMBIE")
	if(!owner.current)
		return
	var/mob/living/carbon/human/zombie = owner.current
	if(!zombie || !istype(zombie))
		return
	var/obj/item/bodypart/head = zombie.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		qdel(src)
		return
	if(zombie.stat != DEAD && !infected_wake)
		qdel(src)
		return
	if(istype(zombie.loc, /obj/structure/closet/dirthole) || istype(zombie.loc, /obj/structure/closet/crate/coffin))
		qdel(src)
		return

	zombie.blood_volume = BLOOD_VOLUME_MAXIMUM
	zombie.setOxyLoss(0, updating_health = FALSE, forced = TRUE) //zombles dont breathe
	zombie.setToxLoss(0, updating_health = FALSE, forced = TRUE) //zombles are immune to poison
	if(!infected_wake) //if we died, heal all of this too
		zombie.adjustBruteLoss(-INFINITY, updating_health = FALSE, forced = TRUE)
		zombie.adjustFireLoss(-INFINITY, updating_health = FALSE, forced = TRUE)
		zombie.heal_wounds(INFINITY) //Heal every wound that is not permanent
	zombie.stat = UNCONSCIOUS //Start unconscious
	zombie.updatehealth() //then we check if the mob should wake up
	zombie.update_mobility()
	zombie.update_sight()
	zombie.reload_fullscreen()
	transform_zombie()
	if(zombie.stat >= DEAD)
		//could not revive
		qdel(src)

/mob/living/carbon/human/proc/zombie_seek()
	set name = "Seek Brains"
	set category = "ZOMBIE"

	if(!mind.has_antag_datum(/datum/antagonist/zombie))
		return FALSE
	if(stat >= UNCONSCIOUS)
		return FALSE
	var/closest_dist
	var/the_dir
	for(var/mob/living/carbon/human/humie as anything in GLOB.human_list)
		if(humie == src)
			continue
		if(humie.mob_biotypes & MOB_UNDEAD)
			continue
		if(humie.stat >= DEAD)
			continue
		var/total_distance = get_dist(src, humie)
		if(!closest_dist)
			closest_dist = total_distance
			the_dir = get_dir(src, humie)
		else
			if(total_distance < closest_dist)
				closest_dist = total_distance
				the_dir = get_dir(src, humie)
	if(!closest_dist)
		to_chat(src, "<span class='warning'>I failed to smell anything...</span>")
		return FALSE
	to_chat(src, "<span class='warning'>[closest_dist] meters away, [dir2text(the_dir)]...</span>")
	return TRUE

/**
 * This occurs when one zombie infects a living human, going into instadeath from here is kind of shit and confusing
 * We instead just transform at the end
 */
/mob/living/carbon/human/proc/zombie_infect_attempt()
	if(!prob(7))
		return
	var/datum/antagonist/zombie/zombie_antag = zombie_check()
	if(!zombie_antag)
		return
	if(stat >= DEAD) //do shit the natural way i guess
		return
	to_chat(src, "<span class='danger'>I feel horrible... REALLY horrible after that...</span>")
	if(blood_volume)
		mob_timers["puke"] = world.time
		vomit(1, blood = TRUE, stun = FALSE)
	addtimer(CALLBACK(src, PROC_REF(wake_zombie)), 1 MINUTES)
	return zombie_antag

/mob/living/carbon/human/proc/wake_zombie()
	var/datum/antagonist/zombie/zombie_antag = mind?.has_antag_datum(/datum/antagonist/zombie)
	if(!zombie_antag)
		return FALSE
	flash_fullscreen("redflash3")
	to_chat(src, "<span class='danger'>It hurts... Is this really the end for me?</span>")
	emote("scream") // heres your warning to others bro
	Knockdown(1)
	zombie_antag.wake_zombie(TRUE)

	return TRUE
