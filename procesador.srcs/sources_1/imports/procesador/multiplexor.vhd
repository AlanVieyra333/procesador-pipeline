LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MULTIPLEXOR IS
    GENERIC (
        SIZE : NATURAL := 16;
        SEL_LENGTH : NATURAL := 4 -- log2(SIZE)
    );
    PORT (
        I_DATA : IN std_logic_vector(SIZE - 1 DOWNTO 0);
        SEL : IN std_logic_vector(SEL_LENGTH - 1 DOWNTO 0);
        O_DATA : OUT std_logic
    );
END MULTIPLEXOR;

ARCHITECTURE Behavioral OF MULTIPLEXOR IS
BEGIN

    O_DATA <= I_DATA(to_integer(unsigned(SEL)));

END Behavioral;