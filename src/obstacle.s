.area _DATA
.area _CODE

.include "hero.h.s"
.include "cpctelera.h.s"

;;====================
;;====================
;;PRIVATE DATA
;;====================
;;====================


;;Hero Data
obs_x: 	.db #80-1
obs_y:	.db #82
obs_w:	.db #1
obs_h:	.db #4

.include "cpctelera.h.s"

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
	  ld a, #80-1


	 not_restart_x:
	  ld (obs_x), a 		;; Update
	 
	 ret


;; ======================
;;	Obstacle draw
;; ======================
obstacle_draw::
	ld a, #0x0F
	call drawObstacle
	ret

;; ======================
;;	Obstacle erase
;; ======================
obstacle_erase::
	ld a, #0x00
	call drawObstacle
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

;; ======================
;;	Draw the obstacle
;;	DESTROYS: AF, BC, DE, HL
;;  Parametrer: a
;; ======================
drawObstacle:
	push af 	;;Save A in the stack

	;; Calculate Screen position
	ld de, #0xC000	;;Video memory

	ld a, (obs_x)	;;|
	ld c, a			;;\ C=hero_x

	ld a, (obs_y)	;;|
	ld b, a			;;\ B=hero_y

	call cpct_getScreenPtr_asm	;;Get pointer to screen
	ex de, hl

	pop AF 		;;A = User selected code

	;; Draw a box
	ld bc, #0x0401	;;4x4
	call cpct_drawSolidBox_asm

	ret