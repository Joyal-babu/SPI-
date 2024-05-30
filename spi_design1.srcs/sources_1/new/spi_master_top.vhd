----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 20.04.2024 14:47:02
-- Design Name: 
-- Module Name: spi_master_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_master_top is
    generic( 
        data_bus_width    : natural;                                     -- natural and positive are two subset of integer data type. The positive subtype can take the any positive integer value. The natural type is the same as the positive type except that it can also be assigned to 0.
                                                                         -- define the width of data to be transfered
        spi_mode          : integer;                                     -- The integer data type is used to express a value which is a whole number in VHDL
                                                                         -- Define the SPI mode of operation
        clk_divider       : std_logic_vector(3 downto 0) := "1000"       -- spi clock will be system clock / 8
        );
    Port ( 
        clock             : in  STD_LOGIC;
        reset             : in  STD_LOGIC;
        data_bus_tx       : in  STD_LOGIC_VECTOR ((data_bus_width-1) downto 0);
        data_bus_tx_valid : in  STD_LOGIC;                                       -- make HIGH for a single clock pulse
        data_bus_rx       : out STD_LOGIC_VECTOR ((data_bus_width-1) downto 0);
        data_bus_rx_valid : out STD_LOGIC;
        tx_ready          : out STD_LOGIC;
        
        spi_clock         : out STD_LOGIC;
        MOSI              : out STD_LOGIC;
        MISO              : in  STD_LOGIC
        );
end spi_master_top;

architecture Behavioral of spi_master_top is

    component spi_master_tx is
        generic( 
            data_bus_width    : natural;                                 -- natural and positive are two subset of integer data type. The positive subtype can take the any positive integer value. The natural type is the same as the positive type except that it can also be assigned to 0.
            clk_divider       : std_logic_vector(3 downto 0)
            );
        Port ( 
            clock             : in  STD_LOGIC;
            reset             : in  STD_LOGIC;
            data_bus_tx       : in  STD_LOGIC_VECTOR ((data_bus_width-1) downto 0);
            data_bus_tx_valid : in  STD_LOGIC;                           -- made HIGH for one clock cycle
            tx_ready          : out STD_LOGIC;
            
            spi_clock         : out STD_LOGIC;
            MOSI              : out STD_LOGIC;
            CPOL              : in  STD_LOGIC;
            CPHA              : in  STD_LOGIC
            );
    end component;
    
    component spi_master_rx is
    generic (
        data_bus_width    : natural
        );
    Port ( 
        clock             : in  STD_LOGIC;
        reset             : in  STD_LOGIC;
        spi_clock         : in  STD_LOGIC;
        MISO              : in  STD_LOGIC;
        CPHA              : in  STD_LOGIC;
        CPOL              : in  STD_LOGIC;
        tx_ready          : in  STD_LOGIC;
        data_bus_rx       : out STD_LOGIC_VECTOR ((data_bus_width-1) downto 0);
        data_bus_rx_valid : out STD_LOGIC
        );
   end component;

signal spi_clock_wire        : std_logic;
signal MOSI_wire             : std_logic; 
signal tx_ready_wire         : std_logic;
signal data_bus_rx_reg       : std_logic_vector((data_bus_width - 1) downto 0); 
signal data_bus_rx_valid_reg : std_logic;
signal CPOL, CPHA            : std_logic;

begin
    
    CPOL <= '1' when (spi_mode = 2) or (spi_mode = 3) else '0';
    CPHA <= '1' when (spi_mode = 1) or (spi_mode = 3) else '0';
    
    spi_clock   <= spi_clock_wire;
    MOSI        <= MOSI_wire;
    tx_ready    <= tx_ready_wire;
    
    data_bus_rx <= data_bus_rx_reg;
    data_bus_rx_valid <= data_bus_rx_valid_reg;
    
    tx_inst1 : spi_master_tx
        generic map (
            data_bus_width    => data_bus_width,
            clk_divider       => clk_divider
            )   
        port map (
            clock             => clock,
            reset             => reset,
            data_bus_tx       => data_bus_tx,
            data_bus_tx_valid => data_bus_tx_valid,
            tx_ready          => tx_ready_wire,
                           
            spi_clock         => spi_clock_wire,
            MOSI              => MOSI_wire,
            CPOL              => CPOL,
            CPHA              => CPHA
            );
            
    rx_inst1 : spi_master_rx
        generic map (
            data_bus_width    => data_bus_width
            )
        port map (
            clock             => clock,
            reset             => reset,
            spi_clock         => spi_clock_wire,
            MISO              => MOSI_wire,                        -- loopback connection 
            CPHA              => CPHA,
            CPOL              => CPOL,
            tx_ready          => tx_ready_wire,
            data_bus_rx       => data_bus_rx_reg,
            data_bus_rx_valid => data_bus_rx_valid_reg
            );           

end Behavioral;
