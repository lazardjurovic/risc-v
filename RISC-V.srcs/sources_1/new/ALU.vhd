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
			when others => res_o    <= (others => '0');
		end case;
 
		--If the sum of two positive numbers yields a negative result, the sum has overflowed.
		--If the sum of two negative numbers yields a positive result, the sum has overflowed.
		--Otherwise, the sum has not overflowed.
 
		--If 2 Two's Complement numbers are subtracted, and their signs are different,
		--then overflow occurs if and only if the result has the same sign as the subtrahend.
 
		if (a_i(WIDTH - 1) = b_i(WIDTH - 1) and res_o(WIDTH - 1) /= a_i(WIDTH - 1)) then
			of_o <= '1';
		elsif (a_i(WIDTH - 1) /= b_i(WIDTH - 1) and b_i(WIDTH - 1) = res_o(WIDTH - 1)) then
			of_o <= '1';
		else
			of_o <= '0';
		end if;
 
		zero_o <= '1' when res_o = zeros else '0';
 
	end process;
 
end behav;