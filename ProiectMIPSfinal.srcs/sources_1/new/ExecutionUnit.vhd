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

entity ExecutionUnit is
    Port ( PCinc : in STD_LOGIC_VECTOR(15 downto 0);  -- adresa urmatoarei instructiuni
           RD1 : in STD_LOGIC_VECTOR(15 downto 0);    -- rs
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);    -- rt
           Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
           func : in STD_LOGIC_VECTOR(2 downto 0);
           sa : in STD_LOGIC;
           ALUSrc : in STD_LOGIC;    -- selectie între Read Data 2 si Ext_Imm pentru intrarea a doua din ALU
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);   -- codul pentru operatia ALU furnizat de catre unitatea principala de control UC
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
           ALURes : out STD_LOGIC_VECTOR(15 downto 0);
           Zero : out STD_LOGIC);
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is

signal ALUIn2 : STD_LOGIC_VECTOR(15 downto 0);
signal ALUIn1 : STD_LOGIC_VECTOR(15 downto 0);
signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
signal ALUResAux : STD_LOGIC_VECTOR(15 downto 0);

begin
    -- MUX pentru ALU intrarea2
    AluIn2 <= RD2(15 downto 0) when ALUSrc = '0' 
                else Ext_Imm(15 downto 0);
          
    -- generare branch address
    BranchAddress <= PCinc + Ext_Imm;
             
    -- ALU CONTROL
    process(ALUOp, func)
    begin
        case ALUOp is
            when "000" => -- R type 
                case func is
                    when "000" => ALUCtrl <= "000"; -- ADD
                    when "001" => ALUCtrl <= "001"; -- SUB
                    when "010" => ALUCtrl <= "010"; -- SLL
                    when "011" => ALUCtrl <= "011"; -- SRL
                    when "100" => ALUCtrl <= "100"; -- AND
                    when "101" => ALUCtrl <= "101"; -- OR
                    when "110" => ALUCtrl <= "110"; -- XOR
                    when "111" => ALUCtrl <= "111"; -- SLT
                    when others => ALUCtrl <= (others => '0'); -- unknown
                end case;
            when "001" => ALUCtrl <= "000"; -- + addi
            when "010" => ALUCtrl <= "001"; -- - subi si BEQ
            when "011" => ALUCtrl <= "000"; -- sw pentru store word
            when "101" => ALUCtrl <= "100"; -- & andi
            when "110" => ALUCtrl <= "101"; -- ORI
            when others => ALUCtrl <= (others => '0'); -- unknown
        end case;
    end process;

    -- ALU
    process(ALUCtrl, RD1, AluIn2, sa, ALUResAux)
    begin
        case ALUCtrl  is
            when "000" => -- ADD
                ALUResAux <= RD1 + ALUIn2;
            when "001" =>  -- SUB si BEQ
                ALUResAux <=  RD1-ALUIn2;                                    
            when "010" => -- SLL
                case sa is
                    when '1' => ALUResAux <= ALUIn2(14 downto 0) & "0";
                    when '0' => ALUResAux <= ALUIn2;
                    when others => ALUResAux <= (others => '0');
                 end case;
            when "011" => -- SRL
                case sa is
                    when '1' => ALUResAux <= "0" & ALUIn2(15 downto 1);
                    when '0' => ALUResAux <= ALUIn2;
                    when others => ALUResAux <= (others => '0');
                end case;
            when "100" => -- AND
                ALUResAux<=RD1 and ALUIn2;        
            when "101" => -- OR
                ALUResAux<=RD1 or ALUIn2;      
            when "111" => -- SLT
                if signed(RD1) < signed(ALUIn2) then
                    ALUResAux <= X"0001";
                else 
                    ALUResAux <= X"0000";
                end if;
            when others => -- unknown
                ALUResAux <= (others => '0');              
        end case;
        
    end process;
    
    -- zero detector
    Zero <= '1' when AluResAux = 0 else '0';
    
    -- ALU result
    ALURes <= ALUResAux;

end Behavioral;