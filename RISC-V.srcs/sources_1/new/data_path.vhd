library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_path is
	port (
		-- sinhronizacioni signali
		clk   : in std_logic;
		reset : in std_logic;
		-- interfejs ka memoriji za instrukcije
		instr_mem_address_o : out std_logic_vector (31 downto 0);
		instr_mem_read_i    : in std_logic_vector(31 downto 0);
		instruction_o       : out std_logic_vector(31 downto 0);
		-- interfejs ka memoriji za podatke
		data_mem_address_o : out std_logic_vector(31 downto 0);
		data_mem_write_o   : out std_logic_vector(31 downto 0);
		data_mem_read_i    : in std_logic_vector (31 downto 0);
		-- kontrolni signali
		mem_to_reg_i       : in std_logic;
		alu_op_i           : in std_logic_vector (4 downto 0);
		alu_src_b_i        : in std_logic;
		pc_next_sel_i      : in std_logic;
		rd_we_i            : in std_logic;
		branch_condition_o : out std_logic;
		-- kontrolni signali za prosledjivanje operanada u ranije faze protocneobrade
		alu_forward_a_i    : in std_logic_vector (1 downto 0);
		alu_forward_b_i    : in std_logic_vector (1 downto 0);
		branch_forward_a_i : in std_logic;
		branch_forward_b_i : in std_logic;
		-- kontrolni signal za resetovanje if/id registra
		if_id_flush_i : in std_logic;
		-- kontrolni signali za zaustavljanje protocne obrade
		pc_en_i    : in std_logic;
		if_id_en_i : in std_logic
	);
end entity;

architecture behav of data_path is

signal program_counter : std_logic_vector(31 downto 0) := (others => '0');

signal IF_ID_reg : std_logic_vector(95 downto 0);
signal ID_EX_reg : std_logic;


signal  rs1_data : std_logic_vector(31 downto 0);
signal  rs2_data: std_logic_vector(31 downto 0);
signal  rs1_address : std_logic_vector(4 downto 0);
signal  rs2_address : std_logic_vector(4 downto 0);
signal  rd_address : std_logic_vector(4 downto 0);
signal  rd_data : std_logic_vector(31 downto 0);

signal immediate : std_logic_vector(31 downto 0);

signal branch_comp_a, branch_comp_b : std_logic_vector(31 downto 0); -- input signals for comparator calculating branch_condition

signal wb_data : std_logic_vector(31 downto 0);

begin

IF_ID: process(clk,instr_mem_read_i, if_id_flush_i, if_id_en_i, branch_forward_a_i, branch_forward_b_i)
begin

    if(if_id_flush_i = '1') then
        IF_ID_reg <= (others=> '0');
    else
        if(if_id_en_i = '1' and falling_edge(clk)) then
            IF_ID_reg <= instr_mem_read_i & program_counter & std_logic_vector( signed(immediate(30 downto 0)& '0') + signed(IF_ID_reg(63 downto 32)));
        end if;
    end if;
    
    if(branch_forward_a_i = '1') then
        branch_comp_a <= wb_data;
    else
        branch_comp_a <= rs1_data;
    end if;
    
    if(branch_forward_b_i = '1') then
          branch_comp_b <= wb_data;
    else
        branch_comp_b <= rs2_data;
    end if;
       
    branch_condition_o <= '1' when branch_comp_a = branch_comp_b else '0';
       
end process;

rs1_address <= IF_ID_reg(19 downto 15);
rs2_address <= IF_ID_reg(24 downto 20);
rd_address <= IF_ID_reg(11 downto 7);

ID_EX: process(clk, rs1_data, rs2_data, immediate)
begin

    

end process;


-- Building blocks from other files

Reg_bank: entity work.register_bank 
port map(
    clk => clk,
    reset => reset,
    rs1_address_i => rs1_address,
    rs2_address_i => rs2_address,
    rs1_data_o => rs1_data,
    rs2_data_o => rs2_data,
    rd_we_i => rd_we_i,
    rd_address_i => rd_address,
    rd_data_i => rd_data
);

Imm_gen: entity work.immediate
port map(
    instruction_i => IF_ID_reg(31 downto 0),
    immediate_extended_o => immediate
);

end behav;