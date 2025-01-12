/datum/rotation_network
	var/total_stress = 0
	var/used_stress = 0
	var/overstressed = FALSE
	var/rebuilding = FALSE

	var/list/connected = list()

/datum/rotation_network/proc/add_connection(obj/structure/incoming)
	connected |= incoming
	incoming.rotation_network = src

/datum/rotation_network/proc/remove_connection(obj/structure/incoming)
	if(incoming.stress_generation)
		total_stress -= incoming.stress_generation
	if(incoming.last_stress_added)
		used_stress -= incoming.last_stress_added
	incoming.rotation_network = null
	connected -= incoming

/datum/rotation_network/proc/check_stress()
	if(rebuilding)
		return
	if(total_stress < used_stress)
		breakdown()
	else if(overstressed)
		restore()

/datum/rotation_network/proc/breakdown()
	overstressed = TRUE
	for(var/obj/structure/child in connected)
		child.MakeParticleEmitter(/particles/sparks, FALSE, 1 SECONDS)
	update_animation_effect()

/datum/rotation_network/proc/restore()
	overstressed = FALSE
	update_animation_effect()

/datum/rotation_network/proc/update_animation_effect()
	for(var/obj/structure/child in connected)
		child.update_animation_effect()

/datum/rotation_network/proc/rebuild_group()
	rebuilding = TRUE
	var/list/producers = list()
	for(var/obj/structure/child in connected)
		if(!child.stress_generator)
			child.rotation_direction = null
			child.set_rotations_per_minute(0)
			child.set_stress_use(0)
			continue
		producers |= child

	for(var/obj/structure/producer in producers)
		producer.find_and_propagate(list(), TRUE)
	update_animation_effect()
	rebuilding = FALSE

/datum/rotation_network/proc/reassess_group(obj/structure/deleted)
	var/list/returned_nearbys = deleted.return_surrounding_rotation(src)
	var/list/connected_copy = connected.Copy()

	for(var/obj/structure/near in returned_nearbys)
		var/list/returned = near.return_connected(deleted, list(), src)
		connected_copy -= deleted
		if(length(connected_copy) == length(returned))
			rebuild_group()
			return
		var/datum/rotation_network/new_network = new
		var/list/dealt_with = list()
		for(var/obj/structure/returned_object in returned)
			remove_connection(returned_object)
			new_network.add_connection(returned_object)
			if(!(returned_object in dealt_with))
				if(returned_object.stress_use)
					new_network.used_stress += returned_object.stress_use
					returned_object.set_stress_use(returned_object.stress_use)
				if(returned_object.stress_generator)
					new_network.total_stress += returned_object.stress_generation
					returned_object.set_stress_generation(returned_object.stress_generation)
			dealt_with |= returned_object
		new_network.rebuild_group()

	if(!length(connected))
		qdel(src)
		return
	rebuild_group()
