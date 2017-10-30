##-----------------------------LICENSE NOTICE------------------------------------
##  This file is part of CPCtelera: An Amstrad CPC Game Engine 
##  Copyright (C) 2016 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU Lesser General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##------------------------------------------------------------------------------

############################################################################
##                        CPCTELERA ENGINE                                ##
##                 Automatic image conversion file                        ##
##------------------------------------------------------------------------##
## This file is intended for users to automate image conversion from JPG, ##
## PNG, GIF, etc. into C-arrays.                                          ##
##                                                                        ##
## Macro used for conversion is IMG2SPRITES, which has up to 9 parameters:##
##  (1): Image file to be converted into C sprite (PNG, JPG, GIF, etc)    ##
##  (2): Graphics mode (0,1,2) for the generated C sprite                 ##
##  (3): Prefix to add to all C-identifiers generated                     ##
##  (4): Width in pixels of each sprite/tile/etc that will be generated   ##
##  (5): Height in pixels of each sprite/tile/etc that will be generated  ##
##  (6): Firmware palette used to convert the image file into C values    ##
##  (7): (mask / tileset /)                                               ##
##     - "mask":    generate interlaced mask for all sprites converted    ##
##     - "tileset": generate a tileset array with pointers to all sprites ##
##  (8): Output subfolder for generated .C/.H files (in project folder)   ##
##  (9): (hwpalette)                                                      ##
##     - "hwpalette": output palette array with hardware colour values    ##
## (10): Aditional options (you can use this to pass aditional modifiers  ##
##       to cpct_img2tileset)                                             ##
##                                                                        ##
## Macro is used in this way (one line for each image to be converted):   ##
##  $(eval $(call IMG2SPRITES,(1),(2),(3),(4),(5),(6),(7),(8),(9), (10))) ##
##                                                                        ##
## Important:                                                             ##
##  * Do NOT separate macro parameters with spaces, blanks or other chars.##
##    ANY character you put into a macro parameter will be passed to the  ##
##    macro. Therefore ...,src/sprites,... will represent "src/sprites"   ##
##    folder, whereas ...,  src/sprites,... means "  src/sprites" folder. ##
##                                                                        ##
##  * You can omit parameters but leaving them empty. Therefore, if you   ##
##  wanted to specify an output folder but do not want your sprites to    ##
##  have mask and/or tileset, you may omit parameter (7) leaving it empty ##
##     $(eval $(call IMG2SPRITES,imgs/1.png,0,g,4,8,$(PAL),,src/))        ##
############################################################################

## Example firmware palette definition as variable in cpct_img2tileset format

PALETTE={0 1 3 6 7 9 12 13 14 15 16 18 19 24 25 26}

## Example image conversion
##    This example would convert img/example.png into src/example.{c|h} files.
##    A C-array called pre_example[24*12*2] would be generated with the definition
##    of the image example.png in mode 0 screen pixel format, with interlaced mask.
##    The palette used for conversion is given through the PALETTE variable and
##    a pre_palette[16] array will be generated with the 16 palette colours as 
##	  hardware colour values.
##HERO
$(eval $(call IMG2SPRITES,assets/Hero/hero_right_pistol.png,0,sprite,18,25,$(PALETTE),mask,src/sprites,hwpalette))
$(eval $(call IMG2SPRITES,assets/Hero/hero_left_pistol.png,0,sprite,18,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Hero/hero_back_pistol.png,0,sprite,18,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Hero/hero_forward_pistol.png,0,sprite,18,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Hero/hero_downRight-diag_pistol.png,0,sprite,18,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Hero/hero_downLeft-diag_pistol.png,0,sprite,18,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Hero/hero_upRight-diag_pistol.png,0,sprite,18,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Hero/hero_upLeft-diag_pistol.png,0,sprite,18,25,$(PALETTE),mask,src/sprites,))

##ENEMIES
$(eval $(call IMG2SPRITES,assets/Enemies/oldMan_left.png,0,sprite,14,25,$(PALETTE),mask,src/sprites,))
#$(eval $(call IMG2SPRITES,assets/Enemies/oldMan_orange_left.png,0,sprite,14,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/ball_bike_left.png,0,sprite,22,30,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/ball_bike_right.png,0,sprite,22,30,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/ball_left.png,0,sprite,22,22,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/ball_right.png,0,sprite,22,22,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/bullet_shooter_left.png,0,sprite,14,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/bullet_shooter_right.png,0,sprite,14,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/ghost_left.png,0,sprite,14,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/ghost_right.png,0,sprite,14,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/hooded_left.png,0,sprite,14,25,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Enemies/hooded_right.png,0,sprite,14,25,$(PALETTE),mask,src/sprites,))



#$(eval $(call IMG2SPRITES,assets/Enemies/octopus_forward.png,0,sprite,18,18,$(PALETTE),mask,src/sprites,))
#$(eval $(call IMG2SPRITES,assets/Enemies/octopus_back.png,0,sprite,18,18,$(PALETTE),mask,src/sprites,))
#$(eval $(call IMG2SPRITES,assets/Enemies/octopus_left.png,0,sprite,18,18,$(PALETTE),mask,src/sprites,))
#$(eval $(call IMG2SPRITES,assets/Enemies/octopus_right.png,0,sprite,18,18,$(PALETTE),mask,src/sprites,))

#$(eval $(call IMG2SPRITES,assets/Enemies/octopus_whip_forward.png,0,sprite,30,22,$(PALETTE),mask,src/sprites,))
#$(eval $(call IMG2SPRITES,assets/Enemies/octopus_whip_back.png,0,sprite,30,22,$(PALETTE),mask,src/sprites,))
#$(eval $(call IMG2SPRITES,assets/Enemies/octopus_whip_left.png,0,sprite,30,22,$(PALETTE),mask,src/sprites,))
#$(eval $(call IMG2SPRITES,assets/Enemies/octopus_whip_right.png,0,sprite,30,22,$(PALETTE),mask,src/sprites,))

##OBJECTS
$(eval $(call IMG2SPRITES,assets/Objects/flower_100.png,0,game,16,15,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Objects/flower_75.png,0,game,6,5,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Objects/flower_50.png,0,game,6,5,$(PALETTE),mask,src/sprites,))
$(eval $(call IMG2SPRITES,assets/Objects/flower_25.png,0,game,6,5,$(PALETTE),mask,src/sprites,))

$(eval $(call IMG2SPRITES,assets/Objects/bala.png,0,sprite,6,5,$(PALETTE),mask,src/sprites,))

##MAP
$(eval $(call IMG2SPRITES,assets/Maps/tiles.png,0,g,4,4,$(PALETTE),tileset,src/sprites,))
