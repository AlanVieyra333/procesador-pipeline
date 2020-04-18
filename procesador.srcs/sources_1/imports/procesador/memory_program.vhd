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
    -- Programa de factorial de n = 10.
    DATA <= (
        "00000" & "00000" & x"0000000a", -- LWI R0, #10
        "00000" & "00010" & x"00000001", -- LWI R2, #1
        "01011" & "11111" & "11111" & "11111" & "0000001000" & x"FFF", -- B +8     // goto FACTORIAL
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        -- MAIN:
        "01011" & "11111" & "11111" & "11111" & "0000000000" & x"FFF", -- B -0     // goto MAIN
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        -- FACTORIAL:
        "01110" & "11111" & "00010" & "00000" & "0000001001" & x"FFF", -- BLTI R2, R0, +9 // goto ELSE-1
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        "00000" & "00001" & x"00000001", -- LWI R1, #1
        "01011" & "11111" & "11111" & "11111" & "0000010001" & x"FFF", -- B +17     // goto ELSE-2
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        -- ELSE-1:
        "01000" & "11111" & "00011" & "00011" & "1000000000" & x"FFF", -- SW R3, 512(R3)  | Mem[R3 + 512] = R3
        "01000" & "11111" & "00011" & "00000" & "0000000000" & x"FFF", -- SW R0, 0(R3)    | Mem[R3 + 0] = R0
        "01001" & "00011" & "00011" & x"FFFFFF" & "111", -- INC R3, R3
        "00100" & "00000" & "00000" & "00010" & x"FFFFF" & "11", -- SUB R0, R0, R2
        "01011" & "11111" & "11111" & "11111" & "1111110011" & x"FFF", -- B -13     // goto FACTORIAL
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        -- CONTINUE:
        (OTHERS => '1'), -- NOP
        "00001" & "00100" & "00011" & "11111" & "00" & x"00" & x"FFF",   -- LW R4, 0(R3)
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        "00111" & "00001" & "00001" & "00100" & x"FFFFF" & "11", -- MUL R1, R1, R4
        -- ELSE-2:
        "01010" & "11111" & "00011" & "00101" & "1111111010" & x"FFF", -- BNEI R3, R5, -6 // goto CONTINUE
        "00100" & "00011" & "00011" & "00010" & x"FFFFF" & "11", -- SUB R3, R3, R2
        (OTHERS => '1'), -- NOP
        (OTHERS => '1'), -- NOP
        "01011" & "11111" & "11111" & "11111" & "1111100001" & x"FFF", -- B -30     // goto MAIN
        OTHERS => (OTHERS => '1'));
    
    -- Programa de prueba 1.
--    DATA <= (
--        "00001" & "00001" & "00000" & "11111" & "00" & x"03" & x"FFF",   -- LW R1, 3(R0)
--        "00001" & "00010" & "00000" & "11111" & "00" & x"04" & x"FFF",   -- LW R2, 4(R0)
--        "00001" & "00011" & "00000" & "11111" & "00" & x"05" & x"FFF",   -- LW R3, 5(R0)
--        (OTHERS => '1'), -- NOP
--        "01001" & "00001" & "00001" & x"FFFFFF" & "111", -- INC R1, R1
--        "01010" & "11111" & "00001" & "00001" & "1111101001" & x"FFF", -- BNEI R1, R1, -5 //0 (DIR-2)
--        "00011" & "00001" & "00010" & "00011" & x"FFFFF" & "11", -- ADD R1, R2, R3
--        "00011" & "00100" & "00001" & "00010" & x"FFFFF" & "11", -- ADD R4, R1, R2
--        "01100" & "00101" & "00010" & "00011" & x"FFFFF" & "11", -- XOR R5, R2, R3
--        "01011" & "11111" & "11111" & "11111" & "0000000110" & x"FFF", -- B +6
--        "00011" & "00110" & "00011" & "00010" & x"FFFFF" & "11", -- ADD R6, R3, R2
--        "00100" & "00111" & "00001" & "00011" & x"FFFFF" & "11", -- SUB R7, R1, R3
--        "00110" & "01000" & "00010" & "00011" & x"FFFFF" & "11", -- OR  R8, R2, R3
--        (OTHERS => '1'), -- STALL
--        (OTHERS => '1'), -- STALL
--        "00010" & "1111111111" & "0" & x"4" & "0000000011" & x"FFF", -- SWI R4, 3
--        "00010" & "1111111111" & "0" & x"5" & "0000000100" & x"FFF", -- SWI R5, 4
--        "00010" & "1111111111" & "0" & x"6" & "0000000101" & x"FFF", -- SWI R6, 5
--        "00010" & "1111111111" & "0" & x"7" & "0000000110" & x"FFF", -- SWI R7, 6
--        "00010" & "1111111111" & "0" & x"8" & "0000000111" & x"FFF", -- SWI R8, 7
--        OTHERS => (OTHERS => '1'));
    
    MEM_LOAD : PROCESS (DIR)
    BEGIN
        O_DATA <= DATA(to_integer(unsigned(DIR)));
    END PROCESS;
END Behavioral;