
library ieee;
use ieee.std_logic_1164.all;

entity UCmodulo2 is
  port (
    	--lista de entradas y salidas de la UC: reset, clk etc
	reset, clk: in std_logic;
	ready, tipo1,C4, ack,code7 : in std_logic;
	ld_key, ld_code, ld_vel : out std_logic;
	n_on, n_off : out std_logic
	
  );
end UCmodulo2;

architecture arquitecturaUCmodulo2 of UCmodulo2 is

	type estado is (e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10);
	signal ep, es: estado;
	
	begin
		process (clk,reset)
    		begin
      			if reset='1' then ep<=e0;
        		elsif clk'event and clk='1' then ep<=es;
      			end if;
  		end process;

		process (ep, tipo1,ready,ack,C4,code7)
		begin
			case ep is
			when e0 => if ready='1' then es<=e1;
				else es<=e0;
				end if;
			when e1 =>  es<=e10;	
			when e10 => if tipo1='1' then es <=e2;
				else es<=e0;
				end if;	
		
			when e2 => if ready='1' then es <=e3; 
				else es<=e2;
				end if;
			
			when e3 => es<=e4;
			when e4 => if ready='1'  then es <=e5;
				else es<=e4;
				end if;
			when e5 => es <=e6;
			when e6 => if C4='0' then es <= e7;
				else es<=e8;
				end if;
			when e7 => if ack='0' then es <=e7;
				else es<= e9;
				end if;
			when e8 => if ack='0' then es <=e8;
				else es<=e9;
				end if; 
			when e9 => if ready='0' then es <=e9;
				elsif code7='0' and ready='1' then es <= e3;
				else es<=e1;
				end if;
			end case;
		end process;
	
		--Se?ales de salida
		ld_code <= '1' when ep = e1 else '0';
		ld_key <= '1' when ep = e3 else '0';
		ld_vel <= '1' when ep = e5 else '0';
		n_on <= '1' when ep = e8 else '0';
		n_off <= '1' when ep = e7 else '0';

end arquitecturaUCmodulo2;
