library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mcd is
    port (
        X_in   : in  std_logic_vector(7 downto 0);
        Y_in   : in  std_logic_vector(7 downto 0);

        CLK    : in  std_logic;
        RESET  : in  std_logic;
        START  : in  std_logic;

        X      : out std_logic_vector(7 downto 0);
        Y      : out std_logic_vector(7 downto 0);

        S      : out std_logic_vector(7 downto 0);
        CARRY  : out std_logic;
        EQ     : out std_logic
    );
end mcd;


architecture Structural of mcd is

    -- Señales que conectan la FSM con el datapath
    signal SEL_int     : std_logic;
    signal SEL_X_int   : std_logic;
    signal SEL_Y_int   : std_logic;

    signal LOAD_X_int  : std_logic;
    signal LOAD_Y_int  : std_logic;

    -- Señales que regresan del datapath a la FSM
    signal EQ_int      : std_logic;
    signal CARRY_int   : std_logic;

begin

    -- ==========================================
    -- FSM
    -- ==========================================

    CONTROL : entity work.fsm
        port map (
            CLK     => CLK,
            RESET   => RESET,
            START   => START,

            EQ      => EQ_int,
            CARRY   => CARRY_int,

            SEL     => SEL_int,
            SEL_X   => SEL_X_int,
            SEL_Y   => SEL_Y_int,

            LOAD_X  => LOAD_X_int,
            LOAD_Y  => LOAD_Y_int
        );


    -- ==========================================
    -- DATAPATH
    -- ==========================================

    DATA : entity work.datapath
        port map (
            X_in   => X_in,
            Y_in   => Y_in,

            CLK    => CLK,

            SEL    => SEL_int,
            SEL_X  => SEL_X_int,
            SEL_Y  => SEL_Y_int,

            LOAD_X => LOAD_X_int,
            LOAD_Y => LOAD_Y_int,

            X      => X,
            Y      => Y,

            S      => S,
            CARRY  => CARRY_int,
            EQ     => EQ_int
        );


    -- Salidas del datapath
    CARRY <= CARRY_int;
    EQ    <= EQ_int;

end Structural;