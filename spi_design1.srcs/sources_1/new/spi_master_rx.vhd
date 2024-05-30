----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 21.04.2024 15:16:56
-- Design Name: 
-- Module Name: spi_master_rx - Behavioral
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

entity spi_master_rx is
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
end spi_master_rx;

architecture Behavioral of spi_master_rx is

signal data_bus_rx_reg       : std_logic_vector((data_bus_width-1) downto 0);
signal data_bus_rx_valid_reg : std_logic;
signal spi_clk_reg_d, spi_clk_reg_d1 : std_logic; 
signal rise_edge, fall_edge   : std_logic;
signal bit_count             : natural;

begin

    data_bus_rx_valid <= data_bus_rx_valid_reg;
    data_bus_rx       <= data_bus_rx_reg;

    process(clock, reset)
    begin
        if(reset = '1') then
            spi_clk_reg_d  <= '0';
            spi_clk_reg_d1 <= '0';
        elsif(rising_edge(clock)) then
            spi_clk_reg_d  <= spi_clock;
            spi_clk_reg_d1 <= spi_clk_reg_d;
        end if;
    end process;
    
    rise_edge  <= spi_clock and (not spi_clk_reg_d);
    fall_edge  <= spi_clk_reg_d and (not spi_clock);

    process(clock, reset)
    begin
        if(reset = '1') then
            data_bus_rx_valid_reg <= '0';
            data_bus_rx_reg       <= (others => '0');
            bit_count             <= (data_bus_width-1);
        elsif(rising_edge(clock)) then
            if(tx_ready = '1') then
                bit_count <= (data_bus_width-1);
                data_bus_rx_valid_reg <= '0';
            elsif((CPOL = '0' and CPHA = '0' and rise_edge = '1') or (CPOL = '1' and CPHA = '0' and fall_edge = '1') or (CPOL = '0' and CPHA = '1' and fall_edge = '1') or (CPOL = '1' and CPHA = '1' and rise_edge = '1')) then 
                data_bus_rx_reg(bit_count) <= MISO;
                if(bit_count > 0) then
                    bit_count <= bit_count - 1;
                else
                    bit_count <= (data_bus_width-1);
                    data_bus_rx_valid_reg <= '1';
                end if;
            end if;
        end if;
    end process;


end Behavioral;
