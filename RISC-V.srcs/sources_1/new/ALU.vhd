library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity ALU is
	generic (
		WIDTH : natural := 32
	);
	port (
		a_i    : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0); --prvi operand
		b_i    : in STD_LOGIC_VECTOR(WIDTH - 1 downto 0); --drugi operand
		op_i   : in STD_LOGIC_VECTOR(3 downto 0); --port za izbor operacije
		res_o  : out STD_LOGIC_VECTOR(WIDTH - 1 downto 0); --rezultat
		zero_o : out STD_LOGIC; -- signal da je rezultat nula
	of_o   : out STD_LOGIC); -- signal da je doslo do prekoracenja opsega
end ALU;
architecture behav of ALU is
	signal zeros : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
begin
	process (a_i, b_i, op_i) is
	begin
		case op_i is
			when "0000" => res_o <= std_logic_vector(signed(a_i) + signed(b_i));
			when "0001" => res_o <= std_logic_vector(signed(a_i) - signed(b_i));
			when "0010" => res_o <= a_i sll to_integer(unsigned(b_i));
			when "0110" => res_o <= std_logic_vector(to_signed(1, 32)) when signed(a_i) < signed(b_i) else
				std_logic_vector(to_signed(0, 32));
			when "0111" => res_o <= std_logic_vector(to_signed(1, 32)) when unsigned(a_i) < unsigned(b_i) else
				std_logic_vector(to_signed(0, 32));
			when "1000" => res_o <= a_i xor b_i;
			when "1010" => res_o <= a_i srl to_integer(unsigned(b_i));
			when "1011" => res_o <= std_logic_vector(signed(a_i) sra to_integer(unsigned(b_i)));
			when "1100" => res_o <= a_i or b_i;
			when "1110" => res_o <= a_i and b_i;
			when others => res_o <= (others => '0');
		end case;
		--If the sum of two positive numbers yields a negative result, the sum has overflowed.
		--If the sum of two negative numbers yields a positive result, the sum has overflowed.
		--Otherwise, the sum has not overflowed.
		--
		-- if (a_i(WIDTH - 1) = b_i(WIDTH - 1) and alu_res(WIDTH-1) /= a_i(WIDTH-1)) then
		-- of_o <= '1';
		-- else
		-- of_o <= '0';
		-- end if;

	end process;
	
	zero_flag : process (a_i, b_i, op_i)
	begin
		if (std_logic_vector(signed(a_i) + signed(b_i)) = zeros and op_i = "0000") then
			zero_o <= '1';
		elsif (std_logic_vector(signed(a_i) - signed(b_i)) = zeros and op_i = "0001") then
			zero_o <= '1';
		elsif ((a_i sll to_integer(unsigned(b_i)) = zeros and op_i = "0010")) then
			zero_o <= '1';
		elsif ((a_i xor b_i) = zeros and op_i = "1000") then
			zero_o <= '1';
		elsif ((a_i srl to_integer(unsigned(b_i)) = zeros) and op_i = "101") then
			zero_o <= '1';
		elsif ((std_logic_vector(signed(a_i) sra to_integer(unsigned(b_i)))) = zeros and op_i = "1011") then
			zero_o <= '1';
		elsif ((a_i or b_i) = zeros and op_i = "1100") then
			zero_o <= '1';
		elsif ((a_i and b_i) = zeros and op_i = "1110") then
			zero_o <= '1';
		else
			zero_o <= '0';
		end if;
		
	end process;
end behav;