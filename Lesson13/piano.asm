.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

; Zero Page
ZP_PTR            = $30

; RAM Interrupt Vectors
IRQVec            = $0314

; VERA
VERA_addr_low     = $9F20
VERA_addr_high    = $9F21
VERA_addr_bank    = $9F22
VERA_data0        = $9F23
VERA_ctrl         = $9F25
VERA_ien          = $9F26
VERA_isr          = $9F27
VSYNC_BIT         = $01
VERA_dc_hscale    = $9F2A
VERA_dc_vscale    = $9F2B
DISPLAY_SCALE     = 64 ; 2X zoom

; Kernal
CHROUT            = $FFD2
GETIN             = $FFE4


; VRAM Addresses
CONTROLS_VRAM     = $00200
KEYS_VRAM         = $00C00
VRAM_psg          = $1F9C0
PULSE_CHAN_VRAM   = VRAM_psg
ST_CHAN_VRAM      = VRAM_psg+4
TRI_CHAN_VRAM     = VRAM_psg+8
NOISE_CHAN_VRAM   = VRAM_psg+12

; --- PSG Values ---
; Frequencies:
C4                = 702
Db4               = 744
D4                = 788
Eb4               = 835
E4                = 885
F4                = 937
Gb4               = 993
G4                = 1052
Ab4               = 1115
A4                = 1181
Bb4               = 1251
B4                = 1326
C5                = 1405
; RL-Volume:
CHANNEL_ON        = $FF ; L&R, max volume
CHANNEL_OFF       = $00
; Waveform:
PULSE             = $3F
SAWTOOTH          = $7F
TRIANGLE          = $BF
NOISE             = $FF

; PETSCII
COMMA             = $2C
CHAR_1            = $31
CHAR_Z            = $5A
CLR               = $93
LEFT_CURSOR       = $9D

.macro RAM2VRAM ram_addr, vram_addr, num_bytes, color
   .scope
      ; set data port 0 to start writing to VRAM address
      stz VERA_ctrl
      lda #($10 | ^vram_addr) ; stride = 1
      sta VERA_addr_bank
      lda #>vram_addr
      sta VERA_addr_high
      lda #<vram_addr
      sta VERA_addr_low
       ; ZP pointer = start of video data in CPU RAM
      lda #<ram_addr
      sta ZP_PTR
      lda #>ram_addr
      sta ZP_PTR+1
      ; use index pointers to compare with number of bytes to copy
      ldx #0
      ldy #0
   vram_loop:
      lda (ZP_PTR),y
      sta VERA_data0
      lda #color
      sta VERA_data0
      iny
      cpx #>num_bytes ; last page yet?
      beq check_end
      cpy #0
      bne vram_loop ; not on last page, Y non-zero
      inx ; next page
      inc ZP_PTR+1
      bra vram_loop
   check_end:
      cpy #<num_bytes ; last byte of last page?
      bne vram_loop ; last page, before last byte
   .endscope
.endmacro

controls:
.byte $20,$20,$55,$43,$43,$43,$49,$20,$20,$55,$43,$43,$43,$49,$20,$20,$55,$43,$43,$43,$49,$20,$20,$55,$43,$43,$43,$49,$20,$20,$20,$20,$20,$55,$43,$43,$43,$49,$20,$20
.res 88
.byte $20,$20,$42,$20,$20,$20,$42,$20,$20,$42,$20,$20,$20,$42,$20,$20,$42,$20,$20,$20,$42,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20
.res 88
.byte $20,$20,$42,$20,$31,$20,$42,$20,$20,$42,$20,$32,$20,$42,$20,$20,$42,$20,$33,$20,$42,$20,$20,$42,$20,$34,$20,$42,$20,$20,$20,$20,$20,$42,$20,$11,$20,$42,$20,$20
.res 88
.byte $20,$20,$42,$20,$20,$20,$42,$20,$20,$42,$20,$20,$20,$42,$20,$20,$42,$20,$20,$20,$42,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20
.res 88
.byte $20,$20,$4A,$43,$43,$43,$4B,$20,$20,$4A,$43,$43,$43,$4B,$20,$20,$4A,$43,$43,$43,$4B,$20,$20,$4A,$43,$43,$43,$4B,$20,$20,$20,$20,$20,$4A,$43,$43,$43,$4B,$20,$20
.res 88
.byte $20,$20,$10,$15,$0C,$13,$05,$20,$20,$13,$01,$17,$14,$2E,$20,$20,$14,$12,$09,$01,$2E,$20,$20,$0E,$0F,$09,$13,$05,$20,$20,$20,$20,$20,$11,$15,$09,$14,$20,$20,$20
end_controls:
CONTROLS_SIZE = end_controls-controls
CONTROLS_COLOR = $61 ; white on blue

keys:
.byte $20,$20,$20,$20,$70,$43,$43,$F8,$F8,$F8,$43,$F8,$F8,$F8,$43,$43,$72,$43,$43,$F8,$F8,$F8,$43,$F8,$F8,$F8,$43,$F8,$F8,$F8,$43,$43,$72,$43,$43,$43,$6E,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$20,$A0,$93,$A0,$20,$A0,$84,$A0,$20,$20,$42,$20,$20,$A0,$87,$A0,$20,$A0,$88,$A0,$20,$A0,$8A,$A0,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$A0,$A0,$A0,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$1A,$20,$42,$20,$18,$20,$42,$20,$03,$20,$42,$20,$16,$20,$42,$20,$02,$20,$42,$20,$0E,$20,$42,$20,$0D,$20,$42,$20,$2C,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20,$42,$20,$20,$20
.res 88
.byte $20,$20,$20,$20,$6D,$43,$43,$43,$71,$43,$43,$43,$71,$43,$43,$43,$71,$43,$43,$43,$71,$43,$43,$43,$71,$43,$43,$43,$71,$43,$43,$43,$71,$43,$43,$43,$7D,$20,$20,$20
end_keys:
KEYS_SIZE = end_keys-keys
KEYS_COLOR = $10 ; black on white

default_irq_vector: .addr 0
current_key: .byte 0
delay: .byte 0
pulse_on: .byte 0
sawtooth_on: .byte 0
triangle_on: .byte 0
noise_on: .byte 0
frequency: .word 0


; key table: value, target address
key_table:
.word C5, set_freq         ; ,
.word 0, stop              ; -
.word 0, stop              ; .
.word 0, stop              ; /
.word 0, stop              ; 0
.word pulse_on, set_wf     ; 1
.word sawtooth_on, set_wf  ; 2
.word triangle_on, set_wf  ; 3
.word noise_on, set_wf     ; 4
.word 0, stop              ; 5
.word 0, stop              ; 6
.word 0, stop              ; 7
.word 0, stop              ; 8
.word 0, stop              ; 9
.word 0, stop              ; :
.word 0, stop              ; ;
.word 0, stop              ; <
.word 0, stop              ; =
.word 0, stop              ; >
.word 0, stop              ; ?
.word 0, stop              ; @
.word 0, stop              ; A
.word G4, set_freq         ; B
.word E4, set_freq         ; C
.word Eb4, set_freq        ; D
.word 0, stop              ; E
.word 0, stop              ; F
.word 0, stop              ; G
.word Ab4, set_freq        ; H
.word 0, stop              ; I
.word Bb4, set_freq        ; J
.word 0, stop              ; K
.word 0, stop              ; L
.word B4, set_freq         ; M
.word A4, set_freq         ; N
.word 0, stop              ; O
.word 0, stop              ; P
.word quit, 0              ; Q
.word 0, stop              ; R
.word Db4, set_freq        ; S
.word 0, stop              ; T
.word 0, stop              ; U
.word F4, set_freq         ; V
.word 0, stop              ; W
.word D4, set_freq         ; X
.word 0, stop              ; Y
.word C4, set_freq         ; Z


start:
   ; scale display to 2x zoom (40x30 characters)
   lda #DISPLAY_SCALE
   sta VERA_dc_hscale
   sta VERA_dc_vscale

   ; clear screen
   lda #CLR
   jsr CHROUT

   ; Initial display
   RAM2VRAM controls, CONTROLS_VRAM, CONTROLS_SIZE, CONTROLS_COLOR
   RAM2VRAM keys, KEYS_VRAM, KEYS_SIZE, KEYS_COLOR

   ; Initialize PSG channels
   stz VERA_ctrl
   lda #($10 | ^VRAM_psg) ; stride = 1
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda #<VRAM_psg
   sta VERA_addr_low
   ; Channel 0: Pulse
   stz VERA_data0 ; freq = 0
   stz VERA_data0
   lda #CHANNEL_OFF ; turn off
   sta VERA_data0
   lda #PULSE ; set waveform
   sta VERA_data0
   ; Channel 1: Sawtooth
   stz VERA_data0 ; freq = 0
   stz VERA_data0
   lda #CHANNEL_OFF ; turn off
   sta VERA_data0
   lda #SAWTOOTH ; set waveform
   sta VERA_data0
   ; Channel 2: Triangle
   stz VERA_data0 ; freq = 0
   stz VERA_data0
   lda #CHANNEL_OFF ; turn off
   sta VERA_data0
   lda #TRIANGLE ; set waveform
   sta VERA_data0
   ; Channel 3: Noise
   stz VERA_data0 ; freq = 0
   stz VERA_data0
   lda #CHANNEL_OFF ; turn off
   sta VERA_data0
   lda #NOISE ; set waveform
   sta VERA_data0

   ; set default waveform to Pulse only
   lda #$80
   sta pulse_on
   stz sawtooth_on
   stz triangle_on
   stz noise_on

   ; clear current key
   stz current_key

   ; Initialize IRQ handling
   jsr init_irq

   ; clear screen
   lda #$20
   jsr CHROUT

main_loop:
   wai
   lda current_key
   beq stop
   cmp #(CHAR_Z + 1)
   bpl stop
   sec
   sbc #COMMA
   bcc stop
   asl
   asl
   tax ; X = key offset * 4
   ; store value in ZP_PTR
   lda key_table,x
   sta ZP_PTR
   inx
   lda key_table,x
   sta ZP_PTR+1
   ; jump to target
   inx
   jmp (key_table,x)

stop:
   jsr stop_subroutine
   jmp main_loop

stop_subroutine:
   stz VERA_ctrl
   lda #($30 | ^VRAM_psg) ; stride = 4
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda #<(VRAM_psg + 2) ; RL-Volume byte
   sta VERA_addr_low
   lda CHANNEL_OFF
   sta VERA_data0 ; turn off channel 0
   sta VERA_data0 ; turn off channel 1
   sta VERA_data0 ; turn off channel 2
   sta VERA_data0 ; turn off channel 3
   rts

.macro SET_FREQ_CHANNEL flag
   .scope
      bit flag
      bpl skip_channel
      lda ZP_PTR ; frequency, low byte
      sta VERA_data0
      lda ZP_PTR+1 ; frequency, high byte
      sta VERA_data0
      lda #CHANNEL_ON
      sta VERA_data0
      bra skip_waveform
   skip_channel:
      lda VERA_data0
      lda VERA_data0
      lda VERA_data0
   skip_waveform:
      lda VERA_data0
   .endscope
.endmacro

set_freq:
   stz VERA_ctrl
   lda #($10 | ^VRAM_psg) ; stride = 1
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda #<VRAM_psg
   sta VERA_addr_low
   SET_FREQ_CHANNEL pulse_on
   SET_FREQ_CHANNEL sawtooth_on
   SET_FREQ_CHANNEL triangle_on
   SET_FREQ_CHANNEL noise_on
   jmp main_loop

set_wf:
   jsr stop_subroutine
   lda current_key
   sec
   sbc #CHAR_1
   asl
   tax ; X = current_key offset * 2
   lda (ZP_PTR)
   eor #$80 ; toggle the high bit
   sta (ZP_PTR)
   jmp main_loop

quit:
   jsr stop_subroutine
   rts ; return to BASIC

init_irq:
   ; backup default RAM IRQ vector
   lda IRQVec
   sta default_irq_vector
   lda IRQVec+1
   sta default_irq_vector+1

   ; overwrite RAM IRQ vector with custom handler address
   sei ; disable IRQ while vector is changing
   lda #<custom_irq_handler
   sta IRQVec
   lda #>custom_irq_handler
   sta IRQVec+1
   lda #VSYNC_BIT ; make VERA only generate VSYNC IRQs
   sta VERA_ien
   cli ; enable IRQ now that vector is properly set
   rts

custom_irq_handler:
   lda VERA_isr
   and #VSYNC_BIT
   beq @continue ; non-VSYNC IRQ, no tick update
   jsr GETIN
   cmp #0
   bne @set_key
   lda delay
   beq @null
   dec delay
   bne @continue
@null:
   stz current_key
   bra @continue
@set_key:
   sta current_key
   lda #16
   sta delay
@continue:
   ; continue to default IRQ handler
   jmp (default_irq_vector)
   ; RTI will happen after jump
