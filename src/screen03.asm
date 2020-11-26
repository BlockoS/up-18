FONT_VRAM_ADDR = $2040
FONT_PAT_ADDR = (FONT_VRAM_ADDR / 32)
TXT_X = $128
TXT_Y = $128

    .zp
_sx .ds 2
_sy .ds 2
_txtCount .ds 1
_off .ds 1

    .code
screen03_init:
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

    lda    #bank(font.pal)
    tam    #$04
    
    jsr    torus_bat
    
    ; load sprite font
    vdc_reg  #VDC_MAWR
    vdc_data #FONT_VRAM_ADDR
    
    vdc_reg  #VDC_DATA
    tia    font.gfx, video_data, font.size
    
    jsr    vgm_update
    
    ; load sprite palette
    stw    #$100, color_reg
    tia    font.pal, color_data, 32

    vdc_reg  #VDC_CR
    vdc_data #TORUS_VDC_CONFIG

    irq_enable_vec #VSYNC
    irq_set_vec #VSYNC, #vsync_callback

    irq_enable_vec #HSYNC
    irq_set_vec #HSYNC, #hsync_callback

    st0    #$0f     ; Enable VRAM SATB DMA
    st1    #$10 
    st2    #$00
    
    st0    #$13
    st1    #low(SATB_ADDR)
    st2    #high(SATB_ADDR)

    jsr    vdc_xres_256
    
    cli
    rts

display_txt:
    lda    <_off+1
    clc
    adc    #$07
    sta    <_off+1
    sta    <_off
    
    st0    #VDC_MAWR
    st1    #low(SATB_ADDR)
    st2    #high(SATB_ADDR)
   
    stw    <_txt, <_si
    
    cly
    clx
.l0:
    lda    [_si], Y             ; Line count
    iny
    sta    <_cl
    
    lda    [_si], Y             ; String bloc y position
    iny
    sta    <_sy
    stz    <_sy+1
    
.l1:
    lda    [_si], Y             ; String line x position
    iny
    sta    <_sx
    stz    <_sx+1

.l2:
    lda    [_si], Y             ; Fetch char
    iny
    sta    <_al
    
    cmp    #$ff                 ; eol
    beq    .eol
    
    cmp    #$fe                 ; space
    beq    .space
        st0    #VDC_DATA        
        ; Sprite position
        ; -- Y
        phx
        
        lda    <_off
        clc
        adc    #$11
        sta    <_off
        tax
        lda    sin_tbl, X
        clx
        bpl    .pos
            dex
.pos:
        cmp    #$80
        ror    A
        cmp    #$80
        ror    A
        cmp    #$80
        ror    A
        cmp    #$80
        ror    A
        
        clc
        adc    <_sy
        sta    video_data_l
        txa
        adc    <_sy+1
        sta    video_data_h

        plx
     
        ; -- X
        stw    <_sx, video_data
        
        ; -- vram addr
        lda    <_al
        asl    A
        clc
        adc    #low(FONT_PAT_ADDR)
        sta    video_data_l
        cla
        adc    #high(FONT_PAT_ADDR)
        sta    video_data_h

        ; -- flags
        st1    #$80
        st2    #$00
    
        inx
.next_char:
        phy
        ldy    <_al
        lda    txt_space, Y
        clc
        adc    <_sx
        sta    <_sx
        lda    <_sx+1
        adc    #0
        sta    <_sx+1
        ply
        
    bra    .l2
.space:
        addw   #TXT_SPACING, <_sx
    bra    .l2

.eol:
    tya
    clc
    adc    <_si
    sta    <_si
    lda    <_si+1
    adc    #$00
    sta    <_si+1
    cly
    
    dec    <_cl
    beq    .end
        addw   #TXT_V_SPACING, <_sy
    jmp    .l1
    
.end:
            
.clean_last:
    st0    #VDC_DATA
    st1    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    inx
    cpx    #2
    bne    .clean_last
    
    rts

screen03_update.0:
    lda    <_frame+1
    bne    .skip
    lda    <_frame
    bmi    .skip
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    and    #$07
    eor    #$ff
    clc
    adc    #8
    tax
    lda    torus.pal.lo, X
    sta    <torus.ptr
    lda    torus.pal.hi, X
    sta    <torus.ptr+1

.skip:
    lda    <_frame+1
    bne    .l0
    lda    <_frame
    cmp    #$01
    bne    .l0
        inc    <_txtCount
        stw    <_si, <_txt
.l0:
    jsr    display_txt
    jmp    torus_cycle

screen03_update.1:
    lda    <_frame+1
    bne    .l0
    lda    <_frame
    cmp    #$01
    bne    .l0
        inc    <_txtCount
        lda    <_txtCount
        cmp    #TXT_COUNT
        beq    .l0
        
        ldy    <_part
        lda    frame_count, Y
        sta    <_frame
        iny
        lda    frame_count, Y
        sta    <_frame+1

        stw    <_si, <_txt
.l0:
    ; [todo] txt anim
    jsr    display_txt
    jmp    torus_cycle
       
    .include "data/invtro_txt.inc"

txt_space:
    ;   ! " # $ % & ' ( ) * + , - . / 0 1 2 3
    .db 16, 9, 9, 16, 16, 10, 16, 8, 9, 9, 12, 11, 7, 10, 8, 10, 10, 8, 10, 10
    ; 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G
    .db 10, 10, 10, 10, 10, 10, 9, 16, 16, 16, 16, 10, 9, 10, 10, 10, 10, 10, 9, 10
    ; H I J K L M N O P Q R S T U V W X Y Z [
    .db 10, 9, 10, 9, 7, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 16
