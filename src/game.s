.area _DATA

hero_alive: .db #01

.area _CODE

.include "hero.h.s"
.include "scene.h.s"
.include "obstacle.h.s"
.include "enemy.h.s"
.include "engine.h.s"
.include "cpctelera.h.s"
.include "keyboard.s"

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

;; ======================
;;	Pointer to Hero Alive
;; ======================
game_PointerHeroAlive::
    ld hl, #hero_alive
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
    call enemy_init
    call obstacle_init
    call scene_drawFloor

    ret

;; ======================
;;	Run the game
;; ======================
game_run:
	call engine_eraseAll
	call engine_updateAll

	ld a, (hero_alive)
	cp #0
	jr z, gameOver

	;;call hero_getPointer
	;;call obstacle_checkCollision

    call engine_drawAll

	call cpct_waitVSYNC_asm
	
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

		;;Space is pressed
		ld a, #01
		ld (hero_alive), a
		call game_start