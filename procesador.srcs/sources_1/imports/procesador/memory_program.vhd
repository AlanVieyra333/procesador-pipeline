LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEMORY_PROG IS
    GENERIC (
        WORD_LENGTH : NATURAL := 42;
        MEM_SIZE : NATURAL := 1024;
        DIR_LENGTH : NATURAL := 10 -- log(RAM_SIZE)
    );
    PORT (
        DIR : IN STD_LOGIC_VECTOR (DIR_LENGTH - 1 DOWNTO 0);
        O_DATA : OUT STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0)
    );
END MEMORY_PROG;

ARCHITECTURE Behavioral OF MEMORY_PROG IS
    TYPE MEM_T IS ARRAY (0 TO MEM_SIZE) OF STD_LOGIC_VECTOR(WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL DATA : MEM_T := (OTHERS => (OTHERS => '1'));
BEGIN
    -- Programa de prueba.
    DATA <= (
        "00001" & "00001" & "00000" & "11111" & "00" & x"03" & x"FFF",   -- LW R1, 3(R0)
        "00001" & "00010" & "00000" & "11111" & "00" & x"04" & x"FFF",   -- LW R2, 4(R0)
        "00001" & "00011" & "00000" & "11111" & "00" & x"05" & x"FFF",   -- LW R3, 5(R0)
        (OTHERS => '1'), -- NOP
        "01001" & "00001" & "00001" & x"FFFFFF" & "111", -- INC R1, R1
        "01010" & "11111" & "00001" & "00001" & "1111101001" & x"FFF", -- BNEI R1, R1, -5 //0 (DIR-2)
        "00011" & "00001" & "00010" & "00011" & x"FFFFF" & "11", -- ADD R1, R2, R3
        "00011" & "00100" & "00001" & "00010" & x"FFFFF" & "11", -- ADD R4, R1, R2
        "01100" & "00101" & "00010" & "00011" & x"FFFFF" & "11", -- XOR R5, R2, R3
        "01011" & "11111" & "11111" & "11111" & "0000000110" & x"FFF", -- B +6
        "00011" & "00110" & "00011" & "00010" & x"FFFFF" & "11", -- ADD R6, R3, R2
        "00100" & "00111" & "00001" & "00011" & x"FFFFF" & "11", -- SUB R7, R1, R3
        "00110" & "01000" & "00010" & "00011" & x"FFFFF" & "11", -- OR  R8, R2, R3
        (OTHERS => '1'), -- STALL
        (OTHERS => '1'), -- STALL
        "00010" & "1111111111" & "0" & x"4" & "0000000011" & x"FFF", -- SWI R4, 3
        "00010" & "1111111111" & "0" & x"5" & "0000000100" & x"FFF", -- SWI R5, 4
        "00010" & "1111111111" & "0" & x"6" & "0000000101" & x"FFF", -- SWI R6, 5
        "00010" & "1111111111" & "0" & x"7" & "0000000110" & x"FFF", -- SWI R7, 6
        "00010" & "1111111111" & "0" & x"8" & "0000000111" & x"FFF", -- SWI R8, 7
        OTHERS => (OTHERS => '1'));
    
    MEM_LOAD : PROCESS (DIR)
    BEGIN
        O_DATA <= DATA(to_integer(unsigned(DIR)));
    END PROCESS;
END Behavioral;