library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mr_balk is
generic(image_Width  : INTEGER := 50; -- Width of image in memory
        image_Height : INTEGER := 50; -- Height of image in memory
        dataSize     : INTEGER := 11;  -- MSB of each row in memory
        addressSize  : integer := 11); -- MSB of addresses
port(clk50MHz  : in std_logic;
     SW : in std_logic_vector(9 downto 0);

     r         : out std_logic_vector(3 downto 0);
     g         : out std_logic_vector(3 downto 0);
     b         : out std_logic_vector(3 downto 0);
     hsync     : out std_logic;
     vsync     : out std_logic);
end entity mr_balk;

architecture display of mr_balk is
	-- Parameters for a 640x480 display
	constant hfp480p  : integer   := 16;
	constant hsp480p  : integer   := 96;
	constant hbp480p  : integer   := 48;
	constant hva480p  : integer   := 640;
	constant vfp480p  : integer   := 10;
	constant vsp480p  : integer   := 2;
	constant vbp480p  : integer   := 33;
	constant vva480p  : integer   := 480;
	-- Parameters for a 1024x768 display
	constant hfp768p  : integer   := 24;
	constant hsp768p  : integer   := 136;
	constant hbp768p  : integer   := 160;
	constant hva768p  : integer   := 1024;
	constant vfp768p  : integer   := 3;
	constant vsp768p  : integer   := 6;
	constant vbp768p  : integer   := 29;
	constant vva768p  : integer   := 768;
	-- Signals that will hold the front port etc that we will acutally use
	signal   hfp      : integer; -- horizontal front porch
	signal   hsp      : integer; -- horizontal sync pulse
	signal   hbp      : integer; -- horizontal back porch
	signal   hva      : integer; -- horizontal visible area
	signal   vfp      : integer; -- vertical front porch
	signal   vsp      : integer; -- vertical sync pulse
	signal   vbp      : integer; -- vertical back porch
	signal   vva      : integer; -- vertical visible area
	-- Signal to hold the clock we will use for the display
	signal   sync2_clk : std_logic := '0';
	-- Signals for each of the clocks available to us
	signal   clk25      : std_logic := '0';
	signal   clk65      : std_logic := '0';
	-- Signals to hold the present horizontal and vertical positions.
	signal   hposition  : integer   := 0;
	signal   vposition  : integer   := 0;
	-- Signals to hold the present memory address to be read and the data read
	signal data_address : std_logic_vector(addressSize downto 0) := (others=>'0');
	signal raw_data     : std_logic_vector(dataSize downto 0)    := (others=>'0');
	
	-- signal holds the vertical postion select
	signal vert_select : std_logic := SW(8);
	-- signal holds the resolution select
	signal res_select : std_logic := SW(9);
-- signal that holds the current vertical position..
	signal vert_pos : integer;
	----------------------------------------------------------------------------------
	signal hcentre            : integer := hfp + hsp + hbp + (hva/2);
	signal vcentre            : integer := vfp + vsp + vbp + (vva/2);
	----------------------------------------------------------------------------
	signal norm_clock : std_logic;
	-----------cordinate signals-------------------------------------------
	signal cord_x : integer := 0 ;
	signal cord_y : integer := 0;
	-------------the maze cordinate---------------------------
	type cordinate is array (0 to 5) of integer;
	signal maze_cord : cordinate;

	signal confirm   : boolean := false;

	------the maze generator------------------------------------------
	procedure isMaze(
		signal h_center : in integer;
		signal v_center : in integer;
		signal h_pos    : in integer;
		signal v_pos    : in integer;
		signal maze_cord: in cordinate;
		signal confirmed: out boolean
	) is
		variable h_start : integer;
		variable h_stop  : integer;
		variable v_start : integer;
		variable v_stop  : integer;
		variable confirm : boolean := false;

		begin
			for i in 0 to (maze_cord'length/2 - 1) loop
				h_start := h_center - (maze_cord(i * 2) * 50) - 20;
				h_stop := h_start + 40;
				v_start:= v_center - (maze_cord(i*2 + 1) * 50) - 20;
				v_stop := v_start + 40;

				if ((h_pos >= h_start and h_pos <= h_stop) and (v_pos >= v_start and v_pos <= v_stop)) then
					confirm := true;
				end if;
			end loop;
			
			confirmed <= confirm;
	end procedure;
	
begin
	sync2_clk<= clk25   when (res_select = '0') else clk25;
	hfp      <= hfp480p when (res_select = '0') else hfp768p;
	hsp      <= hsp480p when (res_select = '0') else hsp768p;
	hbp      <= hbp480p when (res_select = '0') else hbp768p;
	hva      <= hva480p when (res_select = '0') else hva768p;
	vfp      <= vfp480p when (res_select = '0') else vfp768p;
	vsp      <= vsp480p when (res_select = '0') else vsp768p;
	vbp      <= vbp480p when (res_select = '0') else vbp768p;
	vva      <= vva480p when (res_select = '0') else vva768p;

	maze_cord <= (5,4,  4,4  3,1);



	norm_clk : work.game_clk port map(clk50MHz, norm_clock);
	
	
	disp_clk: work.sync_clk port map(inclk0 => clk50MHz,
											c0     => clk25);
	
	image_read : work.charac_mem port map(data_address, sync2_clk, raw_data);

	navigator_component : work.navigator port map(norm_clock,SW(3 downto 0),cord_x, cord_y);

	maze_checker : isMaze(hcentre, vcentre, hposition, vposition, maze_cord, confirm);

	process(sync2_clk)
	variable image_hstart       : integer := hcentre  - (cord_x * 50)    - image_Width/2;
	variable image_hstop        : integer := image_hstart + image_Width;
	variable image_vstart       : integer := vcentre -(cord_y * 50)  - image_Height / 2;
	variable image_vstop        : integer := image_vstart + image_Height;
	variable image_pixel_col    : integer := 0;
	variable image_pixel_row    : integer := 0;
	variable image_pixel_number : integer := 0;
	variable mem_Address        : unsigned(addressSize downto 0) := (others=>'0');
	 

	begin
		if rising_edge(sync2_clk) then
			
			hposition <= hposition + 1;
			

			if hposition >= (hfp+hsp+hbp+hva) then
				hposition <= 0;

				if vposition >= (vfp+vsp+vbp+vva) then
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
			
			

			if ((hposition >= image_hstart and hposition <= image_hstop) and (vposition >= image_vstart and vposition <= image_vstop)) then
				image_pixel_col := hposition - image_hstart;
				image_pixel_row := vposition - image_vstart;
				image_pixel_number := image_pixel_col + image_pixel_row*image_Width;
				mem_Address  := to_unsigned(image_pixel_number, mem_Address'length);
				data_address <= std_logic_vector(mem_Address);
				r <= raw_data(11 downto 8);
				g <= raw_data(7 downto 4);
				b <= raw_data(3 downto 0);
			elsif(confirm) then
				r <= x"e";
				g <= x"7";
				b <= x"a";
			else
				r <= x"0";
				g <= x"0";
				b <= x"0";
			end if;
		end if;
	end process;

end architecture display;