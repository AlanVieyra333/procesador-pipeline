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
    SIGNAL DATA : MEM_T := (others => (others => '0'));
BEGIN
	-- Matriz A 5x1 {1,2,3,4,5}
	DATA(0) <= "00000" & "00000" & x"00000001";	-- LWI R0, #1
    DATA(1) <= "00010" & "0000000000" & "00000" & "0000000000" & x"000";	-- SWI R0, 0
    DATA(2) <= "00000" & "00000" & x"00000002";	-- LWI R0, #2
    DATA(3) <= "00010" & "0000000000" & "00000" & "0000000001" & x"000";	-- SWI R0, 1
    DATA(4) <= "00000" & "00000" & x"00000003";	-- LWI R0, #3
    DATA(5) <= "00010" & "0000000000" & "00000" & "0000000010" & x"000";	-- SWI R0, 2
    DATA(6) <= "00000" & "00000" & x"00000004";	-- LWI R0, #4
    DATA(7) <= "00010" & "0000000000" & "00000" & "0000000011" & x"000";	-- SWI R0, 3
    DATA(8) <= "00000" & "00000" & x"00000005";	-- LWI R0, #5
    DATA(9) <= "00010" & "0000000000" & "00000" & "0000000100" & x"000";	-- SWI R0, 4
    -- Matriz B 1x5 {1,2,3,4,5}
    DATA(10) <= "00000" & "00000" & x"00000001";	-- LWI R0, #1
    DATA(11) <= "00010" & "0000000000" & "00000" & "0000000101" & x"000";	-- SWI R0, 5
    DATA(12) <= "00000" & "00000" & x"00000002";	-- LWI R0, #2
    DATA(13) <= "00010" & "0000000000" & "00000" & "0000000110" & x"000";	-- SWI R0, 6
    DATA(14) <= "00000" & "00000" & x"00000003";	-- LWI R0, #3
    DATA(15) <= "00010" & "0000000000" & "00000" & "0000000111" & x"000";	-- SWI R0, 7
    DATA(16) <= "00000" & "00000" & x"00000004";	-- LWI R0, #4
    DATA(17) <= "00010" & "0000000000" & "00000" & "0000001000" & x"000";	-- SWI R0, 8
    DATA(18) <= "00000" & "00000" & x"00000005";	-- LWI R0, #5
    DATA(19) <= "00010" & "0000000000" & "00000" & "0000001001" & x"000";	-- SWI R0, 9
    -- R2 = 5  -- Matriz de 5*5
    DATA(20) <= "00000" & "00010" & x"00000005";	-- LWI R2, #5
    -- R3 = 0
    DATA(21) <= "00000" & "00011" & x"00000000";	-- LWI R3, #0
    
    -- MULT-MATRIZ-1:
    -- R4 = 0
    DATA(22) <= "00000" & "00100" & x"00000000";	-- LWI R4, #0
    
    -- MULT-MATRIZ-2:
    
    -- sum = A[i] * B[j];
    -- R0 = Mem[R3 + 0]
    DATA(23)(WORD_LENGTH-1 downto WORD_LENGTH-30) <= "00001" & "00000" & "00011" & "00000" & "0000000000";	-- LW R0, 0(R3)
    -- R1 = Mem[R4 + 5]
    DATA(24)(WORD_LENGTH-1 downto WORD_LENGTH-30) <= "00001" & "00001" & "00100" & "00000" & "0000000101";	-- LW R1, 5(R4)
    -- R5 = R0 * R1
    DATA(25)(WORD_LENGTH-1 downto WORD_LENGTH-20) <= "00111" & "00101" & "00000" & "00001";	-- MUL R5, R0, R1
    
    -- result[i*5 + j] = sum;
    -- R0 = 5
    DATA(26) <= "00000" & "00000" & x"00000005";	-- LWI R0, #5
    -- R0 = R3 * R0
    DATA(27)(WORD_LENGTH-1 downto WORD_LENGTH-20) <= "00111" & "00000" & "00011" & "00000";	-- MUL R0, R3, R0
    -- R6 = R0 + R4
    DATA(28)(WORD_LENGTH-1 downto WORD_LENGTH-20) <= "00011" & "01000" & "00000" & "00100";	-- ADD R6, R0, R4
    -- Mem[10 + R6] = R5
    DATA(29)(WORD_LENGTH-1 downto WORD_LENGTH-30) <= "01000" & "00000" & "01000" & "00101" & "0000001010";	-- SW R5, 10(R6)
    
    -- R4 = R4 + 1
    DATA(30)(WORD_LENGTH-1 downto WORD_LENGTH-15) <= "01001" & "00100" & "00100";	-- INC R4, R4
    -- if(R4 != R2) MULT-MATRIZ-2
    DATA(31)(WORD_LENGTH-1 downto WORD_LENGTH-30) <= "01010" & "00000" & "00100" & "00010" & "1111111000";    -- BNEI R4, R2, 23 (MULT-MATRIZ-2)
    -- R3 = R3 + 1
    DATA(32)(WORD_LENGTH-1 downto WORD_LENGTH-15) <= "01001" & "00011" & "00011";	-- INC R3, R3
    -- if(R3 != R2) MULT-MATRIZ-1
    DATA(33)(WORD_LENGTH-1 downto WORD_LENGTH-30) <= "01010" & "00000" & "00011" & "00010" & "1111110101";    -- BNEI R3, R2, 22 (MULT-MATRIZ-1)
    
    DATA(34)(WORD_LENGTH-1 downto WORD_LENGTH-5) <= "11111";    -- End

    MEM_LOAD : PROCESS (DIR)
    BEGIN
        O_DATA <= DATA(to_integer(unsigned(DIR)));
    END PROCESS;
END Behavioral;