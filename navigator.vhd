library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity navigator is
    port(
        clk : in std_logic; -- the screen redraw clock
        directions: in std_logic_vector(3 downto 0);
        x_out, y_out : out integer
    );
end entity;

architecture test of navigator is
    signal x : integer := 0;
    signal y : integer := 0 ;

    begin
    y_out <= y;
    x_out <= x;
        process(clk)
            begin
                if(rising_edge(clk)) then
                    if(directions(0) = '1') then
                        x <= x + 1;
                    else
                        if(directions(1) = '1') then
                            x <= x - 1;
                        else
                            if(directions(2) = '1') then
                                y <= y + 1;
                            else
                                if(directions(3) = '1') then
                                    y <= y - 1;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
        end process;

end architecture;