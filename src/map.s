.area _DATA

.globl _sprite_oldman_left
.globl _sprite_death

.area _CODE
.include "enemy.h.s"
.include "bullets.h.s"
;;========================
;;========================
;; MAP GLOBAL POINTERS
;;========================
;;========================
.equ Enemy_x, 0
.equ Enemy_y, 1
.equ Enemy_w, 2
.equ Enemy_h, 3	
.equ EnemyLives, 6
.equ EnemyTemp, 7
.equ EnemyLastMovement, 8
.equ EnemyType, 9

NextEnemy:
	.db #10
ptilemapA::
	.dw #0x0000
puertaIzquierdaA::
	.dw #0xFFFF
puertaDerechaA::
	.dw Map2
arrayEnemyA::
	.dw arrayEnemyM1

;;========================
;;========================
;; MAPS DATA
;;========================
;;========================

Map1:
	ptilemapM1:
		.dw #0x0000
	puertaIzquierdaM1:
		.dw #0xFFFF
	puertaDerechaM1:
		.dw #Map2
	arrayEnemyM1:

		; Start Array
		; x,  y,  w,  h 
		; sprite
		; lives,  temp, lastmovement, type
		;
		; #0x81 - End Array
		
		.db #0, #170, #7, #25 
		.dw _sprite_oldman_left 
		.db #0x05, #0x00, #0x01, #0x01

		.db #70, #170, #7, #25 
		.dw _sprite_oldman_left 
		.db #0x05, #0x00, #0x01, #0x01

		;.db #65, #50, #7, #25
		;.dw _sprite_oldman_left
		;.db #0x01, #0x00, #0x01, #0x00
		.db #0x81

Map2:
	ptilemapM2:
		.dw #0x0000
	puertaIzquierdaM2:
		.dw Map1
	puertaDerechaM2:
		.dw Map3
	arrayEnemyM2:
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x02, #0x00, #0x01, #0x00
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x02, #0x00, #0x01, #0x00
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x02, #0x00, #0x01, #0x00
		.db #0x81
Map3:
	ptilemapM3:
		.dw #0x0000
	puertaIzquierdaM3:
		.dw Map2
	puertaDerechaM3:
		.dw #0xFFFF
	arrayEnemyM3:
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x03, #0x00, #0x01, #0x02
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x03, #0x00, #0x01, #0x02
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x03, #0x00, #0x01, #0x02
		.db #0x81

map_updateAllEnemiesAndBullets::
	call bullets_updateBullets
	ld ix, (arrayEnemyA)
	loopMapUpdate:
	ld a, Enemy_x(ix)
	cp #0x81
	 ret z
	call enemy_update
	call bullet_checkCollision
	ld de, (NextEnemy)
	add ix, de
	jr loopMapUpdate

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

map_changeMapNext::
	ld a, (puertaDerechaA)
	cp #0xFF
 		ret z
 	ret 
 	
map_changeMapPrevious::

	ret