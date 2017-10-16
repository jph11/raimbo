.area _DATA

.globl _sprite_hero_pistol

.area _CODE

;;===========================================
;;===========================================
;;PRIVATE DATA
;;===========================================
;;===========================================

.include "bullets.h.s"
.include "cpctelera.h.s"
.include "keyboard.s"
.include "entity.h.s"
.include "macros.h.s"
.include "game.h.s"

;;Hero Data
defineEntity hero 39, 60, 9, 25, _sprite_hero_pistol
hero_jump: .db #-1
hero_last_movement: .db #01
hero_lifes: .db #3
hero_invencibleState: .db #0
hero_invencibleTransitions: .db #10			;;Número de animaciones de pintar-no_pintar
hero_invencibleDuration: .db #20	;;Duración de la animación
hero_invencibleAnimState: .db #00	;;Estado actual [0-1]

;;Jump Table
jumptable:
	.db #-5, #-4, #-2, #-1
	.db #-1, #00, #00, #00
	.db #00, #00,#00, #01
	.db #01, #02, #04, #05
	.db #0x80

;;===========================================
;;===========================================
;;PUBLIC FUNTIONS
;;===========================================
;;===========================================

;; ======================
;;	Hero Update
;; ======================
hero_update::
	
	ld hl, #0xC232
	ld a, (hero_lifes)
	cp #0
	jr z, borrar1
	jr c, borrar1
	ld a, #0xFF
	ld (hl), a
	jr pintar
	borrar1:
	ld a, #0x00
	ld (hl), a
	pintar:
	ld hl, #0xC234
	ld a, (hero_lifes)
	cp #1
	jr z, borrar2
	jr c, borrar2
	ld a, #0xFF
	ld (hl), a
	jr pintar2
	borrar2:
	ld a, #0x00
	ld (hl), a
	pintar2:
	ld hl, #0xC236
	ld a, (hero_lifes)
	cp #2
	jr z, borrar3
	jr c, borrar3
	ld a, #0xFF
	ld (hl), a
	jr pintar3
	borrar3:
	ld a, #0x00
	ld (hl), a
	pintar3:
	ld hl, #0xC238
	ld a, (hero_lifes)
	cp #3
	jr z, borrar4
	jr c, borrar4
	ld a, #0xFF
	ld (hl), a
	jr pintar4
	borrar4:
	ld a, #0x00
	ld (hl), a
	pintar4:


	finPintar:

	call jumpControl
	call checkUserInput
	call hero_heroDamage
	ret

;; ======================
;;	Hero Draw
;; ======================
hero_draw::
	ld a, (hero_invencibleState)
	cp #1
		ret z

	ld a, #0xFF
	ld ix, #hero_data
	call entity_draw
	ret

;; ======================
;;	Hero Erase
;; ======================
hero_erase::
	ld a, #0x00
	ld ix, #hero_data
	call entity_draw
	ret

;; ======================
;;	Hero init
;;  Start hero values
;; ======================
hero_init::
	ld a, #39
	ld (hero_x), a
	ld a, #60
	ld (hero_y), a
	ld a, #-1
	ld (hero_jump), a
	ld a, #01
	ld (hero_last_movement), a
	ld a, #03
	ld (hero_lifes), a
	ld a, #0
	ld (hero_invencibleState), a
	ld a, #10
	ld (hero_invencibleTransitions), a
	ld a, #20
	ld (hero_invencibleDuration), a
	ld a, #0
	ld (hero_invencibleAnimState), a
	ret	

;; ======================
;;	Gets a pointer to hero last movement
;;	
;;	RETURNS:
;; 		HL:Pointer to hero last moevement
;; ======================
hero_getPointerLastMovement::
	ld hl, #hero_last_movement 		;; Hl points to the Hero Data
	ret
;; ======================
;;	Gets a pointer to hero last movement
;;	
;;	RETURNS:
;; 		HL:Pointer to hero last moevement
;; ======================
hero_getPointerInvecible::
	ld hl , #hero_invencibleState
	ret
;; ======================
;;	Gets a pointer to hero data 
;;	
;;	RETURNS:
;; 		HL:Pointer to hero data
;; ======================
hero_getPointer::
	ld hl, #hero_x 					;; Hl points to the Hero Data
	ret
	
;;===========================================
;;===========================================
;;PRIVATE FUNCTIONS
;;===========================================
;;===========================================


;; ======================
;;	Controls Jump movements
;; ======================
jumpControl:
	ld a, (hero_jump)	;;A = Hero_jump in status
	cp #-1				;;A == -1? (-1 is not jump)
	ret z				;;If A == -1, not jump

	;;Get Jump Value
	ld hl, #jumptable	;;HL Points
	ld c, a 			;;|
	ld b, #0			;;\ BC = A (Offset)
	add hl, bc			;;HL += BC

	ld a, (hero_jump)	;;A = Hero_jump
	cp #0x10
	jp z, reset

	;;Do Jump Movement
	ld b, (hl)			;;B = Jump Movement
	ld a, (hero_y)		;;A = Hero_y
	add b 				;;A += B (Add jump)
	ld (hero_y), a 		;; Update Hero Jump

	;;Increment Hero_jump Index
	ld a, (hero_jump)	;;A = Hero_jump
	cp #0x10 			;;Check if is latest vallue
	jr nz, continue_jump ;;Not latest value, continue

		;;End jump
		ld a, #-2

	continue_jump:
	inc a 				;;|
	ld (hero_jump), a 	;;\ Hero_jump++

	ret

	reset:
	ld a, #-1
	ld (hero_jump), a
	ret

;; ======================
;;	Starts Hero Jump
;; ======================
startJump:
	ld a, (hero_jump)	;;A = hero_jump
	cp #-1				;;A == -1? Is jump action
	ret nz

	;;Jump is inactive, activate it
	ld a, #0
	ld (hero_jump), a


	ret


;; ======================
;; Move hero to up
;; ======================
moveHeroUp:
	ld a, (hero_y)	;;A = hero_y
	cp #0		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_up	;;Hero_y == Limit, do not move

	dec a 			;;A++ (hero_y--)
	dec a
	dec a
	ld (hero_y), a 	;;Update hero_y

	d_not_move_up:
	ret

;; ======================
;; Move hero to bottom
;; ======================
moveHeroBottom:
	ld a, (hero_y)	;;A = hero_y
	cp #200-26		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_bottom	;;Hero_y == Limit, do not move
	jr nc, d_not_move_bottom


	inc a 			;;A++ (hero_y++)
	inc a
	inc a
	ld (hero_y), a 	;;Update hero_y

	d_not_move_bottom:
	ret

;; ======================
;; Move hero to the right
;; ======================
moveHeroRight:
	ld a, (hero_x)	;;A = hero_x
	cp #80-9		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_right	;;Hero_x == Limit, do not move

	inc a 			;;A++ (hero_x++)
	ld (hero_x), a 	;;Update hero_x

	d_not_move_right:
	ret

;; ======================
;; Move hero to the left
;; ======================
moveHeroLeft:
	ld a, (hero_x)	;;A = hero_x
	cp #0		;;Check against left limit (screen size - hero size)
	jr z, d_not_move_left	;;Hero_x == Limit, do not move

	dec a 			;;A-- (hero_x--)
	ld (hero_x), a 	;;Update hero_x

	d_not_move_left:
	ret

;; ======================
;;	Checks User Input and Reacts
;;	DESTROYS:
;; ======================
checkUserInput:
	;;Scan the whole keyboard
	call cpct_scanKeyboard_asm ;;keyboard.s


	;;Check for key 'Space' being pressed
	ld hl, #Key_Space
	call cpct_isKeyPressed_asm	;;Check if Key_Space is presed
	cp #0						;;Check A == 0
	jr z, space_not_pressed		;;Jump if A==0 (space_not_pressed)

	;;Space is pressed
	call bullets_newBullet

	space_not_pressed:


	;;Check for key 'A' being pressed
	ld hl, #Key_A 				;;HL = Key_A
	call cpct_isKeyPressed_asm	;;Check if Key_A is presed
	cp #0						;;Check A == 0
	jr z, a_not_pressed			;;Jump if A==0 (a_not_pressed)

	;;A is pressed
	ld hl, #hero_last_movement
	ld a, #00
	ld (hl), a
	call moveHeroLeft

	a_not_pressed:

	;;Check for key 'D' being pressed
	ld hl, #Key_D 				;;HL = Key_D
	call cpct_isKeyPressed_asm	;;Check if Key_D is presed
	cp #0						;;Check A == 0
	jr z, d_not_pressed			;;Jump if A==0 (d_not_pressed)

	;;D is pressed
	ld hl, #hero_last_movement
	ld a, #01
	ld (hl), a
	call moveHeroRight

	d_not_pressed:

	;;Check for key 'W' being pressed
	ld hl, #Key_W 				;;HL = Key_W
	call cpct_isKeyPressed_asm	;;Check if Key_W is presed
	cp #0						;;Check W == 0
	jr z, w_not_pressed			;;Jump if W==0 (w_not_pressed)

	;;W is pressed
	ld hl, #hero_last_movement
	ld a, #02
	ld (hl), a
	call moveHeroUp
	w_not_pressed:

	;;Check for key 'S' being pressed
	ld hl, #Key_S 				;;HL = Key_S
	call cpct_isKeyPressed_asm	;;Check if Key_S is presed
	cp #0						;;Check S == 0
	jr z, s_not_pressed			;;Jump if S==0 (s_not_pressed)

	;;S is pressed
	ld hl, #hero_last_movement
	ld a, #03
	ld (hl), a
	call moveHeroBottom
	s_not_pressed:

	

	;;Check for key 'Shift' being pressed
	ld hl, #Key_Shift 				;;HL = Key_Shift
	call cpct_isKeyPressed_asm	;;Check if Key_Shift is presed
	cp #0						;;Check Shift == 0
	jr z, shift_not_pressed			;;Jump if Shift==0 (shift_not_pressed)

	;;S is pressed
	
	call startJump
	shift_not_pressed:

	ret

;; ======================
;;	Hero is death
;; ======================

hero_decreaseLife::
	ld a, (hero_lifes)
	dec a
	ld (hero_lifes), a
	ret




;hero_invencibleState: .db #0 			;; Invencible o no
;hero_invencibleTransitions: .db #10		;; Número de animaciones de pintar-no_pintar
;hero_invencibleDuration: .db #20		;; Duración de la animación
;hero_invencibleAnimState: .db #00		;; Estado actual [0-1]

hero_heroDamage:
	ld a, (hero_invencibleState)
	cp #0
		ret z

	ld a, (hero_lifes)
	cp #0
	 	jr nz, continue
		call game_PointerHeroAlive
		ld a, #0
		ld (hl), a
		ret

	continue:
	ld a, (hero_invencibleTransitions)		;;Cargamos nº alteraciones
		cp #0				
		jr z, end				;;Si nº alteraciones==0 terminamos ==> end
		ld a, (hero_invencibleDuration)		;;sino cargamos la duración de la animación i
								;;y entramos en el loop
		loop:
			cp #0						;;Si la duración de la animación es 0,
			jr z, decrement_anim		;;pasamos al siguiente nº de animación

				push af					;;Pusheamos A para no perder el estado de duración

				ld a, (hero_invencibleAnimState)
				cp #0		
				jr z, dibujar			;;Si es 0-->dibujar / 1-->borrar

				ld a, #0x00				;;||
				ld ix, #hero_data		;;||Borramos
				call entity_draw		;;||

				ld a, #00				;;Alteramos el estado a 0
				ld (hero_invencibleAnimState), a
				jr decrement_anim2

				dibujar:
					ld a, #0xFF			;;||
					ld ix, #hero_data	;;||Dibujamos
					call entity_draw	;;||

					ld a, #01			;;Alteramos el estado a 1
					ld (hero_invencibleAnimState), a

				decrement_anim2:
					pop af				;;Popeamos el estado de duración en A
					dec a				;;death_anim2--
					ld (hero_invencibleDuration), a
					jr draw				;;Finalizamos hasta la siguiente llamada a enemyOver

			decrement_anim:
				ld a, #20				;;Volvemos a cargar a 20 la duración de la animación
				ld (hero_invencibleDuration), a		;;para la animación i+1

				ld a, (hero_invencibleTransitions)		;;Decrementamos nº animación
				dec a
				ld (hero_invencibleTransitions), a

				jr draw					;;Finalizamos hasta la siguiente llamada a enemyOver

	end: 
		ld a, #00				
		ld (hero_invencibleState), a
		ld a, #10
		ld (hero_invencibleTransitions), a
		ld a, #20
		ld (hero_invencibleDuration), a
		ld a, #0
		ld (hero_invencibleAnimState), a
	draw:

	ret