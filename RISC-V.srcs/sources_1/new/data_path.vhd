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
		-- kontrolni signali za prosledjivanje operanada u ranije faze protocneobrade
		alu_forward_a_i    : in std_logic_vector (1 downto 0);
		alu_forward_b_i    : in std_logic_vector (1 downto 0);
		branch_forward_a_i : in std_logic;
		branch_forward_b_i : in std_logic;
		-- kontrolni signal za resetovanje if/id registra
		if_id_flush_i : in std_logic;
		-- kontrolni signali za zaustavljanje protocne obrade
		pc_en_i    : in std_logic;
		if_id_en_i : in std_logic;
		-- kontrolni izlazi za grananje
		branch_condition_o : out std_logic
	);
end entity;

architecture behav of data_path is

	signal program_counter                     : std_logic_vector(31 downto 0) := (others => '0');

	signal IF_ID_reg                           : std_logic_vector(31 downto 0);
	signal ID_EX_reg                           : std_logic_vector(127 downto 0);
	signal EX_MEM_reg                          : std_logic_vector(95 downto 0);
	signal MEM_WB_reg                          : std_logic_vector(95 downto 0);

	signal rs1_data                            : std_logic_vector(31 downto 0);
	signal rs2_data                            : std_logic_vector(31 downto 0);
	signal rs1_address                         : std_logic_vector(4 downto 0);
	signal rs2_address                         : std_logic_vector(4 downto 0);
	signal rd_address                          : std_logic_vector(4 downto 0);
	signal rd_data                             : std_logic_vector(31 downto 0);

	signal immediate                           : std_logic_vector(31 downto 0);

	signal branch_comp_a, branch_comp_b        : std_logic_vector(31 downto 0); -- input signals for comparator calculating branch_condition
	signal alu_a, alu_b, alu_b_intern, alu_out : std_logic_vector(31 downto 0); -- signals for connecting ALU sorces

	signal wb_forward_data, mem_forward_data   : std_logic_vector(31 downto 0);
    signal shifted_immediate : std_logic_vector(31 downto 0);
    signal mem_wb_rd_data_s : std_logic_vector(31 downto 0);
    
    signal pc_next_s : std_logic_vector(31 downto 0);
    signal pc_last : std_logic_vector(31 downto 0);
begin
	
	prog_cntr : process(clk)
	begin
	
	   if(rising_edge(clk)) then	       
	       if(reset = '0') then
	           program_counter <= (others => '0');	
	       elsif(pc_en_i = '1' and reset = '1') then
	           program_counter <= pc_next_s;
	       end if; 
	   end if;

	end process;
	
	PC_sync: process(clk)
    begin
    
        if(rising_edge(clk)) then
            if(pc_en_i = '1') then
                case pc_next_sel_i is
                    when '0' =>  pc_next_s <= std_logic_vector(unsigned(program_counter) +4);
                    when '1' =>  pc_next_s <= std_logic_vector(signed(pc_last) + signed(immediate));
                    when others => pc_next_s <= (others => '0');
                end case;
            end if;
        end if; 
    
    end process;
	
--        with pc_next_sel_i select
--            pc_next_s <= std_logic_vector(unsigned(program_counter) +4) when '0' ,
--            std_logic_vector(signed(pc_last) + signed(immediate)) when '1' ,
--            (others => '0') when others;

    pc_last <= program_counter when rising_edge(clk);    
        
    instr_mem_address_o <= program_counter;
    shifted_immediate <= immediate(30 downto 0 ) & '0';
	
	IF_ID : process (clk, IF_ID_reg)
	begin
		
		if(rising_edge(clk)) then
		
              if(reset = '0') then
                  IF_ID_reg <= (others => '0');
              elsif(if_id_flush_i = '1') then
                  IF_ID_reg <= (others => '0');
              elsif(if_id_en_i = '1') then    
                   IF_ID_reg <= instr_mem_read_i;  
              end if;
		
		end if;
        
            rs1_address <= IF_ID_reg(19 downto 15);
            rs2_address <= IF_ID_reg(24 downto 20);
                
	end process;
	
    instruction_o <= IF_ID_reg(31 downto 0);

	ID_EX : process (clk)
	begin

			if (rising_edge(clk)) then
			    if(reset = '1') then
				    ID_EX_reg <= rs1_data & rs2_data & immediate & IF_ID_reg(31 downto 0);
				else
				    ID_EX_reg <= (others => '0');
				end if;
 
			end if;
    
end process;

with alu_forward_a_i select
    alu_a <= ID_EX_reg(127 downto 96) when "00",
    wb_forward_data when "01",
    mem_forward_data when "10",
    (others => '0') when others;

with alu_forward_b_i select
    alu_b_intern <= ID_EX_reg(95 downto 64) when "00",
    wb_forward_data when "01",
    mem_forward_data when "10",
    (others => '0') when others;



    alu_b <= alu_b_intern when alu_src_b_i = '0' else ID_EX_reg(63 downto 32); -- immediate


	EX_MEM : process (clk,EX_MEM_reg)
	begin
			if (rising_edge(clk)) then
                if(reset = '1') then
				    EX_MEM_reg <= alu_out & ID_EX_reg(95 downto 64) & ID_EX_reg(31 downto 0); -- alu_out & rs2_data & instruction 
                else
                    EX_MEM_reg <= (others => '0');
                end if;    
			end if;

		mem_forward_data   <= EX_MEM_reg(95 downto 64); -- alu out
		data_mem_address_o <= EX_MEM_reg(95 downto 64); -- -||-
		data_mem_write_o   <= EX_MEM_reg(63 downto 32);  -- rs2 out
 

	end process;

	MEM_WB : process (clk)
	begin
			if (rising_edge(clk)) then
                if(reset = '1') then
				    MEM_WB_reg <= EX_MEM_reg(95 downto 64) & data_mem_read_i & EX_MEM_reg(31 downto 0);  -- alu out & mem data & instruction
                else
                    MEM_WB_reg <= (others => '0');
                end if;
			end if;    
	end process;
	
 wb_mux:    mem_wb_rd_data_s <= MEM_WB_reg(95 downto 64) when mem_to_reg_i = '0' else data_mem_read_i; -- alu out or mem data
            wb_forward_data <= MEM_WB_reg(95 downto 64) when mem_to_reg_i = '0' else data_mem_read_i;
            rd_address      <= MEM_WB_reg(11 downto 7); -- rd field in instruction 
            
-- Building blocks from other files

Reg_bank : entity work.register_bank
port map(
    clk           => clk, 
    reset         => reset, 
    rs1_address_i => rs1_address, 
    rs2_address_i => rs2_address, 
    rs1_data_o    => rs1_data, 
    rs2_data_o    => rs2_data, 
    rd_we_i       => rd_we_i, 
    rd_address_i  => rd_address, 
    rd_data_i     => rd_data
);

Imm_gen : entity work.immediate
port map(
    instruction_i        => IF_ID_reg(31 downto 0), 
    immediate_extended_o => immediate
);

ALU_entity : entity work.ALU
port map(
    a_i    => alu_a, 
    b_i    => alu_b, 
    op_i   => alu_op_i, 
    res_o  => alu_out, 
    zero_o => open, 
    of_o   => open
);

branch: entity work.branching_unit
port map(
    rs1_data_i => rs1_data,
    rs2_data_i => rs2_data,
    mem_data_i => EX_MEM_reg(95 downto 64), -- alu_result   
    funct3_i => IF_ID_reg(14 downto 12),     
    branch_forward_a_i => branch_forward_a_i,
    branch_forward_b_i => branch_forward_b_i,
    branch_condition_o  => branch_condition_o,
    opcode_i => IF_ID_reg(6 downto 0)
);

load: entity work.load_unit
port map(
    wb_data_i => mem_wb_rd_data_s,
    wb_opcode_i => MEM_WB_reg(6 downto 0),
    wb_funct3_i => MEM_WB_reg(14 downto 12),
    rd_we_i => rd_we_i,
    reg_bank_data_o => rd_data
);

end behav;