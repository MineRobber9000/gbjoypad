INCLUDE "gbhw.inc"
INCLUDE "ibmpc1.inc"
; rst vectors
SECTION "rst00",ROM0[0]
	ret

SECTION "rst08",ROM0[8]
	ret

SECTION "rst10",ROM0[$10]
	ret

SECTION "rst18",ROM0[$18]
	ret

SECTION "rst20",ROM0[$20]
	ret

SECTION "rst30",ROM0[$30]
	ret

SECTION "rst38",ROM0[$38]
	ret

SECTION "vblank",ROM0[$40]
	jp VBlank
SECTION "lcdc",ROM0[$48]
	reti
SECTION "timer",ROM0[$50]
	reti
SECTION "serial",ROM0[$58]
	reti
SECTION "joypad",ROM0[$60]
	reti

SECTION "signature",ROM0[$80]
	db "MineRobber9000"

SECTION "romheader",ROM0[$100]
	nop
	jp Start

Section "start",ROM0[$150]

Start:
	xor a
	ld [rIE],a ; disable all interrupts
	ei ; Set IME=1 so when we allow interrupts later, VBlank will be serviced
	ld hl,$c000
	ld bc,$2000
	xor a
	call fillmem
	call StopLCD
	ld a,%11100100
	ld [rBGP],a
	ld a,$00
	ld [rSCX],a
	ld [rSCY],a
	ld hl,FontTiles
	ld de,_VRAM
	ld bc,256*16
	call memcpy
	ld a,32
	ld hl,_SCRN0
	ld bc,SCRN_VX_B * SCRN_VY_B
	call fillmem
	ld hl,TextStart
	ld de,_SCRN0
	ld bc,StartEnd-TextStart
	call memcpy
	call DisplayJoypadState
	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJOFF
	ld [rLCDC],a
	ld a,$01
	ld [rIE],a
.loop
	halt
	jr .loop

VBlank:
	call DisplayJoypadState
	reti ; TODO: implement joypad checking and updated button state

StopLCD:
	ld a,[rLCDC]
	rlca
	ret nc
.wait	ld a,[rLY]
	cp 145
	jr nz,.wait
	ld a,[rLCDC]
	res 7,a
	ld [rLCDC],a
	ret

puthex:
	push af
	swap a
	and $0F
	call putnibble
	pop af
	and $0F
putnibble:
	cp $0A
	jr c,.not_letter
	add ("A"-"9"-1)
.not_letter:
	add "0"
	ld [hl+],a
	ret

DisplayJoypadState:
	push hl
	ld hl, _SCRN0+(StartEnd-TextStart)
	ld a,[wCurrentJoypadState]
	call puthex
	pop hl
	ret

TextStart:
	db "Joypad: "
StartEnd:

FontTiles:
	chr_IBMPC1 1,8
