.area _DATA

.globl _sprite_palette
.globl _g_tileset
.globl _song_ingame
.globl _menu_title

.area _CODE

.include "game.h.s"
.include "cpctelera.h.s"
.include "map.h.s"
.include "keyboard.s"
.include "macros.h.s"
.include "drawer.h.s"

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
	call writePressToPlay
	call writeWASD
	call writeArrows
	call writeSpace

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
