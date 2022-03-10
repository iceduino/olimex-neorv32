-- #################################################################################################
-- # << NEORV32 - Setup for the Iceduino Board >>
-- # Schematics available at https://github.com/olimex/olimex                                  #
-- # ********************************************************************************************* #
-- # BSD 3-Clause License                                                                          #
-- #                                                                                               #
-- # Copyright (c) 2021, Patryk Janik, Christopher Parnow. All rights reserved.                    #
-- #                                                                                               #
-- # Redistribution and use in source and binary forms, with or without modification, are          #
-- # permitted provided that the following conditions are met:                                     #
-- #                                                                                               #
-- # 1. Redistributions of source code must retain the above copyright notice, this list of        #
-- #    conditions and the following disclaimer.                                                   #
-- #                                                                                               #
-- # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
-- #    conditions and the following disclaimer in the documentation and/or other materials        #
-- #    provided with the distribution.                                                            #
-- #                                                                                               #
-- # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
-- #    endorse or promote products derived from this software without specific prior written      #
-- #    permission.                                                                                #
-- #                                                                                               #
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
-- # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
-- # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
-- # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
-- # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
-- # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
-- # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
-- # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
-- # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
-- # ********************************************************************************************* #
-- # The NEORV32 Processor - https://github.com/stnolting/neorv32              (c) Stephan Nolting #
-- #################################################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library olimex;

entity neorv32_olimex_top_tb is
end entity;

architecture neorv32_olimex_top_behave of neorv32_olimex_top_tb is

  signal clk : std_ulogic := '0';

begin

  clk <= not clk after 10 ns; -- 50 MHz

  neorv32_olimex_inst: entity olimex.neorv32_olimex_top_sim
  port map (
    SYSCLK  => clk,
    LED     => open,    
    BTN     => "00",
    PIO3_00 => open,
    PIO3_01 => open,
    PIO3_02 => open,
    PIO3_03 => open,
    PIO3_04 => open,
    PIO3_05 => open,
    PIO3_06 => open,
    PIO3_07 => open,
    PIO3_08 => open,
    PIO3_09 => open,
    PIO3_10 => open,
    PIO3_11 => open,
    PIO3_12 => open,
    PIO3_13 => open,
    PIO3_14 => open,
    PIO3_15 => open,
    PIO3_16 => open,
    PIO3_17 => open,
    PIO3_18 => open,
    PIO3_19 => open,
    PIO3_20 => open,
    PIO3_21 => open,
    PIO3_22 => open,
    PIO3_23 => open,
    PIO3_24 => open,
    PIO3_25 => open,
    PIO3_27 => open,
    PIO3_28 => open,
    --SPI
    SDO => open,
    SDI => '0',
    SCK => open,
    SS_B => open,
    --UART
    RxD => '1',
    TxD => open,
    --SRAM
    SRAM_CS => open,
    SRAM_OE => open,
    SRAM_WE => open,
    SA => open,
    SD => open
  );


    
end architecture;
