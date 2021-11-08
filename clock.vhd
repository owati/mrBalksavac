library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock is
    port(
        clock_in: in std_logic; -- the fast clock input
        clock_num : out std_logic -- the normal time signal
    );
end entity;


architecture test of clock is
    signal clock : std_logic := clock_in;
    signal num : integer := 0;
    signal out_put : std_logic := '0';
	 
	 begin

    slow_down : process(clock)
        begin
            if(rising_edge(clock)) then
                if(num = 50000000) then 
                    num <= 0;
                    out_put <= '1';
                else
                    num <= num + 1;
                    out_put <= '0';
                end if;
            end if;
    end process;

    clock_num <= out_put;
end architecture;
