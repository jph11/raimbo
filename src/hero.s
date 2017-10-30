.area _DATA

.globl _sprite_hero_upLeft_diag_pistol
.globl _sprite_hero_upRight_diag_pistol
.globl _sprite_hero_downLeft_diag_pistol
.globl _sprite_hero_downRight_diag_pistol  
.globl _sprite_hero_forward_pistol        
.globl _sprite_hero_back_pistol          
.globl _sprite_hero_left_pistol
.globl _sprite_hero_right_pistol         
.globl nEnemyA
.globl _game_flower_75
.globl _game_flower_50
.globl _game_flower_25

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
.include "map.h.s"

;;Last Movement Info:
;;	- 0: Left
;;	- 1: Right
;;	- 2: Up
;;	- 3: Down
;;	- 4: Up-Left
;;	- 5: Up-Right
;;	- 6: Down-Left
;;	- 7: Down-Right


TablaValoresBullets:
	;; X-Y
	valor_izquierda:
	.db 0x00, #14 ; 0
	valor_derecha:
	.db #6, #14 ; 1
	valor_arriba:
	.db #4, 0xFF ; 2
	valor_abajo:
	.db #2, #19 ; 3
	valor_arriba_izquierda:
	.db 0x00, 0x08 ; 4
	valor_arriba_derecha:
	.db 0x06, 0x08 ; 5
	valor_abajo_izquierda:
	.db 0x01, 0x10 ; 6
	valor_abajo_derecha:
	.db 0x05, 0x10 ; 7

punteroValor::
	.dw 0x0000

;;Hero Data
;;===================================================
;; ¡Si cambiamos el ancho del hero hay que cambiar
;;	 en el SpaceKey check el valor también!
;;===================================================
defineEntity hero, 39, 60, 9, 25, _sprite_hero_right_pistol, 4, 0, 1, 39, 39, 60, 60
hero_jump: .db #-1
hero_id: .db #00
hero_invencibleState: .db #0
hero_invencibleTransitions: .db #05			;;Número de animaciones de pintar-no_pintar
hero_invencibleDuration: .db #4			;;Duración de la animación
hero_invencibleAnimState: .db #00			;;Estado actual [0-1]

;;Jump Table
jumptable:
	.db #-5, #-4, #-2, #-1
	.db #-1, #00, #00, #00
	.db #00, #00,#00, #01
	.db #01, #02, #04, #05
	.db #0x80

petalo75:
	.dw _game_flower_75
petalo50:
	.dw _game_flower_50
petalo25:	
	.dw _game_flower_25

.equ S_spr_l, 4
.equ S_spr_h, 5		

;;===========================================
;;===========================================
;;PUBLIC FUNTIONS
;;===========================================
;;===========================================

hero_getPointerLife::
	ld hl, #hero_lives
	ret 


;; ======================
;;	Hero Update
;; ======================
hero_update::
	
	call jumpControl
	call checkUserInput
	call hero_heroDamage

	ld ix, #hero_data
	call entity_updatePositions
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
	ld a, #20
	ld (hero_y), a
	ld a, #-1
	ld (hero_jump), a
	ld a, #01
	ld (hero_directionBullet), a
	ld a, #04
	ld (hero_lives), a
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
;;	Gets a pointer to hero directionBullet
;;	
;;	RETURNS:
;; 		HL:Pointer to hero directionBullet
;; ======================
hero_getPointerLastMovement::
	ld hl, #hero_directionBullet 		;; Hl points to the Hero Data
	ret
;; ======================
;;	Gets a pointer to hero directionBullet
;;	
;;	RETURNS:
;; 		HL:Pointer to hero directionBullet
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
	cp #3		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_up	;;Hero_y == Limit, do not move
	jr c, d_not_move_up	
	
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
	cp #200-28-18		;;Check against right limit (screen size - hero size)
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
	cp #80-10		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_right	;;Hero_x == Limit, do not move

	inc a 			;;A++ (hero_x++)
	ld (hero_x), a 	;;Update hero_x
	ret 
	
	d_not_move_right:
		ld hl, (nEnemyA)
		ld a, (hl)
		cp #0
		 ret nz
		ld a, (hero_y)
		cp #90
		jr nc, change_rightSecond
			ret 
		change_rightSecond:
		cp #100
		jr c, change_right
			ret 
		change_right:
		ld a, #0
		call map_changeMap
		cp #-1
			ret z
		ld (hero_x), a
	ret

;; ======================
;; Move hero to the left
;; ======================
moveHeroLeft::
	ld a, (hero_x)	;;A = hero_x
	cp #0		;;Check against left limit (screen size - hero size)
	jr z, d_not_move_left	;;Hero_x == Limit, do not move

	dec a 			;;A-- (hero_x--)
	ld (hero_x), a 	;;Update hero_x
	ret 

	d_not_move_left:
		ld hl, (nEnemyA)
		ld a, (hl)
		cp #0
		 ret nz
		ld a, (hero_y)
		cp #90
		jr nc, change_leftSecond
			ret 
		change_leftSecond:
		cp #100
		jr c, change_left
			ret 
		change_left:
		ld a, #1
		call map_changeMap
		cp #-1
			ret z
		ld (hero_x), a
	ret

;; ============================
;; 	Changes the hero sprite
;; 	INPUTS: 
;;		de: hero_spritePointer
;; =============================
cambiarSprite:
	ld hl, #hero_sprite
	ld (hl), e
	inc hl 
	ld (hl), d
ret

;; ====
;;
;;	INPUT:
;; 		de: valor de tupla
;; ====
cambiarPunteroValor:
	ld hl, #punteroValor
	ld (hl), e
	inc hl 
	ld (hl), d
ret

;; ======================
;;	Checks User Input and Reacts
;;	DESTROYS:
;; ======================
checkUserInput::
	;;Scan the whole keyboard
	;;call cpct_scanKeyboard_asm ;;keyboard.s


	;;Check for key 'Space' being pressed
	ld hl, #Key_Space
	call cpct_isKeyPressed_asm	;;Check if Key_Space is presed
	cp #0						;;Check A == 0
	jr z, space_not_pressed		;;Jump if A==0 (space_not_pressed)


	;; Temporizador - Esta primera función guarda una bala cada dos veces y realiza un efecto de temporizador
	ld hl, #hero_temp 						;; hl <= tempBullets
	ld a, (hl) 								;; a <= (tempBullets)
	cp #0x05 								;; a == 0x02
	jr z, nueva 							;; if(!a==0x02){
		inc a 								;; 	a++
		ld (hl), a 							;; 	Actualizamos tempBullets
		jr space_not_pressed				;; 	Continuamos
	nueva:									;; }else{
	ld (hl), #0x00 							;;  Reiniciamos tempBullets y procedemos a guardar la bala
											;; }
	ld a, (hero_x)
	cp #0
		ret z
	cp #80-10
		ret z

	;;Space is pressed
	ld ix, #hero_data
	call entity_setPointer
	ld a, (hero_directionBullet)
	call entity_setPointerLastMovement
	ld a, (hero_id)
	call entity_setId
	call bullets_newBullet

	space_not_pressed:

	;;Check for key 'A' being pressed
	ld hl, #Key_A 				;;HL = Key_A
	call cpct_isKeyPressed_asm	;;Check if Key_A is presed
	cp #0						;;Check A == 0
	jr z, a_not_pressed			;;Jump if A==0 (a_not_pressed)

	;;A is pressed

	ld de, (valor_izquierda)
	call cambiarPunteroValor

	call moveHeroLeft
	ld hl, #hero_directionBullet
	ld a, #0
	ld (hl), a 
	ld de, #_sprite_hero_left_pistol
	call cambiarSprite
	a_not_pressed:

	;;Check for key 'D' being pressed
	ld hl, #Key_D 				;;HL = Key_D
	call cpct_isKeyPressed_asm	;;Check if Key_D is presed
	cp #0						;;Check A == 0
	jr z, d_not_pressed			;;Jump if A==0 (d_not_pressed)

	ld de, (valor_derecha)
	call cambiarPunteroValor

	;;D is pressed
	call moveHeroRight
	ld hl, #hero_directionBullet
	ld a, #1
	ld (hl), a 
	ld de, #_sprite_hero_right_pistol
	call cambiarSprite

	d_not_pressed:

	;;Check for key 'W' being pressed
	ld hl, #Key_W 				;;HL = Key_W
	call cpct_isKeyPressed_asm	;;Check if Key_W is presed
	cp #0						;;Check W == 0
	jr z, w_not_pressed			;;Jump if W==0 (w_not_pressed)

	ld de, (valor_arriba)
	call cambiarPunteroValor

	;;W is pressed
	call moveHeroUp
	ld hl, #hero_directionBullet
	ld a, #2
	ld (hl), a 
	ld de, #_sprite_hero_back_pistol
	call cambiarSprite
	w_not_pressed:

	;;Check for key 'S' being pressed
	ld hl, #Key_S 				;;HL = Key_S
	call cpct_isKeyPressed_asm	;;Check if Key_S is presed
	cp #0						;;Check S == 0
	jr z, s_not_pressed			;;Jump if S==0 (s_not_pressed)

	ld de, (valor_abajo)
	call cambiarPunteroValor

	;;S is pressed	
	call moveHeroBottom
	ld hl, #hero_directionBullet
	ld a, #3
	ld (hl), a 
	ld de, #_sprite_hero_forward_pistol
	call cambiarSprite
	s_not_pressed:

	;;Check for key 'Shift' being pressed
	ld hl, #Key_Shift 				;;HL = Key_Shift
	call cpct_isKeyPressed_asm	;;Check if Key_Shift is presed
	cp #0						;;Check Shift == 0
	jr z, shift_not_pressed			;;Jump if Shift==0 (shift_not_pressed)

	;;S is pressed
	
	call startJump
	shift_not_pressed:

	;;========================================================= Shot Direcction =========================================================

	;;Check for key 'Up Arrow' being pressed
	ld hl, #Key_CursorUp 				
	call cpct_isKeyPressed_asm
	cp #0								
	jr z, up_arrow_not_pressed

	;;Up Arrow is pressed - Check if RightOrLeft is pressed too
	call checkLeftRight
	ld hl, #hero_directionBullet
	cp #0
	jr z, up_arrow_pressed

	;; RightOrLeft is pressed too
	cp #1
	jr z, leftPressedUp
 		;; Right pressed too
		ld a, #05
		ld (hl), a
		ld de, #_sprite_hero_upRight_diag_pistol
		call cambiarSprite

		ld de, (valor_arriba_derecha)
		call cambiarPunteroValor

		ret
	leftPressedUp:
		;; Left pressed too
		ld a, #04
		ld (hl), a
		ld hl, #hero_sprite
		ld de, #_sprite_hero_upLeft_diag_pistol
		call cambiarSprite

		ld de, (valor_arriba_izquierda)
		call cambiarPunteroValor

		ret
	;; Only up arrow pressed
	up_arrow_pressed:
		ld a, #2 
		ld (hl), a
		ld de, #_sprite_hero_back_pistol
		call cambiarSprite

		ld de, (valor_arriba)
		call cambiarPunteroValor

		ret

	up_arrow_not_pressed:

	;;Check for key 'Down Arrow' being pressed
	ld hl, #Key_CursorDown 				
	call cpct_isKeyPressed_asm	
	cp #0						
	jr z, down_arrow_not_pressed

	;;Up Arrow is pressed - Check if RightOrLeft is pressed too
	call checkLeftRight
	ld hl, #hero_directionBullet
	cp #0
	jr z, down_arrow_pressed

	;; RightOrLeft is pressed too
	cp #1
	jr z, leftPressedDown
 		;; Right pressed too
		ld a, #07
		ld (hl), a
		ld de, #_sprite_hero_downRight_diag_pistol
		call cambiarSprite

		ld de, (valor_abajo_derecha)
		call cambiarPunteroValor

		ret
	leftPressedDown:
		;; Left pressed too
		ld a, #06
		ld (hl), a
		ld de, #_sprite_hero_downLeft_diag_pistol
		call cambiarSprite

		ld de, (valor_abajo_izquierda)
		call cambiarPunteroValor

		ret
	;; Only down pressed
	down_arrow_pressed:
		ld a, #03 
		ld (hl), a
		ld de, #_sprite_hero_forward_pistol
		call cambiarSprite

		ld de, (valor_abajo)
		call cambiarPunteroValor

		ret
	down_arrow_not_pressed:

	;;LEFT RIGHT ONLY COMPROBATION
	call checkLeftRight
	cp #0
	jr z, nothing_pressed
	ld hl, #hero_directionBullet
	cp #1
	jr z, leftPressedOnly
 		;; Right pressed only
		ld a, #01
		ld (hl), a
		ld de, #_sprite_hero_right_pistol
		call cambiarSprite

		ld de, (valor_derecha)
		call cambiarPunteroValor

		ret
	leftPressedOnly:
		;; Left pressed only
		ld a, #00
		ld (hl), a
		ld de, #_sprite_hero_left_pistol
		call cambiarSprite
		
		ld de, (valor_izquierda)
		call cambiarPunteroValor

	nothing_pressed:
	ret

;; ================================
;;	Check left or right pressed
;;	OUTPUTS:
;;		A: 0 if none is pressed
;;		   1 if left arrow pressed
;;		   2 if right arrow pressed
;; ================================
checkLeftRight:

	;;Check for key 'Left Arrow' being pressed
	ld hl, #Key_CursorLeft 				;;HL = Key_Shift
	call cpct_isKeyPressed_asm	;;Check if Key_Shift is presed
	cp #0						;;Check Shift == 0
	jr z, left_arrow_not_pressed			;;Jump if Shift==0 (shift_not_pressed)

	;;Left Arrow is pressed
	
	ld a, #1
	ret 

	left_arrow_not_pressed:

	;;Check for key 'Right Arrow' being pressed
	ld hl, #Key_CursorRight 				;;HL = Key_Shift
	call cpct_isKeyPressed_asm	;;Check if Key_Shift is presed
	cp #0						;;Check Shift == 0
	jr z, right_arrow_not_pressed			;;Jump if Shift==0 (shift_not_pressed)

	;;Right Arrow is pressed
	
	ld a, #2 
	ret 

	right_arrow_not_pressed:
	ld a, #0
	ret

;; ======================
;;	Hero is death
;; ======================

hero_decreaseLife::
	push DE
	push HL
	push AF

	ld a, (hero_lives)
	dec a
	ld (hero_lives), a

	cp #3
	jr z, draw75

	cp #2
	jr z, draw50

	cp #1
	jr z, draw25

		jp endDraw

	draw75:
		ld hl, (petalo75)
		ld c, #24	
		ld b, #190

		call changeLife

		jr endDraw

	draw50:
		ld hl, (petalo50)
		ld c, #22	
		ld b, #194
		
		call changeLife
		
		jr endDraw

	draw25:
		ld hl, (petalo25)
		ld c, #20	
		ld b, #190

		call changeLife

	endDraw:
		pop AF
		pop HL
		pop DE
ret


changeLife:
	push hl
	push bc
	push hl

	ld de, #0xC000
	call cpct_getScreenPtr_asm
	ex de, hl
	pop hl
	ld b, #5
	ld c, #3
	call cpct_drawSpriteMasked_asm

	ld de, #0x8000
	pop bc
	call cpct_getScreenPtr_asm
	ex de, hl
	pop hl 
	ld b, #5
	ld c, #3
	call cpct_drawSpriteMasked_asm

ret

hero_heroDamage:
	ld a, (hero_invencibleState)
	cp #0
		ret z

	ld a, (hero_lives)
	cp #0
	 	jr nz, continue
	 	dec a
		ld (hero_lives), a
		ret

	continue:
	ld a, (hero_invencibleTransitions)		;;Cargamos nº alteraciones
		cp #0				
		jr z, end							;;Si nº alteraciones==0 terminamos ==> end
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
				ld a, #4				;;Volvemos a cargar a 20 la duración de la animación
				ld (hero_invencibleDuration), a		;;para la animación i+1

				ld a, (hero_invencibleTransitions)		;;Decrementamos nº animación
				dec a
				ld (hero_invencibleTransitions), a

				jr draw					;;Finalizamos hasta la siguiente llamada a enemyOver

	end: 
		ld a, #00				
		ld (hero_invencibleState), a
		ld a, #5
		ld (hero_invencibleTransitions), a
		ld a, #4
		ld (hero_invencibleDuration), a
		ld a, #0
		ld (hero_invencibleAnimState), a
	draw:

	ret