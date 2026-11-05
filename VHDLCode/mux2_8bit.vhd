library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2_8bit is
    port (
        I0  : in  std_logic_vector(7 downto 0);
        I1  : in  std_logic_vector(7 downto 0);
        SEL : in  std_logic;
        Y   : out std_logic_vector(7 downto 0)
    );
end mux2_8bit;


architecture Behavioral of mux2_8bit is

begin

    Y <= I0 when SEL = '0' else I1;

end Behavioral;
