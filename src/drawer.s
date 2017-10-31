.area _DATA

;;=============================================
press: .db #80,#82,#69,#83,#83,#0
g: .db #71,#0
to: .db #84,#79,#0
play: .db #80,#76,#65,#89,#0
w: .db #87,#0
a: .db #65,#0
s: .db #83,#0
d: .db #68,#0
p: .db #71,#0
up: .db #240,#0
left: .db #242,#0
right: .db #243,#0
down: .db #241,#0
space: .db #83,#80,#65,#67,#69,#0
to2: .db #116,#111,#0
shoot: .db #115,#104,#111,#111,#116,#0
score: .db #83,#67,#79,#82,#69,#0
lives: .db #76,#73,#86,#69,#83,#0
game: .db #71,#65,#77,#69,#0
over: .db #79,#86,#69,#82,#0
;;=============================================

.area _CODE

.include "game.h.s"
.include "cpctelera.h.s"
.include "macros.h.s"

defineWord pressL, 31, 65, 5, 13

defineWord gL, 38, 80, 5, 9

defineWord toL, 28, 95, 5, 13

defineWord playL, 38, 95, 5, 13
;;===================================

defineWord wL, 10, 130, 5, 2

defineWord aL, 2, 145, 5, 2

defineWord sL, 10, 145, 5, 2

defineWord dL, 18, 145, 5, 2
;;===================================
defineWord upL, 66, 130, 5, 2

defineWord leftL, 58, 145, 5, 2

defineWord rightL, 74, 145, 5, 2

defineWord downL, 66, 145, 5, 2
;;===================================
defineWord spaceL, 31, 160, 5, 2

defineWord to2L, 26, 175, 5, 13

defineWord shootL, 36, 175, 5, 13
;==================================
defineWord pressO, 12, 189, 2, 13

defineWord gO, 35, 189, 2, 9

defineWord toO, 42, 189, 2, 13

defineWord playO, 52, 189, 2, 13
;==================================
defineWord scoreO, 40, 189, 2, 13

defineWord livesO, 4, 189, 2, 13
;==================================
defineWord GameO, 22, 75, 1, 13

defineWord OverO, 42, 75, 1, 13

.equ M_x, 0
.equ M_y, 1
.equ M_w, 2
.equ M_h, 3	
.equ M_spr_l, 4
.equ M_spr_h, 5	

.equ L_x, 0
.equ L_y, 1
.equ L_c, 2
.equ L_b, 3

writePressToPlay::
	ld ix, #pressL_data
	ld de, #0xC000
	ld hl, #press
	call drawWord

	ld ix, #pressL_data
	ld de, #0x8000
	ld hl, #press
	call drawWord

	ld ix, #gL_data
	ld de, #0xC000
	ld hl, #g
	call drawWord

	ld ix, #gL_data
	ld de, #0x8000
	ld hl, #g
	call drawWord

	ld ix, #toL_data
	ld de, #0xC000
	ld hl, #to
	call drawWord

	ld ix, #toL_data
	ld de, #0x8000
	ld hl, #to
	call drawWord

	ld ix, #playL_data
	ld de, #0xC000
	ld hl, #play
	call drawWord

	ld ix, #playL_data
	ld de, #0x8000
	ld hl, #play
	call drawWord
ret

writeWASD::
	ld ix, #wL_data
	ld de, #0xC000
	ld hl, #w
	call drawWord

	ld ix, #wL_data
	ld de, #0x8000
	ld hl, #w
	call drawWord

	ld ix, #aL_data
	ld de, #0xC000
	ld hl, #a
	call drawWord

	ld ix, #aL_data
	ld de, #0x8000
	ld hl, #a
	call drawWord

	ld ix, #sL_data
	ld de, #0xC000
	ld hl, #s
	call drawWord

	ld ix, #sL_data
	ld de, #0x8000
	ld hl, #s
	call drawWord

	ld ix, #dL_data
	ld de, #0xC000
	ld hl, #d
	call drawWord

	ld ix, #dL_data
	ld de, #0x8000
	ld hl, #d
	call drawWord
ret	

writeArrows::
	ld ix, #upL_data
	ld de, #0xC000
	ld hl, #up
	call drawWord

	ld ix, #upL_data
	ld de, #0x8000
	ld hl, #up
	call drawWord

	ld ix, #leftL_data
	ld de, #0xC000
	ld hl, #left
	call drawWord

	ld ix, #leftL_data
	ld de, #0x8000
	ld hl, #left
	call drawWord

	ld ix, #rightL_data
	ld de, #0xC000
	ld hl, #right
	call drawWord

	ld ix, #rightL_data
	ld de, #0x8000
	ld hl, #right
	call drawWord

	ld ix, #downL_data
	ld de, #0xC000
	ld hl, #down
	call drawWord

	ld ix, #downL_data
	ld de, #0x8000
	ld hl, #down
	call drawWord
ret

writeSpace::
	ld ix, #spaceL_data
	ld de, #0xC000
	ld hl, #space
	call drawWord

	ld ix, #spaceL_data
	ld de, #0x8000
	ld hl, #space
	call drawWord

	ld ix, #to2L_data
	ld de, #0xC000
	ld hl, #to2
	call drawWord

	ld ix, #to2L_data
	ld de, #0x8000
	ld hl, #to2
	call drawWord

	ld ix, #shootL_data
	ld de, #0xC000
	ld hl, #shoot
	call drawWord

	ld ix, #shootL_data
	ld de, #0x8000
	ld hl, #shoot
	call drawWord
ret

drawWord::
	push hl
	ld c, L_x(ix)
	ld b, L_y(ix)
	call cpct_getScreenPtr_asm
	ex de, hl

	pop hl
	ld b, L_c(ix)
	ld c, L_b(ix)
	call cpct_drawStringM0_asm
ret

drawSprite::
	ld de, #0xC000				;;Video memory
	ld c, M_x(ix)				;;\ C=entity_x
	ld b, M_y(ix)				;;\ B=entity_y
	call cpct_getScreenPtr_asm	;;Get pointer to screen
	ex de, hl
	;; Draw a box
	ld b, M_h(ix)
	ld c, M_w(ix)
	;;Draw sprite
	ld h, M_spr_h(ix)
	ld l, M_spr_l(ix)
	call cpct_drawSpriteMasked_asm
ret

drawBackgroundScore::
	push hl
	ld de, #0x0800
 	ld c, #8
	ld a, #2
 	 	oneLoop:
 	  		ld b, #80	
		twoLoop:
			ld (hl), #0x0C
			inc hl		
			dec b		
			jr nz, twoLoop
			
			add hl, de	
			push de		
			ld de, #0xFFB0
			add hl, de	
			pop de		
			dec c		
 	  	jr nz, oneLoop

		ld c, #8
		pop hl
		push de
		ld de, #0x050
		add hl, de
		pop de
		push hl
		dec a
		cp #0
		jr nz, oneLoop
	pop hl
ret

writeScore::

	ld ix, #scoreO_data
	ld de, #0xC000
	ld hl, #score
	call drawWord

	ld ix, #scoreO_data
	ld de, #0x8000
	ld hl, #score
	call drawWord

	ld ix, #livesO_data
	ld de, #0xC000
	ld hl, #lives
	call drawWord

	ld ix, #livesO_data
	ld de, #0x8000
	ld hl, #lives
	call drawWord

ret

writeWord::
	push hl
	ld c, L_x(ix)
	ld b, L_y(ix)
	call cpct_getScreenPtr_asm
	ex de, hl

	pop hl
	ld b, L_c(ix)
	ld c, L_b(ix)
	call cpct_drawStringM0_asm
ret

;; =================================
;;	Draw background
;; =================================
drawBackground::
	ld hl, #0xC000
	push hl
	ld de, #0x0800
 	ld c, #8
	ld a, #25
 	 	oneFor:
 	  		ld b, #80			;;píxeles a lo ancho de x
		twoFor:
			ld (hl), #0xF0		;;pinto un píxel de color amarillo
			inc hl				;;paso a la siguiente posición de memoria
			dec b				;;b--
			jr nz, twoFor		;;si b es el final de la fila terminamos el bucle
			
			add hl, de			;;sumamos 800 para saltar a la línea de abajo
			push de				;;guardamos 800 porque lo necesitamos para operar a continuación
			ld de, #0xFFB0		;;Cargamos -80
			add hl, de			;;restamos -80 para volver al principio de la línea a la que hemos bajado
			pop de				;;recuperamos 800
			dec c				;;c--
 	  	jr nz, oneFor

		ld c, #8
		pop hl
		push de
		ld de, #0x050
		add hl, de
		pop de
		push hl
		dec a
		cp #0
		jr nz, oneFor
	pop hl	
ret

writeGameOver::
	ld ix, #GameO_data
	ld de, #0xC000
	ld hl, #game
	call drawWord

	ld ix, #GameO_data
	ld de, #0x8000
	ld hl, #game
	call drawWord

	ld ix, #OverO_data
	ld de, #0xC000
	ld hl, #over
	call drawWord

	ld ix, #OverO_data
	ld de, #0x8000
	ld hl, #over
	call drawWord

	ld de, #0xC000
	ld c, #0
	ld b, #184
	call cpct_getScreenPtr_asm
	call drawBackgroundScore

	ld de, #0x8000
	ld c, #0
	ld b, #184
	call cpct_getScreenPtr_asm
	call drawBackgroundScore

	ld ix, #pressO_data
	ld de, #0xC000
	ld hl, #press
	call drawWord

	ld ix, #pressO_data
	ld de, #0x8000
	ld hl, #press
	call drawWord

	ld ix, #gO_data
	ld de, #0xC000
	ld hl, #p
	call drawWord

	ld ix, #gO_data
	ld de, #0x8000
	ld hl, #p
	call drawWord

	ld ix, #toO_data
	ld de, #0xC000
	ld hl, #to
	call drawWord

	ld ix, #toO_data
	ld de, #0x8000
	ld hl, #to
	call drawWord

	ld ix, #playO_data
	ld de, #0xC000
	ld hl, #play
	call drawWord

	ld ix, #playO_data
	ld de, #0x8000
	ld hl, #play
	call drawWord

ret	