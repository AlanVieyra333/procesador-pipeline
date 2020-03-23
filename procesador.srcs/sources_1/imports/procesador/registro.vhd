LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY REGISTRO IS
    GENERIC (
        LENGTH : NATURAL := 32
    );
    PORT (
        I_DATA : IN STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
        CLK, RST, WE : IN STD_LOGIC;
        O_DATA : OUT STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0)
    );
END REGISTRO;

ARCHITECTURE Behavioral OF REGISTRO IS
    SIGNAL Q : STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
BEGIN
    O_DATA <= Q;

    FLIP_FLOP : PROCESS (CLK, RST)
    BEGIN
        IF RST = '1' THEN
            Q <= (OTHERS => '0');
        ELSIF WE = '1' AND rising_edge(CLK) THEN
            Q <= I_DATA;
        END IF;
    END PROCESS;
END Behavioral;