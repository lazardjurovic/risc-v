library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity branching_unit is
	port 
	(

		rs1_data_i     : in std_logic_vector(31 downto 0);
		rs2_data_i     : in std_logic_vector(31 downto 0);
		funct3_i       : in std_logic_vector(2 downto 0);
		branch_instr_i : in std_logic;

		pc_next_sel_o  : out std_logic

	);
end branching_unit;

architecture Behavioral of branching_unit is

begin
	process (rs1_data_i, rs2_data_i, funct3_i, branch_instr_i)
	begin
		if (branch_instr_i = '1') then
			case funct3_i is

				when "000" => -- BEQ
					if (rs1_data_i = rs2_data_i) then
						pc_next_sel_o <= '1';
					else
						pc_next_sel_o <= '0';
					end if;
				when "001" => -- BNE
					if (rs1_data_i /= rs2_data_i) then
						pc_next_sel_o <= '1';
					else
						pc_next_sel_o <= '0';
					end if;
				when "100" => -- BLT
					if (signed(rs1_data_i) < signed(rs2_data_i)) then
						pc_next_sel_o <= '1';
					else
						pc_next_sel_o <= '0';
					end if;
				when "101" => -- BGE
					if (signed(rs1_data_i) > signed(rs2_data_i)) then
						pc_next_sel_o <= '1';
					else
						pc_next_sel_o <= '0';
					end if;
				when "110" => -- BLTU
					if (unsigned(rs1_data_i) < unsigned(rs2_data_i)) then
						pc_next_sel_o <= '1';
					else
						pc_next_sel_o <= '0';
					end if;
				when "111" => -- BGEU
					if (unsigned(rs1_data_i) > unsigned(rs2_data_i)) then
						pc_next_sel_o <= '1';
					else
						pc_next_sel_o <= '0';
					end if;
				when others => pc_next_sel_o <= '0';
			end case;
 
		else
			pc_next_sel_o <= '0';
		end if;
 
 

	end process;

end Behavioral;