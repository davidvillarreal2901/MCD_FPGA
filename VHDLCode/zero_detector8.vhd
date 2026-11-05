library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity zero_detector8 is
    port (
        S  : in  std_logic_vector(7 downto 0);
        EQ : out std_logic
    );
end zero_detector8;


architecture Behavioral of zero_detector8 is

begin

    EQ <= not (
        S(7) or
        S(6) or
        S(5) or
        S(4) or
        S(3) or
        S(2) or
        S(1) or
        S(0)
    );

end Behavioral;