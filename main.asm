INCLUDE "hardware.inc"
INCLUDE "ibmpc1.inc"
; rst vectors
SECTION "RST Handlers",ROM0[$0000]
fillmem equ $00
_fillmem:
    inc b
    inc c
    jr .skip
.loop
    ld [hli], a
.skip
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop
    ret
    ds 4

memcpy equ $10
_memcpy:
    inc b
    inc c
    jr .skip
.loop
    ld a, [hli]
    ld [de], a
    inc de
.skip
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop
    ret
    ds 2

REPT 4
    ret
    ds 7
ENDR

VBlank: ; VBlank handler here
    call Joypad
    call DisplayJoypadState
    ldh a, [hSendByLinkCable]
    rra ; Bit 0 into carry
    ldh a, [hCurrentJoypadState]
    call nc, SendByte
    reti



; Transfers byte from a out through serial port. Z flag is set if result == $FF (peripheral should hold its TX line low so result will == $00)
SendByte:
    ld [rSB], a
    ld a, $81
    ld [rSC], a
.loop
    ld a, [rSC]
    add a, a
    jr c, .loop
    ld a, [rSB]
    inc a ; Return result in Z flag
    ret

Joypad:
    ld c, LOW(rP1)
    ld a, $20
    call .dohalf
    swap a
    ld b, a
    ld a, $10
    call .dohalf
    xor b
    ldh [hCurrentJoypadState],a
    ret

.dohalf
    ld [$ff00+c],a
REPT $03 ; number taken from Aevilia (ISSOtm's RPG) since it seems to work
    ld a,[$ff00+c]
ENDR
    or $F0
    ret

DisplayJoypadState:
; I started work on this but decided to implement joypad checking first :P
;    ld hl, hJoypadOutputString
;    ld bc, $08
;    xor a
;    rst fillmem
;    ld hl, wJoypadOutputString
;    ld a, [wCurrentJoypadState]
    ld hl, _SCRN0 + JoypadTextEnd - JoypadText
    ldh a, [hCurrentJoypadState]
    ; Fallthrough to PrintHex

PrintHex:
    ld b, a
    swap a
    and $0F
    call .nibble
    ld a, b
    and $0F

.nibble
    cp 10
    jr c, .not_letter
    add a, "A" - "0" - 10
.not_letter
    add a, "0"
    ld [hl+], a
    ret

StopLCD:
    ld a, [rLCDC]
    rlca
    ret nc
.wait
    ld a, [rLY]
    cp SCRN_Y
    jr c, .wait
    xor a
    ld [rLCDC], a
    ret


SECTION "ROM header",ROM0[$100]
    di
    xor a
    jr Start

REPT $150 - $104
    db 0
ENDR
    db "MineRobber9000"

Start:
    ld hl, _RAM
    ld bc, $2000
    rst fillmem

    call StopLCD
    ; xor a ; init scroll registers
    ld [rSCX], a
    ld [rSCY], a
    ld a, %11100100 ; Set palette
    ld [rBGP], a
    ld hl, FontTiles ; load font into VRAM
    ld de, _VRAM
    ld bc, 256 * 16
    rst memcpy
    ld a, " " ; blank out screen
    ld hl, _SCRN0
    ld bc, SCRN_VX_B * SCRN_VY_B
    rst fillmem
    ld de, _SCRN0
    ld hl, JoypadText ; add "Joypad:" text to the screen
    ld bc, JoypadTextEnd - JoypadText
    rst memcpy

    call DisplayJoypadState ; display beginning state
    ld a, LCDCF_ON | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ16 | LCDCF_OBJOFF ; turn on screen
    ld [rLCDC], a
    xor a
    call SendByte
    jr nz, .assign
    dec a
.assign
    ldh [hSendByLinkCable], a
    ld a, IEF_VBLANK
    ld [rIE],a
    ei

.loop
    halt
    jr .loop

JoypadText:
    db "Joypad: "
JoypadTextEnd:

FontTiles:
    chr_IBMPC1 1,8

