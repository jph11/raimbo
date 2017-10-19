.area _DATA

.globl _sprite_oldman_left
.globl _sprite_death
.globl _sprite_viejoNaranja 

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
	.dw #0x0000 ;Cambiar al mapa correspondiente
puertaIzquierdaA::
	.dw 0xFFFF
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
		.db #0, #170, #7, #25  											; x,  y,  w,  h
		.dw _sprite_oldman_left 										; sprite 
		.db #0x05, #0x00, #0x01, #0x01									; lives,  temp, lastmovement, type
																		; #0x81 - End Array
		.db #70, #170, #7, #25 
		.dw _sprite_oldman_left 
		.db #0x05, #0x00, #0x01, #0x01

		.db #0x81

Map2:
	ptilemapM2:
		.dw #0x0000
	puertaIzquierdaM2:
		.dw Map1
	puertaDerechaM2:
		.dw Map3
	arrayEnemyM2:
		.db #70, #170, #7, #25 
		.dw _sprite_viejoNaranja 
		.db #0x05, #0x00, #0x01, #0x01
		.db #0x81
Map3:
	ptilemapM3:
		.dw #0x0000
	puertaIzquierdaM3:
		.dw Map2
	puertaDerechaM3:
		.dw #0xFFFF
	arrayEnemyM3:
	
		.db #0, #170, #7, #25 
		.dw _sprite_viejoNaranja 
		.db #0x05, #0x00, #0x01, #0x01

		.db #70, #170, #7, #25 
		.dw _sprite_oldman_left 
		.db #0x05, #0x00, #0x01, #0x01

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
;; 		A = -1: Do not move
;; ======================

map_changeMap::
	
	;Comprobamos si vamos para adelante o para detrás y cargamos los datos correspodientes datos
	ld b, a
	cp #1
		jr z, previousMap
	ld de, (puertaDerechaA)
	jr startChange

	previousMap:
		ld de, (puertaIzquierdaA)
	

	startChange:
		ld a, d
		cp #0xFF
			jr z, keepOnMap

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

		;; Cargamos: arrayEnemyA
		ld hl, #arrayEnemyA
		;; Cambiamos: arrayEnemyA
		ld (hl), e
		inc hl
		inc de
		ld (hl), d

		;; Cargamos el valor, para que se reinicie la posición del hero al princio de la sala.

		ld a, b
		cp #0
		jr z, endMap
			ld a, #80-9
			ret 
		endMap:
		ret 

	keepOnMap:
		;; Cargamoso el valor, para que NO se reinicie la posición del hero.
		ld a, #-1
		ret 