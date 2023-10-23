library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterFile is
 Port ( clk :in std_logic;
        regWrite: in std_logic;
        enable: in std_logic;
        ra1: in std_logic_vector(2 downto 0);
        ra2: in std_logic_vector(2 downto 0);
        wa :in std_logic_vector(2 downto 0);
        wd :in std_logic_vector(15 downto 0);
        rd1: out std_logic_vector(15 downto 0);
        rd2: out std_logic_vector(15 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is

type registerFile is array(0 to 7) of std_logic_vector(15 downto 0);
signal reg_file : registerFile:=(   
    x"0000",
    others =>x"0000"); 
   
begin

process(clk)
begin
    if(rising_edge(clk))then
        if(regWrite= '1' and enable = '1')then
            reg_file(to_integer(unsigned(wa)))<=wd;
        end if;
    end if;
    
    rd1<=reg_file(conv_integer((ra1)));
    rd2<=reg_file(conv_integer((ra2)));
end process;

end Behavioral;