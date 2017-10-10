.area _DATA

.globl _sprite_oldman_left

.area _CODE

;;===========================================
;;===========================================
;;PRIVATE DATA
;;===========================================
;;===========================================

.include "cpctelera.h.s"
.include "game.h.s"
.include "hero.h.s"
.include "entity.h.s"
.include "macros.h.s"

;;Enemy Data
defineEntity enemy 55, 60, 7, 25, _sprite_oldman_left
enemy_temp: .db #0x00

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
	ld ix, #enemy_data
	call entity_draw
	ret

;; ======================
;;	Enemy Erase
;; ======================
enemy_erase::
	ld a, #0x00
	ld ix, #enemy_data
	call entity_draw
	ret

;; ======================
;;	Enemy init
;;  Start enemy values
;; ======================
enemy_init::
	ld a, #65
	ld (enemy_x), a
	ld a, #60
	ld (enemy_y),a

	ret	

;; ======================
;;	Gets a pointer to hero data 
;;	
;;	RETURNS:
;; 		HL:Pointer to hero data
;; ======================
enemy_getPointer::
	ld hl, #enemy_x 					;; Hl points to the Hero Data
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
enemy_checkCollision:
	
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

	ld hl, #enemy_temp	 					;; hl <= enemy_temp
	ld a, (hl) 								;; a <= (enemy_temp)
	cp #0x03 								;; a == 0x04
	jr z, nueva 							;; if(!a==0x02){
		inc a 								;; 	a++
		ld (hl), a 							;; 	Actualizamos enemy_temp
		ret 								;; 	Terminamos
	nueva:									;; }else{
	ld (hl), #0x00 							;;  Reiniciamos tempBullets y procedemos a guardar la bala
											;; }

	;;Move enemy to the left
	ld a, (enemy_x) 			;; |
	dec a						;; | enemy_x--
	jr nz, not_restart_x		;; | If (enemy_x = 0) then restart

	;; Restart_x when it is 0 to the right
	ld a, #65-3

	not_restart_x:
	ld (enemy_x), a

	ret