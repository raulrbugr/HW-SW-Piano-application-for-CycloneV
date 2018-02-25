library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity au_out is
	port(
		reset, clk: in std_logic;
		sample: in signed(15 downto 0);
		daclrc: in std_logic;
		bclk: in std_logic;
		ready: out std_logic;
		dac_dat: out std_logic
	);
end entity au_out;

architecture arquitecturaUPau_out of au_out is
	component UCau_out is
		port(
			-- entradas
			reset, clk: in std_logic;
			daclrc, bclk, fin_cont: in std_logic;
			ld_reg, ready, ld_cont, desp_reg, decr_cont: out std_logic
		);
	end component;

	signal ld_reg, ld_cont, desp_reg, decr_cont : std_logic;
	signal fin_cont : std_logic;
	signal value_cont : unsigned (3 downto 0) := "1111";
	signal sample_aux : signed (15 downto 0) := x"0000";

	begin

		UC : UCau_out
			port map (
				reset => reset, clk => clk, daclrc => daclrc, bclk => bclk,
				fin_cont => fin_cont, ld_reg => ld_reg, ld_cont => ld_cont,
				ready => ready, desp_reg => desp_reg, decr_cont => decr_cont
			);

		process(clk, reset, desp_reg, ld_reg)
		begin
			if (reset='1') then sample_aux(15 downto 0)<= x"0000";
			elsif (clk'event) and (clk='1')  then
				if (ld_reg='1') then sample_aux(15 downto 0) <= sample(15 downto 0);
				elsif (desp_reg='1') then
					sample_aux(15 downto 1) <= sample_aux(14 downto 0);
					sample_aux(0 downto 0)<=sample_aux(15 downto 15);
				end if;
			end if;			
		end process;

		dac_dat<=sample_aux(15);

		process(clk, reset, ld_cont, decr_cont)
		begin
			if (reset='1') or (ld_cont='1') then value_cont<=x"F";
			elsif (clk'event) and (clk='1') then
				if(decr_cont='1') then 
					value_cont<=value_cont-1;
				end if;
			end if;
		end process;

		fin_cont<='1' when value_cont="0000" else '0';
	
end architecture arquitecturaUPau_out; 