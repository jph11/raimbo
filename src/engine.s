.area _DATA
.area _CODE

.include "hero.h.s"
.include "obstacle.h.s"
.include "enemy.h.s"
.include "bullets.h.s"
.include "map.h.s"
.include "cpctelera.h.s"

.macro setBorder color
    ld hl, #0x'color'10
    call cpct_setPALColour_asm
.endm

;;===========================================
;;===========================================
;;PUBLIC FUNTIONS
;;===========================================
;;===========================================

;; ======================
;;  Draw all
;; ======================
engine_drawAll::

    ;;call map_draw
    call hero_draw
    ;;call obstacle_draw
    call map_drawAllEnemiesAndBullets
    ret

;; ======================
;;  Update all
;; ======================
engine_updateAll::
    call hero_update
    ;;call obstacle_update
    call map_updateAllEnemiesAndBullets

    ret

;; ======================
;;  Erase all
;; ======================
engine_eraseAll::
    call hero_erase
    ;;call obstacle_erase
    call map_eraseAllEnemiesAndBullets
    ret  