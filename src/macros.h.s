.macro defineEntity name, x, y, w, h, spr, lives,  temp, lastmovement, ux, pux, uy, puy
    name'_data::
        name'_x:          .db x   ;[0-80]
        name'_y:          .db y   ;[0-200]
        name'_w:          .db w
        name'_h:          .db h
        name'_sprite:     .dw spr
        name'_lives:      .db lives
        name'_temp:       .db temp
        name'_directionBullet:: .db lastmovement
        name'_ux:         .db ux
        name'_pux:        .db pux
        name'_uy:         .db uy
        name'_puy:        .db puy
.endm

.macro defineObject name, x, y, w, h, spr
    name'_data::
        name'_x:          .db x   ;[0-80]
        name'_y:          .db y   ;[0-200]
        name'_w:          .db w
        name'_h:          .db h
        name'_sprite:     .dw spr
.endm

.macro defineInitEntity name, x, y, w, h
    name'_data:
        name'_x:    .db x   ;[0-80]
        name'_y:    .db y   ;[0-200]
        name'_w:    .db w
        name'_h:    .db h
.endm

.macro defineMap name, ptilemap, puertaIzquierda, puertaDerecha, nEnemy
        name'_ptilemap:
            .dw ptilemap
        name'_puertaIzquierda:
            .dw puertaIzquierda
        name'_puertaDerecha:
            .dw puertaDerecha
        name'_nEnemyMap:
            .db nEnemy
        name'_arrayEnemy:
.endm

.macro defineEnemy x,  y,  w,  h, sprite, lives,  temp, lastmovement, ux, pux, uy, puy, type, pattern, pattern_antiguo, contador
        .db x
        .db y
        .db w
        .db h
        .dw sprite
        .db lives
        .db temp
        .db lastmovement
        .db ux
        .db pux
        .db uy
        .db puy
        .db type
        .dw pattern
        .dw pattern_antiguo
        .db contador
.endm

.macro defineEnemyLastOne x,  y,  w,  h, sprite, lives,  temp, lastmovement, ux, pux, uy, puy, type, pattern, pattern_antiguo, contador
        .db x
        .db y
        .db w
        .db h
        .dw sprite
        .db lives
        .db temp
        .db lastmovement
        .db ux
        .db pux
        .db uy
        .db puy
        .db type
        .dw pattern
        .dw pattern_antiguo
        .db contador
        .db #0x81
.endm

.macro definePatternAction numero_veces, aumento_x, aumento_y, sprite, disparo1, disparo2, disparo3, velocidad
        .db numero_veces
        .db aumento_x
        .db aumento_y
        .dw sprite
        .db disparo1
        .db disparo2
        .db disparo3
        .db velocidad
.endm

.macro definePatternLastAction numero_veces, aumento_x, aumento_y, sprite, disparo1, disparo2, disparo3, velocidad
        .db numero_veces
        .db aumento_x
        .db aumento_y
        .dw sprite
        .db disparo1
        .db disparo2
        .db disparo3
        .db velocidad
        .db #0xFF
.endm

.macro defineScoreLife name, x, y, w, h, spr
	name'_data::
		name'_x: 	  	.db x
		name'_y:	    .db y  
		name'_w:	    .db w
		name'_h:	    .db h
		name'_sprite:  	.dw spr
.endm

.macro defineMenu name, x, y, w, h, spr
	name'_data::
		name'_x: 	  	.db x
		name'_y:	    .db y  
		name'_w:	    .db w
		name'_h:	    .db h
		name'_sprite:  	.dw spr
.endm
