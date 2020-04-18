LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU IS
    GENERIC (
        LENGTH : NATURAL := 32
    );
    PORT (
        A, B : IN STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
        OPE : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        RESULT_L : OUT STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
        FLAGS : OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
    );
END ALU;

ARCHITECTURE Behavioral OF ALU IS
    SIGNAL OPE_RESUTL : std_logic_vector ((2 * LENGTH - 1) DOWNTO 0);
BEGIN
    RESULT_L <= OPE_RESUTL(LENGTH - 1 DOWNTO 0);

    ALU_OPE : PROCESS (A, B, OPE)
        variable VAR_OPE_RESUTL: std_logic_vector((2 * LENGTH - 1) downto 0);
    BEGIN
        FLAGS <= (OTHERS => '0');
        VAR_OPE_RESUTL := (OTHERS => '0');
        
        CASE OPE IS
            WHEN "000" => -- Suma
                VAR_OPE_RESUTL(LENGTH - 1 DOWNTO 0) := A + B;
            WHEN "001" => -- Resta
                VAR_OPE_RESUTL(LENGTH - 1 DOWNTO 0) := A - B;
            WHEN "010" => -- Multiplicacion
                VAR_OPE_RESUTL := A * B;
            WHEN "011" => --INCREMENT
                VAR_OPE_RESUTL(LENGTH - 1 DOWNTO 0) := A + 1;
            WHEN "100" => -- XOR
                VAR_OPE_RESUTL(LENGTH - 1 DOWNTO 0) := A XOR B;
            WHEN "101" => -- OR
                VAR_OPE_RESUTL(LENGTH - 1 DOWNTO 0) := A OR B;
            WHEN "110" => --AND
                VAR_OPE_RESUTL(LENGTH - 1 DOWNTO 0) := A AND B;
            WHEN "111" => --NOT
                VAR_OPE_RESUTL(LENGTH - 1 DOWNTO 0) := NOT A;
            WHEN OTHERS =>
                VAR_OPE_RESUTL(LENGTH - 1 DOWNTO 0) := A;
        END CASE;
        
        IF to_integer(unsigned(VAR_OPE_RESUTL)) = 0 THEN
            FLAGS(0) <= '1';
        ELSE
            FLAGS(0) <= '0';
        END IF;
        
        OPE_RESUTL <= VAR_OPE_RESUTL;
    END PROCESS;

END Behavioral;