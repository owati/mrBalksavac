library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game is
    port(
        -- up, down, left, right, start, sel: in std_logic; -- the control signals
        -- clk50MHZ: in std_logic; -- the input clock signal
        -- r, g, b: out std_logic_vector(3 downto 0); -- vga output signals
        -- h_sync, vsync: out std_logic
        SW : in std_logic_vector(9 downto 0);
        LEDR : out std_logic_vector(9 downto 0)
    );
end game;


architecture test of game is
type state is (play, no_play);
signal pol: std_logic_vector(9 downto 0);
begin
    my : process(SW)
    begin
        if(unsigned(SW) > 50) then
            pol <= "0000011111";
        else pol <= "1111100000";
        end if;
    end process;
    LEDR <= pol;
end architecture;