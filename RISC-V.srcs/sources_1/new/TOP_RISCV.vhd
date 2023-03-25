library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity TOP_RISCV is
	port (
		-- Globalna sinhronizacija
		clk   : in std_logic;
		reset : in std_logic;
		-- Interfejs ka memoriji za podatke
		instr_mem_address_o : out std_logic_vector(31 downto 0);
		instr_mem_read_i    : in std_logic_vector(31 downto 0);
		-- Interfejs ka memoriji za instrukcije
		data_mem_address_o : out std_logic_vector(31 downto 0);
		data_mem_read_i    : in std_logic_vector(31 downto 0);
		data_mem_write_o   : out std_logic_vector(31 downto 0);
		data_mem_we_o      : out std_logic_vector(3 downto 0)
	);
end entity;

architecture structural of TOP_RISCV is
begin


data: entity work.data_path
port map(
		-- sinhronizacioni signali
		clk   => clk,
		reset => reset,
		-- interfejs ka memoriji za instrukcije
		instr_mem_address_o => instr_mem_address_o,
		instr_mem_read_i    => instr_mem_read_i,
		instruction_o       => open,
		-- interfejs ka memoriji za podatke
		data_mem_address_o => data_mem_address_o,
		data_mem_write_o   => data_mem_write_o,
		data_mem_read_i    => data_mem_read_i,
		-- kontrolni signali
		mem_to_reg_i       =>
		alu_op_i           =>
		alu_src_b_i        =>
		pc_next_sel_i      =>
		rd_we_i            =>
		branch_condition_o =>
		-- kontrolni signali za prosledjivanje operanada u ranije faze protocneobrade
		alu_forward_a_i    =>
		alu_forward_b_i    =>
		branch_forward_a_i =>
		branch_forward_b_i =>
		-- kontrolni signal za resetovanje if/id registra
		if_id_flush_i =>
		-- kontrolni signali za zaustavljanje protocne obrade
		pc_en_i    =>
		if_id_en_i =>
);

control: entity work.control_path
port map(
-- sinhronizacija
		clk   =>
		reset =>
		-- instrukcija dolazi iz datapah-a
		instruction_i =>
		-- Statusni signaln iz datapath celine
		branch_condition_i =>
		-- kontrolni signali koji se prosledjiuju u datapath
		mem_to_reg_o  =>
		alu_op_o      =>
		alu_src_b_o   =>
		rd_we_o       =>
		pc_next_sel_o =>
		data_mem_we_o =>
		-- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
		alu_forward_a_o    =>
		alu_forward_b_o    =>
		branch_forward_a_o =>
		branch_forward_b_o =>
		-- kontrolni signal za resetovanje if/id registra
		if_id_flush_o =>
		-- kontrolni signali za zaustavljanje protocne obrade
		pc_en_o    =>
		if_id_en_o =>
);

end structural;