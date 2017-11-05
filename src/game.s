.area _DATA
.globl _game_flower_100
.globl _g_tilemap1
.area _CODE

.include "hero.h.s"
.include "engine.h.s"
.include "entity.h.s"
.include "macros.h.s"
.include "cpctelera.h.s"
.include "keyboard.s"
.include "map.h.s"
.include "bullets.h.s"
.include "drawer.h.s"

.equ S_x, 0
.equ S_y, 1
.equ S_w, 2
.equ S_h, 3	
.equ S_spr_l, 4
.equ S_spr_h, 5
youWon::
	.db #0x00
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

	call writeScore

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

	ld a, (youWon)
	cp #1
	jp z, llamada_a_youwin

    call engine_drawAll

	call cpct_waitVSYNC_asm
	call map_switchBuffers
	
    jr game_run

llamada_a_gameover:
	call gameOver
	ret
llamada_a_youwin::
	ld a, #0
	ld (youWon), a
	call game_youWin
ret


game_youWin::

	call writeYouWin
	call bullets_deleteAllBullets
	gWin:
		ld hl, #Key_R
		call cpct_isKeyPressed_asm		;;Check if Key_Space is presed
		cp #0								;;Check A == 0
		jr z, gWin							;;Jump if A==0 (space_not_pressed)
		

		;;P is pressed
		;; Fórmula: Número de enemigos * Tamaño en bytes de un enemigo + Número de mapas * tamaño en bytes de un mapa + Número de enemigos
		;; Fórmula: 
		ld bc, #12 * 21  + 6 * 8 + 12
		ld hl, #M1_aux
		ld de, #M1
		call reInitilize

		
		;; Fórmula: Número de enemigos * Tamaño en bytes de un enemigo + Número de mapas * tamaño en bytes de un mapa + Número de enemigos
		;; Fórmula: 
		ld bc, #7 * 21  + 3 * 8 + 7
		ld hl, #M7_aux
		ld de, #M7
		call reInitilize
ret


reInitilize:

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

;; ======================
;;	Checks User Input and Reacts
;;	DESTROYS:
;; ======================
gameOver:
		call writeGameOver
		call bullets_deleteAllBullets
		;; Scan the whole keyboard
		;;call cpct_scanKeyboard_asm 		;;keyboard.s

		gOver:
		ld hl, #Key_R
		call cpct_isKeyPressed_asm		;;Check if Key_Space is presed
		cp #0								;;Check A == 0
		jr z, gOver							;;Jump if A==0 (space_not_pressed)

		;;P is pressed
		;; Fórmula: Número de enemigos * Tamaño en bytes de un enemigo + Número de mapas * tamaño en bytes de un mapa + Número de enemigos
		;; Fórmula: 
		ld bc, #12 * 21  + 6 * 8 + 12
		ld hl, #M1_aux
		ld de, #M1
		call reInitilize

		ld bc, #7 * 21  + 3 * 8 + 7
		ld hl, #M7_aux
		ld de, #M7
		call reInitilize
ret
