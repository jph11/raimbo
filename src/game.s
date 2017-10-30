.area _DATA

.globl _game_flower_100

.area _CODE

.include "hero.h.s"
.include "engine.h.s"
.include "entity.h.s"
.include "macros.h.s"
.include "cpctelera.h.s"
.include "keyboard.s"
.include "map.h.s"

.equ S_x, 0
.equ S_y, 1
.equ S_w, 2
.equ S_h, 3	
.equ S_spr_l, 4
.equ S_spr_h, 5

defineScoreLife life, 20, 185, 8, 15, _game_flower_100

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
	call map_draw
	call game_putScore
	call map_drawScore
ret

game_putScore::
	ld de, #0xC000
	ld c, #0
	ld b, #184
	call cpct_getScreenPtr_asm
	call drawScore

	ld de, #0x8000
	ld c, #0
	ld b, #184
	call cpct_getScreenPtr_asm
	call drawScore

	ld ix, #life_data
	ld de, #0xC000
	ld c, S_x(ix)
	ld b, S_y(ix)
	call cpct_getScreenPtr_asm
	ex de, hl
	call drawLife

	ld de, #0x8000
	ld c, S_x(ix)
	ld b, S_y(ix)
	call cpct_getScreenPtr_asm
	ex de, hl
	call drawLife

ret

drawScore:
	push hl
	ld de, #0x0800
 	ld c, #8
	ld a, #2
 	 	oneFor:
 	  		ld b, #80	
		twoFor:
			ld (hl), #0x03
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

		ld c, #8
		pop hl
		push de
		ld de, #0x050
		add hl, de
		pop de
		push hl
		dec a
		cp #0
		jr nz, oneFor
	pop hl
ret


drawLife::
	;; Draw a box
	ld b, S_h(ix)
	ld c, S_w(ix)
	;;Draw sprite
	ld h, S_spr_h(ix)
	ld l, S_spr_l(ix)
	call cpct_drawSpriteMasked_asm
ret

game_getPointerLife::
	ld ix, #life_data
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

    call engine_drawAll

	call cpct_waitVSYNC_asm
	call map_switchBuffers
	
    jr game_run

;; ======================
;;	Checks User Input and Reacts
;;	DESTROYS:
;; ======================
gameOver:
		;; Scan the whole keyboard
		;;call cpct_scanKeyboard_asm 		;;keyboard.s

		;; Check for key 'Space' being pressed
		ld hl, #Key_P
		call cpct_isKeyPressed_asm		;;Check if Key_Space is presed
		cp #0							;;Check A == 0
		jr z, gameOver					;;Jump if A==0 (space_not_pressed)

		;;P is pressed
		ld a, #03
		call hero_getPointerLife
		ld (hl), a
		call game_start