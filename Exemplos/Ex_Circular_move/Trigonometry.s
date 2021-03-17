align macro
     cnop 0,\1
     endm
end_global_table equ $ff0634
;dim ram_pointer as long
_global_ram_pointer equ $ff0000
;dim dx as signed fixed 
_global_dx equ $ff0004
;dim dy as signed fixed 
_global_dy equ $ff0006
;dim radius as signed fixed = 20
_global_radius equ $ff0008
;dim x as signed integer = 288
_global_x equ $ff000a
;dim y as signed integer = 240
_global_y equ $ff000c
; Auto Declaracao variavel -> waitvbl = 0
_global_waitvbl equ $ff000e
; Auto Declaracao variavel -> angle = 0
_global_angle equ $ff0010
; Auto Declaracao variavel ->  j = joypad6b_read(0)
_global_j equ $ff0012
;dim sprite_table[80] as new sprite_shape 'Buffer para a Sprite Table na RAM
_global_sprite_table equ $ff0014
;dim buff_dma[3] as long ' Buffer na RAM que serve de construtor para os comandos do DMA
_global_buff_dma equ $ff0294
;dim H_scroll_buff[448] as integer ' Buffer para a  scroll table
_global_H_scroll_buff equ $ff02a0
;dim planes_addr[3] as integer '0=0 1=1 2=Plane_Win
_global_planes_addr equ $ff0620
;dim sprite_table_addr as integer
_global_sprite_table_addr equ $ff0626
;dim scroll_table_addr as integer
_global_scroll_table_addr equ $ff0628
;dim vdp_conf_table_addr as long
_global_vdp_conf_table_addr equ $ff062a
;dim _print_cursor as integer
_global__print_cursor equ $ff062e
;dim _print_plane  as integer
_global__print_plane equ $ff0630
;dim _print_pallet as integer
_global__print_pallet equ $ff0632

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

    ;imports "\system\genesis_header.asm" ' Header de uma ROM de mega Drive Padrao (deve ficar sempre no topo)
    include "C:\workbench\Alcatech_NextBasicMC68000_IDE\utils\system\genesis_header.asm"

    ;std_init()   'Inicializa o VDP
    bsr std_init

    ;print_init() 'Carrega a fonte para a VRAM
    bsr print_init
    move.w #(2560),_global_radius
    move.w #288,_global_x
    move.w #240,_global_y

    ;set_sprite_size(0,0,0)
    move.w #0,-(a7)
    move.w #0,-(a7)
    move.w #0,-(a7)
    bsr set_sprite_size
    addq #6,a7

    ;set_sprite_gfx(0,2,0)
    move.w #0,-(a7)
    move.w #2,-(a7)
    move.w #0,-(a7)
    bsr set_sprite_gfx
    addq #6,a7

    ;set_sprite_size(1,0,0)
    move.w #0,-(a7)
    move.w #0,-(a7)
    move.w #1,-(a7)
    bsr set_sprite_size
    addq #6,a7

    ;set_sprite_gfx(1,1,0)
    move.w #0,-(a7)
    move.w #1,-(a7)
    move.w #1,-(a7)
    bsr set_sprite_gfx
    addq #6,a7

    ;set_sprite_position(1,x,y)
    move.w _global_y,-(a7)
    move.w _global_x,-(a7)
    move.w #1,-(a7)
    bsr set_sprite_position
    addq #6,a7

    ;waitvbl = 0
    move.w #0,_global_waitvbl

    ;enable_global_int() 'Ativa interrupcoes globais
    bsr enable_global_int

    ;angle = 0
    move.w #0,_global_angle

    ;do
lbl_do_1_start:

    ; j = joypad6b_read(0)
    move.w #0,-(a7)
    bsr joypad6b_read
    addq #2,a7
    move.w d7,_global_j

    ; if bit_test(j, 3) then
    move.w _global_j,d0
    btst #3,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_if_true_1
    bra lbl_if_false_1
lbl_if_true_1:

    ; radius+=1
    move.w #(128),d0
    add.w d0,_global_radius
    bra lbl_if_end_1
lbl_if_false_1:

    ; elseif bit_test(j, 2) then
    move.w _global_j,d0
    btst #2,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_2
    bra lbl_elseif_false_2
lbl_elseif_true_2:

    ; radius-=1
    move.w #(128),d0
    sub.w d0,_global_radius
    bra lbl_if_end_1
lbl_elseif_false_2:
lbl_if_end_1:

    ; if bit_test(j, 0) then
    move.w _global_j,d0
    btst #0,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_if_true_3
    bra lbl_if_false_3
lbl_if_true_3:

    ; angle += 1
    moveq #1,d0
    add.w d0,_global_angle
    bra lbl_if_end_3
lbl_if_false_3:

    ; elseif bit_test(j, 1) then
    move.w _global_j,d0
    btst #1,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_4
    bra lbl_elseif_false_4
lbl_elseif_true_4:

    ; angle -=1
    moveq #1,d0
    sub.w d0,_global_angle
    bra lbl_if_end_3
lbl_elseif_false_4:
lbl_if_end_3:

    ; angle &= 511
    move.w #511,d0
    and.w d0,_global_angle

    ; dx = (cos(angle) * radius)
    move.w _global_angle,-(a7)
    bsr cos
    addq #2,a7
    muls _global_radius,d7
    asr.l #7,d7
    move.w d7,_global_dx

    ; dy = (sen(angle) * radius) 
    move.w _global_angle,-(a7)
    bsr sen
    addq #2,a7
    muls _global_radius,d7
    asr.l #7,d7
    move.w d7,_global_dy

    ; set_cursor_position(0,0)
    move.w #0,-(a7)
    move.w #0,-(a7)
    bsr set_cursor_position
    addq #4,a7

    ; print("Seno  : ") : print_signed_fixed(dy) : print("     ")
    move.l #const_string_0_,-(a7)
    bsr print
    addq #4,a7

    ; print("Seno  : ") : print_signed_fixed(dy) : print("     ")
    move.w _global_dy,-(a7)
    bsr print_signed_fixed
    addq #2,a7

    ; print("Seno  : ") : print_signed_fixed(dy) : print("     ")
    move.l #const_string_1_,-(a7)
    bsr print
    addq #4,a7

    ; set_cursor_position(0,1)
    move.w #1,-(a7)
    move.w #0,-(a7)
    bsr set_cursor_position
    addq #4,a7

    ; print("Coseno: ") : print_signed_fixed(dx) : print("     ")
    move.l #const_string_2_,-(a7)
    bsr print
    addq #4,a7

    ; print("Coseno: ") : print_signed_fixed(dx) : print("     ")
    move.w _global_dx,-(a7)
    bsr print_signed_fixed
    addq #2,a7

    ; print("Coseno: ") : print_signed_fixed(dx) : print("     ")
    move.l #const_string_3_,-(a7)
    bsr print
    addq #4,a7

    ; set_cursor_position(0,2)
    move.w #2,-(a7)
    move.w #0,-(a7)
    bsr set_cursor_position
    addq #4,a7

    ; print("Raio  : ") : print_signed_fixed(radius) : print("     ")
    move.l #const_string_4_,-(a7)
    bsr print
    addq #4,a7

    ; print("Raio  : ") : print_signed_fixed(radius) : print("     ")
    move.w _global_radius,-(a7)
    bsr print_signed_fixed
    addq #2,a7

    ; print("Raio  : ") : print_signed_fixed(radius) : print("     ")
    move.l #const_string_5_,-(a7)
    bsr print
    addq #4,a7

    ; set_cursor_position(0,3)
    move.w #3,-(a7)
    move.w #0,-(a7)
    bsr set_cursor_position
    addq #4,a7

    ; print("Angulo: ") : print_var(angle) : print("     ")
    move.l #const_string_6_,-(a7)
    bsr print
    addq #4,a7

    ; print("Angulo: ") : print_var(angle) : print("     ")
    move.w _global_angle,-(a7)
    bsr print_var
    addq #2,a7

    ; print("Angulo: ") : print_var(angle) : print("     ")
    move.l #const_string_7_,-(a7)
    bsr print
    addq #4,a7

    ; set_sprite_position(0, x+dx, y-dy)
    move.w _global_dy,d1
    lsr.w #7,d1
    move.w _global_y,d0
    sub.w d1,d0
    move.w d0,-(a7)
    move.w _global_dx,d0
    lsr.w #7,d0
    add.w _global_x,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr set_sprite_position
    addq #6,a7

    ; waitvbl = 1
    move.w #1,_global_waitvbl

    ; while(waitvbl)_asm("nop")
lbl_while_start_1:
    tst.w _global_waitvbl
    bne lbl_while_true_1
    bra lbl_while_false_1
lbl_while_true_1:

    ; while(waitvbl)_asm("nop")
    nop
    bra lbl_while_start_1
lbl_while_false_1:
    bra lbl_do_1_start
lbl_do_1_end:

    ;loop

    ;sub isr_06_vector()
isr_06_vector:
    movem.l d0-d6/a0-a5,-(a7)

    ;update_sprite_table() 'Update sprite attribute table
    bsr update_sprite_table

    ;waitvbl=0
    move.w #0,_global_waitvbl

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
lbl_for_1_start:
    move.w (_local_i,a6),d0
    cmp.w #80,d0
    beq lbl_for_1_end

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
    bra lbl_for_1_start

    ;  next 
lbl_for_1_end:

    ;  sprite_table[79].size_link = 0 ' Ultimo sprite desenhado deve apontar para o primeiro
    move.w #0,(_global_sprite_table+((79*8)+2))

    ;  for i=0 to 448
    moveq #0,d0
    move.w d0,(_local_i,a6)
lbl_for_2_start:
    move.w (_local_i,a6),d0
    cmp.w #448,d0
    beq lbl_for_2_end

    ;  H_scroll_buff[i] = 0
    move.w (_local_i,a6),d0
    add.w d0,d0
    lea _global_H_scroll_buff,a0
    move.w #0,0(a0,d0.w)
    moveq #1,d0
    add.w d0,(_local_i,a6)
    bra lbl_for_2_start

    ;  next 
lbl_for_2_end:

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
	move.b  (A0),D1
	move.b  #0,(A0)
	andi.w	#$0F, d1
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
lbl_for_3_start:
    move.w (_local__list_,a6),d0
    cmp.w #80,d0
    beq lbl_for_3_end

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
    bra lbl_for_3_start

    ; next
lbl_for_3_end:

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

    ;sub print_init()
print_init:

    ;load_tiles_DMA(addressof(font_lbl_prtn),256,0) ' Carrega a fonte na Vram
    move.l #0,-(a7)
    move.w #256,-(a7)
    move.l #font_lbl_prtn,-(a7)
    bsr load_tiles_DMA
    lea 10(a7),a7

    ;_print_cursor = 0
    move.w #0,_global__print_cursor

    ;_print_plane = 0
    move.w #0,_global__print_plane

    ;_print_pallet = 0
    move.w #0,_global__print_pallet
    rts

    ;end sub

    ;sub set_cursor_position(byval _print_cx_p as integer, byval _print_cy_p as integer)
set_cursor_position:
    link a6,#-0
; byval _local__print_cx_p as word
_local__print_cx_p set 8
; byval _local__print_cy_p as word
_local__print_cy_p set 10

    ;_print_cursor = (_print_cx_p and 63) + ((_print_cy_p and 31) * 64) 
    move.w (_local__print_cx_p,a6),d0
    and.w #63,d0
    move.w (_local__print_cy_p,a6),d1
    and.w #31,d1
    lsl.w #6,d1
    add.w d1,d0
    move.w d0,_global__print_cursor
    unlk a6 
    rts

    ;end sub

    ;sub set_text_plane(byval _print_plane_text as integer)
set_text_plane:
    link a6,#-0
; byval _local__print_plane_text as word
_local__print_plane_text set 8

    ;_print_plane = _print_plane_text
    move.w (_local__print_plane_text,a6),_global__print_plane
    unlk a6 
    rts

    ;end sub

    ;sub set_text_pal(byval _print_pal_set as integer)
set_text_pal:
    link a6,#-0
; byval _local__print_pal_set as word
_local__print_pal_set set 8

    ;_print_pallet = _print_pal_set
    move.w (_local__print_pal_set,a6),_global__print_pallet
    unlk a6 
    rts

    ;end sub

    ;sub print(byval _print_string as long)
print:
;  dim char as integer = peek(  _print_string as byte)
_local_char set -2
    link a6,#-2
; byval _local__print_string as long
_local__print_string set 8
    move.l (_local__print_string,a6),a0
    moveq #0,d0
    move.b (a0),d0
    move.w d0,(_local_char,a6)

    ;  while(char<>0)
lbl_while_start_2:
    move.w (_local_char,a6),d0
    tst.w d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_while_true_2
    bra lbl_while_false_2
lbl_while_true_2:

    ;  draw_tile(char OR _print_pallet, _print_cursor AND 63 , (_print_cursor / 64) ,_print_plane)
    move.w _global__print_plane,-(a7)
    move.w _global__print_cursor,d0
    lsr.w #6,d0
    move.w d0,-(a7)
    move.w _global__print_cursor,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w (_local_char,a6),d0
    or.w _global__print_pallet,d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  _print_string +=1
    moveq #1,d0
    add.l d0,(_local__print_string,a6)

    ;  _print_cursor +=1
    moveq #1,d0
    add.w d0,_global__print_cursor

    ;  if _print_cursor > (64*32) then _print_cursor = 0
    move.w _global__print_cursor,d0
    cmp.w #(64*32),d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_5
    bra lbl_if_false_5
lbl_if_true_5:

    ;  if _print_cursor > (64*32) then _print_cursor = 0
    move.w #0,_global__print_cursor
lbl_if_false_5:

    ;  char = peek(  _print_string as byte)
    move.l (_local__print_string,a6),a0
    moveq #0,d0
    move.b (a0),d0
    move.w d0,(_local_char,a6)
    bra lbl_while_start_2

    ;  end while
lbl_while_false_2:
    unlk a6 
    rts

    ;end sub

    ;sub println(byval _print_string as long)
println:
;  dim char as integer = peek(  _print_string as byte)
_local_char set -2
    link a6,#-2
; byval _local__print_string as long
_local__print_string set 8
    move.l (_local__print_string,a6),a0
    moveq #0,d0
    move.b (a0),d0
    move.w d0,(_local_char,a6)

    ;  while(char<>0)
lbl_while_start_3:
    move.w (_local_char,a6),d0
    tst.w d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_while_true_3
    bra lbl_while_false_3
lbl_while_true_3:

    ;  draw_tile(char OR _print_pallet, _print_cursor AND 63 , (_print_cursor / 64) ,_print_plane)
    move.w _global__print_plane,-(a7)
    move.w _global__print_cursor,d0
    lsr.w #6,d0
    move.w d0,-(a7)
    move.w _global__print_cursor,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w (_local_char,a6),d0
    or.w _global__print_pallet,d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  _print_string +=1
    moveq #1,d0
    add.l d0,(_local__print_string,a6)

    ;  _print_cursor +=1
    moveq #1,d0
    add.w d0,_global__print_cursor

    ;  if _print_cursor > (64*32) then _print_cursor = 0
    move.w _global__print_cursor,d0
    cmp.w #(64*32),d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_6
    bra lbl_if_false_6
lbl_if_true_6:

    ;  if _print_cursor > (64*32) then _print_cursor = 0
    move.w #0,_global__print_cursor
lbl_if_false_6:

    ;  char = peek(  _print_string as byte)
    move.l (_local__print_string,a6),a0
    moveq #0,d0
    move.b (a0),d0
    move.w d0,(_local_char,a6)
    bra lbl_while_start_3

    ;  end while
lbl_while_false_3:

    ;  _print_cursor += 64 - (_print_cursor and 63) 
    move.w _global__print_cursor,d1
    and.w #63,d1
    moveq #64,d0
    sub.w d1,d0
    add.w d0,_global__print_cursor
    unlk a6 
    rts

    ;end sub

    ;sub print_var(byval _print_val as integer)
print_var:
; dim flag_prnt as integer = 0
_local_flag_prnt set -2
; dim div_f as integer = 10000
_local_div_f set -4
; dim pars_ as integer
_local_pars_ set -6
    link a6,#-6
; byval _local__print_val as word
_local__print_val set 8

    ; if _print_val = 0 then
    move.w (_local__print_val,a6),d0
    tst.w d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_7
    bra lbl_if_false_7
lbl_if_true_7:

    ; print("0") : return
    move.l #const_string_8_,-(a7)
    bsr print
    addq #4,a7

    ; print("0") : return
    unlk a6 
    rts
    bra lbl_if_end_7
lbl_if_false_7:
lbl_if_end_7:
    move.w #0,(_local_flag_prnt,a6)
    move.w #10000,(_local_div_f,a6)

    ; while(div_f)
lbl_while_start_4:
    tst.w (_local_div_f,a6)
    bne lbl_while_true_4
    bra lbl_while_false_4
lbl_while_true_4:

    ; pars_ = _print_val / div_f
    moveq #0,d0
    move.w (_local__print_val,a6),d0
    divu (_local_div_f,a6),d0
    move.w d0,(_local_pars_,a6)

    ; if pars_ OR flag_prnt then
    move.w (_local_pars_,a6),d0
    or.w (_local_flag_prnt,a6),d0
    dbra d0,lbl_if_true_8
    bra lbl_if_false_8
lbl_if_true_8:

    ; flag_prnt = true
    move.w #1,(_local_flag_prnt,a6)

    ; draw_tile(((pars_+ &H30) OR _print_pallet), _print_cursor AND 63 , (_print_cursor / 64) ,_print_plane)
    move.w _global__print_plane,-(a7)
    move.w _global__print_cursor,d0
    lsr.w #6,d0
    move.w d0,-(a7)
    move.w _global__print_cursor,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w (_local_pars_,a6),d0
    add.w #$30,d0
    or.w _global__print_pallet,d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; _print_cursor +=1
    moveq #1,d0
    add.w d0,_global__print_cursor

    ; if _print_cursor > (64*32) then _print_cursor = 0
    move.w _global__print_cursor,d0
    cmp.w #(64*32),d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_9
    bra lbl_if_false_9
lbl_if_true_9:

    ; if _print_cursor > (64*32) then _print_cursor = 0
    move.w #0,_global__print_cursor
lbl_if_false_9:
    bra lbl_if_end_8
lbl_if_false_8:
lbl_if_end_8:

    ; _print_val -= pars_ * div_f
    move.w (_local_pars_,a6),d0
    mulu (_local_div_f,a6),d0
    sub.w d0,(_local__print_val,a6)

    ; div_f = div_f / 10
    moveq #0,d0
    move.w (_local_div_f,a6),d0
    divu #10,d0
    move.w d0,(_local_div_f,a6)
    bra lbl_while_start_4

    ; wend
lbl_while_false_4:
    unlk a6 
    rts

    ;end sub

    ;sub print_signed(byval _print_val as signed integer)
print_signed:
    link a6,#-0
; byval _local__print_val as word
_local__print_val set 8

    ; if _unsigned(_print_val > 32768) then 'Negativo
    move.w (_local__print_val,a6),d0
    cmp.w #32768,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_10
    bra lbl_if_false_10
lbl_if_true_10:

    ; print("-")
    move.l #const_string_9_,-(a7)
    bsr print
    addq #4,a7

    ; print_var( (~_print_val) +1 )
    move.w (_local__print_val,a6),d0
    not.w d0
    addq #1,d0
    move.w d0,-(a7)
    bsr print_var
    addq #2,a7
    bra lbl_if_end_10
lbl_if_false_10:

    ; else 'Positivo

    ; print("+")
    move.l #const_string_10_,-(a7)
    bsr print
    addq #4,a7

    ; print_var( _print_val )
    move.w (_local__print_val,a6),-(a7)
    bsr print_var
    addq #2,a7
lbl_if_end_10:
    unlk a6 
    rts

    ;end sub

    ;sub print_hex(byval _print_val as long)
print_hex:
;  dim _parse_bf[9] as byte ' String local que vai armazenar o valor do Hex convertido para string
_local__parse_bf set -10
; Auto Declaracao variavel ->   for k = 0 to 8
_local_k set -12
    link a6,#-12
; byval _local__print_val as long
_local__print_val set 8

    ;  for k = 0 to 8
    moveq #0,d0
    move.w d0,(_local_k,a6)
lbl_for_4_start:
    move.w (_local_k,a6),d0
    cmp.w #8,d0
    beq lbl_for_4_end

    ;  _parse_bf[7-k] = _long( (_print_val AND (&hF << k*4))>>( k*4) )
    moveq #7,d0
    sub.w (_local_k,a6),d0
    add.w #_local__parse_bf,d0
    moveq #0,d2
    move.w (_local_k,a6),d2
    add.l d2,d2
    add.l d2,d2
    moveq #$F,d1
    lsl.l d2,d1
    and.l (_local__print_val,a6),d1
    moveq #0,d2
    move.w (_local_k,a6),d2
    add.l d2,d2
    add.l d2,d2
    lsr.l d2,d1
    move.b d1,0(a6,d0.w)

    ;  if _byte(_parse_bf[7-k] > 9) then _parse_bf[7-k] += _char("7") else _parse_bf[7-k] += _char("0") 
    moveq #7,d0
    sub.w (_local_k,a6),d0
    add.w #_local__parse_bf,d0
    move.b 0(a6,d0.w),d1
    cmp.b #9,d1
    shi d1
    and.b #$01,d1
    tst.b d1
    bne lbl_if_true_11
    bra lbl_if_false_11
lbl_if_true_11:

    ;  if _byte(_parse_bf[7-k] > 9) then _parse_bf[7-k] += _char("7") else _parse_bf[7-k] += _char("0") 
    moveq #7,d0
    sub.w (_local_k,a6),d0
    add.w #_local__parse_bf,d0
    move.b #'7',d1
    add.b d1,0(a6,d0.w)
    bra lbl_if_end_11
lbl_if_false_11:

    ;  if _byte(_parse_bf[7-k] > 9) then _parse_bf[7-k] += _char("7") else _parse_bf[7-k] += _char("0") 
    moveq #7,d0
    sub.w (_local_k,a6),d0
    add.w #_local__parse_bf,d0
    move.b #'0',d1
    add.b d1,0(a6,d0.w)
lbl_if_end_11:
    moveq #1,d0
    add.w d0,(_local_k,a6)
    bra lbl_for_4_start

    ;  next k 
lbl_for_4_end:

    ;  _parse_bf[8] = 0 'Caractere Null - Fim de string
    move.b #0,(_local__parse_bf+(8<<0),a6)

    ;  print("0x")
    move.l #const_string_11_,-(a7)
    bsr print
    addq #4,a7

    ;  print(addressof(_parse_bf))
    move.l a6,d0
    add.l #_local__parse_bf,d0
    move.l d0,-(a7)
    bsr print
    addq #4,a7
    unlk a6 
    rts

    ;end sub

    ;sub print_fixed(byval _print_val as fixed)
print_fixed:
    link a6,#-0
; byval _local__print_val as word
_local__print_val set 8

    ;  print_var(_print_val)
    move.w (_local__print_val,a6),d0
    lsr.w #7,d0
    move.w d0,-(a7)
    bsr print_var
    addq #2,a7

    ;  print(".")
    move.l #const_string_12_,-(a7)
    bsr print
    addq #4,a7

    ;  _print_val = ( (_print_val and &H7F)<<7)  * 0.78125
    move.w (_local__print_val,a6),d0
    and.w #$7F,d0
    lsl.w #7,d0
    mulu #(100),d0
    lsr.l #7,d0
    move.w d0,(_local__print_val,a6)

    ;  if _fixed(_print_val < 10) then print("0") 
    move.w (_local__print_val,a6),d0
    cmp.w #(1280),d0
    scs d0
    and.w #$01,d0
    dbra d0,lbl_if_true_12
    bra lbl_if_false_12
lbl_if_true_12:

    ;  if _fixed(_print_val < 10) then print("0") 
    move.l #const_string_13_,-(a7)
    bsr print
    addq #4,a7
lbl_if_false_12:

    ;  print_var( _print_val)  
    move.w (_local__print_val,a6),d0
    lsr.w #7,d0
    move.w d0,-(a7)
    bsr print_var
    addq #2,a7
    unlk a6 
    rts

    ;end sub

    ;sub print_signed_fixed(byval _print_val as fixed)  
print_signed_fixed:
    link a6,#-0
; byval _local__print_val as word
_local__print_val set 8

    ;  if _unsigned(_print_val > 255) then 'Negativo
    move.w (_local__print_val,a6),d0
    lsr.w #7,d0
    cmp.w #255,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_13
    bra lbl_if_false_13
lbl_if_true_13:

    ;  print("-")
    move.l #const_string_14_,-(a7)
    bsr print
    addq #4,a7

    ;  print_fixed( (~(_print_val-0.01)) )
    move.w (_local__print_val,a6),d0
    sub.w #(1),d0
    not.w d0
    move.w d0,-(a7)
    bsr print_fixed
    addq #2,a7
    bra lbl_if_end_13
lbl_if_false_13:

    ;  else 'Positivo

    ;  print("+")
    move.l #const_string_15_,-(a7)
    bsr print
    addq #4,a7

    ;  print_fixed( _print_val )
    move.w (_local__print_val,a6),-(a7)
    bsr print_fixed
    addq #2,a7
lbl_if_end_13:
    unlk a6 
    rts

    ; end sub

    ;function sen(byval __angle__ as integer) as signed fixed
sen:
    link a6,#-0
; byval _local___angle__ as word
_local___angle__ set 8
    moveq #0,d0
    move.w (_local___angle__,a6),d0
    and.l #511,d0
    add.l d0,d0
    add.l #table_sin_fixed__,d0
    move.l d0,a0
    move.w (a0),d0

    ;return peek(addressof(table_sin_fixed__) + ((__angle__ mod 512)<<1) as integer)
    move.w d0,d7
    unlk a6 
    rts

    ;end function

    ;function cos(byval __angle__ as integer) as signed fixed
cos:
    link a6,#-0
; byval _local___angle__ as word
_local___angle__ set 8
    moveq #0,d0
    move.w (_local___angle__,a6),d0
    and.l #511,d0
    add.l d0,d0
    add.l #table_cos_fixed__,d0
    move.l d0,a0
    move.w (a0),d0

    ;return peek(addressof(table_cos_fixed__) + ((__angle__ mod 512)<<1) as integer)
    move.w d0,d7
    unlk a6 
    rts

    ;end function

    ;function tan(byval __angle__ as integer) as signed fixed
tan:
    link a6,#-0
; byval _local___angle__ as word
_local___angle__ set 8
    moveq #0,d0
    move.w (_local___angle__,a6),d0
    and.l #511,d0
    add.l d0,d0
    add.l #table_tan_fixed__,d0
    move.l d0,a0
    move.w (a0),d0

    ;return peek(addressof(table_tan_fixed__) + ((__angle__ mod 512)<<1) as integer)
    move.w d0,d7
    unlk a6 
    rts

    ;end function
    even
const_string_0_:
    dc.b "Seno  : ",0
    even
const_string_1_:
    dc.b "     ",0
    even
const_string_2_:
    dc.b "Coseno: ",0
    even
const_string_3_:
    dc.b "     ",0
    even
const_string_4_:
    dc.b "Raio  : ",0
    even
const_string_5_:
    dc.b "     ",0
    even
const_string_6_:
    dc.b "Angulo: ",0
    even
const_string_7_:
    dc.b "     ",0
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
const_string_8_:
    dc.b "0",0
    even
const_string_9_:
    dc.b "-",0
    even
const_string_10_:
    dc.b "+",0
    even
const_string_11_:
    dc.b "0x",0
    even
const_string_12_:
    dc.b ".",0
    even
const_string_13_:
    dc.b "0",0
    even
const_string_14_:
    dc.b "-",0
    even
const_string_15_:
    dc.b "+",0

    ;imports "\system\font_msxBR_8x8.bin , -f , -e"
    even
font_lbl_prtn:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\utils\system\font_msxbr_8x8.bin " 
    even
table_sin_fixed__:
    dc.w 0,1,3,5,6,8,9,12,13,14,15,17,19,20,22,23,24,27,28,29,31,32,35,36,37,38
    dc.w 40,42,44,45,46,47,49,50,51,54,55,56,58,59,60,61,63,64,65,67,68,69,72,73,74,76
    dc.w 77,78,78,79,81,82,83,84,86,87,88,90,91,92,92,93,95,96,97,97,99,100,101,102,102,104
    dc.w 105,105,106,108,108,109,110,110,111,113,113,114,114,115,115,116,116,118,118,119,119,120,120,122,122,122
    dc.w 123,123,123,124,124,124,125,125,125,125,127,127,127,127,127,127,128,128,128,128,128,128,128,128,128,128
    dc.w 128,128,128,128,128,128,128,127,127,127,127,127,127,125,125,125,125,124,124,124,123,123,123,122,122,122
    dc.w 120,120,119,119,118,118,116,116,115,115,114,114,113,113,111,110,110,109,109,108,106,106,105,104,102,102
    dc.w 101,100,99,99,97,96,95,93,93,92,91,90,88,87,86,84,83,83,82,81,79,78,77,76,74,73
    dc.w 72,70,69,68,67,65,63,61,60,59,58,56,55,54,52,51,49,47,46,45,44,42,41,38,37,36
    dc.w 35,33,32,29,28,27,26,24,22,20,19,18,15,14,13,12,10,8,6,5,4,1,0,-1,-3,-4
    dc.w -6,-8,-9,-10,-13,-14,-15,-17,-18,-20,-22,-23,-24,-26,-28,-29,-31,-32,-33,-36,-37,-38,-40,-41,-42,-45
    dc.w -46,-47,-49,-50,-51,-52,-54,-56,-58,-59,-60,-61,-63,-64,-65,-67,-68,-69,-70,-72,-73,-74,-76,-77,-78,-79
    dc.w -81,-82,-83,-84,-86,-87,-88,-90,-90,-91,-92,-93,-95,-96,-97,-97,-99,-100,-101,-101,-102,-104,-105,-105,-106,-108
    dc.w -108,-109,-110,-110,-111,-111,-113,-114,-114,-115,-115,-116,-116,-118,-118,-119,-119,-120,-120,-120,-122,-122,-123,-123,-123,-124
    dc.w -124,-124,-124,-125,-125,-125,-125,-127,-127,-127,-127,-127,-127,-128,-128,-128,-128,-128,-128,-128,-128,-128,-128,-128,-128,-128
    dc.w -128,-128,-128,-127,-127,-127,-127,-127,-127,-125,-125,-125,-125,-124,-124,-124,-123,-123,-123,-122,-122,-122,-120,-120,-119,-119
    dc.w -119,-118,-118,-116,-116,-115,-115,-114,-113,-113,-111,-111,-110,-109,-109,-108,-106,-106,-105,-104,-104,-102,-101,-100,-100,-99
    dc.w -97,-96,-95,-95,-93,-92,-91,-90,-88,-87,-86,-86,-84,-83,-82,-81,-79,-78,-77,-76,-74,-73,-72,-70,-69,-68
    dc.w -67,-65,-64,-63,-61,-59,-58,-56,-55,-54,-52,-51,-50,-49,-46,-45,-44,-42,-41,-40,-38,-36,-35,-33,-32,-31
    dc.w -28,-27,-26,-24,-23,-20,-19,-18,-17,-15,-13,-12,-10,-9,-6,-5,-4,-3
    even
table_cos_fixed__:
    dc.w 128,128,128,128,128,128,128,128,128,127,127,127,127,127,127,125,125,125,125,124,124,124,123,123,123,122
    dc.w 122,122,120,120,119,119,118,118,116,116,115,115,114,114,113,113,111,110,110,109,109,108,106,105,105,104
    dc.w 102,102,101,100,99,99,97,96,95,93,92,92,91,90,88,87,86,84,83,82,81,81,79,78,77,76
    dc.w 74,73,72,70,69,68,65,64,63,61,60,59,58,56,55,54,52,50,49,47,46,45,44,42,40,38
    dc.w 37,36,35,33,31,29,28,27,26,23,22,20,19,18,15,14,13,12,9,8,6,5,4,1,0,-1
    dc.w -3,-5,-6,-8,-9,-10,-13,-14,-15,-17,-19,-20,-22,-23,-24,-27,-28,-29,-31,-32,-35,-36,-37,-38,-40,-41
    dc.w -44,-45,-46,-47,-49,-50,-51,-52,-55,-56,-58,-59,-60,-61,-63,-64,-65,-67,-68,-69,-70,-72,-73,-74,-76,-77
    dc.w -78,-79,-81,-82,-83,-84,-86,-87,-88,-90,-91,-91,-92,-93,-95,-96,-97,-97,-99,-100,-101,-101,-102,-104,-105,-105
    dc.w -106,-108,-108,-109,-110,-110,-111,-113,-113,-114,-114,-115,-115,-116,-116,-118,-118,-119,-119,-120,-120,-120,-122,-122,-123,-123
    dc.w -123,-124,-124,-124,-125,-125,-125,-125,-125,-127,-127,-127,-127,-127,-127,-128,-128,-128,-128,-128,-128,-128,-128,-128,-128,-128
    dc.w -128,-128,-128,-128,-128,-127,-127,-127,-127,-127,-127,-125,-125,-125,-125,-124,-124,-124,-123,-123,-123,-122,-122,-122,-120,-120
    dc.w -119,-119,-118,-118,-118,-116,-116,-115,-114,-114,-113,-113,-111,-111,-110,-109,-109,-108,-106,-106,-105,-104,-104,-102,-101,-100
    dc.w -100,-99,-97,-96,-95,-93,-93,-92,-91,-90,-88,-87,-86,-84,-84,-83,-82,-81,-79,-78,-77,-76,-74,-73,-72,-70
    dc.w -69,-68,-67,-65,-64,-63,-60,-59,-58,-56,-55,-54,-52,-51,-50,-47,-46,-45,-44,-42,-41,-40,-37,-36,-35,-33
    dc.w -32,-29,-28,-27,-26,-24,-22,-20,-19,-18,-17,-14,-13,-12,-10,-9,-6,-5,-4,-3,0,1,3,4,6,8
    dc.w 9,10,12,14,15,17,18,19,22,23,24,26,28,29,31,32,33,35,37,38,40,41,42,44,46,47
    dc.w 49,50,51,52,54,55,58,59,60,61,63,64,65,67,68,69,70,72,73,74,76,77,78,79,81,82
    dc.w 83,84,86,87,88,90,90,91,92,93,95,96,96,97,99,100,101,101,102,104,104,105,106,108,108,109
    dc.w 110,110,111,111,113,114,114,115,115,116,116,118,118,119,119,120,120,120,122,122,123,123,123,124,124,124
    dc.w 124,125,125,125,125,127,127,127,127,127,127,128,128,128,128,128,128,128
    even
table_tan_fixed__:
    dc.w 0,1,3,5,6,8,9,12,13,14,15,18,19,20,22,24,26,27,28,31,32,33,36,37,38,41,42,44,46,47,50
    dc.w 51,52,55,56,59,60,63,64,67,68,70,73,74,77,79,81,83,86,88,90,92,95,97,100,102,105,108,110,113,116,119
    dc.w 122,124,128,131,134,138,141,145,148,152,156,160,164,168,173,177,182,187,191,196,202,207,214,219,225,232,239,246,253,261,270
    dc.w 279,288,298,308,319,330,343,357,371,387,403,420,439,461,484,508,536,567,602,640,684,732,790,856,934,1028,1142,1284,1466,1706
    dc.w 2042,2541,3360,4956,9439,32701,-11675,-5510,-3606,-2679,-2130,-1768,-1510,-1318,-1169,-1050,-952,-872,-803,-744,-692,-649,-609,-573
    dc.w -543,-515,-489,-466,-444,-424,-406,-389,-374,-360,-346,-333,-321,-311,-300,-291,-280,-271,-264,-256,-248,-241,-233,-227,-220,-215
    dc.w -209,-204,-197,-192,-187,-183,-178,-173,-169,-165,-160,-156,-152,-148,-146,-142,-138,-134,-132,-128,-125,-123,-119,-116,-114,-111
    dc.w -108,-105,-102,-100,-97,-95,-93,-91,-88,-86,-83,-82,-79,-77,-76,-73,-70,-69,-67,-65,-63,-61,-59,-58,-55,-54
    dc.w -51,-50,-47,-46,-45,-42,-41,-40,-37,-36,-35,-32,-31,-29,-27,-26,-24,-23,-20,-19,-18,-17,-14,-13,-12,-10
    dc.w -8,-6,-5,-4,-1,0,1,3,4,6,8,9,10,13,14,15,17,19,20,22,23,26,27,28,29,32,33,35,37,38
    dc.w 40,42,44,45,47,49,51,52,55,56,58,60,61,64,67,68,70,72,74,77,78,81,83,84,87,90,92,95,97,100,102
    dc.w 105,108,110,113,115,118,122,124,127,131,133,137,141,143,147,151,155,159,163,168,172,175,180,186,191,196,201,206,212,218,224
    dc.w 230,238,244,252,260,269,276,285,296,306,316,328,340,353,367,383,399,416,435,456,479,503,530,561,594,631,673,722,777,841,916
    dc.w 1006,1115,1251,1423,1649,1961,2415,3145,4503,7922,32745,-15296,-6204,-3890,-2833,-2227,-1834,-1559,-1354,-1198,-1073,-972,-887,-817,-755
    dc.w -703,-658,-617,-581,-549,-520,-494,-470,-448,-429,-410,-393,-378,-362,-349,-337,-324,-312,-302,-292,-283,-274,-265,-257,-250,-242
    dc.w -236,-228,-221,-215,-210,-204,-198,-193,-188,-183,-179,-174,-170,-165,-161,-157,-154,-150,-146,-142,-140,-136,-132,-129,-125,-123
    dc.w -120,-116,-114,-111,-109,-106,-104,-101,-99,-96,-93,-91,-88,-87,-84,-82,-79,-78,-76,-73,-72,-69,-67,-65,-63,-61
    dc.w -59,-58,-55,-54,-52,-50,-49,-46,-45,-44,-41,-40,-38,-36,-35,-33,-31,-29,-28,-26,-24,-23,-22,-19,-18,-17
    dc.w -15,-13,-12,-10,-9,-6,-5,-4,-3
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