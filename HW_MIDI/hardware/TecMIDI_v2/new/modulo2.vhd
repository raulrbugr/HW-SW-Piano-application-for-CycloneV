LIBRARY ieee  ; 
USE ieee.std_logic_1164.all  ; 
use ieee.numeric_std.all;

entity modulo2 is
	port(
		--Entradas y salidas de la cajita

		reset, clk: in std_logic;
		ready,ack :in std_logic;
		code: in unsigned (7 downto 0);
		n_on, n_off : out std_logic;
		key, vel : out unsigned (6 downto 0)
	);
end modulo2;

architecture arquitecturaUPmodulo2 of modulo2 is

	--Unidad de control
	component UCmodulo2 is
 		 port (
    		--lista de entradas y salidas de la UC: reset, clk etc
			reset, clk: in std_logic;
			ready, tipo1,C4, ack,code7 : in std_logic;
			ld_key, ld_code, ld_vel : out std_logic;
			n_on, n_off : out std_logic
	
  		);
	end component;

	--Se?ales internas que tenemos que conectar entre la UC y la UP
	signal tipo1,tipo1_aux,c4,code7 : std_logic;
	signal ld_key, ld_code, ld_vel : std_logic;
	signal code_reg : unsigned (3 downto 0) := x"0";

	begin

		UC : UCmodulo2
			port map(
				clk=>clk,reset=>reset,
				ready=>ready,tipo1=>tipo1,c4=>c4,ack=>ack,code7=>code7,
				ld_key=>ld_key,ld_code=>ld_code,ld_vel=>ld_vel,
				n_on=>n_on,n_off=>n_off

			);

		--Registro ON/OFF
		
		process(clk, reset)
			begin
				if (clk'event) and (clk='1')  then
					if ld_code='1' then 
						code_reg (3 downto 0) <= code(7 downto 4);
					end if;
				end if;
		end process;
		
		tipo1 <= '1' when (code_reg(3 downto 1)= "100") else '0';
		C4 <= code_reg(0);

		--Registro Key
		process(clk, reset,ld_key)
			begin
				if reset='1' then key<="0000000";
				elsif (clk'event) and (clk='1') then
					if ld_key='1'  then  key(6 downto 0)<=code(6 downto 0);
					end if;
				end if;
		end process;

		--Registro Vel
		
		process(clk, reset,ld_vel)
			begin
				if reset='1' then vel<="0000000";
				elsif (clk'event) and (clk='1') then
					if ld_vel='1'  then vel(6 downto 0)<=code(6 downto 0);
					end if;
				end if;
		end process;
 
		code7<='1' WHEN code(7)='1' else '0';


end arquitecturaUPmodulo2;

