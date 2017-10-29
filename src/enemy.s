.area _DATA

.globl _sprite_oldMan_left
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
.include "bullets.h.s"
.include "map.h.s"

enemy_memory::
	.dw #arrayEnemyA
enemy_id: 
	.db #01

.equ Enemy_x, 0
.equ Enemy_y, 1
.equ Enemy_w, 2
.equ Enemy_h, 3	
.equ EnemyLives, 6
.equ EnemyTemp, 7
.equ EnemyLastMovement, 8
.equ EnemyUX, 9
.equ EnemyPUX, 10
.equ EnemyUY, 11
.equ EnemyPUY, 12
.equ EnemyType, 13

;;Death Data
defineObject death 0, 0, 8, 16, _sprite_death
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
;;	INPUTS:
;; 		IX: Enemy data
;; ======================
enemy_update::

	ld a, EnemyLives(ix)
	cp #0
	;push ix
	;jr z, enemyOver
	ret z
		;pop ix
		ld a, EnemyType(ix)
		cp #0
		jr z, Shooter
		cp #1
		jr z, Random
		cp #2
		jr z, Fetch
			call Algorithm_Teletransport
			jr collision
		Shooter:
			call Algorithm_Shooter
			call enemyShoot
			jr collision
		Random:
			call Algorithm_Random
			jr collision
		Fetch:
			call Algorithm_FetchHero
		collision:

		call hero_getPointer
		call enemy_checkCollision

		call entity_updatePositions
ret

;; ======================
;;	Enemy Draw
;; 		IX: Enemy data
;; ======================
enemy_draw::
	ld a, EnemyLives(ix)
	cp #0
	ret z
		ld a, #0x6F
		call entity_draw
	ret

;; ======================
;;	Enemy Erase
;; 		IX: Enemy data
;; ======================
enemy_erase::
	ld a, EnemyLives(ix)
	cp #0
	ret z
		ld a, #0x00
		call entity_draw
	ret

;; ======================
;;	Gets a pointer to enemy data 
;;	
;;	RETURNS:
;; 		HL:Pointer to enemy data
;; ======================
enemy_getPointer::
	ld (enemy_memory), ix
	ld hl, (enemy_memory) ;; Hl points to the Enemy Data	
	ret	

;; ======================
;;	Enemy is death
;; ======================
enemy_enemyKill::
	ld a, EnemyLives(ix)
	dec a
	ld EnemyLives(ix), a
	cp #0
	jr z, death
		ret

	death:
		ld a, Enemy_x(ix)
		ld (death_x), a
		ld a, Enemy_y(ix)
		ld (death_y), a
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

	ld a, Enemy_x(ix)		;; | enemy_x
	ld c, a 				;; | +
	ld a, Enemy_w(ix)	 	;; | enemy_w
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
	ld a, Enemy_x(ix)
	ld b, a
	ld a, c
	sub b
	jr z, not_collision 	;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;;	If (enemy_y + enemy_h <= hero_y ) no_collision
	;;	enemy_y + enemy_h - hero_y <= 0
	;;

	ld a, Enemy_y(ix)			;; | enemy_x
	ld c, a 				;; | +
	ld a, Enemy_h(ix)	 		;; | obx_w
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
	ld a, Enemy_y(ix)
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
		call map_substractScore
	
	not_collision:

	ret

Algorithm_Shooter:
	call hero_getPointer
	inc hl
	ld b, (hl)
	ld a, Enemy_y(ix)
	cp b
	jr z, keepDistance
	jr c, incEnemy
		dec a
		ld Enemy_y(ix), a
		jr keepDistance
	incEnemy:
		inc a
		ld Enemy_y(ix), a

	keepDistance:
		dec hl
		ld a, Enemy_x(ix) 			; hl <= Enemy_x
		ld b, a 					; b <= Enemy_x
		ld a, (hl) 					; a <= hero_x
		cp b 					
		jr c, forward 				; Salta si enemy_x > hero_x
		jr z, forward
			;backward
			ld c, b
			ld b, a
			ld a, c 
			sub b
			cp #-20
			jr c, reverseShooter1
			jr z, endShooter
				ld a, Enemy_x(ix)
				cp #0
				 ret z
				dec a
				ld Enemy_x(ix), a
					ret
			reverseShooter1:

				ld a, #80
				ld b, Enemy_w(ix)
				sub b
				ld b, a
				ld a, Enemy_x(ix)
				cp b
				 ret z
				inc a
				ld Enemy_x(ix), a
					ret
				jr endShooter
		forward:
			ld c, b 				; c <= enemy_x
			ld b, a 				; b <= hero_x
			ld a, c  				; a <= enemy_x
			sub b 					; a = enemy_x - hero_x
			cp #40 					; Si 20 > a fin
			jr z, endShooter
			jr nc, reverseShooter2
				ld a, #80
				ld b, Enemy_w(ix)
				sub b
				ld b, a
				ld a, Enemy_x(ix)
				cp b
				 ret z
				inc a
				ld Enemy_x(ix), a
				ret 
		reverseShooter2:
				ld a, Enemy_x(ix)
				cp #0
				 ret z
				dec a
				ld Enemy_x(ix), a
		endShooter:
	ret

Algorithm_Teletransport::
	
	ld a, EnemyTemp(ix) 								
	cp #0x09 								
	jr z, resetTeletransport						
		inc a 								
		ld EnemyTemp(ix), a 							
		ret 								
	resetTeletransport:									
	ld EnemyTemp(ix), #0x00

	call cpct_getRandom_lcg_u8_asm
	cp #128
	jp c, primerRangoTeletransport
	cp #255
	jp c, segundoRangoTeletransport

	primerRangoTeletransport:
		ld a, #80
		ld b, Enemy_w(ix)
		sub b
		ld b, a
		call cpct_getRandom_lcg_u8_asm
		cp b
		jr c, siguienteComprobacionX
			ret
		siguienteComprobacionX:
			cp #0
				ret c
			ld Enemy_x(ix), a
			ret
	segundoRangoTeletransport:
		ld a, #200
		ld b, Enemy_h(ix)
		sub b
		ld b, a
		call cpct_getRandom_lcg_u8_asm
		cp b
		jr c, siguienteComprobacionY
			ret
		siguienteComprobacionY:
			cp #0
				ret c
			ld Enemy_y(ix), a
			ret
	
		

Algorithm_FetchHero:
	
	ld a, EnemyTemp(ix)  								
	cp #0x04 								
	jr z, resetFetch							
		inc a 								
		ld EnemyTemp(ix), a 							
		ret 								
	resetFetch:									
	ld EnemyTemp(ix), #0x00

	call hero_getPointer
	ld b, (hl)
	ld a, Enemy_x(ix)
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
	ld Enemy_x(ix), a
	inc hl
	ld b, (hl)
	ld a, Enemy_y(ix)
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
		ld Enemy_y(ix), a
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
			ld Enemy_y(ix), a
			pop af
			jr samePosition

	endFetch:
	pop af
	ld Enemy_y(ix), a

	samePosition:
	ret


Algorithm_Random:
						
	ld a, EnemyTemp(ix) 								
	cp #0x04 								
	jr z, resetRandom							
		inc a 								
		ld EnemyTemp(ix), a 							
		ret 								
	resetRandom:									
	ld EnemyTemp(ix), #0x00

	call cpct_getRandom_lcg_u8_asm
	cp #64
	jp c, primerRango
	cp #128
	jp c, segundoRango
	cp #192
	jp c, tercerRango
		;; cuartoRango
		ld a, Enemy_y(ix)
		cp #0
			ret z
		cp #1
			ret z
		cp #2
			ret z
		sub a, #3
		ld Enemy_y(ix), a
		ret
	primerRango:
		ld a, #80
		ld b, Enemy_w(ix)
		sub b
		ld b, a
		ld a, Enemy_x(ix)
		cp b
		 ret z
		inc a
		ld Enemy_x(ix), a
		ret
	segundoRango:
		ld a, Enemy_x(ix)
		cp #0
		 ret z
		dec a
		ld Enemy_x(ix), a
		ret
	tercerRango:
		ld a, Enemy_y(ix)
		cp #200-26
		ret z
		cp #200-27
		ret z
		cp #200-25
			ret z
		add a, #3
		ld Enemy_y(ix), a
		ret

enemyShoot:	
	ld a, EnemyTemp(ix)  			
	cp #0x30 			
	jr z, plus 			
		inc a 			
		ld EnemyTemp(ix), a 		
		ret 			
	plus:				
	ld EnemyTemp(ix), #0x00

	call entity_setPointer

	ld a, EnemyLastMovement(ix)
	call entity_setPointerLastMovement

	ld a, (enemy_id)
	call entity_setId

	call bullets_newBullet

	ret
