    .zp
_str     .ds 2
_str_len .ds 1
_str_x   .ds 2
_str_y   .ds 1

    .code
;;
;; Load 16x16 sprite font data and palette.
;;
;; Parameters:
;;      _si : Sprite font address
;;      _bl : Sprite font bank
;;      _di : VRAM address
;;      _dx : Sprite data size
;;      _cl : Sprite palette index
;;      _ax : Sprite palette size
;;
sprite_font.load:
    ; Save mpr 5 and 6
    tma    #6
    pha
    tma    #5
    pha

    ; Map data
    lda    <_bl
    tam    #5
    inc    A
    tam    #6

    ; "Upload" sprite data
    vdc_reg  #VDC_MAWR
    vdc_data <_di
    vdc_reg  #VDC_DATA
    memcpy_mode #SOURCE_INC_DEST_ALT
    memcpy_args <_si, #video_data, <_dx
    jsr    memcpy

    addw   <_dx, <_si
    ; and its palette.
    stz    <_ch
    
    asl    <_cl
    rol    <_ch
    asl    <_cl
    rol    <_ch
    asl    <_cl
    rol    <_ch
    asl    <_cl
    rol    <_ch
    addw   #$100, <_cl
    stw    <_cl, color_reg
    memcpy_mode #SOURCE_INC_DEST_ALT
    memcpy_args <_si, #color_data, <_ax
    jsr    memcpy

    ; VRAM->SATB dma
    st0    #$0f     ; Enable VRAM SATB DMA
    st1    #$10 
    st2    #$00

    st0 #VDC_SATB_SRC
    st1 #low($7000)
    st2 #high($7000)

    ; Restore mpr 5 and 6
    pla
    tam    #5
    pla
    tam    #6
    rts

LINE_OFFSET = 18 
CHAR_OFFSET = 16
SPACE = $fe
NEWLINE = $ff

;;
;; Parameters:
;;      _di : VRAM address
;;      _str : text pointer
;;      _str_len : text length
;;      _str_x : X position of the 1st letter
;;      _str_y : Y position of the 1st letter
;;
sprite_font.render:
    vdc_reg #VDC_MAWR
    vdc_data <_di
    vdc_reg #VDC_DATA

    cly
@l0:
    lda    [_str], Y
    cmp    #NEWLINE
    beq    @newline
    cmp    #SPACE
    beq    @space

@char:
    tax

    ; y
    lda    <_str_y
    clc
    adc    #64
    sta    video_data_l
    cla
    rol    A
    sta    video_data_h

    ; x
    lda    <_str_x
    clc
    adc    #64
    sta    video_data_l
    cla
    rol    A
    sta    video_data_h

    lda    <_str_x
    clc
    adc    #CHAR_OFFSET
    sta    <_str_x

    ; sprite pattern
    lda    spr_offset.lo, X
    sta    video_data_l
    
    lda    spr_offset.hi, X
    sta    video_data_h
  
    ; size etc..
    st1    #$00
    st2    #$00

    iny
    cpy    <_str_len
    bne    @l0
    rts

@space:
    lda    <_str_x
    clc
    adc    #CHAR_OFFSET
    sta    <_str_x
    iny
    cpy    <_str_len
    bne    @l0
    rts

@newline:
    lda    <_str_x+1
    sta    <_str_x

    lda    <_str_y
    clc
    adc    #LINE_OFFSET
    sta    <_str_y
    iny
    cpy    <_str_len
    bne    @l0
    rts

spr_offset.lo:
    .dwl $170, $172, $174, $176, $178, $17a, $17c, $17e
    .dwl $180, $182, $184, $186, $188, $18a, $18c, $18e
    .dwl $190, $192, $194, $196, $198, $19a, $19c, $19e
    .dwl $1a0, $1a2, $1a4, $1a6, $1a8, $1aa, $1ac, $1ae
    .dwl $1b0, $1b2, $1b4, $1b6, $1b8, $1ba, $1bc, $1be
spr_offset.hi:
    .dwh $170, $172, $174, $176, $178, $17a, $17c, $17e
    .dwh $180, $182, $184, $186, $188, $18a, $18c, $18e
    .dwh $190, $192, $194, $196, $198, $19a, $19c, $19e
    .dwh $1a0, $1a2, $1a4, $1a6, $1a8, $1aa, $1ac, $1ae
    .dwh $1b0, $1b2, $1b4, $1b6, $1b8, $1ba, $1bc, $1be
