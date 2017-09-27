ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 .area _CODE
                              3 
                              4 ;;===========================================
                              5 ;;===========================================
                              6 ;;PRIVATE DATA
                              7 ;;===========================================
                              8 ;;===========================================
                              9 
                             10 ;;Hero Data
   40BF 27                   11 hero_x: .db #39
   40C0 50                   12 hero_y:	.db #80
   40C1 02                   13 hero_w:	.db #2
   40C2 04                   14 hero_h:	.db #4
   40C3 FF                   15 hero_jump: .db #-1
                             16 
                             17 ;;Jump Table
   40C4                      18 jumptable:
   40C4 FD FE FF FF          19 	.db #-3, #-2, #-1, #-1
   40C8 FF 00 00 01          20 	.db #-1, #00, #00, #01
   40CC 01 01 02 03          21 	.db #01, #01, #02, #03
   40D0 80                   22 	.db #0x80
                             23 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             24 .include "bullets.h.s"
                              1 ;;========================
                              2 ;;========================
                              3 ;; BULLETS PUBLIC FUNCTIONS
                              4 ;;========================
                              5 ;;========================
                              6 
                              7 .globl bullets_update
                              8 .globl bullets_draw
                              9 .globl bullets_erase
                             10 .globl bullets_newBullet
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                             25 .include "cpctelera.h.s"
                              1 ;;
                              2 ;;	CPCtelera Symbols
                              3 ;;
                              4 
                              5 .globl cpct_drawSolidBox_asm
                              6 .globl cpct_getScreenPtr_asm
                              7 .globl cpct_scanKeyboard_asm
                              8 .globl cpct_isKeyPressed_asm
                              9 .globl cpct_waitVSYNC_asm
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                             26 .include "keyboard/keyboard.s"
                              1 ;;-----------------------------LICENSE NOTICE------------------------------------
                              2 ;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
                              3 ;;  Copyright (C) 2014 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
                              4 ;;
                              5 ;;  This program is free software: you can redistribute it and/or modify
                              6 ;;  it under the terms of the GNU Lesser General Public License as published by
                              7 ;;  the Free Software Foundation, either version 3 of the License, or
                              8 ;;  (at your option) any later version.
                              9 ;;
                             10 ;;  This program is distributed in the hope that it will be useful,
                             11 ;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
                             12 ;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
                             13 ;;  GNU Lesser General Public License for more details.
                             14 ;;
                             15 ;;  You should have received a copy of the GNU Lesser General Public License
                             16 ;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
                             17 ;;-------------------------------------------------------------------------------
                             18 .module cpct_keyboard
                             19 
                             20 ;; bndry directive does not work when linking previously compiled files
                             21 ;.bndry 16
                             22 ;;   16-byte aligned in memory to let functions use 8-bit maths for pointing
                             23 ;;   (alignment not working on user linking)
                             24 
   40D1                      25 _cpct_keyboardStatusBuffer:: .ds 10
                             26 
                             27 ;;
                             28 ;; Assembly constant definitions for keyboard mapping
                             29 ;;
                             30 
                             31 ;; Matrix Line 0x00
                     0100    32 .equ Key_CursorUp     ,#0x0100  ;; Bit 0 (01h) => | 0000 0001 |
                     0200    33 .equ Key_CursorRight  ,#0x0200  ;; Bit 1 (02h) => | 0000 0010 |
                     0400    34 .equ Key_CursorDown   ,#0x0400  ;; Bit 2 (04h) => | 0000 0100 |
                     0800    35 .equ Key_F9           ,#0x0800  ;; Bit 3 (08h) => | 0000 1000 |
                     1000    36 .equ Key_F6           ,#0x1000  ;; Bit 4 (10h) => | 0001 0000 |
                     2000    37 .equ Key_F3           ,#0x2000  ;; Bit 5 (20h) => | 0010 0000 |
                     4000    38 .equ Key_Enter        ,#0x4000  ;; Bit 6 (40h) => | 0100 0000 |
                     8000    39 .equ Key_FDot         ,#0x8000  ;; Bit 7 (80h) => | 1000 0000 |
                             40 ;; Matrix Line 0x01
                     0101    41 .equ Key_CursorLeft   ,#0x0101
                     0201    42 .equ Key_Copy         ,#0x0201
                     0401    43 .equ Key_F7           ,#0x0401
                     0801    44 .equ Key_F8           ,#0x0801
                     1001    45 .equ Key_F5           ,#0x1001
                     2001    46 .equ Key_F1           ,#0x2001
                     4001    47 .equ Key_F2           ,#0x4001
                     8001    48 .equ Key_F0           ,#0x8001
                             49 ;; Matrix Line 0x02
                     0102    50 .equ Key_Clr          ,#0x0102
                     0202    51 .equ Key_OpenBracket  ,#0x0202
                     0402    52 .equ Key_Return       ,#0x0402
                     0802    53 .equ Key_CloseBracket ,#0x0802
                     1002    54 .equ Key_F4           ,#0x1002
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                     2002    55 .equ Key_Shift        ,#0x2002
                     4002    56 .equ Key_BackSlash    ,#0x4002
                     8002    57 .equ Key_Control      ,#0x8002
                             58 ;; Matrix Line 0x03
                     0103    59 .equ Key_Caret        ,#0x0103
                     0203    60 .equ Key_Hyphen       ,#0x0203
                     0403    61 .equ Key_At           ,#0x0403
                     0803    62 .equ Key_P            ,#0x0803
                     1003    63 .equ Key_SemiColon    ,#0x1003
                     2003    64 .equ Key_Colon        ,#0x2003
                     4003    65 .equ Key_Slash        ,#0x4003
                     8003    66 .equ Key_Dot          ,#0x8003
                             67 ;; Matrix Line 0x04
                     0104    68 .equ Key_0            ,#0x0104
                     0204    69 .equ Key_9            ,#0x0204
                     0404    70 .equ Key_O            ,#0x0404
                     0804    71 .equ Key_I            ,#0x0804
                     1004    72 .equ Key_L            ,#0x1004
                     2004    73 .equ Key_K            ,#0x2004
                     4004    74 .equ Key_M            ,#0x4004
                     8004    75 .equ Key_Comma        ,#0x8004
                             76 ;; Matrix Line 0x05
                     0105    77 .equ Key_8            ,#0x0105
                     0205    78 .equ Key_7            ,#0x0205
                     0405    79 .equ Key_U            ,#0x0405
                     0805    80 .equ Key_Y            ,#0x0805
                     1005    81 .equ Key_H            ,#0x1005
                     2005    82 .equ Key_J            ,#0x2005
                     4005    83 .equ Key_N            ,#0x4005
                     8005    84 .equ Key_Space        ,#0x8005
                             85 ;; Matrix Line 0x06
                     0106    86 .equ Key_6            ,#0x0106
                     0106    87 .equ Joy1_Up          ,#0x0106
                     0206    88 .equ Key_5            ,#0x0206
                     0206    89 .equ Joy1_Down        ,#0x0206
                     0406    90 .equ Key_R            ,#0x0406
                     0406    91 .equ Joy1_Left        ,#0x0406
                     0806    92 .equ Key_T            ,#0x0806
                     0806    93 .equ Joy1_Right       ,#0x0806
                     1006    94 .equ Key_G            ,#0x1006
                     1006    95 .equ Joy1_Fire1       ,#0x1006
                     2006    96 .equ Key_F            ,#0x2006
                     2006    97 .equ Joy1_Fire2       ,#0x2006
                     4006    98 .equ Key_B            ,#0x4006
                     4006    99 .equ Joy1_Fire3       ,#0x4006
                     8006   100 .equ Key_V            ,#0x8006
                            101 ;; Matrix Line 0x07
                     0107   102 .equ Key_4            ,#0x0107
                     0207   103 .equ Key_3            ,#0x0207
                     0407   104 .equ Key_E            ,#0x0407
                     0807   105 .equ Key_W            ,#0x0807
                     1007   106 .equ Key_S            ,#0x1007
                     2007   107 .equ Key_D            ,#0x2007
                     4007   108 .equ Key_C            ,#0x4007
                     8007   109 .equ Key_X            ,#0x8007
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                            110 ;; Matrix Line 0x08
                     0108   111 .equ Key_1            ,#0x0108
                     0208   112 .equ Key_2            ,#0x0208
                     0408   113 .equ Key_Esc          ,#0x0408
                     0808   114 .equ Key_Q            ,#0x0808
                     1008   115 .equ Key_Tab          ,#0x1008
                     2008   116 .equ Key_A            ,#0x2008
                     4008   117 .equ Key_CapsLock     ,#0x4008
                     8008   118 .equ Key_Z            ,#0x8008
                            119 ;; Matrix Line 0x09
                     0109   120 .equ Joy0_Up          ,#0x0109
                     0209   121 .equ Joy0_Down        ,#0x0209
                     0409   122 .equ Joy0_Left        ,#0x0409
                     0809   123 .equ Joy0_Right       ,#0x0809
                     1009   124 .equ Joy0_Fire1       ,#0x1009
                     2009   125 .equ Joy0_Fire2       ,#0x2009
                     4009   126 .equ Joy0_Fire3       ,#0x4009
                     8009   127 .equ Key_Del          ,#0x8009
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                             27 
                             28 ;;===========================================
                             29 ;;===========================================
                             30 ;;PUBLIC FUNTIONS
                             31 ;;===========================================
                             32 ;;===========================================
                             33 
                             34 ;; ======================
                             35 ;;	Hero Update
                             36 ;; ======================
   40DB                      37 hero_update::
   40DB CD F2 40      [17]   38 	call jumpControl
   40DE CD 47 41      [17]   39 	call checkUserInput
   40E1 C9            [10]   40 	ret
                             41 
                             42 
                             43 ;; ======================
                             44 ;;	Hero Draw
                             45 ;; ======================
   40E2                      46 hero_draw::
   40E2 3E FF         [ 7]   47 	ld a, #0xFF
   40E4 CD 7F 41      [17]   48 	call drawHero
   40E7 C9            [10]   49 	ret
                             50 
                             51 ;; ======================
                             52 ;;	Hero Erase
                             53 ;; ======================
   40E8                      54 hero_erase::
   40E8 3E 00         [ 7]   55 	ld a, #0x00
   40EA CD 7F 41      [17]   56 	call drawHero
   40ED C9            [10]   57 	ret
                             58 
                             59 ;; ======================
                             60 ;;	Gets a pointer to hero data 
                             61 ;;	
                             62 ;;	RETURNS:
                             63 ;; 		HL:Pointer to hero data
                             64 ;; ======================
   40EE                      65 hero_getPointer::
   40EE 21 BF 40      [10]   66 	ld hl, #hero_x 		;; Hl points to the Hero Data
   40F1 C9            [10]   67 	ret
                             68 
                             69 
                             70 ;;===========================================
                             71 ;;===========================================
                             72 ;;PRIVATE FUNCTIONS
                             73 ;;===========================================
                             74 ;;===========================================
                             75 
                             76 
                             77 ;; ======================
                             78 ;;	Controls Jump movements
                             79 ;; ======================
   40F2                      80 jumpControl:
   40F2 3A C3 40      [13]   81 	ld a, (hero_jump)	;;A = Hero_jump in status
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



   40F5 FE FF         [ 7]   82 	cp #-1				;;A == -1? (-1 is not jump)
   40F7 C8            [11]   83 	ret z				;;If A == -1, not jump
                             84 
                             85 	;;Get Jump Value
   40F8 21 C4 40      [10]   86 	ld hl, #jumptable	;;HL Points
   40FB 4F            [ 4]   87 	ld c, a 			;;|
   40FC 06 00         [ 7]   88 	ld b, #0			;;\ BC = A (Offset)
   40FE 09            [11]   89 	add hl, bc			;;HL += BC
                             90 
   40FF 3A C3 40      [13]   91 	ld a, (hero_jump)	;;A = Hero_jump
   4102 FE 0C         [ 7]   92 	cp #0x0C
   4104 CA 1D 41      [10]   93 	jp z, reset
                             94 
                             95 	;;Do Jump Movement
   4107 46            [ 7]   96 	ld b, (hl)			;;B = Jump Movement
   4108 3A C0 40      [13]   97 	ld a, (hero_y)		;;A = Hero_y
   410B 80            [ 4]   98 	add b 				;;A += B (Add jump)
   410C 32 C0 40      [13]   99 	ld (hero_y), a 		;; Update Hero Jump
                            100 
                            101 	;;Increment Hero_jump Index
   410F 3A C3 40      [13]  102 	ld a, (hero_jump)	;;A = Hero_jump
   4112 FE 0C         [ 7]  103 	cp #0x0C 			;;Check if is latest vallue
   4114 20 02         [12]  104 	jr nz, continue_jump ;;Not latest value, continue
                            105 
                            106 		;;End jump
   4116 3E FE         [ 7]  107 		ld a, #-2
                            108 
   4118                     109 	continue_jump:
   4118 3C            [ 4]  110 	inc a 				;;|
   4119 32 C3 40      [13]  111 	ld (hero_jump), a 	;;\ Hero_jump++
                            112 
   411C C9            [10]  113 	ret
                            114 
   411D                     115 	reset:
   411D 3E FF         [ 7]  116 	ld a, #-1
   411F 32 C3 40      [13]  117 	ld (hero_jump), a
   4122 C9            [10]  118 	ret
                            119 
                            120 
                            121 
                            122 ;; ======================
                            123 ;;	Starts Hero Jump
                            124 ;; ======================
   4123                     125 startJump:
   4123 3A C3 40      [13]  126 	ld a, (hero_jump)	;;A = hero_jump
   4126 FE FF         [ 7]  127 	cp #-1				;;A == -1? Is jump action
   4128 C0            [11]  128 	ret nz
                            129 
                            130 	;;Jump is inactive, activate it
   4129 3E 00         [ 7]  131 	ld a, #0
   412B 32 C3 40      [13]  132 	ld (hero_jump), a
                            133 
                            134 
   412E C9            [10]  135 	ret
                            136 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



                            137 
                            138 
                            139 ;; ======================
                            140 ;; Move hero to the right
                            141 ;; ======================
   412F                     142 moveHeroRight:
   412F 3A BF 40      [13]  143 	ld a, (hero_x)	;;A = hero_x
   4132 FE 4E         [ 7]  144 	cp #80-2		;;Check against right limit (screen size - hero size)
   4134 28 04         [12]  145 	jr z, d_not_move_right	;;Hero_x == Limit, do not move
                            146 
   4136 3C            [ 4]  147 	inc a 			;;A++ (hero_x++)
   4137 32 BF 40      [13]  148 	ld (hero_x), a 	;;Update hero_x
                            149 
   413A                     150 	d_not_move_right:
   413A C9            [10]  151 	ret
                            152 
                            153 
                            154 
                            155 ;; ======================
                            156 ;; Move hero to the left
                            157 ;; ======================
   413B                     158 moveHeroLeft:
   413B 3A BF 40      [13]  159 	ld a, (hero_x)	;;A = hero_x
   413E FE 00         [ 7]  160 	cp #0		;;Check against left limit (screen size - hero size)
   4140 28 04         [12]  161 	jr z, d_not_move_left	;;Hero_x == Limit, do not move
                            162 
   4142 3D            [ 4]  163 	dec a 			;;A-- (hero_x--)
   4143 32 BF 40      [13]  164 	ld (hero_x), a 	;;Update hero_x
                            165 
   4146                     166 	d_not_move_left:
   4146 C9            [10]  167 	ret
                            168 
                            169 ;; ======================
                            170 ;;	Checks User Input and Reacts
                            171 ;;	DESTROYS:
                            172 ;; ======================
   4147                     173 checkUserInput:
                            174 	;;Scan the whole keyboard
   4147 CD 2D 43      [17]  175 	call cpct_scanKeyboard_asm ;;keyboard.s
                            176 
                            177 
                            178 	;;Check for key 'Space' being pressed
   414A 21 05 80      [10]  179 	ld hl, #Key_Space
   414D CD 50 42      [17]  180 	call cpct_isKeyPressed_asm	;;Check if Key_Space is presed
   4150 FE 00         [ 7]  181 	cp #0						;;Check A == 0
   4152 28 03         [12]  182 	jr z, space_not_pressed		;;Jump if A==0 (space_not_pressed)
                            183 
                            184 	;;Space is pressed
   4154 CD BD 41      [17]  185 	call bullets_newBullet
                            186 
   4157                     187 	space_not_pressed:
                            188 
                            189 	;;Check for key 'D' being pressed
   4157 21 07 20      [10]  190 	ld hl, #Key_D 				;;HL = Key_D
   415A CD 50 42      [17]  191 	call cpct_isKeyPressed_asm	;;Check if Key_D is presed
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 10.
Hexadecimal [16-Bits]



   415D FE 00         [ 7]  192 	cp #0						;;Check A == 0
   415F 28 03         [12]  193 	jr z, d_not_pressed			;;Jump if A==0 (d_not_pressed)
                            194 
                            195 	;;D is pressed
   4161 CD 2F 41      [17]  196 	call moveHeroRight
                            197 
   4164                     198 	d_not_pressed:
                            199 
                            200 	;;Check for key 'A' being pressed
   4164 21 08 20      [10]  201 	ld hl, #Key_A 				;;HL = Key_A
   4167 CD 50 42      [17]  202 	call cpct_isKeyPressed_asm	;;Check if Key_A is presed
   416A FE 00         [ 7]  203 	cp #0						;;Check A == 0
   416C 28 03         [12]  204 	jr z, a_not_pressed			;;Jump if A==0 (a_not_pressed)
                            205 
                            206 	;;A is pressed
   416E CD 3B 41      [17]  207 	call moveHeroLeft
                            208 
   4171                     209 	a_not_pressed:
                            210 
                            211 
                            212 	;;Check for key 'W' being pressed
   4171 21 07 08      [10]  213 	ld hl, #Key_W 				;;HL = Key_W
   4174 CD 50 42      [17]  214 	call cpct_isKeyPressed_asm	;;Check if Key_W is presed
   4177 FE 00         [ 7]  215 	cp #0						;;Check W == 0
   4179 28 03         [12]  216 	jr z, w_not_pressed			;;Jump if W==0 (w_not_pressed)
                            217 
                            218 	;;W is pressed
   417B CD 23 41      [17]  219 	call startJump
                            220 
   417E                     221 	w_not_pressed:
                            222 
   417E C9            [10]  223 	ret
                            224 
                            225 
                            226 
                            227 ;; ======================
                            228 ;;	Draw the hero
                            229 ;;	DESTROYS: AF, BC, DE, HL
                            230 ;;  Parametrer: a
                            231 ;; ======================
   417F                     232 drawHero:
                            233 
   417F F5            [11]  234 	push af 	;;Save A in the stack
                            235 
                            236 	;; Calculate Screen position
   4180 11 00 C0      [10]  237 	ld de, #0xC000	;;Video memory
                            238 
   4183 3A BF 40      [13]  239 	ld a, (hero_x)	;;|
   4186 4F            [ 4]  240 	ld c, a			;;\ C=hero_x
                            241 
   4187 3A C0 40      [13]  242 	ld a, (hero_y)	;;|
   418A 47            [ 4]  243 	ld b, a			;;\ B=hero_y
                            244 
   418B CD 11 43      [17]  245 	call cpct_getScreenPtr_asm	;;Get pointer to screen
   418E EB            [ 4]  246 	ex de, hl
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 11.
Hexadecimal [16-Bits]



                            247 
   418F F1            [10]  248 	pop AF 		;;A = User selected code
                            249 
                            250 	;; Draw a box
   4190 01 02 08      [10]  251 	ld bc, #0x0802	;;8x8
   4193 CD 64 42      [17]  252 	call cpct_drawSolidBox_asm
                            253 
   4196 C9            [10]  254 	ret
