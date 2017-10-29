.area _DATA

.globl _sprite_oldMan_left
.globl _sprite_death
.globl _sprite_oldMan_orange_left
.globl _sprite_oldMan_orange_left_pistol

.globl _g_tilemap
.globl _g_tilemap1
.globl _g_tilemap3
.area _CODE
.include "enemy.h.s"
.include "bullets.h.s"
.include "cpctelera.h.s"
.include "macros.h.s"

;;========================
;;========================
;; MAP GLOBAL POINTERS
;;========================
;;========================
puntero_video:: .dw #0x8000

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
	.dw #0x000E
ptilemapA::
	.dw #_g_tilemap ;Cambiar al mapa correspondiente
puertaIzquierdaA::
	.dw 0xFFFF
puertaDerechaA::
	.dw M2
arrayEnemyA::
	.dw M1_arrayEnemy

;;========================
;;========================
;; MAPS DATA
; 	Map:
; 		name, ptilemap, puertaIzquierda, puertaDerecha
; 	Enemy:
;		x,  y,  w,  h, sprite, lives,  temp, lastmovement, type 
;;========================
;;========================

M1:
	defineMap M1 0, -1, M2
	defineEnemy 70, 120, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 3
	defineEnemyLastOne 70, 120, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 3

M2:
	defineMap M2 0, M1, M3
	defineEnemyLastOne 70, 120, 9, 25, _sprite_oldMan_orange_left_pistol, 5, 0, 0, 70, 70, 120, 120, 0

M3:
	defineMap M3 0, M2, -1
	defineEnemy 0, 120, 7, 25, _sprite_oldMan_orange_left, 5, 0, 1, 70, 70, 120, 120, 1
	defineEnemyLastOne 70, 120, 9, 25, _sprite_oldMan_orange_left_pistol, 5, 0, 0, 70, 70, 120, 120, 0
	defineMap M1 #_g_tilemap, -1, M2
	defineEnemyLastOne 70, 120, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 2

M2:
	defineMap M2 #_g_tilemap1, M1, M3
	defineEnemy 30, 100, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 3
	defineEnemyLastOne 70, 120, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 2

M3:
	defineMap M3 #_g_tilemap1, M2, M4
	defineEnemy 60, 87, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 3
	defineEnemy 54, 174, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 3
	defineEnemyLastOne 70, 120, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 2

M4:
	defineMap M4 #_g_tilemap1, M3, M5
	defineEnemy 20, 140, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 3
	defineEnemy 60, 180, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 3
	defineEnemyLastOne 70, 120, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 2

M5:
	defineMap M5 #_g_tilemap1, M4, M6
	defineEnemy 50, 50, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 3
	defineEnemyLastOne 70, 120, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 2

M6:
	defineMap M6 #_g_tilemap3, M5, -1
	defineEnemyLastOne 70, 120, 7, 25, _sprite_oldMan_left, 5, 0, 0, 70, 70, 120, 120, 3

;;========================
;;========================
;
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
	ld   hl, (ptilemapA)   ;; HL = pointer to the tilemap
	push hl              ;; Push ptilemap to the stack
	ld   hl, #0xC000  ;; HL = Pointer to video memory location where tilemap is drawn
	push hl              ;; Push pvideomem to the stack
	;; Set Paramters on registers
	ld    a, #40 ;; A = map_width
	ld    b, #0          ;; B = y tile-coordinate
	ld    c, #0          ;; C = x tile-coordinate
	ld    d, #50          ;; H = height in tiles of the tile-box
	ld    e, #40          ;; L =  width in tiles of the tile-box
	call  cpct_etm_drawTileBox2x4_asm ;; Call the function

	;; Set Parameters on the stack
	ld   hl, (ptilemapA)   		;; HL = pointer to the tilemap
	push hl              	;; Push ptilemap to the stack
	ld   hl, #0x8000  		;; HL = Pointer to video memory location where tilemap is drawn
	push hl              	;; Push pvideomem to the stack
	;; Set Paramters on registers
	ld    a, #40 			;; A = map_width
	ld    b, #0          	;; B = y tile-coordinate
	ld    c, #0          	;; C = x tile-coordinate
	ld    d, #50          	;; H = height in tiles of the tile-box
	ld    e, #40          	;; L =  width in tiles of the tile-box
	call  cpct_etm_drawTileBox2x4_asm ;; Call the function
	
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
		push bc
		call map_draw
		pop bc

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
