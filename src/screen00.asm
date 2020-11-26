SCR00_VDC_CONFIG = (VDC_CR_BG_ENABLE | VDC_CR_SPR_ENABLE | VDC_CR_VBLANK_ENABLE)
SATB_VRAM_ADDR = $7000
SPRITE_VRAM_ADDR = $2000
MAIN_LINE_VRAM_ADDR = SPRITE_VRAM_ADDR + 32*16*2
MAIN_LINE_WIDTH = 10
MAIN_LINE_HEIGHT = 4

MAIN_LINE_X0=$0fec
MAIN_LINE_X1=$00d5

MAIN_LINE_Y0=$0108
MAIN_LINE_Y1=$001f

    .zp
_dt .ds 1
_v .ds 1

_ptr .ds 2
_start .ds 2

_txt_x_start .ds 2
_txt_y_start .ds 2

_txt_x .ds 2
_txt_y .ds 2

    .code

screen00_init:
    sei
    
    ; [todo] clear satb
        
    jsr    vdc_xres_256
    
    lda    #VDC_BG_64x64
    jsr    vdc_set_bat_size
    
    vdc_reg  #VDC_MAWR
    vdc_data #$2100
    
    vdc_reg  #VDC_DATA
    st1    #$00
    ldy    #8
.l0:
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    dey
    bne    .l0
    
    jsr    clear_bat
        
    stw    #MAIN_LINE_X0, <_scroll_x
    stw    #MAIN_LINE_Y0, <_scroll_y

    ; load tiles
    stw    #MAIN_LINE_VRAM_ADDR, <_di
    stb    #bank(main_line), <_bl
    stw    #main_line, <_si
    stw    #(main_line_size/2), <_cx
    jsr    vdc_load_data
    
    ; load palettes
    stb    #bank(main_line_pal), <_bl
    stw    #main_line_pal, <_si
    jsr    map_data
    lda    #0
    ldy    #1
    jsr    vce_load_palette

    ; load sprites
    stw    #SPRITE_VRAM_ADDR, <_di
    stb    #bank(sprite_chr), <_bl
    stw    #sprite_chr, <_si
    stw    #(sprite_chr_size/2), <_cx
    jsr    vdc_load_data

    ; load sprite palette
    stb    #bank(sprite_pal), <_bl
    stw    #sprite_pal, <_si
    jsr    map_data
    lda    #16
    ldy    #1
    jsr    vce_load_palette

    jsr    dma_wait

    stw    #(MAIN_LINE_VRAM_ADDR>>4), <_si
    stw    #(64-MAIN_LINE_WIDTH), <_di
    
    ; setup BAT
    stb   #8, <_al
.loop:
    stw   #(MAIN_LINE_VRAM_ADDR>>4), <_si    
    ldy   #MAIN_LINE_HEIGHT
.loop_y:
    vdc_reg  #VDC_MAWR
    vdc_data <_di
    
    vdc_reg  #VDC_DATA
    clx
.loop_x:
    stw    <_si, video_data
    incw   <_si
    
    inx
    cpx    #MAIN_LINE_WIDTH
    bne    .loop_x

    addw   #63, <_di
    dey
    bne    .loop_y

    dec    <_al
    bne    .loop

    stw   #(MAIN_LINE_VRAM_ADDR>>4), <_si
    vdc_reg  #VDC_MAWR
    vdc_data <_di
    vdc_reg  #VDC_DATA
    clx
.loop_x2:
    stw    <_si, video_data
    incw   <_si
    
    inx
    cpx    #MAIN_LINE_WIDTH
    bne    .loop_x2
    
    vdc_reg  #VDC_CR
    vdc_data #SCR00_VDC_CONFIG

    irq_on #INT_IRQ1

    irq_enable_vec #VSYNC
    irq_set_vec #VSYNC, #vsync_callback

    irq_enable_vec #HSYNC
    irq_set_vec #HSYNC, #hsync_callback

    cli

    ; Enable VRAM SATB DMA
    vdc_reg  #VDC_DMA_CR
    vdc_data #VDC_DMA_SATB_AUTO
     ; Set SATB address
    vdc_reg  #VDC_SATB_SRC
    vdc_data #SATB_VRAM_ADDR
    
    rts

screen00_update:
    ; scroll
    st0    #VDC_BXR
    stw    <_scroll_x, video_data

    st0    #VDC_BYR
    stw    <_scroll_y, video_data

    addw   #4, <_scroll_x
    subw   #4, <_scroll_y

    lda    <_scroll_y+1 
    cmp    #$ff
    bne    .no_reset
        stw   #MAIN_LINE_Y1, <_scroll_y
        stw   #MAIN_LINE_X1, <_scroll_x
.no_reset:

    
    rts
