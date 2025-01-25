/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()
//skull
/atom/movable/screen/ghost/orbit/rogue
	name = "AFTER LIFE"
	icon = 'icons/mob/ghostspin.dmi'
	icon_state = ""
	screen_loc = "WEST-4,SOUTH+6"
	nomouseover = FALSE

/atom/movable/screen/ghost/orbit/rogue/Click(location, control, params)
	var/mob/dead/observer/G = usr
	var/paramslist = params2list(params)
	if(paramslist["right"]) // screen objects don't do the normal Click() stuff so we'll cheat
		if(G.client?.holder)
			G.follow()
	else
		if(G.isinhell)
			return
		if(G.client)
			if(G.client.holder)
				if(istype(G, /mob/dead/observer/rogue/arcaneeye))
					return
				if(istype(G, /mob/dead/observer/profane)) // Souls trapped by a dagger can return to lobby if they want, at the cost of a triumph.
					if(alert("Return to the lobby? This will cost a triumph!", "", "Yes", "No") == "Yes")
						G.returntolobby()
						G.adjust_triumphs(-1)
				G.client.descend()
				return

//		var/take_triumph = FALSE
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(istype(C))
			if(C.skeletons)
				G.returntolobby()
		G.client.descend()
/*		if(world.time < G.ghostize_time + RESPAWNTIME)
			var/ttime = round((G.ghostize_time + RESPAWNTIME - world.time) / 10)
			var/list/thingsz = list("My connection to the world is still too strong.",\
			"I'm not ready to leave...", "I'm not ready to travel with Charon.",\
			"Don't make me leave!", "No... Not yet!", "Please, don't make me go yet...",\
			"The shores are calling me but I cannot go...","My soul isn't ready yet...")
			to_chat(G, "<span class='warning'>[pick(thingsz)] ([ttime])</span>")
			return */ //Disabling this since the underworld will exist

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using =  new /atom/movable/screen/backhudl/ghost()
	using.hud = src
	static_inventory += using

	scannies = new /atom/movable/screen/scannies
	scannies.hud = src
	static_inventory += scannies
	if(owner.client?.prefs?.crt == TRUE)
		scannies.alpha = 70

	using = new /atom/movable/screen/ghost/orbit/rogue()
	using.hud = src
	static_inventory += using

/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client.prefs.ghost_hud)
		screenmob.client.screen -= static_inventory
	else
		screenmob.client.screen += static_inventory

/datum/hud/eye/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using =  new /atom/movable/screen/backhudl/ghost()
	using.hud = src
	static_inventory += using

	scannies = new /atom/movable/screen/scannies
	scannies.hud = src
	static_inventory += scannies
	if(owner.client?.prefs?.crt == TRUE)
		scannies.alpha = 70

/datum/hud/eye/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client.prefs.ghost_hud)
		screenmob.client.screen -= static_inventory
	else
		screenmob.client.screen += static_inventory

/datum/hud/obs/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using =  new /atom/movable/screen/backhudl/obs()
	using.hud = src
	static_inventory += using

	scannies = new /atom/movable/screen/scannies
	scannies.hud = src
	static_inventory += scannies
	if(owner.client?.prefs?.crt == TRUE)
		scannies.alpha = 70
