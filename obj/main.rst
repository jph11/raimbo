ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 .area _CODE
                              3 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              4 .include "hero.h.s"
                              1 ;;========================
                              2 ;;========================
                              3 ;; HERO PUBLIC FUNCTIONS
                              4 ;;========================
                              5 ;;========================
                              6 
                              7 .globl hero_erase
                              8 .globl hero_draw
                              9 .globl hero_update
                             10 .globl hero_getPointer
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                              5 .include "scene.h.s"
                              1 ;;========================
                              2 ;;========================
                              3 ;; SCENE PUBLIC FUNCTIONS
                              4 ;;========================
                              5 ;;========================
                              6 
                              7 .globl scene_drawFloor
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                              6 .include "bullets.h.s"
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                              7 .include "obstacle.h.s"
                              1 ;;========================
                              2 ;;========================
                              3 ;; OBSTACLE PUBLIC FUNCTIONS
                              4 ;;========================
                              5 ;;========================
                              6 
                              7 .globl obstacle_erase
                              8 .globl obstacle_draw
                              9 .globl obstacle_update
                             10 .globl obstacle_checkCollision
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                              8 .include "cpctelera.h.s"
                              1 ;;
                              2 ;;	CPCtelera Symbols
                              3 ;;
                              4 
                              5 .globl cpct_drawSolidBox_asm
                              6 .globl cpct_getScreenPtr_asm
                              7 .globl cpct_scanKeyboard_asm
                              8 .globl cpct_isKeyPressed_asm
                              9 .globl cpct_waitVSYNC_asm
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                              9 
                             10 ;; ======================
                             11 ;;	Main program entry
                             12 ;; ======================
   4096                      13 _main::
   4096 CD 77 40      [17]   14 	call scene_drawFloor
                             15 
   4099                      16 	postStart:
   4099 CD E2 41      [17]   17 	call bullets_erase
   409C CD E8 40      [17]   18 	call hero_erase
   409F CD 16 40      [17]   19 	call obstacle_erase
                             20 
                             21 	
   40A2 CD DE 41      [17]   22 	call bullets_update
   40A5 CD DB 40      [17]   23 	call hero_update
   40A8 CD 04 40      [17]   24 	call obstacle_update
                             25 
   40AB CD EE 40      [17]   26 	call hero_getPointer
   40AE CD 1C 40      [17]   27 	call obstacle_checkCollision
                             28 
   40B1 CD E8 41      [17]   29 	call bullets_draw
   40B4 CD E2 40      [17]   30 	call hero_draw
   40B7 CD 10 40      [17]   31 	call obstacle_draw
                             32 
   40BA CD 5C 42      [17]   33 	call cpct_waitVSYNC_asm
                             34     
   40BD 18 DA         [12]   35 	jr postStart
