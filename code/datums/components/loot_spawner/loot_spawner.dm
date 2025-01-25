/atom/proc/CanLoot(mob/living/looter)
	return TRUE

/obj/structure/closet/CanLoot(mob/living/looter)
	if(!opened)
		return FALSE
	return TRUE

/datum/component/loot_spawner
	var/max_spawns = 3
	var/spawns_per_person = 1

	var/list/takers = list()

	///if set to spawn another item we need to reset it with this item
	var/obj/item/resetting_item
	///have we been reset
	var/needs_reset = FALSE

	///our loot_table
	var/datum/loot_table/loot
	///trigger loot on break
	var/spawn_loot_on_break = TRUE

	var/action_time = 2 SECONDS
	var/action_text = "starts sifting through"

/datum/component/loot_spawner/Initialize(datum/loot_table/table, max_spawns = 3, spawns_per_person = 1, spawn_loot_on_break = TRUE, action_time = 2 SECONDS, action_text = "starts sifting through", obj/item/resetting_item)
	. = ..()
	if(!table)
		return COMPONENT_INCOMPATIBLE

	loot = new table
	src.max_spawns = max_spawns
	src.spawns_per_person = spawns_per_person
	src.spawn_loot_on_break = spawn_loot_on_break
	src.action_time = action_time
	src.action_text = action_text
	src.resetting_item = resetting_item

/datum/component/loot_spawner/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(handle_loot_attempt))
	if(resetting_item)
		RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(handle_reset_attempt))

/datum/component/loot_spawner/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)
	if(resetting_item)
		UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)


/datum/component/loot_spawner/proc/handle_loot_attempt(atom/source, mob/user)
	if(!source.CanLoot(user))
		return NONE
	if(needs_reset)
		return NONE
	if(user in takers)
		if(takers[user] >= spawns_per_person)
			return NONE
	INVOKE_ASYNC(src, PROC_REF(start_loot), source, user)
	return COMPONENT_NO_ATTACK_HAND

/datum/component/loot_spawner/proc/handle_reset_attempt(atom/source, obj/item/L, mob/living/user)
	if(!needs_reset)
		return NONE
	if(istype(L, resetting_item))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(start_reset), source, L, user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/loot_spawner/proc/start_loot(atom/source, mob/user)
	user.visible_message("[user] [action_text] [parent].")
	if(!do_after(user, action_time, target = source))
		return
	loot.spawn_loot(user)

	if(resetting_item)
		needs_reset = TRUE
	takers |= user
	takers[user]++
	SEND_SIGNAL(parent, COMSIG_PARENT_TRAP_TRIGGERED, user)

/datum/component/loot_spawner/proc/start_reset(atom/source, obj/item/L, mob/living/user)
	if(!do_after(user, action_time, target = source))
		return
	needs_reset = FALSE
