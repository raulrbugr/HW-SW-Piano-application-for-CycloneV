
module Lab2_TecMIDI_system (
	clk_clk,
	leds_export,
	pll_0_sdram_clk,
	reset_reset_n,
	rxdecmidi_export,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	switches_export,
	aud_daclrck_export,
	aud_bclk_export,
	aud_dacdat_export);	

	input		clk_clk;
	output	[7:0]	leds_export;
	output		pll_0_sdram_clk;
	input		reset_reset_n;
	input		rxdecmidi_export;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[15:0]	sdram_dq;
	output	[1:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	input	[7:0]	switches_export;
	input		aud_daclrck_export;
	input		aud_bclk_export;
	output		aud_dacdat_export;
endmodule
