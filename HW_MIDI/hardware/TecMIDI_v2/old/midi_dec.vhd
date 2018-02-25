LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity midi_dec is
	port (
		clk,reset	: in std_logic;
		Dato 			: in std_logic_vector(7 downto 0);
		ready			: in std_logic;
		key 			: out std_logic_vector(6 downto 0);
		vel 			: out std_logic_vector(6 downto 0);
		keyon			: out std_logic;
		keyoff		: out std_logic	);

end midi_dec;

architecture a of midi_dec is
-- estados presente y siguiente de la uc
	type  estado is (idle, ldcmd, waitkey, ldkey, waitvel, ldvel, kon, koff, waitready);
	signal est_p, est_s		: estado;
-- registros para comando, tecla y velocidad
	signal onoff				: std_logic;
	signal rkey, rvel			: std_logic_vector (6 downto 0);
	signal ld_cmd, ld_key, ld_vel	: std_logic;
-- info UP
	signal note			: std_logic;
	signal data			: std_logic;

begin
-- ==================================================
-- unidad de control
-- calculo de estado siguiente -------------------------
	process(est_p, ready, note, onoff,data)
	begin
		case est_p is
			when idle	=>
				if ready = '1' and note = '1' then		est_s <= ldcmd;
				else 						         			est_s <= idle;
				end if;
			when ldcmd =>	                     		est_s <= waitkey;
			when waitkey	=>
				if ready = '0' then							est_s <= waitkey;
				else 						            		est_s <= ldkey;
				end if;
			when ldkey =>	                     		est_s <= waitvel;
			when waitvel	=>
				if ready = '0' then							est_s <= waitvel;
				else 						            		est_s <= ldvel;
				end if;
			when ldvel =>
				if onoff = '1' then							est_s <= kon;
				else 						            		est_s <= koff;
				end if;
			when kon =>	                     			est_s <= waitready;
			when koff =>	                     		est_s <= waitready;
			when waitready	=>
				if ready = '0' then							est_s <= waitready;
				elsif data = '1' then						est_s <= ldkey;
				elsif note = '1' then						est_s <= ldcmd;
				else 						         			est_s <= idle;
				end if;
		end case;
	end process;
-- almacenamiento de estado presente --------------
	process (clk, reset)
	begin
		if (reset = '1') then
			est_p <= idle;
		elsif (clk'event and clk = '1') then
			est_p <= est_s;
		end if;
	end process;
-- señales de control --------------------------------
	ld_cmd	<= '1' when est_p=ldcmd						else '0';
	ld_key	<= '1' when est_p=ldkey						else '0';
	ld_vel	<= '1' when est_p=ldvel						else '0';
	keyon		<= '1' when est_p=kon						else '0';
	keyoff	<= '1' when est_p=koff						else '0';
-- ==================================================
-- unidad de proceso
-- registros para comando, tecla y velocidad
	process (clk, reset)
	begin
		if (reset = '1') then
			onoff <= '0';
			rkey <= (others => '0');
			rvel <= (others => '0');
		elsif (clk'event and clk='1') then 
			if (ld_cmd = '1') then
				onoff <= Dato(4);
			end if;
			if (ld_key = '1') then
				rkey <= Dato(6 downto 0);
			end if;
			if (ld_vel = '1') then
				rvel <= Dato(6 downto 0);
			end if;
		end if;
	end process;
-- info UP
	note <= '1' when Dato(7 downto 5) = "100"		else '0';
	data <= '1' when Dato(7) = '0'					else '0';
-- salidas
	key <= rkey;
	vel <= rvel;

	end a;
