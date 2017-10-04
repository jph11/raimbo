.area _DATA

.globl _sprite_jar

.macro defineEntity name, x, y, w, h, spr
    name'_data:
        name'_x: 	.db x
        name'_y:	.db y
        name'_w:	.db w
        name'_h:	.db h
        name'_sprite: .dw spr
.endm

.area _CODE

;;====================
;;====================
;;PRIVATE DATA
;;====================
;;====================

;;Obstacle Data
defineEntity obs 72, 76, 6, 12, _sprite_jar

.include "hero.h.s"
.include "cpctelera.h.s"
.include "entity.h.s"

;;===========================================
;;===========================================
;;PUBLIC FUNTIONS
;;===========================================
;;===========================================

;; ======================
;;	Obstacle update
;; ======================
obstacle_update::
	 ;;Move obstacle to the left
	 ld a, (obs_x) 			;; |
	 dec a					;; | Obs_x--
	 jr nz, not_restart_x	;; | If (Obs_x = 0) then restart

	 ;; Restart_x when it is 0
	  ld a, #72


	 not_restart_x:
		ld (obs_x), a 		;; Update
	 
	 ret


;; ======================
;;	Obstacle draw
;; ======================
obstacle_draw::
	ld a, #0x0F
	ld ix, #obs_data
	call entity_draw
	ret

;; ======================
;;	Obstacle erase
;; ======================
obstacle_erase::
	ld a, #0x00
	ld ix, #obs_data
	call entity_draw
	ret

;; ======================
;;	Obstacle init
;;  Start obstacle values
;; ======================
obstacle_init::
	ld a, #72		
	ld (obs_x), a
	ld a, #76
	ld (obs_y),a

	ret		

;; ======================
;; Obstacle check collision
;; 	Inputs:
;; 	HL : Points to the other 
;;	Return:
;;		XXXXXXXX
;; ======================
obstacle_checkCollision::
	
	;;
	;;	If (obs_x + obs_w <= hero_x ) no_collision
	;;	obs_x + obs_w - hero_x <= 0
	;; 

	ld a, (obs_x)		;; | obs_x
	ld c, a 			;; | +
	ld a, (obs_w)	 	;; | obx_w
	add c 				;; | -
	sub (hl)			;; | hero_x			
	jr z, not_collision ;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;; 	If (hero_x + hero_w <= obs_x)
	;; 	hero_x + hero_w - obs_x <= 0
	;;

	ld a, (hl)
	inc hl
	inc hl
	add (hl)
	ld c, a
	ld a, (obs_x)
	ld b, a
	ld a, c
	sub b
	jr z, not_collision ;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;;	If (obs_y + obs_h <= hero_y ) no_collision
	;;	obs_y + obs_h - hero_y <= 0
	;;

	ld a, (obs_y)		;; | obs_x
	ld c, a 			;; | +
	ld a, (obs_h)	 	;; | obx_w
	add c
	dec hl				;; | -
	sub (hl)			;; | hero_x			
	jr z, not_collision ;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;; 	If (hero_y + hero_h <= obs_x)
	;; 	hero_y + hero_h - obs_y <= 0
	;;

	ld a, (hl)
	inc hl
	inc hl
	add (hl)
	ld c, a
	ld a, (obs_y)
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

;;===========================================
;;===========================================
;;PRIVATE FUNCTIONS
;;===========================================
;;===========================================