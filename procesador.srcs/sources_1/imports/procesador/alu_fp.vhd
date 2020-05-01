LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU_FP IS
    GENERIC (
        LENGTH : NATURAL := 32
    );
    PORT (
        A, B : IN STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
        OPE : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        RESULT_L : OUT STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
        FLAGS : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)   -- N,C
    );
END ALU_FP;

ARCHITECTURE Behavioral OF ALU_FP IS
    SIGNAL OPE_RESUTL : std_logic_vector ((2 * LENGTH - 1) DOWNTO 0);
BEGIN
    RESULT_L <= OPE_RESUTL( (2 * LENGTH - 1) DOWNTO LENGTH) when (OPE = "10")
        else OPE_RESUTL(LENGTH - 1 DOWNTO 0);
 --   RESULT_L <= OPE_RESUTL(LENGTH - 1 DOWNTO 0);

    ALU_OPE : PROCESS (A, B, OPE)
        variable VAR_OPE_RESUTL: std_logic_vector((2 * LENGTH - 1) downto 0);
    BEGIN
        FLAGS <= (OTHERS => '0');
        VAR_OPE_RESUTL := (OTHERS => '0');
        
        CASE OPE IS
            WHEN "00" => -- Suma
                VAR_OPE_RESUTL(LENGTH DOWNTO 0) := ('0' & A) + ('0' & B);
                
                FLAGS(0) <= VAR_OPE_RESUTL(LENGTH); -- C
                FLAGS(1) <= VAR_OPE_RESUTL(LENGTH); -- N
            WHEN "01" => -- Resta
                VAR_OPE_RESUTL(LENGTH DOWNTO 0) := ('0' & A) - ('0' & B);
                
                FLAGS(0) <= VAR_OPE_RESUTL(LENGTH); -- C
                FLAGS(1) <= VAR_OPE_RESUTL(LENGTH); -- N
            WHEN "10" => -- Multiplicacion
                VAR_OPE_RESUTL := std_logic_vector( unsigned(A) * unsigned(B) );
                
                FLAGS(0) <= VAR_OPE_RESUTL(2 * LENGTH - 1); -- C
                FLAGS(1) <= VAR_OPE_RESUTL(2 * LENGTH - 1); -- N
            WHEN OTHERS =>
                VAR_OPE_RESUTL(LENGTH DOWNTO 0) := '0' & A;
                
                FLAGS(0) <= VAR_OPE_RESUTL(LENGTH); -- C
                FLAGS(1) <= VAR_OPE_RESUTL(LENGTH); -- N
        END CASE;
        
        
        OPE_RESUTL <= VAR_OPE_RESUTL;
    END PROCESS;

END Behavioral;
