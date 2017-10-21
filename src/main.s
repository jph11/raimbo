.area _DATA

.globl _sprite_palette
.globl _g_tileset
.globl _g_tilemap

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
	;; Set Parameters on the stack
	ld   hl, #0x4000   ;; HL = pointer to the tilemap
	push hl              ;; Push ptilemap to the stack
	ld   hl, #0xC000  ;; HL = Pointer to video memory location where tilemap is drawn
	push hl              ;; Push pvideomem to the stack
	;; Set Paramters on registers
	ld    a, #120 ;; A = map_width
	ld    b, #0          ;; B = y tile-coordinate
	ld    c, #0          ;; C = x tile-coordinate
	ld    d, #50          ;; H = height in tiles of the tile-box
	ld    e, #40          ;; L =  width in tiles of the tile-box
	call  cpct_etm_drawTileBox2x4_asm ;; Call the function

ret

;; ======================
;;	Main program entry
;; ======================
_main::
	ld sp, #0x8000

	call settings
	call game_start
