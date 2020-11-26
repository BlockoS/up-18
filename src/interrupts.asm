;----------------------------------------------------
; interupts.asm : interruption vectors
;
; (c) 2007 Vincent 'MooZ' Cruz
;
; Interruption vectors for each of the pce
; interruptions.
;
; LICENCE: not my fault if anything burns
;

;;---------------------------------------------------------------------
; desc : hardware memory transfer mode
;;---------------------------------------------------------------------
MEMCPY_SRC_ALT_DEST_INC  = $F3
MEMCPY_SRC_INC_DEST_ALT  = $E3
MEMCPY_SRC_INC_DEST_INC  = $73
MEMCPY_SRC_INC_DEST_NONE = $D3
MEMCPY_SRC_DEC_DEST_DEC  = $C3

;;---------------------------------------------------------------------
; desc : hardware memory transfer instruction helper
;;---------------------------------------------------------------------
    .bss
_hrdw_memcpy_mode .ds 1
_hrdw_memcpy_src  .ds 2
_hrdw_memcpy_dst  .ds 2
_hrdw_memcpy_len  .ds 2 
_hrdw_memcpy_rts  .ds 1

hrdw_memcpy = _hrdw_memcpy_mode

;----------------------------------------------------------------------
; name : set_vec
;
; description : Set user interrupt functions
;
; warning : A,X and Y will be overwritten
;		    Interrupts are disabled. You'll need to enable them by hands
;
; in : \1 interrupt to hook
;	   \2 user function to be called when interrupt will be triggered
set_vec .macro
	sei						; disable interrupts
	
	lda		\1
	asl		A				; compute offset in user function table
	tax
	lda		#low(\2)
	sta		user_jmptbl,X	; store low byte
	inx
	lda		#high(\2)
	sta		user_jmptbl,X
		
	.endm

;----------------------------------------------------------------------
; name : vec_on
;
; description : Enable interrupt vector
;
; warning : SOFT_RESET must not be used.
;			Bit 4 of irq_m is used to tell that the user vsync hook
;			must be run.  
;			Bit 5 is for standard vsync hook.
;			Bit 6 and 7 are the same things but for hsync.
;			Standard and user [h|v]sync hooks are not mutually
;			exclusive. If both bits are set, first the standard handler
;			will be called then the user one.
;
; in : \1 Vector to enable
;
vec_on .macro
	.if (\1 = 5)
	smb		#6, <irq_m		; user hsync
	.else
	smb		#\1, <irq_m
	.endif
	.endm

;----------------------------------------------------------------------
; name : vec_off
;
; description : Disable interrupt vector
;
; warning : same as vec_on (for irq_m bit value)
;
; in : \1 Vector to disable
vec_off .macro
	.if (\1 = 5)
	rmb		#6, <irq_m		; user hsync
	.else
	rmb		\1, <irq_m
	.endif
	.endm
	
;----------------------------------------------------------------------
; name : irq1_end
;
; description : End of IRQ1 interrupt
;
; warning : Must be performed at the end of each IRQ1 vector!
;
irq1_end	.macro 
								; restore registers
    lda    <vdc_reg
    sta    video_reg
    
    ply
    plx
    pla

    rti

	.endm

;----------------------------------------------------------------------
; Interrupt vectors names
;----------------------------------------------------------------------
IRQ2            = 0
IRQ1            = 1
TIMER           = 2
NMI             = 3
VSYNC           = 4
HSYNC           = 5
SOFT_RESET      = 6
