-- #################################################################################################
-- # << NEORV32 - Setup for the Iceduino Board >>
-- # Schematics available at https://github.com/iceduino/iceduino                                  #
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

library iCE40;
use iCE40.components.all; -- for device primitives and macros

library olimex;

library neorv32;
use neorv32.neorv32_package.all; -- for device primitives and macros

entity neorv32_olimex_top is
port (
    SYSCLK : in  std_logic; -- external 100MHz Clock
    LED : out std_ulogic_vector(1 downto 0);  -- Onboard LEDs  
    BTN : in std_ulogic_vector(1 downto 0); --Onboard Buttons
    --GPIO
    PIO3_00 : inout std_ulogic; 
    PIO3_01 : inout std_ulogic;
    PIO3_02 : inout std_ulogic;
    PIO3_03 : inout std_ulogic;
    PIO3_04 : inout std_ulogic;
    PIO3_05 : inout std_ulogic;
    PIO3_06 : inout std_ulogic;
    PIO3_07 : inout std_ulogic;
    PIO3_08 : inout std_ulogic;
    PIO3_09 : inout std_ulogic;
    PIO3_10 : inout std_ulogic;
    PIO3_11 : inout std_ulogic;
    PIO3_12 : inout std_ulogic;
    PIO3_13 : inout std_ulogic;
    PIO3_14 : inout std_ulogic;
    PIO3_15 : inout std_ulogic;
    PIO3_16 : inout std_ulogic;
    PIO3_17 : inout std_ulogic;
    PIO3_18 : inout std_ulogic;
    PIO3_19 : inout std_ulogic;
    PIO3_20 : inout std_ulogic;
    PIO3_21 : inout std_ulogic;
    PIO3_22 : inout std_ulogic;
    PIO3_23 : inout std_ulogic;
    PIO3_24 : inout std_ulogic;
    PIO3_25 : inout std_ulogic;
    PIO3_27 : inout std_ulogic;
    PIO3_28 : inout std_ulogic;
    --SPI
    SDO : out std_ulogic;
    SDI : in std_ulogic;
    SCK : out std_ulogic;
    SS_B : out std_ulogic;
    --UART
    RxD : in std_ulogic;
    TxD : out std_ulogic;
    --SRAM
    SRAM_CS : out std_ulogic;
    SRAM_OE : out std_ulogic;
    SRAM_WE : out std_ulogic;
    SA : out std_ulogic_vector(17 downto 0);
    SD : out std_ulogic_vector(15 downto 0)
);
end entity;

architecture neorv32_olimex_top_rtl of neorv32_olimex_top is

-- configuration --
constant f_clock_c : natural := 50000000; -- clock frequency in Hz
signal pll_rstn : std_logic;
signal pll_clk  : std_logic;
signal con_reset : std_logic;
--internal IO connection
signal con_txd_o  : std_ulogic:='1';
signal con_rxd_i  : std_ulogic:='1';
signal con_sck : std_ulogic;
signal con_ss : std_ulogic_vector(7 downto 0);
signal con_sdo : std_ulogic;
signal con_sdi : std_ulogic;


signal con_gpio_o  : std_ulogic_vector(63 downto 0):=(others => '0');

-- bus_wishbone --
type bus_wishbone_t is record
    tag_o       : std_ulogic_vector(02 downto 0); -- request tag
    adr_o       : std_ulogic_vector(31 downto 0); -- address      
    dat_o       : std_ulogic_vector(31 downto 0); -- write data
    we_o        : std_ulogic; -- read/write
    sel_o       : std_ulogic_vector(03 downto 0); -- byte enable
    stb_o       : std_ulogic; -- strobe
    cyc_o       : std_ulogic; -- valid cycle
    lock_o      : std_ulogic; -- exclusive access request      
end record;    
signal master_bus : bus_wishbone_t;	
-- bus_wishbone slave response  --
type slave_resp_t is record
    rdata_i : std_ulogic_vector(31 downto 0);
    ack_i   : std_ulogic;
    err_i   : std_ulogic;
end record;
constant slave_resp_default : slave_resp_t := (rdata_i => (others => '0'), ack_i => '0', err_i => '0');
signal active_slave_resp : slave_resp_t := slave_resp_default;
signal led_resp : slave_resp_t := slave_resp_default;



begin
    --icepll -i 100 -o 50
    Pll_inst : SB_PLL40_CORE
    generic map (
        FEEDBACK_PATH => "SIMPLE",
        DIVR          => x"0",
        DIVF          => "0000111",
        DIVQ          => "100",
        FILTER_RANGE  => "101"
    )
    port map (
        REFERENCECLK    => SYSCLK,
        PLLOUTCORE      => open,
        PLLOUTGLOBAL    => pll_clk,
        EXTFEEDBACK     => '0',
        DYNAMICDELAY    => x"00",
        LOCK            => pll_rstn,
        BYPASS          => '0',
        RESETB          => '1',
        LATCHINPUTVALUE => '0',
        SDO             => open,
        SDI             => '0',
        SCLK            => '0'
    );
    
    process(pll_clk) is
    variable cnt : unsigned(7 downto 0) := (others => '0');
    begin
        if pll_rstn = '0' then
            cnt := to_unsigned(0, 8); 
        elsif rising_edge(pll_clk) then
            if cnt < 255 then
                cnt := cnt + 1;
                con_reset <= '0';
            else
                con_reset <= '1';
            end if;
        end if;
    end process;
    
     -- external bus multiplexer --
    bus_multiplexer: process(master_bus, led_resp)
    begin
        active_slave_resp.rdata_i <= (others => '0');
        active_slave_resp.ack_i <= '0';
        active_slave_resp.err_i <= '0';
        if(master_bus.adr_o(31 downto 8) = x"F00000") then
            case master_bus.adr_o(7 downto 0) is
                when x"00" =>
                        active_slave_resp.rdata_i <= led_resp.rdata_i; 
                        active_slave_resp.ack_i <= led_resp.ack_i;
                        active_slave_resp.err_i <= led_resp.err_i;
                when others =>
                        active_slave_resp.rdata_i <= (others => '0');
                        active_slave_resp.ack_i <= '0';
                        active_slave_resp.err_i <= '0';
            end case;
        end if;
    end process;

    -- NEORV32 instance
    neorv32_inst: neorv32_top
    generic map (
    -- General --
    CLOCK_FREQUENCY              => f_clock_c,          -- clock frequency of clk_i in Hz
    HW_THREAD_ID                 => 0,     -- hardware thread id (32-bit)
    INT_BOOTLOADER_EN            => true,  -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
    -- On-Chip Debugger (OCD) --
    ON_CHIP_DEBUGGER_EN          => false,  -- implement on-chip debugger
    -- RISC-V CPU Extensions --
    CPU_EXTENSION_RISCV_A        => false,  -- implement atomic extension?
    CPU_EXTENSION_RISCV_B        => false,  -- implement bit-manipulation extension?
    CPU_EXTENSION_RISCV_C        => false,  -- implement compressed extension?
    CPU_EXTENSION_RISCV_E        => false,  -- implement embedded RF extension?
    CPU_EXTENSION_RISCV_M        => false,  -- implement mul/div extension?
    CPU_EXTENSION_RISCV_U        => false,  -- implement user mode extension?
    CPU_EXTENSION_RISCV_Zfinx    => false,  -- implement 32-bit floating-point extension (using INT regs!)
    CPU_EXTENSION_RISCV_Zicsr    => true,   -- implement CSR system?
    CPU_EXTENSION_RISCV_Zicntr   => true,   -- implement base counters?
    CPU_EXTENSION_RISCV_Zihpm    => false,  -- implement hardware performance monitors?
    CPU_EXTENSION_RISCV_Zifencei => false,  -- implement instruction stream sync.?
    CPU_EXTENSION_RISCV_Zmmul    => false,  -- implement multiply-only M sub-extension?
    CPU_EXTENSION_RISCV_Zxcfu    => false,  -- implement custom (instr.) functions unit?
    -- Tuning Options --
    FAST_MUL_EN                  => false,  -- use DSPs for M extension's multiplier
    FAST_SHIFT_EN                => false,  -- use barrel shifter for shift operations
    CPU_CNT_WIDTH                => 64,     -- total width of CPU cycle and instret counters (0..64)
    CPU_IPB_ENTRIES              => 2,      -- entries is instruction prefetch buffer, has to be a power of 2
    -- Physical Memory Protection (PMP) --
    PMP_NUM_REGIONS              => 0,      -- number of regions (0..16)
    PMP_MIN_GRANULARITY          => 4,      -- minimal region granularity in bytes, has to be a power of 2, min 4 bytes
    -- Hardware Performance Monitors (HPM) --
    HPM_NUM_CNTS                 => 0,      -- number of implemented HPM counters (0..29)
    HPM_CNT_WIDTH                => 40,    --total size of HPM counters (0..64)
    -- Internal Instruction memory (IMEM) --
    MEM_INT_IMEM_EN              => true,  -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE            => 4*1024, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory (DMEM) --
    MEM_INT_DMEM_EN              => true,  -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE            => 2*1024, -- size of processor-internal data memory in bytes
    -- Internal Instruction Cache (iCACHE) --
    ICACHE_EN                    => false,  -- implement instruction cache
    ICACHE_NUM_BLOCKS            => 4,      -- i-cache: number of blocks (min 1), has to be a power of 2
    ICACHE_BLOCK_SIZE            => 64,     -- i-cache: block size in bytes (min 4), has to be a power of 2
    ICACHE_ASSOCIATIVITY         => 1,      -- i-cache: associativity / number of sets (1=direct_mapped), has to be a power of 2
    -- External memory interface (WISHBONE) --
    MEM_EXT_EN                   => true, -- implement external memory bus interface?
    MEM_EXT_TIMEOUT              => 255,    -- cycles after a pending bus access auto-terminates (0 = disabled)
    MEM_EXT_PIPE_MODE            => false,  -- protocol: false=classic/standard wishbone mode, true=pipelined wishbone mode
    MEM_EXT_BIG_ENDIAN           => false,  -- byte order: true=big-endian, false=little-endian
    MEM_EXT_ASYNC_RX             => false,  -- use register buffer for RX data when false
    -- Stream link interface (SLINK) --
    SLINK_NUM_TX                 => 0,      -- number of TX links (0..8)
    SLINK_NUM_RX                 => 0,      -- number of TX links (0..8)
    SLINK_TX_FIFO                => 1,      -- TX fifo depth, has to be a power of two
    SLINK_RX_FIFO                => 1,      -- RX fifo depth, has to be a power of two
    -- External Interrupts Controller (XIRQ) --
    XIRQ_NUM_CH                  => 0,      -- number of external IRQ channels (0..32)
    XIRQ_TRIGGER_TYPE            => x"FFFFFFFF", -- trigger type: 0=level, 1=edge
    XIRQ_TRIGGER_POLARITY        => x"FFFFFFFF", -- trigger polarity: 0=low-level/falling-edge, 1=high-level/rising-edge
    -- Processor peripherals --
    IO_GPIO_EN                   => false, -- implement general purpose input/output port unit (GPIO)?
    IO_MTIME_EN                  => true,  -- implement machine system timer (MTIME)?
    IO_UART0_EN                  => true,  -- implement primary universal asynchronous receiver/transmitter (UART0)?
    IO_UART0_RX_FIFO             => 1,      -- RX fifo depth, has to be a power of two, min 1
    IO_UART0_TX_FIFO             => 1,      -- TX fifo depth, has to be a power of two, min 1
    IO_UART1_EN                  => false,  -- implement secondary universal asynchronous receiver/transmitter (UART1)?
    IO_UART1_RX_FIFO             => 1,      -- RX fifo depth, has to be a power of two, min 1
    IO_UART1_TX_FIFO             => 1,      -- TX fifo depth, has to be a power of two, min 1
    IO_SPI_EN                    => true,  -- implement serial peripheral interface (SPI)?
    IO_TWI_EN                    => false,  -- implement two-wire interface (TWI)?
    IO_PWM_NUM_CH                => 0,      -- number of PWM channels to implement (0..60); 0 = disabled
    IO_WDT_EN                    => false,  -- implement watch dog timer (WDT)?
    IO_TRNG_EN                   => false,  -- implement true random number generator (TRNG)?
    IO_CFS_EN                    => false,  -- implement custom functions subsystem (CFS)?
    IO_CFS_CONFIG                => x"00000000", -- custom CFS configuration generic
    IO_CFS_IN_SIZE               => 32,    -- size of CFS input conduit in bits
    IO_CFS_OUT_SIZE              => 32,    -- size of CFS output conduit in bits
    IO_NEOLED_EN                 => false,  -- implement NeoPixel-compatible smart LED interface (NEOLED)?
    IO_NEOLED_TX_FIFO            => 1,      -- NEOLED TX FIFO depth, 1..32k, has to be a power of two
    IO_GPTMR_EN                  => false,  -- implement general purpose timer (GPTMR)?
    IO_XIP_EN                    => false   -- implement execute in place module (XIP)?
)port map (
    -- Global control --
    clk_i          => pll_clk, -- global clock, rising edge
    rstn_i         => con_reset, -- global reset, low-active, async
    -- JTAG on-chip debugger interface (available if ON_CHIP_DEBUGGER_EN = true) --
    jtag_trst_i    => 'U', -- low-active TAP reset (optional)
    jtag_tck_i     => 'U', -- serial clock
    jtag_tdi_i     => 'U', -- serial data input
    jtag_tdo_o     => open,        -- serial data output
    jtag_tms_i     => 'U', -- mode select
    -- Wishbone bus interface (available if MEM_EXT_EN = true) --
    wb_tag_o       => open, -- request tag
    wb_adr_o       => master_bus.adr_o, -- address
    wb_dat_i       => active_slave_resp.rdata_i, -- read data
    wb_dat_o       => master_bus.dat_o, -- write data
    wb_we_o        => master_bus.we_o, -- read/write
    wb_sel_o       => open, -- byte enable
    wb_stb_o       => master_bus.stb_o, -- strobe
    wb_cyc_o       => master_bus.cyc_o, -- valid cycle
    wb_lock_o      => open, -- exclusive access request
    wb_ack_i       => active_slave_resp.ack_i, -- transfer acknowledge
    wb_err_i       => active_slave_resp.err_i, -- transfer error
    -- Advanced memory control signals (available if MEM_EXT_EN = true) --
    fence_o        => open, -- indicates an executed FENCE operation
    fencei_o       => open, -- indicates an executed FENCEI operation
    -- XIP (execute in place via SPI) signals (available if IO_XIP_EN = true) --
    xip_csn_o      => open, -- chip-select, low-active
    xip_clk_o      => open, -- serial clock
    xip_sdi_i      => 'L', -- device data input
    xip_sdo_o      => open, -- controller data output
    -- TX stream interfaces (available if SLINK_NUM_TX > 0) --
    slink_tx_dat_o => open, -- output data
    slink_tx_val_o => open, -- valid output
    slink_tx_rdy_i => (others => 'L'), -- ready to send
    -- RX stream interfaces (available if SLINK_NUM_RX > 0) --
    slink_rx_dat_i => (others => (others => 'U')), -- input data
    slink_rx_val_i => (others => 'L'), -- valid input
    slink_rx_rdy_o => open, -- ready to receive
    -- GPIO (available if IO_GPIO_EN = true) --
    gpio_o         => con_gpio_o, -- parallel output
    gpio_i         => (others => 'U'), -- parallel input
    -- primary UART0 (available if IO_UART0_EN = true) --
    uart0_txd_o    => con_txd_o, -- UART0 send data
    uart0_rxd_i    => con_rxd_i, -- UART0 receive data
    uart0_rts_o    => open, -- hw flow control: UART0.RX ready to receive ("RTR"), low-active, optional
    uart0_cts_i    => '0', -- hw flow control: UART0.TX allowed to transmit, low-active, optional
    -- secondary UART1 (available if IO_UART1_EN = true) --
    uart1_txd_o    => open, -- UART1 send data
    uart1_rxd_i    => 'U', -- UART1 receive data
    uart1_rts_o    => open, -- hw flow control: UART1.RX ready to receive ("RTR"), low-active, optional
    uart1_cts_i    => 'L', -- hw flow control: UART1.TX allowed to transmit, low-active, optional
    -- SPI (available if IO_SPI_EN = true) --
    spi_sck_o      => con_sck, -- SPI serial clock
    spi_sdo_o      => con_sdo, -- controller data out, peripheral data in
    spi_sdi_i      => con_sdi, -- controller data in, peripheral data out
    spi_csn_o      => con_ss, -- chip-select
    -- TWI (available if IO_TWI_EN = true) --
    twi_sda_io     => open, -- twi serial data line
    twi_scl_io     => open, -- twi serial clock line
    -- PWM (available if IO_PWM_NUM_CH > 0) --
    pwm_o          => open, -- pwm channels
    -- Custom Functions Subsystem IO (available if IO_CFS_EN = true) --
    cfs_in_i       => (others => 'U'), -- custom CFS inputs conduit
    cfs_out_o      => open, -- custom CFS outputs conduit
    -- NeoPixel-compatible smart LED interface (available if IO_NEOLED_EN = true) --
    neoled_o       => open, -- async serial data line
    -- System time --
    mtime_i        => (others => 'U'), -- current system time from ext. MTIME (if IO_MTIME_EN = false)
    mtime_o        => open, -- current system time from int. MTIME (if IO_MTIME_EN = true)
    -- External platform interrupts (available if XIRQ_NUM_CH > 0) --
    xirq_i         => (others => 'L'), -- IRQ channels
    -- CPU interrupts --
    mtime_irq_i    => 'L', -- machine timer interrupt, available if IO_MTIME_EN = false
    msw_irq_i      => 'L', -- machine software interrupt
    mext_irq_i     => 'L'  -- machine external interrupt
);

    -- module instance led --
    iceduino_led_inst: entity olimex.olimex_led
    generic map (
        led_addr        =>  x"F0000000"
    )
    port map (
        clk_i  		=>  pll_clk,
        rstn_i 		=>  con_reset,       
        adr_i		=>	master_bus.adr_o,
        dat_i	    =>  master_bus.dat_o,
        dat_o	    =>  led_resp.rdata_i,
        we_i        =>  master_bus.we_o,
        stb_i		=>	master_bus.stb_o,
        cyc_i       =>  master_bus.cyc_o,
        ack_o       =>  led_resp.ack_i,
        err_o       =>  led_resp.err_i,
        led_o       =>  LED     
    );

    TxD  <= con_txd_o;
    con_rxd_i <= RxD;

    SCK  <= con_sck;
    SS_B  <= con_ss(0);
    SDO  <= con_sdo;
    con_sdi <= SDI;


end architecture;
