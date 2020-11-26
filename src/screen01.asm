    .code
screen01_init:
    stw    #000, <_txt_y_start
    stw    #248, <_txt_x_start
    stb    #8, <_v
    
    lda    #1
    tam    #2
    
    ldx    <_txt
    lda    strings_lo, X
    sta    <_start
    lda    strings_hi, X
    sta    <_start+1
    
    inx
    cpx    #txt_count
    bne    .store
        clx
.store:
    stx    <_txt
    
    rts

screen01_update:
    ; scroll
    st0    #VDC_BXR
    stw    <_scroll_x, video_data

    st0    #VDC_BYR
    stw    <_scroll_y, video_data

    addw   #2, <_scroll_x
    subw   #2, <_scroll_y

    lda    <_scroll_y+1 
    cmp    #$ff
    bne    .no_reset
        stw   #MAIN_LINE_Y1, <_scroll_y
        stw   #MAIN_LINE_X1, <_scroll_x
.no_reset:
    lda    <_txt_y_start+1
    cmp    #$01
    bne    .reset
        lda    [_start]
        cmp    #$ff
        beq    .l0
            incw   <_start
.l0:        
        dec    <_dt
        dec    <_dt
        dec    <_dt
        
        lda    <_txt_x_start
        clc
        adc    <_v
        sta    <_txt_x_start
        lda    <_txt_x_start+1
        adc    #$00
        sta    <_txt_x_start+1

        lda    <_txt_y_start
        sec
        sbc    <_v
        sta    <_txt_y_start
        lda    <_txt_y_start+1
        sbc    #$00
        sta    <_txt_y_start+1
.reset:

    ; update SATB
    st0    #VDC_MAWR
    st1    #low(SATB_VRAM_ADDR)
    st2    #high(SATB_VRAM_ADDR)

    st0    #VDC_DATA

    stw    <_start, <_ptr

    dec    <_dt
    dec    <_dt
    
    decw   <_txt_x_start
    incw   <_txt_y_start

    stw    <_txt_x_start, <_txt_x
    stw    <_txt_y_start, <_txt_y

    ldx    <_dt
    cly
.loop:
    lda    cos_tbl, X
    dex
    dex
    dex
    clc
    adc    #64                                  ; [todo] adjust sine table computation
    lsr    A
    sta    <_cl
    
    ; y
    lda    <_txt_y
    clc
    adc    <_cl
    sta    video_data_l
    lda    <_txt_y+1
    adc    #$00
    sta    video_data_h
    
    ; x
    lda    <_txt_x
    clc
    adc    <_cl
    sta    video_data_l
    lda    <_txt_x+1
    adc    #$00
    sta    video_data_h
        
    lda    [_ptr]
    cmp    #$ff
    beq    .chr
        incw   <_ptr
.chr:
    asl    A
    stz    <_cl
    rol    <_cl
    
    ; pattern index
    adc    #low(SPRITE_VRAM_ADDR>>5)
    sta    video_data_l
    lda    <_cl
    adc    #high(SPRITE_VRAM_ADDR>>5)
    sta    video_data_h
    
    ; palette index + priority
    lda    #$00
    cpx    #$80
    bcc    .behind
        lda   #$80
.behind:
    sta    video_data_l
    lda    #$00
    sta    video_data_h
    
    lda    <_txt_x
    clc
    adc    <_v
    sta    <_txt_x
    lda    <_txt_x+1
    adc    #$00
    sta    <_txt_x+1

    lda    <_txt_y
    sec
    sbc    <_v
    sta    <_txt_y
    lda    <_txt_y+1
    sbc    #$00
    sta    <_txt_y+1

    iny
    cpy    #32
    bne    .loop
    
    rts
