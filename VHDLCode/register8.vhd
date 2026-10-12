library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register8 is
    port (
        D   : in  std_logic_vector(7 downto 0);
        CLK : in  std_logic;
        LOAD : in std_logic;
        Q   : out std_logic_vector(7 downto 0)
    );
end register8;

architecture Behavioral of register8 is

begin

    process(CLK)
    begin
        if rising_edge(CLK) then

            if LOAD = '1' then
                Q <= D;
            end if;
            
        end if;
    end process;

end Behavioral;