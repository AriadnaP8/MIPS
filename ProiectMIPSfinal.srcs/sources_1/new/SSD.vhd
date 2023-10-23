----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2023 07:27:26 PM
-- Design Name: 
-- Module Name: SSD - Behavioral
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

entity SSD is
    Port ( clk : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR ( 3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           cifra : in STD_LOGIC_VECTOR (15 downto 0));
end SSD;

architecture Behavioral of SSD is
    signal count: std_logic_vector (15 downto 0);
    signal hex: std_logic_vector (3 downto 0);
begin
    process (clk)
        begin 
            if clk = '1' and clk'event then
                count <= count + 1;
            end if;
    end process;
    
    process (count(15 downto 14), cifra(15 downto 0))
        begin 
            case count(15 downto 14) is
                when "00" => hex <= cifra(3 downto 0);
                when "01" => hex <= cifra(7 downto 4);
                when "10" => hex <= cifra(11 downto 8);
                when others => hex <= cifra(15 downto 12);    -- pentru when "11"
            end case;
    end process;
    
    process (count(15 downto 14))
        begin
            case count(15 downto 14) is
                when "00" => an <= "1110";
                when "01" => an <= "1101";
                when "10" => an <= "1011";
                when others => an <= "0111";
            end case;
    end process;
    
    with hex SElect
      cat <= "1000000"  when "0000" , -- 0
             "1111001"  when "0001" , --'1'
             "0100100"  when "0010" , --'2'0100100
             "0110000"  when "0011" , --'3'   
             "0011001"  when "0100" , --'4'
             "0010010"  when "0101" , --'5'
             "0000010"  when "0110" , --'6'
             "1111000"  when "0111" , --'7'
             "0000000"  when "1000" , --'8'
             "0010000"  when "1001" , --'9'
             "0001000"  when "1010" , --"10" sau 'A'
             "0000011"  when "1011" , --"11" sau 'b'
             "1000110"  when "1100" , --"12" sau 'C'
             "0100001"  when "1101" , --"13" sau 'd'
             "0000110"  when "1110" , --"14" sau 'E'
             "0001110"  when others; --"15" sau 'F'

end Behavioral;
