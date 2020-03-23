LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY PC IS
    GENERIC (
        SIZE : NATURAL := 10 -- Depende del tamano de la memoria de prog. log2(1024) = 10
    );
    PORT (
        I_DIR : IN STD_LOGIC_VECTOR (SIZE - 1 DOWNTO 0);
        ENABLE, WE : IN STD_LOGIC;
        RST, CLK : IN STD_LOGIC;
        O_DIR : OUT STD_LOGIC_VECTOR (SIZE - 1 DOWNTO 0)
    );
END PC;

ARCHITECTURE Behavioral OF PC IS
    SIGNAL DIR : STD_LOGIC_VECTOR (SIZE - 1 DOWNTO 0);
BEGIN
    O_DIR <= DIR;

    pc_process : PROCESS (CLK, RST)
    BEGIN
        IF RST = '1' THEN
            DIR <= (OTHERS => '0');
        ELSIF ENABLE = '1' AND rising_edge(CLK) THEN
            IF WE = '1' THEN
                DIR <= I_DIR;
            ELSE
                DIR <= DIR + '1';
            END IF;

        END IF;
    END PROCESS;

END Behavioral;