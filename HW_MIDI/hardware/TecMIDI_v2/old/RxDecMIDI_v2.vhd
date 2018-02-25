library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RxDecMIDI is
 port(
		reset,clk:	in std_logic;	-- Clk y reset del sistema
		
		RX_Midi	:	in std_logic;		-- Serial RX MIDI external input
	
 		N_ON:		out std_logic; 		--   Note ON
		N_OFF: 		out std_logic; 		--   Note OFF
		key_code: 		out std_logic_vector (7 downto 0);	-- Key Code
		vel_code: 		out std_logic_vector (7 downto 0)	-- Velocity Code
);
end;

architecture str of RxDecMIDI is 
	
	signal key : std_logic_vector(6 downto 0);
	signal vel : std_logic_vector(6 downto 0);
	signal ready : std_logic;
	signal dig3, dig2, dig1, dig0 : std_logic_vector(6 downto 0);
	signal r0, r1 : std_logic_vector(13 downto 0);
	
	signal code : std_logic_vector (7 downto 0);
	
	component uart_rx is
		generic(
			BAUD_RATE : natural := 9600;
			CLK_FREQ : natural := 50000000);
		port(
			clk,reset	: in std_logic;
			rx				: in std_logic;
			ack			: in std_logic;
			byte			: out std_logic_vector(7 downto 0);
			ready			: out std_logic);
	end component uart_rx;


	component midi_dec is
		port (
			clk,reset	: in std_logic;
			Dato 			: in std_logic_vector(7 downto 0);
			ready			: in std_logic;
			key 			: out std_logic_vector(6 downto 0);
			vel 			: out std_logic_vector(6 downto 0);
			keyon			: out std_logic;
			keyoff			: out std_logic	);

	end component midi_dec;

	
begin 
	--declarar como component el modulo1 (port map) e instanciarlo conectando sus entradas y salidas a las descritas arriba
	
	C1: uart_rx
	generic map (
		BAUD_RATE => 31250,
		CLK_FREQ => 50000000	)
	port map (
		clk=>clk,
		reset=>reset,
		rx=>RX_Midi,
		ack => '1',
		byte=>code,
		ready=> ready		
	);
	
	C2: midi_dec
	port map (
		reset => reset, 
		clk => clk, 
		ready => ready,
		Dato => code, 
		keyon=>N_ON, 
		keyoff=>N_OFF,
		key=>key,
		vel=>vel
	);
	key_code <= "0" & key;
	vel_code <= "0" & vel;
	
END str;