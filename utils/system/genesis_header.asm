    ORG $0100                      ; $C0 - $FF Reservado pela Motorola
    dc.b "SEGA GENESIS    "        ; Nome do Console 16 caracteres
    dc.b "                "        ; Data lançamento 16 caracteres
    dc.b "                                                "                 ; Nome do jogo 48 Caracteres
    dc.b "                                                "                 ; Nome Internacional 48 caracteres
    dc.b "              "          ; Versão 14 caracteres
    dc.w $0000                     ; Checksum (Word)
    DC.b "J               "	       ; Joystick
	DC.L $000000,Fim_ROM 	       ; ROM (endereço inicial - Final)
	DC.L $FF0000,$FFFFFF   	       ; RAM (endereço inicial - Final)
	DC.b "            "    	       ; RAM Externa? (endereço inicial - Final)
	DC.b "            "    	       ; Modem?
	DC.b "                                        "	                    ; Anotações (40 Caracteres)
	DC.b "JUE             "	       ; Região da ROM                 

;----------------------
; Inicialização MD    -
;----------------------
inicio_src:  ;Burlar sistema TradeMark da Sega
    move.w #$2700,sr                ;Desliga interrupções (#$2000 Liga interrupções)
    move.b $A10001,D0
    and.b  #$0F, D0
    beq.b   Pula_TMSS               ;Bios V0
    move.l  #'SEGA',$A14000
Pula_TMSS:    
    ;Trava o Z_80 e libera o acesso ao Barramento
    move.w	#$0100,$A11200    ;Z80_Reset
    move.w	#$0100,$A11100    ;Z80_BusReq
@Espera_liberacao_bus_Z80_ini:
    btst #8,$A11100 ;Z80_BusReq
    bne  @Espera_liberacao_bus_Z80_ini
	
;----------------
;  Limpa a RAM  -
;----------------
	lea $FF0000,A0
	move.l #2048-1,D0
_limpa_ram_loop_header:
	move.l #$0,(A0)+
	move.l #$0,(A0)+
	move.l #$0,(A0)+
	move.l #$0,(A0)+
	move.l #$0,(A0)+
	move.l #$0,(A0)+
	move.l #$0,(A0)+
	move.l #$0,(A0)+
	dbra D0,_limpa_ram_loop_header

;----------------------
;  Limpa a RAM do Z80 -
;----------------------
	lea $A00000,A0
	move.l #8192-1,D0
_limpa_ram_z80_loop_header:
	move.b #$0,(A0)+
	dbra D0,_limpa_ram_z80_loop_header

;------------------------------------------------------------------
;salva o endereço final da global table na variavel correspondente-
;------------------------------------------------------------------

    move.l #end_global_table,_global_ram_pointer 

 ;-----------------------------------
 ;-        Código principal         -
 ;----------------------------------- 
 