.area _DATA
.area _CODE

.include "game.h.s"
.include "cpctelera.h.s"


;; ======================
;;	Main program entry
;; ======================
_main::
	call game_start
