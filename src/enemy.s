.area _DATA

.globl _sprite_oldman_left
.globl _sprite_death

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
enemy_alive: .db #03
enemy_last_movement: .db #00

;;Death Data
defineEntity death #enemy_x, #enemy_y, 8, 16, _sprite_death
death_isDraw: .db #00

;;Death Data Animation
death_anim: .db #10			;;Número de animaciones de pintar-no_pintar
death_anim2: .db #20		;;Duración de la animación
death_animState: .db #00	;;Estado actual [0-1]

;;===========================================
;;===========================================
;;PUBLIC FUNTIONS
;;===========================================
;;===========================================

;; ======================
;;	Enemy Update
;; ======================
enemy_update::
	ld a, (enemy_alive)
	cp #0
	jr z, enemyOver
		call Algorithm_Random
		call hero_getPointer
		call enemy_checkCollision
	ret

;; ======================
;;	Enemy Draw
;; ======================
enemy_draw::
	ld a, (enemy_alive)
	cp #0
	ret z
		ld a, #0x6F
		ld ix, #enemy_data
		call entity_draw
	ret

;; ======================
;;	Enemy Erase
;; ======================
enemy_erase::
	ld a, (enemy_alive)
	cp #0
	ret z
		ld a, #0x00
		ld ix, #enemy_data
		call entity_draw
	ret

;; ======================
;;	Enemy init
;;  Start enemy values
;; ======================
enemy_init::
	ld a, #40
	ld (enemy_x), a
	ld a, #100
	ld (enemy_y),a

	ret	

;; ======================
;;	Gets a pointer to enemy data 
;;	
;;	RETURNS:
;; 		HL:Pointer to enemy data
;; ======================
enemy_getPointer::
	ld hl, #enemy_x 	;; Hl points to the Enemy Data
	ret	

;; ======================
;;	Enemy is death
;; ======================
enemy_enemyKill::
	ld a, (enemy_alive)
	dec a
	ld (enemy_alive), a
	cp #0
	jr z, death
		ret

	death:
		ld a, (enemy_x)
		ld (death_x), a
		ld a, (enemy_y)
		ld (death_y), a

	ret  

enemy_isAlive::
	ld hl, #enemy_alive
	ret		

;;===========================================
;;===========================================
;;PRIVATE FUNCTIONS
;;===========================================
;;===========================================

;; ======================
;; Enemy was killed
;; ======================
enemyOver:
	ld a, (death_isDraw)	;;Si la calavera se ha pintado
	cp #01					;;y animado ya una vez,
	jr z, draw				;;no se hace más

		ld a, (death_anim)		;;Cargamos nº alteraciones
		cp #0				
		jr z, end				;;Si nº alteraciones==0 terminamos ==> end
		ld a, (death_anim2)		;;sino cargamos la duración de la animación i
								;;y entramos en el loop
		loop:
			cp #0						;;Si la duración de la animación es 0,
			jr z, decrement_anim		;;pasamos al siguiente nº de animación

				push af					;;Pusheamos A para no perder el estado de duración

				ld a, (death_animState)
				cp #0		
				jr z, dibujar			;;Si es 0-->dibujar / 1-->borrar

				ld a, #0x00				;;||
				ld ix, #death_data		;;||Borramos
				call entity_draw		;;||

				ld a, #00				;;Alteramos el estado a 0
				ld (death_animState), a
				jr decrement_anim2

				dibujar:
					ld a, #0xFF			;;||
					ld ix, #death_data	;;||Dibujamos
					call entity_draw	;;||

					ld a, #01			;;Alteramos el estado a 1
					ld (death_animState), a

				decrement_anim2:
					pop af				;;Popeamos el estado de duración en A
					dec a				;;death_anim2--
					ld (death_anim2), a
					jr draw				;;Finalizamos hasta la siguiente llamada a enemyOver

			decrement_anim:
				ld a, #20				;;Volvemos a cargar a 20 la duración de la animación
				ld (death_anim2), a		;;para la animación i+1

				ld a, (death_anim)		;;Decrementamos nº animación
				dec a
				ld (death_anim), a

				jr draw					;;Finalizamos hasta la siguiente llamada a enemyOver

	end:
		ld hl, #death_isDraw	;;Guardamos en isDraw si está dibujada la calavera 
		ld a, #01				
		ld (hl), a

	draw:

	ret

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

		call hero_getPointerInvecible
		ld a, (hl)
		cp #1
			ret z 
		ld a, #1
		ld (hl), a
		call hero_decreaseLife
	
	not_collision:

	ret

Algorithm_Random::

	ld hl, #enemy_temp 						
	ld a, (hl) 								
	cp #0x04 								
	jr z, resetRandom							
		inc a 								
		ld (hl), a 							
		ret 								
	resetRandom:									
	ld (hl), #0x00

	call cpct_getRandom_lcg_u8_asm
	cp #64
	jp c, primerRango
	cp #128
	jp c, segundoRango
	cp #192
	jp c, tercerRango
		;; cuartoRango
		ld a, (enemy_y)
		cp #0
			ret z
		cp #1
			ret z
		cp #2
			ret z
		sub a, #3
		ld (enemy_y), a
		ret
	primerRango:
		ld a, (enemy_x)
		cp #80-7
		 ret z
		inc a
		ld (enemy_x), a
		ret
	segundoRango:
		ld a, (enemy_x)
		cp #0
		 ret z
		dec a
		ld (enemy_x), a
		ret
	tercerRango:
		ld a, (enemy_y)
		cp #200-26
		ret z
		cp #200-27
		ret z
		cp #200-25
			ret z
		add a, #3
		ld (enemy_y), a
		ret


;; ======================
;; Move enemy to the hero
;; ======================
Algorithm_FetchHero:
	
	ld hl, #enemy_temp 						
	ld a, (hl) 								
	cp #0x04 								
	jr z, resetFetch							
		inc a 								
		ld (hl), a 							
		ret 								
	resetFetch:									
	ld (hl), #0x00

	call hero_getPointer
	ld b, (hl)
	ld a, (enemy_x)
	cp b
	jr z, continue
	jr c, right
		;left
	dec a
	jr continue
	right:
		;right
		inc a
	continue:
	ld (enemy_x), a
	inc hl
	ld b, (hl)
	ld a, (enemy_y)
	cp b
	jr z, samePosition
	jr c, down
		;up
	sub a, #3
	push af
	sub b
	jp nc, endFetch

	equalsUp:
		ld a, (hl)
		ld (enemy_y), a
		pop af
		jr samePosition

	jr endFetch
	down:
		;down
		add a, #3
		push af
		sub b
		jr c, endFetch

		equalsDown:
			ld a, (hl)
			ld (enemy_y), a
			pop af
			jr samePosition

	endFetch:
	pop af
	ld (enemy_y), a

	samePosition:
	ret