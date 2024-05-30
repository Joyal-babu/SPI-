----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.05.2024 23:18:36
-- Design Name: 
-- Module Name: spi_test1_tb - Behavioral
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

entity spi_test1_tb is
--  Port ( );
end spi_test1_tb;

architecture Behavioral of spi_test1_tb is
    
    component spi_test1 is
    Port ( sys_clock : in STD_LOGIC;
           sys_reset : in STD_LOGIC);
    end component;
    
    signal sys_clock, sys_reset : std_logic := '0';

begin
    
    sys_clock <= not sys_clock after 5ns;        --100MHz 
    sys_reset <= '1', '0' after 500ns;

    DUT : spi_test1 
        port map(
           sys_clock => sys_clock,
           sys_reset => sys_reset 
        );


end Behavioral;
