library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity display is
    generic(
        ----------the character generics---------------------------
        charac_width: integer := 149; -- the length and width of the character
        charac_dataSize : integer := 11;
        charac_addressSize : integer := 14
    );
    port(
        clock : in std_logic; -- the clock
        my_state : in state;   -- the current state of the game
        cord : in cordinate;  -- the current position of the character
        r, g, b : out std_logic_vector(3 downto 0);
        hsync : out std_logic;
        vsync : out std_logic
    );
end entity;

architecture test of display is
    -- Parameters for a 640x480 display-----------------
	constant hfp  : integer   := 16;
	constant hsp  : integer   := 96;
	constant hbp  : integer   := 48;
	constant hva  : integer   := 640;
	constant vfp  : integer   := 10;
	constant vsp  : integer   := 2;
	constant vbp  : integer   := 33;
	constant vva  : integer   := 480;
    ---------------------------------------------------
    signal vga_clk : std_logic ; -- the clock to be used by the screen
    -----------------------------------------------------------
    -----these holds the current data of the character image being read-------
    signal charac_data_address: std_logic_vector(charac_addressSize downto 0) := (others => '0'); 
    signal charac_raw_data : std_logic_vector(charac_dataSize downto 0) := (others => '0');
    
    ----------------the center of the screen----------------------------
    signal hcenter : integer := hfp + hsp + hbp + (hva / 2);
    signal vcenter : integer := vfp + vsp + vbp + (vva / 2);

    ------------the current horizontal and vertical position------------------
    signal hposition : integer := 0;
    signal vposition : integer := 0;
    ----------------the signals needed for now---------------------------
begin

    video_clk: work.sync_clk port map(clock, vga_clk);
    charac_read: work.charac_mem port map(charac_data_address,charac_raw_data);

    process(sync_clk)
    -----------the character variables-------------------------------
    variable charac_hstart : integer := hcenter - charac_width / 2;
    variable charac_hstop : integer := charac_hstart + charac_width;
    variable charac_vstart : integer := vcenter - charac_width / 2;
    variable charac_vstop : integer := charac_vstart + charac_width;
    variable charac_pixel_col : integer := 0;
    variable charac_pixel_row : integer := 0;
    variable charac_pixel_num : integer := 0;
    variable charac_mem_address : unsigned(charac_addressSize downto 0) := (others => '0');

    begin
        if rising_edge(sync_clk) then
            hposition <= hposition + 1;

            if hposition >= (hfp + hsp + hbp + hva) then
                hpositon <= 0;

                if vposition >= (vfp + vsp + vbp + vva) then
                    vposition <= 0;
                else
                    vposition <= vposition + 1;
                end if;
            end if;

            if (hposition >= hfp) and (hposition < (hfp+hsp)) then
				hsync <= '0';
			else
				hsync <= '1';
			end if;

			if (vposition >= vfp) and (vposition < (vfp+vsp)) then
				vsync <= '0';
			else
				vsync <= '1';
			end if;

        ------- the display code -------------------------------------------
            if ((hposition >= charac_hstart and hpositon <= charac_hstop) and (vposition >= charac_hstart  and vposition <= charac_hstop)) then
                charac_pixel_col := hpostion - charac_hstart;
                charac_pixel_row := vposition - charac_vstart;
                charac_pixel_num := charac_pixel_col + 

            end if;
        end if;
    end process;
end architecture;