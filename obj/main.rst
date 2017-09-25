ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
   429B 00                    2 floor_x: .db #0
   429C 58                    3 floor_y: .db #88
                              4 
                              5 .area _CODE
                              6 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              7 .include "hero.h.s"
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



                              8 .include "scene.h.s"
                              1 .globl scene_drawFloor
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                              9 .include "obstacle.h.s"
                              1 ;;========================
                              2 ;;========================
                              3 ;; PUBLIC FUNCTIONS
                              4 ;;========================
                              5 ;;========================
                              6 
                              7 .globl obstacle_erase
                              8 .globl obstacle_draw
                              9 .globl obstacle_update
                             10 .globl obstacle_checkCollision
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                             10 .include "cpctelera.h.s"
                              1 .globl cpct_drawSolidBox_asm
                              2 .globl cpct_getScreenPtr_asm
                              3 .globl cpct_scanKeyboard_asm
                              4 .globl cpct_isKeyPressed_asm
                              5 .globl cpct_waitVSYNC_asm
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                             11 
                             12 ;; ======================
                             13 ;;	Main program entry
                             14 ;; ======================
   4096                      15 _main::
                             16 
                             17 	
   4096 CD 77 40      [17]   18 	call scene_drawFloor
                             19 
                             20 
   4099                      21 	postStart:
   4099 CD EF 40      [17]   22 	call hero_erase
   409C CD 16 40      [17]   23 	call obstacle_erase
                             24 	
   409F CD DE 40      [17]   25 	call hero_update
   40A2 CD 04 40      [17]   26 	call obstacle_update
                             27 
   40A5 CD EB 40      [17]   28 	call hero_getPointer
   40A8 CD 1C 40      [17]   29 	call obstacle_checkCollision 	;; A=1 collision, A=0 not collision
   40AB 32 00 C0      [13]   30 	ld (0xC000), a 					;; print if collision in the screen
   40AE 32 01 C0      [13]   31 	ld (0xC001), a
   40B1 32 02 C0      [13]   32 	ld (0xC002), a
   40B4 32 03 C0      [13]   33 	ld (0xC003), a 					
   40B7 CD E5 40      [17]   34 	call hero_draw
   40BA CD 10 40      [17]   35 	call obstacle_draw
                             36 
                             37 
   40BD CD 99 41      [17]   38 	call cpct_waitVSYNC_asm
                             39     
   40C0 18 D7         [12]   40 	jr postStart
