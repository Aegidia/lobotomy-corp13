/mob/living/simple_animal/hostile/abnormality/scarecrow
	name = "Scarecrow searchin for wisdom"
	desc = "An abnormality taking form of a scarecrow with metal rake in place of its hand."
	icon = 'ModularTegustation/Teguicons/32x48.dmi'
	icon_state = "scarecrow"
	icon_living = "scarecrow"
	icon_dead = "scarecrow_dead"
	del_on_death = FALSE
	maxHealth = 1000
	health = 1000
	rapid_melee = 2
	move_to_delay = 3
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0.8, WHITE_DAMAGE = 0.5, BLACK_DAMAGE = 1.2, PALE_DAMAGE = 2)
	melee_damage_lower = 20
	melee_damage_upper = 24
	melee_damage_type = BLACK_DAMAGE
	armortype = BLACK_DAMAGE
	stat_attack = HARD_CRIT
	attack_sound = 'sound/abnormalities/scarecrow/attack.ogg'
	attack_verb_continuous = "stabs"
	attack_verb_simple = "stab"
	faction = list("hostile")
	can_breach = TRUE
	threat_level = HE_LEVEL
	start_qliphoth = 1
	work_chances = list(
						ABNORMALITY_WORK_INSTINCT = 45,
						ABNORMALITY_WORK_INSIGHT = list(50, 60, 70, 80, 90),
						ABNORMALITY_WORK_ATTACHMENT = 45,
						ABNORMALITY_WORK_REPRESSION = 45
						)
	work_damage_amount = 10
	work_damage_type = WHITE_DAMAGE
	deathmessage = "stops moving, with its torso rotating forwards."
	deathsound = 'sound/abnormalities/scarecrow/death.ogg'

	ego_list = list(
		/datum/ego_datum/weapon/harvest,
		/datum/ego_datum/armor/harvest
		)
	gift_type =  /datum/ego_gifts/harvest
	/// Can't move/attack when it's TRUE
	var/finishing = FALSE

/mob/living/simple_animal/hostile/abnormality/scarecrow/CanAttack(atom/the_target)
	if(finishing)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/abnormality/scarecrow/Move()
	if(finishing)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/abnormality/scarecrow/death(gibbed)
	density = FALSE
	animate(src, alpha = 0, time = 10 SECONDS)
	QDEL_IN(src, 10 SECONDS)
	..()

/mob/living/simple_animal/hostile/abnormality/scarecrow/AttackingTarget()
	. = ..()
	if(.)
		if(!istype(target, /mob/living/carbon/human))
			return
		var/mob/living/carbon/human/H = target
		if(H.health < 0 && stat != DEAD && !finishing)
			finishing = TRUE
			H.Stun(10 SECONDS)
			playsound(get_turf(src), 'sound/abnormalities/scarecrow/start_drink.ogg', 50, 1)
			SLEEP_CHECK_DEATH(2)
			for(var/i = 1 to 6)
				if(!targets_from.Adjacent(H) || QDELETED(H)) // They can still be saved if you move them away
					finishing = FALSE
					return
				playsound(get_turf(src), 'sound/abnormalities/scarecrow/drink.ogg', 50, 1)
				adjustBruteLoss(-(maxHealth*0.05)) // Can restore 30% of HP
				SLEEP_CHECK_DEATH(4)
			if(!targets_from.Adjacent(H) || QDELETED(H))
				finishing = FALSE
				return
			for(var/obj/item/organ/O in H.getorganszone(BODY_ZONE_HEAD, TRUE))
				O.Remove(H)
				QDEL_NULL(O)
			finishing = FALSE

/mob/living/simple_animal/hostile/abnormality/scarecrow/failure_effect(mob/living/carbon/human/user, work_type, pe)
	datum_reference.qliphoth_change(-1)
	return

/mob/living/simple_animal/hostile/abnormality/scarecrow/work_complete(mob/living/carbon/human/user, work_type, pe, work_time)
	if(get_attribute_level(user, PRUDENCE_ATTRIBUTE) >= 60)
		datum_reference.qliphoth_change(-1)
	return ..()

/mob/living/simple_animal/hostile/abnormality/scarecrow/breach_effect(mob/living/carbon/human/user)
	..()
	icon_living = "scarecrow_breach"
	icon_state = icon_living
	GiveTarget(user)


