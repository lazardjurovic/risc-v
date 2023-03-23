library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_decoder is
	port (
		--******** Controlpath ulazi *********
		alu_2bit_op_i : in std_logic_vector(1 downto 0);
		--******** Polja instrukcije *******
		funct3_i : in std_logic_vector (2 downto 0);
		funct7_i : in std_logic_vector (6 downto 0);
		--******** Datapath izlazi ********
		alu_op_o : out std_logic_vector(4 downto 0)
	);
end entity;

architecture behav of alu_decoder is
begin

    process(alu_2bit_op_i, funct3_i, funct7_i)
    begin
        
        if(alu_2bit_op_i = "00") then
            alu_op_o <= "00000"; -- add
        elsif(alu_2bit_op_i = "01") then
            alu_op_o <= "00010"; -- sub
        elsif(alu_2bit_op_i = "10") then -- R type
            
            case funct3_i is
                when "000" =>
                    if(funct7_i(5) = '1') then
                        alu_op_o <= "00000"; -- add
                    else
                         alu_op_o <= "00010"; -- sub
                    end if;
                when "001" => alu_op_o <= "00100"; -- sll, slli
                when "010" => alu_op_o <= "01000"; -- slt, stli
                when "011" => alu_op_o <= "01100"; -- sltu, sltiu
                when "100" => alu_op_o <= "10000";
                when "101" => 
                    if(funct7_i(5) = '1') then
                        alu_op_o <= "10110"; --sra, srai
                    else
                        alu_op_o <= "10100"; -- srl, srli
                    end if;
                when "110" => alu_op_o <= "11000"; -- or, ori
                when "111" => alu_op_o <= "11100"; -- and, andi
                when others => alu_op_o <= (others => '1');
            end case;
            
        else
            alu_op_o <= (others =>'0');
        end if;
        
    end process;    

end behav;