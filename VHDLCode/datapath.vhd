library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
    port (
        X_in   : in  std_logic_vector(7 downto 0);
        Y_in   : in  std_logic_vector(7 downto 0);

        CLK    : in  std_logic;

        SEL    : in  std_logic;
        SEL_X  : in  std_logic;
        SEL_Y  : in  std_logic;

        LOAD_X : in  std_logic;
        LOAD_Y : in  std_logic;

        X      : out std_logic_vector(7 downto 0);
        Y      : out std_logic_vector(7 downto 0);

        S      : out std_logic_vector(7 downto 0);
        CARRY  : out std_logic;
        EQ     : out std_logic
    );
end datapath;


architecture Structural of datapath is

    -- Señales internas

    signal X_reg : std_logic_vector(7 downto 0);
    signal Y_reg : std_logic_vector(7 downto 0);

    signal X_D : std_logic_vector(7 downto 0);
    signal Y_D : std_logic_vector(7 downto 0);

    signal A : std_logic_vector(7 downto 0);
    signal B : std_logic_vector(7 downto 0);

    signal S_int : std_logic_vector(7 downto 0);

begin

    ----------------------------------------------------------------
    -- MUX_X
    -- SEL_X = 0 → X_in
    -- SEL_X = 1 → S_int
    ----------------------------------------------------------------

    MUX_X : entity work.mux2_8bit
        port map (
            I0  => X_in,
            I1  => S_int,
            SEL => SEL_X,
            Y   => X_D
        );


    ----------------------------------------------------------------
    -- REG_X
    ----------------------------------------------------------------

    REG_X : entity work.register8
        port map (
            D    => X_D,
            CLK  => CLK,
            LOAD => LOAD_X,
            Q    => X_reg
        );


    ----------------------------------------------------------------
    -- MUX_Y
    -- SEL_Y = 0 → Y_in
    -- SEL_Y = 1 → S_int
    ----------------------------------------------------------------

    MUX_Y : entity work.mux2_8bit
        port map (
            I0  => Y_in,
            I1  => S_int,
            SEL => SEL_Y,
            Y   => Y_D
        );


    ----------------------------------------------------------------
    -- REG_Y
    ----------------------------------------------------------------

    REG_Y : entity work.register8
        port map (
            D    => Y_D,
            CLK  => CLK,
            LOAD => LOAD_Y,
            Q    => Y_reg
        );


    ----------------------------------------------------------------
    -- MUX_A
    -- SEL = 0 → A = X
    -- SEL = 1 → A = Y
    ----------------------------------------------------------------

    MUX_A : entity work.mux2_8bit
        port map (
            I0  => X_reg,
            I1  => Y_reg,
            SEL => SEL,
            Y   => A
        );


    ----------------------------------------------------------------
    -- MUX_B
    -- SEL = 0 → B = Y
    -- SEL = 1 → B = X
    ----------------------------------------------------------------

    MUX_B : entity work.mux2_8bit
        port map (
            I0  => Y_reg,
            I1  => X_reg,
            SEL => SEL,
            Y   => B
        );


    ----------------------------------------------------------------
    -- RESTADOR
    ----------------------------------------------------------------

    SUBTRACTOR : entity work.subtractor8
        port map (
            A     => A,
            B     => B,
            S     => S_int,
            CARRY => CARRY
        );


    ----------------------------------------------------------------
    -- DETECTOR DE IGUALDAD
    ----------------------------------------------------------------

    ZERO_DETECTOR : entity work.zero_detector8
        port map (
            S  => S_int,
            EQ => EQ
        );


    ----------------------------------------------------------------
    -- Salidas
    ----------------------------------------------------------------

    X <= X_reg;
    Y <= Y_reg;

    S <= S_int;

end Structural;