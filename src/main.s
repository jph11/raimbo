.area _DATA
.area _CODE

.include "hero.h.s"
.include "scene.h.s"
.include "bullets.h.s"
.include "obstacle.h.s"
.include "cpctelera.h.s"

;; ======================
;;	Main program entry
;; ======================
_main::
	call scene_drawFloor

	postStart:
	call bullets_erase
	call hero_erase
	call obstacle_erase

	
	call bullets_update
	call hero_update
	call obstacle_update

	call hero_getPointer
	call obstacle_checkCollision

	call bullets_draw
	call hero_draw
	call obstacle_draw

	call cpct_waitVSYNC_asm
    
	jr postStart
