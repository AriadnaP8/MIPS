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

entity InstructionFetch is
    Port ( clk: in STD_LOGIC;   -- semnal de ceas pt PC
           rst : in STD_LOGIC;  -- pt a reseta registrul PC la valoarea 0
           en : in STD_LOGIC;   -- valideaza scrierea in PC
           BranchAddress : in STD_LOGIC_VECTOR(15 downto 0); -- adresa de branch
           JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);   -- adresa de jump
           Jump : in STD_LOGIC;  -- semnal de control jump                        
           PCSrc : in STD_LOGIC; -- semnal de control pt branch
           Instruction : out STD_LOGIC_VECTOR(15 downto 0);  -- instructiunea de executat
           PCinc : out STD_LOGIC_VECTOR(15 downto 0));       -- adresa urmatoarei instructiuni
end InstructionFetch;

architecture Behavioral of InstructionFetch is

-- Memorie ROM
type tROM is array (0 to 19) of STD_LOGIC_VECTOR (15 downto 0);
signal ROM : tROM := (
        B"000_000_000_001_0_000", --"0010"       add $1,$0,$0   i = 0, contorul buclei     
        B"001_000_100_0001010",   --"220A"       addi $4,$0,10  se salveaza numarul maxim de iteratii (10)
        B"000_000_000_010_0_000", --"0020"       add $2,$0,$0   initializarea indexului locatiei de memorie
        B"000_000_000_101_0_000", --"0050"       add $5,$0,$0   sum = 0
        B"011_001_100_0000111",   --"6607"       beq $1,$4,7    s-au facut 10 iteratii? daca da, salt în afara buclei
        B"010_010_011_0000001",   --"4981"       lw $3,1($2)    în $3 se aduce elementul curent din sir
        B"001_011_011_0000010",   --"2D82"       addi $3,$3,2   $3 = $3 + 2
        B"011_010_011_0000001",   --"6981"       sw $3,1($2)    salvarea noii valori $3 în elementul curent din sir
        B"000_101_011_101_0_000", --"15D0"       add $5,$5,$3   se aduna la suma partiala din $5 elementul curent
        B"001_010_010_0000001",   --"2901"       addi $2,$2,1   indexul urmatorului element din sir
        B"001_001_001_0000001",   --"2481"       addi $1,$1,1   i = i + 1, actualizarea contorului buclei
        B"111_0000000000100",     --"E004"       j 4            salt începutul buclei    
        B"011_000_101_0001010",   --"628A"       sw $5,10($0)   salvarea sumei în memorie la adresa 10

others=>X"0000");

signal PCD: STD_LOGIC_VECTOR(15 downto 0);
signal PCQ: STD_LOGIC_VECTOR(15 downto 0);
signal PCplus: STD_LOGIC_VECTOR(15 downto 0);
signal outmux1: STD_LOGIC_VECTOR(15 downto 0);

begin
    ----------PC
    process(clk)
    begin
        if (rst = '1') then
            PCQ <= x"0000";
        end if;
        
        if rising_edge(clk) then
            if en = '1' then
                PCQ <= PCD;
            end if;
        end if;
    end process;

    outmux1 <= BranchAddress when PCSrc = '1' else PCplus; -- muxul cu selectia PCSrc
    PCD <= JumpAddress when Jump = '1' else outmux1;    -- muxul cu selectia Jump
    PCplus <= PCQ + '1';
    PCinc <= PCplus;    -- index-ul fiecarei instructiuni
    instruction <= ROM(conv_integer(PCQ));
    
end Behavioral;