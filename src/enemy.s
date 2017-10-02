.area _DATA
.area _CODE

;;===========================================
;;===========================================
;;PRIVATE DATA
;;===========================================
;;===========================================

;;Enemy Data
enemy_x: .db #77
enemy_y: .db #80
enemy_w: .db #3
enemy_h: .db #8

.include "cpctelera.h.s"
.include "game.h.s"
.include "hero.h.s"


;;===========================================
;;===========================================
;;PUBLIC FUNTIONS
;;===========================================
;;===========================================

;; ======================
;;	Enemy Update
;; ======================
enemy_update::
	call moveEnemyLeft
	call hero_getPointer
	call enemy_checkCollision

	ret

;; ======================
;;	Enemy Draw
;; ======================
enemy_draw::
	ld a, #0x6F
	call drawEnemy
	ret

;; ======================
;;	Enemy Erase
;; ======================
enemy_erase::
	ld a, #0x00
	call drawEnemy
	ret

;; ======================
;;	Enemy init
;;  Start enemy values
;; ======================
enemy_init::
	ld a, #77
	ld (enemy_x), a
	ld a, #80
	ld (enemy_y),a

	ret	


;;===========================================
;;===========================================
;;PRIVATE FUNCTIONS
;;===========================================
;;===========================================

;; ======================
;; Enemy check collision
;; 	Inputs:
;; 	HL : Points to the other 
;;	Return:
;;		XXXXXXXX
;; ======================
enemy_checkCollision::
	
	;;
	;;	If (enemy_x + enemy_w <= hero_x ) no_collision
	;;	enemy_x + enemy_w - hero_x <= 0
	;; 

	ld a, (enemy_x)			;; | enemy_x
	ld c, a 				;; | +
	ld a, (enemy_w)	 		;; | enemy_w
	add c 					;; | -
	sub (hl)				;; | hero_x			
	jr z, not_collision 	;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;; 	If (hero_x + hero_w <= enemy_x)
	;; 	hero_x + hero_w - enemy_x <= 0
	;;

	ld a, (hl)
	inc hl
	inc hl
	add (hl)
	ld c, a
	ld a, (enemy_x)
	ld b, a
	ld a, c
	sub b
	jr z, not_collision 	;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;;	If (enemy_y + enemy_h <= hero_y ) no_collision
	;;	enemy_y + enemy_h - hero_y <= 0
	;;

	ld a, (enemy_y)			;; | enemy_x
	ld c, a 				;; | +
	ld a, (enemy_h)	 		;; | obx_w
	add c
	dec hl					;; | -
	sub (hl)				;; | hero_x			
	jr z, not_collision 	;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;; 	If (hero_y + hero_h <= enemy_x)
	;; 	hero_y + hero_h - enemy_y <= 0
	;;

	ld a, (hl)
	inc hl
	inc hl
	add (hl)
	ld c, a
	ld a, (enemy_y)
	ld b, a
	ld a, c
	sub b
	jr z, not_collision 	;;| If(==0)
	jp m, not_collision 	;;| If(<0)

		;;Other posibilities of collision
		call game_heroKill
	
	not_collision:

	ret

;; ======================
;; Move enemy to the left
;; ======================
moveEnemyLeft:
	;;Move enemy to the left
	ld a, (enemy_x) 			;; |
	dec a						;; | enemy_x--
	jr nz, not_restart_x		;; | If (enemy_x = 0) then restart

	;; Restart_x when it is 0 to the right
	ld a, #80-3

	not_restart_x:
	ld (enemy_x), a

	ret

;; ======================
;;	Draw the enemy
;;	DESTROYS: AF, BC, DE, HL
;;  Parametrer: a
;; ======================
drawEnemy:
	push af 	;;Save A in the stack

	;; Calculate Screen position
	ld de, #0xC000	;;Video memory

	ld a, (enemy_x)	;;|
	ld c, a			;;\ C=enemy_x

	ld a, (enemy_y)	;;|
	ld b, a			;;\ B=enemy_y

	call cpct_getScreenPtr_asm	;;Get pointer to screen
	ex de, hl

	pop AF 		;;A = User selected code

	;; Draw a box
	ld bc, #0x0803	
	call cpct_drawSolidBox_asm

	ret    