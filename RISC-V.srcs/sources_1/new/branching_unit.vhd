library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity branching_unit is
	port 
	(
		rs1_data_i     : in std_logic_vector(31 downto 0);
		rs2_data_i     : in std_logic_vector(31 downto 0);
		mem_data_i     : in std_logic_vector(31 downto 0);
		funct3_i       : in std_logic_vector(2 downto 0);
		opcode_i : in std_logic_vector(6 downto 0);
		branch_forward_a_i : in std_logic;
		branch_forward_b_i : in std_logic;
		
		branch_condition_o  : out std_logic

	);
end branching_unit;

architecture Behavioral of branching_unit is

signal operand1, operand2 : std_logic_vector(31 downto 0);

begin

    operand1 <= mem_data_i when branch_forward_a_i = '1' else rs1_data_i;
    operand2 <= mem_data_i when branch_forward_b_i = '1' else rs2_data_i;
    

	process (operand1, operand2, funct3_i,opcode_i)
	begin
	
	   if(opcode_i = "1100011") then   
			case funct3_i is

				when "000" => -- BEQ
					if (operand1 = operand2) then
						branch_condition_o <= '1';
					else
						branch_condition_o <= '0';
					end if;
				when "001" => -- BNE
					if (operand1 = operand2) then
						branch_condition_o <= '0';
					else
						branch_condition_o <= '1';
					end if;
				when "100" => -- BLT
					if (signed(operand1) < signed(operand2)) then
						branch_condition_o <= '1';
					else
						branch_condition_o <= '0';
					end if;
				when "101" => -- BGE
					if (signed(operand1) > signed(operand2)) then
						branch_condition_o <= '1';
					else
						branch_condition_o <= '0';
					end if;
				when "110" => -- BLTU
					if (unsigned(operand1) < unsigned(operand2)) then
						branch_condition_o <= '1';
					else
						branch_condition_o <= '0';
					end if;
				when "111" => -- BGEU
					if (unsigned(operand1) > unsigned(operand2)) then
						branch_condition_o <= '1';
					else
						branch_condition_o <= '0';
					end if;
				when others => branch_condition_o <= '0';
			end case;
	   else    
	       branch_condition_o <= '0';
	   end if;
	end process;

end Behavioral;