/obj/item/gun/ballistic/revolver/grenadelauncher/pistol
	name = "puffer"
	desc = "The current zenith of Dwarven and Humen cooperation on the Eastern continent. It uses alchemical blastpowder to propel metal balls for devastating effect."
	icon = 'icons/roguetown/weapons/32.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "puffer_uncocked_ramrod"
	item_state = "puffer"
	bigboy = FALSE
	recoil = 8
	randomspread = 2
	spread = 3
	force = 10
	experimental_inhand = FALSE
	experimental_onback = FALSE
	var/click_delay = 0.5
	var/obj/item/ramrod/rod
	cartridge_wording = "ball"
	var/rammed = FALSE
	load_sound = 'sound/foley/nockarrow.ogg'
	fire_sound = 'sound/combat/Ranged/muskshoot.ogg'
	equip_sound = 'sound/foley/gun_equip.ogg'
	pickup_sound = 'sound/foley/gun_equip.ogg'
	drop_sound = 'sound/foley/gun_drop.ogg'
	dropshrink = 0.7
	associated_skill = /datum/skill/combat/firearms
	possible_item_intents = list(INTENT_GENERIC)
	possible_item_intents = list(/datum/intent/shoot/musket, /datum/intent/shoot/musket/arc, INTENT_GENERIC)
	mag_type = /obj/item/ammo_box/magazine/internal/shot/musk
	gripped_intents = null
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL
	sellprice = 200 // This kind of equipment is very hard to come by in Rockhill.
	grid_height = 32
	grid_width = 96
	var/cocked = FALSE
	var/ramrod_inserted = TRUE
	var/powdered = FALSE
	var/wound = FALSE

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/update_icon()
	// Update the icon based on the cocked state and whether the ramrod is inserted
	if(cocked)
		if(ramrod_inserted)
			icon_state = "puffer_cocked_ramrod"
		else
			icon_state = "puffer_cocked"
	else
		if(ramrod_inserted)
			icon_state = "puffer_uncocked_ramrod"
		else
			icon_state = "puffer_uncocked"

	// Update the visual icon
	update_icon_state()

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/shoot_live_shot(mob/living/user, pointblank, mob/pbtarget, message)
	..()
	user.playsound_local(get_turf(user), 'sound/foley/tinnitus.ogg', 60, FALSE) // muh realism or something
	new /obj/effect/particle_effect/smoke(get_turf(user))

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/shoot_with_empty_chamber(mob/living/user)
	if(!cocked || !wound)
		return
	playsound(src.loc, 'sound/combat/Ranged/muskclick.ogg', 100, FALSE)
	cocked = FALSE
	wound = FALSE
	update_icon() // Update the icon state after shooting an empty chamber

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/attack_right(mob/user)
	. = ..()
	if(!user.is_holding(src))
		to_chat(user, "<span class='warning'>I need to hold \the [src] to cock it!</span>")
		return
	if(cocked)
		cocked = FALSE
		to_chat(user, "<span class='warning'>I carefully de-cock \the [src].</span>")
		playsound(src.loc, 'sound/combat/Ranged/muskclick.ogg', 100, FALSE)
	else
		playsound(src.loc, 'sound/combat/Ranged/muskclick.ogg', 100, FALSE)
		to_chat(user, "<span class='info'>I cock \the [src].</span>")
		cocked = TRUE
	update_icon() // Update the icon state after cocking or de-cocking

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/rmb_self(mob/user)
	. = ..()
	if(user.mind.get_skill_level(/datum/skill/combat/firearms) <= 0)
		to_chat(user, "<span class='warning'>I don't know how to do this!</span>")
		return
	if(wound)
		to_chat(user, "<span class='info'>\The [src]'s mechanism is already wound!</span>")
	var/windtime = 3.5
	windtime = windtime - (user.mind.get_skill_level(/datum/skill/combat/firearms) / 2)
	if(do_after(user, windtime SECONDS, TRUE, src) && !wound)
		to_chat(user, "<span class='info'>I wind \the [src]'s mechanism.</span>")
		playsound(src.loc, 'sound/foley/winding.ogg', 100, FALSE)
		wound = TRUE


/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/MiddleClick(mob/user, params)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(rod)
			H.put_in_hands(rod)
			rod = null
			ramrod_inserted = FALSE
			to_chat(user, "<span class='info'>I remove the ramrod from \the [src].</span>")
			playsound(src.loc, 'sound/foley/struggle.ogg', 100, FALSE, -1)
		else if(istype(H.get_active_held_item(), /obj/item/ramrod))
			var/obj/item/ramrod/rrod = H.get_active_held_item()
			rrod.forceMove(src)
			rod = rrod
			ramrod_inserted = TRUE
			to_chat(user, "<span class='info'>I put \the [rrod] into \the [src].</span>")
			playsound(src.loc, 'sound/foley/struggle.ogg', 100, FALSE, -1)
		update_icon() // Update the icon state after handling the ramrod

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
		var/obj/projectile/BB = CB.BB
		if(user.client)
			if(user.client.chargedprog >= 100)
				BB.accuracy += 15 //better accuracy for fully aiming
		if(user.STAPER > 8)
			BB.accuracy += (user.STAPER - 8) * 4 //each point of perception above 8 increases standard accuracy by 4.
			BB.bonus_accuracy += (user.STAPER - 8) //Also, increases bonus accuracy by 1, which cannot fall off due to distance.
		if(user.STAPER > 10)
			BB.damage = BB.damage * (user.STAPER / 10)
		BB.bonus_accuracy += (user.mind.get_skill_level(/datum/skill/combat/firearms) * 3) //+3 accuracy per level in firearms
	if(!cocked)
		return
	if(!rammed)
		return
	if(!powdered)
		return
	if(!wound)
		return
	playsound(src.loc, 'sound/combat/Ranged/muskclick.ogg', 100, FALSE)
	cocked = FALSE
	rammed = FALSE
	powdered = FALSE
	wound = FALSE
	sleep(click_delay)
	update_icon()
	..()

/obj/item/ramrod
	name = "ram rod"
	desc = ""
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "ramrod"

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/Initialize()
	. = ..()
	var/obj/item/ramrod/rrod = new(src)
	rod = rrod

/obj/item/gun/ballistic/revolver/grenadelauncher/pistol/attackby(obj/item/I, mob/user, params)
	var/ramtime = 5.5
	ramtime = ramtime - (user.mind.get_skill_level(/datum/skill/combat/firearms) / 2)

	// Check if the item used is a ramrod
	if(istype(I, /obj/item/ramrod))
		if(user.mind.get_skill_level(/datum/skill/combat/firearms) <= 0)
			to_chat(user, "<span class='warning'>I don't know how to do this!</span>")
			return
		if(!user.is_holding(src))
			to_chat(user, "<span class='warning'>I need to hold \the [src] to ram it!</span>")
			return
		if(chambered)
			if(!powdered)
				to_chat(user, "<span class='warning'>I need to powder the [src] before I can ram it.</span>")
				return
			if(!rammed)
				if(do_after(user, ramtime SECONDS, TRUE, src))
					to_chat(user, "<span class='info'>I ram \the [src].</span>")
					playsound(src.loc, 'sound/foley/nockarrow.ogg', 100, FALSE)
					rammed = TRUE
	else
		// Check if the item used is a reagent container
		if(istype(I, /obj/item/reagent_containers))
			if(user.mind.get_skill_level(/datum/skill/combat/firearms) <= 0)
				to_chat(user, "<span class='warning'>I don't know how to do this!</span>")
				return
			if(powdered)
				to_chat(user, "<span class='warning'>\The [src] is already powdered!</span>")
				return
			// Check if the reagent container contains at least 5u of blastpowder
			if(I.reagents.get_reagent_amount(/datum/reagent/blastpowder) >= 5)
				// Subtract 5u of blastpowder from the reagent container
				I.reagents.remove_reagent(/datum/reagent/blastpowder, 5)
				// Set the 'powdered' flag on the pistol
				powdered = TRUE
				to_chat(user, "<span class='info'>I add blastpowder to \the [src], making it ready for a powerful shot.</span>")
				playsound(src.loc, 'sound/foley/gunpowder_fill.ogg', 100, FALSE)
				return 1
			else
				to_chat(user, "<span class='warning'>Not enough blastpowder in [I] to powder the [src].</span>")
				return 0

	return ..()

/obj/item/ammo_box/magazine/internal/shot/musk
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bullet
	caliber = "musketball"
	max_ammo = 1
	start_empty = TRUE

/obj/item/reagent_containers/glass/bottle/rogue/aflask
	name = "alchemical flask"
	desc = "A small metal flask used for the secure storing of alchemical powders."
	list_reagents = list(/datum/reagent/blastpowder = 30)
	icon_state = "aflask"
