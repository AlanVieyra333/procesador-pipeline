library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE ieee.numeric_std.ALL;

entity floating_point is
    Port ( A : in STD_LOGIC_VECTOR (31 downto 0);
           B : in STD_LOGIC_VECTOR (31 downto 0);
           Ope : in STD_LOGIC_VECTOR (1 downto 0);
           Result : out STD_LOGIC_VECTOR (31 downto 0));
end floating_point;

architecture Behavioral of floating_point is

component extender is
    Port ( i_data : in STD_LOGIC_VECTOR (22 downto 0);
           o_data : out STD_LOGIC_VECTOR (23 downto 0));
end component;

component bit_shift is
    Port ( i_data : in STD_LOGIC_VECTOR (23 downto 0);
           n : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (23 downto 0));
end component;

component ALU_FP IS
    GENERIC (
        LENGTH : NATURAL := 32
    );
    PORT (
        A, B : IN STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
        OPE : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        RESULT_L : OUT STD_LOGIC_VECTOR (LENGTH - 1 DOWNTO 0);
        FLAGS : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)   -- N,C
    );
END component;

component carry_decoder is
    Port ( i_mantissa : in STD_LOGIC_VECTOR (23 downto 0);
           i_exponent : in STD_LOGIC_VECTOR (7 downto 0);
           carry : in STD_LOGIC;
           ope : in STD_LOGIC_vector(1 downto 0);
           o_mantissa : out STD_LOGIC_VECTOR (22 downto 0);
           o_exponent : out STD_LOGIC_VECTOR (7 downto 0));
end component;

component absol is
generic(
 size : integer := 32
);
  
  Port ( 
   i_data : in STD_LOGIC_VECTOR(size-1 downto 0);
   o_data : out STD_LOGIC_VECTOR(size-1 downto 0)
   
  );
end component;

signal s_A, s_B : STD_LOGIC;
signal exp_A, exp_B : STD_LOGIC_VECTOR (7 downto 0);
signal m_A, m_B : STD_LOGIC_VECTOR (22 downto 0);

signal m_ext_A, m_ext_B : STD_LOGIC_VECTOR (23 downto 0);
signal n_shift : STD_LOGIC_VECTOR (7 downto 0);
signal n_flag : STD_LOGIC;
signal m_ext_sel_shift, m_ext_sel_alu : STD_LOGIC_VECTOR (23 downto 0);
signal m_shift : STD_LOGIC_VECTOR (23 downto 0); 

signal exp_sel : STD_LOGIC_VECTOR (7 downto 0);
signal alu_res : STD_LOGIC_VECTOR (23 downto 0);
signal c_flag : STD_LOGIC;

signal m_res : STD_LOGIC_VECTOR (22 downto 0);
signal exp_res : STD_LOGIC_VECTOR (7 downto 0);
signal s_sum, s_sub, s_mul, s_res : STD_LOGIC;
signal c_tmp, n_tmp : STD_LOGIC;
signal n_shift_alu : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal alu_m_res : STD_LOGIC_VECTOR(23 DOWNTO 0);

begin

s_A <= A(31); 
s_B <= B(31);
exp_A <= A(30 downto 23);
exp_B <= B(30 downto 23);
m_A <= A(22 downto 0);
m_B <= B(22 downto 0);

ALU_shift : ALU_FP generic map(8) port map(A=> exp_A, B => exp_B, OPE => "01", RESULT_L => n_shift_alu, FLAGS(1) => n_flag, FLAGS(0) => c_tmp);
absol_pm : absol generic map(8) port map(i_data => n_shift_alu , o_data => n_shift);
extenderA : extender port map(i_data => m_A, o_data => m_ext_A); 
extenderB : extender port map(i_data => m_B, o_data => m_ext_B); 

m_ext_sel_alu <= m_ext_A when n_flag = '0'
    else
        m_ext_B;

m_ext_sel_shift <= m_ext_A when n_flag = '1'
    else
        m_ext_B;

bit_shift_pm : bit_shift port map (i_data => m_ext_sel_shift, n=>n_shift, o_data=> m_shift);

ALU_ope : ALU_FP generic map(24) port map(A=> m_ext_sel_alu, B => m_shift, OPE => Ope, RESULT_L => alu_m_res, FLAGS(0) => c_flag, FLAGS(1) => n_tmp);
--absol2_pm : absol generic map(24) port map(i_data => alu_res , o_data => alu_m_res);

exp_sel <= exp_A when n_flag = '0'
    else
        exp_B;
        
carry_dec :carry_decoder port map(i_mantissa =>alu_m_res, i_exponent => exp_sel, carry => c_flag, ope => ope, o_mantissa => m_res, o_exponent => exp_res); 

s_sum <= s_A when n_flag = '0'
    else
        s_B;

s_sub <= s_sum;
s_mul <= s_A xor s_B;

s_res <= s_sum when ope = "00"
    else
        s_sub when ope = "01"
    else
        s_mul;
        
Result <= s_res & exp_res & m_res;        
end Behavioral;
