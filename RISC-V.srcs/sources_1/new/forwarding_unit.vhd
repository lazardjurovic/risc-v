library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is
	port (
		-- ulazi iz ID faze
		rs1_address_id_i : in std_logic_vector(4 downto 0);
		rs2_address_id_i : in std_logic_vector(4 downto 0);
		-- ulazi iz EX faze
		rs1_address_ex_i : in std_logic_vector(4 downto 0);
		rs2_address_ex_i : in std_logic_vector(4 downto 0);
		-- ulazi iz MEM faze
		rd_we_mem_i      : in std_logic;
		rd_address_mem_i : in std_logic_vector(4 downto 0);
		-- ulazi iz WB faze
		rd_we_wb_i      : in std_logic;
		rd_address_wb_i : in std_logic_vector(4 downto 0);
		-- izlazi za prosledjivanje operanada ALU jedinici
		alu_forward_a_o : out std_logic_vector (1 downto 0);
		alu_forward_b_o : out std_logic_vector(1 downto 0);
		-- izlazi za prosledjivanje operanada komparatoru za odredjivanje uslova skoka
		branch_forward_a_o : out std_logic;
		branch_forward_b_o : out std_logic
	);
end entity;

architecture behav of forwarding_unit is
begin

    process(rs1_address_id_i,rs2_address_id_i,rs1_address_ex_i,rs2_address_ex_i,rd_we_mem_i,rd_address_mem_i,rd_we_wb_i,rd_address_wb_i)
    begin
    
        alu_forward_a_o <= "00";
        alu_forward_b_o <= "00";   
          
        if(rd_we_wb_i = '1' and rd_address_wb_i /= "00000") then  -- forwarding from wb phase
            if(rs1_address_ex_i = rd_address_wb_i) then
                alu_forward_a_o <= "01";  
            end if; 
            
            if(rs2_address_ex_i = rd_address_wb_i) then
                alu_forward_b_o <= "01";
            end if;
        end if;
          
        if(rd_we_mem_i = '1' and rd_address_mem_i /= "00000") then -- forwarding from mem phase
            if(rs1_address_ex_i = rd_address_mem_i) then
                alu_forward_a_o <= "10";
            end if; 
            
            if(rs2_address_ex_i = rd_address_mem_i) then
                alu_forward_b_o <= "10";
            end if;   
         end if;   
               
    -- Branch forwarding 
    
    branch_forward_a_o <= '0';
    branch_forward_b_o <= '0';   
      
    if(rd_we_mem_i = '1' and rd_address_mem_i /= "00000") then
        
        if(rs1_address_id_i = rd_address_mem_i) then
            branch_forward_a_o <= '1';
        end if;
        
        if(rs2_address_id_i = rd_address_mem_i) then
            branch_forward_b_o <= '1';
        end if;
    end if;        
        
    end process;

end behav;