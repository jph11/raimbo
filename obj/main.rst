ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
   4203 00                    2 floor_x: .db #0
   4204 58                    3 floor_y: .db #88
                              4 
                              5 .area _CODE
                              6 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              7 .include "hero.h.s"
                              1 ;;
                              2 ;;
                              3 ;; HERO 
                              4 ;;
                              5 ;;
                              6 .globl hero_erase
                              7 .globl hero_draw
                              8 .globl hero_update
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                              8 .include "scene.h.s"
                              1 .globl scene_drawFloor
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                              9 .globl cpct_waitVSYNC_asm
                             10 
                             11 
                             12 
                             13 
                             14 ;; ======================
                             15 ;;	Main program entry
                             16 ;; ======================
   40C5                      17 _main::
                             18 
                             19 	
   40C5 CD D6 40      [17]   20 	call scene_drawFloor
                             21 
                             22 
   40C8                      23 	postStart:
                             24 
   40C8 CD 27 40      [17]   25 	call hero_erase
                             26 
   40CB CD 1A 40      [17]   27 	call hero_update
                             28 
   40CE CD 21 40      [17]   29 	call hero_draw
                             30 
   40D1 CD 01 41      [17]   31 	call cpct_waitVSYNC_asm
                             32     
   40D4 18 F2         [12]   33 	jr postStart
