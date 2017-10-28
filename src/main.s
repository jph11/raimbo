.area _DATA

.globl _sprite_palette
.globl _g_tileset
.globl _g_tilemap
.globl _sprite_bala

.area _CODE

.include "game.h.s"
.include "cpctelera.h.s"
.include "map.h.s"

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

	;; Trabajo provisional hardware_scrolling
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

	call map_draw

ret

;; ======================
;;	Main program entry
;; ======================
_main::
	ld sp, #0x8000

	call settings
	call game_start
