	Lab2_TecMIDI_system u0 (
		.clk_clk            (<connected-to-clk_clk>),            //         clk.clk
		.leds_export        (<connected-to-leds_export>),        //        leds.export
		.pll_0_sdram_clk    (<connected-to-pll_0_sdram_clk>),    // pll_0_sdram.clk
		.reset_reset_n      (<connected-to-reset_reset_n>),      //       reset.reset_n
		.rxdecmidi_export   (<connected-to-rxdecmidi_export>),   //   rxdecmidi.export
		.sdram_addr         (<connected-to-sdram_addr>),         //       sdram.addr
		.sdram_ba           (<connected-to-sdram_ba>),           //            .ba
		.sdram_cas_n        (<connected-to-sdram_cas_n>),        //            .cas_n
		.sdram_cke          (<connected-to-sdram_cke>),          //            .cke
		.sdram_cs_n         (<connected-to-sdram_cs_n>),         //            .cs_n
		.sdram_dq           (<connected-to-sdram_dq>),           //            .dq
		.sdram_dqm          (<connected-to-sdram_dqm>),          //            .dqm
		.sdram_ras_n        (<connected-to-sdram_ras_n>),        //            .ras_n
		.sdram_we_n         (<connected-to-sdram_we_n>),         //            .we_n
		.switches_export    (<connected-to-switches_export>),    //    switches.export
		.aud_daclrck_export (<connected-to-aud_daclrck_export>), // aud_daclrck.export
		.aud_bclk_export    (<connected-to-aud_bclk_export>),    //    aud_bclk.export
		.aud_dacdat_export  (<connected-to-aud_dacdat_export>)   //  aud_dacdat.export
	);

