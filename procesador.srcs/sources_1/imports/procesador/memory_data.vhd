LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEMORY_DATA IS
    GENERIC (
        WORD_LENGTH : NATURAL := 32;
        MEM_SIZE : NATURAL := 1024;
        DIR_LENGTH : NATURAL := 10 -- log(RAM_SIZE)
    );
    PORT (
        I_DATA : IN STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
        DIR : IN STD_LOGIC_VECTOR (DIR_LENGTH - 1 DOWNTO 0);
        WE : IN STD_LOGIC;
        RST, CLK : IN STD_LOGIC;
        O_DATA : OUT STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0)
    );
END MEMORY_DATA;

ARCHITECTURE Behavioral OF MEMORY_DATA IS
    TYPE MEM_T IS ARRAY (0 TO MEM_SIZE) OF STD_LOGIC_VECTOR(WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL DATA : MEM_T := (others => (others => '0'));
BEGIN

    MEM_LOAD : PROCESS (RST, DIR, WE)
    BEGIN
        IF RST = '1' THEN
            DATA <= (others => (others => '0'));
            
--            DATA(3) <= x"0000000a";
--            DATA(4) <= x"00000005";
--            DATA(5) <= x"00000006";
        ELSE
            O_DATA <= DATA(to_integer(unsigned(DIR)));

            IF WE = '1' THEN
                DATA(to_integer(unsigned(DIR))) <= I_DATA;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;