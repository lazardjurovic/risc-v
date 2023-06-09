library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_decoder is
	port (
		-- opcode instrukcije
		opcode_i : in std_logic_vector (6 downto 0);
		funct3_id_i : in std_logic_vector( 2 downto 0);
		-- kontrolni signali
		branch_o      : out std_logic;
		mem_to_reg_o  : out std_logic;
		data_mem_we_o : out std_logic_vector(1 downto 0);
		alu_src_b_o   : out std_logic;
		rd_we_o       : out std_logic;
		rs1_in_use_o  : out std_logic;
		rs2_in_use_o  : out std_logic;
		alu_2bit_op_o : out std_logic_vector(1 downto 0);
		pc_operand    : out std_logic
	);
end entity;

architecture behav of ctrl_decoder is
begin

    process(opcode_i,funct3_id_i) is
    begin
    
        case opcode_i is 
        
        when "0110011"  => -- R type
            branch_o <= '0';
            mem_to_reg_o <='0';
            data_mem_we_o <="00";
            alu_src_b_o <='0';
            rd_we_o <= '1';
            rs1_in_use_o <='1';
            rs2_in_use_o <='1';
            alu_2bit_op_o <= "10";
            pc_operand <= '0';
        when "0010011" => -- I type
            branch_o <= '0';
            mem_to_reg_o <='0';
            data_mem_we_o <="00";
            alu_src_b_o <='1'; -- pass immediate through mux
            rd_we_o <= '1';
            rs1_in_use_o <='1';
            rs2_in_use_o <='0'; -- only rs1 is used by instruction
            alu_2bit_op_o <= "11";
            pc_operand <= '0';
        when "0000011" => -- Load
            branch_o <= '0';
            mem_to_reg_o <='1';
            data_mem_we_o <="00";
            alu_src_b_o <='1'; 
            rd_we_o <= '1';
            rs1_in_use_o <='1';
            rs2_in_use_o <='0'; 
            alu_2bit_op_o <= "00";
            pc_operand <= '0';
        when "1100011" => -- B type
            branch_o <= '1';
            mem_to_reg_o <='0';
            data_mem_we_o <="00"; 
            alu_src_b_o <='1';
            rd_we_o <= '0';
            rs1_in_use_o <='1';
            rs2_in_use_o <='1';
            alu_2bit_op_o <= "01";
            pc_operand <= '0';
        when "0100011" => -- S type
            branch_o <= '0';
            mem_to_reg_o <='0';
            
            case funct3_id_i is
                when "000" => data_mem_we_o <="01"; -- SB
                when "001" => data_mem_we_o <="10"; -- SH
                when "010" => data_mem_we_o <="11"; -- SW
                when others => data_mem_we_o <="00"; 
            end case;
            
            alu_src_b_o <='1';
            rd_we_o <= '0';
            rs1_in_use_o <='1';
            rs2_in_use_o <='1';
            alu_2bit_op_o <= "00";
            pc_operand <= '0';
        when "1100111" => -- JALR
            branch_o <= '1';
            mem_to_reg_o <='0';
            data_mem_we_o <="00"; 
            alu_src_b_o <='1';
            rd_we_o <= '1';
            rs1_in_use_o <='1';
            rs2_in_use_o <='0';
            alu_2bit_op_o <= "00";
            pc_operand <= '1';
        when "1101111" => -- JAL
            branch_o <= '1';
            mem_to_reg_o <='0';
            data_mem_we_o <="00"; 
            alu_src_b_o <='1';
            rd_we_o <= '1';
            rs1_in_use_o <='0';
            rs2_in_use_o <='0';
            alu_2bit_op_o <= "00";
            pc_operand <= '1';
        when "0010111" => -- AUIPC
            branch_o <= '0';
            mem_to_reg_o <='0';
            data_mem_we_o <="00"; 
            alu_src_b_o <='1';
            rd_we_o <= '1';
            rs1_in_use_o <='0';
            rs2_in_use_o <='0';
            alu_2bit_op_o <= "00";
            pc_operand <= '1';
        when "0110111" => -- LUI
            branch_o <= '0';
            mem_to_reg_o <='0';
            data_mem_we_o <="00"; 
            alu_src_b_o <='1';
            rd_we_o <= '1';
            rs1_in_use_o <='0';
            rs2_in_use_o <='0';
            alu_2bit_op_o <= "00";
            pc_operand <= '0';
        when others =>
            branch_o <= '0';
            mem_to_reg_o <='0';
            data_mem_we_o <="00"; 
            alu_src_b_o <='0';
            rd_we_o <= '0';
            rs1_in_use_o <='0';
            rs2_in_use_o <='0';
            alu_2bit_op_o <= "00";
            pc_operand <= '0';
        end case;
        
    end process;

end behav;