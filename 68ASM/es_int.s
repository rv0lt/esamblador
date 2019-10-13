*
*V2.1

* Inicializa el SP y el PC
        ORG     $0
        DC.L    $8000           *Pila
        DC.L    INIT            *PC
        *DC.L    INICIO

        ORG     $400

	*Buffers
		
        TAM_BUF:  EQU     2001     *1 más para poder tener una poscion auxiliar

        ra:      DS.B    TAM_BUF     *0x400 (posición de memoria en hexadecimal) recepcion de a 
        rb:      DS.B    TAM_BUF     *0xbd1 recepcion de b
        ta:      DS.B    TAM_BUF     *0x13a2 transimision de a 
        tb:      DS.B    TAM_BUF     *0x1b73 transimision de b

        copia_IMR: DS.B    2
        flagTBA:  DS.B    1
        flagTBB:  DS.B    1

        flagPRT: DS.B     1 

***********del test de datsi*************************
        BUFFER: DS.B    2100  * Buffer para lectura y escritura de caracteres 0X2349
        CONTL:  DC.W    0     * Contador de lıneas
        CONTC:  DC.W    0     * Contador de caracteres
        DIRLEC: DC.L    0     * Direccion de lectura para SCAN
        DIRESC: DC.L    0     *direcci�n escritura PRINT
        TAME:   DC.W    0     *Tamaño escritura PRINT
        DESA:   EQU     0     * Descriptor linea A
        DESB:   EQU     1     * Descriptor lınea B
        NLIN:   EQU     2    * Numero de lıneas a leer
        TAML:   EQU     1000    * Tamano de lınea para SCAN
        TAMB:   EQU     1000     *tamaño bloque PRINT
*******************************************************

*Punteros

        ra_escritura:          DS.B  4
        ra_lectura:            DS.B  4
        ra_fin:                DS.B  4       


        rb_escritura:          DS.B  4
        rb_lectura:            DS.B  4
        rb_fin:                DS.B  4       



        ta_escritura:          DS.B  4
        ta_lectura:            DS.B  4
        ta_fin:                DS.B  4       



        tb_escritura:          DS.B  4
        tb_lectura:            DS.B  4
        tb_fin:                DS.B  4       
		
		
		
        


* Definicion de equivalencias

MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2 escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CRA     EQU     $effc05       * de control A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
ACR     EQU     $effc09       * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion A (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion A (lectura)

MR1B    EQU     $effc11       * de modo B (escritura)
MR2B    EQU     $effc11       * de modo B (2 escritura)
SRB     EQU     $effc13       * de estado B (lectura)
CSRB    EQU     $effc13       * de seleccion de reloj B (escritura)
CRB     EQU     $effc15       * de control B (escritura)
RBB     EQU     $effc17       * buffer recepcion B  (lectura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
IVR     EQU     $effc19       * de vector de interrupcion

*************************************INIT*********************************

INIT:

  MOVE.B #%00010000,CRA      * Reinicia el puntero MR1A
  MOVE.B #%00010000,CRB      * Reinicia el puntero MR1B

  MOVE.B #%00000011,MR1A     * 8 bits por caracter de modo A.
  MOVE.B #%00000011,MR1B     * 8 bits por caracter de modo B.

  MOVE.B #%00000000,MR2A     * Eco desactivado de modo A.
  MOVE.B #%00000000,MR2B     * Eco desactivado de modo B.

  MOVE.B #%11001100,CSRA     * Velocidad = 38400 bps.
  MOVE.B #%11001100,CSRB     * Velocidad = 38400 bps

  MOVE.B #%00000000,ACR      * Velocidad = 38400 bps

  MOVE.B #%00000101,CRA      * Transmision y recepcion activados A.
  MOVE.B #%00000101,CRB      * Transmision y recepcion activados B.

  MOVE.B #$040,IVR                       * Vector de Interrrupcion nº 40
  MOVE.B #%00100010,COPIA_IMR      *copia_IMR


  MOVE.B COPIA_IMR,IMR *copia_IMR A IMR (Habilita las interrupciones de A y B)
  MOVE.B  #0,flagTBA                    *Inicializo a 0 el flag TBA 
  MOVE.B  #0,flagTBB                    *Inicializo a 0 el flag TBB

  MOVE.L  #RTI,$100	                    *0x40*0x04=0x100
  
  
  MOVE.B  #0,flagPRT                    *Inicializo a 0 el flag auxiliar que se usa en PRINT

 *INICIALIZACION DE PUNTEROS

        MOVEM.L A0/D0-D1,-(A7)            *Se guardan los registros para evitar su modificacion


        MOVE.L #TAM_BUF,D0 
        SUB.L #1,D0
        *D0 contiene el valor 2000, al sumarselo a la posición de memoria donde apunta el inicio de cada buffer
        *obtendremos un puntero FIN que apunta al último elemento que se puede usar
        
        MOVE.L  #ra,ra_escritura 
        MOVE.L  #ra,ra_lectura
        *los punteros de escritura y lectura están inicializados en la misma posición(vacio)
        MOVE.L  #ra,A0  
        MOVE.L  A0,D1   º                  *en D1 esta 0x400
        ADD.L   D0,D1                      *Al sumar la posicion de memoria del buffer a D0 se obtiene el puntero al final               
        MOVE.L  D1,ra_fin

        MOVE.L  #rb,rb_escritura
        MOVE.L  #rb,rb_lectura
        *los punteros de escritura y lectura están inicializados en la misma posición(vacio)
        MOVE.L  #rb,A0
        MOVE.L  A0,D1                       *en D1 está 0xbd1
        ADD.L   D0,D1                       *Al sumar la posicion de memoria del buffer a D0 se obtiene el puntero al final                         
        MOVE.L  D1,rb_fin

        MOVE.L  #ta,ta_escritura
        MOVE.L  #ta,ta_lectura
        *los punteros de escritura y lectura están inicializados en la misma posición(vacio)
        MOVE.L  #ta,A0
        MOVE.L  A0,D1                       *En d1 esta 0x13a2
        ADD.L   D0,D1                       *Al sumar la posicion de memoria del buffer a D0 se obtiene el puntero al final                   
        MOVE.L  D1,ta_fin

        MOVE.L  #tb,tb_escritura
        MOVE.L  #tb,tb_lectura
        *los punteros de escritura y lectura están inicializados en la misma posición(vacio)
        MOVE.L  #tb,A0
        MOVE.L  A0,D1                       *En d1 esta 0x1b73
        ADD.L   D0,D1                       *Al sumar la posicion de memoria del buffer a D0 se obtiene el puntero al final                 
        MOVE.L  D1,tb_fin 

        MOVEM.L (A7)+,A0/D0-D1                *Restauramos los registros usados durante la ejecución de esta subrutina
        RTS                                  
 *************************PRINT****************************************
PRINT:

    LINK A6,#0
    MOVE.L #0,D2                            *Limpieza D2( para guardar el descriptor)
    MOVE.L #0,D3                            *Limpieza D3( para guardar el Tamaño)
    MOVE.W 12(A6),D2                        *Descriptor a D2
    MOVE.L #0,D4                            *Limpiamos D4 para guardar luego la informacion del buffer en el que nos encontramos
    CMP.W #0,D2                             *Descriptor ==0?
    BEQ PRNT_A                              *Estoy en A
    CMP.W #1,D2                             *Descriptor ==1 ?
    BEQ PRNT_B                              *Estoy en B
                                            *El descriptor pasado como parametro está mal
	MOVE.L #$ffffffff,D0                    *Se mete un -1 en D0
    UNLK A6                             
    RTS
PRNT_A:
    MOVE.L #2,D4                            *Se mete un 2 en D4 porque es el que accede al buffer de Trasmision de A
    BRA PRNT
PRNT_B:
    MOVE.L #3,D4                            *Se mete un 3 en D4 porque es el que accede al buffer de Trasmision de B
    
PRNT:
    MOVE.L #0,D5                            *contador inicializado a 0 en D5
    MOVE.W 14(A6),D3                        *Guarda el tamanio en D3
    MOVE.L 8(A6),A1                         *Mete el Buffer pasado commo parametro en el registro A1
PRNT_BUC    
    CMP.L D5,D3                             *Si contador==tamanio hemos terminado
    BEQ PRNT_TER
	

    MOVE.B (A1)+,D1					        *Sacamos dato y avanzamos buffer
    MOVE.L D4,D0                            *Se mete en D0 el identificador del buffer
    BSR ESCCAR

    CMP #$ffffffff,D0                       *Si la llamada a ESSCAR ha devuelto un -1(buffer lleno) se termina
    BEQ PRNT_TER
    ADD.L #1,D5                             *Avanzar contador
    CMP.B #13,D1                            *Comprueba si se ha escrito un retorno de carro
    BNE PRNT_BUC                            *Si no, salta al bucle
    MOVE.B #1,flagPRT                       *Si he escrito un 0xD activo el flag
    BRA PRNT_BUC

PRNT_TER:
    CMP.B #0,flagPRT                        *Comprueblo si el flag está activado
    BEQ PRNT_FIN                            
    MOVE.L #0,D6                            *limpieza de D6
    MOVE.W SR,D6                    *Guardar SR para restituirlo despues 
    MOVE.W   #$2700,SR              *Inhibe interrupciones
    CMP #2,D4                       *Compruebo en que buffer estoy para saber que bit del IMR activar
    BEQ PRNT_ACA                    *Salto para activatr el bit de A de IMR
    BSET #4,COPIA_IMR               *Activo el BIT 4
    BRA PRNT_IMR
PRNT_ACA:
    BSET #0,COPIA_IMR
PRNT_IMR:
    MOVE.B COPIA_IMR,IMR
    MOVE.W D6,SR                    *Restituimos el SR al valor que tenia previamente 
    MOVE.B #0,flagPRT               *reset a 0 del flag
PRNT_FIN:
    MOVE.L D5,D0                    *Contador a D0
    UNLK A6
    RTS
 *************************FIN PRINT****************************************

 *************************SCAN****************************************
 SCAN:

		LINK A6,#0                          *Se crea el marco de pila 
        MOVE.L #0,D0                        *Limpiamos D0
        MOVE.L #0,D1                        *Limpiamos D1
		MOVE.W 12(A6),D0                    *Descriptor en D0

		CMP.W #0,D0                         *Compara el Descriptor con 0  
		BEQ SC_DESCOK                       *Salta si el Descriptor es 0
		CMP.W #1,D0                         *Compara el Descriptor con 1 
		BEQ SC_DESCOK                       *Salta si el Descriptor es 1
	
*********ERROR*********
		MOVE.L #0,D0 						*Limpiamos D0
		MOVE.L #$ffffffff,D0
		UNLK A6      						*Se destruye el marco de pila
		RTS  
***********************    
SC_DESCOK:
		BSR LINEA
		CMP.L #0,D0							*comparamos D0 con 0 
		BEQ SC_MAL							*Si D0 es un 0 significa que linea ha devuelto un 0 y hemos terminado
        MOVE.W 14(A6),D1                    *Tamanio en D1
		CMP.L D1,D0                         *Compara D0(numero caracteres) con D1(Tamanio)
		BHI SC_MAL							*Si D0 es mayor que Tamanio hemos terminado
		MOVE.L D0,D3						*Metemos D0 en D3, D3 es el tamanio de la linea que hay que leer
		MOVE.L  8(A6),A1                    *Buffer en A1
		MOVE.L #0,D2 						*Limpiamos el registro D2 para usarlo de contador 	
	
SC_BUC:
		CMP.L D3,D2							*Comparamos el contador con el tamanio que hay que leer
		BEQ SC_FIN							*Si son iguales hemos terminado
        MOVE.L #0,D0                        *Limpiamos D0
        MOVE.W 12(A6),D0                    *Descriptor en D0
		BSR LEECAR							*llamamos a LEECAR para leer el proximo caracter
		
        ADD.W #1,D2							*sumamos 1 al contador
		MOVE.B D0,(A1)+						*Metemos el dato en el buffer y Avanzamos el puntero del buffer
		BRA SC_BUC		
	
SC_FIN:
		MOVE.L D3,D0                       *Movemos el tamanio a D0 
		UNLK A6                            *Se destruye el marco de pila
		RTS
SC_MAL:
        MOVE.L #0,D0                        *Limpiamos D0 para devolver un 0

		UNLK A6      						*Se destruye el marco de pila
		RTS
 *********************FIN SCAN**********************

 *********************LEECAR**********************
LEECAR:
    MOVEM.L A1-A4/D2-D3,-(A7)               *Se guardan los registros para evitar su modificacion (29 de Abril)

    MOVE.L #TAM_BUF,D2                      *Tamaño del buffer guardado en D2
                                            *Buffer en D0
                                            *caracter en D1
    BTST #0,D0                              *Consulta el contenido del bit 0
    BEQ  LEE_LA                             *Si bit ==0 salta a la linea A
	************BUFFER B***************
	
    *en caso de no saltar es linea B
    BTST   #1,D0                            *Consulta el contenido del bit 1
    BEQ LEE_B_R                             *Si bit 1 == 0 salta a recepcion
                                            *en caso de no saltar es transimision


        *****Buffer transimision B********
    *Se asignan los punteros a variables
     MOVE.L tb_escritura,A1                 *Puntero escritura en A1
     MOVE.L tb_lectura,A2                   *Puntero lectura en A2
     MOVE.L tb_fin,A3                       *Puntero de fin en A3
     MOVE.L #3,D3                           *escribimos un 3 para saber a posteriori en que opcion estamos
     BRA LEE_COD                            *Codigo de LEECAR    


        ******Buffer recepcion B***********
LEE_B_R:
    *Se asignan los punteros a variables
     MOVE.L rb_escritura,A1                 *Puntero escritura en A1
     MOVE.L rb_lectura,A2                   *Puntero lectura en A2
     MOVE.L rb_fin,A3                       *Puntero de fin en A3
     MOVE.L #1,D3                           *escribimos un 1 para saber a posteriori en que opcion estamos
     BRA LEE_COD                            *Codigo de LEECAR    



	 *************BUFFER A*****************
LEE_LA:
    BTST   #1,D0                            *Consulta el contenido del bit 1
    BEQ LEE_A_R                             *Si bit 1 == 0 salta a recepcion
    *en caso de no saltar es transimision


        ******Buffer Transmision A***********
    *Se asignan los punteros a variables
     MOVE.L ta_escritura,A1                 *Puntero escritura en A1
     MOVE.L ta_lectura,A2                   *Puntero lectura en A2
     MOVE.L ta_fin,A3                       *Puntero de fin en A3
     MOVE.L #2,D3                           *escribimos un 2 para saber a posteriori en que opcion estamos
     BRA LEE_COD                            *Codigo de LEECAR    


        ******Buffer Recepcion A***********
LEE_A_R:
    *Se asignan los punteros a variables
     MOVE.L ra_escritura,A1                 *Puntero escritura en A1
     MOVE.L ra_lectura,A2                   *Puntero lectura en A2
     MOVE.L ra_fin,A3                       *Puntero de fin en A3
     MOVE.L #0,D3                           *escribimos un 0 para saber a posteriori en que opcion estamos *


    *****CODIGO LEECAR*****
LEE_COD:

     CMP A1,A2                                      *compara escritura y lectura
     BEQ VACIO                                      *Si escritura==lectura está vacio
     MOVE.L #0,D0                                   *Limpiamos D0
     MOVE.B (A2),D0                                 *Leer Dato
     MOVE.L A2,A4                                   *Puntero lectura ->A4
     ADD.L #1,A4                                    *Avanzamos el puntero auxiliar 
     CMP A3,A2                                      *compara si el puntero de lectura esta en el final
     BNE LEE_NFIN                                   *Si no esta al final saltamos a actualizar los punteros
     SUB.L D2,A4                                    *Si esta al final restamos el tamaño del buffer al puntero aux para ubicarlo en el inicio
LEE_NFIN:
             **********Codigo de actualizar punteros*********
    CMP.L #0,D3                               *¿D3==0? Comprobamos la variable que hemos creado antes para saber si estamos en Recep de A
    BNE LEE_SIG1                              *Si no estamos, salto
    MOVE.L A4,ra_lectura                 	  *apuntamos ra_lectura a su nueva posicion
    BRA LEE_FIN

LEE_SIG1:
    CMP.L #1,D3                              *¿D3==1? Comprobamos la variable para saber si estamos en Recep de B
    BNE LEE_SIG2                             *Si no estamos, salto
    MOVE.L A4,rb_lectura	                 *apuntamos rb_lectura a su nueva posicion
    BRA LEE_FIN

LEE_SIG2:
    CMP.L #2,D3                             *¿D3==2? Comprobamos la variable para saber si estamos en Transmision de A
    BNE LEE_SIG3                            *Si no estamos, salto (Si saltamos singifica que es Transmision de B)
    MOVE.L A4,ta_lectura                  	*apuntamos ta_lectura a su nueva posicion
    BRA LEE_FIN

LEE_SIG3:
    MOVE.L A4,tb_lectura	                *apuntamos tb_lectura a su nueva posicion
    BRA LEE_FIN


VACIO:
    MOVE.L #0,D0                            *Limpiamos D0
    MOVE.L #$ffffffff,D0                    *Metemos un -1 en D0
LEE_FIN:
    MOVEM.L (A7)+,A1-A4/D2-D3                *Restauramos los registros usados durante la ejecución de esta subrutina
    RTS

 *********************FIN LEECAR**********************




 *********************ESCCAR****************************
ESCCAR:
    MOVEM.L A1-A4/D1-D3,-(A7)               *Se guardan los registros para evitar su modificacion (29 de Abril)
    MOVE.L #TAM_BUF,D2                      *Tamaño del buffer guardado en D2
                                            *Buffer en D0
                                            *caracter en D1
    BTST    #0,D0                           *Consulta el contenido del bit 0
    BEQ  ESC_LA                             *Si bit ==0 salta a la linea A
	************BUFFER B***************
	
    *en caso de no saltar es linea B
    BTST   #1,D0                            *Consulta el contenido del bit 1
    BEQ ESC_B_R                             *Si bit 1 == 0 salta a recepcion
                                            *en caso de no saltar es transimision


        *****Buffer transimision B********
    *Se asignan los punteros a variables
     MOVE.L tb_escritura,A1                 *Puntero escritura en A1
     MOVE.L tb_lectura,A2                   *Puntero lectura en A2
     MOVE.L tb_fin,A3                       *Puntero de fin en A3
     MOVE.L #3,D3                           *escribimos un 3 para saber a posteriori en que opcion estamos
     BRA ESC_COD                            *Codigo de ESCCAR    


        ******Buffer recepcion B***********
ESC_B_R:
    *Se asignan los punteros a variables
     MOVE.L rb_escritura,A1                 *Puntero escritura en A1
     MOVE.L rb_lectura,A2                   *Puntero lectura en A2
     MOVE.L rb_fin,A3                       *Puntero de fin en A3
     MOVE.L #1,D3                           *escribimos un 1 para saber a posteriori en que opcion estamos
     BRA ESC_COD                            *Codigo de ESCCAR    



	 *************BUFFER A*****************
ESC_LA:
    BTST   #1,D0                            * Consulta el contenido del bit 1
    BEQ ESC_A_R                             *Si bit 1 == 0 salta a recepcion
                                            *en caso de no saltar es transimision


        ******Buffer Transmision A***********
    *Se asignan los punteros a variables
     MOVE.L ta_escritura,A1                 *Puntero escritura en A1
     MOVE.L ta_lectura,A2                   *Puntero lectura en A2
     MOVE.L ta_fin,A3                       *Puntero de fin en A3
     MOVE.L #2,D3                           *escribimos un 2 para saber a posteriori en que opcion estamos
     BRA ESC_COD                            *Codigo de ESCCAR    


        ******Buffer Recepcion A***********
ESC_A_R:
    *Se asignan los punteros a variables
     MOVE.L ra_escritura,A1                 *Puntero escritura en A1
     MOVE.L ra_lectura,A2                   *Puntero lectura en A2
     MOVE.L ra_fin,A3                       *Puntero de fin en A3
     MOVE.L #0,D3                           *escribimos un 0 para saber a posteriori en que opcion estamos


ESC_COD:
    MOVE.L A1,A4                           *Puntero escritura -> A4 
    ADD.L #1,A4                            *Avanza A4 una posicion  
    CMP.L A1,A3                            *¿Escritura==Fin?
    BNE ESC_NFIN                           * Si no está en el final no es necesario reiniciar el puntero 
    SUB.L D2,A4                            *A4 apunta al incio al restarle el tamaño del buffer

ESC_NFIN:
    CMP.L A4,A2                           *¿escritura+1==lectura?  
    BEQ LLENO                             * Si z=1 salto a lleno  
    MOVE.B D1,(A1)                        *Inserto caracter en el buffer  
    MOVE.L #0,D0                          * Devuelvo 0 en D0  


         **********Codigo de actualizar punteros*********
    CMP.L #0,D3                               *¿D3==0? Comprobamos la variable que hemos creado antes para saber si estamos en Recep de A
    BNE ESC_SIG1                              *Si z!=0 salto
    MOVE.L A4,ra_escritura                 	  *apuntamos ra_escritura a su nueva posicion
    BRA ESC_FIN

ESC_SIG1:
    CMP.L #1,D3                              *¿D3==1? Comprobamos la variable para saber si estamos en Recep de B
    BNE ESC_SIG2                             *Si z!=1 salto
    MOVE.L A4,rb_escritura	                 *apuntamos rb_escritura a su nueva posicion
    BRA ESC_FIN

ESC_SIG2:
    CMP.L #2,D3                             *¿D3==2? Comprobamos la variable para saber si estamos en Transmision de A
    BNE ESC_SIG3                            *Si z!=1 salto (Si saltamos singifica que es Transmision de B)
    MOVE.L A4,ta_escritura              	*apuntamos ta_escritura a su nueva posicion
    BRA ESC_FIN

ESC_SIG3:
    MOVE.L A4,tb_escritura	                *apuntamos tb_escritura a su nueva posicion
    BRA ESC_FIN   

    
LLENO:
	MOVE.L  #$ffffffff,D0
ESC_FIN:
    MOVEM.L (A7)+,A1-A4/D1-D3               *Restauramos los registros usados durante la ejecución de esta subrutina
	RTS
	
 *************************fIN ESSCAR*************************
 

 ***************************LINEA*******************************
 LINEA:
    MOVEM.L A1-A4/D2-D5,-(A7)               *Se guardan los registros para evitar su modificacion (29 de Abril)

    MOVE.L #TAM_BUF,D2                      *Tamaño del buffer guardado en D2
                                            *Buffer en D0
    BTST #0,D0                              *Consulta el contenido del bit 0
    BEQ  LIN_LA                             *Si bit ==0 salta a la linea A
	************BUFFER B***************
	
    *en caso de no saltar es linea B
    BTST   #1,D0                            *Consulta el contenido del bit 1
    BEQ LIN_B_R                             *Si bit 1 == 0 salta a recepcion
                                            *en caso de no saltar es transimision


        *****Buffer transimision B********
    *Se asignan los punteros a variables
     MOVE.L tb_escritura,A1                 *Puntero escritura en A1
     MOVE.L tb_lectura,A2                   *Puntero lectura en A2
     MOVE.L tb_fin,A3                       *Puntero de fin en A3
     MOVE.L #3,D3                           *escribimos un 3 para saber a posteriori en que opcion estamos
     BRA LIN_COD                            *Codigo de LINEA    


        ******Buffer recepcion B***********
LIN_B_R:
    *Se asignan los punteros a variables
     MOVE.L rb_escritura,A1                 *Puntero escritura en A1
     MOVE.L rb_lectura,A2                   *Puntero lectura en A2
     MOVE.L rb_fin,A3                       *Puntero de fin en A3
     MOVE.L #1,D3                           *escribimos un 1 para saber a posteriori en que opcion estamos
     BRA LIN_COD                            *Codigo de LIN    



	 *************BUFFER A*****************
LIN_LA:
    BTST   #1,D0 *Consulta el contenido del bit 1
    BEQ LIN_A_R *Si bit 1 == 0 salta a recepcion
    *en caso de no saltar es transimision


        ******Buffer Transmision A***********
    *Se asignan los punteros a variables
     MOVE.L ta_escritura,A1                 *Puntero escritura en A1
     MOVE.L ta_lectura,A2                   *Puntero lectura en A2
     MOVE.L ta_fin,A3                       *Puntero de fin en A3
     MOVE.L #2,D3                           *escribimos un 2 para saber a posteriori en que opcion estamos
     BRA LIN_COD                            *Codigo de LINEA    


        ******Buffer Recepcion A***********
LIN_A_R:
    *Se asignan los punteros a variables
     MOVE.L ra_escritura,A1                 *Puntero escritura en A1
     MOVE.L ra_lectura,A2                   *Puntero lectura en A2
     MOVE.L ra_fin,A3                       *Puntero de fin en A3
     MOVE.L #0,D3                           *escribimos un 0 para saber a posteriori en que opcion estamos


LIN_COD:

    MOVE.L #13,D4                           *Retorno de carro
    MOVE.L #0,D5                            * para guardar el dato
    MOVE.L #0,D0                            *Contador inicializado a 0 en D0
    LIN_LOOP:                               *Loop de Transmision de B en la subrutina Linea
        CMP A1,A2                           *compara escritura y lectura
        BEQ NO_LIN                          *Si escritura==lectura no hay mas que leer(y no he alcanzado retorno de carro)
        ADD.l #1,D0                         *Sumo 1 al contador
        MOVE.B (A2),D5                      *leer dato
        CMP.L D5,D4                           *Alcanzado retorno de carro
        BEQ LIN_FIN

        MOVE.L A2,A4                        *Puntero lectura -> A4
        ADD.L #1,A2                         *lectura+1 -> A2
        CMP.L A4,A3                         *compara si el puntero de lectura esta en el final
        BNE LIN_NFIN                        * Si no está en el final no es necesario reiniciar el puntero
        SUB.L D2,A2                         *A2 apunta al incio al restarle el tamaño del buffer
    LIN_NFIN:
        BRA LIN_LOOP

 
NO_LIN:
    MOVE.L #0,D0
LIN_FIN:
    MOVEM.L (A7)+,A1-A4/D2-D5               *Restauramos los registros usados durante la ejecución de esta subrutina
    RTS
 ***************************FIN LINEA****************************




*************************** RTI ************************************************************

RTI:    
        MOVEM.L D0-D4,-(A7) 	* Guarda los registros que se usan en la pila

RTI_BUC:
        MOVE.B ISR,D3
        MOVE.B COPIA_IMR,D4
        AND.B D4,D3             *Aplico la mascara 

        BTST #0,D3              *Compruebo el bit 0 de ISR despues de aplicar la máscara
        BNE RTI_T_A             *Salto a Trasmision de A si el bit estaba activado

        BTST #1,D3              *Compruebo el bit 1 de ISR despues de aplicar la máscara
        BNE RTI_R_A             *Salto a Recepcion de A si el bit estaba activado

        BTST #4,D3              *Compruebo el bit 4 de ISR despues de aplicar la máscara
        BNE RTI_T_B             *Salto a Transmision de B si el bit estaba activado

        BTST #5,D3              *Compruebo el bit 5 de ISR despues de aplicar la máscara
        BNE RTI_R_B             *Salto Recepcion de B si el bit estaba activado

FIN_RTI:
        MOVEM.L (A7)+,D0-D4 	*Restauramos los registros usados durante la ejecución de la RTI
        RTE


RTI_T_A:
    CMP.B #1,flagTBA           *Comparo con 1 el Flag de trasmision de A (está activado)
    BNE RTI_SALA               *Si Flag != 1 salto a RTI_SALA 

    MOVE.B #10,TBA            *Pongo un salto de linea en el buffer
    MOVE.B #0,flagTBA         *Pongo a cero el Flag observado

    MOVE.L #2,D0               *Meto un 2 en el registro cero para hacer que linea use el Buffer de Trasmision A
    BSR LINEA   
    CMP.L #0,D0                
    BNE RTI_BUC                *Si no hay una linea se deben deshabilitar las interrupciones de Trasmision

    BCLR    #0,COPIA_IMR      *Inhibe interrupciones
    MOVE.B COPIA_IMR,IMR      *Actualizamos el IMR
    BRA RTI_BUC

RTI_SALA:
    MOVE.L #2,D0               *Meto un 2 en el registro cero para hacer que linea use el Buffer de Trasmision A 
    BSR LEECAR
    MOVE.B D0,TBA              *Meto el caracter leido en el buffer TBA

    CMP.B #13,D0               *Compara el caracter leido con el retorno de carro
    BNE RTI_BUC                *Si es un retorno de carro activo el flagTBA 
    MOVE.B #1,flagTBA
    BRA RTI_BUC

RTI_T_B:
    CMP.B #1,flagTBB           *Comparo con 1 el Flag de trasmision de B (está activado)
    BNE RTI_SALB               *Si Flag != 1 salto a RTI_SALB (Salto de B)

    MOVE.B #10,TBB            *Pongo un salto de linea en el buffer
    MOVE.B #0,flagTBB         *Pongo a cero el Flag observado

    MOVE.L #3,D0              *Meto un 3 en el registro cero para hacer que linea use el Buffer de Trasmision B
    BSR LINEA   
    CMP.L #0,D0                
    BNE RTI_BUC               *Si no hay una linea se deben deshabilitar las interrupciones de Trasmision

    BCLR #4,COPIA_IMR         *Inhibe interrupciones
    MOVE.B COPIA_IMR,IMR      *Actualizamos el IMR
    BRA RTI_BUC

RTI_SALB:
    MOVE.L #3,D0               *Meto un 3 en el registro cero para hacer que linea use el Buffer de Trasmision B 
    BSR LEECAR
    MOVE.B D0,TBB

    CMP.B #13,D0               *Compara el caracter leido con el retorno de carro
    BNE RTI_BUC                *Si es un retorno de carro activo el flagTBA 
    MOVE.B #1,flagTBB
    BRA RTI_BUC

RTI_R_A:
    MOVE.L #0,D0               *Meto un 0 en el registro cero para hacer que ESSCAR use el Buffer de recepcion A                 
    MOVE.L #0,D1               *Limpio D1 
    MOVE.B RBA,D1              *Escribo el catacter del puerto RBA en D1 para llamar a esscar 
    BSR ESCCAR
    CMP.L #-1,D0               *Si la llamada ha devuelto un 0 termino
    BEQ FIN_RTI
    BRA RTI_BUC        
RTI_R_B: 
    MOVE.L #1,D0                *Meto un 0 en el registro cero para hacer que ESSCAR use el Buffer de recepcion A  
    MOVE.L #0,D1                *Limpio D1 
    MOVE.B RBB,D1               *Escribo el catacter del puerto RBA en D1 para llamar a esscar 
    BSR ESCCAR
    CMP.L #-1,D0                *Si la llamada ha devuelto un 0 termino
    BEQ FIN_RTI
    BRA RTI_BUC
*************************** FIN RTI ************************************************************
TEST_SCAN:
    **Se cosidera que todos los buffers estan vacios antes de llamar a las pruebas
    *Seleccionar buffer para testear 0,1,2,3
    MOVE.L #1,D0        *seleccion del buffer
    MOVE.L #0,D4        *Contador 
    MOVE.L #0,D1        *el carater que insertamos
*Llena el buffer
P1:
    CMP.L #13,D4        *metemos 13 elementos
    BEQ FIN_T1
    ADD.L #1,D4
    MOVE.L #1,D0
    BSR ESCCAR
    ADD.L #1,D1
    BRA P1
FIN_T1:
    MOVE.W   #0,CONTC     * Inicializa contador de caracteres
    MOVE.L  #BUFFER,DIRLEC 
    
    MOVE.W   #TAML,-(A7)        * Tamano maximo de la linea
    MOVE.W   #DESB,-(A7)        * Puerto A
    MOVE.L   DIRLEC,-(A7)       * Direccion de lectura 
    BSR      SCAN
    BREAK


T_SCN_2:
    *Prueba escribimos en el puerto b una serie de caracteres. Tras esto preparamos el buffer, el tamaño y el descriptor (que sera el de b)
    *llamamos a scan que debera scanear los caracteres recien escritos.
    BREAK
T_SCNBU:
    MOVE.W   #0,CONTC     * Inicializa contador de caracteres
    MOVE.L  #BUFFER,DIRLEC 
    
    MOVE.W   #TAML,-(A7)        * Tamano maximo de la linea
    MOVE.W   #DESA,-(A7)        * Puerto A
    MOVE.L   DIRLEC,-(A7)       * Direccion de lectura 
    BSR      SCAN

    BRA T_SCNBU 
    BREAK

    MOVE.W   #TAML,-(A7)        * Tamano maximo de la linea
    MOVE.W   #DESA,-(A7)        * Puerto A
    MOVE.L   DIRLEC,-(A7)       * Direccion de lectura 
    BSR      PRINT

    BREAK
    BRA T_SCN_2
    RTS

T_PRNT:
    *Prueba para probar la prueba 44 del datsi:  4 lineas de 100
    *bytes mas el retorno de carro por la linea B, mediante cuatro llamadas a
    *PRINT. Cada una de las lineas se componen por el bloque 1234567890
    *(repetido 10 veces) mas el retorno de carro.
    BREAK
    MOVE.W   #0,CONTC     * Inicializa contador de caracteres
    MOVE.L  #BUFFER,DIRLEC 
    MOVE.L  #BUFFER,A1

    MOVE.L #0,D3        *Limpiamos d3
    MOVE.L #-1,D4        *Contador
T_PR_BU2:
    ADD.L #1,D4
    CMP.L #10,D4
    BEQ T_PR_F
    MOVE.B #$31,D3        *numero 1
T_PR_BU3
    MOVE.B D3,(A1)+     *Metemos el numero en el buffer
    ADD.L #$1,D3         *Avanzamos d3
    CMP.B #$31,D3
    BEQ T_PR_BU2
    CMP.B #$3a,D3
    BNE T_PR_BU3
    MOVE.B #$30,D3
    BRA T_PR_BU3

T_PR_F:
    MOVE.B #13,(A1)     *Metemos el retorno de carro

    MOVE.W   #TAML,-(A7)        * Tamano maximo de la linea
    MOVE.W   #DESB,-(A7)        * Puerto A
    MOVE.L   DIRLEC,-(A7)       * Direccion de lectura 
    BSR      PRINT
    BREAK

    MOVE.W   #TAML,-(A7)        * Tamano maximo de la linea
    MOVE.W   #DESB,-(A7)        * Puerto A
    MOVE.L   DIRLEC,-(A7)       * Direccion de lectura 
    BSR      PRINT
    BREAK

    MOVE.W   #TAML,-(A7)        * Tamano maximo de la linea
    MOVE.W   #DESB,-(A7)        * Puerto A
    MOVE.L   DIRLEC,-(A7)       * Direccion de lectura 
    BSR      PRINT
    BREAK

    MOVE.W   #TAML,-(A7)        * Tamano maximo de la linea
    MOVE.W   #DESB,-(A7)        * Puerto A
    MOVE.L   DIRLEC,-(A7)       * Direccion de lectura 
    BSR      PRINT
    BREAK
    RTS
INICIO:
    *BSR INIT
        * Manejadores de excepciones

        MOVE.L  #BUS_ERROR,8    * Bus error handler
        MOVE.L  #ADDRESS_ER,12  * Address error handler
        MOVE.L  #ILLEGAL_IN,16  * Illegal instruction handler
        MOVE.L  #PRIV_VIOLT,32  * Privilege violation handler
       * MOVE.L  #ILLEGAL_IN,40  * Illegal instruction handler
        *MOVE.L  #ILLEGAL_IN,44  * Illegal instruction handler


        BSR     INIT
        MOVE.W  #$2000,SR       * Permite interrupciones

BUCPR:  MOVE.W  #0,CONTC        * Inicializa contador de caracteres
        MOVE.W  #NLIN,CONTL     * Inicializa contador de L�neas
        MOVE.L  #BUFFER,DIRLEC  * Direcci�n de lectura = comienzo del buffer
OTRAL:  MOVE.W  #TAML,-(A7)     * Tama�o m�ximo de la l�nea
        MOVE.W  #DESA,-(A7)     * Puerto A
        MOVE.L  DIRLEC,-(A7)    * Direci�n de lectura
ESPL:   BSR     SCAN
        *NOP
        CMP.L   #0,D0
        BEQ     ESPL            * Si no se ha leido una l�nea se intenta de nuevo
        ADD.L   #8,A7           * Restablece la pila
        ADD.L   D0,DIRLEC       * Calcula la nueva direcci�n de lectura
        ADD.W   D0,CONTC        * Actualiza el n�mero de caracteres leidos
        SUB.W   #1,CONTL        * Actualiza el n�mero de l�neas leidas
        BNE     OTRAL           * Si no se han leido todas las l�neas se vuelve a leer

        MOVE.L  #BUFFER,DIRLEC  * Direcci�n de lectura = comienzo del buffer
OTRAE:  MOVE.W  #TAMB,TAME      * Tama�o de escritura = Tama�o de bloque
ESPE:   MOVE.W  TAME,-(A7)      * Tama�o de escritura
        MOVE.W  #DESB,-(A7)     * Puerto B
        MOVE.L  DIRLEC,-(A7)    * Direcci�n de lectura
        BSR     PRINT
        ADD.L   #8,A7           * Restablece la pila
        ADD.L   D0,DIRLEC       * Calcula la nueva direcci�n del buffer
        SUB.W   D0,CONTC        * Actualiza el contador de caracteres
        BEQ     SALIR           * Si no quedan caracteres se acaba
        SUB.W   D0,TAME         * Actualiza el tama�o de escritura
        BNE     ESPE            * Si no se ha escrito todo el bloque se insiste
        CMP.W   #TAMB,CONTC     * Si el n� de caracteres que quedan es menor que el tama�o establecido se imprime ese n�mero
        BHI     OTRAE           * Siguiente  bloque
        MOVE.W  CONTC,TAME
        BRA     ESPE            * Siguiente  bloque

SALIR:  BRA     BUCPR

FIN:    BREAK

BUS_ERROR:      BREAK           * Bus error handler
                NOP
ADDRESS_ER:     BREAK           * Address error handler
                NOP
ILLEGAL_IN:     BREAK           * Illegal instruction handler
                NOP
PRIV_VIOLT:     BREAK           * Privilege violation handler
                NOP

    *BSR T_SCN_2
    *BREAK
    *NOP



    