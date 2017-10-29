.area _DATA

.globl _sprite_palette
.globl _g_tileset
.globl _g_tilemap
.globl _sprite_bala

.area _CODE

.include "game.h.s"
.include "cpctelera.h.s"
.include "map.h.s"
.include "keyboard.s"

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

ret

;; =================================
;;	Menú principal
;; =================================
drawMenu::

    ld hl, #0xC000
	push hl
	ld de, #0x0800
 	ld c, #8
	ld a, #25
 	 	oneFor:
 	  		ld b, #80			;;píxeles a lo ancho de x
		twoFor:
			ld (hl), #0x68		;;pinto un píxel de color amarillo
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

		;;Scan the whole keyboard
		call cpct_scanKeyboard_asm ;;keyboard.s

		;;Check for key 'Enter' being pressed
		ld hl, #Key_P
		call cpct_isKeyPressed_asm	;;Check if Key_Enter is presed
		cp #0						;;Check A == 0
		jr z, drawMenu				;;Jump if A==0 (space_not_pressed)

		;;Enter is pressed
		ret


;; ======================
;;	Main program entry
;; ======================
_main::
	ld sp, #0x8000
	call settings
	call drawMenu
	call map_draw
	call game_start
