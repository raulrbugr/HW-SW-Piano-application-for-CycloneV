
LIBRARY ieee  ; 
USE ieee.std_logic_1164.all  ; 
use ieee.numeric_std.all;
use work.sin256rom_pkg.all;


entity sin_DDS is
	port(
		--Entradas y salidas de la cajita
		reset, clk: in std_logic;
		nextsample, enable : in std_logic;
		vel, key: in unsigned (6 downto 0);
		sample : out signed (15 downto 0)

	);
end sin_DDS;

architecture arquitecturasin_DDS of sin_DDS is

	
	--Se�ales internas que tenemos que conectar entre la UC y la UP
	
	signal delta : unsigned (15 downto 0);
	signal ld : std_logic;
	signal Q : unsigned (15 downto 0) ;
	signal dat: unsigned (15 downto 0) ;
	signal addr : integer range 0 to 255;
	signal dat_rom : signed( 15 downto 0);
	signal dat_x : signed (15 downto 0);
		
	begin
		
		
		process(clk, reset,key)
		begin
			case key is
  				when "0111100" =>   delta <= "0000100000111011"; --60
  				when "0111101" =>   delta <= "0000100010111000";
				when "0111110" =>   delta <= "0000100100111101";
				when "0111111" =>   delta <= "0000100111001010";
				when "1000000" =>   delta <= "0000101001011111";
				when "1000001" =>   delta <= "0000101011111100";
				when "1000010" =>   delta <= "0000101110100100";
				when "1000011" =>   delta <= "0000110001010101";
				when "1000100" =>   delta <= "0000110100010000";
				when "1000101" =>   delta <= "0000110111010111";
				when "1000110" =>   delta <= "0000111010101010";
				when "1000111" =>   delta <= "0000111110001001"; --71
 				when others =>  delta <= X"0000";
			end case;
		end process;

		ld <= '1' when (nextsample='1' and enable='1') else '0';
		dat <= delta + Q;
		process(clk, reset)
			begin
			if (reset='1')  then Q<=X"0000";
			elsif (clk'event) and (clk='1') then
				if ld ='1' then 
					--dat <= delta + Q;
					Q <= dat;
				end if;
			end if;
		end process;
		
		addr <= to_integer(Q(15 downto 8));

		dat_rom <= sin256rom(addr);
		
		dat_x <= resize(shift_right(dat_rom * signed('0' & vel), 7), 16);

		process(clk, reset,enable)
			begin
				if (enable ='1') then sample <=dat_x;
				else sample <=X"0000";
			end if;
		end process;

end arquitecturasin_DDS;