/obj/structure/irrigation_channel
	name = "irrigation channel"
	icon = 'icons/effects/snow.dmi'
	icon_state = "trench_base"

	var/list/diged = list("2" = 0, "1" = 0, "8" = 0, "4" = 0)
	var/water_logged = FALSE
	var/turf/open/water/water_parent
	var/datum/reagent/water_reagent

/obj/structure/irrigation_channel/Initialize()
	. = ..()
	for(var/direction in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(src, direction)
		for(var/obj/structure/irrigation_channel/irrigation_channel in cardinal_turf)
			if(!istype(irrigation_channel))
				continue
			set_diged_ways(get_dir(src, irrigation_channel))
			irrigation_channel.set_diged_ways(get_dir(irrigation_channel, src))
			irrigation_channel.update_overlays()
		if(istype(cardinal_turf, /turf/open/water))
			set_diged_ways(get_dir(src, cardinal_turf))

	update_overlays()
	START_PROCESSING(SSobj, src)

/obj/structure/irrigation_channel/Destroy()
	. = ..()
	UnregisterSignal(water_parent, COMSIG_TURF_CHANGE)
	for(var/direction in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(src, direction)
		for(var/obj/structure/irrigation_channel/irrigation_channel in cardinal_turf)
			if(!istype(irrigation_channel))
				return
			irrigation_channel.unset_diged_ways(get_dir(irrigation_channel, src))
			irrigation_channel.update_overlays()

/obj/structure/irrigation_channel/proc/set_diged_ways(dir)
	diged["[dir]"] = world.time + 60 MINUTES
	update_overlays()

/obj/structure/irrigation_channel/proc/unset_diged_ways(dir)
	diged["[dir]"] = 0
	update_overlays()


/obj/structure/irrigation_channel/update_overlays()
	. = ..()
	cut_overlays()
	var/new_overlay = ""
	for(var/i in diged)
		if(diged[i] > world.time)
			new_overlay += i
	icon_state = "[new_overlay]"
	if(!new_overlay)
		icon_state = "trench_base"

	if(!water_logged)
		return
	var/mutable_appearance/overlay = mutable_appearance('icons/turf/newwater.dmi', "together")
	overlay.blend_mode = BLEND_INSET_OVERLAY
	overlay.color = water_parent.water_reagent.color
	overlays += overlay

/obj/structure/irrigation_channel/process()
	if(!water_logged)
		for(var/direction in GLOB.cardinals)
			var/turf/cardinal_turf = get_step(src, direction)
			if(istype(cardinal_turf, /turf/open/water))
				var/turf/open/water/water = cardinal_turf
				if(water.water_volume < 10)
					continue
				if(water.blocked_flow_directions["[get_dir(water, src)]"])
					continue
				water_logged = TRUE
				water_parent = water
				RegisterSignal(water_parent, COMSIG_TURF_CHANGE, PROC_REF(dry_up), override = TRUE)
				set_diged_ways(get_dir(src, cardinal_turf))
				update_overlays()
				return

			for(var/obj/structure/irrigation_channel/irrigation_channel in cardinal_turf)
				if(!istype(irrigation_channel))
					continue
				if(!irrigation_channel.water_logged)
					continue
				water_parent = irrigation_channel.water_parent
				RegisterSignal(water_parent, COMSIG_TURF_CHANGE, PROC_REF(dry_up), override = TRUE)
				water_logged = TRUE
				update_overlays()
	else
		if(water_parent.blocked_flow_directions["[get_dir(water_parent, src)]"])
			water_logged = FALSE
			update_overlays()

		if(water_reagent != water_parent.water_reagent)
			water_reagent = water_parent.water_reagent
			update_overlays()
		if(water_parent.water_volume >= 10)
			return
		water_logged = FALSE
		update_overlays()

/obj/structure/irrigation_channel/proc/dry_up()
	water_logged = FALSE
	water_parent = null
	update_overlays()



/obj/structure/irrigation_channel/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/rogueweapon/shovel))
		return
	if((user.used_intent.type == /datum/intent/shovelscoop) || (user.used_intent.type == /datum/intent/irrigate))
		var/obj/item/rogueweapon/shovel/shovel = I
		if(!shovel.heldclod)
			user.visible_message("[user] starts diggin a trench.", "You start digging a trench.")
			if(!do_after(user, 10 SECONDS, target = src))
				return
			new /obj/structure/trench(get_turf(src))
			qdel(src)
			return

		user.visible_message("[user] starts filling [src].", "You start filling [src].")
		if(!do_after(user, 4 SECONDS, target = src))
			return
		QDEL_NULL(shovel.heldclod)
		qdel(src)
