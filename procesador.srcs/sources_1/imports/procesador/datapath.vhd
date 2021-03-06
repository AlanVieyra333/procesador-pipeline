LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY DATAPATH IS
    GENERIC (
        WORD_LENGTH : NATURAL := 32;
        MEM_PROG_SIZE : NATURAL := 1024;
        MEM_PROG_DIR_LENGTH : NATURAL := 10; -- log(MEM_PROG_SIZE)
        MEM_DATA_SIZE : NATURAL := 1024;
        MEM_DATA_DIR_LENGTH : NATURAL := 10; -- log(MEM_DATA_SIZE)
        REG_SIZE : NATURAL := 32;
        REG_DIR_LENGTH : NATURAL := 5; -- log2(REG_SIZE)
        INSTRUCTION_LENGTH : NATURAL := 42;
        INST_OPE_LENGTH : NATURAL := 5;
        ALU_OPE_LENGTH : NATURAL := 3
    );
    PORT (
        RST, CLK : IN STD_LOGIC
    );
END DATAPATH;

ARCHITECTURE Behavioral OF DATAPATH IS
    COMPONENT ALU IS
        GENERIC (
            LENGTH : NATURAL := 32
        );
        PORT (
            A, B : IN STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
            OPE : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            RESULT_L : OUT STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
            FLAGS : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT REGISTROS IS
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
    END COMPONENT;

    COMPONENT MEMORY_PROG IS
        GENERIC (
            WORD_LENGTH : NATURAL := 32;
            MEM_SIZE : NATURAL := 1024;
            DIR_LENGTH : NATURAL := 10 -- log(RAM_SIZE)
        );
        PORT (
            DIR : IN STD_LOGIC_VECTOR (DIR_LENGTH - 1 DOWNTO 0);
            O_DATA : OUT STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT PC IS
        GENERIC (
            SIZE : NATURAL := 10 -- Depende del tamano de la memoria. log2(1024) = 10
        );
        PORT (
            I_DIR : IN STD_LOGIC_VECTOR (SIZE - 1 DOWNTO 0);
            ENABLE, WE : IN STD_LOGIC;
            RST, CLK : IN STD_LOGIC;
            O_DIR : OUT STD_LOGIC_VECTOR (SIZE - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT CONTROL IS
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
            PC_ENABLE, PC_JUMP : OUT STD_LOGIC;
            REG_WE : OUT STD_LOGIC;
            REG_I_DATA_SEL : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            ALU_OPE : OUT STD_LOGIC_VECTOR (ALU_OPE_LENGTH - 1 DOWNTO 0);
            MEMORY_DATA_WE : OUT STD_LOGIC;
            ALU_I_DATA_SEL : OUT STD_LOGIC;
            MEM_DIR_SEL : OUT STD_LOGIC;
            JUMP_SEL : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT MEMORY_DATA IS
        GENERIC (
            WORD_LENGTH : NATURAL := 5 + 5 + 32;
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
    
    COMPONENT floating_point is
        Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
               B : in STD_LOGIC_VECTOR (31 downto 0);
               Ope : in STD_LOGIC_VECTOR (1 downto 0);
               Result : out STD_LOGIC_VECTOR (31 downto 0));
    end COMPONENT;

    -- PC
    SIGNAL PC_ENABLE, PC_WE : STD_LOGIC;
    SIGNAL PC_JUMP : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL PC_I_DIR, PC_DIR : STD_LOGIC_VECTOR (MEM_PROG_DIR_LENGTH - 1 DOWNTO 0);
    SIGNAL JUMP_SEL : STD_LOGIC_VECTOR (1 DOWNTO 0);
    -- Registros
    SIGNAL REG_I_DATA : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL REG_O_DATA_R1, REG_O_DATA_R2, I_DATA_B_ALU : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    -- ALU
    SIGNAL ALU_OPE : STD_LOGIC_VECTOR (ALU_OPE_LENGTH - 1 DOWNTO 0);
    SIGNAL ALU_RES : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL ALU_FLAGS : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL Z, N : STD_LOGIC;
    -- Memory program
    SIGNAL INSTRUCTION : STD_LOGIC_VECTOR (INSTRUCTION_LENGTH - 1 DOWNTO 0);
    SIGNAL INST_PC_DIR : STD_LOGIC_VECTOR (MEM_PROG_DIR_LENGTH - 1 DOWNTO 0);
    -- Memory data (RAM)
    SIGNAL MEM_DIR, INST_MEM_DIR : STD_LOGIC_VECTOR (MEM_DATA_DIR_LENGTH - 1 DOWNTO 0);
    SIGNAL MEM_DATA_O : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);

    -- Pipeline IF
    SIGNAL P_INSTRUCTION : STD_LOGIC_VECTOR (INSTRUCTION_LENGTH - 1 DOWNTO 0);
    SIGNAL P_IF_PC_DIR : STD_LOGIC_VECTOR (MEM_PROG_DIR_LENGTH - 1 DOWNTO 0);
    -- Pipeline ID
    SIGNAL P_REG_O_DATA_R1, P_REG_O_DATA_R2 : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_ID_INST_PC_DIR : STD_LOGIC_VECTOR (MEM_PROG_DIR_LENGTH - 1 DOWNTO 0);
    SIGNAL P_ID_PC_DIR : STD_LOGIC_VECTOR (MEM_PROG_DIR_LENGTH - 1 DOWNTO 0);
    SIGNAL P_ID_MEM_DIR_SEL : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_ID_ALU_I_DATA_SEL : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_ID_ALU_OPE : STD_LOGIC_VECTOR (ALU_OPE_LENGTH - 1 DOWNTO 0);
    SIGNAL P_ID_REG_WE : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_ID_MEM_DATA_WE : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_ID_REG_I_DATA_SEL : STD_LOGIC_VECTOR (1 DOWNTO 0); -- Multiplexor Registro
    SIGNAL P_ID_PC_JUMP : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_ID_JUMP_SEL : STD_LOGIC_VECTOR (1 DOWNTO 0);
    -- Pipeline EX
    SIGNAL P_EX_INST_MEM_DIR : STD_LOGIC_VECTOR (MEM_DATA_DIR_LENGTH - 1 DOWNTO 0);
    SIGNAL P_EX_PC_DIR_ALU : STD_LOGIC_VECTOR (MEM_PROG_DIR_LENGTH - 1 DOWNTO 0);
    SIGNAL P_EX_ALU_RES : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_EX_ALU_RES_FP : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_EX_ALU_FLAGS : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL P_EX_MEM_DIR_SEL : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_EX_ALU_I_DATA_SEL : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_EX_REG_WE : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_EX_MEM_DATA_WE : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_EX_REG_I_DATA_SEL : STD_LOGIC_VECTOR (1 DOWNTO 0); -- Multiplexor Registro
    SIGNAL P_EX_INST_DATA : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_EX_INST_REG_DIR : STD_LOGIC_VECTOR (REG_DIR_LENGTH - 1 DOWNTO 0);
    SIGNAL P_EX_PC_JUMP : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_EX_JUMP_SEL : STD_LOGIC_VECTOR (1 DOWNTO 0);
    -- Pipeline MEM
    SIGNAL P_MEM_REG_DATA_R2 : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_MEM_ALU_RES : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_MEM_ALU_RES_FP : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_MEM_MEM_DIR_SEL : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_MEM_REG_WE : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_MEM_MEM_DATA_WE : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_MEM_MEM_DATA_O : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_MEM_REG_I_DATA_SEL : STD_LOGIC_VECTOR (1 DOWNTO 0); -- Multiplexor Registro
    SIGNAL P_MEM_INST_DATA : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_MEM_INST_REG_DIR : STD_LOGIC_VECTOR (REG_DIR_LENGTH - 1 DOWNTO 0);
    -- Pipeline WB
    SIGNAL P_WB_REG_WE : STD_LOGIC_VECTOR (0 DOWNTO 0);
    SIGNAL P_WB_REG_I_DATA_SEL : STD_LOGIC_VECTOR (1 DOWNTO 0); -- Multiplexor Registro
    SIGNAL P_WB_ALU_RES : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_WB_ALU_RES_FP : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_WB_INST_DATA : STD_LOGIC_VECTOR (WORD_LENGTH - 1 DOWNTO 0);
    SIGNAL P_WB_INST_REG_DIR : STD_LOGIC_VECTOR (REG_DIR_LENGTH - 1 DOWNTO 0);
BEGIN
    -- OK
    Z <= ALU_FLAGS(0);
    N <= ALU_FLAGS(1);

    -- Pipeline ID - INST_MEM_DIR
    P_ID_INST_MEM_DIR_R : REGISTRO GENERIC MAP(MEM_DATA_DIR_LENGTH)
    PORT MAP(INSTRUCTION(INSTRUCTION_LENGTH - 21 DOWNTO INSTRUCTION_LENGTH - 30), CLK, RST, '1', P_EX_INST_MEM_DIR);

    -- Pipeline EX - INST_MEM_DIR
    P_EX_INST_MEM_DIR_R : REGISTRO GENERIC MAP(MEM_DATA_DIR_LENGTH)
    PORT MAP(P_EX_INST_MEM_DIR, CLK, RST, '1', INST_MEM_DIR);

    -- OK
    -- Multiplexor input DIR RAM: Elegir de donde tomar la direccion de memoria RAM. (Instruccion / ALU)
    MEM_DIR <= INST_MEM_DIR WHEN P_MEM_MEM_DIR_SEL(0) = '0' ELSE
        ALU_RES(MEM_DATA_DIR_LENGTH - 1 DOWNTO 0);

    -- OK
    PROGRAM_COUNTER : PC GENERIC MAP(MEM_PROG_DIR_LENGTH)
    PORT MAP(PC_I_DIR, PC_ENABLE, PC_WE, RST, CLK, P_IF_PC_DIR);

    -- OK
    -- AND: Ativar PC_WE si la bandera Zero de la ALU se activa y la instruccion es jump.
    --PC_WE <= PC_JUMP(0) AND not Z;
    PC_WE <= (PC_JUMP(0) AND not Z) WHEN JUMP_SEL = "01"        -- BNEI if(Rd != Rt) goto D
        ELSE
            (PC_JUMP(0) AND N) WHEN JUMP_SEL = "10"             -- BLTI if(Rd < Rt) goto D
        ELSE
            PC_JUMP(0);    -- J goto D

    -- OK
    PROGRAM_MEMORY : MEMORY_PROG GENERIC MAP(INSTRUCTION_LENGTH, MEM_PROG_SIZE, MEM_PROG_DIR_LENGTH)
    PORT MAP(P_IF_PC_DIR, P_INSTRUCTION);

    -- Pipeline IF - PROGRAM_MEMORY
    P_PROGRAM_MEMORY : REGISTRO GENERIC MAP(INSTRUCTION_LENGTH)
    PORT MAP(P_INSTRUCTION, CLK, RST, '1', INSTRUCTION);

    -- Pipeline ID - INST_PC_DIR
    P_ID_INST_PC_DIR <= INSTRUCTION(INSTRUCTION_LENGTH - 21 DOWNTO INSTRUCTION_LENGTH - 30);
    P_INST_PC_DIR_R : REGISTRO GENERIC MAP(MEM_PROG_DIR_LENGTH)
    PORT MAP(P_ID_INST_PC_DIR, CLK, RST, '1', INST_PC_DIR);

    -- Pipeline IF - PC_DIR
    P_IF_PC_DIR_R : REGISTRO GENERIC MAP(MEM_PROG_DIR_LENGTH)
    PORT MAP(P_IF_PC_DIR, CLK, RST, '1', P_ID_PC_DIR);

    -- Pipeline ID - PC_DIR
    P_ID_PC_DIR_R : REGISTRO GENERIC MAP(MEM_PROG_DIR_LENGTH)
    PORT MAP(P_ID_PC_DIR, CLK, RST, '1', PC_DIR);

    -- OK
    PROGRAM_ALU : ALU GENERIC MAP(MEM_PROG_DIR_LENGTH) -- word_len = 10 en lugar de 32
    PORT MAP(PC_DIR, INST_PC_DIR, "000", P_EX_PC_DIR_ALU);

    -- Pipeline EX - PC_DIR_ALU
    P_EX_PC_DIR_ALU_R : REGISTRO GENERIC MAP(MEM_PROG_DIR_LENGTH)
    PORT MAP(P_EX_PC_DIR_ALU, CLK, RST, '1', PC_I_DIR);

    -- OK
    REG : REGISTROS GENERIC MAP(WORD_LENGTH, REG_SIZE, REG_DIR_LENGTH)
    PORT MAP(
        P_WB_INST_REG_DIR,
        INSTRUCTION(INSTRUCTION_LENGTH - 11 DOWNTO INSTRUCTION_LENGTH - 15),
        INSTRUCTION(INSTRUCTION_LENGTH - 16 DOWNTO INSTRUCTION_LENGTH - 20),
        REG_I_DATA, CLK, RST, P_WB_REG_WE(0), P_REG_O_DATA_R1, P_REG_O_DATA_R2);
        
    -- Pipeline ID - INST_REG_DIR
    P_ID_INST_REG_DIR_R : REGISTRO GENERIC MAP(REG_DIR_LENGTH)
    PORT MAP(INSTRUCTION(INSTRUCTION_LENGTH - 6 DOWNTO INSTRUCTION_LENGTH - 10), CLK, RST, '1', P_EX_INST_REG_DIR);
    -- Pipeline EX - INST_REG_DIR
    P_EX_INST_REG_DIR_R : REGISTRO GENERIC MAP(REG_DIR_LENGTH)
    PORT MAP(P_EX_INST_REG_DIR, CLK, RST, '1', P_MEM_INST_REG_DIR);
    -- Pipeline MEM - INST_REG_DIR
    P_MEM_INST_REG_DIR_R : REGISTRO GENERIC MAP(REG_DIR_LENGTH)
    PORT MAP(P_MEM_INST_REG_DIR, CLK, RST, '1', P_WB_INST_REG_DIR);

    -- Pipeline ID - REG's
    P_ID_REG_R1 : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(P_REG_O_DATA_R1, CLK, RST, '1', REG_O_DATA_R1);
    P_ID_REG_R2 : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(P_REG_O_DATA_R2, CLK, RST, '1', REG_O_DATA_R2);
    
    -- Pipeline EX - REG
    P_EX_REG_R2 : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(REG_O_DATA_R2, CLK, RST, '1', P_MEM_REG_DATA_R2);

    -- OK
    -- Multiplexor input ALU - EX: Elegir de donde elegir el dato B para la entrada de ALU. (Registro / Instruccion)
    I_DATA_B_ALU <= REG_O_DATA_R2 WHEN P_EX_ALU_I_DATA_SEL(0) = '0' ELSE
        x"00000" & "00" & P_EX_INST_MEM_DIR;

    -- ##########################################################################
    OPE_FP_ALU : floating_point
    PORT MAP(REG_O_DATA_R1, I_DATA_B_ALU, ALU_OPE(1 downto 0), P_EX_ALU_RES_FP);
    
    -- Pipeline EX - ALU_RES_FP
    P_EX_ALU_RES_FP_R : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(P_EX_ALU_RES_FP, CLK, RST, '1', P_MEM_ALU_RES_FP);
    -- Pipeline MEM - ALU_RES_FP
    P_MEM_ALU_RES_FP_R : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(P_MEM_ALU_RES_FP, CLK, RST, '1', P_WB_ALU_RES_FP);

    -- OK
    OPE_ALU : ALU GENERIC MAP(WORD_LENGTH)
    PORT MAP(REG_O_DATA_R1, I_DATA_B_ALU, ALU_OPE, P_EX_ALU_RES, P_EX_ALU_FLAGS);

    -- Pipeline EX - ALU_RES
    P_EX_ALU_RES_R : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(P_EX_ALU_RES, CLK, RST, '1', ALU_RES);
    -- Pipeline MEM - ALU_RES
    P_MEM_ALU_RES_R : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(ALU_RES, CLK, RST, '1', P_WB_ALU_RES);
    
    -- Pipeline EX - ALU_FLAGS
    P_EX_ALU_Z : REGISTRO GENERIC MAP(2)
    PORT MAP(P_EX_ALU_FLAGS, CLK, RST, '1', ALU_FLAGS);

    -- TODO: PC_ENABLE
    CONTROL_MS : CONTROL GENERIC MAP(
        WORD_LENGTH, MEM_PROG_SIZE, MEM_PROG_DIR_LENGTH, MEM_DATA_SIZE, MEM_DATA_DIR_LENGTH,
        REG_SIZE, INST_OPE_LENGTH, ALU_OPE_LENGTH)
    PORT MAP(
        INSTRUCTION(INSTRUCTION_LENGTH - 1 DOWNTO INSTRUCTION_LENGTH - 5), RST, CLK,
        PC_ENABLE, P_ID_PC_JUMP(0), P_ID_REG_WE(0), P_ID_REG_I_DATA_SEL, P_ID_ALU_OPE, P_ID_MEM_DATA_WE(0),
         P_ID_ALU_I_DATA_SEL(0), P_ID_MEM_DIR_SEL(0), P_ID_JUMP_SEL);
        
    -- Pipeline ID - MEM_DIR_SEL
    P_ID_MEM_DIR_SEL_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_ID_MEM_DIR_SEL, CLK, RST, '1', P_EX_MEM_DIR_SEL);
    -- Pipeline EX - MEM_DIR_SEL
    P_EX_MEM_DIR_SEL_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_EX_MEM_DIR_SEL, CLK, RST, '1', P_MEM_MEM_DIR_SEL);
    
    -- Pipeline ID - ALU_I_DATA_SEL
    P_ID_ALU_I_DATA_SELL_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_ID_ALU_I_DATA_SEL, CLK, RST, '1', P_EX_ALU_I_DATA_SEL);
    
    -- Pipeline ID - ALU_OPE
    P_ID_ALU_OPE_R : REGISTRO GENERIC MAP(ALU_OPE_LENGTH)
    PORT MAP(P_ID_ALU_OPE, CLK, RST, '1', ALU_OPE);
    
    -- Pipeline ID - REG_WE
    P_ID_REG_WE_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_ID_REG_WE, CLK, RST, '1', P_EX_REG_WE);
    -- Pipeline EX - REG_WE
    P_EX_REG_WE_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_EX_REG_WE, CLK, RST, '1', P_MEM_REG_WE);
    -- Pipeline MEM - REG_WE
    P_MEM_REG_WE_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_MEM_REG_WE, CLK, RST, '1', P_WB_REG_WE);
    
    -- Pipeline ID - MEM_DATA_WE
    P_ID_MEM_DATA_WE_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_ID_MEM_DATA_WE, CLK, RST, '1', P_EX_MEM_DATA_WE);
    -- Pipeline EX - MEM_DATA_WE
    P_EX_MEM_DATA_WE_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_EX_MEM_DATA_WE, CLK, RST, '1', P_MEM_MEM_DATA_WE);
    
    -- Pipeline ID - REG_I_DATA_SEL
    P_ID_REG_I_DATA_SEL_R : REGISTRO GENERIC MAP(2)
    PORT MAP(P_ID_REG_I_DATA_SEL, CLK, RST, '1', P_EX_REG_I_DATA_SEL);
    -- Pipeline EX - REG_I_DATA_SEL
    P_EX_REG_I_DATA_SEL_R : REGISTRO GENERIC MAP(2)
    PORT MAP(P_EX_REG_I_DATA_SEL, CLK, RST, '1', P_MEM_REG_I_DATA_SEL);
    -- Pipeline MEM - REG_I_DATA_SEL
    P_MEM_REG_I_DATA_SEL_R : REGISTRO GENERIC MAP(2)
    PORT MAP(P_MEM_REG_I_DATA_SEL, CLK, RST, '1', P_WB_REG_I_DATA_SEL);
    
    -- Pipeline PC JUMP
    P_ID_PC_JUMP_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_ID_PC_JUMP, CLK, RST, '1', P_EX_PC_JUMP);
    P_EX_PC_JUMP_R : REGISTRO GENERIC MAP(1)
    PORT MAP(P_EX_PC_JUMP, CLK, RST, '1', PC_JUMP);
    
    -- Pipeline JUMP_SEL
    P_ID_JUMP_SEL_R : REGISTRO GENERIC MAP(2)
    PORT MAP(P_ID_JUMP_SEL, CLK, RST, '1', P_EX_JUMP_SEL);
    P_EX_JUMP_SEL_R : REGISTRO GENERIC MAP(2)
    PORT MAP(P_EX_JUMP_SEL, CLK, RST, '1', JUMP_SEL);
    
    -- OK
    RAM : MEMORY_DATA GENERIC MAP(WORD_LENGTH, MEM_DATA_SIZE, MEM_DATA_DIR_LENGTH)
    PORT MAP(P_MEM_REG_DATA_R2, MEM_DIR, P_MEM_MEM_DATA_WE(0), RST, CLK, P_MEM_MEM_DATA_O);
    
    -- Pipeline MEM - MEM_DATA_O
    P_MEM_MEM_DATA_O_R : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(P_MEM_MEM_DATA_O, CLK, RST, '1', MEM_DATA_O);
    
    -- Pipeline ID - INST_DATA
    P_ID_INST_DATA_R : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(INSTRUCTION(INSTRUCTION_LENGTH - 11 DOWNTO 0), CLK, RST, '1', P_EX_INST_DATA);
    -- Pipeline EX - INST_DATA
    P_EX_INST_DATA_R : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(P_EX_INST_DATA, CLK, RST, '1', P_MEM_INST_DATA);
    -- Pipeline MEM - INST_DATA
    P_MEM_INST_DATA_R : REGISTRO GENERIC MAP(WORD_LENGTH)
    PORT MAP(P_MEM_INST_DATA, CLK, RST, '1', P_WB_INST_DATA);
    
    -- OK
    -- Multiplexor input DATA REG: Elegir de donde escoger el dato a escribir en el registro. (Instruccion / ALU / memoria / ALU_FP)
    REG_I_DATA <= P_WB_INST_DATA WHEN P_WB_REG_I_DATA_SEL = "00"    -- Instruccion
        ELSE
        P_WB_ALU_RES WHEN P_WB_REG_I_DATA_SEL = "01"    -- ALU
        ELSE
        MEM_DATA_O WHEN P_WB_REG_I_DATA_SEL = "10"  -- Memoria
        ELSE
        P_WB_ALU_RES_FP;   -- ALU_FP

END Behavioral;