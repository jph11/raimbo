#include "hero_pistol.h"
// Data created with Img2CPC - (c) Retroworks - 2007-2015
// Palette uses hardware values.
const u8 sprite_palette[16] = { 0x54, 0x44, 0x5c, 0x4c, 0x45, 0x56, 0x5e, 0x40, 0x5f, 0x4e, 0x47, 0x52, 0x42, 0x4a, 0x43, 0x4b };

// Tile sprite_hero_pistol: 18x25 pixels, 9x25 bytes.
const u8 sprite_hero_pistol[2 * 9 * 25] = {
	0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0x55, 0x20, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0xff, 0x00, 0xaa, 0x01, 0x00, 0x03, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0xff, 0x00, 0x00, 0xc0, 0x00, 0xc0, 0x55, 0x80, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0xaa, 0x01, 0x00, 0x03, 0x00, 0x03, 0x00, 0x03, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0x00, 0xf0, 0x00, 0xf0, 0x00, 0xf0, 0x00, 0xf0, 0x55, 0xa0, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00,
	0xaa, 0x51, 0x00, 0xf3, 0x00, 0xf3, 0x00, 0xf3, 0x00, 0xf3, 0x00, 0xf3, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00,
	0x00, 0x73, 0x00, 0xc3, 0x00, 0xc3, 0x00, 0xc3, 0x00, 0xc3, 0x00, 0xc3, 0x55, 0x82, 0xff, 0x00, 0xff, 0x00,
	0x00, 0x73, 0x00, 0xc6, 0x00, 0xcc, 0x00, 0xcc, 0x00, 0xcc, 0x00, 0xcc, 0x55, 0x88, 0xff, 0x00, 0xff, 0x00,
	0x00, 0x73, 0x00, 0xc6, 0x00, 0x3f, 0x00, 0x3f, 0x00, 0x3f, 0x00, 0x3f, 0x55, 0x08, 0xff, 0x00, 0xff, 0x00,
	0x00, 0x73, 0x00, 0xc6, 0x00, 0x3f, 0x00, 0x3f, 0x00, 0x3f, 0x00, 0x3f, 0x55, 0x08, 0xff, 0x00, 0xff, 0x00,
	0x00, 0x26, 0x00, 0x4c, 0x00, 0x3f, 0x00, 0x3f, 0x00, 0x3f, 0x00, 0x3f, 0x55, 0x08, 0xff, 0x00, 0xff, 0x00,
	0x00, 0x26, 0x00, 0x6e, 0x55, 0x2a, 0x00, 0x3f, 0x00, 0x3f, 0x55, 0x2a, 0x55, 0x08, 0xff, 0x00, 0xff, 0x00,
	0x00, 0x26, 0x00, 0x4c, 0x00, 0x3f, 0x00, 0x2e, 0x00, 0x0c, 0x00, 0x3f, 0x55, 0x08, 0xff, 0x00, 0xff, 0x00,
	0xaa, 0x04, 0x00, 0x3f, 0x00, 0x3f, 0x00, 0x3f, 0x00, 0x3f, 0x00, 0x3f, 0x55, 0x08, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0x00, 0x0c, 0x00, 0x0c, 0x00, 0x0c, 0x00, 0x0c, 0x00, 0x0c, 0xff, 0x00, 0xff, 0x00, 0x55, 0x08,
	0xff, 0x00, 0xff, 0x00, 0xaa, 0x14, 0x00, 0x0c, 0x00, 0x1c, 0xaa, 0x54, 0x00, 0xac, 0x00, 0x5c, 0x00, 0xfc,
	0xff, 0x00, 0x00, 0x3c, 0xaa, 0x14, 0x00, 0x3d, 0x00, 0x3e, 0xaa, 0x54, 0x00, 0x5c, 0x00, 0xfc, 0x00, 0xfc,
	0xaa, 0x14, 0x00, 0x0c, 0xff, 0x00, 0x00, 0x3c, 0x00, 0x3c, 0x00, 0x0c, 0x55, 0x08, 0x00, 0x0c, 0x55, 0x08,
	0xaa, 0x04, 0x00, 0x3f, 0x55, 0x08, 0x00, 0x3c, 0x00, 0x3c, 0x00, 0x2e, 0xaa, 0x04, 0x55, 0x08, 0xff, 0x00,
	0xaa, 0x04, 0x00, 0x3f, 0x55, 0x08, 0x00, 0x3c, 0x00, 0x3c, 0x55, 0x08, 0x00, 0x1d, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0x00, 0x0c, 0xaa, 0x14, 0x00, 0x3c, 0x00, 0x3c, 0x00, 0x0c, 0x55, 0x2a, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0xff, 0x00, 0x00, 0xbc, 0x00, 0x3c, 0x00, 0x7c, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0xff, 0x00, 0x00, 0xfc, 0x00, 0x3c, 0x00, 0xfc, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0xff, 0x00, 0x00, 0xfc, 0xaa, 0x41, 0x00, 0xfc, 0xaa, 0x41, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00,
	0xff, 0x00, 0xff, 0x00, 0x00, 0x3f, 0x55, 0x2a, 0x00, 0x3f, 0x55, 0x2a, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00
};

