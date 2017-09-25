.area _DATA
.area _CODE
;;====================
;;====================
;;PRIVATE DATA
;;====================
;;====================

;;====================
;;====================
;;PUBLIC FUNTIONS
;;====================
;;====================



;; ======================
;;	Draw floor
;; ======================
scene_drawFloor::
    ld hl, #0xC370
	call drawFloor
	ret


;;====================
;;====================
;;PRIVATE FUNCTIONS
;;====================
;;====================

;; ======================
;; Draw
;; Parametrers hl (init position), 
;; ======================
drawFloor:
 ld de, #0x0800
 ld c, #16
 oneFor:
  ld b, #80
  twoFor:
   ld (hl), #0xF0
   inc hl
   dec b
   jr nz, twoFor
  
  add hl, de
  push de
  ld de, #0xFFB0
  add hl, de
  pop de
  dec c
  jr nz, oneFor
 ret