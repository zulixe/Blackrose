
/obj/structure/closet/dirthole
	name = "hole"
	icon_state = "hole1"
	icon = 'icons/turf/roguefloor.dmi'
	var/stage = 1
	var/mutable_appearance/abovemob
	var/turf/open/floor/rogue/dirt/mastert
	var/faildirt = 0
	mob_storage_capacity = 3
	allow_dense = TRUE
	opened = TRUE
	density = FALSE
	anchored = TRUE
	can_buckle = FALSE
	max_integrity = 0
	buckle_lying = 90
	layer = 2.8

/obj/structure/closet/dirthole/grave
	stage = 3
	faildirt = 3
	icon_state = "grave"

/obj/structure/closet/dirthole/closed
	stage = 4
	faildirt = 3
	climb_offset = 10
	icon_state = "gravecovered"
	opened = FALSE
	locked = TRUE

/obj/structure/closet/dirthole/closed/loot/Initialize()
	. = ..()
	lootroll = rand(1,4)

/obj/structure/closet/dirthole/closed/loot
	var/looted = FALSE
	var/lootroll = 0

/obj/structure/closet/dirthole/closed/loot/open()
	if(!looted)
		looted = TRUE
		switch(lootroll)
			if(1)
				new /mob/living/carbon/human/species/skeleton/npc(mastert)
				new /obj/structure/closet/crate/chest/lootbox(mastert)
			if(2)
				new /obj/structure/closet/crate/chest/lootbox(mastert)
	..()

/obj/structure/closet/dirthole/closed/loot/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_SOUL_EXAMINE))
		if(lootroll == 1)
			. += "<span class='warning'>Better let this one sleep.</span>"

/obj/structure/closet/dirthole/insertion_allowed(atom/movable/AM)
	if(istype(AM, /obj/structure/closet/crate/chest) || istype(AM, /obj/structure/closet/burial_shroud) || istype(AM, /obj/structure/closet/crate/coffin))
		for(var/mob/living/M in contents)
			return FALSE
		for(var/obj/structure/closet/C in contents)
			return FALSE
		return TRUE
	. = ..()

/obj/structure/closet/dirthole/toggle(mob/living/user)
	return

/obj/structure/closet/dirthole/proc/attemptwatermake(mob/living/user, obj/item/reagent_containers/bucket)
	testing("attempting to make water proc called")
	if(user.used_intent.type == /datum/intent/splash)
		testing("intent check complete")
		if(bucket.reagents)
			testing("reagent check complete")
			var/datum/reagent/master_reagent = bucket.reagents.get_master_reagent()
			var/reagent_volume = master_reagent.volume
			if(do_after(user, 10 SECONDS, target = src))
				if(bucket.reagents.remove_reagent(master_reagent.type, clamp(master_reagent.volume, 1, 100)))
					testing("remove reagent proc complete")
					var/turf/open/water/river/creatable/W = new(get_turf(src))
					W.water_reagent = master_reagent.type
					W.water_volume = clamp(reagent_volume, 1, 100)
					W.update_icon()
					playsound(W, 'sound/foley/waterenter.ogg', 100, FALSE)
					QDEL_NULL(src) // Somehow this actually makes it disappear. Hilarious.
	testing("proc ended")

/obj/structure/closet/dirthole/attackby(obj/item/attacking_item, mob/user, params)
	if(!istype(attacking_item, /obj/item/rogueweapon/shovel))
		if(istype(attacking_item, /obj/item/reagent_containers/glass/bucket/wooden))
			var/obj/item/reagent_containers/glass/bucket/wooden/bucket = attacking_item
			testing("attempt water make proc should be called now")
			attemptwatermake(user, bucket)
			return
		return ..()
	var/obj/item/rogueweapon/shovel/attacking_shovel = attacking_item
	if(user.used_intent.type != /datum/intent/shovelscoop)
		return

	if(attacking_shovel.heldclod)
		playsound(loc,'sound/items/empty_shovel.ogg', 100, TRUE)
		QDEL_NULL(attacking_shovel.heldclod)
		if(stage == 3) //close grave
			stage = 4
			climb_offset = 10
			locked = TRUE
			close()
			var/founds
			for(var/atom/A in contents)
				founds = TRUE
				break
			if(!founds)
				stage = 2
				climb_offset = 0
				locked = FALSE
				open()
			update_icon()
		else if(stage < 4)
			stage--
			climb_offset = 0
			update_icon()
			if(stage == 0)
				qdel(src)
		attacking_shovel.update_icon()
		return
	else
		if(stage == 3)
			var/turf/underT = get_step_multiz(src, DOWN)
			if(underT && isopenturf(underT) && mastert)
				attacking_shovel.heldclod = new(attacking_shovel)
				attacking_shovel.update_icon()
				playsound(mastert,'sound/items/dig_shovel.ogg', 100, TRUE)
				mastert.ChangeTurf(/turf/open/transparent/openspace)
				return
//					for(var/D in GLOB.cardinals)
//						var/turf/T = get_step(mastert, D)
//						if(T)
//							if(istype(T, /turf/open/water))
//								attacking_shovel.heldclod = new(attacking_shovel)
//								attacking_shovel.update_icon()
//								playsound(mastert,'sound/items/dig_shovel.ogg', 100, TRUE)
//								mastert.ChangeTurf(T.type, flags = CHANGETURF_INHERIT_AIR)
//								return
			to_chat(user, "<span class='warning'>I think that's deep enough.</span>")
			return
		var/used_str = 10
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(C.domhand)
				used_str = C.get_str_arms(C.used_hand)
			C.adjust_stamina(max(60 - (used_str * 5), 1))
		if(stage < 3)
			if(faildirt < 2)
				if(prob(used_str * 5))
					stage++
				else
					faildirt++
			else
				stage++
		if(stage == 4)
			stage = 3
			climb_offset = 0
			locked = FALSE
			open()
			for(var/obj/structure/gravemarker/G in loc)
				qdel(G)
				if(isliving(user))
					var/mob/living/L = user
					if(HAS_TRAIT(L, TRAIT_GRAVEROBBER))
						to_chat(user, "<span class='warning'>Necra turns a blind eye to my deeds.</span>")
					else
						to_chat(user, "<span class='warning'>Necra shuns my blasphemous deeds, I am cursed!</span>")
						L.apply_status_effect(/datum/status_effect/debuff/cursed)
		update_icon()
		attacking_shovel.heldclod = new(attacking_shovel)
		attacking_shovel.update_icon()
		playsound(loc,'sound/items/dig_shovel.ogg', 100, TRUE)
		return

/datum/status_effect/debuff/cursed
	id = "cursed"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/cursed
	effectedstats = list("fortune" = -5) // More severe so that the permanent debuff from having the perk makes it actually worth it.
	duration = 10 MINUTES

/atom/movable/screen/alert/status_effect/debuff/cursed
	name = "Cursed"
	desc = "Necra has punished me by my blasphemous deeds with terribly bad luck."
	icon_state = "debuff"

/obj/structure/closet/dirthole/MouseDrop_T(atom/movable/O, mob/living/user)
	var/turf/T = get_turf(src)
	if(istype(O, /obj/structure/closet/crate/coffin))
		O.forceMove(T)
	if(!istype(O) || O.anchored || istype(O, /atom/movable/screen))
		return
	if(!istype(user) || user.incapacitated() || !(user.mobility_flags & MOBILITY_STAND))
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(user == O) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(O.loc))
		return

	var/actuallyismob = 0
	if(isliving(O))
		actuallyismob = 1
	else if(!isitem(O))
		return
	var/list/targets = list(O, src)
	add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] [actuallyismob ? "tries to ":""]stuff [O] into [src].</span>", \
						"<span class='warning'>I [actuallyismob ? "try to ":""]stuff [O] into [src].</span>", \
						"<span class='hear'>I hear clanging.</span>")
	if(actuallyismob)
		if(do_after_mob(user, targets, 40))
			user.visible_message("<span class='notice'>[user] stuffs [O] into [src].</span>", \
								"<span class='notice'>I stuff [O] into [src].</span>", \
								"<span class='hear'>I hear a loud bang.</span>")
			O.forceMove(T)
			user_buckle_mob(O, user)
	else
		O.forceMove(T)
	return 1

/obj/structure/closet/dirthole/take_contents()
	var/atom/L = drop_location()
	..()
	for(var/obj/structure/closet/crate/coffin/C in L)
		if(C != src && insert(C) == -1)
			break


/obj/structure/closet/dirthole/close(mob/living/user)
	if(!opened || !can_close(user))
		return FALSE
	take_contents()
	for(var/mob/A in contents)
		if((A.stat) && (istype(A, /mob/living/carbon/human)))
			var/mob/living/carbon/human/B = A
			B.buried = TRUE
	for(var/obj/structure/closet/crate/coffin/C in contents)
		for(var/mob/living/carbon/human/D in C.contents)
			D.buried = TRUE
	opened = FALSE
//	update_icon()
	return TRUE

/obj/structure/closet/dirthole/dump_contents()
	for(var/mob/A in contents)
		if((!A.stat) && (istype(A, /mob/living/carbon/human)))
			var/mob/living/carbon/human/B = A
			B.buried = FALSE
	..()

/obj/structure/closet/dirthole/open(mob/living/user)
	if(opened)
		return
	opened = TRUE
	dump_contents()
	update_icon()
	return 1


/obj/structure/closet/dirthole/update_icon()
	switch(stage)
		if(1)
			name = "hole"
			icon_state = "hole1"
			can_buckle = FALSE
		if(2)
			name = "hole"
			icon_state = "hole2"
			can_buckle = FALSE
		if(3)
			name = "pit"
			icon_state = "grave"
			can_buckle = TRUE
		if(4)
			name = "grave"
			icon_state = "gravecovered"
			can_buckle = FALSE
	update_abovemob()

/obj/structure/closet/dirthole/Initialize()
	abovemob = mutable_appearance('icons/turf/roguefloor.dmi', "grave_above")
	abovemob.layer = ABOVE_MOB_LAYER
	update_icon()
	var/turf/open/floor/rogue/dirt/T = loc
	if(istype(T))
		mastert = T
		T.holie = src
		if(T.muddy)
			if(!(locate(/obj/item/natural/worms) in T))
				if(prob(40))
					if(prob(10))
						new /obj/item/natural/worms/grubs(T)
					else
						new /obj/item/natural/worms/leech(T)
				else
					new /obj/item/natural/worms(T)
		else
			if(!(locate(/obj/item/natural/stone) in T))
				if(prob(23))
					new /obj/item/natural/stone(T)
	return ..()

/obj/structure/closet/dirthole/Destroy()
	QDEL_NULL(abovemob)
	if(istype(mastert))
		if(mastert && mastert?.holie == src)
			mastert.holie = null
	return ..()

/obj/structure/closet/dirthole/post_buckle_mob(mob/living/M)
	. = ..()
	update_abovemob()

/obj/structure/closet/dirthole/proc/update_abovemob()
	if(has_buckled_mobs() && stage == 3)
		add_overlay(abovemob)
	else
		cut_overlay(abovemob)

/obj/structure/closet/dirthole/post_unbuckle_mob()
	. = ..()
	update_abovemob()

