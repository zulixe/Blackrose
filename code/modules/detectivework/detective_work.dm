//CONTAINS: Suit fibers and Detective's Scanning Computer

/atom/proc/return_fingerprints()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.fingerprints

/atom/proc/return_hiddenprints()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.hiddenprints

/atom/proc/return_blood_DNA()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.blood_DNA

/atom/proc/blood_DNA_length()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = length(D.blood_DNA)

/atom/proc/return_fibers()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.fibers

/atom/proc/add_fingerprint_list(list/fingerprints)		//ASSOC LIST FINGERPRINT = FINGERPRINT
	if(length(fingerprints))
		. = AddComponent(/datum/component/forensics, fingerprints)

//Set ignoregloves to add prints irrespective of the mob having gloves on.
/atom/proc/add_fingerprint(mob/M, ignoregloves = FALSE)
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	. = D.add_fingerprint(M, ignoregloves)

/atom/proc/add_fiber_list(list/fibertext)				//ASSOC LIST FIBERTEXT = FIBERTEXT
	if(length(fibertext))
		. = AddComponent(/datum/component/forensics, null, null, null, fibertext)

/atom/proc/add_fibers(mob/living/carbon/human/M)
	var/old = 0
	if(M.gloves && istype(M.gloves, /obj/item/clothing))
		var/obj/item/clothing/gloves/G = M.gloves
		old = length(G.return_blood_DNA())
		if(G.transfer_blood > 1) //bloodied gloves transfer blood to touched objects
			if(add_blood_DNA(G.return_blood_DNA()) && length(G.return_blood_DNA()) > old) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands > 1)
		old = length(M.return_blood_DNA())
		if(add_blood_DNA(M.return_blood_DNA()) && length(M.return_blood_DNA()) > old)
			M.bloody_hands--
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	. = D.add_fibers(M)

/atom/proc/add_hiddenprint_list(list/hiddenprints)	//NOTE: THIS IS FOR ADMINISTRATION FINGERPRINTS, YOU MUST CUSTOM SET THIS TO INCLUDE CKEY/REAL NAMES! CHECK FORENSICS.DM
	if(length(hiddenprints))
		. = AddComponent(/datum/component/forensics, null, hiddenprints)

/atom/proc/add_hiddenprint(mob/M)
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	. = D.add_hiddenprint(M)

/atom/proc/add_blood_DNA(list/dna)						//ASSOC LIST DNA = BLOODTYPE
	return FALSE

/atom
	/// Cached mixed color of all blood DNA on us
	VAR_PROTECTED/cached_blood_dna_color

/atom/proc/get_blood_dna_color()
	if(cached_blood_dna_color)
		return cached_blood_dna_color

	var/list/colors = list()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	var/list/all_dna = D?.blood_DNA
	for(var/dna_sample in all_dna)
		var/datum/blood_type/blood = GLOB.blood_types[all_dna[dna_sample]]
		colors += blood.color

	var/final_color = pop(colors)
	for(var/color in colors)
		final_color = BlendRGB(final_color, color, 0.5)
	cached_blood_dna_color = final_color
	return final_color

/obj/effect/decal/cleanable/blood/drip/get_blood_dna_color()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	var/list/all_dna = D?.blood_DNA
	return GLOB.blood_types[all_dna[all_dna[1]]]?.color

/obj/add_blood_DNA(list/dna)
	. = ..()
	if(length(dna))
		. = AddComponent(/datum/component/forensics, null, null, dna)

/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna)
	. = ..()
	transfer_blood = rand(2, 4)

/turf/add_blood_DNA(list/blood_dna)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src)
	B.add_blood_DNA(blood_dna) //give blood info to the blood decal.
	return TRUE //we bloodied the floor

/mob/living/carbon/human/add_blood_DNA(list/blood_dna)
	if(cloak)
		cloak.add_blood_DNA(blood_dna)
		update_inv_cloak()
	else if(wear_armor)
		wear_armor.add_blood_DNA(blood_dna)
		update_inv_armor()
	else if(wear_shirt)
		wear_shirt.add_blood_DNA(blood_dna)
		update_inv_shirt()
	else if(wear_pants)
		wear_pants.add_blood_DNA(blood_dna)
		update_inv_pants()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood_DNA(blood_dna)
	else if(length(blood_dna))
		AddComponent(/datum/component/forensics, null, null, blood_dna)
		bloody_hands = rand(2, 4)
	update_inv_gloves()	//handles bloody hands overlays and updating
	return TRUE

/atom/proc/transfer_fingerprints_to(atom/A)
	A.add_fingerprint_list(return_fingerprints())
	A.add_hiddenprint_list(return_hiddenprints())
	A.fingerprintslast = fingerprintslast
