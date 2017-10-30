.area _DATA

.globl _sprite_palette
.globl _g_tileset
.globl _sprite_bala
.globl ptilemapA
.globl _menu_PRESS
.globl _menu_G
.globl _menu_TO_PLAY
.globl _song_ingame
.area _CODE

.include "game.h.s"
.include "cpctelera.h.s"
.include "map.h.s"
.include "keyboard.s"

.macro defineMenu name, x, y, w, h, spr
	name'_data::
		name'_x: 	  	.db x
		name'_y:	    .db y  
		name'_w:	    .db w
		name'_h:	    .db h
		name'_sprite:  	.dw spr
.endm

defineMenu m1, 31, 50, 19, 10, _menu_PRESS
defineMenu m2, 36, 88, 8, 12, _menu_G
defineMenu m3, 27, 120, 26, 10, _menu_TO_PLAY

.equ M_x, 0
.equ M_y, 1
.equ M_w, 2
.equ M_h, 3	
.equ M_spr_l, 4
.equ M_spr_h, 5

unavariable: .db #12

isr::

	;;ld l, #16
	;;ld a, (unavariable)
	;;ld h, a
	;;call cpct_setPALColour_asm

	;;ld a, (unavariable)
	;;inc a
	;;cp #0x16
	;;jr nz, continue

		;;ld a, #0x10

	;;continue:
	;;ld (unavariable), a

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

		ld ix, #m1_data
		call drawSprite
		ld ix, #m2_data
		call drawSprite
		ld ix, #m3_data
		call drawSprite
		
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

;; =================================
;;	Draw Sprite
;; =================================
drawSprite:
	ld de, #0xC000			;;Video memory

	ld c, M_x(ix)			;;\ C=entity_x
	ld b, M_y(ix)			;;\ B=entity_y

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
	call game_start
