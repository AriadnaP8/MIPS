
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

entity test_env is
  Port (clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0) );
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           cifra : in STD_LOGIC_VECTOR (15 downto 0));
end component;

component InstructionFetch is
    Port ( clk: in STD_LOGIC;   -- semnal de ceas pt PC
           rst : in STD_LOGIC;  -- pt a reseta registrul PC la valoarea 0
           en : in STD_LOGIC;   -- valideaza scrierea in PC
           BranchAddress : in STD_LOGIC_VECTOR(15 downto 0); -- adresa de branch
           JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);   -- adresa de jump
           Jump : in STD_LOGIC;  -- semnal de control jump                        
           PCSrc : in STD_LOGIC; -- semnal de control pt branch
           Instruction : out STD_LOGIC_VECTOR(15 downto 0);  -- instructiunea de executat
           PCinc : out STD_LOGIC_VECTOR(15 downto 0));       -- adresa urmatoarei instructiuni
end component;

component InstructionDecode is
    Port ( clk: in STD_LOGIC;    -- folosit pt scrierea in RF
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(12 downto 0);
           WD : in STD_LOGIC_VECTOR(15 downto 0);
           RegWrite : in STD_LOGIC;   -- validarea scrierii in RF
           RegDst : in STD_LOGIC;     -- selecteaza adresa de scriere in RF
           ExtOp : in STD_LOGIC;      -- selecteaza tipul extensiei pt campul imm(cu zero sau cu semn)
           RD1 : out STD_LOGIC_VECTOR(15 downto 0);     -- valoarea registrului de la adresa rs
           RD2 : out STD_LOGIC_VECTOR(15 downto 0);     -- valoarea registrului de la adresa rt
           Ext_Imm : out STD_LOGIC_VECTOR(15 downto 0); -- imediatul extins la 16 biti
           func : out STD_LOGIC_VECTOR(2 downto 0);
           sa : out STD_LOGIC);
end component;

component MainControl is
    Port ( Instr : in STD_LOGIC_VECTOR(2 downto 0);   --opcode-ul instructiunii
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component ExecutionUnit is
     Port ( PCinc : in STD_LOGIC_VECTOR(15 downto 0);  -- adresa urmatoarei instructiuni
          RD1 : in STD_LOGIC_VECTOR(15 downto 0);    -- rs
          RD2 : in STD_LOGIC_VECTOR(15 downto 0);    -- rt
          Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
          func : in STD_LOGIC_VECTOR(2 downto 0);
          sa : in STD_LOGIC;
          ALUSrc : in STD_LOGIC;    -- selectie între Read Data 2 si Ext_Imm pentru intrarea a doua din ALU
          ALUOp : in STD_LOGIC_VECTOR(2 downto 0);   -- codul pentru operatia ALU furnizat de catre unitatea principala de control UC
         -- BranchLowerEX: out STD_LOGIC;
          BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
          ALURes : out STD_LOGIC_VECTOR(15 downto 0);
          Zero : out STD_LOGIC);
end component;

component MEM is
    Port ( clk : in STD_LOGIC; --clock pentru SCRIERE SINCRONA
           en : in STD_LOGIC;  
           ALUResIn : in STD_LOGIC_VECTOR(15 downto 0); --CITIRE ASINCRONA
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           MemWrite : in STD_LOGIC;			--semnal de control,valideaza SCRIEREA
           MemData : out STD_LOGIC_VECTOR(15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end component;

-- SIGNALS
signal Instruction, PCinc, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(15 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(15 downto 0);
signal func : STD_LOGIC_VECTOR(2 downto 0);
signal sa, zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(15 downto 0);
signal en, rst, PCSrc : STD_LOGIC; 
-- main controls 
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp :  STD_LOGIC_VECTOR(2 downto 0);
signal bltzEX, bltzUC: STD_LOGIC;

begin

    -- buttons: reset, enable
    monopulse1: MPG port map(en, btn(0), clk);
    monopulse2: MPG port map(rst, btn(1), clk);
    
    -- main units
    inst_IF: InstructionFetch port map(clk, rst, en, BranchAddress, JumpAddress, Jump, PCSrc, Instruction, PCinc);
    inst_ID: InstructionDecode port map(clk, en, Instruction(12 downto 0), WD, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_imm, func, sa);
    inst_MC: MainControl port map(Instruction(15 downto 13), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
    inst_EX: ExecutionUnit port map(PCinc, RD1, RD2, Ext_imm, func, sa, ALUSrc, ALUOp, BranchAddress, ALURes, Zero); 
    inst_MEM: MEM port map(clk, en, ALURes, RD2, MemWrite, MemData, ALURes1);

    -- WriteBack unit
    with MemtoReg select
        WD <= MemData when '1',
              ALURes1 when '0',
              (others => '0') when others;

    -- branch control
    PCSrc <= (Zero and Branch);

    -- jump address
    JumpAddress <= Instr(2 downto 0) & Instruction(12 downto 0);

   -- SSD display MUX
    with sw(7 downto 5) select
        digits <=  Instruction when "000", 
                   PCinc when "001",    -- id instructiune, a cata instuctiune este 
                   RD1 when "010",
                   RD2 when "011",
                   Ext_Imm when "100",
                   ALURes when "101",
                   MemData when "110",
                   WD when "111",
                   (others => '0') when others; 
    
    display : SSD port map (clk, an, cat, digits);
    
    -- main controls on the leds
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    
end Behavioral;