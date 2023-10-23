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

entity MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end MPG;

architecture Behavioral of MPG is

signal count_int : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal Q1: STD_LOGIC;
signal Q2: STD_LOGIC;
signal Q3: STD_LOGIC;

begin

en <= Q2 AND (not Q3);

process (clock)
begin
    if clock'event and clock='1' then
        count_int <= count_int + 1;
    end if;
end process;

process (clock)
begin
    if clock'event and clock='1' then
        if count_int(15 downto 0) = "1111111111111111" then
            Q1 <= input;
        end if;
    end if;
end process;

process (clock)
begin
    if clock'event and clock='1' then
        Q2 <= Q1;
        Q3 <= Q2;
    end if;
end process;

end Behavioral;