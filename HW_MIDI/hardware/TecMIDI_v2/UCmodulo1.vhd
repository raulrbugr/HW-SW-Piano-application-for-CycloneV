library ieee;
use ieee.std_logic_1164.all;

entity UCmodulo1 is
  port (
    	--lista de entradas y salidas de la UC: reset, clk etc
	reset, clk: in std_logic;
	midi_rx, fin_ct_pd, fin_ct_bt, stop_bit : in std_logic;
	ready, sel_pd, dcr_ct_pd, ld_ct_pd, ld_ct_bt, dcr_ct_bt, desp_der : out std_logic
  );
end UCmodulo1;

architecture arquitecturaUCmodulo1 of UCmodulo1 is

	type estado is (e0, e1, e2, e3, e4, e5, e6, e7,e8);
	signal ep, es: estado;
	
	begin
		process (clk,reset)
    		begin
      			if reset='1' then ep<=e0;
        		elsif clk'event and clk='1' then ep<=es;
      			end if;
  		end process;

		process (ep, midi_rx, fin_ct_pd, fin_ct_bt,stop_bit)
		begin
			case ep is
			when e0 => if midi_rx = '0' then es <= e1;
				else es <= e0;
				end if;
			when e1 => es <= e2;
			when e2 => if fin_ct_pd = '0' then es <= e2;
				elsif fin_ct_pd = '1' and midi_rx = '0' then es <= e3;
				else es <= e0; 
				end if;
			when e3 => es <= e4;
			when e4 => if fin_ct_pd = '1' then es <= e5;
				else es <= e4;
				end if;
			when e5 => if fin_ct_bt = '1' then es <= e7;
				else es <= e6;
				end if;			
			when e6 => es <= e4;
			when e7 => if stop_bit = '1' then es <= e8;
				else es <= e0;
				end if;
			when e8 => es <= e0;
			end case;
		end process;
	
		sel_pd <= '1' when ep = e1 else '0';
		ld_ct_pd <= '1' when (ep=e1 or ep=e3 or ep=e6) else '0';
		dcr_ct_pd <= '1' when (ep=e2 or ep=e4) else '0';
		dcr_ct_bt <= '1' when ep=e5 else '0';
		ld_ct_bt <= '1' when (ep=e3 ) else '0';
		desp_der <= '1' when (ep=e3 or ep=e5)  else '0';
		ready <= '1' when ep=e8 else '0'; 

end arquitecturaUCmodulo1;
