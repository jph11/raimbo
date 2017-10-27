.area _DATA

.globl _sprite_jar

.area _CODE

;;====================
;;====================
;;PRIVATE DATA
;;====================
;;====================

.include "hero.h.s"
.include "cpctelera.h.s"
.include "entity.h.s"
.include "macros.h.s"

;;Object Data
defineObject obj, 0, 184, 80, 16, _sprite_jar

;;===========================================
;;===========================================
;;PUBLIC FUNTIONS
;;===========================================
;;===========================================

;; ======================
;;	Object draw
;; ======================
object_draw::
	ld a, #0x0F
	ld ix, #obj_data
	call entity_draw
	ret

;; ======================
;;	Object erase
;; ======================
object_erase::
	ld a, #0x00
	ld ix, #obj_data
	call entity_draw
	ret

;; ======================
;;	Object init
;;  Start object values
;; ======================
object_init::
	ld a, #0		
	ld (obj_x), a
	ld a, #184
	ld (obj_y),a

	ret		

;; ======================
;; Object check collision
;; 	Inputs:
;; 	HL : Points to the other 
;;	Return:
;;		XXXXXXXX
;; ======================
object_checkCollision::
	
	;;
	;;	If (obj_x + obj_w <= hero_x ) no_collision
	;;	obj_x + obj_w - hero_x <= 0
	;; 

	ld a, (obj_x)		;; | obj_x
	ld c, a 			;; | +
	ld a, (obj_w)	 	;; | obx_w
	add c 				;; | -
	sub (hl)			;; | hero_x			
	jr z, not_collision ;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;; 	If (hero_x + hero_w <= obj_x)
	;; 	hero_x + hero_w - obj_x <= 0
	;;

	ld a, (hl)
	inc hl
	inc hl
	add (hl)
	ld c, a
	ld a, (obj_x)
	ld b, a
	ld a, c
	sub b
	jr z, not_collision ;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;;	If (obj_y + obj_h <= hero_y ) no_collision
	;;	obj_y + obj_h - hero_y <= 0
	;;

	ld a, (obj_y)		;; | obj_x
	ld c, a 			;; | +
	ld a, (obj_h)	 	;; | obx_w
	add c
	dec hl				;; | -
	sub (hl)			;; | hero_x			
	jr z, not_collision ;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;; 	If (hero_y + hero_h <= obj_x)
	;; 	hero_y + hero_h - obj_y <= 0
	;;

	ld a, (hl)
	inc hl
	inc hl
	add (hl)
	ld c, a
	ld a, (obj_y)
	ld b, a
	ld a, c
	sub b
	jr z, not_collision ;; | if(==0)
	jp m, not_collision 	;; | if(<0)

		;;Other posibilities of collision
		ld a, #0xFF
		ret
	
	not_collision:
		ld a, #0x00
	ret