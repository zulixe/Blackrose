/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	hud_possible = list(ANTAG_HUD)
	hud_type = /datum/hud/human
	base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	possible_mmb_intents = list(INTENT_STEAL, INTENT_JUMP, INTENT_KICK, INTENT_BITE, INTENT_GIVE)
	can_buckle = TRUE
	buckle_lying = FALSE
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID

	ambushable = 1

	voice_pitch = 1

	var/footstep_type = FOOTSTEP_MOB_HUMAN

	var/last_sound //last emote so we have no doubles

	//Hair colour and style
	var/hair_color = "000"
	var/hairstyle = "Bald"

	//Facial hair colour and style
	var/facial_hair_color = "000"
	var/facial_hairstyle = "Shaved"

	//Eye colour
	var/eye_color = "000"

	var/voice_color = "a0a0a0"

	var/detail_color = "000"

	var/skin_tone = "caucasian1"	//Skin tone

	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = "Adult"		//Player's age

	var/underwear = "Nude"	//Which underwear the player wants
	var/underwear_color
	var/undershirt = "Nude" //Which undershirt the player wants

	var/cached_underwear = "Nude"

	var/accessory = "None"
	var/detail = "None"
	var/marking = "None"

	var/shavelevel = 0

	var/socks = "Nude" //Which socks the player wants

	//Equipment slots
	var/obj/item/clothing/skin_armor = null
	var/obj/item/clothing/wear_armor = null
	var/obj/item/clothing/wear_pants = null
	var/obj/item/belt = null
	var/obj/item/beltl = null
	var/obj/item/beltr = null
	var/obj/item/wear_ring = null
	var/obj/item/wear_wrists = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null
	var/obj/item/cloak = null
	var/obj/item/clothing/wear_shirt = null

	///for the intent of dodge this is your armor class that you have worn (its highest worn)
	var/worn_armor_class = ARMOR_CLASS_NONE

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/name_override //For temporary visible name changes

	var/datum/physiology/physiology

	var/list/datum/bioware = list()

	var/static/list/can_ride_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/simple_animal/parrot))
	var/lastpuke = 0
	var/last_fire_update
	var/account_id

	canparry = TRUE
	candodge = TRUE

	dodgecd = FALSE
	dodgetime = 0

	var/list/possibleclass = list()
	var/list/special_classes = list()
	var/list/shuffle_special= list()
	var/list/shuffle_combat = list()
	var/classesunlocked = FALSE
	var/advsetup = 0


//	var/alignment = ALIGNMENT_TN

	var/advjob = null
	var/canseebandits = FALSE

	//Familytree datum
	//I dont know how to do UI huds so this will have to do for now.
	var/family_UI = FALSE
	var/mob/living/carbon/spouse_mob
	var/image/spouse_indicator
	var/setspouse
	var/familytree_pref = FAMILY_NONE
	var/datum/heritage/family_datum
	var/list/temp_ui_list = list()

	var/has_stubble = TRUE

	var/original_name = null

	var/buried = FALSE // Whether the body is buried or not.
	var/funeral = FALSE // Whether the body has received rites or not.

	var/datum/devotion/cleric_holder/cleric = null // Used for cleric_holder for priests

	var/confession_points = 0 // Used to track how many confessions the Inquisitor has gotten signed. Used to buy items at mailboxes.
	var/purchase_history = null // Used to track what the Inquisitor has bought from the mailbox.
	var/has_confessed = FALSE // Used to track if they have confessed it was written onto a confession paper

	var/merctype = 0 // Used for mercenary backgrounds - check mail.dm
	var/tokenclaimed = FALSE // Check for one-time tri reward.

	// Boolean. Usually set only to TRUE for non-Eoran church roles.
	var/virginity = FALSE

	possible_rmb_intents = list(/datum/rmb_intent/feint,\
	/datum/rmb_intent/aimed,\
	/datum/rmb_intent/strong,\
	/datum/rmb_intent/swift,\
	/datum/rmb_intent/riposte,\
	/datum/rmb_intent/weak)

	rot_type = /datum/component/rot/corpse

//Checking the highest armor class worn
//Limb armors use the second highest armor class
/mob/living/carbon/human/proc/check_armor_class()
	//Get Torso values
	var/shirt_ac
	var/chest_ac
	var/torso_class = ARMOR_CLASS_NONE
	if(istype(src.wear_shirt, /obj/item/clothing))
		if(wear_shirt.armor_class)
			shirt_ac = wear_shirt.armor_class
		else
			shirt_ac = 0
	if(istype(src.wear_armor, /obj/item/clothing))
		if(wear_armor.armor_class)
			chest_ac = wear_armor.armor_class
		else
			chest_ac = 0

	torso_class = max(shirt_ac, chest_ac)			//Use heaviest Torso Armor Class

	//Get Limb values, use heaviest pair
	var/list/accessories = list(head, wear_mask, wear_wrists, wear_neck, cloak, wear_pants, gloves, shoes, belt, s_store)
	var/acc_class = ARMOR_CLASS_NONE
	var/heavy_count = 0
	var/medium_count = 0
	var/light_count = 0
	for(var/obj/item/clothing/AA in accessories)
		switch(AA.armor_class)
			if(AC_HEAVY)
				heavy_count++
				continue
			if(AC_MEDIUM)
				medium_count++
				continue
			if(AC_LIGHT)
				light_count++
				continue
			if(ARMOR_CLASS_NONE)
				continue

	if(heavy_count >= 2)
		acc_class = AC_HEAVY
	else if(medium_count >= 2)
		acc_class = AC_MEDIUM
	else if(light_count >= 2)
		acc_class = AC_LIGHT
	else if(heavy_count == 1 && medium_count > 0)
		acc_class = AC_MEDIUM
	else if(medium_count == 1 && light_count > 0)
		acc_class = AC_LIGHT

	var/combined_armor = max(torso_class, acc_class)
	worn_armor_class = combined_armor
	return worn_armor_class
