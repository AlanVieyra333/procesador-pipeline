-- Code your testbench here
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY TB IS
    -- empty
    GENERIC(
        WORD_LENGTH : NATURAL := 32;
        MEM_PROG_SIZE : NATURAL := 1024;
        MEM_PROG_DIR_LENGTH : NATURAL := 10; -- log(MEM_PROG_SIZE)
        MEM_DATA_SIZE : NATURAL := 1024;
        MEM_DATA_DIR_LENGTH : NATURAL := 10; -- log(MEM_DATA_SIZE)
        REG_SIZE : NATURAL := 32;
        REG_DIR_LENGTH : NATURAL := 5;  -- log2(REG_SIZE)
        INSTRUCTION_LENGTH : NATURAL := 32;
        ALU_OPE_LENGTH : NATURAL := 3
    );
END TB;

ARCHITECTURE BEV OF TB IS
    -- Procedure for clock generation
    procedure clk_gen(signal clk : out std_logic; constant FREQ : real) is
      constant PERIOD    : time := 1 sec / FREQ;        -- Full period
      constant HIGH_TIME : time := PERIOD / 2;          -- High time
      constant LOW_TIME  : time := PERIOD - HIGH_TIME;  -- Low time; always >= HIGH_TIME
    begin
      -- Check the arguments
      assert (HIGH_TIME /= 0 fs) report "clk_plain: High time is zero; time resolution to large for frequency" severity FAILURE;
      -- Generate a clock cycle
      --for i in 0 to 99 loop
      loop
        clk <= '1';
        wait for HIGH_TIME;
        clk <= '0';
        wait for LOW_TIME;
      end loop;
    end procedure;

	-- COMPONENT
    COMPONENT DATAPATH IS
        GENERIC (
            WORD_LENGTH : NATURAL := 32;
            MEM_PROG_SIZE : NATURAL := 1024;
            MEM_PROG_DIR_LENGTH : NATURAL := 10; -- log(MEM_PROG_SIZE)
            MEM_DATA_SIZE : NATURAL := 1024;
            MEM_DATA_DIR_LENGTH : NATURAL := 10; -- log(MEM_DATA_SIZE)
            REG_SIZE : NATURAL := 32;
            REG_DIR_LENGTH : NATURAL := 5;  -- log2(REG_SIZE)
            INSTRUCTION_LENGTH : NATURAL := 5 + 5 + 32;
            ALU_OPE_LENGTH : NATURAL := 3
        );
        PORT (
            RST, CLK : IN STD_LOGIC
        );
    END COMPONENT;
    -- SIGNALS
    SIGNAL CLK, RST : STD_LOGIC;
BEGIN

	clk_gen(CLK, 1.0E9);  -- Frecuencia: 1GHz

    DATA_PATH : DATAPATH PORT MAP(RST, CLK);

    PROCESS
    BEGIN
    	RST <= '1';
        WAIT FOR 1 ns;
    	RST <= '0';
        
        WAIT FOR 20 ns;
        --assert(O_DATA=x"00000001") report "Fail test 1" severity error;

        ASSERT FALSE REPORT "Test done. Open EPWave to see signals." SEVERITY NOTE;
        WAIT;
    END PROCESS;

END BEV;