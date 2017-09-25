ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 .area _CODE
                              3 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              4 .include "hero.h.s"
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



                              5 .globl cpct_waitVSYNC_asm
                              6 
                              7 ;; ======================
                              8 ;; Draw
                              9 ;; Parametrers hl (init position), 
                             10 ;; ======================
   4000                      11 drawFloor:
                             12  
                             13  
   4000 11 00 08      [10]   14  ld de, #0x0800
   4003 0E 10         [ 7]   15  ld c, #16
   4005                      16  oneFor:
   4005 06 50         [ 7]   17   ld b, #80
   4007                      18   twoFor:
   4007 36 F0         [10]   19    ld (hl), #0xF0
   4009 23            [ 6]   20    inc hl
   400A 05            [ 4]   21    dec b
   400B 20 FA         [12]   22    jr nz, twoFor
                             23   
   400D 19            [11]   24   add hl, de
   400E D5            [11]   25   push de
   400F 11 B0 FF      [10]   26   ld de, #0xFFB0
   4012 19            [11]   27   add hl, de
   4013 D1            [10]   28   pop de
   4014 0D            [ 4]   29   dec c
   4015 20 EE         [12]   30   jr nz, oneFor
   4017 C9            [10]   31  ret
                             32 
                             33 
                             34 ;; ======================
                             35 ;;	Main program entry
                             36 ;; ======================
   4018                      37 _main::
                             38 
   4018 21 70 C3      [10]   39 	ld hl, #0xC370
   401B CD 00 40      [17]   40 	call drawFloor
                             41 
                             42 
   401E                      43 	postStart:
                             44 
   401E 3E 00         [ 7]   45 	ld a, #0x00
   4020 CD 58 40      [17]   46 	call hero_erase
                             47 
   4023 CD 4D 40      [17]   48 	call hero_update
                             49 
   4026 3E FF         [ 7]   50 	ld a, #0xFF
   4028 CD 54 40      [17]   51 	call hero_draw
                             52 
   402B CD 00 41      [17]   53 	call cpct_waitVSYNC_asm
                             54 
                             55 	;; posición actual a la que estamos ejecutando
   402E 18 EE         [12]   56 	jr postStart
