LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MULTIPLEXOR_2IN IS
    GENERIC (
        WORD_LENTH : NATURAL := 32
    );
    PORT (
        I_DATA_1 : IN std_logic_vector(WORD_LENTH - 1 DOWNTO 0);
        I_DATA_2 : IN std_logic_vector(WORD_LENTH - 1 DOWNTO 0);
        SEL : IN std_logic;
        O_DATA : OUT std_logic_vector(WORD_LENTH - 1 DOWNTO 0)
    );
END MULTIPLEXOR_2IN;

ARCHITECTURE Behavioral OF MULTIPLEXOR_2IN IS
BEGIN

    process (SEL, I_DATA_1, I_DATA_2)
	begin
		if SEL = '0' then
			O_DATA <= I_DATA_1;
		else
			O_DATA <= I_DATA_2;
		end if;
	end process;

END Behavioral;