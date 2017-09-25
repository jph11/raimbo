.area _DATA
floor_x: .db #0
floor_y: .db #88

.area _CODE

.include "hero.h.s"
.include "scene.h.s"
.globl cpct_waitVSYNC_asm




;; ======================
;;	Main program entry
;; ======================
_main::

	
	call scene_drawFloor


	postStart:

	call hero_erase

	call hero_update

	call hero_draw

	call cpct_waitVSYNC_asm
    
	jr postStart
