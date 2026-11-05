library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity subtractor8 is
    port (
        A     : in  std_logic_vector(7 downto 0);
        B     : in  std_logic_vector(7 downto 0);
        S     : out std_logic_vector(7 downto 0);
        CARRY : out std_logic
    );
end subtractor8;


architecture Behavioral of subtractor8 is

    signal TEMP : unsigned(8 downto 0);

begin

    TEMP <= ('0' & unsigned(A))
          + ('0' & unsigned(not B))
          + 1;

    S     <= std_logic_vector(TEMP(7 downto 0));
    CARRY <= TEMP(8);

end Behavioral;