----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/27/2023 06:54:11 PM
-- Design Name: 
-- Module Name: My_test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity My_test is
--  Port ( );
end My_test;

architecture Behavioral of My_test is

signal clk_s: std_logic;
signal reset_s : std_logic;
		-- Interfejs ka memoriji za podatke
signal instr_mem_address_o_s :  std_logic_vector(31 downto 0);
signal		instr_mem_read_i_s    :  std_logic_vector(31 downto 0);
signal		data_mem_address_o_s :  std_logic_vector(31 downto 0);
signal		data_mem_read_i_s    :  std_logic_vector(31 downto 0);
signal 		data_mem_write_o_s   :  std_logic_vector(31 downto 0);
signal		data_mem_we_o_s      :  std_logic_vector(3 downto 0);

begin

clk_proc : process
begin
    clk_s <= '1', '0' after 100 ns;
    wait for 200 ns;
end process;


signal_gen: process
begin

    reset_s <= '0';
    data_mem_read_i_s <= (others => '0');
    
    wait for 150ns;
    reset_s<= '1';
    instr_mem_read_i_s <= "00000000000100000000000010010011";
    wait for 200ns;
    instr_mem_read_i_s <= "00000000001000000000000100010011";
    wait for 200ns;
    instr_mem_read_i_s <= "00000000000100010000000110110011";
    wait for 200ns;
    instr_mem_read_i_s <= "00000000000000000001001000110111";
    wait for 200ns;
    instr_mem_read_i_s <= "00000000000000000010001010010111";
    wait for 200ns;
    instr_mem_read_i_s <= (others => '0');
    

wait;
end process;

procesor: entity work.TOP_RISCV
port map(
		clk  => clk_s,
		reset => reset_s,
		-- Interfejs ka memoriji za podatke
		instr_mem_address_o=> instr_mem_address_o_s,
		instr_mem_read_i    => instr_mem_read_i_s,
		-- Interfejs ka memoriji za instrukcije
		data_mem_address_o => data_mem_address_o_s,
		data_mem_read_i   => data_mem_read_i_s,
		data_mem_write_o   => data_mem_write_o_s,
		data_mem_we_o   => data_mem_we_o_s
);


end Behavioral;
