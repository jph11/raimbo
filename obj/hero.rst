ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 .area _CODE
                              3 
                              4 ;;====================
                              5 ;;====================
                              6 ;;PRIVATE DATA
                              7 ;;====================
                              8 ;;====================
                              9 
                             10 ;;Hero Data
   40C2 27                   11 hero_x: .db #39
   40C3 50                   12 hero_y:	.db #80
   40C4 02                   13 hero_w:	.db #2
   40C5 04                   14 hero_h:	.db #4
   40C6 FF                   15 hero_jump: .db #-1
                             16 
                             17 ;;Jump Table
   40C7                      18 jumptable:
   40C7 FD FE FF FF          19 	.db #-3, #-2, #-1, #-1
   40CB FF 00 00 01          20 	.db #-1, #00, #00, #01
   40CF 01 01 02 03          21 	.db #01, #01, #02, #03
   40D3 80                   22 	.db #0x80
                             23 
                             24 ;;CPCtelera Symbols
                             25 .globl cpct_drawSolidBox_asm
                             26 .globl cpct_getScreenPtr_asm
                             27 .globl cpct_scanKeyboard_asm
                             28 .globl cpct_isKeyPressed_asm
                             29 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             30 .include "keyboard/keyboard.s"
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
   40D4                      25 _cpct_keyboardStatusBuffer:: .ds 10
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                             31 
                             32 ;;====================
                             33 ;;====================
                             34 ;;PUBLIC FUNTIONS
                             35 ;;====================
                             36 ;;====================
                             37 
                             38 
                             39 
                             40 ;; ======================
                             41 ;;	Controls Jump movements
                             42 ;; ======================
   40DE                      43 hero_update::
   40DE CD F5 40      [17]   44 	call jumpControl
   40E1 CD 4A 41      [17]   45 	call checkUserInput
   40E4 C9            [10]   46 	ret
                             47 
                             48 
                             49 ;; ======================
                             50 ;;	Controls Jump movements
                             51 ;; ======================
   40E5                      52 hero_draw::
   40E5 3E FF         [ 7]   53 	ld a, #0xFF
   40E7 CD 75 41      [17]   54 	call drawHero
   40EA C9            [10]   55 	ret
                             56 
                             57 ;; ======================
                             58 ;;	Gets a pointer to hero data 
                             59 ;;	
                             60 ;;	RETURNS:
                             61 ;; 		HL:Pointer to hero data
                             62 ;; ======================
   40EB                      63 hero_getPointer::
   40EB 21 C2 40      [10]   64 	ld hl, #hero_x;; Hl points to the Hero Data
   40EE C9            [10]   65 	ret
                             66 
                             67 ;; ======================
                             68 ;;	Controls Jump movements
                             69 ;; ======================
   40EF                      70 hero_erase::
   40EF 3E 00         [ 7]   71 	ld a, #0x00
   40F1 CD 75 41      [17]   72 	call drawHero
   40F4 C9            [10]   73 	ret
                             74 
                             75 ;;====================
                             76 ;;====================
                             77 ;;PRIVATE FUNCTIONS
                             78 ;;====================
                             79 ;;====================
                             80 
                             81 
                             82 ;; ======================
                             83 ;;	Controls Jump movements
                             84 ;; ======================
   40F5                      85 jumpControl:
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



   40F5 3A C6 40      [13]   86 	ld a, (hero_jump)	;;A = Hero_jump in status
   40F8 FE FF         [ 7]   87 	cp #-1				;;A == -1? (-1 is not jump)
   40FA C8            [11]   88 	ret z				;;If A == -1, not jump
                             89 
                             90 	;;Get Jump Value
   40FB 21 C7 40      [10]   91 	ld hl, #jumptable	;;HL Points
   40FE 4F            [ 4]   92 	ld c, a 			;;|
   40FF 06 00         [ 7]   93 	ld b, #0			;;\ BC = A (Offset)
   4101 09            [11]   94 	add hl, bc			;;HL += BC
                             95 
   4102 3A C6 40      [13]   96 	ld a, (hero_jump)	;;A = Hero_jump
   4105 FE 0C         [ 7]   97 	cp #0x0C
   4107 CA 20 41      [10]   98 	jp z, reset
                             99 
                            100 	;;Do Jump Movement
   410A 46            [ 7]  101 	ld b, (hl)			;;B = Jump Movement
   410B 3A C3 40      [13]  102 	ld a, (hero_y)		;;A = Hero_y
   410E 80            [ 4]  103 	add b 				;;A += B (Add jump)
   410F 32 C3 40      [13]  104 	ld (hero_y), a 		;; Update Hero Jump
                            105 
                            106 	;;Increment Hero_jump Index
   4112 3A C6 40      [13]  107 	ld a, (hero_jump)	;;A = Hero_jump
   4115 FE 0C         [ 7]  108 	cp #0x0C 			;;Check if is latest vallue
   4117 20 02         [12]  109 	jr nz, continue_jump ;;Not latest value, continue
                            110 
                            111 		;;End jump
   4119 3E FE         [ 7]  112 		ld a, #-2
                            113 
   411B                     114 	continue_jump:
   411B 3C            [ 4]  115 	inc a 				;;|
   411C 32 C6 40      [13]  116 	ld (hero_jump), a 	;;\ Hero_jump++
                            117 
   411F C9            [10]  118 	ret
                            119 
   4120                     120 	reset:
   4120 3E FF         [ 7]  121 	ld a, #-1
   4122 32 C6 40      [13]  122 	ld (hero_jump), a
   4125 C9            [10]  123 	ret
                            124 
                            125 
                            126 
                            127 ;; ======================
                            128 ;;	Starts Hero Jump
                            129 ;; ======================
   4126                     130 startJump:
   4126 3A C6 40      [13]  131 	ld a, (hero_jump)	;;A = hero_jump
   4129 FE FF         [ 7]  132 	cp #-1				;;A == -1? Is jump action
   412B C0            [11]  133 	ret nz
                            134 
                            135 	;;Jump is inactive, activate it
   412C 3E 00         [ 7]  136 	ld a, #0
   412E 32 C6 40      [13]  137 	ld (hero_jump), a
                            138 
                            139 
   4131 C9            [10]  140 	ret
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                            141 
                            142 
                            143 
                            144 ;; ======================
                            145 ;; ======================
   4132                     146 moveHeroRight:
   4132 3A C2 40      [13]  147 	ld a, (hero_x)	;;A = hero_x
   4135 FE 4E         [ 7]  148 	cp #80-2		;;Check against right limit (screen size - hero size)
   4137 28 04         [12]  149 	jr z, d_not_move_right	;;Hero_x == Limit, do not move
                            150 
   4139 3C            [ 4]  151 	inc a 			;;A++ (hero_x++)
   413A 32 C2 40      [13]  152 	ld (hero_x), a 	;;Update hero_x
                            153 
   413D                     154 	d_not_move_right:
   413D C9            [10]  155 	ret
                            156 
                            157 
                            158 
                            159 ;; ======================
                            160 ;; ======================
   413E                     161 moveHeroLeft:
   413E 3A C2 40      [13]  162 	ld a, (hero_x)	;;A = hero_x
   4141 FE 00         [ 7]  163 	cp #0		;;Check against left limit (screen size - hero size)
   4143 28 04         [12]  164 	jr z, d_not_move_left	;;Hero_x == Limit, do not move
                            165 
   4145 3D            [ 4]  166 	dec a 			;;A-- (hero_x--)
   4146 32 C2 40      [13]  167 	ld (hero_x), a 	;;Update hero_x
                            168 
   4149                     169 	d_not_move_left:
   4149 C9            [10]  170 	ret
                            171 
                            172 ;; ======================
                            173 ;;	Checks User Input and Reacts
                            174 ;;	DESTROYS:
                            175 ;; ======================
   414A                     176 checkUserInput:
                            177 	;;Scan the whole keyboard
   414A CD 6A 42      [17]  178 	call cpct_scanKeyboard_asm ;;keyboard.s
                            179 
                            180 	;;Check for key 'D' being presed
   414D 21 07 20      [10]  181 	ld hl, #Key_D 				;;HL = Key_D
   4150 CD 8D 41      [17]  182 	call cpct_isKeyPressed_asm	;;Check if Key_D is presed
   4153 FE 00         [ 7]  183 	cp #0						;;Check A == 0
   4155 28 03         [12]  184 	jr z, d_not_pressed			;;Jump if A==0 (d_not_pressed)
                            185 
                            186 	;;D is pressed
   4157 CD 32 41      [17]  187 	call moveHeroRight
                            188 
   415A                     189 	d_not_pressed:
                            190 
                            191 	;;Check for key 'A' being presed
   415A 21 08 20      [10]  192 	ld hl, #Key_A 				;;HL = Key_A
   415D CD 8D 41      [17]  193 	call cpct_isKeyPressed_asm	;;Check if Key_A is presed
   4160 FE 00         [ 7]  194 	cp #0						;;Check A == 0
   4162 28 03         [12]  195 	jr z, a_not_pressed			;;Jump if A==0 (a_not_pressed)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



                            196 
                            197 	;;A is pressed
   4164 CD 3E 41      [17]  198 	call moveHeroLeft
                            199 
   4167                     200 	a_not_pressed:
                            201 
                            202 
                            203 	;;Check for key 'W' being presed
   4167 21 07 08      [10]  204 	ld hl, #Key_W 				;;HL = Key_W
   416A CD 8D 41      [17]  205 	call cpct_isKeyPressed_asm	;;Check if Key_W is presed
   416D FE 00         [ 7]  206 	cp #0						;;Check W == 0
   416F 28 03         [12]  207 	jr z, w_not_pressed			;;Jump if W==0 (w_not_pressed)
                            208 
                            209 	;;W is pressed
   4171 CD 26 41      [17]  210 	call startJump
                            211 
   4174                     212 	w_not_pressed:
                            213 
   4174 C9            [10]  214 	ret
                            215 
                            216 
                            217 
                            218 ;; ======================
                            219 ;;	Draw the hero
                            220 ;;	DESTROYS: AF, BC, DE, HL
                            221 ;;  Parametrer: a
                            222 ;; ======================
   4175                     223 drawHero:
                            224 
   4175 F5            [11]  225 	push af 	;;Save A in the stack
                            226 
                            227 	;; Calculate Screen position
   4176 11 00 C0      [10]  228 	ld de, #0xC000	;;Video memory
                            229 
   4179 3A C2 40      [13]  230 	ld a, (hero_x)	;;|
   417C 4F            [ 4]  231 	ld c, a			;;\ C=hero_x
                            232 
   417D 3A C3 40      [13]  233 	ld a, (hero_y)	;;|
   4180 47            [ 4]  234 	ld b, a			;;\ B=hero_y
                            235 
   4181 CD 4E 42      [17]  236 	call cpct_getScreenPtr_asm	;;Get pointer to screen
   4184 EB            [ 4]  237 	ex de, hl
                            238 
   4185 F1            [10]  239 	pop AF 		;;A = User selected code
                            240 
                            241 	;; Draw a box
   4186 01 02 08      [10]  242 	ld bc, #0x0802	;;8x8
   4189 CD A1 41      [17]  243 	call cpct_drawSolidBox_asm
                            244 
   418C C9            [10]  245 	ret
                            246 
