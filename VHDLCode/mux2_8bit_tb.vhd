library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2_8bit_tb is
end mux2_8bit_tb;


architecture Behavioral of mux2_8bit_tb is

    signal I0  : std_logic_vector(7 downto 0) := "00000000";
    signal I1  : std_logic_vector(7 downto 0) := "00000000";
    signal SEL : std_logic := '0';
    signal Y   : std_logic_vector(7 downto 0);

begin

    DUT : entity work.mux2_8bit
        port map (
            I0  => I0,
            I1  => I1,
            SEL => SEL,
            Y   => Y
        );


    process
    begin

        -- I0 = 15, I1 = 6
        I0 <= "00001111";
        I1 <= "00000110";

        -- SEL = 0 → Y debe ser I0 = 15
        SEL <= '0';
        wait for 10 ns;


        -- SEL = 1 → Y debe ser I1 = 6
        SEL <= '1';
        wait for 10 ns;


        -- Cambiamos las entradas
        I0 <= "00000011";
        I1 <= "00001001";

        -- SEL sigue en 1 → Y debe ser 9
        wait for 10 ns;


        -- SEL = 0 → Y debe ser 3
        SEL <= '0';
        wait for 10 ns;


        wait;

    end process;

end Behavioral;