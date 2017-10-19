.area _DATA

.globl _sprite_oldman_left
.globl _sprite_death
.globl _sprite_viejoNaranja 

.area _CODE
.include "enemy.h.s"
.include "bullets.h.s"
.include "macros.h.s"
;;========================
;;========================
;; MAP GLOBAL POINTERS
;;========================
;;========================

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

NextEnemy:
	.db #14
ptilemapA::
	.dw #0x0000 ;Cambiar al mapa correspondiente
puertaIzquierdaA::
	.dw 0xFFFF
puertaDerechaA::
	.dw M2
arrayEnemyA::
	.dw M1_arrayEnemy

;;========================
;;========================
;; MAPS DATA
;;========================
;;========================


 	; Map:
 	; 	name, ptilemap, puertaIzquierda, puertaDerecha
 	; Enemy:
 	;	x,  y,  w,  h, sprite, lives,  temp, lastmovement, type 

M1:
	defineMap M1 0, -1, M2
	;defineEnemy 0, 170, 7, 25, _sprite_oldman_left, 5, 0, 1, 1
	defineEnemyLastOne 70, 170, 7, 25, _sprite_oldman_left, 5, 0, 0, 70, 70, 170, 170, 0

M2:
	defineMap M2 0, M1, M3
	defineEnemyLastOne 70, 170, 7, 25, _sprite_viejoNaranja, 5, 0, 1, 70, 70, 170, 170, 1

M3:
	defineMap M3 0, M2, -1
	defineEnemy 0, 170, 7, 25, _sprite_viejoNaranja, 5, 0, 1, 70, 70, 170, 170, 1
	defineEnemyLastOne 70, 170, 7, 25, _sprite_oldman_left, 5, 0, 1, 70, 70, 170, 170, 1

map_updateAllEnemiesAndBullets::
	call bullets_updateBullets
	ld ix, (arrayEnemyA)
	loopMapUpdate:
	ld a, Enemy_x(ix)
	cp #0x81
	 ret z
	call enemy_update
	push ix
	call bullet_checkCollision
	pop ix
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
;;		A = 80-9: Move hero to the end of the map
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