LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CONTROL IS
    GENERIC (
        WORD_LENGTH : NATURAL := 32;
        MEM_PROG_SIZE : NATURAL := 1024;
        MEM_PROG_DIR_LENGTH : NATURAL := 10; -- log(MEM_PROG_SIZE)
        MEM_DATA_SIZE : NATURAL := 1024;
        MEM_DATA_DIR_LENGTH : NATURAL := 10; -- log(MEM_DATA_SIZE)
        REG_SIZE : NATURAL := 32;
        INST_OPE_LENGTH : NATURAL := 5;
        ALU_OPE_LENGTH : NATURAL := 3
    );
    PORT (
        INST_OPE : IN STD_LOGIC_VECTOR (INST_OPE_LENGTH - 1 DOWNTO 0);
        RST, CLK : IN STD_LOGIC;
        PC_ENABLE, PC_WE : OUT STD_LOGIC;
        REG_WE : OUT STD_LOGIC;
        REG_I_DATA_SEL : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        ALU_OPE : OUT STD_LOGIC_VECTOR (ALU_OPE_LENGTH - 1 DOWNTO 0);
        MEMORY_DATA_WE : OUT STD_LOGIC;
        ALU_I_DATA_SEL : OUT STD_LOGIC;
        MEM_DIR_SEL: OUT STD_LOGIC
    );
END CONTROL;

ARCHITECTURE Behavioral OF CONTROL IS
    TYPE STATE IS (Qrst, Qini, Q_LW);
    SIGNAL STATE_CURRENT, STATE_NEXT : STATE;
BEGIN

    CTRL_CLK : PROCESS (RST, CLK)
    BEGIN
        IF RST = '1' THEN
            STATE_CURRENT <= Qrst;
        ELSIF rising_edge(CLK) THEN
            STATE_CURRENT <= STATE_NEXT;
        END IF;
    END PROCESS;

    CTRL_STATE : PROCESS (STATE_CURRENT, INST_OPE)
    BEGIN

        CASE(STATE_CURRENT) IS -- Decodificar operacion de la instruccion.
            WHEN Qrst =>
	            -- Valores por defecto.
                PC_ENABLE <= '0';
                PC_WE <= '0';
                REG_WE <= '0';
                REG_I_DATA_SEL <= "00";
                ALU_OPE <= (OTHERS => '0');
                MEMORY_DATA_WE <= '0';
                ALU_I_DATA_SEL <= '0';
                MEM_DIR_SEL <= '0';
                
	            STATE_NEXT <= Qini;
            WHEN Qini =>
            	-- Valores por defecto.
                PC_ENABLE <= '1';
                PC_WE <= '0';
                REG_WE <= '0';
                REG_I_DATA_SEL <= "00";
                ALU_OPE <= (OTHERS => '0');
                MEMORY_DATA_WE <= '0';
                ALU_I_DATA_SEL <= '0';
                MEM_DIR_SEL <= '0';
                
                STATE_NEXT <= Qini;
            	
                CASE(INST_OPE) IS
                    WHEN "00000" => -- LWI - Rd = num
                        REG_WE <= '1';
                    WHEN "00001" => -- LW - LW Rd, D(Rt) - Rd = Mem[Rt + D]
                    	ALU_I_DATA_SEL <= '1'; -- Leer input B ALU de instruccion.
                    	ALU_OPE <= "000";
                    	MEM_DIR_SEL <= '1';     -- Elegir la direccion de memoria de ALU.
                        
                        REG_I_DATA_SEL <= "10"; -- Gurdar en registro el dato de memoria.
                        REG_WE <= '1';
                        
                        --PC_ENABLE <= '0';      -- Desactivar PC.
                    	--STATE_NEXT <= Q_LW;
                    WHEN "00010" => -- SWI - Mem[D] = Rd
                    	MEMORY_DATA_WE <= '1';
                    WHEN "00011" => -- ADD
                    	ALU_OPE <= "000";
                    	REG_WE <= '1';
                    	REG_I_DATA_SEL <= "01"; -- Gurdar en registro el dato de ALU.
                    WHEN "00100" => -- Sub
                    	ALU_OPE <= "001";
                    	REG_WE <= '1';
                    	REG_I_DATA_SEL <= "01"; -- Gurdar en registro el dato de ALU.
                    WHEN "00101" => -- And
                    	ALU_OPE <= "110";
                    	REG_WE <= '1';
                    	REG_I_DATA_SEL <= "01"; -- Gurdar en registro el dato de ALU.
                    WHEN "00110" => -- Or
                    	ALU_OPE <= "101";
                    	REG_WE <= '1';
                    	REG_I_DATA_SEL <= "01"; -- Gurdar en registro el dato de ALU.
                    WHEN "00111" => -- MUL
                    	ALU_OPE <= "010";
                    	REG_WE <= '1';
                    	REG_I_DATA_SEL <= "01"; -- Gurdar en registro el dato de ALU.
                    WHEN "01000" => -- SW - SW Rd, D(Rt) - Mem[Rt + D] = Rd 
                    	ALU_I_DATA_SEL <= '1'; -- Leer input B ALU de instruccion.
                    	MEM_DIR_SEL <= '1';    -- Elegir la direccion de memoria de ALU.
                    	MEMORY_DATA_WE <= '1';
                    WHEN "01001" => -- INC - INC Rd, Rt - Rd = Rt + 1
                    	ALU_OPE <= "011";
                    	REG_WE <= '1';
                    	REG_I_DATA_SEL <= "01"; -- Gurdar en registro el dato de ALU.
                    WHEN "01010" => -- BNEI Rd, Rt, D - if(Rd != Rt) goto D
                    	ALU_OPE <= "001";
                    	PC_WE <= '1';
                    WHEN OTHERS => -- NOP
                    	-- NOTHING.
            	END CASE;
            WHEN Q_LW =>
                REG_I_DATA_SEL <= "10"; -- Gurdar en registro el dato de memoria.
                REG_WE <= '1';
                
                PC_ENABLE <= '1';      -- Activar PC.
                STATE_NEXT <= Qini;
            WHEN OTHERS =>
        END CASE;
    END PROCESS;

END Behavioral;