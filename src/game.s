.area _DATA

.globl _game_flower_100
.globl M1_aux
.globl M1
.globl nEnemyA
.globl ptilemapA
.globl puertaIzquierdaA
.globl puertaDerechaA
.globl arrayEnemyA
.globl _g_tilemap1
.globl M1_nEnemyMap
.globl M2
.globl M1_arrayEnemy
.globl maxYA
.globl M1_maxY

score: .db #83,#67,#79,#82,#69,#0
lives: .db #76,#73,#86,#69,#83,#0
game: .db #71,#65,#77,#69,#0
over: .db #79,#86,#69,#82,#0
press: .db #80,#82,#69,#83,#83,#0
p: .db #71,#0
to: .db #84,#79,#0
play: .db #80,#76,#65,#89,#0

.area _CODE

.include "hero.h.s"
.include "engine.h.s"
.include "entity.h.s"
.include "macros.h.s"
.include "cpctelera.h.s"
.include "keyboard.s"
.include "map.h.s"

;==================================
defineWord pressO, 12, 189, 2, 13

defineWord gO, 35, 189, 2, 9

defineWord toO, 42, 189, 2, 13

defineWord playO, 52, 189, 2, 13
;==================================
defineWord scoreO, 40, 189, 2, 13

defineWord livesO, 4, 189, 2, 13
;==================================
defineWord GameO, 22, 75, 1, 13

defineWord OverO, 42, 75, 1, 13

.equ O_x, 0
.equ O_y, 1
.equ O_c, 2
.equ O_b, 3

.equ S_x, 0
.equ S_y, 1
.equ S_w, 2
.equ S_h, 3	
.equ S_spr_l, 4
.equ S_spr_h, 5

defineScoreLife life, 28, 185, 8, 15, _game_flower_100

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
	call drawBackgroundScore

	ld de, #0x8000
	ld c, #0
	ld b, #184
	call cpct_getScreenPtr_asm
	call drawBackgroundScore

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

	call game_writeScore

ret

drawBackgroundScore:
	push hl
	ld de, #0x0800
 	ld c, #8
	ld a, #2
 	 	oneFor:
 	  		ld b, #80	
		twoFor:
			ld (hl), #0x0C
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

game_writeScore:

	ld ix, #scoreO_data
	ld de, #0xC000
	ld hl, #score
	call game_writeWord

	ld ix, #scoreO_data
	ld de, #0x8000
	ld hl, #score
	call game_writeWord

	ld ix, #livesO_data
	ld de, #0xC000
	ld hl, #lives
	call game_writeWord

	ld ix, #livesO_data
	ld de, #0x8000
	ld hl, #lives
	call game_writeWord

ret

game_writeWord:
	push hl
	ld c, O_x(ix)
	ld b, O_y(ix)
	call cpct_getScreenPtr_asm
	ex de, hl

	pop hl
	ld b, O_c(ix)
	ld c, O_b(ix)
	call cpct_drawStringM0_asm
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
	jp z, llamada_a_gameover

    call engine_drawAll

	call cpct_waitVSYNC_asm
	call map_switchBuffers
	
    jr game_run

game_writeGameOver:
	ld ix, #GameO_data
	ld de, #0xC000
	ld hl, #game
	call game_writeWord

	ld ix, #GameO_data
	ld de, #0x8000
	ld hl, #game
	call game_writeWord

	ld ix, #OverO_data
	ld de, #0xC000
	ld hl, #over
	call game_writeWord

	ld ix, #OverO_data
	ld de, #0x8000
	ld hl, #over
	call game_writeWord

	ld de, #0xC000
	ld c, #0
	ld b, #184
	call cpct_getScreenPtr_asm
	call drawBackgroundScore

	ld de, #0x8000
	ld c, #0
	ld b, #184
	call cpct_getScreenPtr_asm
	call drawBackgroundScore

	ld ix, #pressO_data
	ld de, #0xC000
	ld hl, #press
	call game_writeWord

	ld ix, #pressO_data
	ld de, #0x8000
	ld hl, #press
	call game_writeWord

	ld ix, #gO_data
	ld de, #0xC000
	ld hl, #p
	call game_writeWord

	ld ix, #gO_data
	ld de, #0x8000
	ld hl, #p
	call game_writeWord

	ld ix, #toO_data
	ld de, #0xC000
	ld hl, #to
	call game_writeWord

	ld ix, #toO_data
	ld de, #0x8000
	ld hl, #to
	call game_writeWord

	ld ix, #playO_data
	ld de, #0xC000
	ld hl, #play
	call game_writeWord

	ld ix, #playO_data
	ld de, #0x8000
	ld hl, #play
	call game_writeWord

ret	

llamada_a_gameover:
	call gameOver
ret

;; ======================
;;	Checks User Input and Reacts
;;	DESTROYS:
;; ======================
gameOver:
		call game_writeGameOver
		;; Scan the whole keyboard
		;;call cpct_scanKeyboard_asm 		;;keyboard.s

		gOver:
		ld hl, #Key_P
		call cpct_isKeyPressed_asm		;;Check if Key_Space is presed
		cp #0								;;Check A == 0
		jr z, gOver							;;Jump if A==0 (space_not_pressed)

		;;P is pressed
		;; Fórmula: Número de enemigos * Tamaño en bytes de un enemigo + Número de mapas * tamaño en bytes de un mapa + Número de enemigos
		;; Fórmula: 
		ld bc, #12 * 19 + 6 * 8 + 12
		ld hl, #M1_aux
		ld de, #M1
		ldir

		;; Resetear score
		call map_resetScore

		ld ix, #maxYA
		ld de, #M1_maxY


		ld 0(ix), e
		ld 1(ix), d

		;; Resear punteros map
		ld ix, #nEnemyA
		ld de, #M1_nEnemyMap

		ld 0(ix), e
		ld 1(ix), d

		ld ix, #ptilemapA
		ld de, #_g_tilemap1

		ld 0(ix), e
		ld 1(ix), d

		ld ix, #puertaIzquierdaA
		ld 0(ix), #0xFF
		ld 1(ix), #0xFF

		ld ix, #puertaDerechaA
		ld de, #M2

		ld 0(ix), e
		ld 1(ix), d

		ld ix, #arrayEnemyA
		ld de, #M1_arrayEnemy

		ld 0(ix), e
		ld 1(ix), d


		ld a, #04
		call hero_getPointerLife
		ld (hl), a
ret
