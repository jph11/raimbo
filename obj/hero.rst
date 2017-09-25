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
   4000 27                   11 hero_x: .db #39
   4001 50                   12 hero_y:	.db #80
   4002 FF                   13 hero_jump: .db #-1
                             14 
                             15 ;;Jump Table
   4003                      16 jumptable:
   4003 FD FE FF FF          17 	.db #-3, #-2, #-1, #-1
   4007 FF 00 00 01          18 	.db #-1, #00, #00, #01
   400B 01 01 02 03          19 	.db #01, #01, #02, #03
   400F 80                   20 	.db #0x80
                             21 
                             22 ;;CPCtelera Symbols
                             23 .globl cpct_drawSolidBox_asm
                             24 .globl cpct_getScreenPtr_asm
                             25 .globl cpct_scanKeyboard_asm
                             26 .globl cpct_isKeyPressed_asm
                             27 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             28 .include "keyboard/keyboard.s"
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
   4010                      25 _cpct_keyboardStatusBuffer:: .ds 10
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



                             29 
                             30 ;;====================
                             31 ;;====================
                             32 ;;PUBLIC FUNTIONS
                             33 ;;====================
                             34 ;;====================
                             35 
                             36 
                             37 
                             38 ;; ======================
                             39 ;;	Controls Jump movements
                             40 ;; ======================
   401A                      41 hero_update::
   401A CD 2D 40      [17]   42 	call jumpControl
   401D CD 82 40      [17]   43 	call checkUserInput
   4020 C9            [10]   44 	ret
                             45 
                             46 
                             47 ;; ======================
                             48 ;;	Controls Jump movements
                             49 ;; ======================
   4021                      50 hero_draw::
   4021 3E FF         [ 7]   51 	ld a, #0xFF
   4023 CD AD 40      [17]   52 	call drawHero
   4026 C9            [10]   53 	ret
                             54 
                             55 ;; ======================
                             56 ;;	Controls Jump movements
                             57 ;; ======================
   4027                      58 hero_erase::
   4027 3E 00         [ 7]   59 	ld a, #0x00
   4029 CD AD 40      [17]   60 	call drawHero
   402C C9            [10]   61 	ret
                             62 
                             63 ;;====================
                             64 ;;====================
                             65 ;;PRIVATE FUNCTIONS
                             66 ;;====================
                             67 ;;====================
                             68 
                             69 
                             70 ;; ======================
                             71 ;;	Controls Jump movements
                             72 ;; ======================
   402D                      73 jumpControl:
   402D 3A 02 40      [13]   74 	ld a, (hero_jump)	;;A = Hero_jump in status
   4030 FE FF         [ 7]   75 	cp #-1				;;A == -1? (-1 is not jump)
   4032 C8            [11]   76 	ret z				;;If A == -1, not jump
                             77 
                             78 	;;Get Jump Value
   4033 21 03 40      [10]   79 	ld hl, #jumptable	;;HL Points
   4036 4F            [ 4]   80 	ld c, a 			;;|
   4037 06 00         [ 7]   81 	ld b, #0			;;\ BC = A (Offset)
   4039 09            [11]   82 	add hl, bc			;;HL += BC
                             83 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



   403A 3A 02 40      [13]   84 	ld a, (hero_jump)	;;A = Hero_jump
   403D FE 0C         [ 7]   85 	cp #0x0C
   403F CA 58 40      [10]   86 	jp z, reset
                             87 
                             88 	;;Do Jump Movement
   4042 46            [ 7]   89 	ld b, (hl)			;;B = Jump Movement
   4043 3A 01 40      [13]   90 	ld a, (hero_y)		;;A = Hero_y
   4046 80            [ 4]   91 	add b 				;;A += B (Add jump)
   4047 32 01 40      [13]   92 	ld (hero_y), a 		;; Update Hero Jump
                             93 
                             94 	;;Increment Hero_jump Index
   404A 3A 02 40      [13]   95 	ld a, (hero_jump)	;;A = Hero_jump
   404D FE 0C         [ 7]   96 	cp #0x0C 			;;Check if is latest vallue
   404F 20 02         [12]   97 	jr nz, continue_jump ;;Not latest value, continue
                             98 
                             99 		;;End jump
   4051 3E FE         [ 7]  100 		ld a, #-2
                            101 
   4053                     102 	continue_jump:
   4053 3C            [ 4]  103 	inc a 				;;|
   4054 32 02 40      [13]  104 	ld (hero_jump), a 	;;\ Hero_jump++
                            105 
   4057 C9            [10]  106 	ret
                            107 
   4058                     108 	reset:
   4058 3E FF         [ 7]  109 	ld a, #-1
   405A 32 02 40      [13]  110 	ld (hero_jump), a
   405D C9            [10]  111 	ret
                            112 
                            113 
                            114 
                            115 ;; ======================
                            116 ;;	Starts Hero Jump
                            117 ;; ======================
   405E                     118 startJump:
   405E 3A 02 40      [13]  119 	ld a, (hero_jump)	;;A = hero_jump
   4061 FE FF         [ 7]  120 	cp #-1				;;A == -1? Is jump action
   4063 C0            [11]  121 	ret nz
                            122 
                            123 	;;Jump is inactive, activate it
   4064 3E 00         [ 7]  124 	ld a, #0
   4066 32 02 40      [13]  125 	ld (hero_jump), a
                            126 
                            127 
   4069 C9            [10]  128 	ret
                            129 
                            130 
                            131 
                            132 ;; ======================
                            133 ;; ======================
   406A                     134 moveHeroRight:
   406A 3A 00 40      [13]  135 	ld a, (hero_x)	;;A = hero_x
   406D FE 4E         [ 7]  136 	cp #80-2		;;Check against right limit (screen size - hero size)
   406F 28 04         [12]  137 	jr z, d_not_move_right	;;Hero_x == Limit, do not move
                            138 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



   4071 3C            [ 4]  139 	inc a 			;;A++ (hero_x++)
   4072 32 00 40      [13]  140 	ld (hero_x), a 	;;Update hero_x
                            141 
   4075                     142 	d_not_move_right:
   4075 C9            [10]  143 	ret
                            144 
                            145 
                            146 
                            147 ;; ======================
                            148 ;; ======================
   4076                     149 moveHeroLeft:
   4076 3A 00 40      [13]  150 	ld a, (hero_x)	;;A = hero_x
   4079 FE 00         [ 7]  151 	cp #0		;;Check against left limit (screen size - hero size)
   407B 28 04         [12]  152 	jr z, d_not_move_left	;;Hero_x == Limit, do not move
                            153 
   407D 3D            [ 4]  154 	dec a 			;;A-- (hero_x--)
   407E 32 00 40      [13]  155 	ld (hero_x), a 	;;Update hero_x
                            156 
   4081                     157 	d_not_move_left:
   4081 C9            [10]  158 	ret
                            159 
                            160 ;; ======================
                            161 ;;	Checks User Input and Reacts
                            162 ;;	DESTROYS:
                            163 ;; ======================
   4082                     164 checkUserInput:
                            165 	;;Scan the whole keyboard
   4082 CD D2 41      [17]  166 	call cpct_scanKeyboard_asm ;;keyboard.s
                            167 
                            168 	;;Check for key 'D' being presed
   4085 21 07 20      [10]  169 	ld hl, #Key_D 				;;HL = Key_D
   4088 CD F5 40      [17]  170 	call cpct_isKeyPressed_asm	;;Check if Key_D is presed
   408B FE 00         [ 7]  171 	cp #0						;;Check A == 0
   408D 28 03         [12]  172 	jr z, d_not_pressed			;;Jump if A==0 (d_not_pressed)
                            173 
                            174 	;;D is pressed
   408F CD 6A 40      [17]  175 	call moveHeroRight
                            176 
   4092                     177 	d_not_pressed:
                            178 
                            179 	;;Check for key 'A' being presed
   4092 21 08 20      [10]  180 	ld hl, #Key_A 				;;HL = Key_A
   4095 CD F5 40      [17]  181 	call cpct_isKeyPressed_asm	;;Check if Key_A is presed
   4098 FE 00         [ 7]  182 	cp #0						;;Check A == 0
   409A 28 03         [12]  183 	jr z, a_not_pressed			;;Jump if A==0 (a_not_pressed)
                            184 
                            185 	;;A is pressed
   409C CD 76 40      [17]  186 	call moveHeroLeft
                            187 
   409F                     188 	a_not_pressed:
                            189 
                            190 
                            191 	;;Check for key 'W' being presed
   409F 21 07 08      [10]  192 	ld hl, #Key_W 				;;HL = Key_W
   40A2 CD F5 40      [17]  193 	call cpct_isKeyPressed_asm	;;Check if Key_W is presed
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



   40A5 FE 00         [ 7]  194 	cp #0						;;Check W == 0
   40A7 28 03         [12]  195 	jr z, w_not_pressed			;;Jump if W==0 (w_not_pressed)
                            196 
                            197 	;;W is pressed
   40A9 CD 5E 40      [17]  198 	call startJump
                            199 
   40AC                     200 	w_not_pressed:
                            201 
   40AC C9            [10]  202 	ret
                            203 
                            204 
                            205 
                            206 ;; ======================
                            207 ;;	Draw the hero
                            208 ;;	DESTROYS: AF, BC, DE, HL
                            209 ;;  Parametrer: a
                            210 ;; ======================
   40AD                     211 drawHero:
                            212 
   40AD F5            [11]  213 	push af 	;;Save A in the stack
                            214 
                            215 	;; Calculate Screen position
   40AE 11 00 C0      [10]  216 	ld de, #0xC000	;;Video memory
                            217 
   40B1 3A 00 40      [13]  218 	ld a, (hero_x)	;;|
   40B4 4F            [ 4]  219 	ld c, a			;;\ C=hero_x
                            220 
   40B5 3A 01 40      [13]  221 	ld a, (hero_y)	;;|
   40B8 47            [ 4]  222 	ld b, a			;;\ B=hero_y
                            223 
   40B9 CD B6 41      [17]  224 	call cpct_getScreenPtr_asm	;;Get pointer to screen
   40BC EB            [ 4]  225 	ex de, hl
                            226 
   40BD F1            [10]  227 	pop AF 		;;A = User selected code
                            228 
                            229 	;; Draw a box
   40BE 01 02 08      [10]  230 	ld bc, #0x0802	;;8x8
   40C1 CD 09 41      [17]  231 	call cpct_drawSolidBox_asm
                            232 
   40C4 C9            [10]  233 	ret
                            234 
