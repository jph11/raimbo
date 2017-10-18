.area _DATA

.area _CODE

.equ Ent_x, 0
.equ Ent_y, 1
.equ Ent_w, 2
.equ Ent_h, 3	
.equ Ent_spr_l, 4
.equ Ent_spr_h, 5

.include "cpctelera.h.s"
.include "macros.h.s"

defineInitEntity entity 0, 0, 0, 0
entity_last_movement: .db #00
entity_id: .db #03

;; ======================
;;	Sets a pointer to entity data 
;;	INPUT:
;; 		IX: entity_data
;; ======================
entity_setPointer::
	ld a, Ent_x(ix)
	ld (entity_x), a					;; Hl points to the entity Data

	ld a, Ent_y(ix)
	ld (entity_y), a

	ld a, Ent_w(ix)
	ld (entity_w), a					;; Hl points to the entity Data

	ld a, Ent_h(ix)
	ld (entity_h), a
	
	ret

;; ======================
;;	Gets a pointer to hero data 
;;	
;;	RETURNS:
;; 		HL:Pointer to hero data
;; ======================
entity_getPointer::
	ld hl, #entity_x 					;; Hl points to the Hero Data
	ret	

;; ======================
;;	Sets a pointer to entity data 
;;	INPUT:
;; 		A: Entity last movement
;; ======================
entity_setPointerLastMovement::
	ld (entity_last_movement), a
	ret

;; ======================
;;	Sets a pointer to entity data 
;;	OUTPUT:
;; 		HL: Pointer to entity last movement
;; ======================
entity_getPointerLastMovement::
	ld hl, #entity_last_movement 		
	ret

;; ======================
;;	Sets a pointer to entity data 
;;	INPUT:
;; 		A: Entity id
;; ======================
entity_setId::
	ld (entity_id), a
	ret
;; ======================
;;	Sets a pointer to entity data 
;;	OUTPUT:
;; 		HL: Pointer to entity id
;; ======================
entity_getId::
	ld hl, #entity_id		
	ret

;; ======================
;;	Draw the entity
;;	DESTROYS: AF, BC, DE, HL
;;  Parametrer: a
;; ======================
entity_draw::
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Cambiar para optimizar tiempo de orden la comparación
	push af 	;;Save A in the stack

	;; Calculate Screen position
	ld de, #0xC000		;;Video memory

	ld c, Ent_x(ix)			;;\ C=entity_x
	ld b, Ent_y(ix)			;;\ B=entity_y

	call cpct_getScreenPtr_asm	;;Get pointer to screen
	ex de, hl

	;; Draw a box
	ld b, Ent_h(ix)
	ld c, Ent_w(ix)
	pop AF 		;;A = User selected code
	cp #00
	jr z, erase
		;;Draw sprite
		ld h, Ent_spr_h(ix)
		ld l, Ent_spr_l(ix)
		call cpct_drawSprite_asm
		ret
	erase:
		call cpct_drawSolidBox_asm	
	ret