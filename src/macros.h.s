.macro defineEntity name, x, y, w, h, spr, lives,  temp, lastmovement, ux, pux, uy, puy
    name'_data::
        name'_x: 	      .db x   ;[0-80]
        name'_y:	      .db y   ;[0-200]
        name'_w:	      .db w
        name'_h:	      .db h
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
        name'_x: 	.db x   ;[0-80]
        name'_y:	.db y   ;[0-200]
        name'_w:	.db w
        name'_h:	.db h
.endm

.macro defineMap name, ptilemap, puertaIzquierda, puertaDerecha
        name'_ptilemap:
            .dw ptilemap
        name'_puertaIzquierda:
            .dw puertaIzquierda
        name'_puertaDerecha:
            .dw puertaDerecha
        name'_arrayEnemy:
.endm

.macro defineEnemy x,  y,  w,  h, sprite, lives,  temp, lastmovement, ux, pux, uy, puy, type
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

.endm

.macro defineEnemyLastOne x,  y,  w,  h, sprite, lives,  temp, lastmovement, ux, pux, uy, puy, type
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
        .db #0x81
.endm

.macro defineScoreLife name, x, y, w, h, spr
	name'_data::
		name'_x: 	  	.db x
		name'_y:	    .db y  
		name'_w:	    .db w
		name'_h:	    .db h
		name'_sprite:  	.dw spr
.endm