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
    SIGNAL DATA : MEM_T := (OTHERS => (OTHERS => '0'));
BEGIN
    -- Matriz A 5x1 {1,2,3,4,5}
    DATA(0) <= "00000" & "00000" & x"00000001"; -- LWI R0, #1
    DATA(1) <= "00000" & "00001" & x"00000002"; -- LWI R1, #2
    DATA(2) <= "00000" & "00010" & x"00000003"; -- LWI R2, #3
    DATA(3) <= "00000" & "00011" & x"00000004"; -- LWI R3, #4
    DATA(4) <= "00000" & "00100" & x"00000005"; -- LWI R4, #5

    DATA(5) <= "00010" & "0000000000" & "00000" & "0000000000" & x"000"; -- SWI R0, 0    
    DATA(6) <= "00010" & "0000000000" & "00001" & "0000000001" & x"000"; -- SWI R1, 1    
    DATA(7) <= "00010" & "0000000000" & "00010" & "0000000010" & x"000"; -- SWI R2, 2    
    DATA(8) <= "00010" & "0000000000" & "00011" & "0000000011" & x"000"; -- SWI R3, 3  
    DATA(9) <= "00010" & "0000000000" & "00100" & "0000000100" & x"000"; -- SWI R4, 4

    -- Matriz B 1x5 {1,2,3,4,5}
    DATA(10) <= "00000" & "00000" & x"00000001"; -- LWI R0, #1
    DATA(11) <= "00000" & "00001" & x"00000002"; -- LWI R1, #2
    DATA(12) <= "00000" & "00010" & x"00000003"; -- LWI R2, #3
    DATA(13) <= "00000" & "00011" & x"00000004"; -- LWI R3, #4
    DATA(14) <= "00000" & "00100" & x"00000005"; -- LWI R4, #5

    DATA(15) <= "00010" & "0000000000" & "00000" & "0000000101" & x"000"; -- SWI R0, 5
    DATA(16) <= "00010" & "0000000000" & "00001" & "0000000110" & x"000"; -- SWI R1, 6
    DATA(17) <= "00010" & "0000000000" & "00010" & "0000000111" & x"000"; -- SWI R2, 7
    DATA(18) <= "00010" & "0000000000" & "00011" & "0000001000" & x"000"; -- SWI R3, 8   
    DATA(19) <= "00010" & "0000000000" & "00100" & "0000001001" & x"000"; -- SWI R4, 9

    -- R2 = 5  -- Matriz de 5*5
    DATA(20) <= "00000" & "00010" & x"00000005"; -- LWI R2, #5
    -- R3 = 0
    DATA(21) <= "00000" & "00011" & x"00000000"; -- LWI R3, #0

    -- MULT-MATRIZ-1:
    -- R4 = 0
    DATA(22) <= "00000" & "00100" & x"00000000"; -- LWI R4, #0

    -- MULT-MATRIZ-2:
    -- sum = A[i] * B[j];
    -- R0 = Mem[R3 + 0]
    DATA(23) <= (OTHERS => '1'); -- STALL
    DATA(24) <= (OTHERS => '1'); -- STALL
    DATA(25)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 30) <= "00001" & "00000" & "00011" & "00000" & "0000000000"; -- LW R0, 0(R3)
    -- R1 = Mem[R4 + 5]
    DATA(26)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 30) <= "00001" & "00001" & "00100" & "00000" & "0000000101"; -- LW R1, 5(R4)
    -- R5 = R0 * R1
    DATA(27) <= (OTHERS => '1'); -- STALL
    DATA(28) <= (OTHERS => '1'); -- STALL
    DATA(29) <= (OTHERS => '1'); -- STALL
    DATA(30)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 20) <= "00111" & "00101" & "00000" & "00001"; -- MUL R5, R0, R1

    -- result[i*5 + j] = sum;
    -- R0 = 5
    DATA(31) <= "00000" & "00000" & x"00000005"; -- LWI R0, #5
    -- R0 = R3 * R0
    DATA(32) <= (OTHERS => '1'); -- STALL
    DATA(33) <= (OTHERS => '1'); -- STALL
    DATA(34) <= (OTHERS => '1'); -- STALL
    DATA(35)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 20) <= "00111" & "00000" & "00011" & "00000"; -- MUL R0, R3, R0
    -- R6 = R0 + R4
    DATA(36) <= (OTHERS => '1'); -- STALL
    DATA(37) <= (OTHERS => '1'); -- STALL
    DATA(38) <= (OTHERS => '1'); -- STALL
    DATA(39)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 20) <= "00011" & "01000" & "00000" & "00100"; -- ADD R6, R0, R4
    -- Mem[10 + R6] = R5
    DATA(40) <= (OTHERS => '1'); -- STALL
    DATA(41) <= (OTHERS => '1'); -- STALL
    DATA(42) <= (OTHERS => '1'); -- STALL
    DATA(43)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 30) <= "01000" & "00000" & "01000" & "00101" & "0000001010"; -- SW R5, 10(R6)

    -- R4 = R4 + 1
    DATA(44)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 15) <= "01001" & "00100" & "00100"; -- INC R4, R4
    -- if(R4 != R2) MULT-MATRIZ-2
    DATA(45) <= (OTHERS => '1'); -- STALL
    DATA(46) <= (OTHERS => '1'); -- STALL
    DATA(47) <= (OTHERS => '1'); -- STALL
    DATA(48)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 30) <= "01010" & "00000" & "00100" & "00010" & "1111101001"; -- BNEI R4, R2, -23 //25 (MULT-MATRIZ-2)
    DATA(49) <= (OTHERS => '1'); -- STALL
    DATA(50) <= (OTHERS => '1'); -- STALL
    DATA(51) <= (OTHERS => '1'); -- STALL
    -- R3 = R3 + 1
    DATA(52)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 15) <= "01001" & "00011" & "00011"; -- INC R3, R3
    -- if(R3 != R2) MULT-MATRIZ-1
    DATA(53) <= (OTHERS => '1'); -- STALL
    DATA(54) <= (OTHERS => '1'); -- STALL
    DATA(55) <= (OTHERS => '1'); -- STALL
    DATA(56)(WORD_LENGTH - 1 DOWNTO WORD_LENGTH - 30) <= "01010" & "00000" & "00011" & "00010" & "1111011110"; -- BNEI R3, R2, -34 //22 (MULT-MATRIZ-1)

    DATA(57) <= (OTHERS => '1'); -- NOP

    MEM_LOAD : PROCESS (DIR)
    BEGIN
        O_DATA <= DATA(to_integer(unsigned(DIR)));
    END PROCESS;
END Behavioral;