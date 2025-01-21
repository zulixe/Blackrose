/obj/machinery/light/rogue/smelter
	icon = 'icons/roguetown/misc/forge.dmi'
	name = "stone furnace"
	desc = "A stone furnace, weathered by time and heat."
	icon_state = "cavesmelter0"
	base_state = "cavesmelter"
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	climb_time = 0
	climb_offset = 10
	on = TRUE
	var/list/ore = list()
	var/maxore = 1
	var/cooking = 0
	var/actively_smelting = FALSE // Are we currently smelting?
	fueluse = 5 MINUTES
	crossfire = FALSE

/obj/machinery/light/rogue/smelter/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/rogueweapon/tongs))
		if(!actively_smelting) // Prevents an exp gain exploit. - Foxtrot
			var/obj/item/rogueweapon/tongs/T = W
			if(ore.len && !T.hingot)
				var/obj/item/I = ore[ore.len]
				ore -= I
				I.forceMove(T)
				T.hingot = I
				if(user.mind && isliving(user) && T.hingot?.smeltresult) // Prevents an exploit with coal and runtimes with everything else
					if(!istype(T.hingot, /obj/item/rogueore) && T.hingot?.smelted) // Burning items to ash won't level smelting.
						var/mob/living/L = user
						var/boon = user.mind.get_learning_boon(/datum/skill/craft/smelting)
						var/amt2raise = L.STAINT*2 // Smelting is already a timesink, this is justified to accelerate levelling
						if(amt2raise > 0)
							user.mind.adjust_experience(/datum/skill/craft/smelting, amt2raise * boon, FALSE)
				user.visible_message("<span class='info'>[user] retrieves [I] from [src].</span>")
				if(on)
					var/tyme = world.time
					T.hott = tyme
					addtimer(CALLBACK(T, TYPE_PROC_REF(/obj/item/rogueweapon/tongs, make_unhot), tyme), 50)
				T.update_icon()
				return
			if(on)
				to_chat(user, "<span class='info'>Nothing to retrieve from inside.</span>")
				return // Safety for not smelting our tongs
		else
			to_chat(user, "<span class='warning'>\The [src] is currently smelting. Wait for it to finish, or douse it with water to retrieve items from it.</span>")
			return

	if(istype(W, /obj/item/rogueore/coal))
		if(alert(usr, "Fuel \the [src] with [W]?", "VANDERLIN", "Fuel", "Smelt") == "Fuel")
			return ..()
	if(W.smeltresult)
		if(ore.len < maxore)
			if(!(W in user.held_items) || !user.temporarilyRemoveItemFromInventory(W))
				return
			W.forceMove(src)
			ore += W
			if(!isliving(user) || !user.mind)
				ore[W] = SMELTERY_LEVEL_SPOIL
			else
				var/datum/mind/smelter_mind = user.mind // Who smelted the ore?
				var/smelter_exp = smelter_mind.get_skill_level(/datum/skill/craft/smelting) // 0 to 6
				if(smelter_exp < 6)
					ore[W] = floor(rand(smelter_exp*15, max(63, smelter_exp*25))/25) // Math explained below
				else
					ore[W] = floor(min(3, smelter_exp)) // Guarantees a return of 3 no matter how extra experience past 3000 you have.
				/*
				RANDOMLY PICKED NUMBER ACCORDING TO SMELTER SKILL:
					NO SKILL: 		between 00 and 63
					WEAK:	 		between 15 and 63
					AVERAGE:	 	between 30 and 63
					SKILLED: 		between 45 and 75
					EXPERT: 		between 60 and 100
					MASTER: 		between 75 and 125
					LEGENDARY: 		between 90 and 150

				PICKED NUMBER GETS DIVIDED BY 25 AND ROUNDED DOWN TO CLOSEST INTEGER.
				RESULT DETERMINES QUALITY OF BAR. SEE code/__DEFINES/skills.dm
					0 = SPOILED
					1 = POOR
					2 = NORMAL
					3 = GOOD
				*/
			user.visible_message("<span class='warning'>[user] puts something in \the [src].</span>")
			cooking = 0
			return
		else
			to_chat(user, "<span class='warning'>\The [W.name] [W.smeltresult? "can" : "can't"] be smelted, but \the [src] is full.</span>")
	else
		if(!W.firefuel && !istype(W, /obj/item/flint) && !istype(W, /obj/item/flashlight/flare/torch) && !istype(W, /obj/item/rogueore/coal))
			to_chat(user, "<span class='warning'>\The [W.name] cannot be smelted.</span>")
	return ..()

// Gaining experience from just retrieving bars with your hands would be a hard-to-patch exploit.
/obj/machinery/light/rogue/smelter/attack_hand(mob/user, params)
	if(on)
		to_chat(user, "<span class='warning'>It's too hot to retrieve bars with your hands.</span>")
		return
	if(ore.len)
		var/obj/item/I = ore[ore.len]
		ore -= I
		I.loc = user.loc
		user.put_in_active_hand(I)
		user.visible_message("<span class='info'>[user] retrieves \the [I] from \the [src].</span>")
	else
		return ..()


/obj/machinery/light/rogue/smelter/process()
	..()
	if(maxore > 1)
		return
	if(on)
		if(ore.len)
			if(cooking < 20)
				cooking++
				playsound(src.loc,'sound/misc/smelter_sound.ogg', 50, FALSE)
				actively_smelting = TRUE
			else
				if(cooking == 20)
					for(var/obj/item/I in ore)
						if(I.smeltresult)
							var/obj/item/R = new I.smeltresult(src, ore[I])
							ore -= I
							ore += R
							qdel(I)
					playsound(src,'sound/misc/smelter_fin.ogg', 100, FALSE)
					visible_message("<span class='notice'>\The [src] finished smelting.</span>")
					cooking = 21
					actively_smelting = FALSE

/obj/machinery/light/rogue/smelter/burn_out()
	cooking = 0
	actively_smelting = FALSE
	..()

/obj/machinery/light/rogue/smelter/great
	icon = 'icons/roguetown/misc/forge.dmi'
	name = "great furnace"
	desc = "The pinnacle of dwarven engineering and the miracle of Malum's blessed fire crystal, allowing for greater alloys to be made."
	icon_state = "smelter0"
	base_state = "smelter"
	anchored = TRUE
	density = TRUE
	maxore = 4
	fueluse = 5 MINUTES
	climbable = FALSE

/obj/machinery/light/rogue/smelter/great/process()
	..()
	if(on)
		if(ore.len)
			if(cooking < 30)
				cooking++
				playsound(src.loc,'sound/misc/smelter_sound.ogg', 50, FALSE)
				actively_smelting = TRUE
			else
				if(cooking == 30)
					var/alloy //moving each alloy to it's own var allows for possible additions later
					var/steelalloy
					var/bronzealloy
					var/blacksteelalloy

					for(var/obj/item/I in ore)
						if(I.smeltresult == /obj/item/rogueore/coal)
							steelalloy = steelalloy + 1
						if(I.smeltresult == /obj/item/ingot/iron)
							steelalloy = steelalloy + 2
						if(I.smeltresult == /obj/item/ingot/tin)
							bronzealloy = bronzealloy + 1
						if(I.smeltresult == /obj/item/ingot/copper)
							bronzealloy = bronzealloy + 2
						if(I.smeltresult == /obj/item/ingot/silver)
							blacksteelalloy = blacksteelalloy + 1
						if(I.smeltresult == /obj/item/ingot/steel)
							blacksteelalloy = blacksteelalloy + 2

					if(steelalloy == 7)
						testing("STEEL ALLOYED")
						alloy = /obj/item/ingot/steel
					else if(bronzealloy == 7)
						testing("BRONZE ALLOYED")
						alloy = /obj/item/ingot/bronze
					else if(blacksteelalloy == 7)
						testing("BLACKSTEEL ALLOYED")
						alloy = /obj/item/ingot/blacksteel
					else
						alloy = null
					if(alloy)
						// The smelting quality of all ores added together, divided by the number of ores, and then rounded to the lowest integer (this isn't done until after the for loop)
						var/floor_mean_quality = SMELTERY_LEVEL_SPOIL
						var/ore_deleted = 0
						for(var/obj/item/I in ore)
							floor_mean_quality += ore[I]
							ore_deleted += 1
							ore -= I
							qdel(I)
						floor_mean_quality = floor(floor_mean_quality/ore_deleted)
						for(var/i in 1 to maxore)
							var/obj/item/R = new alloy(src, floor_mean_quality)
							ore += R
					else
						for(var/obj/item/I in ore)
							if(I.smeltresult)
								var/obj/item/R = new I.smeltresult(src, ore[I])
								ore -= I
								ore += R
								qdel(I)
					playsound(src,'sound/misc/smelter_fin.ogg', 100, FALSE)
					visible_message("<span class='notice'>\The [src] finished smelting.</span>")
					cooking = 31
					actively_smelting = FALSE
