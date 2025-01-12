/obj/item/paper/scroll
	name = "parchment scroll"
	icon_state = "scroll"
	var/open = FALSE
	slot_flags = null
	dropshrink = 0.6
	firefuel = 30 SECONDS
	sellprice = 2
	textper = 108
	maxlen = 2000
	throw_range = 3


/obj/item/paper/scroll/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(istype(P, /obj/item/natural/thorn) || istype(P, /obj/item/natural/feather))
		if(!open)
			to_chat(user, "<span class='warning'>Open me.</span>")
			return
	..()

/obj/item/paper/scroll/getonmobprop(tag)
	. = ..()
	if(tag)
		if(open)
			switch(tag)
				if("gen")
					return list("shrink" = 0.3,"sx" = 0,"sy" = -1,"nx" = 13,"ny" = -1,"wx" = 4,"wy" = 0,"ex" = 7,"ey" = -1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 2,"sflip" = 0,"wflip" = 0,"eflip" = 8)
				if("onbelt")
					return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
		else
			switch(tag)
				if("gen")
					return list("shrink" = 0.4,"sx" = 0,"sy" = 0,"nx" = 13,"ny" = 1,"wx" = 0,"wy" = 2,"ex" = 5,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 63,"wturn" = -27,"eturn" = 63,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
				if("onbelt")
					return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/paper/scroll/attack_self(mob/user)
	if(mailer)
		user.visible_message("<span class='notice'>[user] opens the missive from [mailer].</span>")
		mailer = null
		mailedto = null
		update_icon()
		return
	if(!open)
		attack_right(user)
		return
	..()
	user.update_inv_hands()

/obj/item/paper/scroll/read(mob/user)
	if(!open)
		to_chat(user, "<span class='info'>Open me.</span>")
		return
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		if(info)
			user.mind.adjust_experience(/datum/skill/misc/reading, 2, FALSE)
		return
	/*font-size: 125%;*/
	if(in_range(user, src) || isobserver(user))
		user.hud_used.reads.icon_state = "scroll"
		user.hud_used.reads.show()
		user.hud_used.reads.maptext = info
		user.hud_used.reads.maptext_width = 230
		user.hud_used.reads.maptext_height = 200
		user.hud_used.reads.maptext_y = 150
		user.hud_used.reads.maptext_x = 120

		onclose(user, "reading", src)
	else
		return "<span class='warning'>I'm too far away to read it.</span>"

/obj/item/paper/scroll/Initialize()
	open = FALSE
	update_icon_state()
	..()

/obj/item/paper/scroll/rmb_self(mob/user)
	attack_right(user)
	return

/obj/item/paper/scroll/attack_right(mob/user)
	if(open)
		slot_flags |= ITEM_SLOT_HIP
		open = FALSE
		playsound(src, 'sound/items/scroll_close.ogg', 100, FALSE)
	else
		slot_flags &= ~ITEM_SLOT_HIP
		open = TRUE
		playsound(src, 'sound/items/scroll_open.ogg', 100, FALSE)
	update_icon_state()
	user.update_inv_hands()

/obj/item/paper/scroll/update_icon_state()
	if(mailer)
		icon_state = "scroll_prep"
		open = FALSE
		name = "missive"
		slot_flags |= ITEM_SLOT_HIP
		throw_range = 7
		return
	throw_range = initial(throw_range)
	if(open)
		if(info)
			icon_state = "scrollwrite"
		else
			icon_state = "scroll"
		name = initial(name)
	else
		icon_state = "scroll_closed"
		name = "scroll"

/obj/item/paper/scroll/cargo
	name = "shipping order"
	icon_state = "contractunsigned"
	var/signedname
	var/signedjob
	var/list/orders = list()
	var/list/fufilled_orders = list()
	open = TRUE
	textper = 150

/obj/item/paper/scroll/cargo/Destroy()
	for(var/datum/supply_pack/SO in orders)
		orders -= SO
	return ..()

/obj/item/paper/scroll/cargo/examine(mob/user)
	. = ..()
	if(signedname)
		. += "It was signed by [signedname] the [signedjob]."

	//for each order, add up total price and display orders

/obj/item/paper/scroll/cargo/update_icon_state()
	if(open)
		if(signedname)
			icon_state = "contractsigned"
		else
			icon_state = "contractunsigned"
		name = initial(name)
	else
		icon_state = "scroll_closed"
		name = "scroll"


/obj/item/paper/scroll/cargo/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(istype(P, /obj/item/natural/feather))
		if(user.is_literate() && open)
			if(signedname)
				to_chat(user, "<span class='warning'>[signedname]</span>")
				return
			switch(alert("Sign your name?",,"Yes","No"))
				if("Yes")
					if(user.mind && user.mind.assigned_role)
						if(do_after(user, 20, target = src))
							signedname = user.real_name
							signedjob = user.mind.assigned_role
							icon_state = "contractsigned"
							user.visible_message("<span class='notice'>[user] signs the [src].</span>")
							update_icon_state()
							playsound(src, 'sound/items/write.ogg', 100, FALSE)
							rebuild_info()
				if("No")
					return

/obj/item/paper/scroll/cargo/proc/rebuild_info()
	info = null
	info += "<div style='vertical-align:top'>"
	info += "<h2 style='color:#06080F;font-family:\"Segoe Script\"'>Shipping Order</h2>"
	info += "<hr/>"

	if(orders.len)
		info += "<ul>"
		for(var/datum/supply_pack/A in orders)
			if(!A.contraband)
				info += "<li style='color:#06080F;font-size:11px;font-family:\"Segoe Script\"'>[A.name] - [A.cost] mammons</li><br/>"
			else
				info += "<li style='color:#610018;font-size:11px;font-family:\"Segoe Script\"'>[A.name] - [A.cost] mammons</li><br/>"
		info += "</ul>"

	info += "<br/></font>"

	if(signedname)
		info += "<font size=\"2\" face=\"[FOUNTAIN_PEN_FONT]\" color=#27293f>[signedname] the [signedjob] of Vanderlin</font>"

	info += "</div>"

/obj/item/paper/confession
	name = "confession"
	icon_state = "confession"
	desc = "A drab piece of parchment stained with the magical ink of the Order lodges. Looking at it fills you with profound guilt."
	info = "THE GUILTY PARTY ADMITS THEIR SINFUL NATURE AS ___. THEY WILL SERVE ANY PUNISHMENT OR SERVICE AS REQUIRED BY THE ORDER OF THE PSYCROSS UNDER PENALTY OF DEATH.<br/><br/>SIGNED,"
	var/signed = null
	var/antag = null // The literal name of the antag, like 'Bandit' or 'worshiper of Zizo'
	var/bad_type = null // The type of the antag, like 'OUTLAW OF THE THIEF-LORD'
	textper = 108
	maxlen = 2000
	var/confession_type = "antag" //for voluntary confessions

/obj/item/paper/confession/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(istype(P, /obj/item/natural/feather))
		var/response = alert(user, "What voluntary confession do I want?","","Villainy", "Faith")
		if(!response)
			return
		if(response == "Villainy")
			confession_type = "antag"
		else
			confession_type = "patron"

/obj/item/paper/confession/update_icon_state()
	if(mailer)
		icon_state = "paper_prep"
		name = "letter"
		throw_range = 7
		return
	name = initial(name)
	throw_range = initial(throw_range)
	if(signed)
		icon_state = "confessionsigned"
		return
	icon_state = "confession"

/obj/item/paper/confession/attack(mob/living/carbon/human/M, mob/user)
	testing("paper confession offer. target is [M], user is [user].")
	if(signed)
		return ..()
	if(M.stat >= UNCONSCIOUS) //unconscious cannot talk to confess, but soft crit can
		return
	to_chat(user, "<span class='info'>I courteously offer the confession to [M].</span>")
	var/input = alert(M, "Sign the confession of your true nature?", "CONFESSION OF [confession_type == "antag" ? "VILLAINY" : "FAITH"]", "Yes", "No")
	if(M.stat >= UNCONSCIOUS)
		return
	if(signed)
		return
	testing("[M] is signing the confession.")
	if(input == "Yes")
		to_chat(user, span_info("[M] has agreed to confess their true nature."))
		M.confess_sins(confession_type, resist=FALSE, user=user, torture=FALSE)
	else
		to_chat(user, span_warning("[M] refused to sign the confession!"))
	return

/obj/item/paper/confession/read(mob/user)
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		if(info)
			user.mind.adjust_experience(/datum/skill/misc/reading, 2, FALSE)
		return
	/*font-size: 125%;*/
	if(in_range(user, src) || isobserver(user))
		user.hud_used.reads.icon_state = "scroll"
		user.hud_used.reads.show()
		var/dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
					<html><head><style type=\"text/css\">
					body { background-image:url('book.png');background-repeat: repeat; }</style></head><body scroll=yes>"}
		dat += "[info]<br>"
		dat += "<a href='byond://?src=[REF(src)];close=1' style='position:absolute;right:50px'>Close</a>"
		dat += "</body></html>"
		user << browse(dat, "window=reading;size=460x300;can_close=0;can_minimize=0;can_maximize=0;can_resize=0;titlebar=0")
		onclose(user, "reading", src)
	else
		return "<span class='warning'>I'm too far away to read it.</span>"

/obj/item/merctoken
	name = "mercenary token"
	desc = "A small, palm-fitting bound scroll - a minuature writ of commendation for a mercenary under MGE. Present to a Guild representative for signing."
	icon_state = "merctoken"
	icon = 'icons/roguetown/items/misc.dmi'
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	dropshrink = 0.5
	firefuel = 30 SECONDS
	sellprice = 2
	throwforce = 0
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_MOUTH
	var/signee = null
	var/signeejob = null
	var/signed = 0

/obj/item/merctoken/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(istype(P, /obj/item/natural/thorn) || istype(P, /obj/item/natural/feather))
		if(!user.can_read(src))
			to_chat(user, "<span class='warning'>Even a reader would find these verba incomprehensible.</span>")
			return
		if(signed == 1)
			to_chat(user, "<span class='warning'>This token has already been signed.</span>")
			return
		if(user.can_read(src))
			if(user.mind.assigned_role == "Mercenary")
				to_chat(user, "<span class='warning'>Signing my own commendation would only befool me.</span>")
				return
			if(user.mind.assigned_role != "Merchant")
				to_chat(user, "<span class='warning'>This is incomprehensible.</span>")
				return
			if(user.mind.assigned_role == "Merchant")
				signee = user.real_name
				signeejob = user.mind.assigned_role
				visible_message("<span class='warning'>[user] writes their name down on the token.</span>")
				playsound(src, 'sound/items/write.ogg', 100, FALSE)
				desc = "A small, palm-fitting bound scroll that can be sent by mail to the Guild. Most of the fine print is unintelligible, save for one bold SIGNEE: [signee], [signeejob] of Enigma."
				signed = 1
				return
		else
			return


/obj/item/paper/scroll/frumentarii/roundstart/Initialize()
	. = ..()
	real_names |= GLOB.roundstart_court_agents


/obj/item/paper/scroll/frumentarii
	name = "List of Known Agents"
	desc = "A list of the Hand's fingers."

	var/list/real_names = list()
	var/list/removed_names = list()
	var/names = 12

/obj/item/paper/scroll/frumentarii/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(length(real_names) + length(removed_names) >= names)
		to_chat(user, span_notice("The scroll is full"))
		return

	if(!isliving(target))
		return
	var/mob/living/attacked_target = target

	if(attacked_target.real_name in real_names)
		return

	if(!attacked_target.client)
		return

	var/choice = input(attacked_target,"Do you list to become one of the Hand's fingers?","Binding Contract",null) as null|anything in list("Yes", "No")

	if(choice != "Yes")
		return

	real_names |= attacked_target.real_name
	removed_names -= attacked_target.real_name

	user.mind.cached_frumentarii |= attacked_target.real_name
	rebuild_info()


/obj/item/paper/scroll/frumentarii/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()
	if(istype(P, /obj/item/natural/thorn) || istype(P, /obj/item/natural/feather))
		var/remove = input(user,"Who are we removing from the fingers","Binding Contract",null) as null|anything in real_names
		if(remove)
			real_names -= remove
			removed_names |= remove

	rebuild_info()

/obj/item/paper/scroll/frumentarii/read(mob/user)
	. = ..()
	user.mind.cached_frumentarii |= real_names
	user.mind.cached_frumentarii -= removed_names

/obj/item/paper/scroll/frumentarii/proc/rebuild_info()
	info = null
	info += "<div style='vertical-align:top'>"
	info += "<h2 style='color:#06080F;font-family:\"Segoe Script\"'>Known Agents</h2>"
	info += "<hr/>"

	if(length(real_names))
		for(var/real_name in real_names)
			info += "<li style='color:#06080F;font-size:11px;font-family:\"Segoe Script\"'>[real_name]</li><br/>"

	if(length(removed_names))
		for(var/removed_name in removed_names)
			info += "<s><li style='color:#610018;font-size:11px;font-family:\"Segoe Script\"'>[removed_name]</li></s><br/>"

	info += "</div>"


/obj/item/paper/scroll/sold_manifest
	name = "Shipping Manifest"

	var/list/count = list()
	var/list/items = list()

/obj/item/paper/scroll/sold_manifest/proc/rebuild_info()
	info = null
	info += "<div style='vertical-align:top'>"
	info += "<h2 style='color:#06080F;font-family:\"Segoe Script\"'>Sold Items</h2>"
	info += "<hr/>"

	if(length(items))
		for(var/real_name in items)
			info += "<li style='color:#06080F;font-size:11px;font-family:\"Segoe Script\"'>[count[real_name]]x[real_name] - [items[real_name]] mammons</li><br/>"

	info += "</div>"

