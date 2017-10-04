.area _DATA

.globl _sprite_palette

.area _CODE

.include "game.h.s"
.include "cpctelera.h.s"

;; =================================
;;	Settings, mode video and palette
;; =================================
settings::
	call cpct_disableFirmware_asm
	ld c, #0

	ld hl, #_sprite_palette
	ld de, #16
	call cpct_setPalette_asm

	call cpct_setVideoMode_asm

ret

;; ======================
;;	Main program entry
;; ======================
_main::
	
	call settings
	call game_start
