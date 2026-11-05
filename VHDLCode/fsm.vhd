library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm is
    port (
        CLK     : in  std_logic;
        RESET   : in  std_logic;
        START   : in  std_logic;

        EQ      : in  std_logic;
        CARRY   : in  std_logic;

        SEL     : out std_logic;
        SEL_X   : out std_logic;
        SEL_Y   : out std_logic;

        LOAD_X  : out std_logic;
        LOAD_Y  : out std_logic
    );
end fsm;


architecture Behavioral of fsm is

    type state_type is (
        IDLE,
        LOAD,
        CHECK_EQUAL,
        COMPARE,
        SUB_X,
        SUB_Y,
        DONE
    );

    signal STATE, NEXT_STATE : state_type;

begin

    -- Registro de estado
    process(CLK, RESET)
    begin
        if RESET = '1' then
            STATE <= IDLE;

        elsif rising_edge(CLK) then
            STATE <= NEXT_STATE;
        end if;
    end process;


    -- Lógica de próximo estado
    process(STATE, START, EQ, CARRY)
    begin

        -- Valor por defecto
        NEXT_STATE <= STATE;

        case STATE is

            when IDLE =>
                if START = '1' then
                    NEXT_STATE <= LOAD;
                end if;


            when LOAD =>
                NEXT_STATE <= CHECK_EQUAL;


            when CHECK_EQUAL =>
                if EQ = '1' then
                    NEXT_STATE <= DONE;
                else
                    NEXT_STATE <= COMPARE;
                end if;


            when COMPARE =>
                if CARRY = '1' then
                    NEXT_STATE <= SUB_X;
                else
                    NEXT_STATE <= SUB_Y;
                end if;


            when SUB_X =>
                NEXT_STATE <= CHECK_EQUAL;


            when SUB_Y =>
                NEXT_STATE <= CHECK_EQUAL;


            when DONE =>
                NEXT_STATE <= DONE;


            when others =>
                NEXT_STATE <= IDLE;

        end case;

    end process;


    -- Lógica de salidas
    process(STATE)
    begin

        -- Valores por defecto
        SEL     <= '0';
        SEL_X   <= '0';
        SEL_Y   <= '0';
        LOAD_X  <= '0';
        LOAD_Y  <= '0';

        case STATE is

            when IDLE =>
                null;


            when LOAD =>
                SEL_X  <= '0';
                SEL_Y  <= '0';
                LOAD_X <= '1';
                LOAD_Y <= '1';


            when CHECK_EQUAL =>
                SEL <= '0';


            when COMPARE =>
                SEL <= '0';


            when SUB_X =>
                SEL    <= '0';
                SEL_X  <= '1';
                LOAD_X <= '1';


            when SUB_Y =>
                SEL    <= '1';
                SEL_Y  <= '1';
                LOAD_Y <= '1';


            when DONE =>
                null;


            when others =>
                null;

        end case;

    end process;

end Behavioral;