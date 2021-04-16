

; ---------------------------------------------------------------------------
; Twizzler decompression algorithm (68k)
; ---------------------------------------------------------------------------

TD_Setup:

	; --- Loading size ---

		moveq	#$05,d4					; load output size bitlength
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.w	d0,d4					; load output size
		moveq	#$01,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.l	d0,d1					; copy to d1

	; --- Loading section counter ---

		moveq	#$05,d4					; load section counter bitlength
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.w	d0,d4					; load section counter
		moveq	#$01,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.l	d0,d7					; copy to d7
		subq.l	#$01,d7					; minus 1 for dbf

	; --- Loading huffman retrace tree ---

		lea	(TwizHuffRet).w,a3			; load Retrace huffman list
		moveq	#$05,d4					; load huffman size bitlength
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.w	d0,d4					; load huffman size
		beq.s	TD_HuffRetNone				; if it's 0, branch (this one allows 0)
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.w	d0,d5					; copy size to d5
		subq.w	#$01,d5					; minus 1 for dbf

TD_HuffRetNext:
		moveq	#$01,d0					; prepare minimal
		move.l	d0,(a3)+				; ''
		moveq	#$05,d4					; load huffman entry bitlength
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.w	d0,d4					; load huffman entry
		beq.s	TD_HuffRetCheck				; if it's 0, branch (this one allows 0)
		moveq	#$01,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.l	d0,-$04(a3)				; save retrace entry

TD_HuffRetCheck:
		dbf	d5,TD_HuffRetNext			; repeat for all entries

TD_HuffRetNone:

	; --- Loading huffman copy tree ---

		lea	(TwizHuffCopy).w,a3			; load Copy huffman list
		moveq	#$05,d4					; load huffman size bitlength
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.w	d0,d4					; load huffman size
		beq.s	TD_HuffCopyNone				; if it's 0, branch (this one allows 0)
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.w	d0,d5					; copy size to d5
		subq.w	#$01,d5					; minus 1 for dbf

TD_HuffCopyNext:
		moveq	#$05,d4					; load huffman entry bitlength
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.w	d0,d4					; load huffman entry
		beq.s	TD_HuffCopyMin				; if it's 0, branch (this one allows 0)
		moveq	#$01,d0					; ''
		bsr.w	TD_LoadBits				; ''
		move.w	d0,(a3)+				; save copy entry
		dbf	d5,TD_HuffCopyNext			; repeat for all entries

TD_HuffCopyNone:
		rts						; return

TD_HuffCopyMin:
		move.w	#$0001,(a3)+				; set to minimum
		dbf	d5,TD_HuffCopyNext			; repeat for all entries
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Macro to check only a single bit of the bitfield
; ---------------------------------------------------------------------------

MAC_ReadBit	macro
		dbf	d2,*+$08				; decrease counter
		moveq	#$07,d2					; reset counter
		move.b	(a0)+,d3				; load next bitfield
		add.b	d3,d3					; load next bit to carry
		endm

; ===========================================================================
; ---------------------------------------------------------------------------
; The main section decompression loop
; ---------------------------------------------------------------------------

	; --- Uncompressed ---

TD_Uncompressed:
		move.b	(a0)+,(a1)+				; dump uncompressed byte
		dbf	d7,TD_DecompTwiz			; repeat for all available sections
		rts						; return

	; --- Main loop area ---

TD_DecompTwiz:
		MAC_ReadBit					; load next bitfield bit to carry
		bcc.s	TD_Uncompressed				; if clear, branch

; ---------------------------------------------------------------------------
; Loading Retrace (Offset)
; ---------------------------------------------------------------------------

		MAC_ReadBit					; load next bitfield bit to carry
		bcc.s	TD_RetDistant				; if set, branch
		MAC_ReadBit					; load next bitfield bit to carry
		bcc.s	TD_RetShort				; if set, branch

	; --- Huffman Retrace ---

	;	lea	(TwizHuffRet-$04).w,a3	; x86 long	; reset Retrace huffman list address
		lea	(TwizHuffRet-$02).w,a3	; 68k word	; reset Retrace huffman list address

TD_RetHuffNext:
		addq.w	#$04,a3					; advance to next Retrace address
		MAC_ReadBit					; load next bitfield bit to carry
		bcs.s	TD_RetHuffNext				; if set, branch to read another
		lea	(a1),a2					; copy output address to a2 for Retrace
	;	sub.l	(a3),a2			; x86 long	; load Retrace address
		sub.w	(a3),a2			; 68k word	; load Retrace address
		bra.s	TD_CopyRead				; continue

	; --- Short Retrace ---

TD_RetShort:
		moveq	#$00,d0					; clear d0
		MAC_ReadBit					; load RRR
		addx.b	d0,d0					; ''
		MAC_ReadBit					; ''
		addx.b	d0,d0					; ''
		MAC_ReadBit					; ''
		addx.b	d0,d0					; ''
		lea	-$01(a1),a2				; copy output address to a2 for Retrace (increment by 1)
		bra.s	TD_RetConvert				; continue

	; --- Distant Retrace ---

TD_RetDistant:
		moveq	#$00,d4					; clear d4
		MAC_ReadBit					; load SSSS
		addx.b	d4,d4					; ''
		MAC_ReadBit					; ''
		addx.b	d4,d4					; ''
		MAC_ReadBit					; ''
		addx.b	d4,d4					; ''
		MAC_ReadBit					; ''
		addx.b	d4,d4					; ''
		lea	-$09(a1),a2				; copy output address to a2 for Retrace (set as 9 automatically)
		tst.b	d4					; must use "tst", addx only clears the Z flag, it does NOT set it.
		beq.s	TD_CopyRead				; if it's 0, branch (this one allows 0)
		moveq	#$01,d0					; load following R's
		bsr.w	TD_LoadBits				; ''
		addq.w	#$01,a2					; add Retrace short distance to address

TD_RetConvert:
	;	sub.l	d0,a2			; x86 long	; move Retrace address back
		sub.w	d0,a2			; 68k word	; move Retrace address back

; ---------------------------------------------------------------------------
; Loading Copy (Length)
; ---------------------------------------------------------------------------

TD_CopyRead:
		moveq	#$00,d5					; clear d5
		MAC_ReadBit					; load next bitfield bit to carry
		bcs.s	TD_CopyDistant				; if set, branch

	; --- Short Copy ---

		MAC_ReadBit					; load next bitfield bit to carry
		subx.w	d5,d5					; subtrace bit from carry (needs to be in reverse order)
		add.b	d5,d5					; multiply by 2
		jmp	(TD_CopyShort+$02)(pc,d5.w)		; jump to correct copy offset

	; --- Distant Copy CC ---

TD_CopyDistant:
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		eori.b	#%00000011,d5				; reverse bit order
		beq.s	TD_CopyNoDistantCC			; if both bits are set, branch
		add.b	d5,d5					; multiply by 2
		jmp	(TD_CopyDistC-$02)(pc,d5.w)		; jump to correct copy offset
TD_CopyDistCC:	move.b	(a2)+,(a1)+				; copy 0D bytes here
		move.b	(a2)+,(a1)+				; copy 0C bytes here
		move.b	(a2)+,(a1)+				; copy 0B bytes here
		move.b	(a2)+,(a1)+				; copy 0A bytes here
		move.b	(a2)+,(a1)+				; copy 09 bytes here
		move.b	(a2)+,(a1)+				; copy 08 bytes here
		move.b	(a2)+,(a1)+				; copy 07 bytes here
TD_CopyDistC:	move.b	(a2)+,(a1)+				; copy 06 bytes here
		move.b	(a2)+,(a1)+				; copy 05 bytes here
		move.b	(a2)+,(a1)+				; copy 04 bytes here
TD_CopyShort:	move.b	(a2)+,(a1)+				; copy 03 bytes here
		move.b	(a2)+,(a1)+				; copy 02 bytes here
		move.b	(a2)+,(a1)+				; copy 01 byte here
		moveq	#$00,d5					; clear remaining counter
		dbf	d7,TD_DecompTwiz			; repeat for all available sections
		rts						; return

	; --- Distant Copy CCC ---

TD_CopyNoDistantCC:
		MAC_ReadBit					; load next bitfield bit to carry
		bcc.w	TD_CopyHuff				; if clear, branch for huffman read
		moveq	#$00,d5					; clear d5
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		eori.b	#%00000111,d5				; reverse bit order
		beq.s	TD_CopyNoDistantCCC			; if both bits are set, branch
		add.b	d5,d5					; multiply by 2
		jmp	(TD_CopyDistCC-$02)(pc,d5.w)		; jump to correct copy offset

	; --- Distant Copy CCCC ---

TD_CopyNoDistantCCC:
		MAC_ReadBit					; load next bitfield bit to carry
		bcc.w	TD_CopyExtended				; if clear, branch for extended copy
		moveq	#$00,d5					; clear d5
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		eori.b	#%00001111,d5				; reverse bit order
		beq.s	TD_CopyNoDistantCCCC			; if both bits are set, branch
		add.b	d5,d5					; multiply by 2
		jmp	(TD_CopyDistCCC-$02)(pc,d5.w)		; jump to correct copy offset
TD_CopyDistCCC:	move.b	(a2)+,(a1)+				; copy 1C bytes here
		move.b	(a2)+,(a1)+				; copy 1B bytes here
		move.b	(a2)+,(a1)+				; copy 1A bytes here
		move.b	(a2)+,(a1)+				; copy 19 bytes here
		move.b	(a2)+,(a1)+				; copy 18 bytes here
		move.b	(a2)+,(a1)+				; copy 17 bytes here
		move.b	(a2)+,(a1)+				; copy 16 bytes here
		move.b	(a2)+,(a1)+				; copy 15 bytes here
		move.b	(a2)+,(a1)+				; copy 14 bytes here
		move.b	(a2)+,(a1)+				; copy 13 bytes here
		move.b	(a2)+,(a1)+				; copy 12 bytes here
		move.b	(a2)+,(a1)+				; copy 11 bytes here
		move.b	(a2)+,(a1)+				; copy 10 bytes here
		move.b	(a2)+,(a1)+				; copy 0F bytes here
		move.b	(a2)+,(a1)+				; copy 0E bytes here
		move.b	(a2)+,(a1)+				; copy 0D bytes here
		move.b	(a2)+,(a1)+				; copy 0C bytes here
		move.b	(a2)+,(a1)+				; copy 0B bytes here
		move.b	(a2)+,(a1)+				; copy 0A bytes here
		move.b	(a2)+,(a1)+				; copy 09 bytes here
		move.b	(a2)+,(a1)+				; copy 08 bytes here
		move.b	(a2)+,(a1)+				; copy 07 bytes here
		move.b	(a2)+,(a1)+				; copy 06 bytes here
		move.b	(a2)+,(a1)+				; copy 05 bytes here
		move.b	(a2)+,(a1)+				; copy 04 bytes here
		move.b	(a2)+,(a1)+				; copy 03 bytes here
		move.b	(a2)+,(a1)+				; copy 02 bytes here
		move.b	(a2)+,(a1)+				; copy 01 byte here
		moveq	#$00,d5					; clear remaining counter
		dbf	d7,TD_DecompTwiz			; repeat for all available sections
		rts						; return

	; --- Distant Copy CCCCC ---

TD_CopyNoDistantCCCC:
		moveq	#$05,d4					; load CCCCC
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		addi.b	#$1D,d0					; add minimum copy count plus previous copies
		move.w	d0,d5					; copy to d5 for decompression loop
		bra.w	TD_CopyStream				; continue to decompression loop

	; --- Extended Copy ---

TD_CopyExtended:
		moveq	#$09,d4					; load CCCCCCCCC
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		addi.w	#$003D,d0				; add minimum copy count plus previous copies
		move.w	d0,d5					; copy to d5 for decompression loop
		bra.w	TD_CopyStream				; continue to decompression loop

	; --- Huffman Copy ---

TD_CopyHuff:
		lea	(TwizHuffCopy-$02).w,a3			; reset Copy huffman list address

TD_CopyHuffNext:
		addq.w	#$02,a3					; advance to next Copy address
		MAC_ReadBit					; load next bitfield bit to carry
		bcs.s	TD_CopyHuffNext				; if set, branch to read another
		move.w	(a3),d5					; load copy value
		bra.w	TD_CopyStream				; continue to decompression loop

; ===========================================================================
; ---------------------------------------------------------------------------
; The Large Copy Stream
; ---------------------------------------------------------------------------

		rept	$23D
		move.b	(a2)+,(a1)+				; copy bytes forward
		endr
TD_CopyList:	rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Decompression loo, Section count, and final
; ---------------------------------------------------------------------------

TD_CopyStream:
		neg.w	d5					; reverse copy amount
		add.w	d5,d5					; multiply by size of "move.b  (a2)+,(a1)+" instruction
		jsr	TD_CopyList(pc,d5.w)			; jump to correct start position based on copy size
		moveq	#$00,d5					; clear remaining counter
		dbf	d7,TD_DecompTwiz			; repeat for all available sections
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; The main section decompression loop
; ---------------------------------------------------------------------------

	; --- Uncompressed ---

TDM_Uncompressed:
		move.b	(a0)+,(a1)				; dump uncompressed byte
		move.b	(a1)+,(a4)+				; ''
		subq.w	#$01,d1					; decrease buffer size counter
		bls.w	TDM_Return	; bls = bcs + beq	; if finished, branch
		dbf	d7,TDM_NextSection			; repeat for all available sections
		rts						; return

TDM_Return:
		subq.w	#$01,d7					; decrease section counter
		rts						; return

	; --- Main loop area ---

TD_DecompTwim:
		tst.w	d5					; is there any remaining data to copy?
		beq.s	TDM_NextSection				; if not, branch
		bsr.w	TDM_CopyRemain				; copy last remaining data before continuing

TDM_NextSection:
		MAC_ReadBit					; load next bitfield bit to carry
		bcc.s	TDM_Uncompressed			; if clear, branch

; ---------------------------------------------------------------------------
; Loading Retrace (Offset)
; ---------------------------------------------------------------------------

		MAC_ReadBit					; load next bitfield bit to carry
		bcc.s	TDM_RetDistant				; if set, branch
		MAC_ReadBit					; load next bitfield bit to carry
		bcc.s	TDM_RetShort				; if set, branch

	; --- Huffman Retrace ---

	;	lea	(TwizHuffRet-$04).w,a3	; x86 long	; reset Retrace huffman list address
		lea	(TwizHuffRet-$02).w,a3	; 68k word	; reset Retrace huffman list address

TDM_RetHuffNext:
		addq.w	#$04,a3					; advance to next Retrace address
		MAC_ReadBit					; load next bitfield bit to carry
		bcs.s	TDM_RetHuffNext				; if set, branch to read another
		lea	(a1),a2					; copy output address to a2 for Retrace
	;	sub.l	(a3),a2			; x86 long	; load Retrace address
		sub.w	(a3),a2			; 68k word	; load Retrace address
		bra.s	TDM_CopyRead				; continue

	; --- Short Retrace ---

TDM_RetShort:
		moveq	#$00,d0					; clear d0
		MAC_ReadBit					; load RRR
		addx.b	d0,d0					; ''
		MAC_ReadBit					; ''
		addx.b	d0,d0					; ''
		MAC_ReadBit					; ''
		addx.b	d0,d0					; ''
		lea	-$01(a1),a2				; copy output address to a2 for Retrace (increment by 1)
		bra.s	TDM_RetConvert				; continue

	; --- Distant Retrace ---

TDM_RetDistant:
		moveq	#$00,d4					; clear d4
		MAC_ReadBit					; load SSSS
		addx.b	d4,d4					; ''
		MAC_ReadBit					; ''
		addx.b	d4,d4					; ''
		MAC_ReadBit					; ''
		addx.b	d4,d4					; ''
		MAC_ReadBit					; ''
		addx.b	d4,d4					; ''
		lea	-$09(a1),a2				; copy output address to a2 for Retrace (set as 9 automatically)
		tst.b	d4					; must use "tst", addx only clears the Z flag, it does NOT set it.
		beq.s	TDM_CopyRead				; if it's 0, branch (this one allows 0)
		moveq	#$01,d0					; load following R's
		bsr.w	TD_LoadBits				; ''
		addq.w	#$01,a2					; add Retrace short distance to address

TDM_RetConvert:
	;	sub.l	d0,a2			; x86 long	; move Retrace address back
		sub.w	d0,a2			; 68k word	; move Retrace address back

; ---------------------------------------------------------------------------
; Loading Copy (Length)
; ---------------------------------------------------------------------------

TDM_CopyRead:
		moveq	#$00,d5					; clear d5
		MAC_ReadBit					; load next bitfield bit to carry
		bcs.s	TDM_CopyDistant				; if set, branch

	; --- Short Copy ---

		MAC_ReadBit					; load next bitfield bit to carry
		subx.w	d5,d5					; subtrace bit from carry (needs to be in reverse order)
		moveq	#$02,d0					; prepare minimum copy
		sub.w	d5,d0					; add copy size
		sub.w	d0,d1					; subtract from buffer size
		bls.w	TDM_CopyReturn	; bls = bcs + beq	; if there isn't enough space, branch
		add.b	d5,d5					; multiply by 4
		add.b	d5,d5					; ''
		jmp	(TDM_CopyShort+$04)(pc,d5.w)		; jump to correct copy offset
TDM_CopyShort:	move.b	(a2)+,(a1)				; copy 03 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 02 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 01 byte here
		move.b	(a1)+,(a4)+				; ''
		moveq	#$00,d5					; clear remaining counter
		dbf	d7,TDM_NextSection			; repeat for all available sections
		rts						; return

	; --- Distant Copy CC ---

TDM_CopyDistant:
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		move.w	d5,d0					; copy size to d0
		eori.b	#%00000011,d5				; reverse bit order
		beq.s	TDM_CopyNoDistantCC			; if both bits are set, branch
		addq.b	#$04,d0					; add minimum copy
		sub.w	d0,d1					; subtract from buffer size
		bls.w	TDM_CopyReturn	; bls = bcs + beq	; if there isn't enough space, branch
		add.b	d5,d5					; multiply by 4
		add.b	d5,d5					; ''
		jmp	(TDM_CopyDistC-$04)(pc,d5.w)		; jump to correct copy offset

	; --- Distant Copy CCC ---

TDM_CopyNoDistantCC:
		MAC_ReadBit					; load next bitfield bit to carry
		bcc.w	TDM_CopyHuff				; if clear, branch for huffman read
		moveq	#$00,d5					; clear d5
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		move.w	d5,d0					; copy size to d0
		eori.b	#%00000111,d5				; reverse bit order
		beq.s	TDM_CopyNoDistantCCC			; if both bits are set, branch
		addq.b	#$07,d0					; add minimum copy
		sub.w	d0,d1					; subtract from buffer size
		bls.w	TDM_CopyReturn	; bls = bcs + beq	; if there isn't enough space, branch
		add.b	d5,d5					; multiply by 4
		add.b	d5,d5					; ''
		jmp	(TDM_CopyDistCC-$04)(pc,d5.w)		; jump to correct copy offset
TDM_CopyDistCC:	move.b	(a2)+,(a1)				; copy 0D bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 0C bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 0B bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 0A bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 09 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 08 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 07 bytes here
		move.b	(a1)+,(a4)+				; ''
TDM_CopyDistC:	move.b	(a2)+,(a1)				; copy 06 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 05 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 04 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 03 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 02 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 01 byte here
		move.b	(a1)+,(a4)+				; ''
		moveq	#$00,d5					; clear remaining counter
		dbf	d7,TDM_NextSection			; repeat for all available sections
		rts						; return

	; --- Distant Copy CCCC ---

TDM_CopyNoDistantCCC:
		MAC_ReadBit					; load next bitfield bit to carry
		bcc.w	TDM_CopyExtended				; if clear, branch for extended copy
		moveq	#$00,d5					; clear d5
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		MAC_ReadBit					; load next bitfield bit to carry
		addx.b	d5,d5					; load bit from carry
		move.w	d5,d0					; copy size to d0
		eori.b	#%00001111,d5				; reverse bit order
		beq.w	TDM_CopyNoDistantCCCC			; if both bits are set, branch
		addi.b	#$0E,d0					; add minimum copy
		sub.w	d0,d1					; subtract from buffer size
		bls.w	TDM_CopyReturn	; bls = bcs + beq	; if there isn't enough space, branch
		add.b	d5,d5					; multiply by 4
		add.b	d5,d5					; ''
		jmp	(TDM_CopyDisCCC-$04)(pc,d5.w)		; jump to correct copy offset
TDM_CopyDisCCC:	move.b	(a2)+,(a1)				; copy 1C bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 1B bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 1A bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 19 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 18 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 17 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 16 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 15 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 14 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 13 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 12 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 11 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 10 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 0F bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 0E bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 0D bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 0C bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 0B bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 0A bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 09 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 08 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 07 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 06 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 05 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 04 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 03 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 02 bytes here
		move.b	(a1)+,(a4)+				; ''
		move.b	(a2)+,(a1)				; copy 01 byte here
		move.b	(a1)+,(a4)+				; ''
		moveq	#$00,d5					; clear remaining counter
		dbf	d7,TDM_NextSection			; repeat for all available sections
		rts						; return

	; --- Distant Copy CCCCC ---

TDM_CopyNoDistantCCCC:
		moveq	#$05,d4					; load CCCCC
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		addi.b	#$1D,d0					; add minimum copy count plus previous copies
		move.w	d0,d5					; copy to d5 for decompression loop
		sub.w	d5,d1					; subtract from buffer size
		bls.w	TDM_CopyReturnFix ; bls = bcs + beq	; if there isn't enough space, branch
		bra.w	TDM_CopyStream				; continue to decompression loop

	; --- Extended Copy ---

TDM_CopyExtended:
		moveq	#$09,d4					; load CCCCCCCCC
		moveq	#$00,d0					; ''
		bsr.w	TD_LoadBits				; ''
		addi.w	#$003D,d0				; add minimum copy count plus previous copies
		move.w	d0,d5					; copy to d5 for decompression loop
		sub.w	d5,d1					; subtract from buffer size
		bls.w	TDM_CopyReturnFix ; bls = bcs + beq	; if there isn't enough space, branch
		bra.w	TDM_CopyStream				; continue to decompression loop

	; --- Huffman Copy ---

TDM_CopyHuff:
		lea	(TwizHuffCopy-$02).w,a3			; reset Copy huffman list address

TDM_CopyHuffNext:
		addq.w	#$02,a3					; advance to next Copy address
		MAC_ReadBit					; load next bitfield bit to carry
		bcs.s	TDM_CopyHuffNext			; if set, branch to read another
		move.w	(a3),d5					; load copy value
		sub.w	d5,d1					; subtract from buffer size
		bls.w	TDM_CopyReturnFix ; bls = bcs + beq	; if there isn't enough space, branch
		bra.w	TDM_CopyStream				; continue to decompression loop

; ===========================================================================
; ---------------------------------------------------------------------------
; The Large Copy Stream
; ---------------------------------------------------------------------------

		rept	$23D
		move.b	(a2)+,(a1)				; copy bytes forward
		move.b	(a1)+,(a4)+				; ''
		endr
TDM_CopyList:	rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Decompression loo, Section count, and final
; ---------------------------------------------------------------------------

TDM_CopyStream:
		neg.w	d5					; reverse copy amount
		add.w	d5,d5					; multiply by size of "move.b  (a2)+,(a1)/move.b  (a1)+,(a4)+" instruction
		add.w	d5,d5					; ''
		jsr	TDM_CopyList(pc,d5.w)			; jump to correct start position based on copy size
		moveq	#$00,d5					; clear remaining counter
		dbf	d7,TDM_NextSection			; repeat for all available sections
		rts						; return

	; --- For copying last bit of data and then returning ---

TDM_CopyReturn:
		add.w	d1,d0					; get remaining buffer size
		move.w	d0,d5					; copy to d5
		neg.w	d1					; get copy amount left over
		neg.w	d5					; reverse copy amount
		exg.l	d1,d5					; put remaining amount in d5, and current amount in d1
		add.w	d1,d1					; multiply by size of "move.b  (a2)+,(a1)/move.b  (a1)+,(a4)+" instruction
		add.w	d1,d1					; ''
		jmp	TDM_CopyList(pc,d1.w)			; jump to correct start position based on copy size

TDM_CopyReturnFix:
		add.w	d1,d5					; get remaining buffer size
		neg.w	d1					; get copy amount left over
		neg.w	d5					; reverse copy amount
		exg.l	d1,d5					; put remaining amount in d5, and current amount in d1
		add.w	d1,d1					; multiply by size of "move.b  (a2)+,(a1)/move.b  (a1)+,(a4)+" instruction
		add.w	d1,d1					; ''
		jmp	TDM_CopyList(pc,d1.w)			; jump to correct start position based on copy size

TDM_CopyRemain:
		move.w	a2,d0					; get source buffer location
		subi.w	#TwizBuffer&$FFFF,d0			; minus start of buffer
		add.w	d5,d0					; add remaining copy amount
		subi.w	#TwizBufferSize&$FFFF,d0		; is it larger than the buffer size (i.e. needs to wrap?)
		bls.s	TDMCC_Single	; bls = bcs + beq	; if not, branch
		sub.w	d0,d5					; get remaining size til the end of the buffer
		sub.w	d5,d1					; subtract from buffer size
		bls.s	TDM_CopyReturn	; bls = bcs + beq	; if there isn't enough space, branch
		neg.w	d5					; reverse copy amount
		add.w	d5,d5					; multiply by size of "move.b  (a2)+,(a1)/move.b  (a1)+,(a4)+" instruction
		add.w	d5,d5					; ''
		jsr	TDM_CopyList(pc,d5.w)			; jump to correct start position based on copy size
		move.w	d0,d5					; get size for the start of the buffer
		lea	(TwizBuffer).w,a2			; load buffer address

TDMCC_Single:
		sub.w	d5,d1					; subtract from buffer size
		bls.s	TDM_CopyReturn	; bls = bcs + beq	; if there isn't enough space, branch
		neg.w	d5					; reverse copy amount
		add.w	d5,d5					; multiply by size of "move.b  (a2)+,(a1)/move.b  (a1)+,(a4)+" instruction
		add.w	d5,d5					; ''
		jmp	TDM_CopyList(pc,d5.w)			; jump to correct start position based on copy size

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load multiple bits from the bitfield correctly
; ---------------------------------------------------------------------------

TD_Mult05:	dc.b	$00,$20,$40,$60,$80,$A0,$C0,$E0

TD_LoadBits:
		or.b	TD_Mult05(pc,d2.w),d4			; multiply counter by 20, and fuse with requested number of bits
		move.b	(TD_IncCounter-$01)(pc,d4.w),d2		; increment bit counter
		add.w	d4,d4					; multiply by word size
		bra.w	TD_Rout					; continue (quicker to branch to relative routine instructions)

TD_IncCounter:	dc.b	$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00
		dc.b	$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00
		dc.b	$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01
		dc.b	$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01
		dc.b	$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02
		dc.b	$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02
		dc.b	$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03
		dc.b	$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03
		dc.b	$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04
		dc.b	$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04
		dc.b	$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05
		dc.b	$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06,$05
		dc.b	$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06
		dc.b	$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07,$06
		dc.b	$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07
		dc.b	$06,$05,$04,$03,$02,$01,$00,$07,$06,$05,$04,$03,$02,$01,$00,$07

TD_Rout:
		move.w	(TD_LB_Routine-$02)(pc,d4.w),d4		; set address
		jmp	(TD_LB_Routine-$02)(pc,d4.w)		; run routine

TD_LB_Routine:	dc.w	TD_L01_R00-(TD_LB_Routine-$02), TD_L02_R00-(TD_LB_Routine-$02), TD_L03_R00-(TD_LB_Routine-$02), TD_L04_R00-(TD_LB_Routine-$02), TD_L05_R00-(TD_LB_Routine-$02), TD_L06_R00-(TD_LB_Routine-$02), TD_L07_R00-(TD_LB_Routine-$02), TD_L08_R00-(TD_LB_Routine-$02)
		dc.w	TD_L09_R00-(TD_LB_Routine-$02), TD_L0A_R00-(TD_LB_Routine-$02), TD_L0B_R00-(TD_LB_Routine-$02), TD_L0C_R00-(TD_LB_Routine-$02), TD_L0D_R00-(TD_LB_Routine-$02), TD_L0E_R00-(TD_LB_Routine-$02), TD_L0F_R00-(TD_LB_Routine-$02), TD_L10_R00-(TD_LB_Routine-$02)
		dc.w	TD_L11_R00-(TD_LB_Routine-$02), TD_L12_R00-(TD_LB_Routine-$02), TD_L13_R00-(TD_LB_Routine-$02), TD_L14_R00-(TD_LB_Routine-$02), TD_L15_R00-(TD_LB_Routine-$02), TD_L16_R00-(TD_LB_Routine-$02), TD_L17_R00-(TD_LB_Routine-$02), TD_L18_R00-(TD_LB_Routine-$02)
		dc.w	TD_L19_R00-(TD_LB_Routine-$02), TD_L1A_R00-(TD_LB_Routine-$02), TD_L1B_R00-(TD_LB_Routine-$02), TD_L1C_R00-(TD_LB_Routine-$02), TD_L1D_R00-(TD_LB_Routine-$02), TD_L1E_R00-(TD_LB_Routine-$02), TD_L1F_R00-(TD_LB_Routine-$02), TD_L20_R00-(TD_LB_Routine-$02)
		dc.w	TD_L01_R01-(TD_LB_Routine-$02), TD_L02_R01-(TD_LB_Routine-$02), TD_L03_R01-(TD_LB_Routine-$02), TD_L04_R01-(TD_LB_Routine-$02), TD_L05_R01-(TD_LB_Routine-$02), TD_L06_R01-(TD_LB_Routine-$02), TD_L07_R01-(TD_LB_Routine-$02), TD_L08_R01-(TD_LB_Routine-$02)
		dc.w	TD_L09_R01-(TD_LB_Routine-$02), TD_L0A_R01-(TD_LB_Routine-$02), TD_L0B_R01-(TD_LB_Routine-$02), TD_L0C_R01-(TD_LB_Routine-$02), TD_L0D_R01-(TD_LB_Routine-$02), TD_L0E_R01-(TD_LB_Routine-$02), TD_L0F_R01-(TD_LB_Routine-$02), TD_L10_R01-(TD_LB_Routine-$02)
		dc.w	TD_L11_R01-(TD_LB_Routine-$02), TD_L12_R01-(TD_LB_Routine-$02), TD_L13_R01-(TD_LB_Routine-$02), TD_L14_R01-(TD_LB_Routine-$02), TD_L15_R01-(TD_LB_Routine-$02), TD_L16_R01-(TD_LB_Routine-$02), TD_L17_R01-(TD_LB_Routine-$02), TD_L18_R01-(TD_LB_Routine-$02)
		dc.w	TD_L19_R01-(TD_LB_Routine-$02), TD_L1A_R01-(TD_LB_Routine-$02), TD_L1B_R01-(TD_LB_Routine-$02), TD_L1C_R01-(TD_LB_Routine-$02), TD_L1D_R01-(TD_LB_Routine-$02), TD_L1E_R01-(TD_LB_Routine-$02), TD_L1F_R01-(TD_LB_Routine-$02), TD_L20_R01-(TD_LB_Routine-$02)
		dc.w	TD_L01_R02-(TD_LB_Routine-$02), TD_L02_R02-(TD_LB_Routine-$02), TD_L03_R02-(TD_LB_Routine-$02), TD_L04_R02-(TD_LB_Routine-$02), TD_L05_R02-(TD_LB_Routine-$02), TD_L06_R02-(TD_LB_Routine-$02), TD_L07_R02-(TD_LB_Routine-$02), TD_L08_R02-(TD_LB_Routine-$02)
		dc.w	TD_L09_R02-(TD_LB_Routine-$02), TD_L0A_R02-(TD_LB_Routine-$02), TD_L0B_R02-(TD_LB_Routine-$02), TD_L0C_R02-(TD_LB_Routine-$02), TD_L0D_R02-(TD_LB_Routine-$02), TD_L0E_R02-(TD_LB_Routine-$02), TD_L0F_R02-(TD_LB_Routine-$02), TD_L10_R02-(TD_LB_Routine-$02)
		dc.w	TD_L11_R02-(TD_LB_Routine-$02), TD_L12_R02-(TD_LB_Routine-$02), TD_L13_R02-(TD_LB_Routine-$02), TD_L14_R02-(TD_LB_Routine-$02), TD_L15_R02-(TD_LB_Routine-$02), TD_L16_R02-(TD_LB_Routine-$02), TD_L17_R02-(TD_LB_Routine-$02), TD_L18_R02-(TD_LB_Routine-$02)
		dc.w	TD_L19_R02-(TD_LB_Routine-$02), TD_L1A_R02-(TD_LB_Routine-$02), TD_L1B_R02-(TD_LB_Routine-$02), TD_L1C_R02-(TD_LB_Routine-$02), TD_L1D_R02-(TD_LB_Routine-$02), TD_L1E_R02-(TD_LB_Routine-$02), TD_L1F_R02-(TD_LB_Routine-$02), TD_L20_R02-(TD_LB_Routine-$02)
		dc.w	TD_L01_R03-(TD_LB_Routine-$02), TD_L02_R03-(TD_LB_Routine-$02), TD_L03_R03-(TD_LB_Routine-$02), TD_L04_R03-(TD_LB_Routine-$02), TD_L05_R03-(TD_LB_Routine-$02), TD_L06_R03-(TD_LB_Routine-$02), TD_L07_R03-(TD_LB_Routine-$02), TD_L08_R03-(TD_LB_Routine-$02)
		dc.w	TD_L09_R03-(TD_LB_Routine-$02), TD_L0A_R03-(TD_LB_Routine-$02), TD_L0B_R03-(TD_LB_Routine-$02), TD_L0C_R03-(TD_LB_Routine-$02), TD_L0D_R03-(TD_LB_Routine-$02), TD_L0E_R03-(TD_LB_Routine-$02), TD_L0F_R03-(TD_LB_Routine-$02), TD_L10_R03-(TD_LB_Routine-$02)
		dc.w	TD_L11_R03-(TD_LB_Routine-$02), TD_L12_R03-(TD_LB_Routine-$02), TD_L13_R03-(TD_LB_Routine-$02), TD_L14_R03-(TD_LB_Routine-$02), TD_L15_R03-(TD_LB_Routine-$02), TD_L16_R03-(TD_LB_Routine-$02), TD_L17_R03-(TD_LB_Routine-$02), TD_L18_R03-(TD_LB_Routine-$02)
		dc.w	TD_L19_R03-(TD_LB_Routine-$02), TD_L1A_R03-(TD_LB_Routine-$02), TD_L1B_R03-(TD_LB_Routine-$02), TD_L1C_R03-(TD_LB_Routine-$02), TD_L1D_R03-(TD_LB_Routine-$02), TD_L1E_R03-(TD_LB_Routine-$02), TD_L1F_R03-(TD_LB_Routine-$02), TD_L20_R03-(TD_LB_Routine-$02)
		dc.w	TD_L01_R04-(TD_LB_Routine-$02), TD_L02_R04-(TD_LB_Routine-$02), TD_L03_R04-(TD_LB_Routine-$02), TD_L04_R04-(TD_LB_Routine-$02), TD_L05_R04-(TD_LB_Routine-$02), TD_L06_R04-(TD_LB_Routine-$02), TD_L07_R04-(TD_LB_Routine-$02), TD_L08_R04-(TD_LB_Routine-$02)
		dc.w	TD_L09_R04-(TD_LB_Routine-$02), TD_L0A_R04-(TD_LB_Routine-$02), TD_L0B_R04-(TD_LB_Routine-$02), TD_L0C_R04-(TD_LB_Routine-$02), TD_L0D_R04-(TD_LB_Routine-$02), TD_L0E_R04-(TD_LB_Routine-$02), TD_L0F_R04-(TD_LB_Routine-$02), TD_L10_R04-(TD_LB_Routine-$02)
		dc.w	TD_L11_R04-(TD_LB_Routine-$02), TD_L12_R04-(TD_LB_Routine-$02), TD_L13_R04-(TD_LB_Routine-$02), TD_L14_R04-(TD_LB_Routine-$02), TD_L15_R04-(TD_LB_Routine-$02), TD_L16_R04-(TD_LB_Routine-$02), TD_L17_R04-(TD_LB_Routine-$02), TD_L18_R04-(TD_LB_Routine-$02)
		dc.w	TD_L19_R04-(TD_LB_Routine-$02), TD_L1A_R04-(TD_LB_Routine-$02), TD_L1B_R04-(TD_LB_Routine-$02), TD_L1C_R04-(TD_LB_Routine-$02), TD_L1D_R04-(TD_LB_Routine-$02), TD_L1E_R04-(TD_LB_Routine-$02), TD_L1F_R04-(TD_LB_Routine-$02), TD_L20_R04-(TD_LB_Routine-$02)
		dc.w	TD_L01_R05-(TD_LB_Routine-$02), TD_L02_R05-(TD_LB_Routine-$02), TD_L03_R05-(TD_LB_Routine-$02), TD_L04_R05-(TD_LB_Routine-$02), TD_L05_R05-(TD_LB_Routine-$02), TD_L06_R05-(TD_LB_Routine-$02), TD_L07_R05-(TD_LB_Routine-$02), TD_L08_R05-(TD_LB_Routine-$02)
		dc.w	TD_L09_R05-(TD_LB_Routine-$02), TD_L0A_R05-(TD_LB_Routine-$02), TD_L0B_R05-(TD_LB_Routine-$02), TD_L0C_R05-(TD_LB_Routine-$02), TD_L0D_R05-(TD_LB_Routine-$02), TD_L0E_R05-(TD_LB_Routine-$02), TD_L0F_R05-(TD_LB_Routine-$02), TD_L10_R05-(TD_LB_Routine-$02)
		dc.w	TD_L11_R05-(TD_LB_Routine-$02), TD_L12_R05-(TD_LB_Routine-$02), TD_L13_R05-(TD_LB_Routine-$02), TD_L14_R05-(TD_LB_Routine-$02), TD_L15_R05-(TD_LB_Routine-$02), TD_L16_R05-(TD_LB_Routine-$02), TD_L17_R05-(TD_LB_Routine-$02), TD_L18_R05-(TD_LB_Routine-$02)
		dc.w	TD_L19_R05-(TD_LB_Routine-$02), TD_L1A_R05-(TD_LB_Routine-$02), TD_L1B_R05-(TD_LB_Routine-$02), TD_L1C_R05-(TD_LB_Routine-$02), TD_L1D_R05-(TD_LB_Routine-$02), TD_L1E_R05-(TD_LB_Routine-$02), TD_L1F_R05-(TD_LB_Routine-$02), TD_L20_R05-(TD_LB_Routine-$02)
		dc.w	TD_L01_R06-(TD_LB_Routine-$02), TD_L02_R06-(TD_LB_Routine-$02), TD_L03_R06-(TD_LB_Routine-$02), TD_L04_R06-(TD_LB_Routine-$02), TD_L05_R06-(TD_LB_Routine-$02), TD_L06_R06-(TD_LB_Routine-$02), TD_L07_R06-(TD_LB_Routine-$02), TD_L08_R06-(TD_LB_Routine-$02)
		dc.w	TD_L09_R06-(TD_LB_Routine-$02), TD_L0A_R06-(TD_LB_Routine-$02), TD_L0B_R06-(TD_LB_Routine-$02), TD_L0C_R06-(TD_LB_Routine-$02), TD_L0D_R06-(TD_LB_Routine-$02), TD_L0E_R06-(TD_LB_Routine-$02), TD_L0F_R06-(TD_LB_Routine-$02), TD_L10_R06-(TD_LB_Routine-$02)
		dc.w	TD_L11_R06-(TD_LB_Routine-$02), TD_L12_R06-(TD_LB_Routine-$02), TD_L13_R06-(TD_LB_Routine-$02), TD_L14_R06-(TD_LB_Routine-$02), TD_L15_R06-(TD_LB_Routine-$02), TD_L16_R06-(TD_LB_Routine-$02), TD_L17_R06-(TD_LB_Routine-$02), TD_L18_R06-(TD_LB_Routine-$02)
		dc.w	TD_L19_R06-(TD_LB_Routine-$02), TD_L1A_R06-(TD_LB_Routine-$02), TD_L1B_R06-(TD_LB_Routine-$02), TD_L1C_R06-(TD_LB_Routine-$02), TD_L1D_R06-(TD_LB_Routine-$02), TD_L1E_R06-(TD_LB_Routine-$02), TD_L1F_R06-(TD_LB_Routine-$02), TD_L20_R06-(TD_LB_Routine-$02)
		dc.w	TD_L01_R07-(TD_LB_Routine-$02), TD_L02_R07-(TD_LB_Routine-$02), TD_L03_R07-(TD_LB_Routine-$02), TD_L04_R07-(TD_LB_Routine-$02), TD_L05_R07-(TD_LB_Routine-$02), TD_L06_R07-(TD_LB_Routine-$02), TD_L07_R07-(TD_LB_Routine-$02), TD_L08_R07-(TD_LB_Routine-$02)
		dc.w	TD_L09_R07-(TD_LB_Routine-$02), TD_L0A_R07-(TD_LB_Routine-$02), TD_L0B_R07-(TD_LB_Routine-$02), TD_L0C_R07-(TD_LB_Routine-$02), TD_L0D_R07-(TD_LB_Routine-$02), TD_L0E_R07-(TD_LB_Routine-$02), TD_L0F_R07-(TD_LB_Routine-$02), TD_L10_R07-(TD_LB_Routine-$02)
		dc.w	TD_L11_R07-(TD_LB_Routine-$02), TD_L12_R07-(TD_LB_Routine-$02), TD_L13_R07-(TD_LB_Routine-$02), TD_L14_R07-(TD_LB_Routine-$02), TD_L15_R07-(TD_LB_Routine-$02), TD_L16_R07-(TD_LB_Routine-$02), TD_L17_R07-(TD_LB_Routine-$02), TD_L18_R07-(TD_LB_Routine-$02)
		dc.w	TD_L19_R07-(TD_LB_Routine-$02), TD_L1A_R07-(TD_LB_Routine-$02), TD_L1B_R07-(TD_LB_Routine-$02), TD_L1C_R07-(TD_LB_Routine-$02), TD_L1D_R07-(TD_LB_Routine-$02), TD_L1E_R07-(TD_LB_Routine-$02), TD_L1F_R07-(TD_LB_Routine-$02), TD_L20_R07-(TD_LB_Routine-$02)

; ---------------------------------------------------------------------------
; Bitfield loading subroutines
; ---------------------------------------------------------------------------

addxs		macro
	;	addx.l	d0,d0			; x86 long	; stack it onto d0
		addx.w	d0,d0			; 68k word	; stack it onto d0
		endm

TD_L20_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1F_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1E_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1D_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1C_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1B_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1A_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L19_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L18_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L17_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L16_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L15_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L14_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L13_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L12_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L11_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L10_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0F_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0E_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0D_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0C_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0B_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0A_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L09_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L08_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L07_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L06_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L05_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L04_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L03_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L02_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L01_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
		rts						; return

TD_L20_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1F_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1E_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1D_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1C_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1B_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1A_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L19_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L18_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L17_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L16_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L15_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L14_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L13_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L12_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L11_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L10_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0F_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0E_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0D_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0C_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0B_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0A_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L09_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L08_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L07_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L06_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L05_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L04_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L03_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L02_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L01_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
		rts						; return

TD_L20_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1F_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1E_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1D_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1C_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1B_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1A_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L19_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L18_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L17_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L16_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L15_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L14_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L13_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L12_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L11_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L10_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0F_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0E_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0D_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0C_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0B_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0A_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L09_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L08_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L07_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L06_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L05_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L04_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L03_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L02_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L01_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
		rts						; return

TD_L20_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1F_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1E_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1D_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1C_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1B_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1A_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L19_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L18_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L17_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L16_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L15_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L14_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L13_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L12_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L11_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L10_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0F_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0E_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0D_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0C_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0B_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0A_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L09_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L08_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L07_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L06_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L05_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L04_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L03_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L02_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L01_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
		rts						; return

TD_L20_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1F_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1E_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1D_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1C_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1B_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1A_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L19_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L18_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L17_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L16_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L15_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L14_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L13_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L12_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L11_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L10_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0F_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0E_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0D_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0C_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0B_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0A_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L09_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L08_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L07_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L06_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L05_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L04_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L03_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L02_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L01_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
		rts						; return

TD_L20_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1F_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1E_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1D_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1C_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1B_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1A_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L19_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L18_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L17_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L16_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L15_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L14_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L13_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L12_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L11_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L10_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0F_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0E_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0D_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0C_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0B_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0A_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L09_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L08_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L07_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L06_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L05_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L04_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L03_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L02_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L01_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
		rts						; return

TD_L20_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1F_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1E_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1D_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1C_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1B_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1A_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L19_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L18_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L17_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L16_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L15_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L14_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L13_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L12_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L11_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L10_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0F_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0E_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0D_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0C_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0B_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0A_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L09_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L08_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L07_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L06_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L05_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L04_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L03_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L02_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L01_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
		rts						; return

TD_L20_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1F_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1E_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1D_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1C_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1B_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L1A_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L19_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L18_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L17_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L16_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L15_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L14_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L13_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L12_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L11_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L10_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0F_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0E_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0D_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0C_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0B_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L0A_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L09_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L08_R07:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L07_R06:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L06_R05:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L05_R04:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L04_R03:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L03_R02:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L02_R01:	add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
TD_L01_R00:	move.b	(a0)+,d3				; load bitfield
		add.b	d3,d3					; load next bit to carry
		addxs						; stack it onto d0
		rts						; return

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to flush data to VRAM
; ---------------------------------------------------------------------------

TD_Flush:
		move.w	sr,-(sp)				; store interrupt status
		movem.l	d2/a2,-(sp)				; store register data
		move.w	#$2700,sr				; disable interrupts
		move.w	a1,d0					; load current buffer address
		andi.w	#$FFFE,d0				; keep on even offset
		subi.w	#TwizBuffer,d0				; get size of transfer
		move.l	(TwizVRAM).w,d2				; load VRAM address
		add.w	d0,(TwizVRAM+$02).w			; add size to VRAM address (for next frame)
		lsr.w	#$01,d0					; divide by 2
		move.l	#$93009400,d1				; prepare DMA Size register values
		move.w	d0,-(sp)				; load upper byte
		move.b	(sp),d1					; ''
		addq.w	#$02,sp					; restore stack position
		swap	d1					; load lower byte
		move.b	d0,d1					; ''
		move.l	d1,4(a5)					; set DMA size
		move.l	#$96009500|(((TwizBuffer>>$01)&$FF00)<<$08)|((TwizBuffer>>$01)&$FF),4(a5)	; set DMA source
		move.w	#$9700|(((TwizBuffer>>$01)&$7F0000)>>$10),4(a5)					; ''
		rol.l	#$02,d2					; send upper bits of address to upper word
		ror.w	#$02,d2					; send rest back
		move.w	d2,4(a5)					; set DMA destination
		swap	d2					; get other bits
		move.w	d2,4(a5)				; save to VDP (DMA starts here)
		lea	(a1),a2					; copy to a2
		lea	(TwizBuffer).w,a1			; reload start of buffer
		lea	-TwizBufferSize(a1),a4			; ''
		move.w	a2,d0					; reload current buffer address
		lsr.b	#$01,d0					; shift odd/even bit into carry
		bcc.s	TD_NoCopyBack				; if we're on an even offset, branch
		move.b	(a2)+,(a1)				; copy odd byte back to beginning
		move.b	(a1)+,(a4)+				; ''

TD_NoCopyBack:
		movem.l	(sp)+,d2/a2				; restore register data
		rtr						; return and restore sr

; ===========================================================================