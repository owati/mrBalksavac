library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game is
    port(
        -- up, down, left, right, start, sel: in std_logic; -- the control signals
        MAX10_CLK1_50: in std_logic; -- the input clock signal
        -- r, g, b: out std_logic_vector(3 downto 0); -- vga output signals
        -- h_sync, vsync: out std_logic
        KEY : in std_logic_vector(1 downto 0);
        SW : in std_logic_vector(9 downto 0);
        LEDR : out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(0 to 6)
    );
end game;


architecture test of game is
    -----------the used components---------------------------
    component clock is
        port(
            clock_in : in std_logic;
            clock_num : out std_logic
        );
    end component clock;
    ---------------------------------------------------------

    type state is (start, play, fini);
    type cordinate is array (0 to 1) of integer range 0 to 49;
    --------------------------------------------------------
    constant start_disp: std_logic_vector(41 downto 0) := "1111111" & "0100100" & "1110000" & "0001000" & "1111010" &  "1110000" ;
    constant play_disp : std_logic_vector(41 downto 0) := "1111111" & "1111111" & "0011000" & "1110001" & "0001000" &  "1000100" ;
    --------------------------------------------------------
    procedure disp_state(
        signal my_state : in state;
        signal out_put : out std_logic_vector(41 downto 0)
    ) is
        begin
            if(my_state = start) then
                out_put <= start_disp;
            elsif(my_state = play) then 
                out_put <= play_disp;
            else out_put <= "111111111111111111111111111111111111111111";
            end if;
    end procedure;
    --------------------------------------------------------
    signal norm_clock : std_logic;
    signal my_state : state := start;
    signal cord : cordinate := (0,0);
    signal b : std_logic := SW(0);
    signal hex_out : std_logic_vector(41 downto 0);

    begin
    
    normal_time : clock port map(MAX10_CLK1_50, norm_clock);

    disp_state(my_state, hex_out);

    HEX5 <= hex_out(41 downto 35);
    HEX4 <= hex_out(34 downto 28);
    HEX3 <= hex_out(27 downto 21);
    HEX2 <= hex_out(20 downto 14);
    HEX1 <= hex_out(13 downto 7);
    HEX0 <= hex_out(6 downto 0);
    
    
    test : process(norm_clock)
        begin
            if (rising_edge(norm_clock)) then
                if(b = '1') then
                    my_state <= play;
                    LEDR(0) <= '1';
                else 
                    my_state <= start;
                    LEDR(0) <= '0';
                end if;
            end if;
    end process;


end architecture;