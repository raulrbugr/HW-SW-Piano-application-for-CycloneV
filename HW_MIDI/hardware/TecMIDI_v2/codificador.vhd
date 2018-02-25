library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity codificador is
	port(
	reset, clk: in std_logic;
	midi_rx : in std_logic;
	--ack :in std_logic;
	n_on, n_off : out std_logic;
	key, vel : out unsigned (6 downto 0)

	);
end;


architecture architecturecodificador of codificador is 
		signal ack: std_logic := '1';
		component modulo1 is
			port(
				

				reset, clk	: in std_logic;
				midi_rx 	: in std_logic;
				ready 		: out std_logic;
				code		: out unsigned (7 downto 0)
			);
		
		end component;

		signal code_aux : unsigned (7 downto 0);
		signal ready_aux : std_logic;
		
		component modulo2 is
		port(
				
				reset, clk	: in std_logic;
				ready,ack 	: in std_logic;
				code		: in unsigned (7 downto 0);
				n_on, n_off 	: out std_logic;
				key, vel 	: out unsigned (6 downto 0)
			);
		end component;
		
		begin
			C1 : modulo1
			port map(
				reset => reset,
				clk => clk,
				midi_rx => midi_rx,
				code => code_aux,
				ready => ready_aux
			);

			C2: modulo2
			port map(
				reset => reset, 
				clk => clk, 
				ready => ready_aux , 
				ack  => ack, 
				code => code_aux,
				n_on => n_on , 
				n_off => n_off, 
				key => key, 
				vel => vel
			);

end architecturecodificador;