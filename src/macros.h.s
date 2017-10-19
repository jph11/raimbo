.macro defineEntity name, x, y, w, h, spr
    name'_data::
        name'_x: 	.db x   ;[0-80]
        name'_y:	.db y   ;[0-200]
        name'_w:	.db w
        name'_h:	.db h
        name'_sprite: .dw spr
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

.macro defineEnemy x,  y,  w,  h, sprite, lives,  temp, lastmovement, type
        .db x
        .db y
        .db w
        .db h
        .dw sprite
        .db lives
        .db temp
        .db lastmovement
        .db type

.endm

.macro defineEnemyLastOne x,  y,  w,  h, sprite, lives,  temp, lastmovement, type
        .db x
        .db y
        .db w
        .db h
        .dw sprite
        .db lives
        .db temp
        .db lastmovement
        .db type
        .db #0x81
.endm