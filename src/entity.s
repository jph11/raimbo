.area _DATA

.area _CODE

.equ Ent_x, 0
.equ Ent_y, 1
.equ Ent_w, 2
.equ Ent_h, 3	
.equ Ent_spr_l, 4
.equ Ent_spr_h, 5

.include "cpctelera.h.s"

;; ======================
;;	Draw the entity
;;	DESTROYS: AF, BC, DE, HL
;;  Parametrer: a
;; ======================
entity_draw::

	push af 	;;Save A in the stack

	;; Calculate Screen position
	ld de, #0xC000		;;Video memory

	ld c, Ent_x(ix)			;;\ C=hero_x
	ld b, Ent_y(ix)			;;\ B=hero_y

	call cpct_getScreenPtr_asm	;;Get pointer to screen
	ex de, hl

	;; Draw a box
	ld b, Ent_h(ix)
	ld c, Ent_w(ix)
	pop AF 		;;A = User selected code
	cp #00
	jr z, erase
		;;Draw sprite
		ld h, Ent_spr_h(ix)
		ld l, Ent_spr_l(ix)
		call cpct_drawSprite_asm
		ret
	erase:
		call cpct_drawSolidBox_asm	
	ret