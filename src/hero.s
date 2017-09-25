.area _DATA
.area _CODE

;;====================
;;====================
;;PRIVATE DATA
;;====================
;;====================


;;Hero Data
hero_x: .db #39
hero_y:	.db #80
hero_jump: .db #-1
floor_x: .db #0
floor_y: .db #88
contador: .db #79

;;Jump Table
jumptable:
	.db #-3, #-2, #-1, #-1
	.db #-1, #00, #00, #01
	.db #01, #01, #02, #03
	.db #0x80

;;CPCtelera Symbols
.globl cpct_drawSolidBox_asm
.globl cpct_getScreenPtr_asm
.globl cpct_scanKeyboard_asm
.globl cpct_isKeyPressed_asm

.include "keyboard/keyboard.s"

;;====================
;;====================
;;PUBLIC FUNTIONS
;;====================
;;====================



;; ======================
;;	Controls Jump movements
;; ======================
hero_update::
	call jumpControl
	call checkUserInput
	ret


;; ======================
;;	Controls Jump movements
;; ======================
hero_draw::
	call drawHero
	ret

;; ======================
;;	Controls Jump movements
;; ======================
hero_erase::
	call drawHero
	ret

;;====================
;;====================
;;PRIVATE FUNCTIONS
;;====================
;;====================


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
;; ======================
moveHeroRight:
	ld a, (hero_x)	;;A = hero_x
	cp #80-2		;;Check against right limit (screen size - hero size)
	jr z, d_not_move_right	;;Hero_x == Limit, do not move

	inc a 			;;A++ (hero_x++)
	ld (hero_x), a 	;;Update hero_x

	d_not_move_right:
	ret



;; ======================
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

	;;Check for key 'D' being presed
	ld hl, #Key_D 				;;HL = Key_D
	call cpct_isKeyPressed_asm	;;Check if Key_D is presed
	cp #0						;;Check A == 0
	jr z, d_not_pressed			;;Jump if A==0 (d_not_pressed)

	;;D is pressed
	call moveHeroRight

	d_not_pressed:

	;;Check for key 'A' being presed
	ld hl, #Key_A 				;;HL = Key_A
	call cpct_isKeyPressed_asm	;;Check if Key_A is presed
	cp #0						;;Check A == 0
	jr z, a_not_pressed			;;Jump if A==0 (a_not_pressed)

	;;A is pressed
	call moveHeroLeft

	a_not_pressed:


	;;Check for key 'W' being presed
	ld hl, #Key_W 				;;HL = Key_W
	call cpct_isKeyPressed_asm	;;Check if Key_W is presed
	cp #0						;;Check W == 0
	jr z, w_not_pressed			;;Jump if W==0 (w_not_pressed)

	;;W is pressed
	call startJump

	w_not_pressed:

	ret



;; ======================
;;	Draw the hero
;;	DESTROYS: AF, BC, DE, HL
;;  Parametrer: a
;; ======================
drawHero:

	push af 	;;Save A in the stack

	;; Calculate Screen position
	ld de, #0xC000	;;Video memory

	ld a, (hero_x)	;;|
	ld c, a			;;\ C=hero_x

	ld a, (hero_y)	;;|
	ld b, a			;;\ B=hero_y

	call cpct_getScreenPtr_asm	;;Get pointer to screen
	ex de, hl

	pop AF 		;;A = User selected code

	;; Draw a box
	ld bc, #0x0802	;;8x8
	call cpct_drawSolidBox_asm

	ret

