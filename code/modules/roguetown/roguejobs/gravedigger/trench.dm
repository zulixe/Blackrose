/obj/structure/trench
	name = "trench"
	icon = 'icons/effects/snow.dmi'
	icon_state = "trench_base"

	var/list/diged = list("2" = 0, "1" = 0, "8" = 0, "4" = 0)

/obj/structure/trench/Initialize()
	. = ..()
	for(var/direction in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(src, direction)
		for(var/obj/structure/trench/trench in cardinal_turf)
			if(!istype(trench))
				return
			set_diged_ways(get_dir(src, trench))
			trench.set_diged_ways(get_dir(trench, src))
			trench.update_overlays()
	update_overlays()
	START_PROCESSING(SSobj, src)

/obj/structure/trench/Destroy()
	. = ..()
	for(var/direction in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(src, direction)
		for(var/obj/structure/trench/trench in cardinal_turf)
			if(!istype(trench))
				return
			trench.unset_diged_ways(get_dir(trench, src))
			trench.update_overlays()

/obj/structure/trench/proc/set_diged_ways(dir)
	diged["[dir]"] = world.time + 60 MINUTES
	update_overlays()

/obj/structure/trench/proc/unset_diged_ways(dir)
	diged["[dir]"] = 0
	update_overlays()


/obj/structure/trench/update_overlays()
	. = ..()
	var/new_overlay = ""
	for(var/i in diged)
		if(diged[i] > world.time)
			new_overlay += i
			icon_state = null
	overlays += "[new_overlay]"


/obj/structure/trench/process()
	for(var/direction in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(src, direction)
		if(!istype(cardinal_turf, /turf/open/water))
			continue

		var/turf/open/water/water = cardinal_turf
		var/spreads_left = FLOOR(water.water_volume * 0.1, 1) - 1
		if(!spreads_left)
			continue
		if(istype(water, /turf/open/water/river))
			if(water.dir == direction)
				continue

		var/turf/open/water/river/creatable/W = new(get_turf(src))
		W.water_reagent = water.water_reagent
		W.try_set_parent(water)
		W.update_icon()
		W.dir = GLOB.reverse_dir[direction]
		playsound(W, 'sound/foley/waterenter.ogg', 100, FALSE)
		qdel(src)
		return
