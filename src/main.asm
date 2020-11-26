    .include "system.inc"
    .include "irq.inc"
    .include "vce.inc"
    .include "vdc.inc"
    .include "psg.inc"
    .include "macro.inc"
    .include "word.inc"
    .include "byte.inc"
    .include "memcpy.inc"
    .include "joypad.inc"
    .include "sprite.inc"
    
    .zp
_frame .ds 2
_part .ds 1
_scroll_x .ds 2
_scroll_y .ds 3
_txt .ds 2

    .code
    .bank 0
    .org $e000
    
    align_org 256
    .include "math_tbl.asm"

    .include "irq_reset.asm"
    .include "vdc.asm"
    .include "vce.asm"
    .include "psg.asm"
    .include "utils.asm"
    .include "joypad.asm"
    .include "vgm.asm"
    .include "random.asm"
    
    .include "screen02.asm"
    .include "torus.asm"
    .include "screen03.asm"
    
    .code
main:
    jsr    rand8_seed

    jsr    vdc_yres_224
    jsr    vdc_xres_256

    lda    #VDC_BG_64x64
    jsr    vdc_set_bat_size

    stz    <irq_m
    
    lda    #low(song_base_address)
    sta    <vgm_base
    sta    <vgm_ptr

    lda    #high(song_base_address)
    sta    <vgm_base+1
    sta    <vgm_ptr+1

    lda    #song_bank
    sta    <vgm_bank

    lda    <vgm_base+1
    clc
    adc    #$20
    sta    <vgm_end

    lda    #song_loop_bank
    sta    <vgm_loop_bank
    stw    #song_loop, <vgm_loop_ptr
    
    irq_on #INT_IRQ1

    irq_enable_vec #VSYNC
    irq_set_vec #VSYNC, #vsync_callback

    irq_enable_vec #HSYNC
    irq_set_vec #HSYNC, #hsync_callback
    
    vdc_reg  #VDC_CR
    vdc_data #$00

    jsr    torus_load_gfx ; we upload it once and for all

    stw    #txtData, <_txt
    stz    <_txtCount
    
    stw    #torus.pal.0, <torus.ptr
    
    stz    <_part
    cla
    jsr    init_part

    cli
.loop:

    lda    <_frame
    sec
    sbc    #$01
    sta    <_frame
    lda    <_frame+1
    sbc    #$00
    sta    <_frame+1
    ora    <_frame
    bne   .go
        jsr    init_next_part
.go:
    ldx    <_part
    jsr    update_part

    stz    <irq_cnt
.wait_vsync:
    lda    <irq_cnt
    beq    .wait_vsync

    bra  .loop

init_next_part:
    lda    <_part
    clc
    adc    #$02
    cmp    #(part_count*2)
    bne    .no_reset
        cla
.no_reset:
    sta    <_part
init_part:
    tax
    tay
    lda    frame_count, Y
    sta    <_frame
    iny
    lda    frame_count, Y
    sta    <_frame+1

    jmp    [init_routines, X]

update_part:
    jmp    [update_routines, X]

; ----------------------------------------------------------------
; [todo] bat size and tile index are hardcorded
; [todo] add a flag to wait?
clear_bat:
    ; disable hblank, bg and sprite display.
    vdc_reg #VDC_CR
    vdc_data #$0000
    
    ; clear bat using DMA
    ; 1. set the first word
    vdc_reg #VDC_MAWR
    vdc_data #$0000
    vdc_reg #VDC_DATA
    st1    #low($2000>>4)
    st2    #high($2000>>4)
    st2    #high($2000>>4)

    ; 2. DMA copy
    vdc_reg  #VDC_DMA_CR
    vdc_data #(VDC_DMA_VRAM_ENABLE | VDC_DMA_SRC_INC | VDC_DMA_DST_INC)
    
    st0    #VDC_DMA_SRC
    st1    #low($0000)
    st2    #high($0000)

    st0    #VDC_DMA_DST
    st1    #low($0002)
    st2    #high($0002)

    st0    #VDC_DMA_LEN
    st1    #low(64*64-2)
    st2    #high(64*64-2)

    rts

dma_wait:
.wait:
    lda    video_reg
    bit    #VDC_STATUS_VRAM_DMA_END
    beq    .wait
    
    rts
    
; ----------------------------------------------------------------
vsync_callback:
    ply
    plx
    pla
    rti

; ----------------------------------------------------------------
hsync_callback:
    ply
    plx
    pla
    rti

;-----------------------------------------------------------------------
; Timer interrupt
;-----------------------------------------------------------------------
_timer:
    timer_ack     ; acknowledge timer interrupt
    rti
;-----------------------------------------------------------------------
; IRQ2 interrupt
;-----------------------------------------------------------------------
_irq_2:
    rti
;-----------------------------------------------------------------------
; NMI interrupt
;-----------------------------------------------------------------------
_nmi:
    rti
;-----------------------------------------------------------------------
; IRQ1 interrupt
;-----------------------------------------------------------------------
_irq_1:
    pha                     ; save registers
    phx
    phy

    lda    video_reg        ; get VDC status register
    sta    <vdc_sr

@vsync:                     ; vsync interrupt
    bbr5   <vdc_sr, @hsync
    inc    <irq_cnt         ; update irq counter (for wait_vsync)

    jsr    vgm_update
        
    jmp    [vsync_hook]
@hsync:
    bbr2   <vdc_sr, @exit
    jmp    [hsync_hook]

@exit:

_dummy:
    ply
    plx
    pla

    rti
@user_hsync:
    jmp    [hsync_hook]
@user_vsync:
    jmp    [vsync_hook]

part_count = 5
init_routines:
    .dw screen02_init
    .dw screen03_init
    .dw torus_init
    .dw screen03_init
    .dw torus_init
        
update_routines:
    .dw screen02_update
    .dw screen03_update.0
    .dw torus_update
    .dw screen03_update.1
    .dw torus_update.1
    
frame_count:
    .dw $0100
    .dw $0100
    .dw $0200
    .dw $0100
        
;-----------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------
logo.ptr.lo:
    .dwl divine_stylers.gfx, genesis_project.gfx, pacific.gfx, tulou.gfx, uprough.gfx
logo.ptr.hi:
    .dwh divine_stylers.gfx, genesis_project.gfx, pacific.gfx, tulou.gfx, uprough.gfx    
logo.size.lo:
    .dwl 4480, 1280, 2080, 1600, 3840
logo.size.hi:
    .dwh 4480, 1280, 2080, 1600, 3840
logo.bat.lo:
    .dwl $201, $28d, $2b5, $2f6, $328
logo.bat.hi:
    .dwh $201, $28d, $2b5, $2f6, $328      
logo.width:
    .db 28, 8, 13, 10, 24
logo.height = 5
logo.size = 13280
logo.count = 5

    .data
    .bank 1
    .org $8000
logo.gfx:
divine_stylers.gfx:
    .incbin "./data/logos/divine_stylers.tiles"
genesis_project.gfx:
    .incbin "./data/logos/genesis_project.tiles"
pacific.gfx:
    .incbin "./data/logos/pacific.tiles"
tulou.gfx:
    .incbin "./data/logos/tulou.tiles"
uprough.gfx:
    .incbin "./data/logos/uprough.tiles"

    .bank 3
    .org $8000
font.pal:
    .incbin "./data/fnt_toy3.pal"
font.gfx:
    .incbin "./data/fnt_toy3.bin"
font.size = 7680

    .bank 4
    .org $8000
torus:
    .incbin "./data/torus.bin"
torus.size=14848

    .include "data/song/song.inc"

    .bank $25
    .org $8000
ds_logo.pal:
    .incbin "./data/logo_ds.pal"
ds_logo.gfx:
    .incbin "./data/logo_ds.bin"
ds_logo.size = 12800
    
;-----------------------------------------------------------------------
; Vector table
;-----------------------------------------------------------------------
    .data
    .bank 0
    .org $fff6

    .dw _irq_2
    .dw _irq_1
    .dw _timer
    .dw _nmi
    .dw _reset
