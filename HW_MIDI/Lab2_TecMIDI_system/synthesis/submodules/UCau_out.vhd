library ieee;
use ieee.std_logic_1164.all;

entity UCau_out is
	port(
		-- entradas
		reset, clk: in std_logic;
		daclrc, bclk, fin_cont: in std_logic;
		ld_reg, ready, ld_cont, desp_reg, decr_cont: out std_logic
		);
end UCau_out;

architecture arquitectura_au_out of UCau_out is
	
	type estado is (e0, e1, e2, e3, e4, e5, e6, e7);
	signal ep, es: estado;

	begin

		process (clk, reset)
			begin
				if (reset = '1') then ep <= e0;
				elsif (clk'event and clk='1') then ep<= es;
				end if;
		end process;

		process (ep, daclrc, bclk, fin_cont)
			begin
				case ep is
				when e0 => 	if (daclrc='1') then es <= e1;
							else es <= e0;
							end if;
				when e1 => es <= e2;
				when e2 => es <= e3;
				when e3 => 	if (bclk='1') then es <= e4;
							else es <= e3;
							end if;
				when e4 => 	if (bclk='0') then es <= e5;
							else es <= e4;
							end if;
				when e5 =>	if (fin_cont='0') then es <= e3;
							elsif (daclrc='0') then es <= e6;
							else es <= e7;
							end if;
				when e6 =>	if (daclrc='1') then es <= e1;
							else es <= e6;
							end if;
				when e7 =>	if (daclrc='0') then es <= e2;
							else es <= e7;
							end if;
			end case;
		end process;

		ld_cont <= '1' when ep = e2 else '0';			
		ld_reg <= '1' when ep = e1 else '0';
		decr_cont <= '1' when ep = e5 else '0';
		desp_reg <= '1' when ep = e5 else '0';
		ready <= '1' when ep = e1 else '0';

end arquitectura_au_out;
