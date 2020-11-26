TORUS_VDC_CONFIG = (VDC_CR_BG_ENABLE | VDC_CR_SPR_ENABLE | VDC_CR_VBLANK_ENABLE | VDC_CR_HBLANK_ENABLE)
TORUS_VRAM_ADDR = $4400
LOGO_VRAM_ADDR = $2100
SATB_ADDR = $7e00

    .zp
torus.index .ds 1
torus.ptr .ds 2

    .code
reverse_xor:
    .db $ff,$7f,$bf,$3f,$df,$5f,$9f,$1f,$ef,$6f,$af,$2f,$cf,$4f,$8f,$0f
    .db $f7,$77,$b7,$37,$d7,$57,$97,$17,$e7,$67,$a7,$27,$c7,$47,$87,$07
    .db $fb,$7b,$bb,$3b,$db,$5b,$9b,$1b,$eb,$6b,$ab,$2b,$cb,$4b,$8b,$0b
    .db $f3,$73,$b3,$33,$d3,$53,$93,$13,$e3,$63,$a3,$23,$c3,$43,$83,$03
    .db $fd,$7d,$bd,$3d,$dd,$5d,$9d,$1d,$ed,$6d,$ad,$2d,$cd,$4d,$8d,$0d
    .db $f5,$75,$b5,$35,$d5,$55,$95,$15,$e5,$65,$a5,$25,$c5,$45,$85,$05
    .db $f9,$79,$b9,$39,$d9,$59,$99,$19,$e9,$69,$a9,$29,$c9,$49,$89,$09
    .db $f1,$71,$b1,$31,$d1,$51,$91,$11,$e1,$61,$a1,$21,$c1,$41,$81,$01
    .db $fe,$7e,$be,$3e,$de,$5e,$9e,$1e,$ee,$6e,$ae,$2e,$ce,$4e,$8e,$0e
    .db $f6,$76,$b6,$36,$d6,$56,$96,$16,$e6,$66,$a6,$26,$c6,$46,$86,$06
    .db $fa,$7a,$ba,$3a,$da,$5a,$9a,$1a,$ea,$6a,$aa,$2a,$ca,$4a,$8a,$0a
    .db $f2,$72,$b2,$32,$d2,$52,$92,$12,$e2,$62,$a2,$22,$c2,$42,$82,$02
    .db $fc,$7c,$bc,$3c,$dc,$5c,$9c,$1c,$ec,$6c,$ac,$2c,$cc,$4c,$8c,$0c
    .db $f4,$74,$b4,$34,$d4,$54,$94,$14,$e4,$64,$a4,$24,$c4,$44,$84,$04
    .db $f8,$78,$b8,$38,$d8,$58,$98,$18,$e8,$68,$a8,$28,$c8,$48,$88,$08
    .db $f0,$70,$b0,$30,$d0,$50,$90,$10,$e0,$60,$a0,$20,$c0,$40,$80,$00

torus.pal.0:
    RGB_dw 0,0,0 
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0 
    RGB_dw 0,0,0
    RGB_dw 0,0,0 
torus.pal.1:
    RGB_dw 0,0,0 
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0 
    RGB_dw 1,0,1 
    RGB_dw 1,0,1 
    RGB_dw 0,0,0
torus.pal.2:
    RGB_dw 0,0,0 
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 1,0,1 
    RGB_dw 1,1,1 
    RGB_dw 1,1,1 
    RGB_dw 1,0,1 
    RGB_dw 0,0,0
torus.pal.3:
    RGB_dw 0,0,0 
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 1,0,1
    RGB_dw 1,1,1 
    RGB_dw 2,1,2 
    RGB_dw 2,1,2 
    RGB_dw 1,1,1 
    RGB_dw 1,0,1
    RGB_dw 0,0,0
torus.pal.4:
    RGB_dw 0,0,0 
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 1,0,1
    RGB_dw 1,1,1
    RGB_dw 2,1,2 
    RGB_dw 2,1,2 
    RGB_dw 2,1,2 
    RGB_dw 2,1,2 
    RGB_dw 1,1,1
    RGB_dw 1,0,1
    RGB_dw 0,0,0
torus.pal.5:
    RGB_dw 0,0,0 
    RGB_dw 0,0,0
    RGB_dw 0,0,0
    RGB_dw 1,0,1
    RGB_dw 1,1,1
    RGB_dw 2,1,2
    RGB_dw 2,1,2 
    RGB_dw 2,2,2 
    RGB_dw 2,2,2 
    RGB_dw 2,1,2 
    RGB_dw 2,1,2
    RGB_dw 1,1,1
    RGB_dw 1,0,1
    RGB_dw 0,0,0
torus.pal.6:
    RGB_dw 0,0,0 
    RGB_dw 0,0,0
    RGB_dw 1,0,1
    RGB_dw 1,1,1
    RGB_dw 2,1,2
    RGB_dw 2,1,2
    RGB_dw 2,2,2 
    RGB_dw 2,2,2 
    RGB_dw 2,2,2 
    RGB_dw 2,2,2 
    RGB_dw 2,1,2
    RGB_dw 2,1,2
    RGB_dw 1,1,1
    RGB_dw 1,0,1
    RGB_dw 0,0,0 
    RGB_dw 0,0,0 

torus.pal.lo:
    .dwl torus.pal.0, torus.pal.1, torus.pal.2, torus.pal.3, torus.pal.4, torus.pal.5, torus.pal.6, torus.pal.6      
torus.pal.hi:
    .dwh torus.pal.0, torus.pal.1, torus.pal.2, torus.pal.3, torus.pal.4, torus.pal.5, torus.pal.6, torus.pal.6  
    
torus_init:
    sei
    
    vdc_reg  #VDC_CR
    vdc_data #0

    jsr    vdc_xres_512
    
    st0    #VDC_BXR
    st1    #$00
    st2    #$00
    
    st0    #VDC_BYR
    st1    #$00
    st2    #$00
    
    lda    #VDC_BG_32x32
    jsr    vdc_set_bat_size
        
    lda    #bank(ds_logo.gfx)
    tam    #$04
    inc    A
    tam    #$05

    vdc_reg  #VDC_MAWR
    vdc_data #LOGO_VRAM_ADDR
    
    vdc_reg  #VDC_DATA
    tia    ds_logo.gfx, video_data, ds_logo.size

    stw    #$100, color_reg
    tia    ds_logo.pal, color_data, 32

    jsr    torus_bat
    
    jsr    vgm_update
    
    jsr    vdc_xres_256


    st0    #$0f     ; Enable VRAM SATB DMA
    st1    #$10 
    st2    #$00
    
    st0    #$13
    st1    #low(SATB_ADDR)
    st2    #high(SATB_ADDR)

    stwz   <_cx
    jsr    torus_satb
    ; clear the rest of the satb
    ldx    #25
    st1    #$00
.satb_clear:
    st2    #$00
    inx
    cpx    #64
    bne    .satb_clear

    vdc_reg  #VDC_CR
    vdc_data #TORUS_VDC_CONFIG

    irq_enable_vec #VSYNC
    irq_set_vec #VSYNC, #vsync_callback

    irq_enable_vec #HSYNC
    irq_set_vec #HSYNC, #hsync_callback

    cli
    rts

torus_bat:
    stw    #(TORUS_VRAM_ADDR>>4), <_si
    stw    #$0000, <_di

    ldx    #32
.l2:
    jsr    vdc_set_write
    addw   vdc_bat_width, <_di
    
    ldy    #32
.l3:
    stw    <_si, video_data
    incw   <_si
    
    dey
    bne    .l3
        
    dex
    bne    .l2

    stz    <torus.index
    rts

torus_satb:
    lda    <_off+1
    clc
    adc    #$09
    sta    <_off+1
    tay
    lda    sin_tbl, Y
    cmp    #$80
    stz    <_ch
    bcc    .pos
        dec    <_ch
.pos:
    ror    A
    cmp    #$80
    ror    A
    cmp    #$80
    ror    A
    cmp    #$80
    ror    A
    sta    <_cl
    
    st0    #VDC_MAWR
    st1    #low(SATB_ADDR)
    st2    #high(SATB_ADDR)

    st0    #VDC_DATA
    
    
    lda    #low(64+120-80)
    clc
    adc    <_cl
    sta    <_al
    lda    <_ch
    adc    #high(64+120-80)
    sta    <_ah
    
    stw    #(LOGO_VRAM_ADDR / 32), <_si
    
    cly
.ly:
    stw    #(32+128-80), <_bx

    clx
.lx:
    ; y
    stw    <_ax, video_data
    
    ; x
    lda    <_bl
    sta    video_data_l
    clc
    adc    #32
    sta    <_bl
    lda    <_bh
    sta    video_data_h
    adc    #0
    sta    <_bh
        
    ; pattern index
    lda    <_si
    sta    video_data_l
    clc
    adc    #8
    sta    <_si
    lda    <_si+1
    sta    video_data_h
    adc    #0
    sta    <_si+1
    
    ; palette index + priority
    st1    #$80
    ; sprite size + flip
    lda    #(SPRITE_WIDTH_32 | SPRITE_HEIGHT_32)
    sta    video_data_h

    inx
    cpx    #5
    bne    .lx
    
    addw   #32, <_ax
    
    iny
    cpy    #5
    bne    .ly

    rts

torus_update.1:
    incw   <_frame    
torus_update:
    jsr    torus_satb

torus_cycle:    
    stwz   color_reg
    ldy    <torus.index
    ldx    #16
.l0:
    tya
    and    #31
    tay
    
    lda    [torus.ptr], Y
    sta    color_data
    iny
    
    lda    [torus.ptr], Y
    sta    color_data+1
    iny
        
    dex
    bne   .l0
    
    inc    <torus.index
    inc    <torus.index

    rts
    
torus_load_gfx:
    vdc_reg  #VDC_MAWR
    vdc_data #TORUS_VRAM_ADDR

    lda    #bank(torus)
    tam    #$04
    inc    A
    tam    #$05
        
    vdc_reg  #VDC_DATA
    tia    torus, video_data, torus.size

    stw    #(torus + torus.size - 32), <_si
    stw    #(torus.size / 32), <_ax
.l0:
    ldy    #14  
.l1:
    lda    [_si], Y
    tax
    lda    reverse_xor, X
    sta    video_data_l
    iny
    
    lda    [_si], Y
    tax
    lda    reverse_xor, X
    sta    video_data_h
    
    dey
    dey
    dey
    bpl    .l1
    
    ldy    #30
.l11:
    lda    [_si], Y
    tax
    lda    reverse_xor, X
    sta    video_data_l
    iny
    
    lda    [_si], Y
    tax
    lda    reverse_xor, X
    sta    video_data_h
    
    dey
    dey
    dey
    cpy    #14
    bne    .l11
    
    subw   #32, <_si
    
    lda    <_al
    sec
    sbc    #$01
    sta    <_al
    lda    <_ah
    sbc    #$00
    sta    <_ah
    ora    <_al
    bne    .l0

    rts