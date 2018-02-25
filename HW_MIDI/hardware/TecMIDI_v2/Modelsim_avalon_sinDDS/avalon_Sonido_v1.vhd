
---------------------------------------------------------------
--- Versión inicial de Michael Sandoval y Raúl Ruiz
--- Fecha: 20/2/2018
-- 	Version: V1.0  Version inicial Sonido (20/2/2018)

---------------------------------------------------------------

--------------------------------------------------------------
--  Registro RegDatos : Registro de Datos del controlador
--					
--		Leng: 32 bits 
--		Offset 1 
--		Formato:	0x00-0E-VV-TT
--					: E es el bit de codigo de enable (bits 16)
--					: VV es el byte de codigo de velocidad (bits 15-8)
--					: TT es el byte de codigo de tecla(bits 7-0)
--			(Nota: en VV y TT  usamos 7 bits)
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
--	aud_daclrck 	: Entrada del modulo Au_out	
--	aud_bclk 		: Entrada del modulo Au_out
--	aud_dacdat : out std_logic	: Salida de datos del modulo Au_out
--
-----------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity avalon_SoundMIDI is
port (
-- Señales   del BUS AVALON	
	clk 	: in std_logic;			-- System CLK
	clr_n 	: in std_logic;			-- System reset ( activo en baja, lógica negativa)
	cs 	: in std_logic;			-- Chip Select signal  			(CONTROL Bus)
	--rd_n 	: in std_logic;			-- Read data CONTROL signal		(CONTROL Bus)
	wr_n 	: in std_logic;			-- Write data CONTROL signal	(CONTROL Bus)
	--irq 	: OUT STD_LOGIC;		-- Irq signal  					(CONTROL Bus)
	addr 	: in std_logic_vector(1 downto 0);			-- Address Bus	 			(Address Bus)
	wr_data : in std_logic_vector (31 downto 0);	-- Write Data 	(DATA Bus)
	rd_data : out std_logic_vector (31 downto 0);	-- Read data	(DATA Bus)

-- Señal de entrada del exterior del sistema NIOS II (conduit)	

	aud_daclrck : in std_logic;
	aud_bclk : in std_logic;
	aud_dacdat : out std_logic

);

	
	
end avalon_SoundMIDI;

architecture behave of avalon_SoundMIDI is

--constant REG_Estado_Address : std_logic_vector(1 downto 0) :="00";
constant REG_Datos_Address : std_logic_vector(1 downto 0) :="01";
--constant REG_Control_Address : std_logic_vector(1 downto 0) :="10";

-- Registros de la interfaz de usuario
signal RegDatos : std_logic_vector (31 downto 0);	
--signal RegEstado : std_logic_vector (31 downto 0);
--signal RegControl : std_logic_vector (31 downto 0);



	component SoundModule is
		port(
		reset, clk: in std_logic;
		
		--au_out
		
		--sample: in signed(15 downto 0);
		daclrc: in std_logic;
		bclk: in std_logic;
		--ready: out std_logic; --conectado internamente con 1
		dac_dat: out std_logic;
	
		--sin_DDS
		
		--nextsample : in std_logic; --conectado internamente con 1
		enable : in std_logic;
		vel, key: in unsigned (6 downto 0)
		--sample : out signed (15 downto 0)
	
		);
	end component;



-- Señales internas del controlador


signal key_code : std_logic_vector(7 downto 0);
signal vel_code : std_logic_vector(7 downto 0);

signal enable : std_logic;


begin

--------------------------------------------------------------------------------------------
-- Hardware de control del bus (Glue-Logic)
--


	rd_data<= RegDatos;
					


	P_RegDatos: process (clk, clr_n)
	begin
		if clr_n = '0' then
			RegDatos <= (others => '0');

		elsif clk'event and clk = '1' then
			-- Senial de escritura se activa en baja
			if (cs='1' and addr = REG_Datos_Address and wr_n = '0') then
				
				RegDatos <= wr_data; 		--Formato:	0x00-0E-VV-TT	
				
			end if;
		end if;
	end process;

	key_code <= RegDatos(7 downto 0);
	vel_code <= RegDatos(15 downto 8);
	enable <= RegDatos(16);
	
	


----------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------	
--  Hardware interno del controlador 
--	
--

-- SoundModule es la entidad que engloba a sin_dds y au_out

	u_SoundMIDI: component SoundModule
		port map(
		reset => not clR_N, 
		clk => clk,
		
		--au_out
			
		--sample: in signed(15 downto 0);  -- conectado internamente con 2
		daclrc => AUD_DACLRCK, 
		bclk => AUD_BCLK,
		--ready: out std_logic; --conectado internamente con 1
		dac_dat => AUD_DACDAT,
					
		--sin_DDS
				
		--nextsample : in std_logic; --conectado internamente con 1
		enable => enable,
		vel => unsigned(vel_code(6 downto 0)),
		key => unsigned(key_code(6 downto 0))
		--sample : out signed (15 downto 0) -- conectado internamente con 2
	
		);

	
-------------------------------------------------------------------------------------------------------	
end behave;
