library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mcd_tb is
end mcd_tb;

architecture Behavioral of mcd_tb is

    signal X_in  : std_logic_vector(7 downto 0) := "00000000";
    signal Y_in  : std_logic_vector(7 downto 0) := "00000000";

    signal CLK   : std_logic := '0';
    signal RESET : std_logic := '0';
    signal START : std_logic := '0';

    signal X     : std_logic_vector(7 downto 0);
    signal Y     : std_logic_vector(7 downto 0);

    signal S     : std_logic_vector(7 downto 0);
    signal CARRY : std_logic;
    signal EQ    : std_logic;

begin

    DUT : entity work.mcd
        port map (
            X_in  => X_in,
            Y_in  => Y_in,

            CLK   => CLK,
            RESET => RESET,
            START => START,

            X     => X,
            Y     => Y,

            S     => S,
            CARRY => CARRY,
            EQ    => EQ
        );


    -- ==========================================
    -- RELOJ
    -- Periodo = 10 ns
    -- ==========================================

    process
    begin
        while true loop

            CLK <= '0';
            wait for 5 ns;

            CLK <= '1';
            wait for 5 ns;

        end loop;
    end process;


    -- ==========================================
    -- ESTÍMULOS
    -- ==========================================

    process
    begin

        -- PASO 1: colocar los datos de entrada
        X_in <= "00001111"; -- 15
        Y_in <= "00000110"; -- 6

        -- PASO 2: RESET
        RESET <= '1';
        wait for 12 ns;

        RESET <= '0';

        -- PASO 3: iniciar el cálculo
        START <= '1';
        wait for 10 ns;

        START <= '0';

        -- Dejar funcionar la FSM
        wait for 150 ns;

        wait;

    end process;

end Behavioral;