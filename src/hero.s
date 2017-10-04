.area _DATA

.globl _sprite_hero_right
.globl _sprite_hero_left

.macro defineEntity name, x, y, w, h, spr_right, spri_left
	name'_data:
		name'_x: 	.db x
		name'_y:	.db y
		name'_w:	.db w
		name'_h:	.db h
		name'_jump: .db #-1
		name'_sprite_right: .dw spr_right
		name'_sprite_left: .dw spri_left
.endm

.area _CODE

;;===========================================
;;===========================================
;;PRIVATE DATA
;;===========================================
;;===========================================

;;Hero Data
defineEntity hero 39, 60, 7, 25, _sprite_hero_right, _sprite_hero_left 
hero_last_movement: .db #01
	
.equ Ent_x, 0
.equ Ent_y, 1
.equ Ent_w, 2
.equ Ent_h, 3
.equ Ent_jmp, 4	
.equ Ent_spr_right_l, 5
.equ Ent_spr_right_h, 6
.equ Ent_spr_left_l, 7
.equ Ent_spr_left_h, 8
.equ Ent_lst_mov, 9

;;Jump Table
jumptable:
	.db #-3, #-2, #-1, #-1
	.db #-1, #00, #00, #01
	.db #01, #01, #02, #03
	.db #0x80

.include "bullets.h.s"
.include "cpctelera.h.s"
.include "keyboard.s"

;;===========================================
;;===========================================
;;PUBLIC FUNTIONS
;;===========================================
;;===========================================

;; ======================
;;	Hero Update
;; ======================
hero_update::
	call jumpControl
	call checkUserInput
	ret


;; ======================
;;	Hero Draw
;; ======================
hero_draw::
	ld a, #0xFF
	ld ix, #hero_data
	call drawHero
	ret

;; ======================
;;	Hero Erase
;; ======================
hero_erase::
	ld a, #0x00
	ld ix, #hero_data
	call drawHero
	ret

;; ======================
;;	Hero init
;;  Start hero values
;; ======================
hero_init::
	ld a, #39
	ld (hero_x), a
	ld a, #60
	ld (hero_y), a
	ld a, #-1
	ld (hero_jump), a
	ld a, #01
	ld (hero_last_movement), a

	ret	

;; ======================
;;	Gets a pointer to hero data 
;;	
;;	RETURNS:
;; 		HL:Pointer to hero data
;; ======================
hero_getPointerLastMovement::
	ld hl, #hero_last_movement 		;; Hl points to the Hero Data
	ret

;; ======================
;;	Gets a pointer to hero data 
;;	
;;	RETURNS:
;; 		HL:Pointer to hero data
;; ======================
hero_getPointer::
	ld hl, #hero_x 					;; Hl points to the Hero Data
	ret
	
;;===========================================
;;===========================================
;;PRIVATE FUNCTIONS
;;===========================================
;;===========================================


;; ======================
;;	Controls Jump movements
;; ======================
jumpControl:
	ld a, (hero_jump)	;;A = Hero_jump in status
	cp #-1				;;A == -1? (-1 is not jump)
	ret z				;;If A == -1, not jump

	;;Get Jump Value
	ld hl, #jumptable	;;HL Points
	ld c, a 			;;|
	ld b, #0			;;\ BC = A (Offset)
	add hl, bc			;;HL += BC

	ld a, (hero_jump)	;;A = Hero_jump
	cp #0x0C
	jp z, reset

	;;Do Jump Movement
	ld b, (hl)			;;B = Jump Movement
	ld a, (hero_y)		;;A = Hero_y
	add b 				;;A += B (Add jump)
	ld (hero_y), a 		;; Update Hero Jump

	;;Increment Hero_jump Index
	ld a, (hero_jump)	;;A = Hero_jump
	cp #0x0C 			;;Check if is latest vallue
	jr nz, continue_jump ;;Not latest value, continue

		;;End jump
		ld a, #-2

	continue_jump:
	inc a 				;;|
	ld (hero_jump), a 	;;\ Hero_jump++

	ret

	reset:
	ld a, #-1
	ld (hero_jump), a
	ret



;; ======================
;;	Starts Hero Jump
;; ======================
startJump:
	ld a, (hero_jump)	;;A = hero_jump
	cp #-1				;;A == -1? Is jump action
	ret nz

	;;Jump is inactive, activate it
	ld a, #0
	ld (hero_jump), a


	ret


;; ======================
;; Move hero to up
;; ======================
moveHeroUp:
	ld a, (hero_y)	;;A = hero_y
	cp #0		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_up	;;Hero_y == Limit, do not move

	dec a 			;;A++ (hero_y--)
	dec a
	dec a
	ld (hero_y), a 	;;Update hero_y

	d_not_move_up:
	ret

;; ======================
;; Move hero to bottom
;; ======================
moveHeroBottom:
	ld a, (hero_y)	;;A = hero_y
	cp #180-5		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_bottom	;;Hero_y == Limit, do not move
	cp #180-6		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_bottom	;;Hero_y == Limit, do not move
	cp #180-7		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_bottom	;;Hero_y == Limit, do not move


	inc a 			;;A++ (hero_y++)
	inc a
	inc a
	ld (hero_y), a 	;;Update hero_y

	d_not_move_bottom:
	ret

;; ======================
;; Move hero to the right
;; ======================
moveHeroRight:
	ld a, (hero_x)	;;A = hero_x
	cp #80-7		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_right	;;Hero_x == Limit, do not move

	inc a 			;;A++ (hero_x++)
	ld (hero_x), a 	;;Update hero_x

	d_not_move_right:
	ret



;; ======================
;; Move hero to the left
;; ======================
moveHeroLeft:
	ld a, (hero_x)	;;A = hero_x
	cp #0		;;Check against left limit (screen size - hero size)
	jr z, d_not_move_left	;;Hero_x == Limit, do not move

	dec a 			;;A-- (hero_x--)
	ld (hero_x), a 	;;Update hero_x

	d_not_move_left:
	ret

;; ======================
;;	Checks User Input and Reacts
;;	DESTROYS:
;; ======================
checkUserInput:
	;;Scan the whole keyboard
	call cpct_scanKeyboard_asm ;;keyboard.s


	;;Check for key 'Space' being pressed
	ld hl, #Key_Space
	call cpct_isKeyPressed_asm	;;Check if Key_Space is presed
	cp #0						;;Check A == 0
	jr z, space_not_pressed		;;Jump if A==0 (space_not_pressed)

	;;Space is pressed
	call bullets_newBullet

	space_not_pressed:


	;;Check for key 'A' being pressed
	ld hl, #Key_A 				;;HL = Key_A
	call cpct_isKeyPressed_asm	;;Check if Key_A is presed
	cp #0						;;Check A == 0
	jr z, a_not_pressed			;;Jump if A==0 (a_not_pressed)

	;;A is pressed
	ld hl, #hero_last_movement
	ld a, #00
	ld (hl), a
	call moveHeroLeft

	a_not_pressed:

	;;Check for key 'D' being pressed
	ld hl, #Key_D 				;;HL = Key_D
	call cpct_isKeyPressed_asm	;;Check if Key_D is presed
	cp #0						;;Check A == 0
	jr z, d_not_pressed			;;Jump if A==0 (d_not_pressed)

	;;D is pressed
	ld hl, #hero_last_movement
	ld a, #01
	ld (hl), a
	call moveHeroRight

	d_not_pressed:

	;;Check for key 'W' being pressed
	ld hl, #Key_W 				;;HL = Key_W
	call cpct_isKeyPressed_asm	;;Check if Key_W is presed
	cp #0						;;Check W == 0
	jr z, w_not_pressed			;;Jump if W==0 (w_not_pressed)

	;;W is pressed
	ld hl, #hero_last_movement
	ld a, #02
	ld (hl), a
	call moveHeroUp
	w_not_pressed:

	;;Check for key 'S' being pressed
	ld hl, #Key_S 				;;HL = Key_S
	call cpct_isKeyPressed_asm	;;Check if Key_S is presed
	cp #0						;;Check S == 0
	jr z, s_not_pressed			;;Jump if S==0 (s_not_pressed)

	;;S is pressed
	ld hl, #hero_last_movement
	ld a, #03
	ld (hl), a
	call moveHeroBottom
	s_not_pressed:

	

	;;Check for key 'Shift' being pressed
	ld hl, #Key_Shift 				;;HL = Key_Shift
	call cpct_isKeyPressed_asm	;;Check if Key_Shift is presed
	cp #0						;;Check Shift == 0
	jr z, shift_not_pressed			;;Jump if Shift==0 (shift_not_pressed)

	;;S is pressed
	
	call startJump
	shift_not_pressed:

	ret



;; ======================
;;	Draw the hero
;;	DESTROYS: AF, BC, DE, HL
;;  Parametrer: a
;; ======================
drawHero:

	push af 	;;Save A in the stack

	;; Calculate Screen position
	ld de, #0xC000		;;Video memory

	ld c, Ent_x(ix)			;;\ C=hero_x
	ld b, Ent_y(ix)			;;\ B=hero_y

	call cpct_getScreenPtr_asm	;;Get pointer to screen
	ex de, hl

	;; Draw a box
	ld b, Ent_h(ix)
	ld c, Ent_w(ix)
	pop AF 		;;A = User selected code
	cp #00
	jr z, eraseHero
		push af
		ld a, (hero_last_movement)
		cp #0
		jr z, left
		;;Draw sprite
		pop af
		ld h, Ent_spr_right_h(ix)
		ld l, Ent_spr_right_l(ix)
		call cpct_drawSprite_asm
		ret

		left:
		;;Draw sprite
		pop af
		ld h, Ent_spr_left_h(ix)
		ld l, Ent_spr_left_l(ix)
		call cpct_drawSprite_asm
		ret
	eraseHero:
	call cpct_drawSolidBox_asm	
	ret