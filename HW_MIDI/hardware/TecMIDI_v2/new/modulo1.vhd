LIBRARY ieee  ; 
USE ieee.std_logic_1164.all  ; 
use ieee.numeric_std.all;

entity modulo1 is
	port(
		--Entradas y salidas de la cajita

		reset, clk: in std_logic;
		midi_rx : in std_logic;
		ready :out std_logic;
		code: out unsigned (7 downto 0)
	);
end modulo1;

architecture arquitecturaUPmodulo1 of modulo1 is

	--Unidad de control
	component UCmodulo1 is
		port (
    			--lista de entradas y salidas de la UC: reset, clk etc
			reset, clk: in std_logic;
			midi_rx, fin_ct_pd, fin_ct_bt, stop_bit : in std_logic;
			ready, sel_pd, dcr_ct_pd, ld_ct_pd, ld_ct_bt, dcr_ct_bt, desp_der : out std_logic
  		);
	end component;

	--Señales internas que tenemos que conectar entre la UC y la UP
	signal sel_pd, dcr_ct_pd, ld_ct_pd, ld_ct_bt, dcr_ct_bt, desp_der : std_logic;
	signal fin_ct_pd, fin_ct_bt, stop_bit : std_logic;
	signal stop_bit_aux : std_logic;
	signal code_aux : unsigned (9 downto 0);

	signal value_bt : unsigned (3 downto 0) := "0000";
	signal value_pd : unsigned (11 downto 0) := "000000000000";
	
	signal mux_value: unsigned (11 downto 0) := x"010";
	

	begin

		UC : UCmodulo1
			port map(
				reset => reset, clk => clk, fin_ct_pd => fin_ct_pd,
				stop_bit => stop_bit, fin_ct_bt => fin_ct_bt,
				midi_rx => midi_rx, ready=> ready, sel_pd => sel_pd,
				dcr_ct_pd => dcr_ct_pd, ld_ct_pd => ld_ct_pd, 
				ld_ct_bt => ld_ct_bt, dcr_ct_bt => dcr_ct_bt,
				desp_der=> desp_der

			);
		
		--registro de desplazamiento
		process(clk, reset,desp_der)
			begin
				if reset='1' then code_aux(9 downto 0)<="0000000000";
				elsif (clk'event) and (clk='1')  then
					if (desp_der='1') then
						code_aux(8 downto 0) <= code_aux( 9 downto 1);
						code_aux(9) <= midi_rx;
						--code( 7 downto 0) <= code_aux (8 downto 1);
					end if;
				end if;
		end process;

		code( 7 downto 0) <= code_aux (8 downto 1);

		--registro de contador byte
		process(clk,reset,dcr_ct_bt,ld_ct_bt)
			begin
				if (reset='1')  then value_bt<=x"8";
				elsif (clk'event) and (clk='1') then
					if (ld_ct_bt='1') then value_bt<=x"8";
					elsif (dcr_ct_bt='1')  then 
						value_bt<=value_bt-1;
						
					end if;
				end if;
		end process;
		
		fin_ct_bt<='1' WHEN  (value_bt= x"0" or value_bt= x"F") else '0';

		--sincronizamos en cuanto este el dato, no cuando termine el ciclo de reloj
		stop_bit<=code_aux(9);
		
		--mux de periodo
		process(sel_pd)
			begin
				if sel_pd='0' then mux_value<=x"63F"; --640
				else mux_value<=x"31F"; --320
				end if;
				
		end process;

		--registro de contador de periodo
		
		process(clk,reset)
			begin
				if (reset='1')  then value_pd<=x"320";
				elsif (clk'event) and (clk='1') then
					if (ld_ct_pd='1') then value_pd<=mux_value;
					elsif (dcr_ct_pd='1')  then value_pd<=value_pd-1;
					end if;
				end if;
		end process;

		fin_ct_pd<='1' WHEN  value_pd="000000000000" else '0';

end arquitecturaUPmodulo1;
