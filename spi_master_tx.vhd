----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 20.04.2024 15:12:51
-- Design Name: 
-- Module Name: spi_master_tx - Behavioral
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

entity spi_master_tx is
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
end spi_master_tx;

architecture Behavioral of spi_master_tx is

signal clk_edge_cnt : integer range 0 to (2*data_bus_width);
signal bit_count    : integer;

signal clk_div_half, spi_clk_cnt     : std_logic_vector(3 downto 0);
signal spi_clk_reg, tx_ready_reg     : std_logic;
signal spi_clk_reg_d, spi_clk_reg_d1 : std_logic;
signal rise_edge, fall_edge          : std_logic;
signal data_bus_valid_reg, data_bus_valid_d, data_bus_valid_d1 : std_logic;
signal mosi_reg                      : std_logic;
signal data_bus_tx_reg               : std_logic_vector((data_bus_width-1) downto 0); 

begin

    clk_div_half <= '0' & clk_divider(3 downto 1);
    
    tx_ready  <= tx_ready_reg;
    spi_clock <= spi_clk_reg;
    
    MOSI      <= mosi_reg;
    
    process(clock, reset) 
    begin
        if(reset = '1') then
            data_bus_valid_reg <= '0';
            data_bus_valid_d   <= '0';
            data_bus_valid_d1  <= '0';
            data_bus_tx_reg    <= (others => '0');
        elsif(rising_edge(clock)) then
            if(data_bus_tx_valid = '1') then
                data_bus_tx_reg <= data_bus_tx;           -- storing the data to be transfered locally  
            end if;
            data_bus_valid_d   <= data_bus_tx_valid;
            data_bus_valid_d1  <= data_bus_valid_d;         -- registering the signal 
            data_bus_valid_reg <= data_bus_valid_d1;
        end if;
    end process;
    
    process(clock, reset, CPOL)                                                            -- generates the SPI clock and tx_ready signals 
    begin 
        if(reset = '1') then
            spi_clk_reg  <= CPOL;
            tx_ready_reg <= '0';
            spi_clk_cnt  <= (others => '0');
            clk_edge_cnt <= 0;
        elsif(rising_edge(clock)) then
            if(data_bus_tx_valid = '1') then
                tx_ready_reg <= '0';                                                -- will be low when data is being transfered, HIGH otherwise indicates TX is ready to accept data
                clk_edge_cnt <= (2*data_bus_width);
            elsif(clk_edge_cnt > 0) then
                tx_ready_reg <= '0';
                
                if(spi_clk_cnt = (clk_div_half - "0001")) then
                    spi_clk_cnt  <= (others => '0');
                    spi_clk_reg  <= not spi_clk_reg;
                    clk_edge_cnt <= clk_edge_cnt - 1;
                else
                    spi_clk_cnt <= spi_clk_cnt + '1';
                end if;
                
            else
                tx_ready_reg <= '1';                                                -- while no data is transfered
            end if;
        end if;
    end process;
    
    process(clock, reset)
    begin
        if(reset = '1') then
            spi_clk_reg_d  <= '0';
            spi_clk_reg_d1 <= '0';
        elsif(rising_edge(clock)) then
            spi_clk_reg_d  <= spi_clk_reg;
            spi_clk_reg_d1 <= spi_clk_reg_d;
        end if;
    end process;
    
    rise_edge  <= spi_clk_reg and (not spi_clk_reg_d);
    fall_edge  <= spi_clk_reg_d and (not spi_clk_reg);
    
    process(clock, reset)
    begin
        if(reset = '1') then
            mosi_reg  <= '0';
            bit_count <= (data_bus_width-1);
        elsif(rising_edge(clock)) then
            if(tx_ready_reg = '1') then
                bit_count <= (data_bus_width-1);
            elsif(data_bus_valid_d = '1' and CPHA = '0') then
                mosi_reg  <= data_bus_tx_reg(bit_count);
                bit_count <= bit_count - 1;
            elsif((CPOL = '0' and CPHA = '0' and fall_edge = '1') or (CPOL = '1' and CPHA = '0' and rise_edge = '1') or (CPOL = '0' and CPHA = '1' and rise_edge = '1') or (CPOL = '1' and CPHA = '1' and fall_edge = '1')) then
                mosi_reg  <= data_bus_tx_reg(bit_count);
                if(bit_count > 0) then
                    bit_count <= bit_count - 1;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
