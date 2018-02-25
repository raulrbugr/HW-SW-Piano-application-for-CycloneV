
-- Ejemplo de un perifericos de usuario con PWM:
--
-- Inputs: SW7¡0 are parallel port inputs to the Nios II system.
-- CLOCK_50 is the system clock.
-- KEY0 is the active-low system reset.
-- Outputs: LEDR7¡0 are parallel port outputs from the Nios II system.
-- used in the DE1-SoC User Manual.
---------------------------------------------------------------
--- Realizado por: M.S & R.R.
--- Fecha: 20/2/2018
--
--- Version: V0.0  Sistema de procesamiento de señales de sonido
---------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY Top_Lab2_v1 IS
	PORT (
		CLOCK_50 : IN STD_LOGIC;
		KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		LEDR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		SW : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		
		DRAM_DQ : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		DRAM_ADDR : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
		DRAM_BA : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		DRAM_CAS_N, DRAM_RAS_N, DRAM_CLK : OUT STD_LOGIC;
		DRAM_CKE, DRAM_CS_N, DRAM_WE_N : OUT STD_LOGIC;
		DRAM_UDQM, DRAM_LDQM: OUT STD_LOGIC;
		
		RX_MIDI 		: in	std_logic;
			-- CODEC Audio ----------------
		AUD_ADCDAT	: in	std_logic;
		AUD_ADCLRCK	: in	std_logic;
		AUD_BCLK	: in	std_logic;
		AUD_DACDAT	: out	std_logic;
		AUD_DACLRCK	: in	std_logic;
		AUD_XCK		: out	std_logic;

		-- I2C for Audio and Video-In ----------------
		FPGA_I2C_SCLK	: out	std_logic;
		FPGA_I2C_SDAT	: inout	std_logic
		
		);
END Top_Lab2_v1;

ARCHITECTURE Structure1 OF Top_Lab2_v1 IS
  
   signal reset : std_logic;
 
   signal reset_n : std_logic;
 
	signal byte : std_logic_vector(7 downto 0);
 	signal ready : std_logic;
 	signal ack : std_logic;
	signal dig1, dig0 : std_logic_vector(6 downto 0);
	signal r0, r1, r2 : std_logic_vector(13 downto 0);



    component Lab2_TecMIDI_system is
        port (
            clk_clk          : in    std_logic                     := 'X';             -- clk
            leds_export      : out   std_logic_vector(7 downto 0);                     -- export
            pll_0_sdram_clk  : out   std_logic;                                        -- clk
            reset_reset_n    : in    std_logic                     := 'X';             -- reset_n
            rxdecmidi_export : in    std_logic                     := 'X';             -- export
            sdram_addr       : out   std_logic_vector(12 downto 0);                    -- addr
            sdram_ba         : out   std_logic_vector(1 downto 0);                     -- ba
            sdram_cas_n      : out   std_logic;                                        -- cas_n
            sdram_cke        : out   std_logic;                                        -- cke
            sdram_cs_n       : out   std_logic;                                        -- cs_n
            sdram_dq         : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            sdram_dqm        : out   std_logic_vector(1 downto 0);                     -- dqm
            sdram_ras_n      : out   std_logic;                                        -- ras_n
            sdram_we_n       : out   std_logic;                                        -- we_n
            switches_export  : in    std_logic_vector(7 downto 0)  := (others => 'X');  -- export
				aud_daclrck_export : in 	std_logic;
				aud_bclk_export	: in		std_logic;
				aud_dacdat_export		: out		std_logic
        );
    end component Lab2_TecMIDI_system;
	 
	 component au_setup IS 
			port
			(	reset		   :  IN STD_LOGIC;
				clk_50 		:  IN STD_LOGIC;
				mic_lin		:  IN STD_LOGIC; -- si '1' MIC, si '0' LINEIN
				i2c_sdat	   :  INOUT STD_LOGIC;
				i2c_sclk	   :  OUT STD_LOGIC;
				aud_xck		:  OUT STD_LOGIC	);
		END component;
		
		signal mic_lin : std_logic := '0';

 
	
BEGIN
	    --reset <= not(KEY(0));
	    --reset_n <= KEY(0);

     u0 : component Lab2_TecMIDI_system
        port map (
            clk_clk          => CLOCK_50,          --        clk.clk
            leds_export      => LEDR(7 downto 0),      --       leds.export
            rxdecmidi_export => RX_MIDI, -- rx_uart_conduit_end.export
            reset_reset_n    => KEY(0),    --      reset.reset_n
            sdram_addr  => DRAM_ADDR,  -- sdram_wire.addr
            sdram_ba    => DRAM_BA,    --           .ba
            sdram_cas_n => DRAM_CAS_N, --           .cas_n
            sdram_cke   => DRAM_CKE,   --           .cke
            sdram_cs_n  => DRAM_CS_N,  --           .cs_n
            sdram_dq    => DRAM_DQ,    --           .dq
            sdram_dqm(1) => DRAM_UDQM,   --           .dqm
            sdram_dqm(0) => DRAM_LDQM,   --           .dqm
            sdram_ras_n => DRAM_RAS_N, --           .ras_n
            sdram_we_n  => DRAM_WE_N,   --           .we_n
            switches_export  => SW,  --   switches.export
            pll_0_sdram_clk  => DRAM_CLK,     --  sdram_clk.clk
				aud_daclrck_export  => AUD_DACLRCK,
				aud_bclk_export  => AUD_BCLK,
				aud_dacdat_export  => AUD_DACDAT
        );
		  
		u1	:	 au_setup
			port map (
					reset => reset,
					clk_50 => clock_50,
					mic_lin => mic_lin,
					i2c_sdat => fpga_i2c_sdat,
					i2c_sclk => fpga_i2c_sclk,
					aud_xck => aud_xck
				);

		  
END Structure1;
