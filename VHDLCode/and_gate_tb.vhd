library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity and_gate_tb is
end and_gate_tb;

architecture Behavioral of and_gate_tb is

    -- Señales que conectaremos al circuito que estamos probando
    signal A : std_logic := '0';
    signal B : std_logic := '0';
    signal Y : std_logic;

begin

    -- Instancia del circuito AND
    DUT: entity work.and_gate
        port map (
            A => A,
            B => B,
            Y => Y
        );

    -- Proceso de prueba
    process
    begin

        -- Prueba 1: 0 AND 0
        A <= '0';
        B <= '0';
        wait for 10 ns;

        -- Prueba 2: 0 AND 1
        A <= '0';
        B <= '1';
        wait for 10 ns;

        -- Prueba 3: 1 AND 0
        A <= '1';
        B <= '0';
        wait for 10 ns;

        -- Prueba 1: 1 AND 1
        A <= '1';
        B <= '1';
        wait for 10 ns;

        -- Finalizar simulación
        wait;

    end process;

end Behavioral;