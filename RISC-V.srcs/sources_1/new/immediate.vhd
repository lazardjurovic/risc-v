library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity immediate is
	port (
		instruction_i        : in std_logic_vector (31 downto 0);
		immediate_extended_o : out std_logic_vector (31 downto 0)
	);
end entity;
architecture behav of immediate is
	signal ones  : std_logic_vector(19 downto 0) := (others => '1');
	signal zeros : std_logic_vector(19 downto 0) := (others => '0');
begin
	process (instruction_i) is
	begin
		case instruction_i(6 downto 0) is -- checking opcode
			when "0000011" | "0010011" | "1100111" => -- JALR, loads, immediate ALU instructions
				if (instruction_i(31) = '0') then
					immediate_extended_o <= zeros & instruction_i(31 downto 20);
				else
					immediate_extended_o <= ones & instruction_i(31 downto 20);
				end if;
			when "1100011" => -- branches
				if (instruction_i(31) = '0') then
					immediate_extended_o <= zeros(18 downto 0) & instruction_i(31) & instruction_i(7) & instruction_i(30 downto 25) & instruction_i(11 downto 8) & '0';
				else
					immediate_extended_o <= ones(18 downto 0) & instruction_i(31) & instruction_i(7) & instruction_i(30 downto 25) & instruction_i(11 downto 8) & '0';
				end if;
			when "0100011" => -- store
				if (instruction_i(31) = '0') then
					immediate_extended_o <= zeros & instruction_i(31 downto 25) & instruction_i(11 downto 7);
				else
					immediate_extended_o <= ones & instruction_i(31 downto 25) & instruction_i(11 downto 7);
				end if;
			when "0110111" | "0010111" => -- LUI, AUIPC
				if (instruction_i(31) = '0') then
					immediate_extended_o <= instruction_i(31 downto 12) & zeros(11 downto 0);
				else
					immediate_extended_o <= instruction_i(31 downto 12) & ones(11 downto 0);
				end if;
			when "1101111" => -- JAL
				if (instruction_i(31) = '0') then
					immediate_extended_o <= zeros(10 downto 0) & instruction_i(31) & instruction_i(19 downto 12) & instruction_i(20) & instruction_i(30 downto 21) & '0';
				else
					immediate_extended_o <= ones(10 downto 0) & instruction_i(31) & instruction_i(19 downto 12) & instruction_i(20) & instruction_i(30 downto 21) & '0';
				end if;
			when others => null;


		end case;
	end process;
end behav;