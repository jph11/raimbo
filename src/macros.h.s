.macro defineEntity name, x, y, w, h, spr
    name'_data:
        name'_x: 	.db x
        name'_y:	.db y
        name'_w:	.db w
        name'_h:	.db h
        name'_sprite: .dw spr
.endm