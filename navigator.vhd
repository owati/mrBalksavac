library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity navigator is
    port(
        clk : in std_logic; -- the screen redraw clock
        directions: in std_logic_vector(3 downto 0);
        x_out, y_out : out integer;
        state : out std_logic_vector(1 downto 0)
    );
end entity;

architecture test of navigator is
    type cordinate is array (0 to 123) of integer;
	signal maze_cord : cordinate;

    signal x : integer := 0;
    signal y : integer := 0;

    signal state_sig : std_logic_vector(1 downto 0) := "00";


    begin
    y_out <= y;
    x_out <= x;

    
	maze_cord <= (5,4,  4,4,  3,4, 2,4, 1,4, 0,4, -1,4, -2,4, -3,4, -4,4, -5,4,
    5,3, -4,3, -5,3,
    5,2, 3,2, 2,2, 1,2, 0,2, -2,2, -4,2, -5,2,
    5,1, 1,1, 0,1, -2,1, 
    5,0, 4,0, 2,0, 1,0, -1,0, -2,0, -3,0, -5,0,
    5,-1, 4,-1, 2,-1, 1,-1, -1,-1, -3,-1, -5,-1,
    5,-2, 4,-2, 2,-2, 1,-2, -1,-2, -3,-2, -5,-2,
    5,-3, -3,-3, -5,-3,
    5,-4,  4,-4,  3,-4, 2,-4, 1,-4, 0,-4, -1,-4, -2,-4, -3,-4, -4,-4, -5,-4);

        process(clk)
            variable x_var : integer := x;
            variable y_var : integer := y;
            begin
                if(rising_edge(clk)) then
                    ----incrememts the cordinate based on the direction..
                    if state_sig = "00" then
                        if(directions(0) = '1' or directions(2) = '1' or directions(1) = '1' or  directions(3) = '1') then
                            state_sig <= "01";
                        end if;
                    elsif state_sig = "01" then
                        if(directions(0) = '1') then
                            x_var := x + 1;
                        else
                            if(directions(1) = '1') then
                                x_var := x - 1;
                            else
                                if(directions(2) = '1') then
                                    y_var := y + 1;
                                else
                                    if(directions(3) = '1') then
                                        y_var := y - 1;
                                    end if;
                                end if;
                            end if;
                        end if;


                        --- chacks if the place to be moved is a containing a wall------------
                        for i in 0 to (maze_cord'length/2 - 1) loop
                            if(x_var = maze_cord(i * 2)) and (y_var = maze_cord(i*2 + 1)) then
                                x_var := x;
                                y_var := y;
                            end if;
                        end loop;


                        --whwn you get out of the maze------------------
                        if(x_var = -6) and (y_var = 1) then
                            x_var := 0;
                            y_var := 0;
                        end if;
                    end if;
                    x <= x_var;
                    y <= y_var;
                    state <= state_sig;

                end if;
        end process;

end architecture;