align macro
     cnop 0,\1
     endm
end_global_table equ $ff0630
;dim ram_pointer as long
_global_ram_pointer equ $ff0000
; Auto Declaracao variavel -> for y = 0 to 32
_global_y equ $ff0004
; Auto Declaracao variavel ->  for x=0 to 64
_global_x equ $ff0006
; Auto Declaracao variavel ->   j = joypad6b_read(0)
_global_j equ $ff0008
; Auto Declaracao variavel ->   if lastj <> j AND j.4 = 1 then
_global_lastj equ $ff000a
; Auto Declaracao variavel ->  vb_flag = 1
_global_vb_flag equ $ff000c
;dim sprite_table[80] as new sprite_shape 'Buffer para a Sprite Table na RAM
_global_sprite_table equ $ff000e
;dim buff_dma[3] as long ' Buffer na RAM que serve de construtor para os comandos do DMA
_global_buff_dma equ $ff028e
;dim H_scroll_buff[448] as integer ' Buffer para a  scroll table
_global_H_scroll_buff equ $ff029a
;dim planes_addr[3] as integer '0=0 1=1 2=Plane_Win
_global_planes_addr equ $ff061a
;dim sprite_table_addr as integer
_global_sprite_table_addr equ $ff0620
;dim scroll_table_addr as integer
_global_scroll_table_addr equ $ff0622
;dim vdp_conf_table_addr as long
_global_vdp_conf_table_addr equ $ff0624
;dim __dma_queue_lenght__ as integer
_global___dma_queue_lenght__ equ $ff0628
;dim __dma_queue_max_lenght__ as integer
_global___dma_queue_max_lenght__ equ $ff062a
;dim __DMA_queue_buff_addr__ as long
_global___DMA_queue_buff_addr__ equ $ff062c

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

    ;dma_Queue_init(10)
    move.w #10,-(a7)
    bsr dma_Queue_init
    addq #2,a7

    ;dma_add_Queue(addressof(tiles),168,1) 'Adiciona na Fila de DMA a tranferencia de 168 Tiles copiados para a posicao 1 da VRAM
    move.l #1,-(a7)
    move.w #168,-(a7)
    move.l #tiles,-(a7)
    bsr dma_add_Queue
    lea 10(a7),a7

    ;dma_CRAM_add_Queue(addressof(paleta),16,0)
    move.l #0,-(a7)
    move.w #16,-(a7)
    move.l #paleta,-(a7)
    bsr dma_CRAM_add_Queue
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

    ;x=0
    move.w #0,_global_x

    ;y=0
    move.w #0,_global_y

    ;Enable_global_int()
    bsr Enable_global_int

    ;Do 'main
lbl_do_1_start:

    ;  j = joypad6b_read(0)
    move.w #0,-(a7)
    bsr joypad6b_read
    addq #2,a7
    move.w d7,_global_j

    ;  if lastj <> j AND j.4 = 1 then
    move.w _global_lastj,d0
    cmp.w _global_j,d0
    sne d0
    and.w #$01,d0
    move.w _global_j,d1
    btst #4,d1
    sne d1
    and.w #$01,d1
    cmp.w #1,d1
    seq d1
    and.w #$01,d1
    and.w d1,d0
    dbra d0,lbl_if_true_1
    bra lbl_if_false_1
lbl_if_true_1:

    ;   dma_add_Queue(addressof(tiles)+4*32,1,6+1)
    move.l #(6+1),-(a7)
    move.w #1,-(a7)
    move.l #(tiles+(4*32)),-(a7)
    bsr dma_add_Queue
    lea 10(a7),a7

    ;    dma_add_Queue(addressof(tiles)+5*32,1,7+1)
    move.l #(7+1),-(a7)
    move.w #1,-(a7)
    move.l #(tiles+(5*32)),-(a7)
    bsr dma_add_Queue
    lea 10(a7),a7

    ;     dma_add_Queue(addressof(tiles)+88*32,1,90+1)
    move.l #(90+1),-(a7)
    move.w #1,-(a7)
    move.l #(tiles+(88*32)),-(a7)
    bsr dma_add_Queue
    lea 10(a7),a7

    ;      dma_add_Queue(addressof(tiles)+89*32,1,91+1)
    move.l #(91+1),-(a7)
    move.w #1,-(a7)
    move.l #(tiles+(89*32)),-(a7)
    bsr dma_add_Queue
    lea 10(a7),a7
    bra lbl_if_end_1
lbl_if_false_1:

    ;  else if lastj <> j AND j.6 = 1 then
    move.w _global_lastj,d0
    cmp.w _global_j,d0
    sne d0
    and.w #$01,d0
    move.w _global_j,d1
    btst #6,d1
    sne d1
    and.w #$01,d1
    cmp.w #1,d1
    seq d1
    and.w #$01,d1
    and.w d1,d0
    dbra d0,lbl_elseif_true_2
    bra lbl_elseif_false_2
lbl_elseif_true_2:

    ;   dma_add_Queue(addressof(tiles)+6*32,1,6+1)
    move.l #(6+1),-(a7)
    move.w #1,-(a7)
    move.l #(tiles+(6*32)),-(a7)
    bsr dma_add_Queue
    lea 10(a7),a7

    ;    dma_add_Queue(addressof(tiles)+7*32,1,7+1)
    move.l #(7+1),-(a7)
    move.w #1,-(a7)
    move.l #(tiles+(7*32)),-(a7)
    bsr dma_add_Queue
    lea 10(a7),a7

    ;     dma_add_Queue(addressof(tiles)+90*32,1,90+1)
    move.l #(90+1),-(a7)
    move.w #1,-(a7)
    move.l #(tiles+(90*32)),-(a7)
    bsr dma_add_Queue
    lea 10(a7),a7

    ;      dma_add_Queue(addressof(tiles)+91*32,1,91+1)
    move.l #(91+1),-(a7)
    move.w #1,-(a7)
    move.l #(tiles+(91*32)),-(a7)
    bsr dma_add_Queue
    lea 10(a7),a7
    bra lbl_if_end_1
lbl_elseif_false_2:
lbl_if_end_1:

    ;  if bit_test(j, 2) then 
    move.w _global_j,d0
    btst #2,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_if_true_3
    bra lbl_if_false_3
lbl_if_true_3:

    ;  x -= 1
    moveq #1,d0
    sub.w d0,_global_x
    bra lbl_if_end_3
lbl_if_false_3:

    ;  elseif bit_test(j, 3) then
    move.w _global_j,d0
    btst #3,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_4
    bra lbl_elseif_false_4
lbl_elseif_true_4:

    ;  x +=1  
    moveq #1,d0
    add.w d0,_global_x
    bra lbl_if_end_3
lbl_elseif_false_4:
lbl_if_end_3:

    ;  if x <  0  then x = 0   ' Seria equivalente a x > 32767 numa variavel unsigned
    move.w _global_x,d0
    tst.w d0
    slt d0
    and.w #$01,d0
    dbra d0,lbl_if_true_5
    bra lbl_if_false_5
lbl_if_true_5:

    ;  if x <  0  then x = 0   ' Seria equivalente a x > 32767 numa variavel unsigned
    move.w #0,_global_x
lbl_if_false_5:

    ;  if x > 192 then x = 192
    move.w _global_x,d0
    cmp.w #192,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_6
    bra lbl_if_false_6
lbl_if_true_6:

    ;  if x > 192 then x = 192
    move.w #192,_global_x
lbl_if_false_6:

    ;  if bit_test(j, 0) then
    move.w _global_j,d0
    btst #0,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_if_true_7
    bra lbl_if_false_7
lbl_if_true_7:

    ;  y-=1
    moveq #1,d0
    sub.w d0,_global_y
    bra lbl_if_end_7
lbl_if_false_7:

    ;  elseif bit_test(j, 1) then
    move.w _global_j,d0
    btst #1,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_8
    bra lbl_elseif_false_8
lbl_elseif_true_8:

    ;  y+=1  
    moveq #1,d0
    add.w d0,_global_y
    bra lbl_if_end_7
lbl_elseif_false_8:
lbl_if_end_7:

    ;  if y < 0 then y = 0 
    move.w _global_y,d0
    tst.w d0
    slt d0
    and.w #$01,d0
    dbra d0,lbl_if_true_9
    bra lbl_if_false_9
lbl_if_true_9:

    ;  if y < 0 then y = 0 
    move.w #0,_global_y
lbl_if_false_9:

    ;  if y > 32    then y = 32
    move.w _global_y,d0
    cmp.w #32,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_10
    bra lbl_if_false_10
lbl_if_true_10:

    ;  if y > 32    then y = 32
    move.w #32,_global_y
lbl_if_false_10:

    ;  lastJ  = j
    move.w _global_j,_global_lastJ

    ;  Set_HorizontalScroll_position(x AND 511,0)
    move.w #0,-(a7)
    move.w _global_x,d0
    and.w #511,d0
    move.w d0,-(a7)
    bsr Set_HorizontalScroll_position
    addq #4,a7

    ;  Set_VerticalScroll_position(y AND 255,0)
    move.w #0,-(a7)
    move.w _global_y,d0
    and.w #255,d0
    move.w d0,-(a7)
    bsr Set_VerticalScroll_position
    addq #4,a7

    ; vb_flag = 1
    move.w #1,_global_vb_flag

    ; while(vb_flag) : wend 
lbl_while_start_1:
    tst.w _global_vb_flag
    bne lbl_while_true_1
    bra lbl_while_false_1
lbl_while_true_1:
    bra lbl_while_start_1

    ; while(vb_flag) : wend 
lbl_while_false_1:
    bra lbl_do_1_start
lbl_do_1_end:

    ;Loop ' Laco infinito

    ;sub isr_06_vector()
isr_06_vector:
    movem.l d0-d6/a0-a5,-(a7)

    ; vb_flag = 0
    move.w #0,_global_vb_flag

    ; DMA_Queue_Transfer() ' Realiza todas as transferencias de DMA na fila
    bsr DMA_Queue_Transfer

    ; update_sprite_table() 'Atualiza a Sprite Table
    bsr update_sprite_table

    movem.l (a7)+,d0-d6/a0-a5
    rte

    ;end sub

    ;sub std_init()  
std_init:
; Auto Declaracao variavel ->   for i = 0 to 80
_local_i set -2
    link a6,#-2

    ;  buff_dma[0]= &h94009300 
    move.l #$94009300,_global_buff_dma+(0<<2)

    ;  buff_dma[1]= &h97009600 
    move.l #$97009600,_global_buff_dma+(1<<2)

    ;  buff_dma[2]= &h95008114 
    move.l #$95008114,_global_buff_dma+(2<<2)

    ;  for i = 0 to 80
    moveq #0,d0
    move.w d0,(_local_i,a6)
lbl_for_3_start:
    move.w (_local_i,a6),d0
    cmp.w #80,d0
    beq lbl_for_3_end

    ;  sprite_table[i].x         = 0
    move.w (_local_i,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w #0,6(a0,d0.w)

    ;  sprite_table[i].size_link = i+1 ' Ordem com que os sprites sao desenhado na tela
    move.w (_local_i,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w (_local_i,a6),d1
    addq #1,d1
    move.w d1,2(a0,d0.w)

    ;  sprite_table[i].gfx       = 0
    move.w (_local_i,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w #0,4(a0,d0.w)

    ;  sprite_table[i].y         = 0  
    move.w (_local_i,a6),d0
    lsl.w #3,d0
    lea _global_sprite_table,a0
    move.w #0,0(a0,d0.w)
    moveq #1,d0
    add.w d0,(_local_i,a6)
    bra lbl_for_3_start

    ;  next 
lbl_for_3_end:

    ;  sprite_table[79].size_link = 0 ' Ultimo sprite desenhado deve apontar para o primeiro
    move.w #0,(_global_sprite_table+((79*8)+2))

    ;  for i=0 to 448
    moveq #0,d0
    move.w d0,(_local_i,a6)
lbl_for_4_start:
    move.w (_local_i,a6),d0
    cmp.w #448,d0
    beq lbl_for_4_end

    ;  H_scroll_buff[i] = 0
    move.w (_local_i,a6),d0
    add.w d0,d0
    lea _global_H_scroll_buff,a0
    move.w #0,0(a0,d0.w)
    moveq #1,d0
    add.w d0,(_local_i,a6)
    bra lbl_for_4_start

    ;  next 
lbl_for_4_end:

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
    unlk a6 
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
lbl_for_5_start:
    move.w (_local__list_,a6),d0
    cmp.w #80,d0
    beq lbl_for_5_end

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
    bra lbl_for_5_start

    ; next
lbl_for_5_end:

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

    ;sub dma_Queue_init(byval __size__ as integer)
dma_Queue_init:
; Auto Declaracao variavel ->  for loc_i = 0 to __size__
_local_loc_i set -2
    link a6,#-2
; byval _local___size__ as word
_local___size__ set 8

    ; __dma_queue_lenght__ = 0
    move.w #0,_global___dma_queue_lenght__

    ; __dma_queue_max_lenght__ = __size__
    move.w (_local___size__,a6),_global___dma_queue_max_lenght__

    ; __DMA_queue_buff_addr__ = ram_pointer
    move.l _global_ram_pointer,_global___DMA_queue_buff_addr__

    ; ram_pointer += __size__ << 4
    moveq #0,d0
    move.w (_local___size__,a6),d0
    lsl.l #4,d0
    add.l d0,_global_ram_pointer

    ; for loc_i = 0 to __size__
    moveq #0,d0
    move.w d0,(_local_loc_i,a6)
lbl_for_6_start:
    move.w (_local_loc_i,a6),d0
    cmp.w (_local___size__,a6),d0
    beq lbl_for_6_end

    ;  poke(&h94009300 as long, (__DMA_queue_buff_addr__ + (loc_i <<4))   )
    moveq #0,d0
    move.w (_local_loc_i,a6),d0
    lsl.l #4,d0
    add.l _global___DMA_queue_buff_addr__,d0
    move.l d0,a0
    move.l #$94009300,(a0)

    ;  poke(&h97009600 as long, (__DMA_queue_buff_addr__ + (loc_i <<4)+4) )
    moveq #0,d0
    move.w (_local_loc_i,a6),d0
    lsl.l #4,d0
    addq #4,d0
    add.l _global___DMA_queue_buff_addr__,d0
    move.l d0,a0
    move.l #$97009600,(a0)

    ;  poke(&h95008114 as long, (__DMA_queue_buff_addr__ + (loc_i <<4)+8) )
    moveq #0,d0
    move.w (_local_loc_i,a6),d0
    lsl.l #4,d0
    addq #8,d0
    add.l _global___DMA_queue_buff_addr__,d0
    move.l d0,a0
    move.l #$95008114,(a0)
    moveq #1,d0
    add.w d0,(_local_loc_i,a6)
    bra lbl_for_6_start

    ; next
lbl_for_6_end:
    unlk a6 
    rts

    ;end sub

    ;sub dma_add_Queue(byval endereco_tiles as long, byval N_tiles as integer, byval end_dest as long)
dma_add_Queue:
    link a6,#-0
; byval _local_endereco_tiles as long
_local_endereco_tiles set 8
; byval _local_N_tiles as word
_local_N_tiles set 12
; byval _local_end_dest as long
_local_end_dest set 14

    ; if ((__dma_queue_lenght__+2) > __dma_queue_max_lenght__) then return 'Buffer Overflow
    move.w _global___dma_queue_lenght__,d0
    addq #2,d0
    cmp.w _global___dma_queue_max_lenght__,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_11
    bra lbl_if_false_11
lbl_if_true_11:

    ; if ((__dma_queue_lenght__+2) > __dma_queue_max_lenght__) then return 'Buffer Overflow
    unlk a6 
    rts
lbl_if_false_11:

    ; push((__DMA_queue_buff_addr__ + (__dma_queue_lenght__ <<4))+10 as long, "A0")
    moveq #0,d0
    move.w _global___dma_queue_lenght__,d0
    lsl.l #4,d0
    add.l _global___DMA_queue_buff_addr__,d0
    add.l #10,d0
    move.l d0,A0

    ; push(endereco_tiles as long,"D0")
    move.l (_local_endereco_tiles,a6),D0

    ; push(N_tiles as word,"D1")
    move.w (_local_N_tiles,a6),D1

    ; push(end_dest as long,"D2")
    move.l (_local_end_dest,a6),D2

    ;_asm_block #__
     lsr.l #1,D0   ;Endereco   fonte  pra Words
 lsl.w #4,D1   ;No Tiles copiados pra Words
 lsl.w #5,D2   ;Ender. dest.Tiles pra Bytes
 moveq #0,D3
 sub.w D1,D3
 sub.w D0,D3
 bcs.s @ex_2p_DMAQ
 bra @ex_DMAQ
 @ex_DMAQ:
 bsr @executa_DMAQ
 bra @fimQ
 @ex_2p_DMAQ:
 add.w D1,D3    
 movem.w D1-D2,-(A7)
 move.w D3,D1     
 bsr @executa_DMAQ
 movem.w (A7)+,D1-D2 
 sub.w D3,D1   
 add.l D3,D0   
 add.w D3,D3   
 add.w D3,D2   
 bsr.s @executa_DMAQ
 bra @fimQ
 @executa_DMAQ:
 movep.l D0,-7(A0)
 movep.w D1,-9(A0)	
 lsl.l #2,D2
 lsr.w #2,D2
 swap D2
 and.w #$3,D2
 or.l #$40000080,D2
 move.w      D2,2(A0)
 swap D2
 move.w      D2,(A0)
 adda       #16,A0
 moveq       #1,D4
 add.w     D4,_global___dma_queue_lenght__
 rts
 @fimQ: 


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub dma_CRAM_add_Queue(byval endereco_pal as long, byval N_cores as integer, byval paleta_dest as long)
dma_CRAM_add_Queue:
    link a6,#-0
; byval _local_endereco_pal as long
_local_endereco_pal set 8
; byval _local_N_cores as word
_local_N_cores set 12
; byval _local_paleta_dest as long
_local_paleta_dest set 14

    ; if ((__dma_queue_lenght__+2) > __dma_queue_max_lenght__) then return 'Buffer Overflow
    move.w _global___dma_queue_lenght__,d0
    addq #2,d0
    cmp.w _global___dma_queue_max_lenght__,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_12
    bra lbl_if_false_12
lbl_if_true_12:

    ; if ((__dma_queue_lenght__+2) > __dma_queue_max_lenght__) then return 'Buffer Overflow
    unlk a6 
    rts
lbl_if_false_12:

    ; push((__DMA_queue_buff_addr__ + (__dma_queue_lenght__ <<4))+10 as long, "A0")
    moveq #0,d0
    move.w _global___dma_queue_lenght__,d0
    lsl.l #4,d0
    add.l _global___DMA_queue_buff_addr__,d0
    add.l #10,d0
    move.l d0,A0

    ; push(endereco_pal as long, "D0")
    move.l (_local_endereco_pal,a6),D0

    ; push(N_cores as word, "D1")
    move.w (_local_N_cores,a6),D1

    ; push(paleta_dest as long, "D2")
    move.l (_local_paleta_dest,a6),D2

    ;_asm_block #__
     lsr.l #1,D0  
 lsl.w #5,D2  
 moveq #0,D3
 sub.w D1,D3
 sub.w D0,D3
 bcs.s @ex_2p_DMAQ_cram
 bra @ex_DMAQ_cram
 @ex_DMAQ_cram:
 bsr @executa_DMAQ_cram
 bra @fim_cramQ
 @ex_2p_DMAQ_cram:
 add.w D1,D3      
 movem.w D1-D2,-(A7)
 move.w D3,D1     
 bsr @executa_DMAQ_cram
 movem.w (A7)+,D1-D2 
 sub.w D3,D1   
 add.l D3,D0   
 add.w D3,D3   
 add.w D3,D2   
 bsr.s @executa_DMAQ_cram
 bra @fim_cramQ
 @executa_DMAQ_cram:
 movep.l D0,-7(A0)
 movep.w D1,-9(A0)	
 swap D2
 or.l #$C0000080,D2
 move.w      D2,2(A0)
 swap D2
 move.w      D2,(A0)
 adda       #16,A0
 moveq       #1,D4
 add.w     D4,_global___dma_queue_lenght__
 rts
 @fim_cramQ: 


    ;__# _asm_block_end
    unlk a6 
    rts

    ;end sub

    ;sub dma_CRAM_add_Queue_128ksafe(byval endereco_pal as long, byval N_cores as integer, byval paleta_dest as long)
dma_CRAM_add_Queue_128ksafe:
    link a6,#-0
; byval _local_endereco_pal as long
_local_endereco_pal set 8
; byval _local_N_cores as word
_local_N_cores set 12
; byval _local_paleta_dest as long
_local_paleta_dest set 14

    ; if ((__dma_queue_lenght__+1) > __dma_queue_max_lenght__) then return 'Buffer Overflow
    move.w _global___dma_queue_lenght__,d0
    addq #1,d0
    cmp.w _global___dma_queue_max_lenght__,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_13
    bra lbl_if_false_13
lbl_if_true_13:

    ; if ((__dma_queue_lenght__+1) > __dma_queue_max_lenght__) then return 'Buffer Overflow
    unlk a6 
    rts
lbl_if_false_13:

    ; push((__DMA_queue_buff_addr__ + (__dma_queue_lenght__ <<4))+10 as long, "A0")
    moveq #0,d0
    move.w _global___dma_queue_lenght__,d0
    lsl.l #4,d0
    add.l _global___DMA_queue_buff_addr__,d0
    add.l #10,d0
    move.l d0,A0

    ; push(endereco_pal as long, "D0")
    move.l (_local_endereco_pal,a6),D0

    ; push(N_cores as word, "D1")
    move.w (_local_N_cores,a6),D1

    ; push(paleta_dest as long, "D2")
    move.l (_local_paleta_dest,a6),D2

    ;_asm_block #__
     lsr.l #1,D0  
 lsl.w #5,D2   
 movep.l D0,-7(A0)
 movep.w D1,-9(A0)	
 swap D2
 or.l #$C0000080,D2
 move.w      D2,2(A0)
 swap D2
 move.w      D2,(A0)


    ;__# _asm_block_end

    ; __dma_queue_lenght__+=1
    moveq #1,d0
    add.w d0,_global___dma_queue_lenght__
    unlk a6 
    rts

    ;end sub

    ;sub dma_add_Queue_128ksafe(byval __tiles_addr__ as long, byval __N_tiles__ as integer, byval __addr_dest__ as long)
dma_add_Queue_128ksafe:
    link a6,#-0
; byval _local___tiles_addr__ as long
_local___tiles_addr__ set 8
; byval _local___N_tiles__ as word
_local___N_tiles__ set 12
; byval _local___addr_dest__ as long
_local___addr_dest__ set 14

    ; if ((__dma_queue_lenght__+1) > __dma_queue_max_lenght__) then return 'Buffer Overflow
    move.w _global___dma_queue_lenght__,d0
    addq #1,d0
    cmp.w _global___dma_queue_max_lenght__,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_14
    bra lbl_if_false_14
lbl_if_true_14:

    ; if ((__dma_queue_lenght__+1) > __dma_queue_max_lenght__) then return 'Buffer Overflow
    unlk a6 
    rts
lbl_if_false_14:

    ; push((__DMA_queue_buff_addr__ + (__dma_queue_lenght__ <<4))+10 as long, "A0")
    moveq #0,d0
    move.w _global___dma_queue_lenght__,d0
    lsl.l #4,d0
    add.l _global___DMA_queue_buff_addr__,d0
    add.l #10,d0
    move.l d0,A0

    ; push(__tiles_addr__ as long,"D0")
    move.l (_local___tiles_addr__,a6),D0

    ; push(__N_tiles__ as word,"D1")
    move.w (_local___N_tiles__,a6),D1

    ; push(__addr_dest__ as long,"D2")
    move.l (_local___addr_dest__,a6),D2

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
 move.w      D2,2(A0)
 swap D2
 move.w      D2,(A0)


    ;__# _asm_block_end

    ; __dma_queue_lenght__+=1
    moveq #1,d0
    add.w d0,_global___dma_queue_lenght__
    unlk a6 
    rts

    ;end sub

    ;sub DMA_Queue_Transfer()
DMA_Queue_Transfer:
; Auto Declaracao variavel ->  for __i__ = 0 to __dma_queue_lenght__
_local___i__ set -2
    link a6,#-2

    ; if __dma_queue_lenght__ = 0 then return
    move.w _global___dma_queue_lenght__,d0
    tst.w d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_15
    bra lbl_if_false_15
lbl_if_true_15:

    ; if __dma_queue_lenght__ = 0 then return
    unlk a6 
    rts
lbl_if_false_15:

    ; push(__DMA_queue_buff_addr__  as long, "A1")
    move.l _global___DMA_queue_buff_addr__,A1

    ; push( &hC00004 as long, "A2")
    lea $C00004,A2

    ; for __i__ = 0 to __dma_queue_lenght__
    moveq #0,d0
    move.w d0,(_local___i__,a6)
lbl_for_7_start:
    move.w (_local___i__,a6),d0
    cmp.w _global___dma_queue_lenght__,d0
    beq lbl_for_7_end

    ; _asm("move.l (A1)+,(A2)") ' Tamanho dos dados		
    move.l (A1)+,(A2)

    ; _asm("move.l (A1)+,(A2)") ' Endereco Fonte Up bytes
    move.l (A1)+,(A2)

    ; _asm("move.l (A1)+,(A2)") ' Endereco fonte low byte + endereco de Destino High Byte
    move.l (A1)+,(A2)

    ; _asm("move.w (A1)+,(A2)") ' trigger do DMA
    move.w (A1)+,(A2)

    ; _asm("addq      #2,A1")   ' alinha o vetor -> long data wide
    addq      #2,A1
    moveq #1,d0
    add.w d0,(_local___i__,a6)
    bra lbl_for_7_start

    ; next
lbl_for_7_end:

    ; __dma_queue_lenght__ = 0 'Clear Queue 
    move.w #0,_global___dma_queue_lenght__
    unlk a6 
    rts

    ;end sub

    ;imports"\mapa.bin"
    even
mapa:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\EX_DMA_Queue\mapa.bin" 

    ;imports"\tiles.bin"
    even
tiles:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\EX_DMA_Queue\tiles.bin" 
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