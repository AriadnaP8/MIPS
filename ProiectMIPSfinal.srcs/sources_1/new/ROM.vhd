----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2023 08:15:26 PM
-- Design Name: 
-- Module Name: ROM - Behavioral
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

entity ROM is
    port(clk :in std_logic;
    RA:in std_logic_vector(3 downto 0);
    RD:out std_logic_vector(15 downto 0)
    );
end ROM;

architecture Behavioral of ROM is
signal adresa: integer:=0;
type ROM_COMP is array (0 to 15) of std_logic_vector(15 downto 0) ;
signal ROM : ROM_COMP :=(
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
    process (clk)
    begin
        if clk'event and clk='1' then
            adresa<= conv_integer(RA);
            RD<=ROM(adresa);
        end if;
    end process;

end Behavioral;
