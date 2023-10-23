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

entity InstructionDecode is
    Port( clk: in STD_LOGIC;     --folosit pt scrierea in RF 
          en: in STD_LOGIC;
          Instr: in STD_LOGIC_VECTOR(12 downto 0);
          WD: in STD_LOGIC_VECTOR(15 downto 0);
          RegWrite: in STD_LOGIC;    -- validarea scrierii in RF
          RegDst: in STD_LOGIC;      -- selecteaza adresa de scriere in RF
          ExtOp: in STD_LOGIC;       -- selecteaza tipul extensiei pt campul imm(cu zero sau cu semn)
          RD1: out STD_LOGIC_VECTOR(15 downto 0);       -- valoarea registrului de la adresa rs
          RD2: out STD_LOGIC_VECTOR(15 downto 0);       -- valoarea registrului de la adresa rt
          Ext_Imm: out STD_LOGIC_VECTOR(15 downto 0);   -- imediatul extins la 16 biti
          func: out STD_LOGIC_VECTOR(2 downto 0);
          sa: out STD_LOGIC);
end InstructionDecode;

architecture Behavioral of InstructionDecode is

component RegisterFile is
 Port ( clk :in std_logic;
        regWrite: in std_logic;
        enable: in std_logic;
        ra1: in std_logic_vector(2 downto 0);
        ra2: in std_logic_vector(2 downto 0);
        wa :in std_logic_vector(2 downto 0);
        wd :in std_logic_vector(15 downto 0);
        rd1: out std_logic_vector(15 downto 0);
        rd2: out std_logic_vector(15 downto 0));
end component;

signal WriteAddress: std_logic_vector(2 downto 0);
signal Ext_Op: std_logic_vector(15 downto 0);  -- semnalul de iesire din Ext Unit

begin

-- REGISTER FILE
with RegDst select
    WriteAddress <= Instr(6 downto 4) when '1',   -- rd
                    Instr(9 downto 7) when '0',   -- rt
                    (others => 'X') when others;  -- unknown

-- UNITATEA DE EXTENSIE SEMN/ZERO
process(ExtOp,Instr)   
begin
    case (ExtOp) is
        when '1' => 	
	       case (Instr(6)) is  -- daca bitul de semn(primul bit, cel mai semnificativ)
	           when '0' => Ext_op <= B"000000000" & Instr(6 downto 0); -- adaugam in fata imediatului 9 de 0 pentru a alcatui cei 16 biti
	           when '1' => Ext_op <= B"111111111" & Instr(6 downto 0); -- tot asa da pt nr negativ
		  end case;
	   when others => Ext_op <= B"000000000" & Instr(6 downto 0);  -- vom adauga tot 0 in cazu asta
    end case;
end process;

func <= instr(2 downto 0); -- selecteaza ce operatie de tipul r se va face in alu
sa <= instr(3); -- cu cati biti sa shifteze
ext_imm <= Ext_op; -- iesirea de la Ext unit va transmite intrarea in fct de selectia ExtOp

--REGISTER FILE
RF : RegisterFile port map(clk, RegWrite, en, Instr(12 downto 10),Instr(9 downto 7), WriteAddress, WD, RD1, RD2);

end Behavioral;