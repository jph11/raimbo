.area _DATA
.globl _sprite_ball_bike_left
.globl _sprite_bullet_shooter_left
.globl _sprite_hooded_left
.globl _sprite_ghost_forward
.globl _sprite_ball_left
.globl _sprite_bullet_shooter_forward
.globl _sprite_spider_forward
.globl _sprite_spider_back
.globl _g_tilemap1
.globl _g_tilemap2
.globl _g_tilemap3
.area _CODE

.include "drawer.h.s"
.include "enemy.h.s"
.include "bullets.h.s"
.include "cpctelera.h.s"
.include "macros.h.s"
.include "game.h.s"

;;========================
;;========================
;; MAP GLOBAL POINTERS
;;========================
;;========================
puntero_video:: .dw #0x8000
noPattern:
score_char: .db #48, #48, #48, #0
score: .db #0

.equ Enemy_x, 0
.equ Enemy_y, 1
.equ Enemy_w, 2
.equ Enemy_h, 3
.equ Ent_spr_l, 4
.equ Ent_spr_h, 5
.equ EnemyLives, 6
.equ EnemyTemp, 7
.equ EnemyLastMovement, 8
.equ EnemyUX, 9
.equ EnemyPUX, 10
.equ EnemyUY, 11
.equ EnemyPUY, 12
.equ EnemyPatternL, 14
.equ EnemyPatternH, 15
.equ EnemyPatternAntiguoL, 16
.equ EnemyPatternAntiguoH, 17
.equ EnemyPatternContador, 18

;; ------------------------
;; Equivalencias del score que nada tienen que ver con el enemy
;; ------------------------
.equ score_digito_menos_significativo, 2
.equ score_segundo_digito_menos_significativo, 1
.equ score_tercer_digito_menos_significativo, 0

NextEnemy:
	.dw #21
nEnemyA::
	.dw #M1_nEnemyMap
ptilemapA::
	.dw #_g_tilemap1 ;Cambiar al mapa correspondiente
puertaIzquierdaA::
	.dw 0xFFFF
puertaDerechaA::
	.dw M2
arrayEnemyA::
	.dw M1_arrayEnemy
maxYA::
	.dw M1_maxY

;; ========================
;; ========================

;;========================
;;========================
;; MAPS DATA
; 	Map:
; 		name, ptilemap, puertaIzquierda, puertaDerecha
; 	Enemy:
;		x,  y,  w,  h, sprite, lives,  temp, lastmovement, type 
;;========================
;;========================

M1::
  defineMap M1 #_g_tilemap1, -1, M2, 1, 50
  defineEnemy 65, 120, 7, 25, _sprite_hooded_left, 7, 0, 0, 65, 65, 20, 20, 2, noPattern, noPattern, 0, 0, 0
  defineEnemyLastOne 50, 50, 7, 25, _sprite_bullet_shooter_left, 0xFF, 0, 0, 50, 50, 50, 50, 3, balinCabreado, balinCabreado, 0, 0, 0

M2::
  defineMap M2 #_g_tilemap3, M1, M3, 1, 3
  defineEnemyLastOne 71, 160, 5, 10, _sprite_spider_back, 4, 0, 0, 8, 8, 20, 20, 3, spiderBottom, spiderBottom, 0, 0, 0	

M3:
  defineMap M3 #_g_tilemap2, M2, M4, 1, 3
  defineEnemyLastOne 65, 140, 11, 22, _sprite_ball_left, 20, 0, 0, 65, 65, 140, 140, 3, bolin, bolin, 0, 0, 0

M4:
  defineMap M4 #_g_tilemap2, M3, M5, 3, 3
  defineEnemy 10, 20, 7, 25, _sprite_ghost_forward, 8, 0, 0, 10, 10, 20, 20, 2, noPattern, noPattern, 0, 0, 0
  defineEnemy 54, 124, 7, 25, _sprite_ghost_forward, 8, 0, 0, 54, 54, 124, 124, 2, noPattern, noPattern, 0, 0, 0
  defineEnemyLastOne 70, 120, 7, 25, _sprite_ghost_forward, 8, 0, 0, 70, 70, 120, 120, 2, noPattern, noPattern, 0, 0, 0

M5:
  defineMap M5 #_g_tilemap3, M4, M6, 2, 3
  defineEnemy 60, 30, 11, 30, _sprite_ball_bike_left, 7, 0, 0, 60, 60, 30, 30, 3, saltarin, saltarin, 0, 0, 0
  defineEnemyLastOne 50, 120, 11, 30, _sprite_ball_bike_left, 7, 0, 0, 50, 50, 120, 120, 3, saltarin, saltarin, 0, 0, 0

M6:
  defineMap M6 #_g_tilemap3, M5, M7, 2, 3
  defineEnemy 50, 50, 11, 30, _sprite_ball_bike_left, 10, 0, 0, 50, 50, 50, 50, 3, saltarin, saltarin, 0, 0, 0
  defineEnemy 50, 120, 7, 25, _sprite_bullet_shooter_left, 0xFF, 0, 0, 50, 50, 50, 50, 3, balin, balin, 0, 0, 0
  defineEnemyLastOne 30, 120, 7, 25, _sprite_ghost_forward, 8, 0, 0, 70, 70, 120, 120, 2, noPattern, noPattern, 0, 0, 0

M7::
  defineMap M7 #_g_tilemap3, M6, M8, 2, 3
  defineEnemy 5, 20, 7, 25, _sprite_ghost_forward, 10, 0, 0, 5, 5, 20, 20, 2, noPattern, noPattern, 0, 0, 0
  defineEnemy 60, 140, 7, 25, _sprite_ghost_forward, 10, 0, 0, 60, 60, 140, 140, 2, noPattern, noPattern, 0, 0, 0
  defineEnemyLastOne 35, 80, 7, 25, _sprite_bullet_shooter_forward, 0xFF, 0, 0, 32, 32, 80, 80, 3, balinCentro, balinCentro, 0, 0, 0

M8:
  defineMap M8 #_g_tilemap3, M7, M9, 1, 3
  defineEnemy 71, 20, 5, 10, _sprite_spider_forward, 4, 0, 0, 71, 71, 20, 20, 3, spider, spider, 0, 0, 0
  defineEnemyLastOne 35, 80, 7, 25, _sprite_bullet_shooter_forward, 0xFF, 0, 0, 32, 32, 80, 80, 3, balinCentro, balinCentro, 0, 0, 0

M9:
  defineMap M9 #_g_tilemap2, M8, -1, 2, 3
  defineEnemy 71, 160, 5, 10, _sprite_spider_back, 4, 0, 0, 71, 71, 160, 160, 3, spiderBottom, spiderBottom, 0, 0, 0
  defineEnemyLastOne 71, 20, 5, 10, _sprite_spider_forward, 4, 0, 0, 71, 71, 20, 20, 3, spider, spider, 0, 0, 0



;;========================
;;========================

;;========================
;;========================
;; MAPS DATA AUXILIAR. Estos serán los que se guarden en ROM y los valores a los que se reiniciará en Game over
; 	Map:
; 		name, ptilemap, puertaIzquierda, puertaDerecha
; 	Enemy:
;		x,  y,  w,  h, sprite, lives,  temp, lastmovement, type 
;;========================
;;========================

M1_aux::
  defineMap M1_aux #_g_tilemap1, -1, M2, 1, 50
  defineEnemy 65, 120, 7, 25, _sprite_hooded_left, 7, 0, 0, 65, 65, 20, 20, 2, noPattern, noPattern, 0, 0, 0
  defineEnemyLastOne 50, 50, 7, 25, _sprite_bullet_shooter_left, 0xFF, 0, 0, 50, 50, 50, 50, 3, balinCabreado, balinCabreado, 0, 0, 0

M2_aux::
  defineMap M2_aux #_g_tilemap3, M1, M3, 1, 3
  defineEnemyLastOne 71, 160, 5, 10, _sprite_spider_back, 4, 0, 0, 8, 8, 20, 20, 3, spiderBottom, spiderBottom, 0, 0, 0	

M3_aux:
  defineMap M3_aux #_g_tilemap2, M2, M4, 1, 3
  defineEnemyLastOne 65, 140, 11, 22, _sprite_ball_left, 20, 0, 0, 65, 65, 140, 140, 3, bolin, bolin, 0, 0, 0

M4_aux:
  defineMap M4_aux #_g_tilemap2, M3, M5, 3, 3
  defineEnemy 10, 20, 7, 25, _sprite_ghost_forward, 8, 0, 0, 10, 10, 20, 20, 2, noPattern, noPattern, 0, 0, 0
  defineEnemy 54, 124, 7, 25, _sprite_ghost_forward, 8, 0, 0, 54, 54, 124, 124, 2, noPattern, noPattern, 0, 0, 0
  defineEnemyLastOne 70, 120, 7, 25, _sprite_ghost_forward, 8, 0, 0, 70, 70, 120, 120, 2, noPattern, noPattern, 0, 0, 0

M5_aux:
  defineMap M5_aux #_g_tilemap3, M4, M6, 2, 3
  defineEnemy 60, 30, 11, 30, _sprite_ball_bike_left, 7, 0, 0, 60, 60, 30, 30, 3, saltarin, saltarin, 0, 0, 0
  defineEnemyLastOne 50, 120, 11, 30, _sprite_ball_bike_left, 7, 0, 0, 50, 50, 120, 120, 3, saltarin, saltarin, 0, 0, 0

M6_aux:
  defineMap M6_aux #_g_tilemap3, M5, M7, 2, 3
  defineEnemy 50, 50, 11, 30, _sprite_ball_bike_left, 10, 0, 0, 50, 50, 50, 50, 3, saltarin, saltarin, 0, 0, 0
  defineEnemy 50, 120, 7, 25, _sprite_bullet_shooter_left, 0xFF, 0, 0, 50, 50, 50, 50, 3, balin, balin, 0, 0, 0
  defineEnemyLastOne 30, 120, 7, 25, _sprite_ghost_forward, 8, 0, 0, 70, 70, 120, 120, 2, noPattern, noPattern, 0, 0, 0

M7_aux::
  defineMap M7_aux #_g_tilemap3, M6, M8, 2, 3
  defineEnemy 5, 20, 7, 25, _sprite_ghost_forward, 10, 0, 0, 5, 5, 20, 20, 2, noPattern, noPattern, 0, 0, 0
  defineEnemy 60, 140, 7, 25, _sprite_ghost_forward, 10, 0, 0, 60, 60, 140, 140, 2, noPattern, noPattern, 0, 0, 0
  defineEnemyLastOne 35, 80, 7, 25, _sprite_bullet_shooter_forward, 0xFF, 0, 0, 32, 32, 80, 80, 3, balinCentro, balinCentro, 0, 0, 0

M8_aux:
  defineMap M8_aux #_g_tilemap3, M7, M9, 1, 3
  defineEnemy 71, 20, 5, 10, _sprite_spider_forward, 4, 0, 0, 71, 71, 20, 20, 3, spider, spider, 0, 0, 0
  defineEnemyLastOne 35, 80, 7, 25, _sprite_bullet_shooter_forward, 0xFF, 0, 0, 32, 32, 80, 80, 3, balinCentro, balinCentro, 0, 0, 0

M9_aux:
  defineMap M9_aux #_g_tilemap2, M8, -1, 2, 3
  defineEnemy 71, 160, 5, 10, _sprite_spider_back, 4, 0, 0, 71, 71, 160, 160, 3, spiderBottom, spiderBottom, 0, 0, 0
  defineEnemyLastOne 71, 20, 5, 10, _sprite_spider_forward, 4, 0, 0, 71, 71, 20, 20, 3, spider, spider, 0, 0, 0

;;========================
;;========================

;;========================
;;========================
map_updateAllEnemiesAndBullets::
	call bullets_updateBullets
	ld ix, (arrayEnemyA)
	loopMapUpdate:
	ld a, Enemy_x(ix)
	cp #0x81
	 	ret z
	call enemy_update
	ld hl, #arrayEnemyA
	push ix
	call bullet_checkCollision
	pop ix
	ld de, (NextEnemy)
	add ix, de
	jr loopMapUpdate

;;========================
;;========================
;
;;========================
;;========================
map_drawAllEnemiesAndBullets::
	ld ix, (arrayEnemyA)
	loopMapDraw:
	ld a, Enemy_x(ix)
	cp #0x81
	 	ret z
	call enemy_draw
	call bullets_draw
	ld de, (NextEnemy)
	add ix, de
	jr loopMapDraw

;;========================
;;========================
;
;;========================
;;========================
map_eraseAllEnemiesAndBullets::
	ld ix, (arrayEnemyA)
	loopMapErase:
	ld a, Enemy_x(ix)
	cp #0x81
	 	ret z
	call enemy_erase
	call bullets_erase
	ld de, (NextEnemy)
	add ix, de
	jr loopMapErase

;;========================
;;========================
;
;;========================
;;========================
map_switchBuffers::

	modifier = .+1
	ld l, #0x20
	call cpct_setVideoMemoryPage_asm
	ld hl, #modifier
	ld a, #0x10
	xor (hl)
	ld (modifier), a

	ld hl, #puntero_video+1
	ld a, #0x40
	xor (hl)
	ld (puntero_video+1), a
ret

;;========================
;;========================
;
;;========================
;;========================
map_draw::

	;; Set Parameters on the stack
	ld   hl, (ptilemapA)   		;; HL = pointer to the tilemap
	push hl              		;; Push ptilemap to the stack
	ld   hl, #0xC000  			;; HL = Pointer to video memory location where tilemap is drawn
	push hl              		;; Push pvideomem to the stack
	;; Set Paramters on registers
	ld    a, #40 				;; A = map_width
	ld    b, #0          		;; B = y tile-coordinate
	ld    c, #0          		;; C = x tile-coordinate
	ld    d, #46          		;; H = height in tiles of the tile-box
	ld    e, #40          		;; L =  width in tiles of the tile-box
	call  cpct_etm_drawTileBox2x4_asm ;; Call the function


	;; Set Parameters on the stack
	ld   hl, (ptilemapA)   		;; HL = pointer to the tilemap
	push hl              		;; Push ptilemap to the stack
	ld   hl, #0x8000  			;; HL = Pointer to video memory location where tilemap is drawn
	push hl              		;; Push pvideomem to the stack
	;; Set Paramters on registers
	ld    a, #40 				;; A = map_width
	ld    b, #0          		;; B = y tile-coordinate
	ld    c, #0          		;; C = x tile-coordinate
	ld    d, #46          		;; H = height in tiles of the tile-box
	ld    e, #40          		;; L =  width in tiles of the tile-box
	call  cpct_etm_drawTileBox2x4_asm ;; Call the function

	;call game_putScore
	;call map_drawScore
ret

map_drawScore::

	push af
	push bc
	push de
	push hl

	ld de, #0xC000
	ld c, #64
	ld b, #189
	call cpct_getScreenPtr_asm

	ex de, hl

	ld hl, #score_char
	ld b, #2
	ld c, #15
	call cpct_drawStringM0_asm

	ld de, #0x8000
	ld c, #64
	ld b, #189
	call cpct_getScreenPtr_asm

	ex de, hl

	ld hl, #score_char
	ld b, #2
	ld c, #15
	call cpct_drawStringM0_asm

	pop hl
	pop de
	pop bc
	pop af
ret

map_addScore::
	
	push ix

	;; Actualización del score numérico para llevar control
	ld ix, #score
	inc (ix)

	ld ix, #score_char
	ld a, score_digito_menos_significativo(ix)

	;; if (digito_menos_significativo == 9 == 57 EN ASCII)
	;; --------------------------------------------------
	cp #57
	jr nz, no_modificar_segundo_digito_ascore
	
	;; then digito_menos_significativo = 0 = 48 EN ASCII
	;; --------------------------------------------------
	ld score_digito_menos_significativo(ix), #48

	;; and segundo_digito_menos_significativo += 1
	;; --------------------------------------------------
	inc score_segundo_digito_menos_significativo(ix)
	jr add_score_fin

	;; else
	no_modificar_segundo_digito_ascore:
	inc score_digito_menos_significativo(ix)

	add_score_fin:
	call map_drawScore

	pop ix
ret

map_substractScore::

	push ix

	;; if (score == 0) then end
	;; -------------------------
	ld ix, #score
	ld a, (ix)
	cp #0
	jr z, substract_score_fin

	;; Actualización del score numérico para llevar control
	dec (ix)

	ld ix, #score_char
	ld a, score_digito_menos_significativo(ix)

	;; if (digito_menos_significativo == 0 == 48 EN ASCII)
	;; --------------------------------------------------
	cp #48
	jr nz, no_modificar_segundo_digito_sscore
	
	;; then digito_menos_significativo = 9 = 57 EN ASCII
	;; --------------------------------------------------
	ld score_digito_menos_significativo(ix), #57

	;; and segundo_digito_menos_significativo += 1
	;; --------------------------------------------------
	dec score_segundo_digito_menos_significativo(ix)
	jr substract_score_fin

	;; else
	no_modificar_segundo_digito_sscore:
	dec score_digito_menos_significativo(ix)

	substract_score_fin:
	call map_drawScore

	pop ix
ret

map_resetScore::

	push ix

	ld ix, #score
	ld a, #0
	ld (ix), a

	ld ix, #score_char
	ld a, #48
	ld score_digito_menos_significativo(ix), a
	ld score_segundo_digito_menos_significativo(ix), a
	ld score_tercer_digito_menos_significativo(ix), a

	pop ix
ret

;; =============================
;;	Incrementador de punteros
;; 	INPUTS:
;; 		HL: Pointer to change
;; =============================
changePointer:
	;; Vamos siguiente puntero del siguiente mapa y cargamos datos
	ld a, (de)
	ld (hl), a
	inc hl
	inc de
	ld a, (de)
	ld (hl), a
	inc de
ret

;; ======================
;; Change to the next map if posible
;; 	INPUTS:
;; 		A = 0: Next map (right)
;; 		A = 1: Previous map (right)
;;	OUTPUTS:
;;		A = 0: Move hero to the start of the map
;;		A = 80-9: Move hero to the end of the map
;; 		A = -1: Do not move
;; ======================
	

map_changeMap::
	;Comprobamos si vamos para adelante o para detrás y cargamos los datos correspodientes datos
	ld b, a
	cp #1
		jr z, previousMap
	ld de, (puertaDerechaA)

	ld a, d
	cp #0xFF
		jr z, endMap2
	jr startChange

	previousMap:
		ld de, (puertaIzquierdaA)
		
	startChange:
		ld a, d
		cp #0xFF
			jr z, keepOnMap

		call bullets_deleteAllBullets

		;; Cargamos: ptilemapA
		ld hl, #ptilemapA
		;; Cambiamos: ptilemapA
		call changePointer

		;; Cargamos: puertaIzquierdaA
		ld hl, #puertaIzquierdaA
		;; Cambiamos: puertaIzquierdaA
		call changePointer

		;; Cargamos: puertaDerechaA
		ld hl, #puertaDerechaA
		;; Cambiamos: puertaDerechaA
		call changePointer

		;; Cargamos: nEnemyA
		ld hl, #nEnemyA
		;; Cambiamos: nEnemyA
		ld (hl), e
		inc hl
		ld (hl), d
		inc de
		
		;; Cargamos: maxYA
		ld hl, #maxYA
		;; Cambiamos: maxYA
		ld (hl), e
		inc hl
		ld (hl), d
		inc de

		;; Cargamos: arrayEnemyA
		ld hl, #arrayEnemyA
		;; Cambiamos: arrayEnemyA
		ld (hl), e
		inc hl
		inc de
		ld (hl), d


		;; Cargamos el valor, para que se reinicie la posición del hero al princio de la sala.
		push bc
		call map_draw
		pop bc

		ld a, b
		cp #0
		jr z, endMap
			ld a, #80-10
			ret 
		endMap:
			ret 

	keepOnMap:
		;; Cargamoso el valor, para que NO se reinicie la posición del hero.
		ld a, #-1
		ret 
	endMap2:
		ld a, #1
		ld (youWon), a
		ld a, #-1 
		ret
