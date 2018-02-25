	component Lab2_TecMIDI_system is
		port (
			clk_clk            : in    std_logic                     := 'X';             -- clk
			leds_export        : out   std_logic_vector(7 downto 0);                     -- export
			pll_0_sdram_clk    : out   std_logic;                                        -- clk
			reset_reset_n      : in    std_logic                     := 'X';             -- reset_n
			rxdecmidi_export   : in    std_logic                     := 'X';             -- export
			sdram_addr         : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_ba           : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_cas_n        : out   std_logic;                                        -- cas_n
			sdram_cke          : out   std_logic;                                        -- cke
			sdram_cs_n         : out   std_logic;                                        -- cs_n
			sdram_dq           : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_dqm          : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_ras_n        : out   std_logic;                                        -- ras_n
			sdram_we_n         : out   std_logic;                                        -- we_n
			switches_export    : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
			aud_daclrck_export : in    std_logic                     := 'X';             -- export
			aud_bclk_export    : in    std_logic                     := 'X';             -- export
			aud_dacdat_export  : out   std_logic                                         -- export
		);
	end component Lab2_TecMIDI_system;

	u0 : component Lab2_TecMIDI_system
		port map (
			clk_clk            => CONNECTED_TO_clk_clk,            --         clk.clk
			leds_export        => CONNECTED_TO_leds_export,        --        leds.export
			pll_0_sdram_clk    => CONNECTED_TO_pll_0_sdram_clk,    -- pll_0_sdram.clk
			reset_reset_n      => CONNECTED_TO_reset_reset_n,      --       reset.reset_n
			rxdecmidi_export   => CONNECTED_TO_rxdecmidi_export,   --   rxdecmidi.export
			sdram_addr         => CONNECTED_TO_sdram_addr,         --       sdram.addr
			sdram_ba           => CONNECTED_TO_sdram_ba,           --            .ba
			sdram_cas_n        => CONNECTED_TO_sdram_cas_n,        --            .cas_n
			sdram_cke          => CONNECTED_TO_sdram_cke,          --            .cke
			sdram_cs_n         => CONNECTED_TO_sdram_cs_n,         --            .cs_n
			sdram_dq           => CONNECTED_TO_sdram_dq,           --            .dq
			sdram_dqm          => CONNECTED_TO_sdram_dqm,          --            .dqm
			sdram_ras_n        => CONNECTED_TO_sdram_ras_n,        --            .ras_n
			sdram_we_n         => CONNECTED_TO_sdram_we_n,         --            .we_n
			switches_export    => CONNECTED_TO_switches_export,    --    switches.export
			aud_daclrck_export => CONNECTED_TO_aud_daclrck_export, -- aud_daclrck.export
			aud_bclk_export    => CONNECTED_TO_aud_bclk_export,    --    aud_bclk.export
			aud_dacdat_export  => CONNECTED_TO_aud_dacdat_export   --  aud_dacdat.export
		);

