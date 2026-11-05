library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity zero_detector8_tb is
end zero_detector8_tb;

architecture Behavioral of zero_detector8_tb is

    signal S  : std_logic_vector(7 downto 0) := "00000000";
    signal EQ : std_logic;

begin

    DUT : entity work.zero_detector8
        port map (
            S  => S,
            EQ => EQ
        );

    process
    begin

        -- Caso 1: S = 00
        S <= "00000000";
        wait for 10 ns;

        -- Caso 2: S = 09
        S <= "00001001";
        wait for 10 ns;

        -- Caso 3: S = F4
        S <= "11110100";
        wait for 10 ns;

        -- Caso 4: S = 07
        S <= "00000111";
        wait for 10 ns;

        -- Caso 5: S vuelve a 00
        S <= "00000000";
        wait for 10 ns;

        wait;

    end process;

end Behavioral;
