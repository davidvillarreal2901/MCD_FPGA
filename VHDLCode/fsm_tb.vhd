library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm_tb is
end fsm_tb;

architecture Behavioral of fsm_tb is

    signal CLK     : std_logic := '0';
    signal RESET   : std_logic := '0';
    signal START   : std_logic := '0';

    signal EQ      : std_logic := '0';
    signal CARRY   : std_logic := '0';

    signal SEL     : std_logic;
    signal SEL_X   : std_logic;
    signal SEL_Y   : std_logic;

    signal LOAD_X  : std_logic;
    signal LOAD_Y  : std_logic;

begin

    DUT : entity work.fsm
        port map (
            CLK     => CLK,
            RESET   => RESET,
            START   => START,

            EQ      => EQ,
            CARRY   => CARRY,

            SEL     => SEL,
            SEL_X   => SEL_X,
            SEL_Y   => SEL_Y,

            LOAD_X  => LOAD_X,
            LOAD_Y  => LOAD_Y
        );


    -- Reloj de 10 ns
    process
    begin
        while true loop
            CLK <= '0';
            wait for 5 ns;

            CLK <= '1';
            wait for 5 ns;
        end loop;
    end process;


    -- Estímulos
    process
    begin

        -- PASO 1: RESET
        RESET <= '1';
        wait for 12 ns;

        RESET <= '0';

        -- PASO 2: START
        START <= '1';
        wait for 10 ns;

        START <= '0';

        -- PASO 3: X != Y
        EQ <= '0';

        -- X > Y
        CARRY <= '1';
        wait for 30 ns;

        -- PASO 4: X < Y
        CARRY <= '0';
        wait for 30 ns;

        -- PASO 5: X = Y
        EQ <= '1';
        wait for 20 ns;

        wait;

    end process;

end Behavioral;