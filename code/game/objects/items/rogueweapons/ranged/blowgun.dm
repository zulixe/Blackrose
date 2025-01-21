
/obj/item/gun/ballistic/revolver/grenadelauncher/blowgun
	name = "blowgun"
	desc = "A primitive tool used for hunting. To use most accuratly, hold your breath for a moment before releasing."
	icon = 'icons/roguetown/weapons/bows.dmi'
	icon_state = "blowgun"
	possible_item_intents = list(/datum/intent/shoot/blowgun, /datum/intent/arc/blowgun, INTENT_GENERIC)
	mag_type = /obj/item/ammo_box/magazine/internal/shot/blowgun
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL
	randomspread = 0
	spread = 0
	can_parry = FALSE
	force = 6
	var/cocked = FALSE
	cartridge_wording = "dart"
	fire_sound = 'sound/combat/Ranged/blowgun_shot.ogg'
	associated_skill =  /datum/skill/combat/bows

/obj/item/gun/ballistic/revolver/grenadelauncher/blowgun/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.5,"sx" = -4,"sy" = -6,"nx" = 9,"ny" = -6,"wx" = -6,"wy" = -4,"ex" = 4,"ey" = -6,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 90,"wturn" = 93,"eturn" = -12,"nflip" = 0,"sflip" = 1,"wflip" = 0,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/gun/ballistic/revolver/grenadelauncher/blowgun/shoot_with_empty_chamber()
	update_icon()
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/blowgun/dropped()
	. = ..()
	if(chambered)
		chambered = null
		var/num_unloaded = 0
		for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
			CB.forceMove(drop_location())
			num_unloaded++
		if (num_unloaded)
			update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/blowgun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(user.get_num_arms(FALSE) < 2)
		return FALSE
	if(user.get_inactive_held_item())
		return FALSE
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
		var/obj/projectile/BB = CB.BB
		if(user.client.chargedprog < 100)
			BB.damage = BB.damage - (BB.damage * (user.client.chargedprog / 100))
			BB.embedchance = 5
		else
			BB.damage = BB.damage
			BB.embedchance = 100
			BB.accuracy += 15 //fully aiming blow makes your accuracy better.

		if(user.STAPER > 8)
			BB.accuracy += (user.STAPER - 8) * 4 //each point of perception above 8 increases standard accuracy by 4.
			BB.bonus_accuracy += (user.STAPER - 8) //Also, increases bonus accuracy by 1, which cannot fall off due to distance.
			if(user.STAPER > 10) // Every point over 10 PER adds 10% damage
				BB.damage = BB.damage * (user.STAPER / 10)
		BB.damage *= damfactor // Apply blow's inherent damage multiplier regardless of PER
		BB.bonus_accuracy += (user.mind.get_skill_level(/datum/skill/combat/bows) * 5) //+5 accuracy per level in bows. Bonus accuracy will not drop-off.
	. = ..()

/obj/item/gun/ballistic/revolver/grenadelauncher/blowgun/update_icon()
	. = ..()
	cut_overlays()
	if(chambered)
		var/obj/item/I = chambered
		I.pixel_x = 0
		I.pixel_y = 0
		add_overlay(new /mutable_appearance(I))
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/ammo_box/magazine/internal/shot/blowgun
	ammo_type = /obj/item/ammo_casing/caseless/rogue/dart
	caliber = "dart"
	max_ammo = 1
	start_empty = TRUE

/datum/intent/shoot/blowgun
	chargetime = 1
	chargedrain = 1
	charging_slowdown = 1
	item_damage_type = "piercing"

/datum/intent/shoot/blowgun/can_charge()
	if(mastermob)
		if(mastermob.get_num_arms(FALSE) < 1)
			return FALSE
	return TRUE

/datum/intent/shoot/blowgun/get_chargetime()
	if(mastermob && chargetime)
		mastermob.visible_message("<span class='warning'>[mastermob] takes a deep breath!</span>")
		var/newtime = 0
		newtime = newtime + 3 SECONDS
		newtime = newtime - (mastermob.mind.get_skill_level(/datum/skill/combat/bows) * (5))- (mastermob.STAPER * 0.5)
		if(newtime > 0)
			return newtime
		else
			return 0.1
	return chargetime

/datum/intent/arc/blowgun
	chargetime = 1 SECONDS
	chargedrain = 1
	charging_slowdown = 1

/datum/intent/arc/blowgun/can_charge()
	if(mastermob)
		if(mastermob.get_num_arms(FALSE) < 2)
			return FALSE
		if(mastermob.get_inactive_held_item())
			return FALSE
	return TRUE

/datum/intent/arc/blowgun/get_chargetime()
	if(mastermob && chargetime)
		mastermob.visible_message("<span class='warning'>[mastermob] takes a deep breath!</span>")
		var/newtime = 0
		//skill block
		newtime = newtime + 10
		newtime = newtime - (mastermob.mind.get_skill_level(/datum/skill/combat/bows) * (10/6))
		//str block //rtd replace 10 with drawdiff on bows that are hard and scale str more (10/20 = 0.5)
		newtime = newtime + 10
		newtime = newtime - (mastermob.STASTR * (10/20))
		//per block
		newtime = newtime + 20
		newtime = newtime - (mastermob.STAPER * 1) //20/20 is 1
		if(newtime > 0)
			return newtime
		else
			return 1
	return chargetime
