.area _DATA
.area _CODE

.include "hero.h.s"
.include "scene.h.s"
.include "obstacle.h.s"
.include "cpctelera.h.s"

;; ======================
;;	Main program entry
;; ======================
_main::
	call scene_drawFloor

	postStart:
	call hero_erase
	call obstacle_erase
	
	call hero_update
	call obstacle_update

	call hero_getPointer
	call obstacle_checkCollision
	ld (0xC000), a 					;; print if collision in the screen
	
	call hero_draw
	call obstacle_draw

	call cpct_waitVSYNC_asm
    
	jr postStart
