.area _DATA
.area _CODE

.include "hero.h.s"
.globl cpct_waitVSYNC_asm

;; ======================
;; Draw
;; Parametrers hl (init position), 
;; ======================
drawFloor:
 
 
 ld de, #0x0800
 ld c, #16
 oneFor:
  ld b, #80
  twoFor:
   ld (hl), #0xF0
   inc hl
   dec b
   jr nz, twoFor
  
  add hl, de
  push de
  ld de, #0xFFB0
  add hl, de
  pop de
  dec c
  jr nz, oneFor
 ret


;; ======================
;;	Main program entry
;; ======================
_main::

	ld hl, #0xC370
	call drawFloor


	postStart:

	ld a, #0x00
	call hero_erase

	call hero_update

	ld a, #0xFF
	call hero_draw

	call cpct_waitVSYNC_asm

	;; posición actual a la que estamos ejecutando
	jr postStart
