ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 
                              3 ;;Hero Data
   41D8 27                    4 hero_x: .db #39
   41D9 50                    5 hero_y:	.db #80
   41DA FF                    6 hero_jump: .db #-1
   41DB 00                    7 floor_x: .db #0
   41DC 58                    8 floor_y: .db #88
   41DD 4F                    9 contador: .db #79
                             10 
                             11 ;;Jump Table
   41DE                      12 jumptable:
   41DE FD FE FF FF          13 	.db #-3, #-2, #-1, #-1
   41E2 FF 00 00 01          14 	.db #-1, #00, #00, #01
   41E6 01 01 02 03          15 	.db #01, #01, #02, #03
   41EA 80                   16 	.db #0x80
                             17 
                             18 ;;CPCtelera Symbols
                             19 .globl cpct_drawSolidBox_asm
                             20 .globl cpct_getScreenPtr_asm
                             21 .globl cpct_scanKeyboard_asm
                             22 .globl cpct_isKeyPressed_asm
                             23 .globl cpct_waitVSYNC_asm
                             24 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             25 .include "keyboard/keyboard.s"
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
   41EB                      25 _cpct_keyboardStatusBuffer:: .ds 10
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



                             26 
                             27 .area _CODE
                             28 
                             29 ;; ======================
                             30 ;;	Controls Jump movements
                             31 ;; ======================
   4000                      32 jumpControl:
   4000 3A DA 41      [13]   33 	ld a, (hero_jump)	;;A = Hero_jump in status
   4003 FE FF         [ 7]   34 	cp #-1				;;A == -1? (-1 is not jump)
   4005 C8            [11]   35 	ret z				;;If A == -1, not jump
                             36 
                             37 	;;Get Jump Value
   4006 21 DE 41      [10]   38 	ld hl, #jumptable	;;HL Points
   4009 4F            [ 4]   39 	ld c, a 			;;|
   400A 06 00         [ 7]   40 	ld b, #0			;;\ BC = A (Offset)
   400C 09            [11]   41 	add hl, bc			;;HL += BC
                             42 
   400D 3A DA 41      [13]   43 	ld a, (hero_jump)	;;A = Hero_jump
   4010 FE 0C         [ 7]   44 	cp #0x0C
   4012 CA AD 40      [10]   45 	jp z, reset
                             46 
                             47 	;;Do Jump Movement
   4015 46            [ 7]   48 	ld b, (hl)			;;B = Jump Movement
   4016 3A D9 41      [13]   49 	ld a, (hero_y)		;;A = Hero_y
   4019 80            [ 4]   50 	add b 				;;A += B (Add jump)
   401A 32 D9 41      [13]   51 	ld (hero_y), a 		;; Update Hero Jump
                             52 
                             53 	;;Increment Hero_jump Index
   401D 3A DA 41      [13]   54 	ld a, (hero_jump)	;;A = Hero_jump
   4020 FE 0C         [ 7]   55 	cp #0x0C 			;;Check if is latest vallue
   4022 20 02         [12]   56 	jr nz, continue_jump ;;Not latest value, continue
                             57 
                             58 		;;End jump
   4024 3E FE         [ 7]   59 		ld a, #-2
                             60 
   4026                      61 	continue_jump:
   4026 3C            [ 4]   62 	inc a 				;;|
   4027 32 DA 41      [13]   63 	ld (hero_jump), a 	;;\ Hero_jump++
                             64 
   402A C9            [10]   65 	ret
                             66 
                             67 
                             68 
                             69 ;; ======================
                             70 ;;	Starts Hero Jump
                             71 ;; ======================
   402B                      72 startJump:
   402B 3A DA 41      [13]   73 	ld a, (hero_jump)	;;A = hero_jump
   402E FE FF         [ 7]   74 	cp #-1				;;A == -1? Is jump action
   4030 C0            [11]   75 	ret nz
                             76 
                             77 	;;Jump is inactive, activate it
   4031 3E 00         [ 7]   78 	ld a, #0
   4033 32 DA 41      [13]   79 	ld (hero_jump), a
                             80 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                             81 
   4036 C9            [10]   82 	ret
                             83 
                             84 
                             85 
                             86 ;; ======================
                             87 ;; ======================
   4037                      88 moveHeroRight:
   4037 3A D8 41      [13]   89 	ld a, (hero_x)	;;A = hero_x
   403A FE 4E         [ 7]   90 	cp #80-2		;;Check against right limit (screen size - hero size)
   403C 28 04         [12]   91 	jr z, d_not_move_right	;;Hero_x == Limit, do not move
                             92 
   403E 3C            [ 4]   93 	inc a 			;;A++ (hero_x++)
   403F 32 D8 41      [13]   94 	ld (hero_x), a 	;;Update hero_x
                             95 
   4042                      96 	d_not_move_right:
   4042 C9            [10]   97 	ret
                             98 
                             99 
                            100 
                            101 ;; ======================
                            102 ;; ======================
   4043                     103 moveHeroLeft:
   4043 3A D8 41      [13]  104 	ld a, (hero_x)	;;A = hero_x
   4046 FE 00         [ 7]  105 	cp #0		;;Check against left limit (screen size - hero size)
   4048 28 04         [12]  106 	jr z, d_not_move_left	;;Hero_x == Limit, do not move
                            107 
   404A 3D            [ 4]  108 	dec a 			;;A-- (hero_x--)
   404B 32 D8 41      [13]  109 	ld (hero_x), a 	;;Update hero_x
                            110 
   404E                     111 	d_not_move_left:
   404E C9            [10]  112 	ret
                            113 
                            114 
                            115 ;; ======================
                            116 ;; Draw the floor
                            117 ;; ======================
   404F                     118 drawFloor:
                            119  
   404F 21 70 C3      [10]  120  ld hl, #0xC370
   4052 11 00 08      [10]  121  ld de, #0x0800
   4055 0E 10         [ 7]  122  ld c, #16
   4057                     123  oneFor:
   4057 06 50         [ 7]  124   ld b, #80
   4059                     125   twoFor:
   4059 36 F0         [10]  126    ld (hl), #0xF0
   405B 23            [ 6]  127    inc hl
   405C 05            [ 4]  128    dec b
   405D 20 FA         [12]  129    jr nz, twoFor
                            130   
   405F 19            [11]  131   add hl, de
   4060 D5            [11]  132   push de
   4061 11 B0 FF      [10]  133   ld de, #0xFFB0
   4064 19            [11]  134   add hl, de
   4065 D1            [10]  135   pop de
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



   4066 0D            [ 4]  136   dec c
   4067 20 EE         [12]  137   jr nz, oneFor
   4069 C9            [10]  138  ret
                            139 	
                            140 
                            141 
                            142 ;; ======================
                            143 ;;	Checks User Input and Reacts
                            144 ;;	DESTROYS:
                            145 ;; ======================
   406A                     146 checkUserInput:
                            147 	;;Scan the whole keyboard
   406A CD A7 41      [17]  148 	call cpct_scanKeyboard_asm ;;keyboard.s
                            149 
                            150 	;;Check for key 'D' being presed
   406D 21 07 20      [10]  151 	ld hl, #Key_D 				;;HL = Key_D
   4070 CD CA 40      [17]  152 	call cpct_isKeyPressed_asm	;;Check if Key_D is presed
   4073 FE 00         [ 7]  153 	cp #0						;;Check A == 0
   4075 28 03         [12]  154 	jr z, d_not_pressed			;;Jump if A==0 (d_not_pressed)
                            155 
                            156 	;;D is pressed
   4077 CD 37 40      [17]  157 	call moveHeroRight
                            158 
   407A                     159 	d_not_pressed:
                            160 
                            161 	;;Check for key 'A' being presed
   407A 21 08 20      [10]  162 	ld hl, #Key_A 				;;HL = Key_A
   407D CD CA 40      [17]  163 	call cpct_isKeyPressed_asm	;;Check if Key_A is presed
   4080 FE 00         [ 7]  164 	cp #0						;;Check A == 0
   4082 28 03         [12]  165 	jr z, a_not_pressed			;;Jump if A==0 (a_not_pressed)
                            166 
                            167 	;;A is pressed
   4084 CD 43 40      [17]  168 	call moveHeroLeft
                            169 
   4087                     170 	a_not_pressed:
                            171 
                            172 
                            173 	;;Check for key 'W' being presed
   4087 21 07 08      [10]  174 	ld hl, #Key_W 				;;HL = Key_W
   408A CD CA 40      [17]  175 	call cpct_isKeyPressed_asm	;;Check if Key_W is presed
   408D FE 00         [ 7]  176 	cp #0						;;Check W == 0
   408F 28 03         [12]  177 	jr z, w_not_pressed			;;Jump if W==0 (w_not_pressed)
                            178 
                            179 	;;W is pressed
   4091 CD 2B 40      [17]  180 	call startJump
                            181 
   4094                     182 	w_not_pressed:
                            183 
   4094 C9            [10]  184 	ret
                            185 
                            186 
                            187 
                            188 ;; ======================
                            189 ;;	Draw the hero
                            190 ;;	DESTROYS: AF, BC, DE, HL
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



                            191 ;;  Parametrer: a
                            192 ;; ======================
   4095                     193 drawHero:
                            194 
   4095 F5            [11]  195 	push af 	;;Save A in the stack
                            196 
                            197 	;; Calculate Screen position
   4096 11 00 C0      [10]  198 	ld de, #0xC000	;;Video memory
                            199 
   4099 3A D8 41      [13]  200 	ld a, (hero_x)	;;|
   409C 4F            [ 4]  201 	ld c, a			;;\ C=hero_x
                            202 
   409D 3A D9 41      [13]  203 	ld a, (hero_y)	;;|
   40A0 47            [ 4]  204 	ld b, a			;;\ B=hero_y
                            205 
   40A1 CD 8B 41      [17]  206 	call cpct_getScreenPtr_asm	;;Get pointer to screen
   40A4 EB            [ 4]  207 	ex de, hl
                            208 
   40A5 F1            [10]  209 	pop AF 		;;A = User selected code
                            210 
                            211 	;; Draw a box
   40A6 01 02 08      [10]  212 	ld bc, #0x0802	;;8x8
   40A9 CD DE 40      [17]  213 	call cpct_drawSolidBox_asm
                            214 
   40AC C9            [10]  215 	ret
                            216 
                            217 
                            218 ;; ======================
                            219 ;;	Main program entry
                            220 ;; ======================
   40AD                     221 _main::
                            222 
   40AD                     223 	reset:
   40AD 3E FF         [ 7]  224 	ld a, #-1
   40AF 32 DA 41      [13]  225 	ld (hero_jump), a
                            226 
   40B2 CD 4F 40      [17]  227 	call drawFloor
                            228 
                            229 
   40B5                     230 	postStart:
                            231 
   40B5 3E 00         [ 7]  232 	ld a, #0x00
   40B7 CD 95 40      [17]  233 	call drawHero
                            234 
   40BA CD 00 40      [17]  235 	call jumpControl
   40BD CD 6A 40      [17]  236 	call checkUserInput
                            237 
   40C0 3E FF         [ 7]  238 	ld a, #0xFF
   40C2 CD 95 40      [17]  239 	call drawHero
                            240 
                            241 	;;ld e, #40
                            242 
                            243 		;;espera:
                            244 		;;	halt
                            245 		;;	dec e
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



                            246 		;;	jr nz, espera
                            247 
   40C5 CD D6 40      [17]  248 	call cpct_waitVSYNC_asm
                            249 
                            250 	;; posición actual a la que estamos ejecutando
   40C8 18 EB         [12]  251 	jr postStart
