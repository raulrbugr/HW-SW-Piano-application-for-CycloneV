LIBRARY ieee  ; 
USE ieee.std_logic_1164.all  ; 
use ieee.numeric_std.all;

ENTITY sin_DDS_tb  IS 

END ; 

architecture sin_DDS_tb_arch of sin_DDS_tb is
	
		signal reset : std_logic := '1';
		signal clk : std_logic := '0';
		signal nextsample : std_logic := '0';
		signal enable :  std_logic := '0';
		signal vel : unsigned (6 downto 0) := "0000000";
		signal key:  unsigned (6 downto 0) := "0000000";
	
		signal sample : signed (15 downto 0);

	component sin_DDS 
	port(
		--Entradas y salidas de la cajita
		reset, clk: in std_logic;
		nextsample, enable : in std_logic;
		vel, key: in unsigned (6 downto 0);
		sample : out signed (15 downto 0)

	);
	end component;

	begin
		DUT: sin_DDS
		
		port map(
			clk=>clk, reset=>reset,nextsample=>nextsample,
			enable=>enable,vel=>vel,key=>key,sample=>sample
		);
		--Reloj
		clk <= not clk after 10 ns;


		--Test bench

		process
		begin
			--midi_rx <='0';
			--wait for 40 ns;
			

			wait for 20 ns;
			reset <= '0';
			nextsample <= '1';
			enable <= '1';
			key <= "0111100";
			vel <= "0000111";
			
			wait for 20 ns;
			enable <='0';

			wait for 20 ns;
			enable <='1';
			key <="0111110";
			
			wait for 500 ns;
			

			wait for 20 ns;
			enable <='1';
			key <="0111111";
			wait;
		end process;
end;