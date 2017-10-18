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