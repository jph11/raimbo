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

NextEnemy:
	.db #10
ptilemapA::
	.dw #0x0000
puertaIzquierdaA::
	.dw #0xFFFF
puertaDerechaA::
	.dw #Map1
arrayEnemyA::
	.dw #arrayEnemyM1

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
		;Enemy:x, y,   w,   h,       sprite,        lives,  temp, lastmovement, type
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x01, #0x00, #0x01, #0x01 
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x01, #0x00, #0x01, #0x02
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x01, #0x00, #0x01, #0x00
		.db #0x81

Map2:
	ptilemapM2:
		.dw #0x0000
	puertaIzquierdaM2:
		.dw #Map1
	puertaDerechaM2:
		.dw #Map3
	arrayEnemyM2:
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x02, #0x00, #0x01, #0x00
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x02, #0x00, #0x01, #0x00
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x02, #0x00, #0x01, #0x00
		.db #0x81
Map3:
	ptilemapM3:
		.dw #0x0000
	puertaIzquierdaM3:
		.dw #Map2
	puertaDerechaM3:
		.dw #0xFFFF
	arrayEnemyM3:
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x03, #0x00, #0x01, #0x02
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x03, #0x00, #0x01, #0x02
		.db #65, #50, #7, #25, _sprite_oldman_left, #0x03, #0x00, #0x01, #0x02
		.db #0x81

map_updateAllEnemiesAndBullets::
	ld ix, #arrayEnemyA
	loopMapUpdate:
	ld a, 0(ix)
	cp #81
	 ret z
	call enemy_update
	call bullets_update
	ld de, (NextEnemy)
	add ix, de
	jr loopMapUpdate

map_drawAllEnemiesAndBullets::
	ld ix, #arrayEnemyA
	loopMapDraw:
	ld a, 0(ix)
	cp #81
	 ret z
	call enemy_draw
	call bullets_draw
	ld de, (NextEnemy)
	add ix, de
	jr loopMapDraw

map_eraseAllEnemiesAndBullets::
	ld ix, #arrayEnemyA
	loopMapErase:
	ld a, 0(ix)
	cp #81
	 ret z
	call enemy_erase
	call bullets_erase
	ld de, (NextEnemy)
	add ix, de
	jr loopMapErase