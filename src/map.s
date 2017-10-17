.area _DATA

.globl _sprite_oldman_left
.globl _sprite_death

.area _CODE

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
	.dw #0xFFFF
arrayEnemyA::
	.dw #0x0000

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

map_updateAllEnemies::
	ld ix, #arrayEnemyA
	loopMap:
	ld a, 0(ix)
	cp #81
	 ret z
	call enemy_update
	ld de, (NextEnemy)
	add ix, de
ret

map_drawAllEnemies::
	ld ix, #arrayEnemyA
	loopMap:
	ld a, 0(ix)
	cp #81
	 ret z
	call enemy_update
	ld de, (NextEnemy)
	add ix, de
ret

map_eraseAllEnemies::
	ld ix, #arrayEnemyA
	loopMap:
	ld a, 0(ix)
	cp #81
	 ret z
	call enemy_update
	ld de, (NextEnemy)
	add ix, de
ret