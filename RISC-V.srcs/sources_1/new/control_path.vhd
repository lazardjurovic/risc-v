library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_path is
	port (
		-- sinhronizacija
		clk   : in std_logic;
		reset : in std_logic;
		-- instrukcija dolazi iz datapah-a
		instruction_i : in std_logic_vector (31 downto 0);
		branch_condition_i : in std_logic;
		-- kontrolni signali koji se prosledjiuju u datapath
		mem_to_reg_o  : out std_logic;
		alu_op_o      : out std_logic_vector(4 downto 0);
		alu_src_b_o   : out std_logic;
		rd_we_o       : out std_logic;
		pc_next_sel_o : out std_logic;
		data_mem_we_o : out std_logic_vector(3 downto 0);
		-- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
		alu_forward_a_o    : out std_logic_vector (1 downto 0);
		alu_forward_b_o    : out std_logic_vector (1 downto 0);
		branch_forward_a_o : out std_logic; -- mux a
		branch_forward_b_o : out std_logic; -- mux b
		-- kontrolni signal za resetovanje if/id registra
		if_id_flush_o : out std_logic;
		-- kontrolni signali za zaustavljanje protocne obrade
		pc_en_o    : out std_logic;
		if_id_en_o : out std_logic
	);
end entity;

architecture behav of control_path is

signal ID_EX_reg : std_logic_vector(31 downto 0); 
signal EX_MEM_reg : std_logic_vector(8 downto 0);
signal MEM_WB_reg : std_logic_vector(6 downto 0);

-- control decoder signals
-- innputs
signal mem_to_reg_id_s : std_logic := '0';
signal data_mem_we_id_s : std_logic_vector(1 downto 0) := "00";
signal rd_we_id_s : std_logic := '0';
signal alu_src_b_id_s : std_logic := '0';
signal branch_id_s : std_logic := '0' ;
signal alu_2bit_op_id_s : std_logic_vector(1 downto 0) := (others =>'0');
-- outputs 
signal rs1_in_use_id_s : std_logic := '0';
signal rs2_in_use_id_s : std_logic := '0';

-- hazard unit signals
-- inputs
-- outputs
signal control_pass_s : std_logic := '0';
 
-- forwarding unit signals
-- inputs
signal funct3_ex_s : std_logic_vector(2 downto 0) := (others =>'0');
signal funct7_ex_s : std_logic_vector(6 downto 0) := (others =>'0');
signal rd_address_wb_s : std_logic_vector(4 downto 0) := (others =>'0');
signal rd_we_wb_s : std_logic := '0';
signal rd_address_mem_s : std_logic_vector(4 downto 0) := (others =>'0');
signal rd_we_mem_s : std_logic := '0';

-- branching unit signals
--outputs
signal pc_next_sel_s : std_logic := '0';

begin

    -- TODO: solve control_pass signal as control of ID_EX_reg
    
    ID_EX : process(clk, reset, instruction_i, MEM_WB_reg, ID_EX_reg, branch_id_s)
    begin
    
        if(reset = '1') then
            if(rising_edge(clk)) then
                
                ID_EX_reg <= mem_to_reg_id_s & data_mem_we_id_s & rd_we_id_s & alu_src_b_id_s & alu_2bit_op_id_s &
                             instruction_i(14 downto 12) & instruction_i(31 downto 25) & instruction_i(11 downto 7) & instruction_i(19 downto 15) & instruction_i(24 downto 20);
                             
                 
            end if;
        else
            ID_EX_reg <= (others => '0');
        end if;
        
            alu_src_b_o <= ID_EX_reg (27);   
            
            pc_next_sel_s <= branch_condition_i and branch_id_s;
            
    end process;
    
    pc_next_sel_o <= pc_next_sel_s;
    if_id_flush_o <= pc_next_sel_s;
    
    EX_MEM: process(clk,reset, ID_EX_reg, EX_MEM_reg)
    begin
        
        if(reset = '1') then
            
            if(rising_edge(clk)) then
                
                EX_MEM_reg <= ID_EX_reg(31) & ID_EX_reg(30 downto 29) & ID_EX_reg(28) & ID_EX_reg(14 downto 10); -- mem_to_reg & data_mem_we_id & rd_ex & rd_address
                
            end if; 
        else
            EX_MEM_reg <= (others => '0');    
        end if;
        
            case EX_MEM_reg(7 downto 6) is
                when "00" => data_mem_we_o <= (others => '0');
                when "01" => data_mem_we_o <= "0001"; -- SB
                when "10" => data_mem_we_o <= "0011"; -- SH
                when "11" => data_mem_we_o <= "1111"; -- SW
                when others => data_mem_we_o <= (others => '0');
            end case;
            rd_we_mem_s <= EX_MEM_reg(5);
            rd_address_mem_s <= EX_MEM_reg(4 downto 0);
    
    end process;
    
    MEM_WB: process(clk,reset, EX_MEM_reg, MEM_WB_reg)
    begin
    
        if(reset = '1') then
        
            if(rising_edge(clk)) then
                
                MEM_WB_reg <= EX_MEM_reg(7) & EX_MEM_reg(5) & EX_MEM_reg(4 downto 0);
                
            end if; 
        else
            MEM_WB_reg <= (others => '0');
        end if;
        
        mem_to_reg_o <= MEM_WB_reg(6);
        rd_we_o <= MEM_WB_reg(5);
        rd_we_wb_s <= MEM_WB_reg(5);
        rd_address_wb_s <= MEM_WB_reg(4 downto 0);
        

    end process;
    
-- Other prewritten entities

ctrl_dec: entity work.ctrl_decoder
port map(
    opcode_i => instruction_i(6 downto 0),
    funct3_id_i => instruction_i(14 downto 12),
    branch_o   => branch_id_s,
    mem_to_reg_o  => mem_to_reg_id_s,
    data_mem_we_o => data_mem_we_id_s,
    alu_src_b_o  => alu_src_b_id_s,
    rd_we_o      => rd_we_id_s,
    rs1_in_use_o  => rs1_in_use_id_s,
    rs2_in_use_o   => rs2_in_use_id_s,
    alu_2bit_op_o  => alu_2bit_op_id_s
);

forward: entity work.forwarding_unit
port map(
    -- ulazi iz ID faze
    rs1_address_id_i => instruction_i(19 downto 15),
    rs2_address_id_i => instruction_i(24 downto 20),
    -- ulazi iz EX faze
    rs1_address_ex_i => ID_EX_reg(9 downto 5),
    rs2_address_ex_i => ID_EX_reg(4 downto 0),
    -- ulazi iz MEM faze
    rd_we_mem_i     => rd_we_mem_s,
    rd_address_mem_i => rd_address_mem_s,
    -- ulazi iz WB faze
    rd_we_wb_i     => rd_we_wb_s,
    rd_address_wb_i => rd_address_wb_s,
    -- izlazi za prosledjivanje operanada ALU jedinici
    alu_forward_a_o => alu_forward_a_o,
    alu_forward_b_o => alu_forward_b_o,
    -- izlazi za prosledjivanje operanada komparatoru za odredjivanje uslova skoka
    branch_forward_a_o => branch_forward_a_o,
    branch_forward_b_o => branch_forward_b_o
);

alu_dec: entity work.alu_decoder
port map(
    --******** Controlpath ulazi *********
    alu_2bit_op_i => ID_EX_reg(26 downto 25),
    --******** Polja instrukcije *******
    funct3_i => ID_EX_reg(24 downto 22),
    funct7_i => ID_EX_reg(21 downto 15),
    --******** Datapath izlazi ********
    alu_op_o => alu_op_o
);

hazard: entity work.hazard_unit
port map(
    -- ulazni signali
    rs1_address_id_i => instruction_i(19 downto 15),
    rs2_address_id_i => instruction_i(24 downto 20),
    rs1_in_use_i     => rs1_in_use_id_s,
    rs2_in_use_i     => rs2_in_use_id_s,
    branch_id_i      => branch_id_s,
    rd_address_ex_i  => ID_EX_reg(14 downto 10),
    mem_to_reg_ex_i  => ID_EX_reg(1),
    rd_we_ex_i       => ID_EX_reg(3),
    rd_address_mem_i => EX_MEM_reg(4 downto 0),
    mem_to_reg_mem_i => EX_MEM_reg(0),
    -- izlazni kontrolni signali
    -- pc_en_o je signal dozvole rada za pc registar
    pc_en_o => pc_en_o,
    -- if_id_en_o je signal dozvole rada za if/id registar
    if_id_en_o => if_id_en_o,
    -- control_pass_o kontrolise da li ce u execute fazu biti prosledjeni
    -- kontrolni signali iz ctrl_decoder-a ili sve nule
    control_pass_o => control_pass_s
);


end behav;