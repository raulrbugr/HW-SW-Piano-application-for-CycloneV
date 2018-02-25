library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SoundModule is
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
end;


architecture architectureSoundModule of SoundModule is 
		
		signal sample_aux: signed (15 downto 0);
		signal ready: std_logic;
		
		component au_out is
		port(
			reset, clk: in std_logic;
			sample: in signed(15 downto 0);
			daclrc: in std_logic;
			bclk: in std_logic;
			ready: out std_logic;
			dac_dat: out std_logic
		);
		end component;


		signal code_aux : unsigned (7 downto 0);
		signal ready_aux : std_logic;
		
		component sin_DDS is
		port(
			
			reset, clk: in std_logic;
			nextsample, enable : in std_logic;
			vel, key: in unsigned (6 downto 0);
			sample : out signed (15 downto 0)

		);
		end component;

		
		begin
			C1 : au_out
			port map(
				reset => reset, 
				clk => clk,
				sample => sample_aux,
				daclrc => daclrc,
				bclk => bclk,
				ready => ready,
				dac_dat => dac_dat
			);

			C2: sin_DDS
			port map(
				reset => reset,  
				clk => clk, 
				nextsample => ready, 
				enable => enable, 
				vel => vel, 
				key => key, 
				sample => sample_aux
			);



end architectureSoundModule;

