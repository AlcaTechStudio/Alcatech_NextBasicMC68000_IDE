align macro
     cnop 0,\1
     endm
end_global_table equ $ff0626
;dim ram_pointer as long
_global_ram_pointer equ $ff0000
; Auto Declaracao variavel -> for y = 0 to 32
_global_y equ $ff0004
; Auto Declaracao variavel ->  for x=0 to 64
_global_x equ $ff0006
; Auto Declaracao variavel -> offset = 0
_global_offset equ $ff0008
; Auto Declaracao variavel ->   for i=0 to 224
_global_i equ $ff000a
;dim sprite_table[80] as new sprite_shape 'Buffer para a Sprite Table na RAM
_global_sprite_table equ $ff000c
;dim buff_dma[3] as long ' Buffer na RAM que serve de construtor para os comandos do DMA
_global_buff_dma equ $ff028c
;dim H_scroll_buff[448] as integer ' Buffer para a  scroll table
_global_H_scroll_buff equ $ff0298
;dim planes_addr[3] as integer '0=0 1=1 2=Plane_Win
_global_planes_addr equ $ff0618
;dim sprite_table_addr as integer
_global_sprite_table_addr equ $ff061e
;dim scroll_table_addr as integer
_global_scroll_table_addr equ $ff0620
;dim vdp_conf_table_addr as long
_global_vdp_conf_table_addr equ $ff0622

;------------------------
;  Header Vector Table  -
;------------------------
	 ORG $0000
	 dc.l $FFFFFE      
    dc.l inicio_src   
    dc.l isr_buserror
    dc.l isr_addreserror
    dc.l isr_illegalinstruction
    dc.l isr_divisionbyzero
    dc.l isr_chk
    dc.l isr_trapv
    dc.l isr_privilegeviolation
	 ORG $0060
    dc.l isr_Errortrap
    dc.l isr_01_vector
    dc.l isr_02_vector
    dc.l isr_03_vector
    dc.l isr_04_vector
    dc.l isr_05_vector
    dc.l isr_06_vector
    dc.l isr_07_vector
    dc.l trap_00_vector
    dc.l trap_01_vector
    dc.l trap_02_vector
    dc.l trap_03_vector
    dc.l trap_04_vector
    dc.l trap_05_vector
    dc.l trap_06_vector
    dc.l trap_07_vector
    dc.l trap_08_vector
    dc.l trap_09_vector
    dc.l trap_10_vector
    dc.l trap_11_vector
    dc.l trap_12_vector
    dc.l trap_13_vector
    dc.l trap_14_vector
    dc.l trap_15_vector

    ;imports"\system\genesis_header.asm" ' Header de uma ROM de mega Drive Padrao 
    include "C:\workbench\Alcatech_NextBasicMC68000_IDE\utils\system\genesis_header.asm"

    ;std_init()
    bsr std_init

    ;vdp_set_config(addressof(vdp_config_table)) ' Scroll Horizontal modo 8px Strips
    move.l #vdp_config_table,-(a7)
    bsr vdp_set_config
    addq #4,a7

    ;load_tiles_DMA(addressof(tiles),168,1)
    move.l #1,-(a7)
    move.w #168,-(a7)
    move.l #tiles,-(a7)
    bsr load_tiles_DMA
    lea 10(a7),a7

    ;load_cram_DMA(addressof(paleta),16,0)
    move.l #0,-(a7)
    move.w #16,-(a7)
    move.l #paleta,-(a7)
    bsr load_cram_DMA
    lea 10(a7),a7

    ;for y = 0 to 32
    moveq #0,d0
    move.w d0,_global_y
lbl_for_1_start:
    move.w _global_y,d0
    cmp.w #32,d0
    beq lbl_for_1_end

    ; for x=0 to 64
    moveq #0,d0
    move.w d0,_global_x
lbl_for_2_start:
    move.w _global_x,d0
    cmp.w #64,d0
    beq lbl_for_2_end

    ; draw_tile( peek(addressof(mapa) + (x<<1) + (y<<7) as word)+1, x , y , 0)
    move.w #0,-(a7)
    move.w _global_y,-(a7)
    move.w _global_x,-(a7)
    moveq #0,d0
    move.w _global_x,d0
    add.l d0,d0
    moveq #0,d1
    move.w _global_y,d1
    lsl.l #7,d1
    add.l d1,d0
    add.l #mapa,d0
    move.l d0,a0
    move.w (a0),d0
    addq #1,d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7
    moveq #1,d0
    add.w d0,_global_x
    bra lbl_for_2_start

    ; next 
lbl_for_2_end:
    moveq #1,d0
    add.w d0,_global_y
    bra lbl_for_1_start

    ;next 
lbl_for_1_end:

    ;offset = 0
    move.w #0,_global_offset

    ;Do 'main
lbl_do_1_start:

    ;  for i=0 to 224
    moveq #0,d0
    move.w d0,_global_i
lbl_for_3_start:
    move.w _global_i,d0
    cmp.w #224,d0
    beq lbl_for_3_end

    ;  Hscroll_line(peek(addressof(seno)+i+offset as byte),i,0)
    move.w #0,-(a7)
    move.w _global_i,-(a7)
    moveq #0,d0
    move.w _global_i,d0
    moveq #0,d1
    move.w _global_offset,d1
    add.l d1,d0
    add.l #seno,d0
    move.l d0,a0
    moveq #0,d0
    move.b (a0),d0
    move.w d0,-(a7)
    bsr Hscroll_line
    addq #6,a7
    moveq #1,d0
    add.w d0,_global_i
    bra lbl_for_3_start

    ;  next 
lbl_for_3_end:

    ;  offset+=1
    moveq #1,d0
    add.w d0,_global_offset

    ;  if offset>255 then offset=0
    move.w _global_offset,d0
    cmp.w #255,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_1
    bra lbl_if_false_1
lbl_if_true_1:

    ;  if offset>255 then offset=0
    move.w #0,_global_offset
lbl_if_false_1:

    ;  update_Hscroll_table()
    bsr update_Hscroll_table

    ;  wait_Vblank()
    bsr wait_Vblank
    bra lbl_do_1_start
lbl_do_1_end:

    ;Loop ' Laco infinito

    ;sub std_init()  
std_init:

    ;  buff_dma[0]= &h94009300 
    move.l #$94009300,_global_buff_dma+(0<<2)

    ;  buff_dma[1]= &h97009600 
    move.l #$97009600,_global_buff_dma+(1<<2)

    ;  buff_dma[2]= &h95008114 
    move.l #$95008114,_global_buff_dma+(2<<2)

    ;  for i = 0 to 80
    moveq #0,d0
    move.w d0,_global_i
lbl_for_4_start:
    move.w _global_i,d0
    cmp.w #80,d0
    beq lbl_for_4_end

    ;  sprite_table[i].x         = 0
    move.w _global_i,d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w #0,6(a0,d0.w)

    ;  sprite_table[i].size_link = i+1 ' Ordem com que os sprites sao desenhado na tela
    move.w _global_i,d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w _global_i,d1
    addq #1,d1
    move.w d1,2(a0,d0.w)

    ;  sprite_table[i].gfx       = 0
    move.w _global_i,d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w #0,4(a0,d0.w)

    ;  sprite_table[i].y         = 0  
    move.w _global_i,d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w #0,0(a0,d0.w)
    moveq #1,d0
    add.w d0,_global_i
    bra lbl_for_4_start

    ;  next 
lbl_for_4_end:

    ;  sprite_table[79].size_link = 0 ' Ultimo sprite desenhado deve apontar para o primeiro
    move.w #0,(_global_sprite_table+((79*8)+2))

    ;  for i=0 to 448
    moveq #0,d0
    move.w d0,_global_i
lbl_for_5_start:
    move.w _global_i,d0
    cmp.w #448,d0
    beq lbl_for_5_end

    ;  H_scroll_buff[i] = 0
    move.w _global_i,d0
    add.w d0,d0
    lea _global_H_scroll_buff,a0
    move.w #0,0(a0,d0.w)
    moveq #1,d0
    add.w d0,_global_i
    bra lbl_for_5_start

    ;  next 
lbl_for_5_end:

    ;  vdp_set_config(addressof(VDP_Std_Reg_init)) ' Envia configuracao padrao pro VDP
    move.l #VDP_Std_Reg_init,-(a7)
    bsr vdp_set_config
    addq #4,a7

    ;_asm_block #__
        move.l #$C00004,A5
    move.w #$8174,(A5) 
	clr D0
    move.w #$8F01,(A5) 
    move.l #$94000000+(($FFFF&$FF00)<<8)+$9300+($FFFF&$FF),(A5)
    move.w #$9780,(A5)
    move.l #$40000080+(($0000&$3FFF)<<16)+(($0000&$C000)>>14),(A5)
    move.w #$0000,-4(A5)
    nop
@Espera_dma_inicializacao_header_fim:
    btst #1,$C00005
    bne.s @Espera_dma_inicializacao_header_fim
    move.w #$8F02,(A5)
    move.l #$C0000000,(A5)
    move.l #$003F-2,D0
		move.w #$0000,-4(A5)
	    move.w #$0EEE,-4(A5)
@loop_inicalizacao_zera_Cram:
    move.w #$0000,-4(A5)
    dbra D0,@loop_inicalizacao_zera_Cram
    move.w #$0027,D0
    move.l #$40000010,(A5)
@loop_inicalizacao_zera_VSram:
    move.w #$0000,-4(A5)
    dbra D0,@loop_inicalizacao_zera_VSram
	move.w #$8174,(A5)    


    ;__# _asm_block_end
    rts

    ;end sub 

    ;sub vdp_set_config(byval conf_table_addr as long)
vdp_set_config:
    link a6,#-0
; byval _local_conf_table_addr as long
_local_conf_table_addr set 8

    ; vdp_conf_table_addr=conf_table_addr
    move.l (_local_conf_table_addr,a6),_global_vdp_conf_table_addr

    ; planes_addr[0] = peek(conf_table_addr + 2 as byte) << 10 'Endereco Plane A
    move.l (_local_conf_table_addr,a6),d0
    addq #2,d0
    move.l d0,a0
    moveq #0,d0
    move.b (a0),d0
    moveq #10,d1
    lsl.w d1,d0
    move.w d0,_global_planes_addr+(0<<1)

    ; planes_addr[1] = peek(conf_table_addr + 4 as byte) << 13 'Endereco Plane B
    move.l (_local_conf_table_addr,a6),d0
    addq #4,d0
    move.l d0,a0
    moveq #0,d0
    move.b (a0),d0
    moveq #13,d1
    lsl.w d1,d0
    move.w d0,_global_planes_addr+(1<<1)

    ; planes_addr[2] = peek(conf_table_addr + 3 as byte) << 10 'Endereco Plane Window.
    move.l (_local_conf_table_addr,a6),d0
    addq #3,d0
    move.l d0,a0
    moveq #0,d0
    move.b (a0),d0
    moveq #10,d1
    lsl.w d1,d0
    move.w d0,_global_planes_addr+(2<<1)

    ; sprite_table_addr =  peek(conf_table_addr + 5 as byte) << 9 'Endereco spt_table
    move.l (_local_conf_table_addr,a6),d0
    addq #5,d0
    move.l d0,a0
    moveq #0,d0
    move.b (a0),d0
    moveq #9,d1
    lsl.w d1,d0
    move.w d0,_global_sprite_table_addr

    ; scroll_table_addr = peek(conf_table_addr + &h0D as byte) << 10' Endereco da Scroll Table
    move.l (_local_conf_table_addr,a6),d0
    add.l #$0D,d0
    move.l d0,a0
    moveq #0,d0
    move.b (a0),d0
    moveq #10,d1
    lsl.w d1,d0
    move.w d0,_global_scroll_table_addr

    ; push( conf_table_addr as long, "A0")
    move.l (_local_conf_table_addr,a6),A0

    ;_asm_block #__
        move.l #$C00004,A5           
	move.w #$8000,D0
    move.l  #18,D1    
@loop_vdp_config_sub__:
    move.b (A0)+,D0   
    move.w D0,(A5)    
    add.w #$0100,D0   
    dbra D1,@loop_vdp_config_sub__


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub draw_tile(byval tile as integer, byval x_tile_cord as integer, byval y_tile_cord as integer, byval plane as integer )
draw_tile:
    link a6,#-0
; byval _local_tile as word
_local_tile set 8
; byval _local_x_tile_cord as word
_local_x_tile_cord set 10
; byval _local_y_tile_cord as word
_local_y_tile_cord set 12
; byval _local_plane as word
_local_plane set 14

    ; push(  ((x_tile_cord  + ((y_tile_cord)<<6))<<1) + planes_addr[plane] as long, "D0")
    moveq #0,d0
    move.w (_local_x_tile_cord,a6),d0
    moveq #0,d1
    move.w (_local_y_tile_cord,a6),d1
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,d0
    move.w (_local_plane,a6),d1
    add.w d1,d1
    lea _global_planes_addr,a0
    moveq #0,d2
    move.w 0(a0,d1.w),d2
    add.l d2,d0

    ;_asm_block #__
     move.w sr,-(A7)
 move.w #$2700,sr
 lsl.l #2,D0
 lsr.w #2,D0
 swap  D0
 add.l #$40000000,D0
 move.l D0,$C00004
 move.w _local_tile(A6),$C00000
 move.w (A7)+,sr


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub draw_tilemap(byval tm as long, byval s_x as word, byval s_y as word, byval c_x as word,byval c_y as word, byval plane as word, byval offset_ts_k as word)
draw_tilemap:
    link a6,#-0
; byval _local_tm as long
_local_tm set 8
; byval _local_s_x as word
_local_s_x set 12
; byval _local_s_y as word
_local_s_y set 14
; byval _local_c_x as word
_local_c_x set 16
; byval _local_c_y as word
_local_c_y set 18
; byval _local_plane as word
_local_plane set 20
; byval _local_offset_ts_k as word
_local_offset_ts_k set 22

    ;push(((c_x  + ((c_y)<<6))<<1) or planes_addr[plane] as long, "D0")
    moveq #0,d0
    move.w (_local_c_x,a6),d0
    moveq #0,d1
    move.w (_local_c_y,a6),d1
    lsl.l #6,d1
    add.l d1,d0
    add.l d0,d0
    move.w (_local_plane,a6),d1
    add.w d1,d1
    lea _global_planes_addr,a0
    moveq #0,d2
    move.w 0(a0,d1.w),d2
    or.l d2,d0

    ;_asm_block #__
     lea $C00000,A1
 move.l _local_tm(A6),A0
 move.w #1,D1
 sub.w D1,_local_s_y(A6)
 sub.w D1,_local_s_x(A6)
 lsl.l #2,D0
 lsr.w #2,D0
 swap  D0
 or.l #$40000000,D0
 move.w _local_s_y(A6),D4
for_y_dr_tiles_lbl:
 move.l D0,4(A1)
 move.w _local_s_x(A6),D5
for_x_dr_tiles_lbl:
 move.w (A0)+,D3
 add.w  _local_offset_ts_k(A6),D3
 move.w D3,(A1)
 dbra D5,for_x_dr_tiles_lbl
 add.l #$800000,d0
 dbra D4,for_y_dr_tiles_lbl


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;function joypad6b_read(byval jp as integer) as integer
joypad6b_read:
    link a6,#-0
; byval _local_jp as word
_local_jp set 8

    ; push( jp as word, "D1")
    move.w (_local_jp,a6),D1

    ;_asm_block #__
    	moveq #0,D0
    move.l  #$A10003,A0
    add.w   D1,D1
	add.w   D1,A0	
	move.b  #$40,6(a0);(0xA10009)
	move.b  #$40,(a0) ;(0xA10003)
	nop
	nop
	move.b  (a0),d0		
	andi.b	#$3F,d0		
	move.b	#$0,(a0)	
	nop
	nop
	move.b	(a0),d1	
	move.b  #$40,(a0)	
	andi.b	#$30,d1		
	move.b	#$0,(a0)	
	lsl.b	#$2,d1		
	move.b	#$40,(a0)
	or.b	d1,d0		
	move.b  (a0),D1
	move.b  #0,(A0)
	ori.w	#$FFF0, d1
	lsl.w	#8, d1
	or.w    D1,D0
	not.w   d0


    ;__# _asm_block_end

    ; return pop("D0" as word)
    move.w d0,d7
    unlk a6 
    rts

    ;end function 

    ;sub wait_Next_Vblank()
wait_Next_Vblank:

    ;_asm_block #__
    		move.w  $C00004,D0
        btst    #3,D0
		bne.b   wait_Next_vblank
		
        move.w  $C00004,D0
        btst    #3,D0
        beq.b   wait_Next_vblank


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub wait_Vblank()
wait_Vblank:

    ;_asm_block #__
    		move.w  $C00004,D0
        btst    #3,D0
        beq.b   wait_vblank


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub load_tiles_DMA_128ksafe(byval endereco_tiles as long, byval N_tiles as integer, byval end_dest as long)
load_tiles_DMA_128ksafe:
    link a6,#-0
; byval _local_endereco_tiles as long
_local_endereco_tiles set 8
; byval _local_N_tiles as word
_local_N_tiles set 12
; byval _local_end_dest as long
_local_end_dest set 14

    ; push(endereco_tiles as long,"D0")
    move.l (_local_endereco_tiles,a6),D0

    ; push(N_tiles as word,"D1")
    move.w (_local_N_tiles,a6),D1

    ; push(end_dest as long,"D2")
    move.l (_local_end_dest,a6),D2

    ; push(addressof(buff_dma)+10 as long, "A0")
    lea (_global_buff_dma+10),A0

    ;_asm_block #__
     lsr.l #1,D0   
 lsl.w #4,D1   
 lsl.w #5,D2    
 movep.l D0,-7(A0)
 movep.w D1,-9(A0)
 lsl.l #2,D2
 lsr.w #2,D2
 swap D2
 and.w #$3,D2
 or.l #$40000080,D2
 move.l -10(A0),$C00004
 move.l  -6(A0),$C00004
 move.w  -2(A0),$C00004
 move.l      D2,$C00004


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub load_tiles_DMA(byval endereco_tiles as long, byval N_tiles as integer, byval end_dest as long)
load_tiles_DMA:
    link a6,#-0
; byval _local_endereco_tiles as long
_local_endereco_tiles set 8
; byval _local_N_tiles as word
_local_N_tiles set 12
; byval _local_end_dest as long
_local_end_dest set 14

    ; push(endereco_tiles as long,"D0")
    move.l (_local_endereco_tiles,a6),D0

    ; push(N_tiles as word,"D1")
    move.w (_local_N_tiles,a6),D1

    ; push(end_dest as long,"D2")
    move.l (_local_end_dest,a6),D2

    ; push(addressof(buff_dma)+10 as long, "A0")
    lea (_global_buff_dma+10),A0

    ;_asm_block #__
     lsr.l #1,D0   ;Endereco   fonte  pra Words
 lsl.w #4,D1   ;No Tiles copiados pra Words
 lsl.w #5,D2   ;Ender. dest.Tiles pra Bytes
 moveq #0,D3
 sub.w D1,D3
 sub.w D0,D3
 bcs.s @ex_2p_DMA
 bra @ex_DMA
@ex_DMA:
 bsr @executa_DMA
 bra @fim
@ex_2p_DMA:
 add.w D1,D3    
 movem.w D1-D2,-(A7)
 move.w D3,D1     
 bsr @executa_DMA
 movem.w (A7)+,D1-D2 
 sub.w D3,D1   
 add.l D3,D0   
 add.w D3,D3   
 add.w D3,D2   
 bsr.s @executa_DMA
 bra @fim
@executa_DMA:
 movep.l D0,-7(A0)
 movep.w D1,-9(A0)	
 lsl.l #2,D2
 lsr.w #2,D2
 swap D2
 and.w #$3,D2
 or.l #$40000080,D2
 move.l -10(A0),$C00004
 move.l  -6(A0),$C00004
 move.w  -2(A0),$C00004
 move.l      D2,$C00004
 rts
@fim: 


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub load_cram_dma(byval endereco_pal as long, byval N_cores as integer, byval paleta_dest as long)
load_cram_dma:
    link a6,#-0
; byval _local_endereco_pal as long
_local_endereco_pal set 8
; byval _local_N_cores as word
_local_N_cores set 12
; byval _local_paleta_dest as long
_local_paleta_dest set 14

    ;push(endereco_pal as long, "D0")
    move.l (_local_endereco_pal,a6),D0

    ;push(N_cores as word, "D1")
    move.w (_local_N_cores,a6),D1

    ;push(paleta_dest as long, "D2")
    move.l (_local_paleta_dest,a6),D2

    ;push(addressof(buff_dma)+10 as long, "A0")
    lea (_global_buff_dma+10),A0

    ;_asm_block #__
     lsr.l #1,D0  
 lsl.w #5,D2  
 moveq #0,D3
 sub.w D1,D3
 sub.w D0,D3
 bcs.s @ex_2p_DMA_cram
 bra @ex_DMA_cram
@ex_DMA_cram:
 bsr @executa_DMA_cram
 bra @fim_cram
@ex_2p_DMA_cram:
 add.w D1,D3      
 movem.w D1-D2,-(A7)
 move.w D3,D1     
 bsr @executa_DMA_cram
 movem.w (A7)+,D1-D2 
 sub.w D3,D1   
 add.l D3,D0   
 add.w D3,D3   
 add.w D3,D2   
 bsr.s @executa_DMA_cram
 bra @fim_cram
@executa_DMA_cram:
 movep.l D0,-7(A0)
 movep.w D1,-9(A0)	
 swap D2
 or.l #$C0000080,D2
 move.l -10(A0),$C00004
 move.l  -6(A0),$C00004
 move.w  -2(A0),$C00004
 move.l      D2,$C00004
 rts
@fim_cram: 


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub load_cram_dma_128ksafe(byval endereco_pal as long, byval N_cores as integer, byval paleta_dest as long)
load_cram_dma_128ksafe:
    link a6,#-0
; byval _local_endereco_pal as long
_local_endereco_pal set 8
; byval _local_N_cores as word
_local_N_cores set 12
; byval _local_paleta_dest as long
_local_paleta_dest set 14

    ; push(endereco_pal as long, "D0")
    move.l (_local_endereco_pal,a6),D0

    ; push(N_cores as word, "D1")
    move.w (_local_N_cores,a6),D1

    ; push(paleta_dest as long, "D2")
    move.l (_local_paleta_dest,a6),D2

    ; push(addressof(buff_dma)+10 as long, "A0")
    lea (_global_buff_dma+10),A0

    ;_asm_block #__
     lsr.l #1,D0  
 lsl.w #5,D2   
 movep.l D0,-7(A0)
 movep.w D1,-9(A0)	
 swap D2
 or.l #$C0000080,D2
 move.l -10(A0),$C00004
 move.l  -6(A0),$C00004
 move.w  -2(A0),$C00004
 move.l      D2,$C00004


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub set_sprite_gfx(byval sprite_idx as word, byval sprite_gfx_ini as word,byval sprite_pal as word)
set_sprite_gfx:
    link a6,#-0
; byval _local_sprite_idx as word
_local_sprite_idx set 8
; byval _local_sprite_gfx_ini as word
_local_sprite_gfx_ini set 10
; byval _local_sprite_pal as word
_local_sprite_pal set 12

    ;_asm_block #__
      move.w _local_sprite_pal(a6),D1
  lsl.w #8,D1
  lsl.w #5,D1
  or.w _local_sprite_gfx_ini(a6),D1  


    ;__# _asm_block_end

    ;  sprite_table[sprite_idx].gfx = pop("d1" as word)
    move.w (_local_sprite_idx,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w d1,4(a0,d0.w)
    unlk a6 
    rts

    ;end sub

    ;sub set_sprite_position(byval sprite_idx as word, byval sprite_x_pos as word,byval sprite_y_pos as word)
set_sprite_position:
    link a6,#-0
; byval _local_sprite_idx as word
_local_sprite_idx set 8
; byval _local_sprite_x_pos as word
_local_sprite_x_pos set 10
; byval _local_sprite_y_pos as word
_local_sprite_y_pos set 12

    ;  sprite_table[sprite_idx].x = sprite_x_pos AND 511
    move.w (_local_sprite_idx,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w (_local_sprite_x_pos,a6),d1
    and.w #511,d1
    move.w d1,6(a0,d0.w)

    ;  sprite_table[sprite_idx].y = sprite_y_pos AND 511
    move.w (_local_sprite_idx,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w (_local_sprite_y_pos,a6),d1
    and.w #511,d1
    move.w d1,0(a0,d0.w)
    unlk a6 
    rts

    ;end sub

    ;sub set_sprite_size(byval sprite_idx as word,byval sprite_x_size as word,byval sprite_y_size as word)
set_sprite_size:
    link a6,#-0
; byval _local_sprite_idx as word
_local_sprite_idx set 8
; byval _local_sprite_x_size as word
_local_sprite_x_size set 10
; byval _local_sprite_y_size as word
_local_sprite_y_size set 12

    ;   sprite_table[sprite_idx].size_link = sprite_table[sprite_idx].size_link AND &H00FF
    move.w (_local_sprite_idx,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w (_local_sprite_idx,a6),d1
    lsl.w #3,d1
    lea _global_sprite_table,a1
    move.w 2(a1,d1.w),d2
    and.w #$00FF,d2
    move.w d2,2(a0,d0.w)

    ;   sprite_table[sprite_idx].size_link |= ((sprite_x_size << 2) OR sprite_y_size) << 8 
    move.w (_local_sprite_idx,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w (_local_sprite_x_size,a6),d1
    add.w d1,d1
    add.w d1,d1
    or.w (_local_sprite_y_size,a6),d1
    lsl.w #8,d1
    or.w d1,2(a0,d0.w)
    unlk a6 
    rts

    ;end sub  

    ;sub reset_sprite_priority()
reset_sprite_priority:
; Auto Declaracao variavel ->  for _list_ = 0 to 80
_local__list_ set -2
    link a6,#-2

    ; for _list_ = 0 to 80
    moveq #0,d0
    move.w d0,(_local__list_,a6)
lbl_for_6_start:
    move.w (_local__list_,a6),d0
    cmp.w #80,d0
    beq lbl_for_6_end

    ; sprite_table[ _list_ ].size_link = (sprite_table[_list_].size_link AND &HFF00) OR (_list_ +1)
    move.w (_local__list_,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w (_local__list_,a6),d1
    lsl.w #3,d1
    lea _global_sprite_table,a1
    move.w 2(a1,d1.w),d2
    and.w #$FF00,d2
    move.w (_local__list_,a6),d3
    addq #1,d3
    or.w d3,d2
    move.w d2,2(a0,d0.w)
    moveq #1,d0
    add.w d0,(_local__list_,a6)
    bra lbl_for_6_start

    ; next
lbl_for_6_end:

    ; sprite_table[79].size_link = (sprite_table[79].size_link AND &HFF00) 'Ultimo Sprite deve apontar para o primeiro
    move.w (_global_sprite_table+((79*8)+2)),d0
    and.w #$FF00,d0
    move.w d0,(_global_sprite_table+((79*8)+2))
    unlk a6 
    rts

    ;end sub

    ;sub set_sprite_link(byval _sp1_ as integer, byval _link_value_ as integer)
set_sprite_link:
    link a6,#-0
; byval _local__sp1_ as word
_local__sp1_ set 8
; byval _local__link_value_ as word
_local__link_value_ set 10

    ; sprite_table[_sp1_].size_link = (sprite_table[_sp1_].size_link and &hFF00) or (_link_value_ and &H00FF)
    move.w (_local__sp1_,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w (_local__sp1_,a6),d1
    lsl.w #3,d1
    lea _global_sprite_table,a1
    move.w 2(a1,d1.w),d2
    and.w #$FF00,d2
    move.w (_local__link_value_,a6),d3
    and.w #$00FF,d3
    or.w d3,d2
    move.w d2,2(a0,d0.w)
    unlk a6 
    rts

    ; end sub

    ;sub update_sprite_table()
update_sprite_table:

    ; push(addressof(buff_dma)+10 as long, "A0")
    lea (_global_buff_dma+10),A0

    ; push(sprite_table_addr as long,"D2")
    moveq #0,d0
    move.w _global_sprite_table_addr,d0
    move.l d0,D2

    ; push(320 as word,"D1")
    move.w #320,D1

    ; push(addressof(sprite_table)>>1 as long,"D0")
    move.l #(_global_sprite_table>>1),D0

    ;_asm_block #__
     movep.l D0,-7(A0)
 movep.w D1,-9(A0)	
 lsl.l #2,D2
 lsr.w #2,D2
 swap D2
 and.w #$3,D2
 or.l #$40000080,D2
 move.l -10(A0),$C00004
 move.l  -6(A0),$C00004
 move.w  -2(A0),$C00004
 move.l      D2,$C00004


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub Set_VerticalScroll_position(byval cam_V as integer, byval plane as integer)
Set_VerticalScroll_position:
    link a6,#-0
; byval _local_cam_V as word
_local_cam_V set 8
; byval _local_plane as word
_local_plane set 10

    ;  push(Cam_V as word, "D0")
    move.w (_local_Cam_V,a6),D0

    ;  push(plane as word, "D1")
    move.w (_local_plane,a6),D1

    ;_asm_block #__
      add.w D1,D1
  and.l #$0F,D1   ;Estende D1 para 32 Bits
  and.w #$3FF,D0 ;Resto de divisao por 1023
  swap D1
  add.l #$40000010,D1
  move.l D1,$C00004
  move.w D0,$C00000


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub Set_HorizontalScroll_position(byval cam_H as integer, byval plane as integer)
Set_HorizontalScroll_position:
    link a6,#-0
; byval _local_cam_H as word
_local_cam_H set 8
; byval _local_plane as word
_local_plane set 10

    ;  push(512 - cam_H as word, "D0")
    move.w #512,d0
    sub.w (_local_cam_H,a6),d0

    ;  push(plane as word, "D1")
    move.w (_local_plane,a6),D1

    ;_asm_block #__
      add.w D1,D1  
  and.l #$0000000F,D1   ;Ext. D1 para 32 Bits
  add.w _global_scroll_table_addr,D1
  and.w #$3FF,D0 ;Resto de divisao por 1023
  lsl.l #2,D1
  lsr.w #2,D1
  swap D1
  add.l #$40000000,D1
  move.l D1,$C00004
  move.w D0,$C00000


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub Hscroll_strip8(byval cam as integer, byval strip as integer, byval plane as integer )
Hscroll_strip8:
    link a6,#-0
; byval _local_cam as word
_local_cam set 8
; byval _local_strip as word
_local_strip set 10
; byval _local_plane as word
_local_plane set 12

    ;H_scroll_buff[(strip << 4)+plane] =  (512 - cam ) and 511
    move.w (_local_strip,a6),d0
    lsl.w #4,d0
    add.w (_local_plane,a6),d0
    add.w d0,d0
    lea _global_H_scroll_buff,a0
    move.w #512,d1
    sub.w (_local_cam,a6),d1
    and.w #511,d1
    move.w d1,0(a0,d0.w)
    unlk a6 
    rts

    ;end sub

    ;sub Hscroll_line(byval cam as integer, byval line as integer, byval plane as integer )
Hscroll_line:
    link a6,#-0
; byval _local_cam as word
_local_cam set 8
; byval _local_line as word
_local_line set 10
; byval _local_plane as word
_local_plane set 12

    ;H_scroll_buff[(line << 1)+plane] =  (512 - cam ) and 511
    move.w (_local_line,a6),d0
    add.w d0,d0
    add.w (_local_plane,a6),d0
    add.w d0,d0
    lea _global_H_scroll_buff,a0
    move.w #512,d1
    sub.w (_local_cam,a6),d1
    and.w #511,d1
    move.w d1,0(a0,d0.w)
    unlk a6 
    rts

    ;end sub

    ;sub update_Hscroll_table()
update_Hscroll_table:

    ; push(scroll_table_addr as long,"D2")
    moveq #0,d0
    move.w _global_scroll_table_addr,d0
    move.l d0,D2

    ; push(448 as word,"D1")
    move.w #448,D1

    ; push(addressof(H_scroll_buff)>>1 as long,"D0")
    move.l #(_global_H_scroll_buff>>1),D0

    ; push(addressof(buff_dma)+10 as long, "A0")
    lea (_global_buff_dma+10),A0

    ;_asm_block #__
     movep.l D0,-7(A0)
 movep.w D1,-9(A0)	
 lsl.l #2,D2
 lsr.w #2,D2
 swap D2
 and.w #$3,D2
 or.l #$40000080,D2
 move.l -10(A0),$C00004
 move.l  -6(A0),$C00004
 move.w  -2(A0),$C00004
 move.l      D2,$C00004


    ;__# _asm_block_end
    rts

    ;end sub 

    ; sub Enable_Display()
Enable_Display:

    ;_asm_block #__
        move.l _global_vdp_conf_table_addr,A0
    move.w #$8B00,D0
	move.b 1(A0),D0
    or.b #%01000000,D0
	move.w D0,$C00004


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub Disable_Display()
Disable_Display:

    ;_asm_block #__
        move.l _global_vdp_conf_table_addr,A0
    move.w #$8B00,D0
	move.b 1(A0),D0
    and.b #%10111111,D0
	move.w D0,$C00004


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub Enable_global_int()
Enable_global_int:

    ;   _asm("move.w #$2000,sr")
    move.w #$2000,sr
    rts

    ;end sub

    ;sub Disable_global_int()
Disable_global_int:

    ;   _asm("move.w #$2700,sr")
    move.w #$2700,sr
    rts

    ;end sub

    ; sub Enable_v_int()
Enable_v_int:

    ;_asm_block #__
        move.l _global_vdp_conf_table_addr,A0
    move.w #$8100,D0
	move.b 1(A0),D0
    or.b #%00100000,D0
	move.w D0,$C00004


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub Disable_v_int()
Disable_v_int:

    ;_asm_block #__
        move.l _global_vdp_conf_table_addr,A0
    move.w #$8100,D0
	move.b 1(A0),D0
    and.b #%11011111,D0
	move.w D0,$C00004


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub Enable_h_int()
Enable_h_int:

    ;_asm_block #__
        move.l _global_vdp_conf_table_addr,A0
    move.w #$8000,D0
	move.b (A0),D0
    or.b #%00010000,D0
	move.w D0,$C00004


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub Disable_h_int()
Disable_h_int:

    ;_asm_block #__
        move.l _global_vdp_conf_table_addr,A0
    move.w #$8000,D0
	move.b (A0),D0
    and.b #%11101111,D0
	move.w D0,$C00004


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub Enable_Ext_int()
Enable_Ext_int:

    ;_asm_block #__
        move.l _global_vdp_conf_table_addr,A0
    move.w #$8B00,D0
	move.b 11(A0),D0
    or.b #%00001000,D0
	move.w D0,$C00004


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub Disable_Ext_int()
Disable_Ext_int:

    ;_asm_block #__
        move.l _global_vdp_conf_table_addr,A0
    move.w #$8B00,D0
	move.b 11(A0),D0
    and.b #%11110111,D0
	move.w D0,$C00004


    ;__# _asm_block_end
    rts

    ;end sub

    ;sub set_hint_counter( byval count as integer)
set_hint_counter:
    link a6,#-0
; byval _local_count as word
_local_count set 8

    ; push( ((count AND &h00FF) + &h8A00) as word, "D0")
    move.w (_local_count,a6),d0
    and.w #$00FF,d0
    add.w #$8A00,d0

    ; _asm("move.w D0,$C00004")
    move.w D0,$C00004
    unlk a6 
    rts

    ;end sub

    ;sub direct_color_DMA(byval addr as long, byval frames as integer)
direct_color_DMA:
    link a6,#-0
; byval _local_addr as long
_local_addr set 8
; byval _local_frames as word
_local_frames set 12

    ; disable_global_int()
    bsr disable_global_int

    ; push(addressof(buff_dma)+10 as long, "A0")
    lea (_global_buff_dma+10),A0

    ; push(&hAD40 as word,"D1")
    move.w #$AD40,D1

    ; push(addr>>1 as long,"D0")
    move.l (_local_addr,a6),d0
    lsr.l #1,d0

    ; push(frames as word ,"D4")
    move.w (_local_frames,a6),D4

    ;_asm_block #__
       movep.l D0,-7(A0)
   movep.w D1,-9(A0)	
   move.l #$C00004,A2
   
   move.l #$00000020,(A2)
   move.w -4(A2),-(A7)
   
   moveq #0,D0
   move.w  #$8F00,(A2)    
   
dcd_bgf__:  
    lea _global_buff_dma,A0
    move.w  #$8154,(A2)            
    move.l  #$40000000,(A2)        
VB_inicio:
    btst    #3,1(A2)
    beq.b   VB_inicio              
VB_Fim:
    btst    #3,1(A2)
    bne.b   VB_Fim                 
    move.l  d0,-4(A2)
    move.l  d0,-4(A2)
    move.l  d0,-4(A2)
    move.l  d0,-4(A2)
    move.l  d0,-4(A2)
    move.l  d0,-4(A2)
    move.w  d0,-4(A2)
    nop
    nop
    nop
    nop 
    move.l (A0)+,(A2)
    move.l (A0)+,(A2)
    move.l (A0),(A2)
    move.l #$C0000080,(A2)
    dbra D4,dcd_bgf__

    move.l _global_vdp_conf_table_addr,A0
	move.w #$8100,D0
	move.b 1(A0),D0
	move.w D0,(A2)
    move.w #$8F00,D0
	move.b 15(A0),D0
	move.w D0,(A2)
    move.l #$C0000000,(A2)
    move.w (A7)+,-4(A2)
	


    ;__# _asm_block_end

    ; enable_global_int()
    bsr enable_global_int
    unlk a6 
    rts

    ;end sub

    ;sub wait_frames(byval nframes as integer)
wait_frames:
    link a6,#-0
; byval _local_nframes as word
_local_nframes set 8

    ;  push( nframes as long, "D0")
    moveq #0,d0
    move.w (_local_nframes,a6),d0

    ;_asm_block #__
    	lea $C00004,A0
@act_disp:
	move.w	(A0),d1
	btst	#3,d1
	beq	@act_disp
@vb_in_pg:
	move.w	(A0),d1
	btst	#3,d1
	bne	@vb_in_pg
	dbra D0,@act_disp


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;imports"\mapa.bin"
    even
mapa:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Scroll_lines\mapa.bin" 

    ;imports"\tiles.bin"
    even
tiles:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Scroll_lines\tiles.bin" 
    even
VDP_std_Reg_init:
    dc.b $04
    dc.b $74
    dc.b $30
    dc.b $40
    dc.b $07
    dc.b $78
    dc.b $00
    dc.b $00
    dc.b $00
    dc.b $00
    dc.b $08
    dc.b $00
    dc.b $81
    dc.b $3F
    dc.b $00
    dc.b $02
    dc.b $01
    dc.b $00
    dc.b $00
    dc.b $00
    even
paleta:
    dc.w $0000,$0000,$00A0,$0E22,$0400,$002C,$0006,$0EA2
    dc.w $02CE,$0046,$0040,$0C0C,$0606,$0666,$0660,$0CEE
    even
vdp_config_table:
    dc.b $04
    dc.b $74
    dc.b $30
    dc.b $40
    dc.b $07
    dc.b $78
    dc.b $00
    dc.b $00
    dc.b $00
    dc.b $00
    dc.b $1C
    dc.b $03
    dc.b $81
    dc.b $3F
    dc.b $00
    dc.b $02
    dc.b $01
    dc.b $00
    dc.b $00
    dc.b $00
    even
seno:
    dc.b 128,131,134,137,140,143,146,149,152,156,159,162,165,168,171,174
    dc.b 176,179,182,185,188,191,193,196,199,201,204,206,209,211,213,216
    dc.b 218,220,222,224,226,228,230,232,234,236,237,239,240,242,243,245
    dc.b 246,247,248,249,250,251,252,252,253,254,254,255,255,255,255,255
    dc.b 255,255,255,255,255,255,254,254,253,252,252,251,250,249,248,247
    dc.b 246,245,243,242,240,239,237,236,234,232,230,228,226,224,222,220
    dc.b 218,216,213,211,209,206,204,201,199,196,193,191,188,185,182,179
    dc.b 176,174,171,168,165,162,159,156,152,149,146,143,140,137,134,131
    dc.b 128,124,121,118,115,112,109,106,103,099,096,093,090,087,084,081
    dc.b 079,076,073,070,067,064,062,059,056,054,051,049,046,044,042,039
    dc.b 037,035,033,031,029,027,025,023,021,019,018,016,015,013,012,010
    dc.b 009,008,007,006,005,004,003,003,002,001,001,000,000,000,000,000
    dc.b 000,000,000,000,000,000,001,001,002,003,003,004,005,006,007,008
    dc.b 009,010,012,013,015,016,018,019,021,023,025,027,029,031,033,035
    dc.b 037,039,042,044,046,049,051,054,056,059,062,064,067,070,073,076
    dc.b 079,081,084,087,090,093,096,099,103,106,109,112,115,118,121,124
    dc.b 128,131,134,137,140,143,146,149,152,156,159,162,165,168,171,174
    dc.b 176,179,182,185,188,191,193,196,199,201,204,206,209,211,213,216
    dc.b 218,220,222,224,226,228,230,232,234,236,237,239,240,242,243,245
    dc.b 246,247,248,249,250,251,252,252,253,254,254,255,255,255,255,255
    dc.b 255,255,255,255,255,255,254,254,253,252,252,251,250,249,248,247
    dc.b 246,245,243,242,240,239,237,236,234,232,230,228,226,224,222,220
    dc.b 218,216,213,211,209,206,204,201,199,196,193,191,188,185,182,179
    dc.b 176,174,171,168,165,162,159,156,152,149,146,143,140,137,134,131
    dc.b 128,124,121,118,115,112,109,106,103,099,096,093,090,087,084,081
    dc.b 079,076,073,070,067,064,062,059,056,054,051,049,046,044,042,039
    dc.b 037,035,033,031,029,027,025,023,021,019,018,016,015,013,012,010
    dc.b 009,008,007,006,005,004,003,003,002,001,001,000,000,000,000,000
    dc.b 000,000,000,000,000,000,001,001,002,003,003,004,005,006,007,008
    dc.b 009,010,012,013,015,016,018,019,021,023,025,027,029,031,033,035
    dc.b 037,039,042,044,046,049,051,054,056,059,062,064,067,070,073,076
    dc.b 079,081,084,087,090,093,096,099,103,106,109,112,115,118,121,124
    even    
isr_01_vector:
    rte
isr_02_vector:
    rte
isr_03_vector:
    rte
isr_04_vector:
    rte
isr_05_vector:
    rte
isr_06_vector:
    rte
isr_07_vector:
    rte
isr_buserror:
isr_addreserror:
isr_illegalinstruction:
isr_divisionbyzero:
isr_chk:
isr_trapv:
isr_privilegeviolation:
isr_errortrap:
trap_00_vector:
trap_01_vector:
trap_02_vector:
trap_03_vector:
trap_04_vector:
trap_05_vector:
trap_06_vector:
trap_07_vector:
trap_08_vector:
trap_09_vector:
trap_10_vector:
trap_11_vector:
trap_12_vector:
trap_13_vector:
trap_14_vector:
trap_15_vector:
    move.l 'F',D0
    move.l 'U',D1
    move.l 'C',D2
    move.l 'K',D3
exception_generic_auto_generated_code:
    bra.s exception_generic_auto_generated_code
    rte
Fim_ROM: