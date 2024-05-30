----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 20.04.2024 15:48:41
-- Design Name: 
-- Module Name: spi_master_top_TB - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_master_top_TB is
--  Port ( );
end spi_master_top_TB;

architecture Behavioral of spi_master_top_TB is

    component spi_master_top is
        generic( 
            data_bus_width    : natural;                                     -- natural and positive are two subset of integer data type. The positive subtype can take the any positive integer value. The natural type is the same as the positive type except that it can also be assigned to 0.
            spi_mode          : integer;                                     -- The integer data type is used to express a value which is a whole number in VHDL
            clk_divider       : std_logic_vector(3 downto 0) := "1000"
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
    end component;
    
    constant data_bus_width : natural := 8;
    constant spi_mode       : integer := 2;
    
    signal clock, reset, data_bus_tx_valid, data_bus_rx_valid, tx_ready, spi_clock, MOSI, MISO : std_logic := '0';
    signal data_bus_tx, data_bus_rx : std_logic_vector((data_bus_width-1) downto 0) := (others => '0');
    
    
        procedure send_spi_data (
                         in_data  : in  std_logic_vector((data_bus_width-1) downto 0);
                  signal tx_data  : out std_logic_vector((data_bus_width-1) downto 0);
                  signal tx_valid : out std_logic
                  ) is  
        begin
            wait until rising_edge(clock);
            tx_data  <= in_data;
            tx_valid <= '1';
            wait until rising_edge(clock);
            tx_valid <= '0';
            wait until rising_edge(tx_ready);
            wait for 100ns;
        end procedure send_spi_data;
                 
begin

    clock <= not clock after 1.25 ns;                 -- 400MHz (2.5ns)
    reset <= '1' , '0' after 500  ns;
    

    process
    begin
        wait for 1000ns;
        
        send_spi_data( x"4F", data_bus_tx, data_bus_tx_valid);
        
        send_spi_data( x"8A", data_bus_tx, data_bus_tx_valid);
        wait;
        
    end process;

   
--    process
--    begin
--        wait for 20 us;
--        data_bus_tx_valid <= '1'; 
--        data_bus_tx <= x"A9";    
--        wait for 2.5 ns;
--        data_bus_tx_valid <= '0';
        
        
--        wait until tx_ready <= '1';
--        wait for 40 ns;
--        data_bus_tx_valid <= '1'; 
--        data_bus_tx <= x"4C";    
--        wait for 2.5 ns;
--        data_bus_tx_valid <= '0';
        
--        wait for 40 ns;
--        wait until tx_ready <= '1';
--        wait for 40 ns;
--        data_bus_tx_valid <= '1'; 
--        data_bus_tx <= x"87";    
--        wait for 2.5 ns;
--        data_bus_tx_valid <= '0';
       
--       wait for 40 ns;
--        wait until tx_ready <= '1';
--        wait for 40 ns;
--        data_bus_tx_valid <= '1'; 
--        data_bus_tx <= x"90";    
--        wait for 2.5 ns;
--        data_bus_tx_valid <= '0';
        
--        wait for 40 ns;
--        wait until tx_ready <= '1';
--        wait for 40 ns;
--        data_bus_tx_valid <= '1'; 
--        data_bus_tx <= x"d4";    
--        wait for 2.5 ns;
--        data_bus_tx_valid <= '0';
        
--    end process;

    DUT : spi_master_top
        generic map(
            data_bus_width => data_bus_width,
            spi_mode       => spi_mode
            )
        port map(
            clock              => clock,
            reset              => reset,
            data_bus_tx        => data_bus_tx,
            data_bus_tx_valid  => data_bus_tx_valid,
            data_bus_rx        => data_bus_rx,
            data_bus_rx_valid  => data_bus_rx_valid,
            tx_ready           => tx_ready,
                             
            spi_clock          => spi_clock,
            MOSI               => MOSI,
            MISO               => MISO 
            );

end Behavioral;
