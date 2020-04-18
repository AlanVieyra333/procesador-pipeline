LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE ieee.numeric_std.ALL;

ENTITY REGISTROS IS
    GENERIC (
        WORD_LENGTH : NATURAL := 32;
        REG_SIZE : NATURAL := 32;
        DIR_LENGTH : NATURAL := 5 -- log2(REG_SIZE)
    );
    PORT (
        DIR, DIR_R1, DIR_R2 : IN STD_LOGIC_VECTOR (DIR_LENGTH - 1 DOWNTO 0);
        I_DATA : IN STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
        CLK, RST, WE : IN STD_LOGIC;
        O_DATA_R1, O_DATA_R2 : OUT STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0)
    );
END REGISTROS;

ARCHITECTURE Behavioral OF REGISTROS IS
    COMPONENT REGISTRO_ASYNC IS
        GENERIC (
            LENGTH : NATURAL := 32
        );
        PORT (
            I_DATA : IN STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
            RST, WE : IN STD_LOGIC;
            O_DATA : OUT STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT REGISTRO IS
        GENERIC (
            LENGTH : NATURAL := 32
        );
        PORT (
            I_DATA : IN STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
            CLK, RST, WE : IN STD_LOGIC;
            O_DATA : OUT STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT DECODIFICADOR IS
        GENERIC (
            ENC_LENGTH : NATURAL := 4; -- logs(DEC_LENGTH)
            DEC_LENGTH : NATURAL := 16
        );
        PORT (
            ENCODED : IN STD_LOGIC_VECTOR (ENC_LENGTH - 1 DOWNTO 0);
            DECODED : OUT STD_LOGIC_VECTOR (DEC_LENGTH - 1 DOWNTO 0));
    END COMPONENT;
    TYPE MEM_BANK IS ARRAY (0 TO REG_SIZE - 1) OF STD_LOGIC_VECTOR(WORD_LENGTH - 1 DOWNTO 0);

    SIGNAL REG_WE : STD_LOGIC_VECTOR(REG_SIZE - 1 DOWNTO 0);
    SIGNAL REG_O_DATA : MEM_BANK;

    SIGNAL DEC_WE : STD_LOGIC_VECTOR(REG_SIZE - 1 DOWNTO 0);
    SIGNAL WE_ARRAY : STD_LOGIC_VECTOR(REG_SIZE - 1 DOWNTO 0);
BEGIN

    -- WE vector.
    WE_VECTOR : DECODIFICADOR
    GENERIC MAP(DIR_LENGTH, REG_SIZE)
    PORT MAP(DIR, DEC_WE);
   
    WE_ARRAY <= (others=>WE);
    REG_WE <= DEC_WE AND WE_ARRAY;

    -- Registros.
    MEM_REG :
    FOR I IN 0 TO REG_SIZE - 1 GENERATE
        REGX : REGISTRO_ASYNC
        GENERIC MAP(WORD_LENGTH)
        PORT MAP(I_DATA, RST, REG_WE(I), REG_O_DATA(I));
    END GENERATE MEM_REG;

    -- Output R1 (MUX)
    OUT_DATA_R1 : PROCESS (DIR_R1, REG_O_DATA)
        VARIABLE idx : INTEGER := 0;
    BEGIN
        idx := to_integer(unsigned(DIR_R1));
        O_DATA_R1 <= REG_O_DATA(idx);
    END PROCESS;

    -- Output R2 (MUX)
    OUT_DATA_R2 : PROCESS (DIR_R2, REG_O_DATA)
        VARIABLE idx : INTEGER := 0;
    BEGIN
        idx := to_integer(unsigned(DIR_R2));
        O_DATA_R2 <= REG_O_DATA(idx);
    END PROCESS;

END Behavioral;