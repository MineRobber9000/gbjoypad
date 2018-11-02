INCLUDE "gbhw.inc"
INCLUDE "ibmpc1.inc"
; rst vectors
SECTION "Dummy RST Handlers",ROM0[0]
REPT 8
	ret
REPT 7
	nop
ENDR
ENDR

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
	ld hl,$c000 ; clear WRAM
	ld bc,$2000
	xor a
	call fillmem
	call StopLCD
	ld a,%11100100 ; fix palette
	ld [rBGP],a
	ld a,$00 ; init scroll registers
	ld [rSCX],a
	ld [rSCY],a
	ld hl,FontTiles ; load font into VRAM
	ld de,_VRAM
	ld bc,256*16
	call memcpy
	ld a,32 ; blank out screen
	ld hl,_SCRN0
	ld bc,SCRN_VX_B * SCRN_VY_B
	call fillmem
	ld hl,TextStart ; add "Joypad:" text to the screen
	ld de,_SCRN0
	ld bc,StartEnd-TextStart
	call memcpy
	call DisplayJoypadState ; display beginning state
	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJOFF ; turn on screen
	ld [rLCDC],a
	ld a,$01
	ld [rIE],a
.loop
	halt
	jr .loop

VBlank:
	call Joypad
	call SendByte
	call DisplayJoypadState
	reti

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

; Transfers byte from a out through serial port. Carry flag is set if result == $FF (peripheral should hold its TX line low so result will == $00)
SendByte:
	ld [rSB],a
	ld a,$81
	ld [rSC],a
.loop	ld a,[rSC]
	bit 7,a
	jr nz,.loop
	ld a,[rSB]
	cp $FF
	jr nz,.c
	scf
	jr .end
.c	ccf
.end	ret

Joypad:
	ld a, $20
	call .dohalf
	swap a
	push af
	ld a, $10
	call .dohalf
	ld b, a
	pop af
	or a,b
	cpl
	ld [wCurrentJoypadState],a
	ret
.dohalf	ld [rP1],a
REPT $03 ; number taken from Aevilia (ISSOtm's RPG) since it seems to work
	ld a,[rP1]
ENDR
	and $0F
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
	push bc
	push af
; I started work on this but decided to implement joypad checking first :P
;	ld hl, wJoypadOutputString
;	ld bc, $08
;	xor a
;	call fillmem
;	ld hl, wJoypadOutputString
;	ld a,[wCurrentJoypadState]
	ld hl, _SCRN0+(StartEnd-TextStart)
	ld a,[wCurrentJoypadState]
	call puthex
	pop af
	pop bc
	pop hl
	ret

TextStart:
	db "Joypad: "
StartEnd:

FontTiles:
	chr_IBMPC1 1,8
