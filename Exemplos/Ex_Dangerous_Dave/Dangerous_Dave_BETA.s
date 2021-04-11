align macro
     cnop 0,\1
     endm
end_global_table equ $ff296e
;dim ram_pointer as long
_global_ram_pointer equ $ff0000
;dim camera as integer = 0 'Posicao da Camera em Tiles
_global_camera equ $ff0004
;dim frame  as integer = 0 'Contagem dos frames para temporizacao das animacoes
_global_frame equ $ff0006
;dim anima_tiles1 as integer = 0 'Contagem dos quadros de animacao de 4 frames
_global_anima_tiles1 equ $ff0008
;dim anima_tiles2 as integer = 0 'Contagem dos quadros de animacao de 5 frames
_global_anima_tiles2 equ $ff000a
;dim anima_dave   as integer = 0 'Contagem dos quadros de animacao do Sprite
_global_anima_dave equ $ff000c
;dim gravidade    as integer = 0 'Aceleracao no eixo Y (Gravidade)
_global_gravidade equ $ff000e
;dim dirx     as integer = 0 'Aceleracao no Eixo X
_global_dirx equ $ff0010
;dim score    as integer = 0 'Score
_global_score equ $ff0012
;dim x_scroll as integer = 0 'Posicao da scroll Plane
_global_x_scroll equ $ff0014
;dim dave as new char_ ' Matriz indexada 
_global_dave equ $ff0016
;dim tile_map_ram [200,20] as integer ' Tile Map na RAM (evitar uso para mapas muito grandes)
_global_tile_map_ram equ $ff0022
;dim colision_vector[100,10] as byte  ' Mapa de colisores
_global_colision_vector equ $ff1f62
;dim level_index as integer = 0 ' Zero = Level 1
_global_level_index equ $ff234a
;dim frame_c as integer = 0 
_global_frame_c equ $ff234c
;dim v_count as integer = 0
_global_v_count equ $ff234e
;dim frame_rate as integer = 0
_global_frame_rate equ $ff2350
; Auto Declaracao variavel ->  vbl = 1             ' Sobe um Flag que e limpo na Interrupcao por V_blank
_global_vbl equ $ff2352
;dim sprite_table[80] as new sprite_shape 'Buffer para a Sprite Table na RAM
_global_sprite_table equ $ff2354
;dim buff_dma[3] as long ' Buffer na RAM que serve de construtor para os comandos do DMA
_global_buff_dma equ $ff25d4
;dim H_scroll_buff[448] as integer ' Buffer para a  scroll table
_global_H_scroll_buff equ $ff25e0
;dim planes_addr[3] as integer '0=0 1=1 2=Plane_Win
_global_planes_addr equ $ff2960
;dim sprite_table_addr as integer
_global_sprite_table_addr equ $ff2966
;dim scroll_table_addr as integer
_global_scroll_table_addr equ $ff2968
;dim vdp_conf_table_addr as long
_global_vdp_conf_table_addr equ $ff296a

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

    ;imports"\system\genesis_header.asm" ' Header de uma ROM de mega Drive Padrao (deve ficar sempre no topo)
    include "C:\workbench\Alcatech_NextBasicMC68000_IDE\utils\system\genesis_header.asm"

    ;std_init()
    bsr std_init

    ;load_tiles_DMA_128ksafe(addressof(tiles),204,1)
    move.l #1,-(a7)
    move.w #204,-(a7)
    move.l #tiles,-(a7)
    bsr load_tiles_DMA_128ksafe
    lea 10(a7),a7

    ;load_tiles_DMA_128ksafe(addressof(dave_data),36,205)
    move.l #205,-(a7)
    move.w #36,-(a7)
    move.l #dave_data,-(a7)
    bsr load_tiles_DMA_128ksafe
    lea 10(a7),a7

    ;load_tiles_DMA_128ksafe(addressof(numeros),10,241)
    move.l #241,-(a7)
    move.w #10,-(a7)
    move.l #numeros,-(a7)
    bsr load_tiles_DMA_128ksafe
    lea 10(a7),a7

    ;load_cram_DMA_128ksafe(addressof(paletatile0),64,0)
    move.l #0,-(a7)
    move.w #64,-(a7)
    move.l #paletatile0,-(a7)
    bsr load_cram_DMA_128ksafe
    lea 10(a7),a7
    move.w #0,_global_camera
    move.w #0,_global_frame
    move.w #0,_global_anima_tiles1
    move.w #0,_global_anima_tiles2
    move.w #0,_global_anima_dave
    move.w #0,_global_gravidade
    move.w #0,_global_dirx
    move.w #0,_global_score
    move.w #0,_global_x_scroll
    move.w #0,_global_level_index
    move.w #0,_global_frame_c
    move.w #0,_global_v_count
    move.w #0,_global_frame_rate

    ;dave.sprite = 0 ' Atribui o indice Zero na Sprite table para o sprite do personagem
    move.w #0,(_global_dave+4)

    ;dave.hjump  = 0 ' Zera altura do Pulo
    move.w #0,(_global_dave+6)

    ;dave.flags  = 0 ' Zera os Flags
    move.w #0,(_global_dave+10)

    ;set_sprite_size(dave.sprite,1,1)  ' Sprite 16x16 Pixels
    move.w #1,-(a7)
    move.w #1,-(a7)
    move.w (_global_dave+4),-(a7)
    bsr set_sprite_size
    addq #6,a7

    ;set_sprite_gfx(dave.sprite,205,2) ' Desenhado com a Paleta 02
    move.w #2,-(a7)
    move.w #205,-(a7)
    move.w (_global_dave+4),-(a7)
    bsr set_sprite_gfx
    addq #6,a7

    ;load_level(tile_map_ram,colision_vector,level_index) 'Carrega o primeiro nivel
    move.w _global_level_index,-(a7)
    move.l #_global_colision_vector,-(a7)
    move.l #_global_tile_map_ram,-(a7)
    bsr load_level
    lea 10(a7),a7

    ;enable_global_int() ' Interrupcao por Vblank
    bsr enable_global_int

    ;Do 'main
lbl_do_1_start:

    ; input_thread()    ' Joystick e Direcoes
    bsr input_thread

    ; check_colision()  ' Colisao e posicoes
    bsr check_colision

    ; draw_score()      ' Printa na tela o Score 
    bsr draw_score

    ; draw_frame_rate() ' Printa na tela o Frame Rate
    bsr draw_frame_rate

    ; if dave.x > 816 then scroll_right()               ' Movimenta a camera para a Direita
    move.w (_global_dave+0),d0
    cmp.w #816,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_1
    bra lbl_if_false_1
lbl_if_true_1:

    ; if dave.x > 816 then scroll_right()               ' Movimenta a camera para a Direita
    bsr scroll_right
lbl_if_false_1:

    ; if dave.x < 312 and camera>16 then  scroll_left() ' Movimenta a camera para a Esquerda
    move.w (_global_dave+0),d0
    cmp.w #312,d0
    scs d0
    and.w #$01,d0
    move.w _global_camera,d1
    cmp.w #16,d1
    shi d1
    and.w #$01,d1
    and.w d1,d0
    dbra d0,lbl_if_true_2
    bra lbl_if_false_2
lbl_if_true_2:

    ; if dave.x < 312 and camera>16 then  scroll_left() ' Movimenta a camera para a Esquerda
    bsr scroll_left
lbl_if_false_2:

    ; frame   +=1       ' Conta os Frames Renderizados Para temporizacao das animacoes
    moveq #1,d0
    add.w d0,_global_frame

    ; frame_c +=1       ' Conta os Frames Renderizados para calculo do Frame Rate
    moveq #1,d0
    add.w d0,_global_frame_c

    ; if frame > 4 then anima_cenario() ' Completou o intervalo de tempo entre as animacoes?
    move.w _global_frame,d0
    cmp.w #4,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_3
    bra lbl_if_false_3
lbl_if_true_3:

    ; if frame > 4 then anima_cenario() ' Completou o intervalo de tempo entre as animacoes?
    bsr anima_cenario
lbl_if_false_3:

    ; if bit_test(dave.flags,5) then ' Jogador passou de nivel?
    move.w (_global_dave+10),d0
    btst #5,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_if_true_4
    bra lbl_if_false_4
lbl_if_true_4:

    ;  if level_index>9 then level_index = 0
    move.w _global_level_index,d0
    cmp.w #9,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_5
    bra lbl_if_false_5
lbl_if_true_5:

    ;  if level_index>9 then level_index = 0
    move.w #0,_global_level_index
lbl_if_false_5:

    ;  load_level(tile_map_ram,colision_vector,level_index) 
    move.w _global_level_index,-(a7)
    move.l #_global_colision_vector,-(a7)
    move.l #_global_tile_map_ram,-(a7)
    bsr load_level
    lea 10(a7),a7
    bra lbl_if_end_4
lbl_if_false_4:
lbl_if_end_4:

    ; set_sprite_position(dave.sprite,dave.x>>1,dave.y>>1)
    move.w (_global_dave+2),d0
    lsr.w #1,d0
    move.w d0,-(a7)
    move.w (_global_dave+0),d0
    lsr.w #1,d0
    move.w d0,-(a7)
    move.w (_global_dave+4),-(a7)
    bsr set_sprite_position
    addq #6,a7

    ; vbl = 1             ' Sobe um Flag que e limpo na Interrupcao por V_blank
    move.w #1,_global_vbl

    ; while(vbl) : wend   ' Trava o FPS em no Maximo 60 Frames por segundo
lbl_while_start_1:
    tst.w _global_vbl
    bne lbl_while_true_1
    bra lbl_while_false_1
lbl_while_true_1:
    bra lbl_while_start_1

    ; while(vbl) : wend   ' Trava o FPS em no Maximo 60 Frames por segundo
lbl_while_false_1:
    bra lbl_do_1_start
lbl_do_1_end:

    ;Loop ' Laco infinito

    ;sub scroll_right() ' Animacao de transicao do cenario para a Direita
scroll_right:
; Auto Declaracao variavel ->  for i=0 to 15     'Scroll de 15 blocos
_local_i set -2
; Auto Declaracao variavel ->  for y = 0 to 20 ' Desenha uma linha vertical de 16 Pixels de largura na margem direita da tela
_local_y set -4
    link a6,#-4

    ; for i=0 to 15     'Scroll de 15 blocos
    moveq #0,d0
    move.w d0,(_local_i,a6)
lbl_for_1_start:
    move.w (_local_i,a6),d0
    cmp.w #15,d0
    beq lbl_for_1_end

    ; for y = 0 to 20 ' Desenha uma linha vertical de 16 Pixels de largura na margem direita da tela
    moveq #0,d0
    move.w d0,(_local_y,a6)
lbl_for_2_start:
    move.w (_local_y,a6),d0
    cmp.w #20,d0
    beq lbl_for_2_end

    ; draw_tile(tile_map_ram[camera + 40 ,y], (camera + 40) and 63 ,y, 1)
    move.w #1,-(a7)
    move.w (_local_y,a6),-(a7)
    move.w _global_camera,d0
    add.w #40,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w _global_camera,d0
    add.w #40,d0
    move.w (_local_y,a6),d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w 0(a0,d0.w),-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(tile_map_ram[camera + 41 ,y], (camera + 41) and 63 ,y, 1)
    move.w #1,-(a7)
    move.w (_local_y,a6),-(a7)
    move.w _global_camera,d0
    add.w #41,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w _global_camera,d0
    add.w #41,d0
    move.w (_local_y,a6),d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w 0(a0,d0.w),-(a7)
    bsr draw_tile
    addq #8,a7
    moveq #1,d0
    add.w d0,(_local_y,a6)
    bra lbl_for_2_start

    ; next
lbl_for_2_end:

    ; x_scroll += 16
    moveq #16,d0
    add.w d0,_global_x_scroll

    ; dave.x  -= 32
    moveq #32,d0
    sub.w d0,(_global_dave+0)

    ; camera  += 2
    moveq #2,d0
    add.w d0,_global_camera

    ; frame_c +=1 'A contagem de frames tambem tem que acontecer durante a animacao dos cenarios
    moveq #1,d0
    add.w d0,_global_frame_c

    ; set_sprite_position(dave.sprite,dave.x>>1,dave.y>>1)
    move.w (_global_dave+2),d0
    lsr.w #1,d0
    move.w d0,-(a7)
    move.w (_global_dave+0),d0
    lsr.w #1,d0
    move.w d0,-(a7)
    move.w (_global_dave+4),-(a7)
    bsr set_sprite_position
    addq #6,a7

    ; Set_HorizontalScroll_position(x_scroll AND 511,1)
    move.w #1,-(a7)
    move.w _global_x_scroll,d0
    and.w #511,d0
    move.w d0,-(a7)
    bsr Set_HorizontalScroll_position
    addq #4,a7

    ; vbl=1
    move.w #1,_global_vbl

    ; while(vbl) : wend
lbl_while_start_2:
    tst.w _global_vbl
    bne lbl_while_true_2
    bra lbl_while_false_2
lbl_while_true_2:
    bra lbl_while_start_2

    ; while(vbl) : wend
lbl_while_false_2:
    moveq #1,d0
    add.w d0,(_local_i,a6)
    bra lbl_for_1_start

    ; next 
lbl_for_1_end:
    unlk a6 
    rts

    ;end sub

    ;sub scroll_left() ' Animacao de transicao do cenario para a Esquerda
scroll_left:
; Auto Declaracao variavel ->  for i=0 to 15    'Scroll de 15 blocos
_local_i set -2
; Auto Declaracao variavel ->  for y = 0 to 20 ' Desenha uma linha vertical de 16 Pixels de largura na margem esquerda da tela
_local_y set -4
    link a6,#-4

    ; for i=0 to 15    'Scroll de 15 blocos
    moveq #0,d0
    move.w d0,(_local_i,a6)
lbl_for_3_start:
    move.w (_local_i,a6),d0
    cmp.w #15,d0
    beq lbl_for_3_end

    ; for y = 0 to 20 ' Desenha uma linha vertical de 16 Pixels de largura na margem esquerda da tela
    moveq #0,d0
    move.w d0,(_local_y,a6)
lbl_for_4_start:
    move.w (_local_y,a6),d0
    cmp.w #20,d0
    beq lbl_for_4_end

    ; draw_tile(tile_map_ram[camera-1 ,y], (camera-1) and 63 ,y, 1)
    move.w #1,-(a7)
    move.w (_local_y,a6),-(a7)
    move.w _global_camera,d0
    subq #1,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w _global_camera,d0
    subq #1,d0
    move.w (_local_y,a6),d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w 0(a0,d0.w),-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(tile_map_ram[camera-2 ,y], (camera-2) and 63 ,y, 1)
    move.w #1,-(a7)
    move.w (_local_y,a6),-(a7)
    move.w _global_camera,d0
    subq #2,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w _global_camera,d0
    subq #2,d0
    move.w (_local_y,a6),d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w 0(a0,d0.w),-(a7)
    bsr draw_tile
    addq #8,a7
    moveq #1,d0
    add.w d0,(_local_y,a6)
    bra lbl_for_4_start

    ; next 
lbl_for_4_end:

    ; x_scroll -= 16
    moveq #16,d0
    sub.w d0,_global_x_scroll

    ; dave.x  += 32
    moveq #32,d0
    add.w d0,(_global_dave+0)

    ; camera  -= 2
    moveq #2,d0
    sub.w d0,_global_camera

    ; frame_c +=1  'A contagem de frames tambem tem que acontecer durante a animacao dos cenarios
    moveq #1,d0
    add.w d0,_global_frame_c

    ; set_sprite_position(dave.sprite,dave.x>>1,dave.y>>1)
    move.w (_global_dave+2),d0
    lsr.w #1,d0
    move.w d0,-(a7)
    move.w (_global_dave+0),d0
    lsr.w #1,d0
    move.w d0,-(a7)
    move.w (_global_dave+4),-(a7)
    bsr set_sprite_position
    addq #6,a7

    ; Set_HorizontalScroll_position(x_scroll AND 511,1)
    move.w #1,-(a7)
    move.w _global_x_scroll,d0
    and.w #511,d0
    move.w d0,-(a7)
    bsr Set_HorizontalScroll_position
    addq #4,a7

    ; vbl=1
    move.w #1,_global_vbl

    ; while(vbl) : wend
lbl_while_start_3:
    tst.w _global_vbl
    bne lbl_while_true_3
    bra lbl_while_false_3
lbl_while_true_3:
    bra lbl_while_start_3

    ; while(vbl) : wend
lbl_while_false_3:
    moveq #1,d0
    add.w d0,(_local_i,a6)
    bra lbl_for_3_start

    ; next 
lbl_for_3_end:
    unlk a6 
    rts

    ;end sub

    ;sub draw_frame_rate()
draw_frame_rate:
; Auto Declaracao variavel ->  centena = frame_rate  /  100
_local_centena set -2
; Auto Declaracao variavel ->  dezenap = frame_rate mod 100
_local_dezenap set -4
; Auto Declaracao variavel ->  dezena = dezenap / 10
_local_dezena set -6
; Auto Declaracao variavel ->  unidade = dezenap mod 10
_local_unidade set -8
    link a6,#-8

    ; centena = frame_rate  /  100
    moveq #0,d0
    move.w _global_frame_rate,d0
    divu #100,d0
    move.w d0,(_local_centena,a6)

    ; dezenap = frame_rate mod 100
    moveq #0,d0
    move.w _global_frame_rate,d0
    divu #100,d0
    swap d0
    move.w d0,(_local_dezenap,a6)

    ; dezena = dezenap / 10
    moveq #0,d0
    move.w (_local_dezenap,a6),d0
    divu #10,d0
    move.w d0,(_local_dezena,a6)

    ; unidade = dezenap mod 10
    moveq #0,d0
    move.w (_local_dezenap,a6),d0
    divu #10,d0
    swap d0
    move.w d0,(_local_unidade,a6)

    ; draw_tile( ( centena+241 ) or 3<<13 , 37 , 21 , 0)
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w #37,-(a7)
    move.w (_local_centena,a6),d0
    add.w #241,d0
    or.w #(3<<13),d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile( (  dezena+241 ) or 3<<13 , 38 , 21 , 0)
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w #38,-(a7)
    move.w (_local_dezena,a6),d0
    add.w #241,d0
    or.w #(3<<13),d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile( ( unidade+241 ) or 3<<13 , 39 , 21 , 0)
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w #39,-(a7)
    move.w (_local_unidade,a6),d0
    add.w #241,d0
    or.w #(3<<13),d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7
    unlk a6 
    rts

    ;end sub

    ;sub Draw_score()
Draw_score:
; Auto Declaracao variavel ->  centena = score  /  100
_local_centena set -2
; Auto Declaracao variavel ->  dezenap = score mod 100
_local_dezenap set -4
; Auto Declaracao variavel ->  dezena = dezenap / 10
_local_dezena set -6
; Auto Declaracao variavel ->  unidade = dezenap mod 10
_local_unidade set -8
    link a6,#-8

    ; centena = score  /  100
    moveq #0,d0
    move.w _global_score,d0
    divu #100,d0
    move.w d0,(_local_centena,a6)

    ; dezenap = score mod 100
    moveq #0,d0
    move.w _global_score,d0
    divu #100,d0
    swap d0
    move.w d0,(_local_dezenap,a6)

    ; dezena = dezenap / 10
    moveq #0,d0
    move.w (_local_dezenap,a6),d0
    divu #10,d0
    move.w d0,(_local_dezena,a6)

    ; unidade = dezenap mod 10
    moveq #0,d0
    move.w (_local_dezenap,a6),d0
    divu #10,d0
    swap d0
    move.w d0,(_local_unidade,a6)

    ; draw_tile( ( centena+241 ) or 3<<13 , 35 , 20 , 0)
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #35,-(a7)
    move.w (_local_centena,a6),d0
    add.w #241,d0
    or.w #(3<<13),d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile( (  dezena+241 ) or 3<<13 , 36 , 20 , 0)
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #36,-(a7)
    move.w (_local_dezena,a6),d0
    add.w #241,d0
    or.w #(3<<13),d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile( ( unidade+241 ) or 3<<13 , 37 , 20 , 0)
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #37,-(a7)
    move.w (_local_unidade,a6),d0
    add.w #241,d0
    or.w #(3<<13),d0
    move.w d0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(             241 or 3<<13 , 38 , 20 , 0)
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #38,-(a7)
    move.w #(241|(3<<13)),-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(             241 or 3<<13 , 39 , 20 , 0)
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #39,-(a7)
    move.w #(241|(3<<13)),-(a7)
    bsr draw_tile
    addq #8,a7
    unlk a6 
    rts

    ;end sub

    ;sub anima_cenario()  
anima_cenario:
; dim gfx as integer
_local_gfx set -2
    link a6,#-2

    ; load_tiles_DMA_128ksafe((addressof(tiles) + 132*32)+(anima_tiles2<<7),4,133) ' Agua
    move.l #133,-(a7)
    move.w #4,-(a7)
    moveq #0,d0
    move.w _global_anima_tiles2,d0
    lsl.l #7,d0
    add.l #(tiles+(132*32)),d0
    move.l d0,-(a7)
    bsr load_tiles_DMA_128ksafe
    lea 10(a7),a7

    ; load_tiles_DMA_128ksafe((addressof(tiles) + 152*32)+(anima_tiles2<<7),4,153) ' Trofeu
    move.l #153,-(a7)
    move.w #4,-(a7)
    moveq #0,d0
    move.w _global_anima_tiles2,d0
    lsl.l #7,d0
    add.l #(tiles+(152*32)),d0
    move.l d0,-(a7)
    bsr load_tiles_DMA_128ksafe
    lea 10(a7),a7

    ; load_tiles_DMA_128ksafe((addressof(tiles) + 172*32)+(anima_tiles1<<7),4,173) ' Fogo
    move.l #173,-(a7)
    move.w #4,-(a7)
    moveq #0,d0
    move.w _global_anima_tiles1,d0
    lsl.l #7,d0
    add.l #(tiles+(172*32)),d0
    move.l d0,-(a7)
    bsr load_tiles_DMA_128ksafe
    lea 10(a7),a7

    ; load_tiles_DMA_128ksafe((addressof(tiles) + 188*32)+(anima_tiles1<<7),4,189) ' Plantas
    move.l #189,-(a7)
    move.w #4,-(a7)
    moveq #0,d0
    move.w _global_anima_tiles1,d0
    lsl.l #7,d0
    add.l #(tiles+(188*32)),d0
    move.l d0,-(a7)
    bsr load_tiles_DMA_128ksafe
    lea 10(a7),a7

    ; anima_tiles2 +=1
    moveq #1,d0
    add.w d0,_global_anima_tiles2

    ; anima_tiles1 +=1
    moveq #1,d0
    add.w d0,_global_anima_tiles1

    ; anima_dave   +=1
    moveq #1,d0
    add.w d0,_global_anima_dave

    ; if anima_tiles2 > 4 then anima_tiles2 = 0
    move.w _global_anima_tiles2,d0
    cmp.w #4,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_6
    bra lbl_if_false_6
lbl_if_true_6:

    ; if anima_tiles2 > 4 then anima_tiles2 = 0
    move.w #0,_global_anima_tiles2
lbl_if_false_6:

    ; if anima_tiles1 > 3 then anima_tiles1 = 0
    move.w _global_anima_tiles1,d0
    cmp.w #3,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_7
    bra lbl_if_false_7
lbl_if_true_7:

    ; if anima_tiles1 > 3 then anima_tiles1 = 0
    move.w #0,_global_anima_tiles1
lbl_if_false_7:

    ; if anima_dave   > 2 then anima_dave   = 0
    move.w _global_anima_dave,d0
    cmp.w #2,d0
    shi d0
    and.w #$01,d0
    dbra d0,lbl_if_true_8
    bra lbl_if_false_8
lbl_if_true_8:

    ; if anima_dave   > 2 then anima_dave   = 0
    move.w #0,_global_anima_dave
lbl_if_false_8:

    ; if bit_test(dave.flags,1) OR bit_test(dave.flags,0) then
    move.w (_global_dave+10),d0
    btst #1,d0
    sne d0
    and.w #$01,d0
    move.w (_global_dave+10),d1
    btst #0,d1
    sne d1
    and.w #$01,d1
    or.w d1,d0
    dbra d0,lbl_if_true_9
    bra lbl_if_false_9
lbl_if_true_9:

    ; gfx = 221                   ' Sprite Caindo
    move.w #221,(_local_gfx,a6)
    bra lbl_if_end_9
lbl_if_false_9:

    ; elseif dirx then
    tst.w _global_dirx
    bne lbl_elseif_true_10
    bra lbl_elseif_false_10
lbl_elseif_true_10:

    ; gfx = 205 + (anima_dave<<2) ' Sprite Andando
    move.w _global_anima_dave,d0
    add.w d0,d0
    add.w d0,d0
    add.w #205,d0
    move.w d0,(_local_gfx,a6)
    bra lbl_if_end_9
lbl_elseif_false_10:

    ; else

    ; gfx = 209                   ' Sprite Parado
    move.w #209,(_local_gfx,a6)
lbl_if_end_9:

    ; set_sprite_gfx(dave.sprite,gfx or dave.flip,2)
    move.w #2,-(a7)
    move.w (_local_gfx,a6),d0
    or.w (_global_dave+8),d0
    move.w d0,-(a7)
    move.w (_global_dave+4),-(a7)
    bsr set_sprite_gfx
    addq #6,a7

    ; frame = 0 ' Zera a variavel de contagem para a temporizacao das animacoes
    move.w #0,_global_frame
    unlk a6 
    rts

    ;end sub

    ;sub load_level(byref _ram_map_ as integer , byref _ram_col_map_ as byte, byval level as integer)
load_level:
; Auto Declaracao variavel ->  for k=0 to (200*20) 'Tamanho do mapa em Tiles
_local_k set -2
    link a6,#-2
; byref _local__ram_map_ as word
_local__ram_map_ set 8
; byref _local__ram_col_map_ as byte
_local__ram_col_map_ set 12
; byval _local_level as word
_local_level set 16

    ; X_scroll   = 0 ' Limpa a variavel que armazena a posicao vertical da Scroll Plane
    move.w #0,_global_X_scroll

    ; camera     = 0 ' Coloca a camera no inicio do level
    move.w #0,_global_camera

    ; dave.flags = 0 ' Limpa todos os Flags
    move.w #0,(_global_dave+10)

    ; dave.flip  = 0 ' Personagem virado para a Direita
    move.w #0,(_global_dave+8)

    ; push((addressof(levels_) +((level * 1000)<<3)) as long, "A5") 'Salva o endereco do tile map no Registrador A5
    moveq #0,d0
    move.w (_local_level,a6),d0
    mulu #1000,d0
    lsl.l #3,d0
    add.l #levels_,d0
    move.l d0,A5

    ; for k=0 to (200*20) 'Tamanho do mapa em Tiles
    moveq #0,d0
    move.w d0,(_local_k,a6)
lbl_for_5_start:
    move.w (_local_k,a6),d0
    cmp.w #(200*20),d0
    beq lbl_for_5_end

    ; _ram_map_[k] = pop("(A5)+" as word) +1 ' Le o registrador (A5) como enderecamento indireto com pos-incremento e soma 1 ao valor (1 e o offset na Vram)
    move.w (_local_k,a6),d0
    add.w d0,d0
    move.l (_local__ram_map_,a6),a0
    move.w (A5)+,d1
    addq #1,d1
    move.w d1,0(a0,d0.w)

    ; if _ram_map_[k] <= 37 then _ram_map_[k] |= 1<<13 'Se o tile for menor que 37 ele deve ser desenhado com a paleta 01 da Cram
    move.w (_local_k,a6),d0
    add.w d0,d0
    move.l (_local__ram_map_,a6),a0
    move.w 0(a0,d0.w),d1
    cmp.w #37,d1
    sls d1
    and.w #$01,d1
    dbra d1,lbl_if_true_11
    bra lbl_if_false_11
lbl_if_true_11:

    ; if _ram_map_[k] <= 37 then _ram_map_[k] |= 1<<13 'Se o tile for menor que 37 ele deve ser desenhado com a paleta 01 da Cram
    move.w (_local_k,a6),d0
    add.w d0,d0
    move.l (_local__ram_map_,a6),a0
    move.w #(1<<13),d1
    or.w d1,0(a0,d0.w)
lbl_if_false_11:
    moveq #1,d0
    add.w d0,(_local_k,a6)
    bra lbl_for_5_start

    ; next k
lbl_for_5_end:

    ; push(addressof(colision_map) + (level * 1000) as long, "A5")
    moveq #0,d0
    move.w (_local_level,a6),d0
    mulu #1000,d0
    add.l #colision_map,d0
    move.l d0,A5

    ; for k=0 to (100*10) 'Tamanho doColision Map
    moveq #0,d0
    move.w d0,(_local_k,a6)
lbl_for_6_start:
    move.w (_local_k,a6),d0
    cmp.w #(100*10),d0
    beq lbl_for_6_end

    ; _ram_col_map_[k] = pop("(A5)+" as byte) '
    move.w (_local_k,a6),d0
    move.l (_local__ram_col_map_,a6),a0
    move.b (A5)+,d1
    move.b d1,0(a0,d0.w)
    moveq #1,d0
    add.w d0,(_local_k,a6)
    bra lbl_for_6_start

    ; next k
lbl_for_6_end:

    ; Set_HorizontalScroll_position(0,1)
    move.w #1,-(a7)
    move.w #0,-(a7)
    bsr Set_HorizontalScroll_position
    addq #4,a7

    ; draw_screen()                ' Desenha o level(Plane B)
    bsr draw_screen

    ; set_initial_position(level)  ' Define Posicao inicial do sprite
    move.w (_local_level,a6),-(a7)
    bsr set_initial_position
    addq #2,a7

    ; for k = 0 to 40
    moveq #0,d0
    move.w d0,(_local_k,a6)
lbl_for_7_start:
    move.w (_local_k,a6),d0
    cmp.w #40,d0
    beq lbl_for_7_end

    ; draw_tile(0,k,20,0)
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w (_local_k,a6),-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(0,k,21,0)
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w (_local_k,a6),-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7
    moveq #1,d0
    add.w d0,(_local_k,a6)
    bra lbl_for_7_start

    ; Next 
lbl_for_7_end:
    unlk a6 
    rts

    ;end sub

    ;sub set_initial_position(byval lv as word)
set_initial_position:
    link a6,#-0
; byval _local_lv as word
_local_lv set 8

    ; select lv
    move.w (_local_lv,a6),d0

    ; case 0 'Level 1
    tst.w d0
    beq lbl_case_true_2
    bra lbl_case_false_2
lbl_case_true_2:

    ; dave.x = (128 + (2<<4))*2
    move.w #((128+(2<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (8<<4))*2
    move.w #((128+(8<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_2:

    ; case 1 'Level 2 
    cmp.w #1,d0
    beq lbl_case_true_3
    bra lbl_case_false_3
lbl_case_true_3:

    ; dave.x = (128 + (1<<4))*2
    move.w #((128+(1<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (8<<4))*2
    move.w #((128+(8<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_3:

    ; case 2 'Level 3
    cmp.w #2,d0
    beq lbl_case_true_4
    bra lbl_case_false_4
lbl_case_true_4:

    ; dave.x = (128 + (2<<4))*2
    move.w #((128+(2<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (5<<4))*2
    move.w #((128+(5<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_4:

    ; case 3 'Level 4
    cmp.w #3,d0
    beq lbl_case_true_5
    bra lbl_case_false_5
lbl_case_true_5:

    ; dave.x = (128 + (1<<4))*2
    move.w #((128+(1<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (5<<4))*2
    move.w #((128+(5<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_5:

    ; case 4 'Level 5
    cmp.w #4,d0
    beq lbl_case_true_6
    bra lbl_case_false_6
lbl_case_true_6:

    ; dave.x = (128 + (2<<4))*2
    move.w #((128+(2<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (8<<4))*2
    move.w #((128+(8<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_6:

    ; case 5 'Level 6
    cmp.w #5,d0
    beq lbl_case_true_7
    bra lbl_case_false_7
lbl_case_true_7:

    ; dave.x = (128 + (1<<4))*2
    move.w #((128+(1<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (8<<4))*2
    move.w #((128+(8<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_7:

    ; case 6 'Level 7
    cmp.w #6,d0
    beq lbl_case_true_8
    bra lbl_case_false_8
lbl_case_true_8:

    ; dave.x = (128 + (1<<4))*2
    move.w #((128+(1<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (2<<4))*2
    move.w #((128+(2<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_8:

    ; case 7 'Level 8
    cmp.w #7,d0
    beq lbl_case_true_9
    bra lbl_case_false_9
lbl_case_true_9:

    ; dave.x = (128 + (2<<4))*2
    move.w #((128+(2<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (8<<4))*2
    move.w #((128+(8<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_9:

    ; case 8 'Level 9
    cmp.w #8,d0
    beq lbl_case_true_10
    bra lbl_case_false_10
lbl_case_true_10:

    ; dave.x = (128 + (6<<4))*2
    move.w #((128+(6<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (1<<4))*2
    move.w #((128+(1<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_10:

    ; case 9 'Level 10
    cmp.w #9,d0
    beq lbl_case_true_11
    bra lbl_case_false_11
lbl_case_true_11:

    ; dave.x = (128 + (2<<4))*2
    move.w #((128+(2<<4))*2),(_global_dave+0)

    ; dave.y = (128 + (8<<4))*2
    move.w #((128+(8<<4))*2),(_global_dave+2)
    bra lbl_select_end_1
lbl_case_false_11:

    ; end select
lbl_select_end_1:
    unlk a6 
    rts

    ;end sub

    ;sub draw_screen() 
draw_screen:
; Auto Declaracao variavel ->  for y = 0 to 20
_local_y set -2
; Auto Declaracao variavel ->  for x = 0 to 40
_local_x set -4
    link a6,#-4

    ; for y = 0 to 20
    moveq #0,d0
    move.w d0,(_local_y,a6)
lbl_for_8_start:
    move.w (_local_y,a6),d0
    cmp.w #20,d0
    beq lbl_for_8_end

    ; for x = 0 to 40
    moveq #0,d0
    move.w d0,(_local_x,a6)
lbl_for_9_start:
    move.w (_local_x,a6),d0
    cmp.w #40,d0
    beq lbl_for_9_end

    ; draw_tile(tile_map_ram[ x + camera , y ] ,x,y,1)
    move.w #1,-(a7)
    move.w (_local_y,a6),-(a7)
    move.w (_local_x,a6),-(a7)
    move.w (_local_x,a6),d0
    add.w _global_camera,d0
    move.w (_local_y,a6),d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w 0(a0,d0.w),-(a7)
    bsr draw_tile
    addq #8,a7
    moveq #1,d0
    add.w d0,(_local_x,a6)
    bra lbl_for_9_start

    ; next 
lbl_for_9_end:
    moveq #1,d0
    add.w d0,(_local_y,a6)
    bra lbl_for_8_start

    ; next  
lbl_for_8_end:
    unlk a6 
    rts

    ;end sub

    ;sub input_thread()
input_thread:
; Auto Declaracao variavel ->  j = joypad6b_read(0)
_local_j set -2
    link a6,#-2

    ; j = joypad6b_read(0)
    move.w #0,-(a7)
    bsr joypad6b_read
    addq #2,a7
    move.w d7,(_local_j,a6)

    ; dirx = 0
    move.w #0,_global_dirx

    ; if bit_test(j,2) then  ' Direita e Esquerda
    move.w (_local_j,a6),d0
    btst #2,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_if_true_12
    bra lbl_if_false_12
lbl_if_true_12:

    ; dirx = - 3
    move.w #-3,_global_dirx

    ; dave.flip = &h800 ' Precisamos aplicar um Flip Horizontal caso o Personagem esteja indo pra esquerda
    move.w #$800,(_global_dave+8)
    bra lbl_if_end_12
lbl_if_false_12:

    ; elseif bit_test(j,3) then
    move.w (_local_j,a6),d0
    btst #3,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_13
    bra lbl_elseif_false_13
lbl_elseif_true_13:

    ; dirx = 3
    move.w #3,_global_dirx

    ; dave.flip = 0
    move.w #0,(_global_dave+8)
    bra lbl_if_end_12
lbl_elseif_false_13:
lbl_if_end_12:

    ; if bit_test(j,0) AND not(bit_test(dave.flags,0)) AND not(bit_test(dave.flags,1)) then 'Botao UP + Flags que impedem double Jump 
    move.w (_local_j,a6),d0
    btst #0,d0
    sne d0
    and.w #$01,d0
    move.w (_global_dave+10),d1
    btst #0,d1
    sne d1
    and.w #$01,d1
    tst.w d1
    seq d1
    and.w #$01,d1
    move.w (_global_dave+10),d2
    btst #1,d2
    sne d2
    and.w #$01,d2
    tst.w d2
    seq d2
    and.w #$01,d2
    and.w d2,d1
    and.w d1,d0
    dbra d0,lbl_if_true_14
    bra lbl_if_false_14
lbl_if_true_14:

    ; bit_set(dave.flags,1) ' Seta o Flag que indica se esta pulando
    move.w (_global_dave+10),d0
    bset.l #1,d0
    move.w d0,(_global_dave+10)
    bra lbl_if_end_14
lbl_if_false_14:
lbl_if_end_14:

    ; if bit_test(dave.flags,1) AND dave.hjump < 33 then ' Esta pulando e nao atingiu a altura maxima ainda
    move.w (_global_dave+10),d0
    btst #1,d0
    sne d0
    and.w #$01,d0
    move.w (_global_dave+6),d1
    cmp.w #33,d1
    scs d1
    and.w #$01,d1
    and.w d1,d0
    dbra d0,lbl_if_true_15
    bra lbl_if_false_15
lbl_if_true_15:

    ; dave.hjump+=1 
    moveq #1,d0
    add.w d0,(_global_dave+6)

    ; gravidade =-2
    move.w #-2,_global_gravidade
    bra lbl_if_end_15
lbl_if_false_15:

    ; else  

    ; bit_clear(dave.flags,1)
    move.w (_global_dave+10),d0
    bclr.l #1,d0
    move.w d0,(_global_dave+10)

    ; dave.hjump=0
    move.w #0,(_global_dave+6)

    ; gravidade=2
    move.w #2,_global_gravidade
lbl_if_end_15:
    unlk a6 
    rts

    ;end sub

    ;sub check_colision()
check_colision:
; Auto Declaracao variavel ->  hy1 =  ((Dave.y>>1) - 128-2 )>>4
_local_hy1 set -2
; Auto Declaracao variavel ->  hy2 =  ((Dave.y>>1) - 128-15)>>4 
_local_hy2 set -4
; Auto Declaracao variavel ->  hx  = (((Dave.x>>1) - 128-14)>>4) + (camera>>1)
_local_hx set -6
; Auto Declaracao variavel ->  col_point0 = colision_vector[ hx , hy1 ]
_local_col_point0 set -8
; Auto Declaracao variavel ->  col_point1 = colision_vector[ hx , hy2 ]
_local_col_point1 set -10
; Auto Declaracao variavel ->  vx1 = (((Dave.x>>1) - 128-4 )>>4) + (camera>>1)
_local_vx1 set -12
; Auto Declaracao variavel ->  vx2 = (((Dave.x>>1) - 128-12)>>4) + (camera>>1)
_local_vx2 set -14
; Auto Declaracao variavel ->  vy = ((Dave.y>>1) - 128-16)>>4
_local_vy set -16
; Auto Declaracao variavel ->  col_point3 = colision_vector[ vx1 , vy ]
_local_col_point3 set -18
; Auto Declaracao variavel ->  col_point4 = colision_vector[ vx2 , vy ]
_local_col_point4 set -20
    link a6,#-20

    ; hy1 =  ((Dave.y>>1) - 128-2 )>>4
    move.w (_global_Dave+2),d0
    lsr.w #1,d0
    sub.w #(128-2),d0
    lsr.w #4,d0
    move.w d0,(_local_hy1,a6)

    ; hy2 =  ((Dave.y>>1) - 128-15)>>4 
    move.w (_global_Dave+2),d0
    lsr.w #1,d0
    sub.w #(128-15),d0
    lsr.w #4,d0
    move.w d0,(_local_hy2,a6)

    ; if dirx = 3 then ' Indo para a direita
    move.w _global_dirx,d0
    cmp.w #3,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_16
    bra lbl_if_false_16
lbl_if_true_16:

    ; hx  = (((Dave.x>>1) - 128-14)>>4) + (camera>>1)
    move.w (_global_Dave+0),d0
    lsr.w #1,d0
    sub.w #(128-14),d0
    lsr.w #4,d0
    move.w _global_camera,d1
    lsr.w #1,d1
    add.w d1,d0
    move.w d0,(_local_hx,a6)

    ; col_point0 = colision_vector[ hx , hy1 ]
    move.w (_local_hy1,a6),d0
    mulu #100,d0
    add.w (_local_hx,a6),d0
    lea _global_colision_vector,a0
    moveq #0,d1
    move.b 0(a0,d0.w),d1
    move.w d1,(_local_col_point0,a6)

    ; col_point1 = colision_vector[ hx , hy2 ]
    move.w (_local_hy2,a6),d0
    mulu #100,d0
    add.w (_local_hx,a6),d0
    lea _global_colision_vector,a0
    moveq #0,d1
    move.b 0(a0,d0.w),d1
    move.w d1,(_local_col_point1,a6)
    bra lbl_if_end_16
lbl_if_false_16:

    ; else'if dirx = -1 then 'Indo para a esquerda

    ; hx  = (((Dave.x>>1) - 128-2 )>>4) + (camera>>1)
    move.w (_global_Dave+0),d0
    lsr.w #1,d0
    sub.w #(128-2),d0
    lsr.w #4,d0
    move.w _global_camera,d1
    lsr.w #1,d1
    add.w d1,d0
    move.w d0,(_local_hx,a6)

    ; col_point0 = colision_vector[ hx , hy1 ]
    move.w (_local_hy1,a6),d0
    mulu #100,d0
    add.w (_local_hx,a6),d0
    lea _global_colision_vector,a0
    moveq #0,d1
    move.b 0(a0,d0.w),d1
    move.w d1,(_local_col_point0,a6)

    ; col_point1 = colision_vector[ hx , hy2 ] 
    move.w (_local_hy2,a6),d0
    mulu #100,d0
    add.w (_local_hx,a6),d0
    lea _global_colision_vector,a0
    moveq #0,d1
    move.b 0(a0,d0.w),d1
    move.w d1,(_local_col_point1,a6)
lbl_if_end_16:

    ; vx1 = (((Dave.x>>1) - 128-4 )>>4) + (camera>>1)
    move.w (_global_Dave+0),d0
    lsr.w #1,d0
    sub.w #(128-4),d0
    lsr.w #4,d0
    move.w _global_camera,d1
    lsr.w #1,d1
    add.w d1,d0
    move.w d0,(_local_vx1,a6)

    ; vx2 = (((Dave.x>>1) - 128-12)>>4) + (camera>>1)
    move.w (_global_Dave+0),d0
    lsr.w #1,d0
    sub.w #(128-12),d0
    lsr.w #4,d0
    move.w _global_camera,d1
    lsr.w #1,d1
    add.w d1,d0
    move.w d0,(_local_vx2,a6)

    ; if gravidade = 2 then 'indo para baixo
    move.w _global_gravidade,d0
    cmp.w #2,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_17
    bra lbl_if_false_17
lbl_if_true_17:

    ; vy = ((Dave.y>>1) - 128-16)>>4
    move.w (_global_Dave+2),d0
    lsr.w #1,d0
    sub.w #(128-16),d0
    lsr.w #4,d0
    move.w d0,(_local_vy,a6)

    ; col_point3 = colision_vector[ vx1 , vy ]
    move.w (_local_vy,a6),d0
    mulu #100,d0
    add.w (_local_vx1,a6),d0
    lea _global_colision_vector,a0
    moveq #0,d1
    move.b 0(a0,d0.w),d1
    move.w d1,(_local_col_point3,a6)

    ; col_point4 = colision_vector[ vx2 , vy ]
    move.w (_local_vy,a6),d0
    mulu #100,d0
    add.w (_local_vx2,a6),d0
    lea _global_colision_vector,a0
    moveq #0,d1
    move.b 0(a0,d0.w),d1
    move.w d1,(_local_col_point4,a6)
    bra lbl_if_end_17
lbl_if_false_17:

    ; else'if gravidade = -1 then 'Indo para cima

    ; vy = ((Dave.y>>1) - 128-1 )>>4
    move.w (_global_Dave+2),d0
    lsr.w #1,d0
    sub.w #(128-1),d0
    lsr.w #4,d0
    move.w d0,(_local_vy,a6)

    ; col_point3 = colision_vector[ vx1 , vy ]
    move.w (_local_vy,a6),d0
    mulu #100,d0
    add.w (_local_vx1,a6),d0
    lea _global_colision_vector,a0
    moveq #0,d1
    move.b 0(a0,d0.w),d1
    move.w d1,(_local_col_point3,a6)

    ; col_point4 = colision_vector[ vx2 , vy ]
    move.w (_local_vy,a6),d0
    mulu #100,d0
    add.w (_local_vx2,a6),d0
    lea _global_colision_vector,a0
    moveq #0,d1
    move.b 0(a0,d0.w),d1
    move.w d1,(_local_col_point4,a6)
lbl_if_end_17:

    ; if hy1 = hy2 then ' Os dois pontos estao no mesmo tile -> Analisa um ponto so
    move.w (_local_hy1,a6),d0
    cmp.w (_local_hy2,a6),d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_18
    bra lbl_if_false_18
lbl_if_true_18:

    ;  if col_point0 = 1 then             ' E um solido 
    move.w (_local_col_point0,a6),d0
    cmp.w #1,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_19
    bra lbl_if_false_19
lbl_if_true_19:

    ;  dirx = 0                           ' Entao, apenas bloqueia o caminho
    move.w #0,_global_dirx
    bra lbl_if_end_19
lbl_if_false_19:

    ;  elseif col_point0 <> 0 then        ' Se nao e um solido e e algo diferente de um espaco vazio
    move.w (_local_col_point0,a6),d0
    tst.w d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_20
    bra lbl_elseif_false_20
lbl_elseif_true_20:

    ;  check_vertices(col_point0,hx,hy1)  '  Chama a rotina para verificar que objeto e
    move.w (_local_hy1,a6),-(a7)
    move.w (_local_hx,a6),-(a7)
    move.w (_local_col_point0,a6),-(a7)
    bsr check_vertices
    addq #6,a7
    bra lbl_if_end_19
lbl_elseif_false_20:
lbl_if_end_19:
    bra lbl_if_end_18
lbl_if_false_18:

    ; else ' Os Dois pontos estao em Tiles diferentesm -> entao analisa os Dois

    ;  if col_point0 = 1 then             ' E um solido 
    move.w (_local_col_point0,a6),d0
    cmp.w #1,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_21
    bra lbl_if_false_21
lbl_if_true_21:

    ;  dirx = 0                           ' Apenas bloqueia o caminho
    move.w #0,_global_dirx
    bra lbl_if_end_21
lbl_if_false_21:

    ;  elseif col_point0 <> 0 then        ' E algo diferente de um espaco vazio
    move.w (_local_col_point0,a6),d0
    tst.w d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_22
    bra lbl_elseif_false_22
lbl_elseif_true_22:

    ;  check_vertices(col_point0,hx,hy1)  ' Chama a rotina para verificar que objeto e
    move.w (_local_hy1,a6),-(a7)
    move.w (_local_hx,a6),-(a7)
    move.w (_local_col_point0,a6),-(a7)
    bsr check_vertices
    addq #6,a7
    bra lbl_if_end_21
lbl_elseif_false_22:
lbl_if_end_21:

    ;  if col_point1 = 1 then             ' E um solido
    move.w (_local_col_point1,a6),d0
    cmp.w #1,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_23
    bra lbl_if_false_23
lbl_if_true_23:

    ;  dirx=0                             ' Apenas bloqueia o caminho
    move.w #0,_global_dirx
    bra lbl_if_end_23
lbl_if_false_23:

    ;  elseif col_point1 <> 0 then        ' E algo diferente de um espaco vazio
    move.w (_local_col_point1,a6),d0
    tst.w d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_24
    bra lbl_elseif_false_24
lbl_elseif_true_24:

    ;  check_vertices(col_point1,hx,hy2)  ' Chama a rotina para verificar que objeto e
    move.w (_local_hy2,a6),-(a7)
    move.w (_local_hx,a6),-(a7)
    move.w (_local_col_point1,a6),-(a7)
    bsr check_vertices
    addq #6,a7
    bra lbl_if_end_23
lbl_elseif_false_24:
lbl_if_end_23:
lbl_if_end_18:

    ; if vx1 = vx2 then ' Os dois pontos estao no mesmo tile
    move.w (_local_vx1,a6),d0
    cmp.w (_local_vx2,a6),d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_25
    bra lbl_if_false_25
lbl_if_true_25:

    ; if col_point3 = 1 then             ' E um solido 
    move.w (_local_col_point3,a6),d0
    cmp.w #1,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_26
    bra lbl_if_false_26
lbl_if_true_26:

    ;  if gravidade = -2 AND bit_test(dave.flags,1) then ' Acertou algo que limita o pulo
    move.w _global_gravidade,d0
    cmp.w #-2,d0
    seq d0
    and.w #$01,d0
    move.w (_global_dave+10),d1
    btst #1,d1
    sne d1
    and.w #$01,d1
    and.w d1,d0
    dbra d0,lbl_if_true_27
    bra lbl_if_false_27
lbl_if_true_27:

    ;  bit_clear(dave.flags,1)                           ' Fim do pulo (bateu a cebeca)
    move.w (_global_dave+10),d0
    bclr.l #1,d0
    move.w d0,(_global_dave+10)
    bra lbl_if_end_27
lbl_if_false_27:

    ;  elseif gravidade = 2 then                          ' Bateu em algo e a gravidade nao esta invertida
    move.w _global_gravidade,d0
    cmp.w #2,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_28
    bra lbl_elseif_false_28
lbl_elseif_true_28:

    ;  bit_clear(dave.flags,0)                          ' Nao esta caindo 
    move.w (_global_dave+10),d0
    bclr.l #0,d0
    move.w d0,(_global_dave+10)
    bra lbl_if_end_27
lbl_elseif_false_28:
lbl_if_end_27:

    ;  gravidade = 0                       ' Apenas bloqueia o caminho
    move.w #0,_global_gravidade
    bra lbl_if_end_26
lbl_if_false_26:

    ; elseif col_point3 <> 0 then        ' E algo diferente de um espaco vazio
    move.w (_local_col_point3,a6),d0
    tst.w d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_29
    bra lbl_elseif_false_29
lbl_elseif_true_29:

    ;  check_vertices(col_point3,vx1,vy)  ' Chama a rotina para verificar que objeto e
    move.w (_local_vy,a6),-(a7)
    move.w (_local_vx1,a6),-(a7)
    move.w (_local_col_point3,a6),-(a7)
    bsr check_vertices
    addq #6,a7
    bra lbl_if_end_26
lbl_elseif_false_29:
lbl_if_end_26:
    bra lbl_if_end_25
lbl_if_false_25:

    ; else ' Os dois ponto estao em Tiles Diferentes

    ;  if col_point3 = 1 then             ' E um solido 
    move.w (_local_col_point3,a6),d0
    cmp.w #1,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_30
    bra lbl_if_false_30
lbl_if_true_30:

    ;   if gravidade = -2 AND bit_test(dave.flags,1) then ' Acertou algo que limita o pulo
    move.w _global_gravidade,d0
    cmp.w #-2,d0
    seq d0
    and.w #$01,d0
    move.w (_global_dave+10),d1
    btst #1,d1
    sne d1
    and.w #$01,d1
    and.w d1,d0
    dbra d0,lbl_if_true_31
    bra lbl_if_false_31
lbl_if_true_31:

    ;   bit_clear(dave.flags,1)                           ' Fim do pulo (bateu a cebeca)
    move.w (_global_dave+10),d0
    bclr.l #1,d0
    move.w d0,(_global_dave+10)
    bra lbl_if_end_31
lbl_if_false_31:

    ;   elseif gravidade = 2 then                          ' Bateu em algo e a gravidade nao esta invertida
    move.w _global_gravidade,d0
    cmp.w #2,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_32
    bra lbl_elseif_false_32
lbl_elseif_true_32:

    ;   bit_clear(dave.flags,0)                          ' Nao esta caindo 
    move.w (_global_dave+10),d0
    bclr.l #0,d0
    move.w d0,(_global_dave+10)
    bra lbl_if_end_31
lbl_elseif_false_32:
lbl_if_end_31:

    ;   gravidade = 0                     ' Apenas bloqueia o caminho
    move.w #0,_global_gravidade
    bra lbl_if_end_30
lbl_if_false_30:

    ; elseif col_point3 <> 0 then        ' E algo diferente de um espaco vazio
    move.w (_local_col_point3,a6),d0
    tst.w d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_33
    bra lbl_elseif_false_33
lbl_elseif_true_33:

    ;  check_vertices(col_point3,vx1,vy)  ' Chama a rotina para verificar que objeto e
    move.w (_local_vy,a6),-(a7)
    move.w (_local_vx1,a6),-(a7)
    move.w (_local_col_point3,a6),-(a7)
    bsr check_vertices
    addq #6,a7
    bra lbl_if_end_30
lbl_elseif_false_33:
lbl_if_end_30:

    ; if col_point4 = 1 then             ' E um solido
    move.w (_local_col_point4,a6),d0
    cmp.w #1,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_34
    bra lbl_if_false_34
lbl_if_true_34:

    ;  if gravidade = -2 AND bit_test(dave.flags,1) then ' Acertou algo que limita o pula
    move.w _global_gravidade,d0
    cmp.w #-2,d0
    seq d0
    and.w #$01,d0
    move.w (_global_dave+10),d1
    btst #1,d1
    sne d1
    and.w #$01,d1
    and.w d1,d0
    dbra d0,lbl_if_true_35
    bra lbl_if_false_35
lbl_if_true_35:

    ;  bit_clear(dave.flags,1)                           ' Fim do pulo (bateu a cebeca)
    move.w (_global_dave+10),d0
    bclr.l #1,d0
    move.w d0,(_global_dave+10)
    bra lbl_if_end_35
lbl_if_false_35:

    ;  elseif gravidade = 2 then                              ' Bateu em algo ea gravidade nao esta invertida
    move.w _global_gravidade,d0
    cmp.w #2,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_36
    bra lbl_elseif_false_36
lbl_elseif_true_36:

    ;  bit_clear(dave.flags,0)                          ' Nao esta caindo 
    move.w (_global_dave+10),d0
    bclr.l #0,d0
    move.w d0,(_global_dave+10)
    bra lbl_if_end_35
lbl_elseif_false_36:
lbl_if_end_35:

    ;  gravidade = 0                      ' Apenas bloqueia o caminho
    move.w #0,_global_gravidade
    bra lbl_if_end_34
lbl_if_false_34:

    ; elseif col_point4 <> 0 then        ' E algo diferente de um espaco vazio
    move.w (_local_col_point4,a6),d0
    tst.w d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_37
    bra lbl_elseif_false_37
lbl_elseif_true_37:

    ;  check_vertices(col_point4,vx2,vy)  ' Chama a rotina para verificar que objeto e
    move.w (_local_vy,a6),-(a7)
    move.w (_local_vx2,a6),-(a7)
    move.w (_local_col_point4,a6),-(a7)
    bsr check_vertices
    addq #6,a7
    bra lbl_if_end_34
lbl_elseif_false_37:
lbl_if_end_34:
lbl_if_end_25:

    ; if gravidade = 2 then bit_set(dave.flags,0) 'Seta o Flag de queda
    move.w _global_gravidade,d0
    cmp.w #2,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_38
    bra lbl_if_false_38
lbl_if_true_38:

    ; if gravidade = 2 then bit_set(dave.flags,0) 'Seta o Flag de queda
    move.w (_global_dave+10),d0
    bset.l #0,d0
    move.w d0,(_global_dave+10)
lbl_if_false_38:

    ; dave.y += gravidade
    move.w _global_gravidade,d0
    add.w d0,(_global_dave+2)

    ; dave.x += dirx
    move.w _global_dirx,d0
    add.w d0,(_global_dave+0)
    unlk a6 
    rts

    ;end sub

    ;sub check_vertices(byval point as integer, byval xt as integer, byval yt as integer)
check_vertices:
    link a6,#-0
; byval _local_point as word
_local_point set 8
; byval _local_xt as word
_local_xt set 10
; byval _local_yt as word
_local_yt set 12

    ; if     point = 2 then ' 2 Morte
    move.w (_local_point,a6),d0
    cmp.w #2,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_if_true_39
    bra lbl_if_false_39
lbl_if_true_39:

    ; set_initial_position(level_index)
    move.w _global_level_index,-(a7)
    bsr set_initial_position
    addq #2,a7

    ; camera = 0
    move.w #0,_global_camera

    ; X_scroll = 0
    move.w #0,_global_X_scroll

    ; dirx = 0
    move.w #0,_global_dirx

    ; gravidade = 0
    move.w #0,_global_gravidade

    ; dave.flip = 0
    move.w #0,(_global_dave+8)

    ; Set_HorizontalScroll_position(0,1)
    move.w #1,-(a7)
    move.w #0,-(a7)
    bsr Set_HorizontalScroll_position
    addq #4,a7

    ; draw_screen()
    bsr draw_screen
    bra lbl_if_end_39
lbl_if_false_39:

    ; elseif point = 3 then ' 3 Trofeu
    move.w (_local_point,a6),d0
    cmp.w #3,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_40
    bra lbl_elseif_false_40
lbl_elseif_true_40:

    ; colision_vector[xt,yt]=0 ' Remove do Colision Map
    move.w (_local_yt,a6),d0
    mulu #100,d0
    add.w (_local_xt,a6),d0
    lea _global_colision_vector,a0
    move.b #0,0(a0,d0.w)

    ; bit_set(dave.flags,2)
    move.w (_global_dave+10),d0
    bset.l #2,d0
    move.w d0,(_global_dave+10)

    ; draw_tile(0, (xt<<1)   AND 63, (yt<<1)   AND 31,1) 
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(0,((xt<<1)+1)AND 63, (yt<<1)   AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(0, (xt<<1)   AND 63,((yt<<1)+1)AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(0,((xt<<1)+1)AND 63,((yt<<1)+1)AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ; tile_map_ram[(xt<<1)  ,(yt<<1)  ] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ; tile_map_ram[(xt<<1)+1,(yt<<1)  ] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ; tile_map_ram[(xt<<1)  ,(yt<<1)+1] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    addq #1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ; tile_map_ram[(xt<<1)+1,(yt<<1)+1] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    addq #1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ; draw_tile(153,0,20,0) 
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #0,-(a7)
    move.w #153,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(154,0,21,0)
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w #0,-(a7)
    move.w #154,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(155,1,20,0)
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #1,-(a7)
    move.w #155,-(a7)
    bsr draw_tile
    addq #8,a7

    ; draw_tile(156,1,21,0)
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w #1,-(a7)
    move.w #156,-(a7)
    bsr draw_tile
    addq #8,a7
    bra lbl_if_end_39
lbl_elseif_false_40:

    ; elseif point = 4 then ' 4 Porta
    move.w (_local_point,a6),d0
    cmp.w #4,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_41
    bra lbl_elseif_false_41
lbl_elseif_true_41:

    ; if bit_test(dave.flags,2) then
    move.w (_global_dave+10),d0
    btst #2,d0
    sne d0
    and.w #$01,d0
    dbra d0,lbl_if_true_42
    bra lbl_if_false_42
lbl_if_true_42:

    ;  level_index +=1
    moveq #1,d0
    add.w d0,_global_level_index

    ;  bit_set(dave.flags,5)
    move.w (_global_dave+10),d0
    bset.l #5,d0
    move.w d0,(_global_dave+10)
    bra lbl_if_end_42
lbl_if_false_42:
lbl_if_end_42:
    bra lbl_if_end_39
lbl_elseif_false_41:

    ; elseif point = 5 then ' 5 Jetpack
    move.w (_local_point,a6),d0
    cmp.w #5,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_43
    bra lbl_elseif_false_43
lbl_elseif_true_43:

    ;  colision_vector[xt,yt]=0 ' Remove do Colision Map
    move.w (_local_yt,a6),d0
    mulu #100,d0
    add.w (_local_xt,a6),d0
    lea _global_colision_vector,a0
    move.b #0,0(a0,d0.w)

    ;  bit_set(dave.flags,4)
    move.w (_global_dave+10),d0
    bset.l #4,d0
    move.w d0,(_global_dave+10)

    ;  draw_tile(0, (xt<<1)   AND 63, (yt<<1)   AND 31,1) 
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(0,((xt<<1)+1)AND 63, (yt<<1)   AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(0, (xt<<1)   AND 63,((yt<<1)+1)AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(0,((xt<<1)+1)AND 63,((yt<<1)+1)AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  tile_map_ram[(xt<<1)  ,(yt<<1)  ] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  tile_map_ram[(xt<<1)+1,(yt<<1)  ] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  tile_map_ram[(xt<<1)  ,(yt<<1)+1] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    addq #1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  tile_map_ram[(xt<<1)+1,(yt<<1)+1] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    addq #1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  draw_tile(41,8,20,0) 
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #8,-(a7)
    move.w #41,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(42,8,21,0)
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w #8,-(a7)
    move.w #42,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(43,9,20,0)
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #9,-(a7)
    move.w #43,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(44,9,21,0)
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w #9,-(a7)
    move.w #44,-(a7)
    bsr draw_tile
    addq #8,a7
    bra lbl_if_end_39
lbl_elseif_false_43:

    ; elseif point = 6 then ' 6 Arma  
    move.w (_local_point,a6),d0
    cmp.w #6,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_44
    bra lbl_elseif_false_44
lbl_elseif_true_44:

    ;  colision_vector[xt,yt]=0 ' Remove do Colision Map
    move.w (_local_yt,a6),d0
    mulu #100,d0
    add.w (_local_xt,a6),d0
    lea _global_colision_vector,a0
    move.b #0,0(a0,d0.w)

    ;  bit_set(dave.flags,3)
    move.w (_global_dave+10),d0
    bset.l #3,d0
    move.w d0,(_global_dave+10)

    ;  draw_tile(0, (xt<<1)   AND 63, (yt<<1)   AND 31,1) 
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(0,((xt<<1)+1)AND 63, (yt<<1)   AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(0, (xt<<1)   AND 63,((yt<<1)+1)AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(0,((xt<<1)+1)AND 63,((yt<<1)+1)AND 31,1) 
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  tile_map_ram[(xt<<1)  ,(yt<<1)  ] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  tile_map_ram[(xt<<1)+1,(yt<<1)  ] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  tile_map_ram[(xt<<1)  ,(yt<<1)+1] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    addq #1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  tile_map_ram[(xt<<1)+1,(yt<<1)+1] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    addq #1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  draw_tile(1 or 1<<13,4,20,0) 
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #4,-(a7)
    move.w #(1|(1<<13)),-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(2 or 1<<13,4,21,0)
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w #4,-(a7)
    move.w #(2|(1<<13)),-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(3 or 1<<13,5,20,0)
    move.w #0,-(a7)
    move.w #20,-(a7)
    move.w #5,-(a7)
    move.w #(3|(1<<13)),-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(4 or 1<<13,5,21,0) 
    move.w #0,-(a7)
    move.w #21,-(a7)
    move.w #5,-(a7)
    move.w #(4|(1<<13)),-(a7)
    bsr draw_tile
    addq #8,a7
    bra lbl_if_end_39
lbl_elseif_false_44:

    ; elseif point = 7 then ' 7 Escalavel (arvores)
    move.w (_local_point,a6),d0
    cmp.w #7,d0
    seq d0
    and.w #$01,d0
    dbra d0,lbl_elseif_true_45
    bra lbl_elseif_false_45
lbl_elseif_true_45:
    bra lbl_if_end_39
lbl_elseif_false_45:

    ; else                      ' Maior que 8 = Pontos

    ;  score += (point - 7)     ' Incrementa o Score
    move.w (_local_point,a6),d0
    subq #7,d0
    add.w d0,_global_score

    ;  colision_vector[xt,yt]=0 ' Remove do Colision Map
    move.w (_local_yt,a6),d0
    mulu #100,d0
    add.w (_local_xt,a6),d0
    lea _global_colision_vector,a0
    move.b #0,0(a0,d0.w)

    ;  draw_tile(0, (xt<<1)   AND 63, (yt<<1)   AND 31,1) 
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(0,((xt<<1)+1)AND 63, (yt<<1)   AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(0, (xt<<1)   AND 63,((yt<<1)+1)AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  draw_tile(0,((xt<<1)+1)AND 63,((yt<<1)+1)AND 31,1)
    move.w #1,-(a7)
    move.w (_local_yt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #31,d0
    move.w d0,-(a7)
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    and.w #63,d0
    move.w d0,-(a7)
    move.w #0,-(a7)
    bsr draw_tile
    addq #8,a7

    ;  tile_map_ram[(xt<<1)  ,(yt<<1)  ] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  tile_map_ram[(xt<<1)+1,(yt<<1)  ] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  tile_map_ram[(xt<<1)  ,(yt<<1)+1] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    addq #1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)

    ;  tile_map_ram[(xt<<1)+1,(yt<<1)+1] = 0
    move.w (_local_xt,a6),d0
    add.w d0,d0
    addq #1,d0
    move.w (_local_yt,a6),d1
    add.w d1,d1
    addq #1,d1
    mulu #200,d1
    add.w d0,d1
    add.w d1,d1
    move.w d1,d0
    lea _global_tile_map_ram,a0
    move.w #0,0(a0,d0.w)
lbl_if_end_39:
    unlk a6 
    rts

    ;end sub

    ;sub isr_06_vector()
isr_06_vector:
    movem.l d0-d6/a0-a5,-(a7)

    ; update_sprite_table() ' Atualiza os dados do Sprite na tela
    bsr update_sprite_table

    ; vbl = 0               ' Limpa o Flag de espera pelo Vblank
    move.w #0,_global_vbl

    ; v_count +=1           ' Incrementa a variavel de contagem de interrupcoes por Vblank
    moveq #1,d0
    add.w d0,_global_v_count

    ; if v_count >= 60 then ' Se ja ocorreram 60 interrupcoes ja se passou 1 segundo
    move.w _global_v_count,d0
    cmp.w #60,d0
    scc d0
    and.w #$01,d0
    dbra d0,lbl_if_true_46
    bra lbl_if_false_46
lbl_if_true_46:

    ; frame_rate = frame_c  ' Frame Rate e igual ao Numero de Frames renderizados (frame_c) em 1 segudo
    move.w _global_frame_c,_global_frame_rate

    ; v_count=0             ' Zera variavel de contagem de interupcoes
    move.w #0,_global_v_count

    ; frame_c = 0           ' Zera a variavel de contagem de frame Renderizados
    move.w #0,_global_frame_c
    bra lbl_if_end_46
lbl_if_false_46:
lbl_if_end_46:

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
lbl_for_10_start:
    move.w (_local_i,a6),d0
    cmp.w #80,d0
    beq lbl_for_10_end

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
    bra lbl_for_10_start

    ;  next 
lbl_for_10_end:

    ;  sprite_table[79].size_link = 0 ' Ultimo sprite desenhado deve apontar para o primeiro
    move.w #0,(_global_sprite_table+((79*8)+2))

    ;  for i=0 to 448
    moveq #0,d0
    move.w d0,(_local_i,a6)
lbl_for_11_start:
    move.w (_local_i,a6),d0
    cmp.w #448,d0
    beq lbl_for_11_end

    ;  H_scroll_buff[i] = 0
    move.w (_local_i,a6),d0
    add.w d0,d0
    lea _global_H_scroll_buff,a0
    move.w #0,0(a0,d0.w)
    moveq #1,d0
    add.w d0,(_local_i,a6)
    bra lbl_for_11_start

    ;  next 
lbl_for_11_end:

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
lbl_for_12_start:
    move.w (_local__list_,a6),d0
    cmp.w #80,d0
    beq lbl_for_12_end

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
    bra lbl_for_12_start

    ; next
lbl_for_12_end:

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

    ;imports"\assets\tile_sets\numbers.bin"
    even
numeros:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_sets\numbers.bin" 

    ;imports"\assets\tile_sets\tilepal1.bin"
    even
tiles:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_sets\tilepal1.bin" 

    ;imports"\assets\tile_sets\tilepal0.bin"	
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_sets\tilepal0.bin" 

    ;imports"\assets\sprite_sheets\dave.bin"
    even
dave_data:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\sprite_sheets\dave.bin" 

    ;imports"\assets\tile_maps\level1.bin"
    even
levels_:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level1.bin" 

    ;imports"\assets\tile_maps\level2.bin"
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level2.bin" 

    ;imports"\assets\tile_maps\level3.bin"
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level3.bin" 

    ;imports"\assets\tile_maps\level4.bin"
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level4.bin" 

    ;imports"\assets\tile_maps\level5.bin"
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level5.bin" 

    ;imports"\assets\tile_maps\level6.bin"
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level6.bin" 

    ;imports"\assets\tile_maps\level7.bin"
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level7.bin" 

    ;imports"\assets\tile_maps\level8.bin"
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level8.bin" 

    ;imports"\assets\tile_maps\level9.bin"
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level9.bin" 

    ;imports"\assets\tile_maps\level10.bin"
    even
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\tile_maps\level10.bin" 

    ;imports"\assets\colision_map\colision_maps.bin"
    even
colision_map:
    incbin "C:\workbench\Alcatech_NextBasicMC68000_IDE\Exemplos\Ex_Dangerous_Dave\assets\colision_map\colision_maps.bin" 
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
paletatile0:
    dc.w $0000,$00A0,$0E22,$0400,$002C,$0006,$0EA2,$02CE
    dc.w $0046,$0040,$0C0C,$0606,$0666,$0660,$0CEE,$00C0
    dc.w $0000,$0000,$068E,$046A,$0268,$0EEE,$0888,$0AAA
    dc.w $0CCC,$0666,$0444,$0222,$0246,$06AE,$04EE,$0024
    dc.w $0000,$022C,$0ACE,$0E0A,$06AE,$0246,$08AE,$0060
    dc.w $0666,$0EEE,$00C0,$0AAA,$08E8,$0A40,$0EA2,$0000
    dc.w $0000,$00A0,$0EEE,$04EE,$04E4,$0444,$0000,$0000
    dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
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