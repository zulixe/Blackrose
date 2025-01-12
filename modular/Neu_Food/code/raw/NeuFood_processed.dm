/* * * * * * * * * * * **
 *						*
 *		 NeuFood		*
 *	    (Preserves)		*
 *						*
 * * * * * * * * * * * **/

// -------------- FAT -----------------
/obj/item/reagent_containers/food/snacks/fat
	icon = 'modular/Neu_Food/icons/food.dmi'
	name = "fat"
	desc = ""
	icon_state = "fat"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	eat_effect = /datum/status_effect/debuff/uncookedfood
/obj/item/reagent_containers/food/snacks/fat/attackby(obj/item/I, mob/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(user.mind)
		short_cooktime = (50 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*5))
		long_cooktime = (90 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*10))
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/meat/mince))
		if(isturf(loc)&& (found_table))
			to_chat(user, "<span class='notice'>Stuffing a wiener...</span>")
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,long_cooktime, target = src))
				new /obj/item/reagent_containers/food/snacks/rogue/meat/sausage(loc)
				user.mind.adjust_experience(/datum/skill/craft/cooking, SIMPLE_COOKING_XPGAIN, FALSE)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	else
		return ..()

// -------------- SPIDER HONEY -----------------
/obj/item/reagent_containers/food/snacks/rogue/honey
	name = "spider honey"
	icon = 'modular/Neu_Food/icons/food.dmi'
	icon_state = "spiderhoney"
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("sweetness and spiderwebs" = 1)
	eat_effect = null
	rotprocess = null

// -------------- RAISINS -----------------
/obj/item/reagent_containers/food/snacks/rogue/raisins
	name = "raisins"
	icon = 'modular/Neu_Farming/icons/produce.dmi'
	icon_state = "raisins5"
	bitesize = 5
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("dried fruit" = 1)
	foodtype = GRAIN
	eat_effect = null
	rotprocess = null

/obj/item/reagent_containers/food/snacks/rogue/raisins/On_Consume(mob/living/eater)
	..()
	if(bitecount == 1)
		icon_state = "raisins4"
	if(bitecount == 2)
		icon_state = "raisins3"
	if(bitecount == 3)
		icon_state = "raisins2"
	if(bitecount == 4)
		icon_state = "raisins1"

/obj/item/reagent_containers/food/snacks/rogue/raisins/CheckParts(list/parts_list, datum/crafting_recipe/R)
	..()
	for(var/obj/item/reagent_containers/food/snacks/M in parts_list)
		color = M.filling_color
		if(M.reagents)
			M.reagents.remove_reagent(/datum/reagent/consumable/nutriment, M.reagents.total_volume)
			M.reagents.trans_to(src, M.reagents.total_volume)
		qdel(M)

/obj/item/reagent_containers/food/snacks/rogue/raisins/poison
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR, /datum/reagent/berrypoison = 4)
	tastes = list("bitter dried fruit" = 1)


// -------------- SALUMOI (dwarven smoked sausage) -----------------
/obj/item/reagent_containers/food/snacks/rogue/meat/salami
	name = "salumoi"
	desc = "Traveling food invented by dwarves. Said to last for ten yils before spoiling"
	icon_state = "salumoi5"
	eat_effect = null
	fried_type = null
	slices_num = 4
	bitesize = 5
	slice_batch = FALSE
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_NUTRITIOUS)
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice
	tastes = list("salted meat" = 1)
	rotprocess = null
	slice_sound = TRUE

/obj/item/reagent_containers/food/snacks/rogue/meat/salami/update_icon()
	if(slices_num)
		icon_state = "salumoi[slices_num]"
	else
		icon_state = "salumoi_slice"

/obj/item/reagent_containers/food/snacks/rogue/meat/salami/On_Consume(mob/living/eater)
	..()
	if(slices_num)
		if(bitecount == 1)
			slices_num = 4
		if(bitecount == 2)
			slices_num = 3
		if(bitecount == 3)
			slices_num = 2
		if(bitecount == 4)
			changefood(slice_path, eater)

/obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice
	eat_effect = null
	slices_num = 0
	name = "salumoi"
	icon_state = "salumoi_slice"
	fried_type = null
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)
	bitesize = 1
	tastes = list("salted meat" = 1)

// -------------- COPPIETTE (dried meat) -----------------
/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette
	eat_effect = null
	name = "coppiette"
	icon_state = "jerk5"
	desc = "Dried meat sticks."
	fried_type = null
	bitesize = 5
	slice_path = null
	tastes = list("salted meat" = 1)
	rotprocess = null
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_NUTRITIOUS)

/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette/On_Consume(mob/living/eater)
	..()
	if(bitecount == 1)
		icon_state = "jerk4"
	if(bitecount == 2)
		icon_state = "jerk3"
	if(bitecount == 3)
		icon_state = "jerk2"
	if(bitecount == 4)
		icon_state = "jerk1"

// -------------- SALTFISH -----------------
/obj/item/reagent_containers/food/snacks/rogue/saltfish
	eat_effect = null
	icon = 'icons/roguetown/misc/fish.dmi'
	name = "saltfish"
	icon_state = ""
	desc = "Dried fish."
	fried_type = null
	bitesize = 4
	slice_path = null
	tastes = list("salted meat" = 1)
	rotprocess = null
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_NUTRITIOUS)
	dropshrink = 0.6

/obj/item/reagent_containers/food/snacks/rogue/saltfish/CheckParts(list/parts_list, datum/crafting_recipe/R)
	for(var/obj/item/reagent_containers/food/snacks/M in parts_list)
		icon_state = "[initial(M.icon_state)]dried"
		qdel(M)

// -------------- SALO (salted fat) -----------------
/obj/item/reagent_containers/food/snacks/fat/salo
	name = "salo"
	icon_state = "salo4"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12)
	bitesize = 4
	slice_path = /obj/item/reagent_containers/food/snacks/fat/salo/slice
	slices_num = 4
	slice_batch = FALSE
	slice_sound = TRUE
	eat_effect = null

/obj/item/reagent_containers/food/snacks/fat/salo/update_icon()
	if(slices_num)
		icon_state = "salo[slices_num]"
	else
		icon_state = "saloslice"

/obj/item/reagent_containers/food/snacks/fat/salo/On_Consume(mob/living/eater)
	..()
	if(slices_num)
		if(bitecount == 1)
			slices_num = 3
		if(bitecount == 2)
			slices_num = 2
		if(bitecount == 3)
			changefood(slice_path, eater)

/obj/item/reagent_containers/food/snacks/fat/salo/slice
	name = "salo"
	icon_state = "saloslice"
	bitesize = 2
	slices_num = FALSE
	slice_path = FALSE
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)



/*------------\
| Salted milk |
\------------*/		// The base for making butter and cheese

/datum/reagent/consumable/milk/gote
	taste_description = "gote milk"

/datum/reagent/consumable/milk/salted_gote
	taste_description = "salty gote-milk"

/datum/reagent/consumable/milk/salted
	taste_description = "salty milk"

/obj/item/reagent_containers/attackby(obj/item/I, mob/user, params) // add cook time to containers & salted milk for butter churning
	..()
	if(user.mind)
		short_cooktime = (70 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*5))
		long_cooktime = (120 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*10))
	if(istype(I, /obj/item/reagent_containers/powder/salt))
		if(!reagents.has_reagent(/datum/reagent/consumable/milk, 15) && !reagents.has_reagent(/datum/reagent/consumable/milk/gote, 15))
			to_chat(user, "<span class='warning'>Not enough milk.</span>")
			return
		to_chat(user, "<span class='warning'>Adding salt to the milk.</span>")
		playsound(src, pick('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg'), 100, FALSE)
		if(do_after(user,2 SECONDS, target = src))
			if(reagents.has_reagent(/datum/reagent/consumable/milk, 15))
				reagents.remove_reagent(/datum/reagent/consumable/milk, 15)
				reagents.add_reagent(/datum/reagent/consumable/milk/salted, 15)
			if(reagents.has_reagent(/datum/reagent/consumable/milk/gote, 15))
				reagents.remove_reagent(/datum/reagent/consumable/milk/gote, 15)
				reagents.add_reagent(/datum/reagent/consumable/milk/salted_gote, 15)
			qdel(I)



/*-------\
| Butter |
\-------*/

/*	............   Churning butter   ................ */
/obj/item/reagent_containers/glass/bucket/wooden/attackby(obj/item/I, mob/user, params)
	if(user.mind)
		long_cooktime = (200 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*20))
	if(istype(I, /obj/item/kitchen/spoon))
		if(!reagents.has_reagent(/datum/reagent/consumable/milk/salted, 15) && !reagents.has_reagent(/datum/reagent/consumable/milk/salted_gote, 15))
			to_chat(user, "<span class='warning'>Not enough salted milk.</span>")
			return
		user.adjust_stamina(40) // forgot stamina is our lovely stamloss proc here
		user.visible_message("<span class='info'>[user] churns butter...</span>")
		playsound(get_turf(user), 'modular/Neu_Food/sound/churn.ogg', 100, TRUE, -1)
		if(do_after(user,long_cooktime, target = src))
			user.adjust_stamina(50)
			if(reagents.has_reagent(/datum/reagent/consumable/milk/salted, 15))
				reagents.remove_reagent(/datum/reagent/consumable/milk/salted, 15)
			if(reagents.has_reagent(/datum/reagent/consumable/milk/salted_gote, 15))
				reagents.remove_reagent(/datum/reagent/consumable/milk/salted_gote, 15)
			new /obj/item/reagent_containers/food/snacks/butter(drop_location())
			user.mind.adjust_experience(/datum/skill/craft/cooking, COMPLEX_COOKING_XPGAIN, FALSE)
		return
	..()

// -------------- BUTTER -----------------
/obj/item/reagent_containers/food/snacks/butter
	icon = 'modular/Neu_Food/icons/food.dmi'
	name = "stick of butter"
	desc = ""
	icon_state = "butter6"
	list_reagents = list(/datum/reagent/consumable/nutriment = BUTTER_NUTRITION)
	foodtype = DAIRY
	slice_path = /obj/item/reagent_containers/food/snacks/butterslice
	slices_num = 6
	slice_batch = FALSE
	bitesize = 6
	slice_sound = TRUE

/obj/item/reagent_containers/food/snacks/butter/update_icon()
	if(slices_num)
		icon_state = "butter[slices_num]"
	else
		icon_state = "butter_slice"

/obj/item/reagent_containers/food/snacks/butter/On_Consume(mob/living/eater)
	..()
	if(slices_num)
		if(bitecount == 1)
			slices_num = 5
		if(bitecount == 2)
			slices_num = 4
		if(bitecount == 3)
			slices_num = 3
		if(bitecount == 4)
			slices_num = 2
		if(bitecount == 5)
			changefood(slice_path, eater)

/obj/item/reagent_containers/food/snacks/butterslice
	icon = 'modular/Neu_Food/icons/food.dmi'
	icon_state = "butter_slice"
	name = "butter"
	desc = ""
	foodtype = DAIRY
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)



/*-------\
| Cheese |
\-------*/

/*	............   Making fresh cheese   ................ */
/obj/item/reagent_containers/glass/bucket/wooden/attackby(obj/item/I, mob/user, params)
	if(user.mind)
		long_cooktime = (100 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*10))
	if(istype(I, /obj/item/natural/cloth))
		if(reagents.has_reagent(/datum/reagent/consumable/milk/salted, 5))
			user.visible_message("<span class='info'>[user] strains fresh cheese...</span>")
			playsound(src, pick('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg'), 100, FALSE)
			if(do_after(user,long_cooktime, target = src))
				reagents.remove_reagent(/datum/reagent/consumable/milk/salted, 5)
				user.mind.adjust_experience(/datum/skill/craft/cooking, COMPLEX_COOKING_XPGAIN, FALSE)
				new /obj/item/reagent_containers/food/snacks/rogue/cheese(drop_location())
		else if(reagents.has_reagent(/datum/reagent/consumable/milk/salted_gote, 5))
			user.visible_message("<span class='info'>[user] strains fresh cheese...</span>")
			playsound(src, pick('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg'), 100, FALSE)
			if(do_after(user,long_cooktime, target = src))
				reagents.remove_reagent(/datum/reagent/consumable/milk/salted_gote, 5)
				user.mind.adjust_experience(/datum/skill/craft/cooking, COMPLEX_COOKING_XPGAIN, FALSE)
				new /obj/item/reagent_containers/food/snacks/rogue/cheese/gote(drop_location())

		var/obj/item/natural/cloth/T = I
		if(T.wet && !T.return_blood_DNA())
			return
		else
			var/removereg = /datum/reagent/water
			if(!reagents.has_reagent(/datum/reagent/water, 5))
				removereg = /datum/reagent/water/gross
				if(!reagents.has_reagent(/datum/reagent/water/gross, 5))
					to_chat(user, "<span class='warning'>No water to soak in.</span>")
					return
			wash_atom(T)
			playsound(src, pick('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg'), 100, FALSE)
			reagents.remove_reagent(removereg, 5)
			user.visible_message("<span class='info'>[user] soaks [T] in [src].</span>")
			return
	..()

/*	............   Making cheese wheel   ................ */
/obj/item/natural/cloth/attackby(obj/item/I, mob/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/cheese))
		if(isturf(loc)&& (found_table))
			user.visible_message("<span class='info'>[user] starts packing the cloth with fresh cheese...</span>")
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 30, TRUE, -1)
			if(do_after(user,3 SECONDS, target = src))
				new /obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_start(loc)
				user.mind.adjust_experience(/datum/skill/craft/cooking, SIMPLE_COOKING_XPGAIN, FALSE)
				qdel(I)
				qdel(src)
			return
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	..()

/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_start
	name = "unfinished cheese wheel"
	icon_state = "cheesewheel_1"
	w_class = WEIGHT_CLASS_BULKY
/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_start/attackby(obj/item/I, mob/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(user.mind)
		short_cooktime = (50 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*5))
		long_cooktime = (90 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*10))
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/cheese))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 30, TRUE, -1)
			if(do_after(user,short_cooktime, target = src))
				new /obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_two(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	else
		return ..()

/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_two
	name = "unfinished cheese wheel"
	icon_state = "cheesewheel_2"
	w_class = WEIGHT_CLASS_BULKY
/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_two/attackby(obj/item/I, mob/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(user.mind)
		short_cooktime = (50 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*5))
		long_cooktime = (90 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*10))
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/cheese))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 30, TRUE, -1)
			if(do_after(user,short_cooktime, target = src))
				new /obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_three(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	else
		return ..()

/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_three
	name = "unfinished cheese wheel"
	icon_state = "cheesewheel_3"
	w_class = WEIGHT_CLASS_BULKY
	var/mature_proc = PROC_REF(maturing_done)

/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_three/attackby(obj/item/I, mob/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(user.mind)
		short_cooktime = (50 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*5))
		long_cooktime = (90 - ((user.mind.get_skill_level(/datum/skill/craft/cooking))*10))
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/cheese))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 30, TRUE, -1)
			if(do_after(user,short_cooktime, target = src))
				qdel(I)
				name = "maturing cheese wheel"
				icon_state = "cheesewheel_end"
				desc = "Slowly solidifying, best left alone a bit longer."
				addtimer(CALLBACK(src, mature_proc), 5 MINUTES)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	else
		return ..()

/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesewheel_three/proc/maturing_done()
	playsound(src.loc, 'modular/Neu_Food/sound/rustle2.ogg', 100, TRUE, -1)
	new /obj/item/reagent_containers/food/snacks/rogue/cheddar(loc)
	new /obj/item/natural/cloth(loc)
	qdel(src)


// -------------- CHEESE -----------------
/obj/item/reagent_containers/food/snacks/rogue/cheese
	name = "fresh cheese"
	icon_state = "freshcheese"
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = FRESHCHEESE_NUTRITION)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("cheese" = 1)
	foodtype = GRAIN
	eat_effect = null
	rotprocess = SHELFLIFE_DECENT
	become_rot_type = null
	slice_path = null

/obj/item/reagent_containers/food/snacks/rogue/cheese/gote
	name = "fresh gote cheese"

/obj/item/reagent_containers/food/snacks/rogue/cheddar
	name = "wheel of cheese"
	icon_state = "cheesewheel"
	bitesize = 6
	list_reagents = list(/datum/reagent/consumable/nutriment = FRESHCHEESE_NUTRITION*4)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("cheese" = 1)
	eat_effect = null
	rotprocess = SHELFLIFE_LONG
	slices_num = 6
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/cheddar/aged
	slice_sound = TRUE

/obj/item/reagent_containers/food/snacks/rogue/cheddar/aged
	name = "wheel of aged cheese"
	icon_state = "blue_cheese"
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge/aged
	become_rot_type = null
	rotprocess = null
	sellprice = 60

/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge
	name = "wedge of cheese"
	icon_state = "cheese_wedge"
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("cheese" = 1)
	eat_effect = null
	rotprocess = SHELFLIFE_LONG
	slices_num = 3
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarslice
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge/aged
	baitpenalty = 0
	isbait = TRUE
	fishloot = list(/obj/item/reagent_containers/food/snacks/fish/carp = 10,
					/obj/item/reagent_containers/food/snacks/fish/eel = 5,
					/obj/item/reagent_containers/food/snacks/fish/angler = 1)

/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge/aged
	name = "wedge of aged cheese"
	icon_state = "blue_cheese_wedge"
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarslice/aged
	become_rot_type = null
	rotprocess = null
	sellprice = 10

/obj/item/reagent_containers/food/snacks/rogue/cheddarslice
	name = "slice of cheese"
	icon_state = "cheese_slice"
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("cheese" = 1)
	eat_effect = null
	rotprocess = 20 MINUTES
	slices_num = null
	slice_path = null
	become_rot_type = null
	baitpenalty = 0
	isbait = TRUE
	fishloot = list(/obj/item/reagent_containers/food/snacks/fish/carp = 10,
					/obj/item/reagent_containers/food/snacks/fish/eel = 5)

/obj/item/reagent_containers/food/snacks/rogue/cheddarslice/aged
	name = "slice of aged cheese"
	icon_state = "blue_cheese_slice"
	become_rot_type = null
	rotprocess = null



