library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity subtractor8_tb is
end subtractor8_tb;

architecture Behavioral of subtractor8_tb is

    signal A     : std_logic_vector(7 downto 0) := "00000000";
    signal B     : std_logic_vector(7 downto 0) := "00000000";
    signal S     : std_logic_vector(7 downto 0);
    signal CARRY : std_logic;

begin

    DUT : entity work.subtractor8
        port map (
            A     => A,
            B     => B,
            S     => S,
            CARRY => CARRY
        );

    process
    begin

        -- Caso 1: 15 - 6 = 9
        A <= "00001111";
        B <= "00000110";
        wait for 10 ns;

        -- Caso 2: 8 - 20
        A <= "00001000";
        B <= "00010100";
        wait for 10 ns;

        -- Caso 3: 21 - 14 = 7
        A <= "00010101";
        B <= "00001110";
        wait for 10 ns;

        -- Caso 4: 6 - 6 = 0
        A <= "00000110";
        B <= "00000110";
        wait for 10 ns;

        wait;

    end process;

end Behavioral;
