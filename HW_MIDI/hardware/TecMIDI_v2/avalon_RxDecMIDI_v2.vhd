-- Ejemplo de un dispositivo RxDecMIDI con bus Avalon 
--
---------------------------------------------------------------
--- Versión inicial de Gonzalo Alvarez - Dpto. ATC/KAT  (UPV/EHU)
--- Fecha: 23/12/2016
-- 	Version: V1.0  Version inicial PWM (8/1/2018)
--  Version: V2.0  RX_UART  (15/1/2018)
--  Version: V2.2  RxDecMIDI (7/2/2018) 
---------------------------------------------------------------
-- Interfaz de usuario:
--------------------------------------------------------------
--  Registro REG_Estado : Registro de Estado del controlador 
--					
--		Leng: 32 bits 
--		Offset 0
--		Formato:	0b00...00 OFI	
--					: O es el bit de Note_ON (O=1 Note_ON recibido)
--					: F es el bit de Note_OFF (F=1 Note_OFF recibido)
--					: I es el bit de interrupción (I=1 Interrupción generada)
--						Cuando se he producido un evento del RxMIDI: Note_ON o Note_OFF o Note_ERROR
--			El registro se borra (pone todo a 0)  cuando se lee 
--
--------------------------------------------------------------
--  Registro RegDatos : Registro de Datos del controlador
--					
--		Leng: 32 bits 
--		Offset 1 
--		Formato:	0x00-00-VV-TT	
--					: VV es el byte de codigo de velovidad (bits 15-8)
--					: TT es el byte de codigo de tecla(bits 7-0)
--			(Nota: Se podría realizar otra versión sin registro de Datos anadiendo 
--  los bits de O  con 
-- 			una generación automática del ACK (cundo se ha guardado en el registro de 
--			datos y de estado los valores correspondientes)
--
--------------------------------------------------------------
--------------------------------------------------------------
--  Registro RegControl : Registro de Control del controlador
--					
--		Leng: 32 bits 
--		Offset 2
--		Formato:	0b000...000A	
--					: A es el bit de ACK_Note para el RxDecMIDI (A=1 ACK)
--			(Nota: Se podría realizar otra versión sin registro de control con 
-- 			una generación automática del ACK (cundo se ha guardado en el registro de 
--			datos y de estado los valores correspondientes)
--	     El registro se borra en el siguiente ciclo de reloj 
--
--------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
-- Interfaz BUS AVALON
--      clk 	: the system clock.
--		clr_n	: Reset del bus
--		cs  	: Chip select
--		addr 	: Dirección interna de los registros( 1 bit)
--		rd_n	: Control de Lectura de un Registro (Read)
--		irq 	: Senial de interrupción 
--		rd_data	: Dato de lectura 
--
-- Interfaz Externa: (conduit)
--		rx : de entrada RX del exterior del sistema NIOS II (conduit) (8 bits con la misma señal)
--
-----------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity avalon_RxDecMIDI is
port (
-- Señales   del BUS AVALON	
	clk 	: in std_logic;			-- System CLK
	clr_n 	: in std_logic;			-- System reset ( activo en baja, lógica negativa)
	cs 	: in std_logic;			-- Chip Select signal  			(CONTROL Bus)
	rd_n 	: in std_logic;			-- Read data CONTROL signal		(CONTROL Bus)
	wr_n 	: in std_logic;			-- Write data CONTROL signal	(CONTROL Bus)
	irq 	: OUT STD_LOGIC;		-- Irq signal  					(CONTROL Bus)
	addr 	: in std_logic_vector(1 downto 0);			-- Address Bus	 			(Address Bus)
	wr_data : in std_logic_vector (31 downto 0);	-- Write Data 	(DATA Bus)
	rd_data : out std_logic_vector (31 downto 0);	-- Read data	(DATA Bus)

-- Señal de entrada del exterior del sistema NIOS II (conduit)	
	RX_Midi : in std_logic );
	
end avalon_RxDecMIDI;

architecture behave of avalon_RxDecMIDI is

constant REG_Estado_Address : std_logic_vector(1 downto 0) :="00";
constant REG_Datos_Address : std_logic_vector(1 downto 0) :="01";
constant REG_Control_Address : std_logic_vector(1 downto 0) :="10";

-- Registros de la interfaz de usuario
signal RegDatos : std_logic_vector (31 downto 0);	
signal RegEstado : std_logic_vector (31 downto 0);
signal RegControl : std_logic_vector (31 downto 0);


--	component RxDecMIDI is
--	port  (	clk, reset:	in std_logic;	-- Clk y reset del sistema
--		RX_Midi	:	in std_logic;		-- Serial RX MIDI external input
--		N_ON:		out std_logic; 		--   Note ON
--		N_OFF: 		out std_logic; 		--   Note OFF
--		key_code: 		out std_logic_vector (7 downto 0);	-- Key Code
--		vel_code: 		out std_logic_vector (7 downto 0)	-- Velocity Code
--		  );
--	end component RxDecMIDI;

	component codificador is
	port(
		reset, clk: in std_logic;
		midi_rx : in std_logic;
		--ack :in std_logic;
		n_on, n_off : out std_logic;
		key, vel : out unsigned (6 downto 0)

	);
	end component;

-- Señales internas del controlador

-- 

signal ack_Note : std_logic;
signal Dato : std_logic_vector(7 downto 0);
signal N_ON : std_logic;
signal N_OFF : std_logic;

signal key_code : std_logic_vector(7 downto 0);
signal vel_code : std_logic_vector(7 downto 0);



begin

--------------------------------------------------------------------------------------------
-- Hardware de control del bus (Glue-Logic)
--

-- Lectura de  un registro de datos
-- 	Siempre muestra en Bus de datos de Salida el contenido del registro indicado por addr.
	rd_data <= 	RegControl when addr = REG_Control_Address  else
					RegDatos   when addr = REG_Datos_Address 	else
					RegEstado ;

					
					
-- Senial de Interrupcion
-- 	En este ejemplo el bit 0 del Registro de estado (RegEstado(0))
	irq <= RegEstado(0);

-- Escritura de  un registro de Estado

	P_RegEstado: process (clk, clr_n)
	begin
		if clr_n = '0' then
			RegEstado <= (others => '0');

		elsif clk'event and clk = '1' then
			-- Senial de escritura se activa en baja
			if (N_ON = '1'  ) then
				RegEstado(2) <= '1' ; -- ------O-- Activamos Bit O (Note On)
				RegEstado(0) <= '1' ; -- ------O-- Activamos Bit I (Int)
			elsif ( N_OFF = '1' ) then
				RegEstado(1) <= '1' ; -- ------O-- Activamos Bit F (Note oFF)
				RegEstado(0) <= '1' ; -- ------O-- Activamos Bit I (Int)
			elsif (cs='1' and addr = REG_Control_Address and wr_n = '0') then -- Borrar el registro de Estado
				RegEstado <= (others => '0');
			end if;
		end if;
	end process; 

-- Escritura de  un registro de Datos

	P_RegDatos: process (clk, clr_n)
	begin
		if clr_n = '0' then
			RegDatos <= (others => '0');

		elsif clk'event and clk = '1' then
			-- Senial de escritura se activa en baja
			if (N_ON = '1' or N_OFF = '1' ) then
				RegDatos <= x"0000" & vel_code & key_code; ----		Formato:	0x00-00-VV-TT	
			end if;
		end if;
	end process;
	
	
-- Escritura de  un registro de Control

	P_RegControl: process (clk, clr_n)
	begin
		if clr_n = '0' then
			RegControl <= (others => '0');

		elsif clk'event and clk = '1' then
			-- Senial de escritura se activa en baja
			   if (cs='1' and addr = REG_Control_Address and wr_n ='0') then -- 
				   RegControl <=wr_data ;-- Debería ser el ACK ("00...01")
			   else
				   RegControl <= (others => '0');	-- El ACK solo se debe mantener 1 ciclo
			   end if;
		end if;
	end process;

----------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------	
--  Hardware interno del controlador 
--	
--

-- Componente RxDecMIDI
--
--	u_RxDecMIDI: component RxDecMIDI 
--	port map (	clk 		=> clk,
--				reset 		=> not clR_N,		--  En el componente se activa en ALTA (lógica positiva)
--				RX_Midi 	=> RX_Midi,			--   Serial RX MIDI external input
--				N_ON	 	=> N_ON,		 		--   Note ON
--				N_OFF 	 	=> N_OFF,		 		--   Note OFF
--				key_code 	=> key_code,				--   Key Code
--				vel_code 	=> vel_code					--   Velocity Code
--		  );

	u_RxDecMIDI: component codificador 
	port map (	clk 		=> clk,
				reset 		=> not clR_N,		--  En el componente se activa en ALTA (lógica positiva)
				midi_rx 	=> RX_Midi,			--   Serial RX MIDI external input
				N_ON	 	=> N_ON,		 		--   Note ON
				N_OFF 	 	=> N_OFF,		 		--   Note OFF
				std_logic_vector(key)	 	=> key_code(7 downto 1),				--   Key Code
				std_logic_vector(vel)	 	=> vel_code(7 downto 1)				--   Velocity Code
		  );

	

	---  Generar la senial ACK
--	ack_Note <=  RegControl(0);	-- Bit A del Registro de Control (Formato:	0b000...000A)
	-- O bien generacion automatica
	-- P_RegACK: process (clk, clr_n)
	-- begin
		-- if clr_n = '0' then
			-- ack_Note <=  '0';
		-- elsif clk'event and clk = '1' then
				 -- ack_Note <=  ready;
		-- end if;
		
	-- end process;
	
-------------------------------------------------------------------------------------------------------	
end behave;
