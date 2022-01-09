library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- aim of this entity is to provide a slower clock with which 
-- we update the character position
entity game_clk is
    port(
        clk : in std_logic;
        out_clk : out std_logic
    );
end entity;

architecture test of game_clk is
    signal number : integer := 0;

    begin
        clock_divider : process(clk)
        begin
            if(rising_edge(clk)) then
                if (number = 25000000) then
                    number <= 0;
                    out_clk <= '1';
                else number <= number + 1; out_clk <= '0';
                end if;
            end if;
        end process;

end architecture;