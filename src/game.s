.area _DATA
.area _CODE

.include "hero.h.s"
.include "scene.h.s"
.include "obstacle.h.s"
.include "enemy.h.s"
.include "engine.h.s"
.include "cpctelera.h.s"
.include "keyboard.s"
.include "map.h.s"

;;===========================================
;;===========================================
;;PUBLIC FUNTIONS
;;===========================================
;;===========================================

;; ======================
;;	Start game
;; ======================
game_start::
    call game_init
	call game_run
    ret

;;===========================================
;;===========================================
;;PRIVATE FUNTIONS
;;===========================================
;;===========================================

;; ======================
;;	Init values game
;; ======================
game_init:
    call hero_init
    call obstacle_init
    ;;call scene_drawFloor

    ret

;; ======================
;;	Run the game
;; ======================
game_run:
	call engine_eraseAll
	call engine_updateAll

	call hero_getPointerLife
	ld a, (hl)
	cp #0
	jr z, gameOver

	;;call hero_getPointer
	;;call obstacle_checkCollision

    call engine_drawAll

	call cpct_waitVSYNC_asm
	call map_switchBuffers
	
    jr game_run

;; ======================
;;	Checks User Input and Reacts
;;	DESTROYS:
;; ======================
gameOver:
		;;Scan the whole keyboard
		call cpct_scanKeyboard_asm ;;keyboard.s

		;;Check for key 'Space' being pressed
		ld hl, #Key_P
		call cpct_isKeyPressed_asm	;;Check if Key_Space is presed
		cp #0						;;Check A == 0
		jr z, gameOver		;;Jump if A==0 (space_not_pressed)

		;;P is pressed
		ld a, #03
		call hero_getPointerLife
		ld (hl), a
		call game_start