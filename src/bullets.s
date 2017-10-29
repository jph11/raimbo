.area _DATA
.globl _sprite_bala
.globl ptilemapA
.area _CODE

;;===========================================
;;===========================================
;;PRIVATE DATA
;;===========================================
;;===========================================

;; Bullets - Cantidad máxima de balas en pantalla 10
nBullets::
	.db #0x00
bullets:	;; Bullets (x,y,dirección,idAsesino)
	.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
	.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
	.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
	.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
	.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
	.db #0x81

;; bullet_ux, bullet_pux, bullet_uy, bullet_puy
bullets_posiciones:
	.db #0x00, #0x00, #0x00, #0x00
	.db #0x00, #0x00, #0x00, #0x00
	.db #0x00, #0x00, #0x00, #0x00
	.db #0x00, #0x00, #0x00, #0x00
	.db #0x00, #0x00, #0x00, #0x00
	.db #0x00, #0x00, #0x00, #0x00
	.db #0x00, #0x00, #0x00, #0x00
	.db #0x00, #0x00, #0x00, #0x00
	.db #0x00, #0x00, #0x00, #0x00
	.db #0x00, #0x00, #0x00, #0x00

bullet_w: .db #03
bullet_h: .db #05
bullet_victim: .db #09		;Valor sin importancia

actual_enemy: .dw #0x0000

.equ Enemy_x, 0
.equ Enemy_y, 1
.equ Enemy_w, 2
.equ Enemy_h, 3	
.equ EnemyLives, 6
.equ EnemyTemp, 7
.equ EnemyLastMovement, 8
.equ EnemyType, 9

.equ bullet_ux, 0
.equ bullet_pux, 1
.equ bullet_uy, 2
.equ bullet_puy, 3

.include "hero.h.s"
.include "enemy.h.s"
.include "entity.h.s"
.include "game.h.s"
.include "cpctelera.h.s"
.include "map.h.s"

;;===========================================
;;===========================================
;; PUBLIC FUNCTIONS
;;===========================================
;;===========================================

;;======================
;; Add a new bullet if posible 
;;======================
bullets_newBullet::

	call checkAvalibility					;; Comprobamos si hay un hueco libre
	cp #-1									;; if(a == -1)
		ret z								;; No hay hueco libre, terminamos

						
	call entity_getPointer					;; hl <= Entity_data / hl(entity_x)
	ld a, (hl)								;; a <= Entity_x
	inc hl
	inc hl
	ld b, (hl)								;; b <= Entity_w
	add b									;; Sumamos para poner la salida de la bala en la pistola de hero
	ld c, a									;; c <= Entity_x + Entity_w

	dec hl									;; hl++ / hl(entity_y)
	ld a, (hl)								;; a <= Entity_y
	;========================================================================================================================================
	; 	Falta:
	;   inc hl
	;	inc hl  <= hl = entity_h
	;	(hl)/2
	;	add (hl)
	;========================================================================================================================================
	add #14
	ld b, a									;; b <= Entity_y + (Entity_h/2)
	ld hl, #bullets 						;; hl = referencia a memoria a #bullets_x
	ld iy, #bullets_posiciones

	bucleNew:									
	ld a, (hl)								;; a = hl(bullets_x)
	cp #0xFF								;; 
	jr nz, incrementNew						;; if (a != 0xFF){
		ld (hl), c 							;; 	bullet_x <= entity_x
		inc hl								;;  hl++  hl <= entity_y
		ld (hl), b 							;; 	bullets_y <= entity_y 

		ld bullet_ux(iy), c
		ld bullet_uy(iy), b

		ld bullet_pux(iy), c
		ld bullet_puy(iy), b

		inc hl 								;;  hl++  hl <= bullet_direccion
		push hl 							;; Guardamos bullet_direccion, la siguiente llamada lo sobreescribe
		call entity_getPointerLastMovement  ;; Obtenemos la última dirección del heroe 
		ld a, (hl) 							;; Cargamos la última posición
		pop hl 								;; Recuperamos bullet_dirección
		ld (hl), a 							;; Y la guardamos

		inc hl								;;  hl++  hl <= bullet_idAsesino
		push hl								;; Guardamos bullet_idAsesino, la siguiente llamada lo sobreescribe
		call entity_getId					;; Obtenemos quién dispara bullet 
		ld a, (hl)							;; Cargamos la idAsesino
		pop hl								;; Recuperamos bullet_idAsesino
		ld (hl), a							;; Y la guardamos

		ld a, (nBullets) 					;; Cargamos cantidad de balas 
		inc a 								;; Aumentamos
		ld (nBullets), a 					;; Volvemos a guardar
		ret 								;; 	Nueva bala añadida, terminamos

	incrementNew: 							;; }else{
	inc hl 									;; 	hl++  hl <= bullet_y
	inc hl 									;; 	hl++  hl <= bullet_direccion
	inc hl									;;  hl++  hl <= bullet_idAsesino
	inc hl									;;  hl++  hl <= bullet_x
	call bullets_posiciones_updatePointer	;;  Actualización puntero iy
	jp bucleNew								;; 	Repetimos operación hasta encontrar hueco libre
											;; }

;; ======================
;;	Erase bullets
;; ======================
bullets_erase::
	ld a, #0x00
	call drawBullet
	ret
;; ======================
;;	Draw bullets
;; ======================
bullets_draw::
	ld a, #0xFF
	call drawBullet
	ret

;;===========================================
;;===========================================
;;PRIVATE FUNCTIONS
;;===========================================
;;===========================================
bullets_posiciones_updateList::

	;; Actualización de las posiciones de las balas
	ld a, bullet_ux(iy)
	ld bullet_pux(iy), a

	ld a, bullet_uy(iy)
	ld bullet_puy(iy), a

	;;dec hl 							;; hl-- hl <= bullet_x
	ld a, (hl)
	ld bullet_ux(iy), a

	inc hl 							;; hl++ hl <= bullet_y
	ld a, (hl)
	ld bullet_uy(iy), a

	dec hl
ret

bullets_posiciones_updatePointer:

	inc iy
	inc iy
	inc iy
	inc iy
ret

bullets_cleanOrDraw::

	push hl
	push af

	ld de, (puntero_video)
	ld c, bullet_pux(iy)
	ld b, bullet_puy(iy)
	call cpct_getScreenPtr_asm

	ex de, hl

	pop af
	pop hl

	internal_draw:
	ld a, #0x00
	ld (de), a

	fin_cleanOrDraw:
ret

bullets_eraseBulletOnCollision::

	push hl
	push bc
	push de
	push af

	;; Calculamos y
	ld b, bullet_uy(iy)
	srl b
	srl b

	;; Calculamos x
	ld c, bullet_ux(iy)
	srl c

	;; Set Parameters on the stack
	ld   hl, (ptilemapA)   ;; HL = pointer to the tilemap
	push hl              ;; Push ptilemap to the stack
	ld   hl, #0xC000  ;; HL = Pointer to video memory location where tilemap is drawn
	push hl              ;; Push pvideomem to the stack
	;; Set Paramters on registers
	ld    a, #40 ;; A = map_width
	;;ld    b, #0          ;; B = y tile-coordinate
	;;ld    c, #0          ;; C = x tile-coordinate
	ld    d, #2          ;; H = height in tiles of the tile-box
	ld    e, #2          ;; L =  width in tiles of the tile-box
	call  cpct_etm_drawTileBox2x4_asm ;; Call the function

	;; Calculamos y
	ld b, bullet_uy(iy)
	srl b
	srl b

	;; Calculamos x
	ld c, bullet_ux(iy)
	srl c

	;; Set Parameters on the stack
	ld   hl, (ptilemapA)   ;; HL = pointer to the tilemap
	push hl              ;; Push ptilemap to the stack
	ld   hl, #0x8000  ;; HL = Pointer to video memory location where tilemap is drawn
	push hl              ;; Push pvideomem to the stack
	;; Set Paramters on registers
	ld    a, #40 ;; A = map_width
	;;ld    b, #0          ;; B = y tile-coordinate
	;;ld    c, #0          ;; C = x tile-coordinate
	ld    d, #2          ;; H = height in tiles of the tile-box
	ld    e, #2          ;; L =  width in tiles of the tile-box
	call  cpct_etm_drawTileBox2x4_asm ;; Call the function

	pop af
	pop de
	pop bc
	pop hl
ret

bullets_eraseBulletOnCollisionWithEntity::

	push hl
	push bc
	push de
	push af

	;; Calculamos y
	ld b, bullet_puy(iy)
	srl b
	srl b

	;; Calculamos x
	ld c, bullet_pux(iy)
	srl c

	;; Set Parameters on the stack
	ld   hl, (ptilemapA)   ;; HL = pointer to the tilemap
	push hl              ;; Push ptilemap to the stack
	ld   hl, #0xC000  ;; HL = Pointer to video memory location where tilemap is drawn
	push hl              ;; Push pvideomem to the stack
	;; Set Paramters on registers
	ld    a, #40 ;; A = map_width
	;;ld    b, #0          ;; B = y tile-coordinate
	;;ld    c, #0          ;; C = x tile-coordinate
	ld    d, #2          ;; H = height in tiles of the tile-box
	ld    e, #2          ;; L =  width in tiles of the tile-box
	call  cpct_etm_drawTileBox2x4_asm ;; Call the function

	;; Calculamos y
	ld b, bullet_puy(iy)
	srl b
	srl b

	;; Calculamos x
	ld c, bullet_pux(iy)
	srl c

	;; Set Parameters on the stack
	ld   hl, (ptilemapA)   ;; HL = pointer to the tilemap
	push hl              ;; Push ptilemap to the stack
	ld   hl, #0x8000  ;; HL = Pointer to video memory location where tilemap is drawn
	push hl              ;; Push pvideomem to the stack
	;; Set Paramters on registers
	ld    a, #40 ;; A = map_width
	;;ld    b, #0          ;; B = y tile-coordinate
	;;ld    c, #0          ;; C = x tile-coordinate
	ld    d, #2          ;; H = height in tiles of the tile-box
	ld    e, #2          ;; L =  width in tiles of the tile-box
	call  cpct_etm_drawTileBox2x4_asm ;; Call the function

	pop af
	pop de
	pop bc
	pop hl
ret

bullet_whoShots::
	inc de  			;; de++  de <= bullet_idAsesino 
	inc de
	inc de
	ld a, (de)
	dec de
	dec de
	dec de
	cp #00
	jr z, heroShoot
		ld a, #00
		ld (bullet_victim), a
		ld ix, #hero_data
		ret
	heroShoot:
		push hl
		push de

		ld hl, #actual_enemy
		ld e, (hl)

		inc hl

		ld d, (hl)

		push de
		pop ix

		pop de
		pop hl

		;;push iy
		;;pop ix

		ld a, #01
		ld (bullet_victim), a
		ret

;; ======================
;; Bullet check collision
;; 	Inputs:
;; 		HL : Points to the other 
;; ======================
bullet_checkCollision::
	
	ld a, (nBullets)
	cp #0
	ret z
	ld de, #bullets 					;; de = referencia a memoria a #bullets
	ld iy, #bullets_posiciones

	push hl

	push ix
	pop bc

	ld hl, #actual_enemy
	ld (hl), c

	inc hl
	ld (hl), b

	pop hl
	;;push ix
	;;pop iy
	for:								;;
	ld a, (de) 							;; a = de(bullets_x)
	cp #0x81 							;; a == 0x81
		ret z 							;; if(a==0x81) ret
	cp #0xFF 							;; else a == 0xFF
	jp z, incr		 					;; Si la condición de arriba es verdadera salta a incrementar la dirección de memoria

	call bullet_whoShots

	;;
	;;	If (bullet_x + bullet_w <= enemy_x ) no_collision
	;;	bullet_x + bullet_w - enemy_x <= 0
	;; 
	ld a, (de)					;; | bullet_x
	ld c, a 					;; | +
	ld a, (bullet_w)	 		;; | bullet_w
	add c 						;; | -
	sub Enemy_x(ix)				;; | enemy_x			
	jr z, not_collision 		;; | if(==0)
	jp m, not_collision 		;; | if(<0)

	;;
	;; 	If (enemy_x + enemy_w <= bullet_x)
	;; 	enemy_x + enemy_w - bullet_x <= 0
	;;

	ld a, Enemy_x(ix)			;; | enemy_x
	add Enemy_w(ix)				;; | enemy_x + enemy_w
	ld c, a						;; C <= enemy_x + enemy_w
	ld a, (de)					;; A <= bullet_x
	ld b, a						;; B <= bullet_x
	ld a, c						;; A <= enemy_x + enemy_w
	sub b						;; (enemy_x + enemy_w) - bullet_x
	jr z, not_collision 		;; | if(==0)
	jp m, not_collision 		;; | if(<0)

	;;
	;;	If (bullet_y + bullet_h <= enemy_y ) no_collision
	;;	bullet_y + bullet_h - enemy_y <= 0
	;;

	inc de								;; | de++ / de = bullet_y
	ld a, (de)							;; | A <= bullet_y
	ld c, a 							;; | C <= bullet_y
	ld a, (bullet_h)	 				;; | A <= bullet_h
	add c								;; | bullet_y + bullet_h
	sub Enemy_y(ix)						;; | (bullet_y + bullet_h) enemy_y
	jr z, not_collision_dec1DE 			;; | if(==0)
	jp m, not_collision_dec1DE 	 		;; | if(<0)

	;;
	;; 	If (enemy_y + enemy_h <= bullet_y)
	;; 	enemy_y + enemy_h - bullet_y <= 0
	;;
	ld a, Enemy_y(ix)					;; | A <= enemy_y
	add Enemy_h(ix)						;; | enemy_y + enemy_h
	ld c, a								;; | C <= enemy_y + enemy_h
	ld a, (de)							;; | A <= bullet_y
	ld b, a								;; | B <= bullet_y
	ld a, c								;; | A <= enemy_y + enemy_h
	sub b								;; | (enemy_y + enemy_h) - bullet_y
	dec de								;; | de-- / de = bullet_x
	jr z, not_collision 			;;| If(==0)
	jp m, not_collision 			;;| If(<0)

		;;Other posibilities of collision
			ld a, (bullet_victim)
			cp #00
			jr nz, enemyVictim
			
				;;Hero es la víctima
				call hero_getPointerInvecible
				ld a, (hl)
				cp #1
					ret z 
				ld a, #1
				ld (hl), a
				call hero_decreaseLife

				call bullets_eraseBulletOnCollisionWithEntity

				ld a, #0xFF			;;||
				ld (de), a			;;|| Borramos la bala 
				inc de 				;;|| que ha matado a enemy
				ld (de), a			;;||

				ld a, (nBullets)
				dec a
				ld (nBullets), a
				
				ret

			;;Enemy es la víctima
			enemyVictim:
				ld a, EnemyLives(ix)	;;|| Si el enemigo ya está muerto finalizamos
				cp #0					;;||
				ret z

				call bullets_eraseBulletOnCollisionWithEntity

				ld a, #0xFF				;;||
				ld (de), a				;;|| Borramos la bala 
				inc de 					;;|| que ha matado a enemy
				ld (de), a				;;||

				ld a, (nBullets)
				dec a
				ld (nBullets), a

				call enemy_erase
				call enemy_enemyKill

				ret

	not_collision_dec1DE:
	dec de
	not_collision:
	incr: 								
		inc de 							;; de++  de <= bullet_y
		inc de 							;; de++  de <= bullet_dirección
		inc de 							;; de++  de <= bullet_idAsesino
		inc de 							;; de++  de <= bullet_x
		call bullets_posiciones_updatePointer
	jp for	 							

	ret

;; ======================
;;	Check if avaible and then insert the bullet
;;  OUTPUTS: 
;;		A <= 1 Space
;;		A <= -1 No Space
;; ======================
checkAvalibility:
	ld a, (nBullets)
	cp #15
	jr z, noHayHueco
	hayHueco: 							;;	Hueco
	ld a, #1 							;;	Devolvemos 1
	ret 								;;
	noHayHueco: 						;;	No hueco
	ld a, #-1 							;;	Devolvemos -1
	ret
	
;; ======================
;;	Draw the bullets that are storage in memory
;;  INPUTS: 
;;		A (Color)
;; ======================
drawBullet::
	push af 							;; Guardamos el color
	ld a, (nBullets)
	cp #0
		jr z, fin

	ld hl, #bullets 					;; hl = referencia a memoria a #bullets_x
	ld iy, #bullets_posiciones

	bucleDraw: 							
	ld a, (hl)  						;; A = (hl) Guardamos el primer valor de #bullets_x
	cp #0x81 							;; A == 0x81 Comparamos con fin del bucle
	jr z, fin 							;; if(a == 0x81) return 
	cp #0xFF							;; else if A = 0xFF
	jr z, incrementDraw 				;; Entonces saltar a incrementar la dirección de memoria
		ld c, a 						;; C = bullet_x
		inc hl 							;; hl++
		ld b, (hl) 						;; B = bullet_y
		ld de, (puntero_video) 					;; Video memory
		push hl 						;; Almacenamos la dirección de de bullets_y
		call cpct_getScreenPtr_asm 		;; Get pointer to screen						
		ex de, hl 						;; de = posicion a pintar en pantalla, hl = ni idea (no nos importa)
		pop hl 							;; hl = bullets_y
		pop af
		push af
		cp #0
		jr z, borrar

			push hl
			push af
			push bc
			push de

			ld hl, #_sprite_bala

			;;Draw sprite
			ld c, #3
			ld b, #5
			call cpct_drawSprite_asm

			pop de
			pop bc
			pop af
			pop hl
			jr increment_after_draw
		borrar:
			push hl
			push bc
			push de
			push af

			;; Calculamos y
			ld b, bullet_puy(iy)
			srl b
			srl b

			;; Calculamos x
			ld c, bullet_pux(iy)
			srl c

			;; Set Parameters on the stack
			ld   hl, (ptilemapA)   ;; HL = pointer to the tilemap
			push hl              ;; Push ptilemap to the stack
			ld   hl, (puntero_video)  ;; HL = Pointer to video memory location where tilemap is drawn
			push hl              ;; Push pvideomem to the stack
			;; Set Paramters on registers
			ld    a, #40 ;; A = map_width
			;;ld    b, #0          ;; B = y tile-coordinate
			;;ld    c, #0          ;; C = x tile-coordinate
			ld    d, #2          ;; H = height in tiles of the tile-box
			ld    e, #2          ;; L =  width in tiles of the tile-box
			call  cpct_etm_drawTileBox2x4_asm ;; Call the function

			pop af
			pop de
			pop bc
			pop hl

			jr increment_after_draw
			;;BORRAR
			;;push hl

			;;ld de, (puntero_video)
			;;ld c, bullet_pux(iy)
			;;ld b, bullet_puy(iy)
			;;call cpct_getScreenPtr_asm
			
			;;ex de, hl

			;;pop hl

			;;ld a, #0x00
			;;ld c, #1
			;;ld b, #1
			;;call cpct_drawSolidBox_asm


			;; Mirar el puntero de hl a ver dónde hay que saltar
	incrementDraw: 						
	inc hl  							;; hl++  hl <= bullet_y
	increment_after_draw: 				
	inc hl 								;; hl++  hl <= bullet_direccion
	inc hl 								;; hl++  hl <= bullet_idAsesino
	inc hl 								;; hl++  hl <= bullet_x
	call bullets_posiciones_updatePointer
	jp bucleDraw 						;; Continuamos con el bucle
	fin: 								
	pop af 								;; hl++  hl <= bullet_y
ret 


;; ======================
;;	Update all the bullets
;; ======================
bullets_updateBullets::

	ld a, (nBullets)
	cp #0
	ret z

	ld hl, #bullets 					;; hl = referencia a memoria a #bullets
	ld iy, #bullets_posiciones
	bucle: 								;;
	ld a, (hl) 							;; a = hl(bullets_x)
	cp #0x81 							;; a == 0x81
		ret z 							;; if(a==0x81) ret
	cp #0xFF 							;; else a == 0xFF
	jp z, increment 					;; Si la condición de arriba es verdadera
										;; salta a incrementar la dirección de memoria

	startSwitch:
		push hl		;; hl = bullets_x
		inc hl		;; hl = bullets_y
		inc hl		;; hl = bullets_direccion
		ld a, (hl)
		;; Izquierda
		cp #0
		jr z, left
			;; Derecha
			cp #1
			jr z, right
				;; Arriba-Izquierda
				cp #4
				jr z, up_left
					;; Arriba-Derecha
					cp #5
					jr z, up_right
						;; Abajo-Izquierda
						cp #6
						jp z, down_left
							;; Abajo-Derecha
							cp #7
							jp z, down_right
								;;Arriba-Abajo
								pop hl 	;; hl = bullets_x
								inc hl 	;; hl = bullets_y
								cp #2
								jr z, up
									;; Down
									ld a, (hl)
									cp #200-14-18 
									jp nc, resetVertical
										add a, #9
										ld (hl), a

										dec hl 	;; hl = bullets_x
										call bullets_posiciones_updateList
										jp increment
								up:
									ld a, (hl)
									cp #9
									jp c, resetVertical
										sub a, #9
										ld (hl), a

										dec hl 	;; hl = bullets_x
										call bullets_posiciones_updateList
										jp increment
		left:
			pop hl		;; hl = bullets_x
			ld a, (hl)
			cp #3
			jp c,  reset
				dec a
				dec a
				dec a
				ld (hl), a
				call bullets_posiciones_updateList
				jp increment
			right:
				pop hl	;; hl = bullets_x
				ld a, (hl)
				cp #80-6
				jr nc,  reset
					inc a
					inc a
					inc a
					ld (hl), a
					call bullets_posiciones_updateList
					jr increment
				up_left:
					pop hl		;; hl = bullets_x
					ld a, (hl)
					cp #3
					jr c, reset
						inc hl 		;; hl = bullets_y
						ld a, (hl)
						cp #9
						jr c, resetVertical
						sub a, #9
						ld (hl), a
						dec hl 			;; hl = bullets_x
						ld a, (hl) 
						dec a
						dec a
						dec a
						ld (hl), a
						call bullets_posiciones_updateList
						jr increment
						up_right:
							pop hl		;; hl = bullets_x
							ld a, (hl)
							cp #80-6
							jr nc, reset
								inc hl 		;; hl = bullets_y
								ld a, (hl)
								cp #9
								jr c, resetVertical
								sub a, #9
								ld (hl), a
								dec hl 			;; hl = bullets_x
								ld a, (hl) 
								inc a
								inc a
								inc a
								ld (hl), a
								call bullets_posiciones_updateList
								jr increment
								down_left:
									pop hl		;; hl = bullets_x
									ld a, (hl)
									cp #3
									jr c, reset
										inc hl 		;; hl = bullets_y
										ld a, (hl)
										cp #200-14-18
										jr nc, resetVertical
										add a, #9
										ld (hl), a
										dec hl 			;; hl = bullets_x
										ld a, (hl) 
										dec a
										dec a
										dec a
										ld (hl), a
										call bullets_posiciones_updateList
										jr increment
										down_right:
											pop hl		;; hl = bullets_x
											ld a, (hl)
											cp #80-6
											jr nc, reset
												inc hl 		;; hl = bullets_y
												ld a, (hl)
												cp #200-14-18
												jr nc, resetVertical
												add a, #9
												ld (hl), a
												dec hl 			;; hl = bullets_x
												ld a, (hl) 
												inc a
												inc a
												inc a
												ld (hl), a
												call bullets_posiciones_updateList
												jr increment

	resetVertical:
		dec hl 							;; hl = bullet_x
	reset:
		call bullets_eraseBulletOnCollision

		ld (hl), #0xFF					;; bullet_x reiniciado
		inc hl							;; hl++	hl<= bullet_y
		ld (hl), #0xFF					;; bullet_y reiniciado

		ld a, (nBullets) 				;; Cargamos cantidad de balas 
		dec a 							;; Decrementamos 
		ld (nBullets), a 				;; Volvemos a guardar
		jr increment_after_update		
	increment: 							
		inc hl 							;; hl++  hl <= bullet_y
	increment_after_update:

		;; Actualización del puntero iy a la siguiente bala
		call bullets_posiciones_updatePointer

		inc hl 							;; hl++  hl <= bullet_dirección
		inc hl 							;; hl++  hl <= bullet_idAsesino
		inc hl 							;; hl++  hl <= bullet_x	
	jp bucle 		

;; ======================
;;	Delete all the bullets
;; ======================
bullets_deleteAllBullets::

	ld a, (nBullets)
	cp #0
	ret z

	ld a, #0
	ld (nBullets), a

	ld hl, #bullets 					;; hl = referencia a memoria a #bullets
	bucleDelete: 								;;
	ld a, (hl) 							;; a = hl(bullets_x)
	cp #0x81 							;; a == 0x81
		ret z 							;; if(a==0x81) ret
	ld a, #0xFF
	ld (hl), a
	inc hl
	jr bucleDelete