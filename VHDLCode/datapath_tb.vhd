library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath_tb is
end datapath_tb;

architecture Behavioral of datapath_tb is

    signal X_in   : std_logic_vector(7 downto 0) := "00000000";
    signal Y_in   : std_logic_vector(7 downto 0) := "00000000";

    signal CLK    : std_logic := '0';

    signal SEL    : std_logic := '0';
    signal SEL_X  : std_logic := '0';
    signal SEL_Y  : std_logic := '0';

    signal LOAD_X : std_logic := '0';
    signal LOAD_Y : std_logic := '0';

    signal X      : std_logic_vector(7 downto 0);
    signal Y      : std_logic_vector(7 downto 0);

    signal S      : std_logic_vector(7 downto 0);
    signal CARRY  : std_logic;
    signal EQ     : std_logic;

begin

    DUT : entity work.datapath
        port map (
            X_in   => X_in,
            Y_in   => Y_in,

            CLK    => CLK,

            SEL    => SEL,
            SEL_X  => SEL_X,
            SEL_Y  => SEL_Y,

            LOAD_X => LOAD_X,
            LOAD_Y => LOAD_Y,

            X      => X,
            Y      => Y,

            S      => S,
            CARRY  => CARRY,
            EQ     => EQ
        );


    ----------------------------------------------------------------
    -- Generador de reloj
    ----------------------------------------------------------------

    process
    begin
        while true loop

            CLK <= '0';
            wait for 5 ns;

            CLK <= '1';
            wait for 5 ns;

        end loop;
    end process;


    ----------------------------------------------------------------
    -- ESTÍMULOS
    ----------------------------------------------------------------

    process
    begin
        -- PASO 1: cargar X=6, Y=9
        X_in <= "00000110";
        Y_in <= "00001001";

        SEL_X <= '0';
        SEL_Y <= '0';

        LOAD_X <= '1';
        LOAD_Y <= '1';

        wait for 12 ns;

        -- PASO 2: preparar Y - X
        LOAD_X <= '0';
        LOAD_Y <= '0';

        SEL <= '1';

        wait for 5 ns;

        -- PASO 3: cargar el resultado S en Y
        SEL_Y <= '1';
        LOAD_Y <= '1';

        wait for 10 ns;

        -- PASO 4: dejar de cargar Y
        LOAD_Y <= '0';
        SEL_Y <= '0';

        wait;

    end process;


end Behavioral;
