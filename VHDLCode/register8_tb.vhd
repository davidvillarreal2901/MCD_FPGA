library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register8_tb is
end register8_tb;

architecture Behavioral of register8_tb is

    signal D    : std_logic_vector(7 downto 0) := "00000000";
    signal CLK  : std_logic := '0';
    signal LOAD : std_logic := '0';
    signal Q    : std_logic_vector(7 downto 0);

begin

    DUT : entity work.register8
        port map (
            D    => D,
            CLK  => CLK,
            LOAD => LOAD,
            Q    => Q
        );

    -- Generador de reloj
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

        -- LOAD desactivado
        LOAD <= '0';

        -- D = 15
        D <= "00001111";
        wait for 12 ns;

        -- D = 9, pero LOAD sigue en 0
        D <= "00001001";
        wait for 10 ns;

        -- Ahora activamos LOAD
        LOAD <= '1';
        wait for 10 ns;

        -- D = 3, LOAD sigue activo
        D <= "00000011";
        wait for 10 ns;

        -- Desactivamos LOAD
        LOAD <= '0';
        wait for 10 ns;

        wait;

    end process;

end Behavioral;