SCR02_VDC_CONFIG = (VDC_CR_BG_ENABLE | VDC_CR_VBLANK_ENABLE | VDC_CR_HBLANK_ENABLE)

; sprite_font_size = a00

    .zp
_delay   .ds 1
_counter .ds 1
_rcr .ds 2
_index .ds 1
_pal_index .ds 1

    .code

;             256  352  512
xres_HDS: .db $02, $03, $0B
xres_HSW: .db $02, $03, $02
xres_HDE: .db $04, $06, $04
xres_HDW: .db $1f, $2b, $3f
xres_CLK: .db $00, $01, $02

xres_inc_lo: .dwl 256, 352, 512
xres_inc_hi: .dwh 256, 352, 512

xres_sx_lo: .dwl 256+128, 256+128-44-6, 256 
xres_sx_hi: .dwh 256+128, 256+128-44-6, 256 

xres_sy_lo: .dwl 512-116+20, 512-116*352/256+20, 512-116*2+20
xres_sy_hi: .dwh 512-116+20, 512-116*352/256+20, 512-116*2+20

xres_index: .db 2, 1, 0, 1, 2

logo.half_width: .db 112, 32, 52, 40, 96

ZOOM_IN_DELAY = 10
ZOOM_COUNT = 5

logo.pal.index:
    .db 0, 2, 2, 2, 3, 3, 3, 4, 4, 4
    .db 5, 5, 5, 6, 6, 6, 7, 7, 7, 8
    .db 8, 8, 8, 8, 8, 8, 8, 8, 8, 7
    .db 7, 7, 6, 6, 6, 5, 5, 5, 4, 4
    .db 4, 3, 3, 3, 2, 2, 2, 1, 1, 0

logo.pal.lo:
    .dwl $000, $000, $000, $000, $000, $000, $000, $000
    .dwl $000, $049, $092, $0db, $124, $16d, $1b6, $1ff
    .dwl $1ff
    
logo.pal.hi:
    .dwh $000, $000, $000, $000, $000, $000, $000, $000
    .dwh $000, $049, $092, $0db, $124, $16d, $1b6, $1ff
    .dwh $1ff
    
logo.set_bat:
    lda    #bank(logo.width)
    tam    #$02

    ldy    <_index
    
    lda    logo.width, Y
    sta    <_cl
    
    lda    logo.bat.lo, Y
    sta    <_si
    lda    logo.bat.hi, Y
    sta    <_si+1

    stw    #$0000, <_di
    
    ldy    #logo.height
.l0:
    jsr    vdc_set_write
    addw   vdc_bat_width, <_di
    
    clx
.l1:
    stw    <_si, video_data
    incw   <_si

    inx
    cpx    <_cl
    bne    .l1

    st1    #$00
.l2:
    st2    #$02
    inx
    cpx    #32
    bne    .l2
    
    dey
    bne    .l0
    rts

  .macro logo.set_col
    lda    logo.pal.lo+\1, Y
    sta    color_data_lo
    lda    logo.pal.hi+\1, Y
    sta    color_data_hi
  .endm
  
logo.set_pal:
    stwz   color_reg
    
    ldx    <_pal_index
    ldy    logo.pal.index, X
    logo.set_col 0
    logo.set_col 1
    logo.set_col 2
    logo.set_col 3
    logo.set_col 4
    logo.set_col 5
    logo.set_col 6
    logo.set_col 7
    logo.set_col 8
    logo.set_col 9
    logo.set_col 10
    logo.set_col 11
    logo.set_col 12
    logo.set_col 13
    logo.set_col 14
    logo.set_col 15

    rts

screen02_init:
    sei
    lda    #VDC_BG_64x64
    jsr    vdc_set_bat_size

    jsr    clear_bat

    stz    <_counter    
    stz    <_pal_index
    stb    #ZOOM_IN_DELAY, <_delay
    jsr    logo.set_pal

    jsr    dma_wait

    vdc_reg  #VDC_MAWR
    vdc_data #$2000

    vdc_reg  #VDC_DATA
    st1    #$00
    ldx    #$10
.clear_tile0:
    st2    #$00
    dex
    bne    .clear_tile0
        
    vdc_reg  #VDC_MAWR
    vdc_data #$2010
    
    vdc_reg  #VDC_DATA
        
    lda    #bank(logo.gfx)
    tam    #$04
    inc    A
    tam    #$05

    tia    logo.gfx, video_data, logo.size

    stz    <_index
    jsr    logo.set_bat

    vdc_reg  #VDC_CR
    vdc_data #SCR02_VDC_CONFIG
        
    irq_enable_vec #VSYNC
    irq_set_vec #VSYNC, #screen02_vsync_callback

    irq_enable_vec #HSYNC
    irq_set_vec #HSYNC, #screen02_hsync_callback
    
    cli
    
    jsr    zoom_in
    rts

screen02_end.01:
    stw    #$01, <_frame
    rts
 
screen02_update:
    ; zoom in
    dec    <_delay
    bne    screen02_end

    stb    #ZOOM_IN_DELAY, <_delay

    inc    <_counter
    lda    <_counter
    cmp    #ZOOM_COUNT
    bne    zoom_in
        stwz   <_frame
        stz    <_counter
        lda    <_index
        cmp    #(logo.count-1)
        beq    screen02_end.01
            stz    <_pal_index
            inc    <_index
            jsr    logo.set_bat
zoom_in:        
    ldy    <_counter    
    ldx    xres_index, Y
     
    st0    #VDC_HSR
    lda    xres_HSW, X
    sta    video_data_l
    lda    xres_HDS, X
    sta    video_data_h
    
    st0    #VDC_HDR
    lda    xres_HDW, X
    sta    video_data_l
    lda    xres_HDE, X
    sta    video_data_h
    
    lda    xres_CLK, X
    sta    color_ctrl
    stz    color_ctrl+1
    
    st0    #VDC_BYR
    stz    <_scroll_y
    lda    xres_sy_lo, X
    sta    <_scroll_y+1
    sta    video_data_l
    lda    xres_sy_hi, X
    sta    <_scroll_y+2
    sta    video_data_h

screen02_end:
    jsr    logo.set_pal
    inc    <_pal_index
    rts
       
screen02_vsync_callback:
    st0    #VDC_RCR
    lda    #low(VDC_RCR_START)
    sta    video_data_l
    sta    <_rcr
    lda    #high(VDC_RCR_START)
    sta    video_data_h
    sta    <_rcr+1

    st0    #VDC_BXR
    st1    #$00
    st2    #$00


    stz    <_scroll_y

    ldy    <_counter
    ldx    xres_index, Y

    st0    #VDC_BYR
    lda    xres_sy_lo, X
    sta    <_scroll_y+1
    sta    video_data_l
    lda    xres_sy_hi, X
    sta    <_scroll_y+2
    sta    video_data_h
    
    ply
    plx
    pla
    rti

screen02_hsync_callback:
    ldy    <_counter
    ldx    xres_index, Y
    clc
    lda    <_scroll_y
    adc    xres_inc_lo, X
    sta    <_scroll_y
    lda    <_scroll_y+1
    adc    xres_inc_hi, X
    sta    <_scroll_y+1
    lda    <_scroll_y+2
    adc    #$00
    sta    <_scroll_y+2

    st0    #VDC_BXR
    clc
    ldy    <_index
    lda    logo.half_width, Y
    adc    xres_sx_lo, X
    sta    video_data_l
    cla
    adc    xres_sx_hi, X
    sta    video_data_h
    
    st0    #VDC_BYR
    lda    <_scroll_y+1
    sta    video_data_l
    lda    <_scroll_y+2
    sta    video_data_h

    
    incw   <_rcr    
    st0    #VDC_RCR
    stw    <_rcr, video_data
 
    ply
    plx
    pla
    rti

