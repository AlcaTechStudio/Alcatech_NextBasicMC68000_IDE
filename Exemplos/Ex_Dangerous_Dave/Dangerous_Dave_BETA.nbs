imports"\system\genesis_header.asm" ' Header de uma ROM de mega Drive Padrão (deve ficar sempre no topo)

Equal map_width "200" ' Largura do Mapa em Tiles
Equal Map_Height "20" ' Altura do Mapa em Tiles
Equal animation_c "4" ' Intervalo de frames entre as animações

Equal max_h_jump "33" ' Altura maxima do pulo

Equal falling  "0" ' Flag - caindo
Equal jump_p   "1" ' Flag - Saltando
Equal trofeu_f "2" ' Flag - Possui Trofeu
Equal gun_f    "3" ' Flag - Possui Arma
Equal jet_F    "4" ' Flag - Possui JetPack
Equal next_lv  "5" ' Flag - Carregar Proximo level

Equal X_vel    "3" ' Velocidade no Eixo X 1.5 Pixels Por Frame
Equal Y_vel    "2" ' Velocidade no Eixo Y (gravidade) - 1 Pixel Por Frame

structure char_
 dim x      as integer 'Posição X
 dim y      as integer 'Posição Y
 dim sprite as integer 'Numero do Sprite Na Sprite Tablet
 dim hjump  as integer 'Variavel que mede altura do pulo
 dim flip   as integer 'Esprite indo para a Esquerda ou não
 dim flags  as integer 'Flags do Jogo
end structure

' Inicializa o VDP com a configuração Padrao
std_init()
' Carrega o tile set e as peletas de cores
load_tiles_DMA_128ksafe(addressof(tiles),204,1)
load_tiles_DMA_128ksafe(addressof(dave_data),36,205)
load_tiles_DMA_128ksafe(addressof(numeros),10,241)
load_cram_DMA_128ksafe(addressof(paletatile0),64,0)

dim camera as integer = 0 'Posição da Camera em Tiles
dim frame  as integer = 0 'Contagem dos frames para temporização das animações
dim anima_tiles1 as integer = 0 'Contagem dos quadros de animação de 4 frames
dim anima_tiles2 as integer = 0 'Contagem dos quadros de animação de 5 frames
dim anima_dave   as integer = 0 'Contagem dos quadros de animação do Sprite
dim gravidade    as integer = 0 'Aceleração no eixo Y (Gravidade)
dim dirx     as integer = 0 'Aceleração no Eixo X
dim score    as integer = 0 'Score
dim x_scroll as integer = 0 'Posição da scroll Plane

dim dave as new char_ ' Matriz indexada 

dim tile_map_ram [200,20] as integer ' Tile Map na RAM (evitar uso para mapas muito grandes)
dim colision_vector[100,10] as byte  ' Mapa de colisores

dim level_index as integer = 0 ' Zero = Level 1

' Variaveis usadas para mensurar o frame Rate
dim frame_c as integer = 0 
dim v_count as integer = 0
dim frame_rate as integer = 0

'Inicialização de valores
dave.sprite = 0 ' Atribui o indice Zero na Sprite table para o sprite do personagem
dave.hjump  = 0 ' Zera altura do Pulo
dave.flags  = 0 ' Zera os Flags

set_sprite_size(dave.sprite,1,1)  ' Sprite 16x16 Pixels
set_sprite_gfx(dave.sprite,205,2) ' Desenhado com a Paleta 02

load_level(tile_map_ram,colision_vector,level_index) 'Carrega o primeiro nivel
enable_global_int() ' Interrupção por Vblank

Do 'main
 input_thread()    ' Joystick e Direções
 check_colision()  ' Colisão e posições
 draw_score()      ' Printa na tela o Score 
 draw_frame_rate() ' Printa na tela o Frame Rate
 
 'analisa se o Sprite atingiu as bordas da tela
 if dave.x > 816 then scroll_right()               ' Movimenta a camera para a Direita
 if dave.x < 312 and camera>16 then  scroll_left() ' Movimenta a camera para a Esquerda
 
 frame   +=1       ' Conta os Frames Renderizados Para temporização das animações
 frame_c +=1       ' Conta os Frames Renderizados para calculo do Frame Rate
 
 if frame > animation_c then anima_cenario() ' Completou o intervalo de tempo entre as animações?
 
 if bit_test(dave.flags,next_lv) then ' Jogador passou de nivel?
  if level_index>9 then level_index = 0
  load_level(tile_map_ram,colision_vector,level_index) 
 end if
 'Atuliza os dados de posição do Sprites na tela
 set_sprite_position(dave.sprite,dave.x>>1,dave.y>>1)
 'Espera o proximo frame
 vbl = 1             ' Sobe um Flag que é limpo na Interrupção por V_blank
 while(vbl) : wend   ' Trava o FPS em no Maximo 60 Frames por segundo
Loop ' Laço infinito

sub scroll_right() ' Animação de transição do cenario para a Direita
 for i=0 to 15     'Scroll de 15 blocos
 for y = 0 to 20 ' Desenha uma linha vertical de 16 Pixels de largura na margem direita da tela
 draw_tile(tile_map_ram[camera + 40 ,y], (camera + 40) and 63 ,y, plane_B)
 draw_tile(tile_map_ram[camera + 41 ,y], (camera + 41) and 63 ,y, plane_B)
 next
 'Atualiza as variaveis com a nova posição na tela
 x_scroll += 16
 dave.x  -= 32
 camera  += 2
 frame_c +=1 'A contagem de frames tambem tem que acontecer durante a animação dos cenarios
 'Envia as mudanças para o VDP
 set_sprite_position(dave.sprite,dave.x>>1,dave.y>>1)
 'update_sprite_table()
 Set_HorizontalScroll_position(x_scroll AND 511,Plane_B)
 'Espera o proximo frame para prosseguir com a Animação
 vbl=1
 while(vbl) : wend
 next 
end sub

sub scroll_left() ' Animação de transição do cenario para a Esquerda
 for i=0 to 15    'Scroll de 15 blocos
 for y = 0 to 20 ' Desenha uma linha vertical de 16 Pixels de largura na margem esquerda da tela
 draw_tile(tile_map_ram[camera-1 ,y], (camera-1) and 63 ,y, plane_B)
 draw_tile(tile_map_ram[camera-2 ,y], (camera-2) and 63 ,y, plane_B)
 next 
 ' Atualiza as variaveis com a nova posição na tela
 x_scroll -= 16
 dave.x  += 32
 camera  -= 2
 frame_c +=1  'A contagem de frames tambem tem que acontecer durante a animação dos cenarios
 ' Envia as mudanças para o VDP
 set_sprite_position(dave.sprite,dave.x>>1,dave.y>>1)
 'update_sprite_table()
 Set_HorizontalScroll_position(x_scroll AND 511,Plane_B)
 ' Espera o proximo frame para prosseguir com a Animação
 vbl=1
 while(vbl) : wend
 next 
end sub

' Printa na tela o Frame Rate
sub draw_frame_rate()
 centena = frame_rate  /  100
 dezenap = frame_rate mod 100
 dezena = dezenap / 10
 unidade = dezenap mod 10
 draw_tile( ( centena+241 ) or palette_3 , 37 , 21 , Plane_A)
 draw_tile( (  dezena+241 ) or palette_3 , 38 , 21 , Plane_A)
 draw_tile( ( unidade+241 ) or palette_3 , 39 , 21 , Plane_A)
end sub

' Printa na Tela o Score
sub Draw_score()
 centena = score  /  100
 dezenap = score mod 100
 dezena = dezenap / 10
 unidade = dezenap mod 10
 draw_tile( ( centena+241 ) or palette_3 , 35 , 20 , Plane_A)
 draw_tile( (  dezena+241 ) or palette_3 , 36 , 20 , Plane_A)
 draw_tile( ( unidade+241 ) or palette_3 , 37 , 20 , Plane_A)
 draw_tile(             241 or palette_3 , 38 , 20 , Plane_A)
 draw_tile(             241 or palette_3 , 39 , 20 , Plane_A)
end sub

' Sub Rotina responsavel Por animar os cenarios e os Sprites do personagem
sub anima_cenario()  
 load_tiles_DMA_128ksafe((addressof(tiles) + 132*32)+(anima_tiles2<<7),4,133) ' Agua
 load_tiles_DMA_128ksafe((addressof(tiles) + 152*32)+(anima_tiles2<<7),4,153) ' Trofeu
 load_tiles_DMA_128ksafe((addressof(tiles) + 172*32)+(anima_tiles1<<7),4,173) ' Fogo
 load_tiles_DMA_128ksafe((addressof(tiles) + 188*32)+(anima_tiles1<<7),4,189) ' Plantas
 
 anima_tiles2 +=1
 anima_tiles1 +=1
 anima_dave   +=1
 
 if anima_tiles2 > 4 then anima_tiles2 = 0
 if anima_tiles1 > 3 then anima_tiles1 = 0
 if anima_dave   > 2 then anima_dave   = 0
 
 dim gfx as integer
 
 if bit_test(dave.flags,jump_p) OR bit_test(dave.flags,falling) then
 gfx = 221                   ' Sprite Caindo
 elseif dirx then
 gfx = 205 + (anima_dave<<2) ' Sprite Andando
 else
 gfx = 209                   ' Sprite Parado
 end if 
 
 set_sprite_gfx(dave.sprite,gfx or dave.flip,2)
 
 frame = 0 ' Zera a variavel de contagem para a temporização das animações
 
end sub

' Carrega o Tile Map e o Colision MAP (cujo os enderesços das matrizes são recebidos por referencia), reseta a camera e o estado inicial do jogador
' Essa rotina é lenta e leva 12 Frames para ser concluinda(0,2 segundos), porem só sera chamada na transição entre os level's
sub load_level(byref _ram_map_ as integer , byref _ram_col_map_ as byte, byval level as integer)
 ' Reseta as Variaveis Globais
 X_scroll   = 0 ' Limpa a variavel que armazena a posição vertical da Scroll Plane
 camera     = 0 ' Coloca a camera no inicio do level
 dave.flags = 0 ' Limpa todos os Flags
 dave.flip  = 0 ' Personagem virado para a Direita
 
 'Carrega o Tile Map  ~ O tile Map tem 8000 Bytes de tamanho, isso multiplicado pelo numero de level's (10) da um address range de  80000 (80 mil) Bytes
 'como o MC68000 NÃO multiplica valores long temos que quebrar as multiplicações long em multiplicações word menores e complementar com a operação shift
 push((addressof(levels_) +((level * 1000)<<3)) as long, "A5") 'Salva o endereço do tile map no Registrador A5
 for k=0 to (200*20) 'Tamanho do mapa em Tiles
 _ram_map_[k] = pop("(A5)+" as word) +1 ' Lê o registrador (A5) como endereçamento indireto com pos-incremento e soma 1 ao valor (1 é o offset na Vram)
 if _ram_map_[k] <= 37 then _ram_map_[k] |= palette_1 'Se o tile for menor que 37 ele deve ser desenhado com a paleta 01 da Cram
 next k
 
 'Carrega o colision map ~ O colision Map tem o tamanho de um level completo (10 x 100 blocos)
 push(addressof(colision_map) + (level * 1000) as long, "A5")
 for k=0 to (100*10) 'Tamanho doColision Map
 _ram_col_map_[k] = pop("(A5)+" as byte) '
 next k

 Set_HorizontalScroll_position(0,Plane_B)
 draw_screen()                ' Desenha o level(Plane B)
 set_initial_position(level)  ' Define Posição inicial do sprite
 ' Limpa o Hud (linhas 20 e 21 até a terceira coluna mo Plane A)
 for k = 0 to 40
 draw_tile(0,k,20,Plane_A)
 draw_tile(0,k,21,Plane_A)
 Next 
 
end sub

' Define a posição inicial do Sprite para cada level diferente
sub set_initial_position(byval lv as word)
 select lv
 case 0 'Level 1
 dave.x = (128 + (2<<4))*2
 dave.y = (128 + (8<<4))*2
 case 1 'Level 2 
 dave.x = (128 + (1<<4))*2
 dave.y = (128 + (8<<4))*2
 case 2 'Level 3
 dave.x = (128 + (2<<4))*2
 dave.y = (128 + (5<<4))*2
 case 3 'Level 4
 dave.x = (128 + (1<<4))*2
 dave.y = (128 + (5<<4))*2
 case 4 'Level 5
 dave.x = (128 + (2<<4))*2
 dave.y = (128 + (8<<4))*2
 case 5 'Level 6
 dave.x = (128 + (1<<4))*2
 dave.y = (128 + (8<<4))*2
 case 6 'Level 7
 dave.x = (128 + (1<<4))*2
 dave.y = (128 + (2<<4))*2
 case 7 'Level 8
 dave.x = (128 + (2<<4))*2
 dave.y = (128 + (8<<4))*2
 case 8 'Level 9
 dave.x = (128 + (6<<4))*2
 dave.y = (128 + (1<<4))*2
 case 9 'Level 10
 dave.x = (128 + (2<<4))*2
 dave.y = (128 + (8<<4))*2
 end select
end sub

' Sub Rotina que desenha a tela baseado num tilemap + um valor de referencia para camera
sub draw_screen() 
 for y = 0 to 20
 for x = 0 to 40
 draw_tile(tile_map_ram[ x + camera , y ] ,x,y,Plane_B)
 next 
 next  
end sub


' Sub Rotina que trata a aquisição do input do joystick
'dim j_old as integer 'Variavel global que armazena o valor lido do joystick anteriormente
sub input_thread()
 
 j = joypad6b_read(0)
 
 'if j <> j_old and j.btn_start then : bit_set(dave.flags,next_lv) : level_index += 1 : end if  ' Botão Start avança os levels
 
 dirx = 0
 
 if bit_test(j,btn_left) then  ' Direita e Esquerda
 dirx = - X_vel
 dave.flip = H_Flip ' Precisamos aplicar um Flip Horizontal caso o Personagem esteja indo pra esquerda
 elseif bit_test(j,btn_right) then
 dirx = X_vel
 dave.flip = 0
 end if
 
 if bit_test(j,btn_up) AND not(bit_test(dave.flags,falling)) AND not(bit_test(dave.flags,jump_p)) then 'Botão UP + Flags que impedem double Jump 
 bit_set(dave.flags,jump_p) ' Seta o Flag que indica se esta pulando
 end if 
 
 if bit_test(dave.flags,jump_p) AND dave.hjump < max_h_jump then ' Esta pulando e não atingiu a altura maxima ainda
 dave.hjump+=1 
 gravidade =-Y_vel
 else  
 bit_clear(dave.flags,jump_p)
 dave.hjump=0
 gravidade=Y_vel
 end if
' j_old = j
end sub

'Sub rotina que verifica se o jogador esta betendo em algo no cenario
'São utilizados 4 pontos de colisão porem são analizados apenas os pontos equivalentes nas direções em que o char esta se movendo
sub check_colision()
 'Colisao no eixo X
 hy1 =  ((Dave.y>>1) - 128-2 )>>4
 hy2 =  ((Dave.y>>1) - 128-15)>>4 
 if dirx = X_vel then ' Indo para a direita
 hx  = (((Dave.x>>1) - 128-14)>>4) + (camera>>1)
 col_point0 = colision_vector[ hx , hy1 ]
 col_point1 = colision_vector[ hx , hy2 ]
 else'if dirx = -1 then 'Indo para a esquerda
 hx  = (((Dave.x>>1) - 128-2 )>>4) + (camera>>1)
 col_point0 = colision_vector[ hx , hy1 ]
 col_point1 = colision_vector[ hx , hy2 ] 
 end if 
 
 'Colisao no eixo y
 vx1 = (((Dave.x>>1) - 128-4 )>>4) + (camera>>1)
 vx2 = (((Dave.x>>1) - 128-12)>>4) + (camera>>1)
 if gravidade = Y_vel then 'indo para baixo
 vy = ((Dave.y>>1) - 128-16)>>4
 col_point3 = colision_vector[ vx1 , vy ]
 col_point4 = colision_vector[ vx2 , vy ]
 else'if gravidade = -1 then 'Indo para cima
 vy = ((Dave.y>>1) - 128-1 )>>4
 col_point3 = colision_vector[ vx1 , vy ]
 col_point4 = colision_vector[ vx2 , vy ]
 end if
 
 ''''''''''''''''  Colisão Horizontal '''''''''''''''''''''
 if hy1 = hy2 then ' Os dois pontos estão no mesmo tile -> Analisa um ponto só
  if col_point0 = 1 then             ' É um solido 
  dirx = 0                           ' Então, apenas bloqueia o caminho
  elseif col_point0 <> 0 then        ' Se não é um solido e é algo diferente de um espaço vazio
  check_vertices(col_point0,hx,hy1)  '  Chama a rotina para verificar que objeto é
  end if
 else ' Os Dois pontos estão em Tiles diferentesm -> então analisa os Dois
  ' Checa o primeiro ponto
  if col_point0 = 1 then             ' É um solido 
  dirx = 0                           ' Apenas bloqueia o caminho
  elseif col_point0 <> 0 then        ' É algo diferente de um espaço vazio
  check_vertices(col_point0,hx,hy1)  ' Chama a rotina para verificar que objeto é
  end if
  ' Checa o segundo ponto
  if col_point1 = 1 then             ' É um solido
  dirx=0                             ' Apenas bloqueia o caminho
  elseif col_point1 <> 0 then        ' É algo diferente de um espaço vazio
  check_vertices(col_point1,hx,hy2)  ' Chama a rotina para verificar que objeto é
  end if
 end if
 
 ''''''''''''''''  Colisão Vertical '''''''''''''''''''''
 if vx1 = vx2 then ' Os dois pontos estão no mesmo tile
 
 if col_point3 = 1 then             ' É um solido 
  if gravidade = -Y_vel AND bit_test(dave.flags,jump_p) then ' Acertou algo que limita o pulo
  bit_clear(dave.flags,jump_p)                           ' Fim do pulo (bateu a cebeça)
  elseif gravidade = Y_vel then                          ' Bateu em algo e a gravidade não esta invertida
  bit_clear(dave.flags,falling)                          ' Não esta caindo 
  end if
  gravidade = 0                       ' Apenas bloqueia o caminho
 elseif col_point3 <> 0 then        ' É algo diferente de um espaço vazio
  check_vertices(col_point3,vx1,vy)  ' Chama a rotina para verificar que objeto é
 end if
 
 else ' Os dois ponto estão em Tiles Diferentes
 ' Analisa o primeiro Ponto
  if col_point3 = 1 then             ' É um solido 
   if gravidade = -Y_vel AND bit_test(dave.flags,jump_p) then ' Acertou algo que limita o pulo
   bit_clear(dave.flags,jump_p)                           ' Fim do pulo (bateu a cebeça)
   elseif gravidade = Y_vel then                          ' Bateu em algo e a gravidade não esta invertida
   bit_clear(dave.flags,falling)                          ' Não esta caindo 
   end if
   gravidade = 0                     ' Apenas bloqueia o caminho
 elseif col_point3 <> 0 then        ' É algo diferente de um espaço vazio
  check_vertices(col_point3,vx1,vy)  ' Chama a rotina para verificar que objeto é
 end if
 'Analisa o segundo ponto
 if col_point4 = 1 then             ' É um solido
  if gravidade = -Y_vel AND bit_test(dave.flags,jump_p) then ' Acertou algo que limita o pula
  bit_clear(dave.flags,jump_p)                           ' Fim do pulo (bateu a cebeça)
  elseif gravidade = Y_vel then                              ' Bateu em algo ea gravidade não esta invertida
  bit_clear(dave.flags,falling)                          ' Não esta caindo 
  end if
  gravidade = 0                      ' Apenas bloqueia o caminho
 elseif col_point4 <> 0 then        ' É algo diferente de um espaço vazio
  check_vertices(col_point4,vx2,vy)  ' Chama a rotina para verificar que objeto é
  end if
 end if
 if gravidade = Y_vel then bit_set(dave.flags,falling) 'Seta o Flag de queda
 
 dave.y += gravidade
 dave.x += dirx
end sub

' Verifica em que objeto do cenario o sprite colidiu
' Os parmetros XT e YT são as coordenadas no colision map + Offset da posição camera
sub check_vertices(byval point as integer, byval xt as integer, byval yt as integer)
 ' 0 Espaço vazio
 ' 1 solido
 if     point = 2 then ' 2 Morte
 set_initial_position(level_index)
 camera = 0
 X_scroll = 0
 dirx = 0
 gravidade = 0
 dave.flip = 0
 Set_HorizontalScroll_position(0,Plane_B)
 draw_screen()
 
 elseif point = 3 then ' 3 Trofeu
 colision_vector[xt,yt]=0 ' Remove do Colision Map
 bit_set(dave.flags,trofeu_f)
 ' Apaga da tela
 draw_tile(0, (xt<<1)   AND 63, (yt<<1)   AND 31,Plane_B) 
 draw_tile(0,((xt<<1)+1)AND 63, (yt<<1)   AND 31,Plane_B)
 draw_tile(0, (xt<<1)   AND 63,((yt<<1)+1)AND 31,Plane_B)
 draw_tile(0,((xt<<1)+1)AND 63,((yt<<1)+1)AND 31,Plane_B)
 ' Apaga do tile map (para não ser desenhado quando a tela for atualizada)
 tile_map_ram[(xt<<1)  ,(yt<<1)  ] = 0
 tile_map_ram[(xt<<1)+1,(yt<<1)  ] = 0
 tile_map_ram[(xt<<1)  ,(yt<<1)+1] = 0
 tile_map_ram[(xt<<1)+1,(yt<<1)+1] = 0
 ' Exibe na Barra
 draw_tile(153,0,20,Plane_A) 
 draw_tile(154,0,21,Plane_A)
 draw_tile(155,1,20,Plane_A)
 draw_tile(156,1,21,Plane_A)
 elseif point = 4 then ' 4 Porta
 if bit_test(dave.flags,trofeu_f) then
  ' Proximo Nivel!
  level_index +=1
  bit_set(dave.flags,next_lv)
  end if
 elseif point = 5 then ' 5 Jetpack
  colision_vector[xt,yt]=0 ' Remove do Colision Map
  bit_set(dave.flags,jet_f)
  ' Apaga da tela
  draw_tile(0, (xt<<1)   AND 63, (yt<<1)   AND 31,Plane_B) 
  draw_tile(0,((xt<<1)+1)AND 63, (yt<<1)   AND 31,Plane_B)
  draw_tile(0, (xt<<1)   AND 63,((yt<<1)+1)AND 31,Plane_B)
  draw_tile(0,((xt<<1)+1)AND 63,((yt<<1)+1)AND 31,Plane_B)
  ' Apaga do tile map (para não ser desenhado quando a tela for atualizada)
  tile_map_ram[(xt<<1)  ,(yt<<1)  ] = 0
  tile_map_ram[(xt<<1)+1,(yt<<1)  ] = 0
  tile_map_ram[(xt<<1)  ,(yt<<1)+1] = 0
  tile_map_ram[(xt<<1)+1,(yt<<1)+1] = 0
  ' Exibe na Barra
  draw_tile(41,8,20,Plane_A) 
  draw_tile(42,8,21,Plane_A)
  draw_tile(43,9,20,Plane_A)
  draw_tile(44,9,21,Plane_A)
 
 elseif point = 6 then ' 6 Arma  
  colision_vector[xt,yt]=0 ' Remove do Colision Map
  bit_set(dave.flags,gun_f)
  ' Apaga da tela
  draw_tile(0, (xt<<1)   AND 63, (yt<<1)   AND 31,Plane_B) 
  draw_tile(0,((xt<<1)+1)AND 63, (yt<<1)   AND 31,Plane_B)
  draw_tile(0, (xt<<1)   AND 63,((yt<<1)+1)AND 31,Plane_B)
  draw_tile(0,((xt<<1)+1)AND 63,((yt<<1)+1)AND 31,Plane_B) 
  ' Apaga do tile map (para não ser desenhado quando a tela for atualizada)
  tile_map_ram[(xt<<1)  ,(yt<<1)  ] = 0
  tile_map_ram[(xt<<1)+1,(yt<<1)  ] = 0
  tile_map_ram[(xt<<1)  ,(yt<<1)+1] = 0
  tile_map_ram[(xt<<1)+1,(yt<<1)+1] = 0
 ' Exibe na Barra
  draw_tile(1 or palette_1,4,20,Plane_A) 
  draw_tile(2 or palette_1,4,21,Plane_A)
  draw_tile(3 or palette_1,5,20,Plane_A)
  draw_tile(4 or palette_1,5,21,Plane_A) 

 elseif point = 7 then ' 7 Escalavel (arvores)
 ' Soma botão com direção 
 
 else                      ' Maior que 8 = Pontos
  score += (point - 7)     ' Incrementa o Score
  colision_vector[xt,yt]=0 ' Remove do Colision Map
  ' Apaga da tela
  draw_tile(0, (xt<<1)   AND 63, (yt<<1)   AND 31,Plane_B) 
  draw_tile(0,((xt<<1)+1)AND 63, (yt<<1)   AND 31,Plane_B)
  draw_tile(0, (xt<<1)   AND 63,((yt<<1)+1)AND 31,Plane_B)
  draw_tile(0,((xt<<1)+1)AND 63,((yt<<1)+1)AND 31,Plane_B)
  ' Apaga do tile map (para não ser desenhado quando a tela for atualizada)
  tile_map_ram[(xt<<1)  ,(yt<<1)  ] = 0
  tile_map_ram[(xt<<1)+1,(yt<<1)  ] = 0
  tile_map_ram[(xt<<1)  ,(yt<<1)+1] = 0
  tile_map_ram[(xt<<1)+1,(yt<<1)+1] = 0
 end if
end sub

' Interrupção por Vblank (acontece 60 vezes por segundo)
sub isr_Vblank()
 update_sprite_table() ' Atualiza os dados do Sprite na tela
 vbl = 0               ' Limpa o Flag de espera pelo Vblank
 v_count +=1           ' Incrementa a variavel de contagem de interrupções por Vblank
 if v_count >= 60 then ' Se ja ocorreram 60 interrupções ja se passou 1 segundo
 frame_rate = frame_c  ' Frame Rate é igual ao Numero de Frames renderizados (frame_c) em 1 segudo
 v_count=0             ' Zera variavel de contagem de interupções
 frame_c = 0           ' Zera a variavel de contagem de frame Renderizados
 end if
end sub

imports"\system\genesis_std.nbs" ' Biblioteca contendo funções standard do Mega Drive

paletatile0:
	DATAINT	&H0000,&H00A0,&H0E22,&H0400,&H002C,&H0006,&H0EA2,&H02CE
	DATAINT	&H0046,&H0040,&H0C0C,&H0606,&H0666,&H0660,&H0CEE,&H00C0
'paletatile1:
	DATAINT	&H0000,&H0000,&H068E,&H046A,&H0268,&H0EEE,&H0888,&H0AAA
	DATAINT	&H0CCC,&H0666,&H0444,&H0222,&H0246,&H06AE,&H04EE,&H0024
'paletaDave:
	DATAINT	&H0000,&H022C,&H0ACE,&H0E0A,&H06AE,&H0246,&H08AE,&H0060
	DATAINT	&H0666,&H0EEE,&H00C0,&H0AAA,&H08E8,&H0A40,&H0EA2,&H0000
'paletanumeros:
	DATAINT	&h0000,&h00A0,&h0EEE,&h04EE,&h04E4,&h0444,&h0000,&h0000
	DATAINT	&h0000,&h0000,&h0000,&h0000,&h0000,&h0000,&h0000,&h0000
numeros:
imports"\assets\tile_sets\numbers.bin"
tiles:
imports"\assets\tile_sets\tilepal1.bin"
imports"\assets\tile_sets\tilepal0.bin"	
'sprite Sheets
dave_data:
imports"\assets\sprite_sheets\dave.bin"
'tile_maps
levels_:
imports"\assets\tile_maps\level1.bin"
imports"\assets\tile_maps\level2.bin"
imports"\assets\tile_maps\level3.bin"
imports"\assets\tile_maps\level4.bin"
imports"\assets\tile_maps\level5.bin"
imports"\assets\tile_maps\level6.bin"
imports"\assets\tile_maps\level7.bin"
imports"\assets\tile_maps\level8.bin"
imports"\assets\tile_maps\level9.bin"
imports"\assets\tile_maps\level10.bin"
' Mapa de colisão
colision_map:
imports"\assets\colision_map\colision_maps.bin"