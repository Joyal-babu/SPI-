----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2024 22:03:27
-- Design Name: 
-- Module Name: spi_master_tx_TB - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_master_tx_TB is
--  Port ( );
end spi_master_tx_TB;

architecture Behavioral of spi_master_tx_TB is

    component spi_master_tx is
    generic( 
        data_bus_width     : natural;                                 -- natural and positive are two subset of integer data type. The positive subtype can take the any positive integer value. The natural type is the same as the positive type except that it can also be assigned to 0.
        clk_divider        : std_logic_vector(3 downto 0)
        );
    Port ( 
        clock              : in  STD_LOGIC;
        reset              : in  STD_LOGIC;
        data_bus_tx        : in  STD_LOGIC_VECTOR ((data_bus_width-1) downto 0);
        data_bus_tx_valid  : in  STD_LOGIC;                           -- made HIGH for one clock cycle
        tx_ready           : out STD_LOGIC;
        
        spi_clock          : out STD_LOGIC;
        MOSI               : out STD_LOGIC;
        CPOL               : in  STD_LOGIC;
        CPHA               : in  STD_LOGIC
        );
    end component;
    
    constant data_bus_width : natural := 8;
    constant clk_divider    : std_logic_vector(3 downto 0) := "1000";
    
    signal clock, reset, data_bus_tx_valid, tx_ready, spi_clock, MOSI, CPOL, CPHA : std_logic := '0';
    signal data_bus_tx : std_logic_vector((data_bus_width-1) downto 0); 
    
    
begin

    clock <= not clock after 1.25 ns;
    reset <= '1' , '0' after 500  ns;
    data_bus_tx <= x"5C";

    process
    begin
        wait for 20 us;
        data_bus_tx_valid <= '1'; wait for 2.5 ns;
        data_bus_tx_valid <= '0'; wait;
    end process;
    
    
    DUT : spi_master_tx 
    generic map(
        data_bus_width => data_bus_width,
        clk_divider    => clk_divider
        )
    port map(
        clock             => clock            ,
        reset             => reset            ,
        data_bus_tx       => data_bus_tx      ,
        data_bus_tx_valid => data_bus_tx_valid,
        tx_ready          => tx_ready         ,
                        
        spi_clock         => spi_clock        ,
        MOSI              => MOSI             ,
        CPOL              => CPOL             ,
        CPHA              => CPHA             
        );
        
        
        
end Behavioral;
