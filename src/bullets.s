.area _DATA
.area _CODE

;;===========================================
;;===========================================
;;PRIVATE DATA
;;===========================================
;;===========================================

;; Bullets - Cantidad máxima de balas en pantalla 10

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
	call checkAvalibility				;; Comprobamos si hay un hueco libre
	cp #-1								;; if(a == -1)
		ret z							;; No hay hueco libre, terminamos

	call hero_getPointer				;; hl <= Hero_data 		;; hl(hero_x)
	ld c, (hl)							;; c <= Hero_x
	inc hl								;; hl++ 				;; hl(hero_y)
	ld b, (hl)							;; b <= Hero_y
	ld hl, #bullets 					;; hl = referencia a memoria a #bullets_x
	bucleNew:							;;
	ld a, (hl)							;; a = hl(bullets_x)
	cp #0xFF							;; 
	jr nz, incrementNew					;; if (a != 0xFF){
		ld (hl), c 						;; 	bullet_x <= hero_x
		inc hl							;;  hl++  hl <= bullet_y
		ld (hl), b 						;; 	bullets_y <= hero_y 
		ret 							;; 	Nueva bala añadida, terminamos
	incrementNew: 						;; }else{
	inc hl 								;; 	hl++  hl <= bullet_y
	inc hl 								;; 	hl++  hl <= bullet_direccion
	inc hl								;;  hl++  hl <= bullet_x
	jp bucleNew							;; 	Repetimos operación hasta encontrar hueco libre
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

	push af
	ld hl, #bullets
	bucleDraw:
	ld a, (hl)
	cp #0x81
	jr z, fin
	cp #0xFF
	jr z, incrementDraw
		ld c, a
		inc hl
		ld b, (hl)
		ld de, #0xC000
		pop af
		push hl
		push af
		call cpct_getScreenPtr_asm
		pop af
		ld (hl), a
		pop hl
		push af
		jr increment_after_draw
	incrementDraw:
	inc hl
	increment_after_draw:
	inc hl
	inc hl
	jp bucleDraw
	fin:
	pop af
	ret 


	;;push af								;; Guardamos el color
	;;ld hl, #bullets_y 					;; hl = referencia a memoria a #bullets_y
	;;ex de, hl 							;; de <> hl Guardamos referencia a #bullets_y
	;;ld hl, #bullets_x  					;; hl = referencia a memoria a #bullets_x   
	;;bucleDraw:							;; 																;;hl <= bullets_x ;; de <= bullets_y
	;;ld a, (hl)							;; A = (hl) Guardamos el primer valor de #bullets_x
	;;cp #0x81 							;; A == 0x81 Comparamos con fin del bucle
	;;jr z, fin 							;; if(a == 0x81) return 
	;;cp #0xFF							;; else if A = 0xFF
	;;jr z, incrementDraw 				;; Entonces saltar a incrementar la dirección de memoria
	;;	ld c, a 						;; C = bullet_x
	;;	ex de, hl 						;; Cambiamos de <> hl											;;hl <= bullets_y ;; de <= bullets_y
	;;	ld b, (hl) 						;; B = bullet_y
	;;	ex de, hl 						;; Cambiamos de <> hl 											;;hl <= bullets_x ;; de <= bullets_y	
	;;	pop af 							;; 	| Recuperamos el valor para mantener orden en la pila
	;;	push de 						;; 	| 
	;;	push hl 						;;  | Guardamos valores de(bullets_x), hl(bullets_y), af (Color), 
	;;	push af 						;;  \ porque la función cpct_getScreenPtr_asm las modificar
	;;	ld de, #0xC000					;; Video memory
	;;	call cpct_getScreenPtr_asm		;; Get pointer to screen
	;;	pop af							;; Recuperamos el color
	;;	ld (hl), a						;; Pintamos el color
	;;	pop hl 							;; Recuperamos hl(bullets_x)
	;;	pop de 							;; Recuperamos hl(bullets_y)
	;;	push af							;; Puseamos el valor af, por si a la siguiente vamos a fin:
	;;									;; el cual hace pop de af (necesario por el primer push af de todos)
	;;incrementDraw: 						;; Incrementamos la posicion de memoria para el siguiente valor
	;;inc hl 								;; hl++  (bullets_x)++
	;;inc de 								;; de++  (bullets_y)++
	;;jp bucleDraw						;;
	;;fin:								;;
	;;pop af								;; Sacamos el último push af
	;;ret 								;; Terminamos

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
	jr nz, update 					;; Si está en el final de la pantalla...
		ld (hl), #0xFF				;; bullet_x reiniciado
		inc hl						;; hl++	hl<= bullet_y
		ld (hl), #0xFF				;; bullet_y reiniciado
		jr increment_after_update	;;
	update: 						;;
	inc a 							;; Aumentamos a 
	ld (hl), a 						;; Modificar a nueva posicion (bullet_x++)
	increment: 						;;
	inc hl 							;; hl++  hl <= bullet_y
	increment_after_update:			;;
	inc hl 							;; hl++  hl <= bullet_dirección
	inc hl 							;; hl++  hl <= bullet_x
	jp bucle 						;;


	;;ld hl, #bullets_y  		;; hl = referencia a memoria a #bullets_y
	;;ex de, hl 				;; de = hl Guardamos referencia a #bullets_y
	;;ld hl, #bullets_x 		;; hl = referencia a memoria a #bullets_x
	;;bucle:					;;	
	;;ld a, (hl)				;; A = hl(bullets_x)
	;;cp #0x81				;; A == 0x81
	;;	ret z				;; if(a==0x81) ret
	;;cp #0xFF				;; else if A = 0xFF
	;;jr z, increment 		;; Si la condición de arriba es verdadera salta a incrementar la dirección de memoria
	;;cp #80-1				;; Comprobamos si está al final de la pantalla
	;;jr nz, update 			;; Si está en el final de la pantalla
	;;	ld (hl), #0xFF  	;; Borramos la bala_x poniendola a 0xFF 
	;;	ex de, hl 			;; de <> hl																;;hl <= bullets_y ;; de <= bullets_x
	;;	ld (hl), #0xFF 		;; Borramos la bala_y poniendola a 0xFF
	;;	ex de , hl 			;; de <> hl																;;hl <= bullets_x ;; de <= bullets_y
	;;	jr increment		;; \ pasamos a la siguiente bala	
	;;update: 				;;
	;;inc a					;; Aumentamos a ====> bullet_x++
	;;ld (hl), a 				;; Modificar a nueva posicion
	;;increment: 				;;
	;;inc hl 					;; hl++  (bullets_x)++
	;;inc de 					;; de++  (bullets_y)++
	;;jp bucle 				;;