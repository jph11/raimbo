.area _DATA
.area _CODE

;;===========================================
;;===========================================
;;PRIVATE DATA
;;===========================================
;;===========================================

;; Bullets - Cantidad máxima de balas en pantalla 10
tempBullets: 
	.db #0x00
bullets:	;; Bullets (x,y,dirección)
	.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF;, #0xFF
	;.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
	;.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF  
	.db #0x81

bullet_w: .db #1

bullet_h: .db #1	

.include "hero.h.s"
.include "enemy.h.s"
.include "cpctelera.h.s"

;;===========================================
;;===========================================
;; PUBLIC FUNCTIONS
;;===========================================
;;===========================================

;;======================
;; Add a new bullet if posible 
;;======================
bullets_newBullet::
											;; Esta primera función guarda una bala cada dos veces y realiza un efecto de temporizador
	ld hl, #tempBullets 					;; hl <= tempBullets
	ld a, (hl) 								;; a <= (tempBullets)
	cp #0x02 								;; a == 0x02
	jr z, nueva 							;; if(!a==0x02){
		inc a 								;; 	a++
		ld (hl), a 							;; 	Actualizamos tempBullets
		ret 								;; 	Terminamos
	nueva:									;; }else{
	ld (hl), #0x00 							;;  Reiniciamos tempBullets y procedemos a guardar la bala
											;; }
	call checkAvalibility					;; Comprobamos si hay un hueco libre
	cp #-1									;; if(a == -1)
		ret z								;; No hay hueco libre, terminamos

	call hero_getPointer					;; hl <= Hero_data 		;; hl(hero_x)
	ld c, (hl)								;; c <= Hero_x
	inc hl									;; hl++ 				;; hl(hero_y)
	ld b, (hl)								;; b <= Hero_y
	ld hl, #bullets 						;; hl = referencia a memoria a #bullets_x
	bucleNew:								;;
	ld a, (hl)								;; a = hl(bullets_x)
	cp #0xFF								;; 
	jr nz, incrementNew						;; if (a != 0xFF){
		ld (hl), c 							;; 	bullet_x <= hero_x
		inc hl								;;  hl++  hl <= bullet_y
		ld (hl), b 							;; 	bullets_y <= hero_y 
		inc hl 								;;  hl++  hl <= bullet_direccion
		push hl 							;; Guardamos bullet_direccion, la siguiente llamada lo sobreescribe
		call hero_getPointerLastMovement    ;; Obtenemos la última direccioón del heroe 
		ld a, (hl) 							;; Cargamos la última posicion
		pop hl 								;; Recuperamos bullet_dirección
		ld (hl), a 							;; Y la guardamos
		ret 								;; 	Nueva bala añadida, terminamos
	incrementNew: 							;; }else{
	inc hl 									;; 	hl++  hl <= bullet_y
	inc hl 									;; 	hl++  hl <= bullet_direccion
	inc hl									;;  hl++  hl <= bullet_x
	jp bucleNew								;; 	Repetimos operación hasta encontrar hueco libre
											;; }

;; ======================
;;	Bullets Update
;; ======================
bullets_update::
	call updateBullets
	call enemy_getPointer
	call bullet_checkCollision
	ret

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

;; ======================
;; Bullet check collision
;; 	Inputs:
;; 	HL : Points to the other 
;;	Return:
;;		XXXXXXXX
  ;; ======================
bullet_checkCollision:
	
	ld de, #bullets 					;; hl = referencia a memoria a #bullets
	for: 								;;
	ld a, (de) 							;; a = hl(bullets_x)
	cp #0x81 							;; a == 0x81
		ret z 							;; if(a==0x81) ret
	cp #0xFF 							;; else a == 0xFF
	jr z, incr		 					;; Si la condición de arriba es verdadera salta a incrementar la dirección de memoria
	
	;;
	;;	If (bullet_x + bullet_w <= enemy_x ) no_collision
	;;	bullet_x + bullet_w - enemy_x <= 0
	;; 
	ld a, (de)					;; | bullet_x
	ld c, a 					;; | +
	ld a, (bullet_w)	 		;; | bullet_w
	add c 						;; | -
	sub (hl)					;; | enemy_x			
	jr z, not_collision 		;; | if(==0)
	jp m, not_collision 		;; | if(<0)

	;;
	;; 	If (enemy_x + enemy_w <= bullet_x)
	;; 	enemy_x + enemy_w - bullet_x <= 0
	;;

	ld a, (hl)
	inc hl
	inc hl
	add (hl)
	ld c, a
	ld a, (de)
	ld b, a
	ld a, c
	sub b
	jr z, not_collision 	;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;;	If (bullet_y + bullet_h <= enemy_y ) no_collision
	;;	bullet_y + bullet_h - enemy_y <= 0
	;;

	inc de

	ld a, (de)				;; | bullet_x
	ld c, a 				;; | +
	ld a, (bullet_h)	 	;; | obx_w
	add c
	dec hl					;; | -
	sub (hl)				;; | enemy_x			
	jr z, not_collision 	;; | if(==0)
	jp m, not_collision 	;; | if(<0)

	;;
	;; 	If (enemy_y + enemy_h <= bullet_x)
	;; 	enemy_y + enemy_h - bullet_y <= 0
	;;

	ld a, (hl)
	inc hl
	inc hl
	add (hl)
	ld c, a
	ld a, (de)
	ld b, a
	ld a, c
	sub b
	dec de
	jr z, not_collision 	;;| If(==0)
	jp m, not_collision 	;;| If(<0)

		;;Other posibilities of collision
		call enemy_erase
		call enemy_enemyKill
		ret
	
	not_collision:

	incr: 								;;
		inc de 							;; hl++  hl <= bullet_y
		inc de 							;; hl++  hl <= bullet_dirección
		inc de 							;; hl++  hl <= bullet_x	
	jp for	 							;;

	ret

;; ======================
;;	Check if avaible and then insert the bullet
;;  OUTPUTS: 
;;		A <= 1 Space
;;		A <= -1 No Space
;; ======================
checkAvalibility:
	ld hl, #bullets 			 		;;	Cargamos la dirección bullets en hl
	check: 								;;
	ld a, (hl)							;;	Cargamos VALOR de la posición hl(bullets_x) en a
	cp #0x81 							;;	Comprobamos fin array
	jr z, noHayHueco 					;;	Si fin array -> no hay hueco
	cp #0xFF 							;;	Comprobamos si está libre (0xFF)
	jr z, hayHueco 						;;	Si 0xFF -> hay Hueco
		inc hl							;;	hl++ hl <= bullet_y_1
		inc hl 							;;	hl++ hl <= bullet_direccion_1
		inc hl							;;	hl++ hl <= bullet_x_2
		jr check						;;	Saltamos para comprobar la siguiente posición 
	hayHueco: 							;;	Hueco
	ld a, #1 							;;	Devolvemos 1
	ret 								;;
	noHayHueco: 						;;	No hueco
	ld a, #-1 							;;	Devolvemos -1
	ret 								;;

drawBulletVertically:
	
;; ======================
;;	Draw the bullets that are storage in memory
;;  INPUTS: 
;;		A (Color)
;; ======================
drawBullet:
	push af 							;; Guardamos el color
	ld hl, #bullets 					;; hl = referencia a memoria a #bullets_x
	bucleDraw: 							;;
	ld a, (hl)  						;; A = (hl) Guardamos el primer valor de #bullets_x
	cp #0x81 							;; A == 0x81 Comparamos con fin del bucle
	jr z, fin 							;; if(a == 0x81) return 
	cp #0xFF							;; else if A = 0xFF
	jr z, incrementDraw 				;; Entonces saltar a incrementar la dirección de memoria
		ld c, a 						;; C = bullet_x
		inc hl 							;; hl++
		ld b, (hl) 						;; B = bullet_y
		ld de, #0xC000 					;; Video memory
		push hl 						;; Almacenamos la dirección de de bullets_y
		call cpct_getScreenPtr_asm 		;; Get pointer to screen
		ex de, hl 						;; de = posicion a pintar en pantalla, hl = ni idea (no nos importa)
		pop hl 							;; hl = bullets_y
		inc hl 							;; hl = bullets_dirección
		ld a, (hl) 						;; A = dirección
		push hl
		ex de, hl  						;; hl = posicion a pintar en pantalla, de = ni idea (no nos importa)
		cp #2 							;; Compramos con 2
		jr c, leftRight 				;; Si 2 mayor que dirección pitamos izquierda-derecha modo
		ex de, hl
		pop hl
		pop af
		cp #00
		jr z, borrar
			ld a, #0xAA
			ld (de), a
		borrar:
			ld (de), a
		jr keepGoingDraw 				;; Saltamos 
		leftRight:
		ex de, hl
		pop hl
		pop af
		ld (de), a 						;; Lo pintamos en la pantalla
		keepGoingDraw:
		inc hl 							;; Recuperamos bullets_x
		push af 						;; Mantenemos consistencia en la pila
		jr bucleDraw			 		;; Saltamos a incrementar la dirección de memoria
	incrementDraw: 						;;
	inc hl  							;; hl++  hl <= bullet_y
	increment_after_draw: 				;;
	inc hl 								;; hl++  hl <= bullet_direccion
	inc hl 								;; hl++  hl <= bullet_x
	jp bucleDraw 						;; Continuamos con el bucle
	fin: 								;;
	pop af 								;; hl++  hl <= bullet_y
	ret 

;; ======================
;;	Update all the bullets
;; ======================
updateBullets:
	ld hl, #bullets 					;; hl = referencia a memoria a #bullets
	bucle: 								;;
	ld a, (hl) 							;; a = hl(bullets_x)
	cp #0x81 							;; a == 0x81
		ret z 							;; if(a==0x81) ret
	cp #0xFF 							;; else a == 0xFF
	jr z, increment 					;; Si la condición de arriba es verdadera salta a incrementar la dirección de memoria

	startSwitch:
		push hl
		inc hl
		inc hl
		ld a, (hl)
		;; Izquierda
		cp #0
		jr z, left
			;; Derecha
			cp #1
			jr z, right
				;;Arriba-Abajo
				pop hl 	;; hl = bullets_x
				inc hl 	;; hl = bullets_y
				cp #2
				jr z, up
					;; Down
					ld a, (hl)
					cp #200-2
					jr z, resetVertical
					cp #200-1 
					jr z, resetVertical
					cp #200-3 
					jr z, resetVertical
					jr c, keepGoingDown
						jr resetVertical
					keepGoingDown:
						inc a
						inc a
						inc a
						ld (hl), a
						jr increment_after_update
				up:
					ld a, (hl)
					cp #0
					jr z, resetVertical
					jr c, resetVertical
						dec a
						dec a
						dec a
						ld (hl), a
						jr increment_after_update
		left:
			pop hl
			ld a, (hl)
			cp #0
			jr z,  reset
				dec a
				ld (hl), a
				jr increment
			right:
				pop hl
				ld a, (hl)
				cp #80-1
				jr z,  reset
					inc a
					ld (hl), a
					jr increment
	resetVertical:
		dec hl 							;; hl = bullet_x
	reset:
		ld (hl), #0xFF					;; bullet_x reiniciado
		inc hl							;; hl++	hl<= bullet_y
		ld (hl), #0xFF					;; bullet_y reiniciado
		jr increment_after_update		;;
	increment: 							;;
		inc hl 							;; hl++  hl <= bullet_y
	increment_after_update:				;;
		inc hl 							;; hl++  hl <= bullet_dirección
		inc hl 							;; hl++  hl <= bullet_x	
	jp bucle 							;;