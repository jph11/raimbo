.area _DATA

.globl _sprite_palette
.globl _g_tileset
.globl _menu_title
.globl _song_ingame

press: .db #80,#82,#69,#83,#83,#0
g: .db #71,#0
to: .db #84,#79,#0
play: .db #80,#76,#65,#89,#0
w: .db #87,#0
a: .db #65,#0
s: .db #83,#0
d: .db #68,#0
up: .db #240,#0
left: .db #242,#0
right: .db #243,#0
down: .db #241,#0
space: .db #83,#80,#65,#67,#69,#0
to2: .db #116,#111,#0
shoot: .db #115,#104,#111,#111,#116,#0

.area _CODE

.include "game.h.s"
.include "cpctelera.h.s"
.include "map.h.s"
.include "keyboard.s"
.include "macros.h.s"

.equ L_x, 0
.equ L_y, 1
.equ L_c, 2
.equ L_b, 3

.equ M_x, 0
.equ M_y, 1
.equ M_w, 2
.equ M_h, 3	
.equ M_spr_l, 4
.equ M_spr_h, 5	

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

defineMenu title, 16, 15, 50, 20, _menu_title

unavariable: .db #12

isr::
	ex af, af'
	exx
	push af
	push bc
	push de
	push hl
	push iy

	call cpct_scanKeyboard_if_asm

	ld a, (unavariable)
	dec a
	ld (unavariable), a
	jr nz, return

		call cpct_akp_musicPlay_asm
		ld a, #12
		ld (unavariable), a

	return:
	pop iy
	pop hl
	pop de
	pop bc
	pop af
	exx
	ex af, af'
	
ret


;; =================================
;;	Settings, mode video and palette
;; =================================
settings::
	call cpct_disableFirmware_asm

	ld c, #0
	call cpct_setVideoMode_asm

	ld hl, #_sprite_palette
	ld de, #16
	call cpct_setPalette_asm

	;; MAP
	ld hl, #_g_tileset
	call cpct_etm_setTileset2x4_asm

	ld de, #0xC000
	ld a, #0x00
	ld bc, #0x4000
	call cpct_memset_asm

	ld de, #0x8000
	ld a, #0x00
	ld bc, #0x4000
	call cpct_memset_asm

	ld de, #_song_ingame
	call cpct_akp_musicInit_asm

	ld hl, #isr
	call cpct_setInterruptHandler_asm

ret

;; =================================
;;	Menú principal
;; =================================
drawMenu::
	call drawBackground
	ld ix, #title_data
	call drawSprite
	call drawPressToPlay
	call drawWASD
	call drawArrows
	call drawSpace

	loop:
		;;Scan the whole keyboard
		;;call cpct_scanKeyboard_asm ;;keyboard.s

		;;Check for key 'Enter' being pressed
		ld hl, #Key_G
		call cpct_isKeyPressed_asm	;;Check if Key_Enter is presed
		cp #0						;;Check A == 0
		jr z, loop					;;Jump if A==0 (space_not_pressed)

		;;Enter is pressed
		ret

drawPressToPlay:
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

drawWASD:
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

drawArrows:
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

drawSpace:
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

drawWord:
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

drawSprite:
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

;; =================================
;;	Draw background
;; =================================
drawBackground:
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

;; ======================
;;	Main program entry
;; ======================
_main::
	ld sp, #0x8000
	
	call settings
	call drawMenu

	ad_infinitum:
	call game_start
	jr ad_infinitum
