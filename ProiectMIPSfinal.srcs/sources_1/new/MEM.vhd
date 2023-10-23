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

entity MEM is
    Port ( clk : in STD_LOGIC; --clock pentru SCRIERE SINCRONA
           en : in STD_LOGIC;  
           ALUResIn : in STD_LOGIC_VECTOR(15 downto 0); --CITIRE ASINCRONA
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           MemWrite : in STD_LOGIC;			--semnal de control,valideaza SCRIEREA
           MemData : out STD_LOGIC_VECTOR(15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end MEM;

architecture Behavioral of MEM is

type mem_type is array (0 to 31) of STD_LOGIC_VECTOR(15 downto 0);
signal MEM : mem_type := (
    x"0000",   -- 0
    x"0001",   -- 1
    x"0002",   -- 2
    x"0003",   -- 3
    x"0004",   -- 4
    x"0005",   -- 5
    x"0006",   -- 6
    x"0007",   -- 7
    x"0008",   -- 8
    x"0009",   -- 9
    x"000A",   -- 10
    others => x"0000");

begin
    
     -- outputs
   MemData <= MEM(conv_integer(ALUResIn(4 downto 0)));
   ALUResOut <= ALUResIn;
    
    -- Data Memory
    process(clk) 			
    begin
        if rising_edge(clk) then
            if en = '1' and MemWrite='1' then
                MEM(conv_integer(ALUResIn(4 downto 0))) <= RD2;			
            end if;
        end if;
    end process;

end Behavioral;
