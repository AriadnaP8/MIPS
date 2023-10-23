----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2023 08:13:25 PM
-- Design Name: 
-- Module Name: RAM - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM is
     port(WRA: in std_logic_vector(3 downto 0);
     RD: out std_logic_vector(15 downto 0);
     WD: in std_logic_vector(15 downto 0);
     WE: in std_logic;
     clk: in std_logic);
end RAM;

architecture Behavioral of RAM is
    signal WRadresa : integer := 0;
    type ROM_COMP is array (0 to 15) of std_logic_vector(15 downto 0) ;
    signal RAM : ROM_COMP :=(
        "0000000000000001",
        "0000000000000010",
        "0000000000000011",
        "0000000000000100",
        "0011000010000000",
        "1100000010000100",
        "0000100000000001",
        "0010000011000000",
        "1101000100000100",
        "0000000000000001",
        "0011000011000000",
        "1100000100000100",
        "0000000000000001",
        "0011000010000000",
        "1100000010000100",
        "0000100000000001",
        others=>"1101000100000111"
     );

begin
    process(clk)
    begin
    
    if clk'event and clk='1' then
        WRadresa <=conv_integer(WRA);
        RD<=RAM(WRadresa);
            if WE ='1' then
            RAM(WRadresa)<=WD;
            end if;
    end if;
    
end process;



end Behavioral;
