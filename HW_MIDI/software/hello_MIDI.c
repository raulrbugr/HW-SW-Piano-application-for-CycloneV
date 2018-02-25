// hello_MIDI.c 
 
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "system.h"
#include <stdio.h>
#include <unistd.h>



#include <io.h>
#include <altera_avalon_pio_regs.h>

#define IORD_ALTERA_AVALON_RX_MIDI_ESTADO()           IORD(RXDECMIDI_BASE, 0)
#define IORD_ALTERA_AVALON_RX_MIDI_DATA()             IORD(RXDECMIDI_BASE, 1)
#define IORD_ALTERA_AVALON_RX_UART_CONTROL()          IORD(RXDECMIDI_BASE, 2)
#define IOWR_ALTERA_AVALON_RX_UART_CONTROL(data)      IOWR(RXDECMIDI_BASE, 2, data)


#define IORD_SWITCHES_DATA()             	IORD_ALTERA_AVALON_PIO_DATA(SWITCHES_BASE)
#define IOWR_LEDS_DATA(data)                 IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, data)


//---------------------------------------------------------------
//-- Interfaz de usuario:
//--------------------------------------------------------------
//--  Registro REG_Estado : Registro de Estado del controlador
//--
//--		Leng: 32 bits
//--		Offset 0
//--		Formato:	0b00...000OFI
//--					: O es el bit de Note_ON (O=1 Note_ON recibido)
//--					: F es el bit de Note_OFF (F=1 Note_OFF recibido)
//--					: I es el bit de interrupción (I=1 Interrupción generada)
//--						Cuando se he producido un evento del RxMIDI: Note_ON o Note_OFF o Note_ERROR
//--			El registro se borra (pone todo a 0)  cuando se lee
//--
//--------------------------------------------------------------
//--  Registro RegDatos : Registro de Datos del controlador
//--
//--		Leng: 32 bits
//--		Offset 1
//--		Formato:	0x00-00-VV-TT
//--					: VV es el byte de codigo de velovidad (bits 15-8)
//--					: TT es el byte de codigo de tecla(bits 7-0)
//--			(Nota: Se podría realizar otra versión sin registro de Datos anadiendo
//--  los bits de O  con
//-- 			una generación automática del ACK (cundo se ha guardado en el registro de
//--			datos y de estado los valores correspondientes)
//--
//--------------------------------------------------------------
//--------------------------------------------------------------
//--  Registro RegControl : Registro de Control del controlador
//--
//--		Leng: 32 bits
//--		Offset 2
//--		Formato:	0b000...000A
//--					: A es el bit de ACK_Note para el RxDecMIDI (A=1 ACK)
//--			(Nota: Se podría realizar otra versión sin registro de control con
//-- 			una generación automática del ACK (cundo se ha guardado en el registro de
//--			datos y de estado los valores correspondientes)
//--		El registro se borra en el siguiente ciclo de reloj
//--
//--------------------------------------------------------------


//alt_u32  Estado, Estado2, Dato;

struct st_texto
{
	alt_u32  Estado, Estado2, Dato, Control1, Control2;

} ;


void EsperaTiempo (useconds_t Tiempo_us)
{
	usleep(Tiempo_us);
}

#define REG_CONTROL_ACK (0x01)

// Rutina gestión de interrupción
//
static void irqhandler (void * context, alt_u32 id)
{
	struct st_texto * pContext = (struct st_texto *) context;

	pContext->Estado = IORD_ALTERA_AVALON_RX_MIDI_ESTADO(); // Leer el registro de Estado

	pContext->Dato = IORD_ALTERA_AVALON_RX_MIDI_DATA();		// LEemos los datos

	pContext->Control1 = IORD_ALTERA_AVALON_RX_UART_CONTROL();		// LEemos el reg de Control

	IOWR_ALTERA_AVALON_RX_UART_CONTROL(REG_CONTROL_ACK); // Enviamos el ACK ( y resetear la interupcion)

	pContext->Control2 = IORD_ALTERA_AVALON_RX_UART_CONTROL();		// Volvemos leer el reg de Control

	pContext->Estado2 = IORD_ALTERA_AVALON_RX_MIDI_ESTADO(); // Leer el registro de Estado

}


int main()
{


	int chek_Irq;
	struct st_texto Mi_Contexto;
	alt_u32 Dato_switches;
	alt_u32 REstado1,REstado2, RDato, RControl;

	printf("Hello from Nios II RX_UART Con Interrupciones2!\n");

	Mi_Contexto.Estado =0;
	Mi_Contexto.Dato =0;
	Mi_Contexto.Estado2 =0;
	Mi_Contexto.Control1 =0xFFFFFFFF;
	Mi_Contexto.Control2 =0xFFFFFFFF;

	chek_Irq = alt_irq_register( RXDECMIDI_IRQ, (void*) &Mi_Contexto,	(void*) irqhandler ); // register the irq
	if (chek_Irq !=0) {
		// Error
		printf("Error al registrar el la interrupción %d....\n bye...\n",RXDECMIDI_IRQ );
		for (;;) ; //
	}
	printf("Comenzamos....\n");

	while (1)
	{

		if (Mi_Contexto.Estado !=0) {

			printf(" EA:0x%lx  D:0x%lx  C1:0x%lx   C2:0x%lx  \n",Mi_Contexto.Estado, Mi_Contexto.Dato, Mi_Contexto.Control1, Mi_Contexto.Control2 );
			Mi_Contexto.Estado =0;
			Mi_Contexto.Dato =0;
			Mi_Contexto.Estado2 =0;
			Mi_Contexto.Control1 =0xFFFFFFFF;
			Mi_Contexto.Control2 =0xFFFFFFFF;
		}

		Dato_switches= IORD_SWITCHES_DATA() ;	// Leer switches
		IOWR_LEDS_DATA(Dato_switches);			// Escribir en Leds

	}

	while (1) ;
	return 0;
}
