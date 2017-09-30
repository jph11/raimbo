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
	.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
	.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF
	.db #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF, #0xFF  
	.db #0x81

.include "hero.h.s"
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
;;	Check if avaible and then insert the bullet
;;  OUTPUTS: 
;;		A <= 1 Space
;;		A <= -1 No Space
;; ======================
checkAvalibility:
	ld hl, #bullets 			 	;;	Cargamos la dirección bullets en hl
	check: 							;;
	ld a, (hl)						;;	Cargamos VALOR de la posición hl(bullets_x) en a
	cp #0x81 						;;	Comprobamos fin array
	jr z, noHayHueco 				;;	Si fin array -> no hay hueco
	cp #0xFF 						;;	Comprobamos si está libre (0xFF)
	jr z, hayHueco 					;;	Si 0xFF -> hay Hueco
		inc hl						;;	hl++ hl <= bullet_y_1
		inc hl 						;;	hl++ hl <= bullet_direccion_1
		inc hl						;;	hl++ hl <= bullet_x_2
		jr check					;;	Saltamos para comprobar la siguiente posición 
	hayHueco: 						;;	Hueco
	ld a, #1 						;;	Devolvemos 1
	ret 							;;
	noHayHueco: 					;;	No hueco
	ld a, #-1 						;;	Devolvemos -1
	ret 							;;

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
		pop af 							;; Mantenemos consistencia en pila
		push hl 						;; Almacenamos la dirección de de bullets_x
		push af 						;; Guardamos Color
		call cpct_getScreenPtr_asm 		;; Get pointer to screen
		pop af 							;; Recuperamos color
		ld (hl), a 						;; Lo pintamos en la pantalla
		pop hl 							;; Recuperamos bullets_x
		push af 						;; Mantenemos consistencia en la pila
		jr increment_after_draw 		;; Saltamos a incrementar la dirección de memoria
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
	ld hl, #bullets 				;; hl = referencia a memoria a #bullets
	bucle: 							;;
	ld a, (hl) 						;; a = hl(bullets_x)
	cp #0x81 						;; a == 0x81
		ret z 						;; if(a==0x81) ret
	cp #0xFF 						;; else a == 0xFF
	jr z, increment 				;; Si la condición de arriba es verdadera salta a incrementar la dirección de memoria
	cp #80-1 						;; Comprobamos si está al final de la pantalla
	jr z, reset 					;; Si está en el final de la pantalla...
	cp #0
	jr nz, update 					;; Si está en el principio de la pantalla...
	reset:
		ld (hl), #0xFF				;; bullet_x reiniciado
		inc hl						;; hl++	hl<= bullet_y
		ld (hl), #0xFF				;; bullet_y reiniciado
		jr increment_after_update	;;
	update: 						;;
	push hl 						;; Guardamos bullets_x
	ld b, a 						;; Guardamos x
	inc hl 							;; hl++  hl <= bullet_y
	inc hl 							;; hl++  hl <= bullet_direccion
	ld a, (hl) 						;; Obtenemos la última dirección que el usuario se ha movido
	cp #01 							;; Se ha movido derecha
	ld a, b 						;; Cargamos x en a 
	pop hl 							;; Recuperamos bullets_x
	jr z, right 					;;
	dec a 							;; Decrementamos a  (izquierda)
	ld (hl), a 						;; Modificar a nueva posicion (bullet_x--)
	jr increment  					;;
	right: 							;;
	inc a 							;; Aumentamos a (derecha)
	ld (hl), a 						;; Modificar a nueva posicion (bullet_x++)
	jr increment 					;;
	increment: 						;;
	inc hl 							;; hl++  hl <= bullet_y
	increment_after_update:			;;
	inc hl 							;; hl++  hl <= bullet_dirección
	inc hl 							;; hl++  hl <= bullet_x
	jp bucle 						;;