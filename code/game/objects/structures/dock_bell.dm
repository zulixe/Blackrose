/obj/structure/dock_bell
	name = "Dock Bell"
	desc = "A loud bell that carries its sound to the nearby ports. Signals to merchants that the dock has wares to sell."


	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "dock_bell"


	COOLDOWN_DECLARE(ring_bell)
	COOLDOWN_DECLARE(outsider_ring_bell)
	var/static/approved_jobs = list(/datum/job/roguetown/merchant, /datum/job/roguetown/grabber, /datum/job/roguetown/steward)
	max_integrity = 999999

/obj/structure/dock_bell/examine(mob/user)
	. = ..()
	. += span_info("The dock bell can be rung by sanctioned workers in [COOLDOWN_TIMELEFT(src, ring_bell)] seconds.")
	. += span_info("The dock bell can be rung by outsiders in [COOLDOWN_TIMELEFT(src, outsider_ring_bell)] seconds.")

/obj/structure/dock_bell/attack_hand(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, ring_bell))
		return
	var/datum/job/user_job = SSjob.GetJob(user.job)
	if(user_job && !(initial(user_job.type) in approved_jobs))
		if(!COOLDOWN_FINISHED(src, outsider_ring_bell))
			return
	if(!do_after(user, 5 SECONDS, target = src))
		return
	if(!COOLDOWN_FINISHED(src, ring_bell))
		return
	visible_message(span_notice("[user] starts ringing the dock bell."))
	playsound(get_turf(src), 'sound/misc/handbell.ogg', 50, 1)
	if(!SSmerchant.cargo_docked && SSmerchant.cargo_boat.check_living())
		SSmerchant.send_cargo_ship_back()
	else if(SSmerchant.cargo_docked)
		SSmerchant.prepare_cargo_shipment()
	COOLDOWN_START(src, ring_bell, 3 MINUTES)
	COOLDOWN_START(src, outsider_ring_bell, 20 MINUTES)
