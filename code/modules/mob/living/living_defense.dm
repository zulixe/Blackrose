
/mob/living/proc/run_armor_check(def_zone = null, attack_flag = "blunt", absorb_text = null, soften_text = null, armor_penetration, penetrated_text, damage, blade_dulling)
	var/armor = getarmor(def_zone, attack_flag, damage, armor_penetration, blade_dulling)

	//the if "armor" check is because this is used for everything on /living, including humans
	if(armor > 0 && armor_penetration)
		armor = max(0, armor - armor_penetration)
		if(penetrated_text)
			to_chat(src, "<span class='danger'>[penetrated_text]</span>")
		else
			to_chat(src, "<span class='danger'>My armor was penetrated!</span>")
	else if(armor >= 130)
		if(absorb_text)
			to_chat(src, "<span class='notice'>[absorb_text]</span>")
		else
			to_chat(src, "<span class='notice'>My armor absorbs the blow!</span>")
	else if(armor > 0)
		if(soften_text)
			to_chat(src, "<span class='warning'>[soften_text]</span>")
		else
			to_chat(src, "<span class='warning'>My armor softens the blow!</span>")
	return armor


/mob/living/proc/getarmor(def_zone, type, damage, armor_penetration, blade_dulling)
	return 0

//this returns the mob's protection against eye damage (number between -1 and 2) from bright lights
/mob/living/proc/get_eye_protection()
	return 0

//this returns the mob's protection against ear damage (0:no protection; 1: some ear protection; 2: has no ears)
/mob/living/proc/get_ear_protection()
	return 0

/mob/living/proc/is_mouth_covered(head_only = 0, mask_only = 0)
	return FALSE

/mob/living/proc/is_eyes_covered(check_glasses = 1, check_head = 1, check_mask = 1)
	return FALSE
/mob/living/proc/is_pepper_proof(check_head = TRUE, check_mask = TRUE)
	return FALSE
/mob/living/proc/on_hit(obj/projectile/P)
	return BULLET_ACT_HIT

/mob/living/bullet_act(obj/projectile/P, def_zone = BODY_ZONE_CHEST)
	if(!prob(P.accuracy + P.bonus_accuracy)) //if your accuracy check fails, you wont hit your intended target
		def_zone = ran_zone(BODY_ZONE_CHEST, 65)//Hits a random part of the body, geared towards the chest

	var/armor = run_armor_check(def_zone, P.flag, "", "",P.armor_penetration, damage = P.damage)

	next_attack_msg.Cut()

	var/on_hit_state = P.on_hit(src, armor)
	var/nodmg = FALSE
	if(!P.nodamage && on_hit_state != BULLET_ACT_BLOCK)
		if(!apply_damage(P.damage, P.damage_type, def_zone, armor))
			nodmg = TRUE
			next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
		apply_effects(P.stun, 0, 0, 0,0, 0, 0, 0, armor, P.jitter, P.paralyze, 0)
		if(!nodmg)
			if(P.dismemberment)
				check_projectile_dismemberment(P, def_zone,armor)
			if(P.woundclass)
				check_projectile_wounding(P, def_zone)
			if(P.embedchance && !check_projectile_embed(P, def_zone))
				P.handle_drop()
		else
			P.handle_drop()

	var/organ_hit_text = ""
	var/limb_hit = check_limb_hit(def_zone)//to get the correct message info.
	if(limb_hit)
		organ_hit_text = " in \the [parse_zone(limb_hit)]"
	if(P.hitsound && !nodmg)
		var/volume = P.vol_by_damage()
		playsound(loc, pick(P.hitsound), volume, TRUE, -1)
	visible_message("<span class='danger'>[src] is hit by \a [P][organ_hit_text]![next_attack_msg.Join()]</span>", \
			"<span class='danger'>I'm hit by \a [P][organ_hit_text]![next_attack_msg.Join()]</span>", null, COMBAT_MESSAGE_RANGE)
	next_attack_msg.Cut()


	return on_hit_state ? BULLET_ACT_HIT : BULLET_ACT_BLOCK

/mob/living/proc/check_projectile_dismemberment(obj/projectile/P, def_zone)
	return 0

/mob/living/proc/check_projectile_wounding(obj/projectile/P, def_zone)
	return simple_woundcritroll(P.woundclass, P.damage, null, def_zone, crit_message = TRUE)

/mob/living/proc/check_projectile_embed(obj/projectile/P, def_zone)
	if(!prob(P.embedchance) || !P.dropped)
		return FALSE
	simple_add_embedded_object(P.dropped, crit_message = TRUE)
	return TRUE

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
	if(throwforce && w_class)
		return CLAMP((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
	else if(w_class)
		return CLAMP(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
	else
		return 0

/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum, damage_type = "blunt")
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		var/zone = ran_zone(BODY_ZONE_CHEST, 65)//Hits a random part of the body, geared towards the chest
		SEND_SIGNAL(I, COMSIG_MOVABLE_IMPACT_ZONE, src, zone)
		if(!blocked)
			var/armor = run_armor_check(zone, damage_type, "", "",I.armor_penetration, damage = I.throwforce)
			next_attack_msg.Cut()
			var/nodmg = FALSE
			if(!apply_damage(I.throwforce, damage_type, zone, armor))
				nodmg = TRUE
				next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
			if(!nodmg)
				if(iscarbon(src))
					var/obj/item/bodypart/affecting = get_bodypart(zone)
					if(affecting)
						var/throwee = null
						if(throwingdatum)
							throwee = isliving(throwingdatum.thrower) ? throwingdatum.thrower : null
						affecting.bodypart_attacked_by(I.thrown_bclass, I.throwforce, throwee, affecting.body_zone, crit_message = TRUE)
				else
					simple_woundcritroll(I.thrown_bclass, I.throwforce, null, zone, crit_message = TRUE)
					if(((throwingdatum ? throwingdatum.speed : I.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || I.embedding.embedded_ignore_throwspeed_threshold)
						if(can_embed(I) && prob(I.embedding.embed_chance) && HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS) && !HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
							simple_add_embedded_object(I, silent = FALSE, crit_message = TRUE)
			visible_message("<span class='danger'>[src] is hit by [I]![next_attack_msg.Join()]</span>", \
							"<span class='danger'>I'm hit by [I]![next_attack_msg.Join()]</span>")
			next_attack_msg.Cut()
			if(I.thrownby)
				log_combat(I.thrownby, src, "threw and hit", I)
		else
			return 1
	else
		playsound(loc, 'sound/blank.ogg', 50, TRUE, -1) //Item sounds are handled in the item itself
	..()

/mob/living/fire_act(added, maxstacks)
	if(added > 20)
		added = 20
	if(maxstacks > 20)
		maxstacks = 20
	if(!maxstacks)
		maxstacks = 1
	if(maxstacks)
		if(fire_stacks >= maxstacks)
			return
	if(added)
		adjust_fire_stacks(added)
	else
		adjust_fire_stacks(1)
	IgniteMob()

/mob/living/proc/grabbedby(mob/living/carbon/user, supress_message = FALSE, item_override)
	if(!user || !src || anchored || !isturf(user.loc))
		return FALSE

	if(!user.pulling || user.pulling == src)
		user.start_pulling(src, supress_message = supress_message, item_override = item_override)
		return
/*
	if(!(status_flags & CANPUSH) || HAS_TRAIT(src, TRAIT_PUSHIMMUNE))
		to_chat(user, "<span class='warning'>[src] can't be grabbed more aggressively!</span>")
		return FALSE

	if(user.grab_state >= GRAB_AGGRESSIVE && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>I don't want to risk hurting [src]!</span>")
		return FALSE
	grippedby(user)*/

//proc to upgrade a simple pull into a more aggressive grab.
/mob/living/proc/grippedby(mob/living/carbon/user, instant = FALSE)
	user.changeNext_move(CLICK_CD_GRABBING)

	if(user == src)
		instant = TRUE

//	if(user.pulling != src)
//		return

	var/probby =  20 - ((user.STACON - STACON) * 10)
	if(src.pulling == user && !instant)
		probby += 30

	if(src.dir == turn(get_dir(src,user), 180))
		probby = (probby - 30)
	probby = clamp(probby, 5, 95)

	if(prob(probby) && !instant && !stat && cmode)
		visible_message("<span class='warning'>[user] struggles with [src]!</span>",
						"<span class='warning'>[user] struggles to restrain me!</span>", "<span class='hear'>I hear aggressive shuffling!</span>", null, user)
		if(src.client?.prefs.showrolls)
			to_chat(user, "<span class='warning'>I struggle with [src]! ([probby]%)</span>")
		else
			to_chat(user, "<span class='warning'>I struggle with [src]!</span>")
		playsound(src.loc, 'sound/foley/struggle.ogg', 100, FALSE, -1)
		user.Immobilize(2 SECONDS)
		user.changeNext_move(2 SECONDS)
		user.adjust_stamina(5)
		src.Immobilize(1 SECONDS)
		src.changeNext_move(1 SECONDS)
		return

	if(!instant)
		var/sound_to_play = 'sound/foley/grab.ogg'
		playsound(src.loc, sound_to_play, 100, FALSE, -1)

	testing("eheh1")
	user.setGrabState(GRAB_AGGRESSIVE)
	if(user.active_hand_index == 1)
		if(user.r_grab)
			user.r_grab.grab_state = GRAB_AGGRESSIVE
	if(user.active_hand_index == 2)
		if(user.l_grab)
			user.l_grab.grab_state = GRAB_AGGRESSIVE

	user.update_grab_intents()

	var/add_log = ""
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		add_log = " (pacifist)"
	send_grabbed_message(user)
	if(user != src)
		stop_pulling()
		user.set_pull_offsets(src, user.grab_state)
	log_combat(user, src, "grabbed", addition="aggressive grab[add_log]")
	return 1

/mob/living/proc/update_grab_intents(mob/living/target)
	return

/mob/living/carbon/update_grab_intents()
	var/obj/item/grabbing/G = get_active_held_item()
	if(!istype(G))
		return
	if(ismob(G.grabbed))
		if(isitem(G.sublimb_grabbed))
			var/obj/item/I = G.sublimb_grabbed
			G.possible_item_intents = I.grabbedintents(src, G.sublimb_grabbed)
		else
			if(iscarbon(G.grabbed) && G.limb_grabbed)
				var/obj/item/I = G.limb_grabbed
				G.possible_item_intents = I.grabbedintents(src, G.sublimb_grabbed)
			else
				var/mob/M = G.grabbed
				G.possible_item_intents = M.grabbedintents(src, G.sublimb_grabbed)
	if(isobj(G.grabbed))
		var/obj/I = G.grabbed
		G.possible_item_intents = I.grabbedintents(src, G.sublimb_grabbed)
	if(isturf(G.grabbed))
		var/turf/T = G.grabbed
		G.possible_item_intents = T.grabbedintents(src)
	update_a_intents()

/turf/proc/grabbedintents(mob/living/user)
	//RTD up and down
	return list(/datum/intent/grab/move)

/obj/proc/grabbedintents(mob/living/user, precise)
	return list(/datum/intent/grab/move)

/obj/item/grabbedintents(mob/living/user, precise)
	return list(/datum/intent/grab/remove, /datum/intent/grab/twistitem)

/mob/proc/grabbedintents(mob/living/user, precise)
	return list(/datum/intent/grab/move)

/mob/living/proc/send_grabbed_message(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		visible_message("<span class='danger'>[user] firmly grips [src]!</span>",
						"<span class='danger'>[user] firmly grips me!</span>", "<span class='hear'>I hear aggressive shuffling!</span>", null, user)
		to_chat(user, "<span class='danger'>I firmly grip [src]!</span>")
	else
		visible_message("<span class='danger'>[user] tightens [user.p_their()] grip on [src]!</span>", \
						"<span class='danger'>[user] tightens [user.p_their()] grip on me!</span>", "<span class='hear'>I hear aggressive shuffling!</span>", null, user)
		to_chat(user, "<span class='danger'>I tighten my grip on [src]!</span>")

/mob/living/attack_animal(mob/living/simple_animal/M)
	if(M.swinging)
		return
	M.swinging = TRUE
	M.face_atom(src)
	if(M.melee_damage_upper == 0)
		visible_message("<span class='notice'>\The [M] [pick(M.a_intent.attack_verb)] [src].</span>", \
						"<span class='notice'>\The [M] [pick(M.a_intent.attack_verb)] me!</span>", null, COMBAT_MESSAGE_RANGE)
		return FALSE
	if(HAS_TRAIT(M, TRAIT_PACIFISM))
		to_chat(M, "<span class='warning'>I don't want to hurt anyone!</span>")
		return FALSE

	M.do_attack_animation(src, visual_effect_icon = M.a_intent.animname)
	playsound(get_turf(M), pick(M.attack_sound), 100, FALSE)

	var/cached_intent = M.used_intent

	sleep(M.used_intent.swingdelay)
	M.swinging = FALSE
	if(M.a_intent != cached_intent)
		return FALSE
	if(QDELETED(src) || QDELETED(M))
		return FALSE
	if(!M.Adjacent(src))
		return FALSE
	if(M.incapacitated())
		return FALSE

	if(checkmiss(M))
		return FALSE

	if(checkdefense(M.a_intent, M))
		return FALSE

	if(M.attack_sound)
		playsound(loc, M.a_intent.hitsound, 100, FALSE)

	log_combat(M, src, "attacked")

	return TRUE


/mob/living/attack_paw(mob/living/carbon/monkey/M)
	if(isturf(loc) && istype(loc.loc, /area/start))
//		to_chat(M, "No attacking people at spawn, you jackass.")
		return FALSE

	if (M.used_intent.type == INTENT_HARM)
		if(HAS_TRAIT(M, TRAIT_PACIFISM))
			to_chat(M, "<span class='info'>I don't want to hurt anyone!</span>")
			return FALSE

		if(M.is_muzzled() || M.is_mouth_covered(FALSE, TRUE))
			to_chat(M, "<span class='warning'>I can't bite with my mouth covered!</span>")
			return FALSE
		M.do_attack_animation(src, ATTACK_EFFECT_BITE)
		if (prob(75))
			log_combat(M, src, "attacked")
			playsound(loc, 'sound/blank.ogg', 50, TRUE, -1)
			visible_message("<span class='danger'>[M.name] bites [src]!</span>", \
							"<span class='danger'>[M.name] bites you!</span>", "<span class='hear'>I hear a chomp!</span>", COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='danger'>I bite [src]!</span>")
			return TRUE
		else
			visible_message("<span class='danger'>[M.name]'s bite misses [src]!</span>", \
							"<span class='danger'>I avoid [M.name]'s bite!</span>", "<span class='hear'>I hear the sound of jaws snapping shut!</span>", COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='warning'>My bite misses [src]!</span>")
	return FALSE

/mob/living/ex_act(severity, target)
	..()

/mob/living/attack_paw(mob/living/carbon/monkey/M)
	if(isturf(loc) && istype(loc.loc, /area/start))
//		to_chat(M, "No attacking people at spawn, you jackass.")
		return FALSE

	if (M.used_intent.type == INTENT_HARM)
		if(HAS_TRAIT(M, TRAIT_PACIFISM))
			to_chat(M, "<span class='info'>I don't want to hurt anyone!</span>")
			return FALSE

		if(M.is_muzzled() || M.is_mouth_covered(FALSE, TRUE))
			to_chat(M, "<span class='warning'>I can't bite with my mouth covered!</span>")
			return FALSE
		M.do_attack_animation(src, ATTACK_EFFECT_BITE)
		if (prob(75))
			log_combat(M, src, "attacked")
			playsound(loc, 'sound/blank.ogg', 50, TRUE, -1)
			visible_message("<span class='danger'>[M.name] bites [src]!</span>", \
							"<span class='danger'>[M.name] bites you!</span>", "<span class='hear'>I hear a chomp!</span>", COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='danger'>I bite [src]!</span>")
			return TRUE
		else
			visible_message("<span class='danger'>[M.name]'s bite misses [src]!</span>", \
							"<span class='danger'>I avoid [M.name]'s bite!</span>", "<span class='hear'>I hear the sound of jaws snapping shut!</span>", COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='warning'>My bite misses [src]!</span>")
	return FALSE

/mob/living/acid_act(acidpwr, acid_volume)
	take_bodypart_damage(acidpwr * min(1, acid_volume * 0.1))
	return 1

///As the name suggests, this should be called to apply electric shocks.
/mob/living/proc/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage, source, siemens_coeff, flags)
	shock_damage *= siemens_coeff
	if((flags & SHOCK_TESLA) && (flags_1 & TESLA_IGNORE_1))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		return FALSE
	if(shock_damage < 1)
		return FALSE
	if(!(flags & SHOCK_ILLUSION))
		adjustFireLoss(shock_damage)
	visible_message(
		"<span class='danger'>[src] was shocked by \the [source]!</span>", \
		"<span class='danger'>I feel a powerful shock coursing through my body!</span>", \
		"<span class='hear'>I hear a heavy electrical crack.</span>" \
	)
	playsound(get_turf(src), pick('sound/misc/elec (1).ogg', 'sound/misc/elec (2).ogg', 'sound/misc/elec (3).ogg'), 100, FALSE)
	return shock_damage

/mob/living/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/O in contents)
		O.emp_act(severity)


//called when the mob receives a bright flash
/mob/living/proc/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash)
	if(HAS_TRAIT(src, TRAIT_NOFLASH))
		return FALSE
	if(get_eye_protection() < intensity && (override_blindness_check || !(HAS_TRAIT(src, TRAIT_BLIND))))
		overlay_fullscreen("flash", type)
		addtimer(CALLBACK(src, PROC_REF(clear_fullscreen), "flash", 25), 25)
		return TRUE
	return FALSE

//called when the mob receives a loud bang
/mob/living/proc/soundbang_act()
	return 0

//to damage the clothes worn by a mob
/mob/living/proc/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	return


/mob/living/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item)
		used_item = get_active_held_item()
	..()
	setMovetype(movement_type & ~FLOATING) // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.
