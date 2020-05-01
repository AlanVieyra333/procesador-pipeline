library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;               -- Needed for shifts

entity carry_decoder is
    Port ( i_mantissa : in STD_LOGIC_VECTOR (23 downto 0);
           i_exponent : in STD_LOGIC_VECTOR (7 downto 0);
           carry : in STD_LOGIC;
           ope : in STD_LOGIC_vector(1 downto 0);
           o_mantissa : out STD_LOGIC_VECTOR (22 downto 0);
           o_exponent : out STD_LOGIC_VECTOR (7 downto 0));
end carry_decoder;

architecture Behavioral of carry_decoder is

begin

    CARRY_PROC : PROCESS (i_mantissa, i_exponent, carry)
        variable mantissa: std_logic_vector(23 downto 0);
        variable exponent : std_logic_vector(7 downto 0);
        variable exponent_aux : std_logic_vector(15 downto 0);
        variable i : integer;
    BEGIN
        IF carry = '1' THEN
            mantissa := std_logic_vector(unsigned(i_mantissa) srl 1);
            exponent := i_exponent + 1;
        ELSE
            mantissa := i_mantissa;
            exponent := i_exponent;
            i := 0;
            
            while (mantissa(23) = '0') and i <= 23 loop
                mantissa := std_logic_vector(unsigned(mantissa) sll 1);
                i := i + 1;
            end loop;
            
            if ope /= "10" then
                exponent := exponent - i;
            else
                exponent_aux := ( ((exponent - 127) * "00000010") + 127 );
                exponent := exponent_aux(7 downto 0) - i + 1;
            end if;
            
        END IF;
        
        o_mantissa <= mantissa(22 downto 0);
        o_exponent <= exponent;
    END PROCESS;

end Behavioral;
