LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY DECODIFICADOR IS
    GENERIC (
        ENC_LENGTH : NATURAL := 4; -- logs(DEC_LENGTH)
        DEC_LENGTH : NATURAL := 16
    );
    PORT (
        ENCODED : IN STD_LOGIC_VECTOR (ENC_LENGTH - 1 DOWNTO 0);
        DECODED : OUT STD_LOGIC_VECTOR (DEC_LENGTH - 1 DOWNTO 0));
END DECODIFICADOR;

ARCHITECTURE Behavioral OF DECODIFICADOR IS

BEGIN
    PROCESS (ENCODED)
        VARIABLE idx : INTEGER := 0;
    BEGIN
        DECODED <= (OTHERS => '0');

        idx := to_integer(unsigned(ENCODED));

        DECODED(idx) <= '1';
    END PROCESS;

END Behavioral;