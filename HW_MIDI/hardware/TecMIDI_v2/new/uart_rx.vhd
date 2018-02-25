----------------------
--  uart_rx.vhd
----------------------
--	Recepcion asincrona por una linea serie UART (RX) de un dato de 8 bits (BYTE)
--	con 1 bit de start ('0') y 1 bit de stop ('1') empezando por el bit de menos peso.
-- Al acabar la recepcion de un byte se activa la salida READY duranate un ciclo de reloj
-------------------------------------------------------------------
--	Andoni Arruti
--------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
	generic(
		BAUD_RATE : natural := 9600;
		CLK_FREQ : natural := 50000000);
	port(
		clk,reset	: in std_logic;
		rx				: in std_logic;
		ack			: in std_logic;
		byte			: out std_logic_vector(7 downto 0);
		ready			: out std_logic);
end uart_rx;

architecture a of uart_rx is
	constant CICLOS_BIT : natural := CLK_FREQ/BAUD_RATE;
	constant CICLOS_MBIT : natural := CICLOS_BIT/2;
-- estados presente y siguiente de la uc
	type  state is (idle, wait0, cltmp, waitbit, readbit, recend);
	signal st, next_st	: state;
-- sincronizacion de rx y deteccion de flanco de bajada	
	signal rxd		: std_logic;
	signal rxdd		: std_logic;
	signal rxdown	: std_logic;
-- registro de desplazamiento para recepcion de dato
	signal srbyte		: std_logic_vector(7 downto 0);
	signal sh_right	: std_logic;
-- contador de bits recibidos
	signal cbits		: integer range 0 to 8;
	signal cl_bits		: std_logic;
	signal inc_bits	: std_logic;
	signal lastbit		: std_logic;
-- contador de tiempo por bit
	signal ctmp			: integer range 0 to CICLOS_BIT-2 ;
	signal cl_tmp		: std_logic;
	signal inc_tmp		: std_logic;
	signal tmp0			: std_logic;
	signal tmpbit		: std_logic;
-- JK para señal ready
	signal jkready		: std_logic;
	signal ready_0		: std_logic;
	signal ready_1		: std_logic;

begin
-- ==================================================
-- unidad de control
-- calculo de estado siguiente -------------------------
	process(st, rxdown, tmp0, tmpbit, lastbit, rxd)
	begin
		case st is
			when idle	=>
				if rxdown = '1' then				next_st <= wait0;
				else									next_st <= idle;
				end if;
			when wait0 =>
				if tmp0 = '0' then				next_st <= wait0;
				elsif rxd = '1' then				next_st <= idle;
				else									next_st <= cltmp;
				end if;
			when cltmp =>							next_st <= waitbit;
			when waitbit =>
				if tmpbit = '0' then				next_st <= waitbit;
				elsif lastbit = '0' then		next_st <= readbit;
				elsif rxd = '1' then				next_st <= recend;
				else									next_st <= idle;
				end if;
			when readbit =>						next_st <= cltmp;
			when recend =>							next_st <= idle;
		end case;
	end process;
-- almacenamiento de estado presente --------------
	process (clk, reset)
	begin
		if (reset = '1') then
			st <= idle;
		elsif (clk'event and clk = '1') then
			st <= next_st;
		end if;
	end process;
-- señales de control --------------------------------
	cl_bits	<= '1' when st = idle							else '0';
	cl_tmp	<= '1' when st = idle	or st = cltmp		else '0';
	inc_tmp	<= '1' when st = wait0	or st = waitbit	else '0';
	sh_right	<= '1' when st = readbit						else '0';
	inc_bits	<= sh_right;
	ready_0	<= sh_right;
	ready_1	<= '1' when st = recend							else '0';
-- ==================================================
-- unidad de proceso
-- biestables d para sincronizacion y deteccion de flanco en rx --
	process (clk, reset)
	begin
		if (reset = '1') then
			rxd <= '0';
			rxdd <= '0';
		elsif (clk'event and clk = '1') then
			rxdd <= rxd;
			rxd <= rx;
		end if;
	end process;
	rxdown <= '1' when (rxd='0' and rxdd='1')	else '0';
-- registro de desplazamiento -------------------------
	process (clk, reset)
	begin
		if (reset = '1') then
			srbyte <= x"00";
		elsif (clk'event and clk='1') then 
			if (sh_right = '1') then
				srbyte <= rxd & srbyte(7 downto 1);
			end if;
		end if;
	end process;
	byte	<=	srbyte(7 downto 0);
-- contador de ciclos -------------------------
	process (clk, reset)
	begin
		if (reset = '1') then
			ctmp <= 0;
		elsif (clk'event and clk = '1') then
			if (cl_tmp = '1') then
				ctmp <= 0;
			elsif (inc_tmp = '1') then
				ctmp <= ctmp + 1;
			end if;
		end if;
	end process;
	tmp0	<=	'1' when ctmp = CICLOS_MBIT-2	else '0';
	tmpbit	<=	'1' when ctmp = CICLOS_BIT-3	else '0';
-- contador de bits -------------------------
	process (clk, reset)
	begin
		if (reset = '1') then
			cbits <= 0;
		elsif (clk'event and clk ='1') then
			if (cl_bits = '1') then
				cbits <= 0;
			elsif (inc_bits = '1') then
				cbits <= cbits + 1;
			end if;
		end if;
	end process;
	lastbit <= '1' when cbits = 8 else  '0';
-- jk para ready -------------------------
	process (clk, reset)
	begin
		if (reset = '1') then
			jkready <= '0';
		elsif (clk'event and clk ='1') then
			if (ready_1 = '1') then
				jkready <= '1';
			elsif (ready_0 = '1' or ack = '1') then
				jkready <= '0';
			end if;
		end if;
	end process;
	ready <= jkready;
end a;

