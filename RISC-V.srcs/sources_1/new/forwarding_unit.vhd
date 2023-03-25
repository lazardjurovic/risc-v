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