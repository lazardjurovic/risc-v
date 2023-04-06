library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity load_unit is
  Port ( 
        wb_data_i : in std_logic_vector(31 downto 0);
        wb_opcode_i : in std_logic_vector;
        wb_funct3_i : in std_logic_vector(2 downto 0);
        rd_we_i : in std_logic;
        
        reg_bank_data_o : out std_logic_vector(31 downto 0)
        
  );
end load_unit;

architecture Behavioral of load_unit is

constant zeros : std_logic_vector(31 downto 0) := (others => '0');
constant ones : std_logic_vector(31 downto 0) := (others => '1');

begin
    
    process(wb_data_i, wb_opcode_i)
    begin
    
        if(rd_we_i = '1') then
            
            if(wb_opcode_i = "0000011") then -- Load
                case wb_funct3_i is
                    when "000" => -- LB
                        if(wb_data_i(7) = '1') then -- sign extend
                            reg_bank_data_o <= ones(31 downto 8) & wb_data_i(7 downto 0); 
                        else
                            reg_bank_data_o <= zeros(31 downto 8) & wb_data_i(7 downto 0); 
                        end if;
                    when "001" => -- LH
                        if(wb_data_i(15) = '1') then -- sign extend
                            reg_bank_data_o <= ones(31 downto 16) & wb_data_i(15 downto 0); 
                        else
                            reg_bank_data_o <= zeros(31 downto 16) & wb_data_i(15 downto 0); 
                        end if;
                    when "010" => reg_bank_data_o <= wb_data_i; -- LW
                    when "100" => reg_bank_data_o <= zeros(31 downto 8) & wb_data_i(7 downto 0); -- LBU
                    when "101" => reg_bank_data_o <= zeros(31 downto 16) & wb_data_i(15 downto 0); -- LHU
                    when others => reg_bank_data_o <= wb_data_i; -- pass writeback result
                end case;
            else
                reg_bank_data_o <= wb_data_i; -- pass writeback result
            end if;
        
        else
            reg_bank_data_o <= (others => '0');
        end if;
    end process;


end Behavioral;
