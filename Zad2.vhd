library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Zad2 is
	port(Clk 			 : in std_logic; -- zegar zewn�trzny 1 Hz
		  time_h 		 : inout std_logic_vector (4 downto 0) := "00000"; -- akutalna godzina
		  time_m 		 : inout std_logic_vector (5 downto 0) := "000000"; -- akutalna minuta
		  time_s			 : inout std_logic_vector (5 downto 0) := "000000"; -- akutalna sekunda
		  temperature 	 : inout std_logic_vector (8 downto 0) := "100011010"; -- temperatura wody (w Kelwinach)
		  state_grzalka : inout std_logic; -- stan grzalki (1 - w�, 0 - wy�)
		  light_h 		 : inout std_logic_vector (4 downto 0) := "01101"; -- godzina w��czenia �wiat�a
		  light_m 		 : inout std_logic_vector (5 downto 0) := "011110"; -- minuta w��czenia �wiat�a)
		  state_swiatlo : inout std_logic); -- stan �wiat�a (1 - w�, 0 - wy�)
end Zad2;

architecture Behavioral of Zad2 is

-- Zegarek ---------------------------------------------------------------------------
procedure zegarek
	(signal zeg   : in std_logic; -- zegar zewn�trzny 1 Hz
	 signal zeg_g : inout std_logic_vector (4 downto 0); -- liczba godzin
	 signal zeg_m : inout std_logic_vector (5 downto 0); -- liczba minut
	 signal zeg_s : inout std_logic_vector (5 downto 0)) is -- liczba sekund
begin
	 if (zeg'event and zeg = '1') then
		if (zeg_s < 59) then
			zeg_s <= zeg_s + 1;
		else
			zeg_s <= "000000";
			if (zeg_m < 59) then
				zeg_m <= zeg_m + 1;
			else
				zeg_m <= "000000";
				if (zeg_g < 23) then
					zeg_g <= zeg_g + 1;
				else
					zeg_g <= "00000";
				end if;
			end if;
		end if;
	end if;
end zegarek;
--------------------------------------------------------------------------------------

-- Grza�ka ---------------------------------------------------------------------------
procedure grzalka 
	(signal temp  : in std_logic_vector (8 downto 0); -- temperatura (0 - 511 K)
	 signal stan  : out std_logic) is -- stan grza�ki (1 - w�, 0 - wy�)
begin
	if (temp < 283) then -- je�li temeperatura poni�ej 10*C
		stan <= '1';
	else
		stan <= '0';
	end if;
end grzalka;
--------------------------------------------------------------------------------------

-- �wiat�o ---------------------------------------------------------------------------
procedure swiatlo
	(signal clk_h : in std_logic_vector (4 downto 0); -- aktualna godzina
	 signal clk_m : in std_logic_vector (5 downto 0); -- aktualna minuta
	 signal wl_h  : in std_logic_vector (4 downto 0); -- godzina w�aczenia �wiat�a
	 signal wl_m  : in std_logic_vector (5 downto 0); -- minuta w��czenia �wiat�a
	 signal state : inout std_logic) is -- stan �wiat�a (1 - w�, 0 - wy�)
	 variable tmp : integer; -- zmienna pomocniczna na aktualny czas w minutach
	 variable tmp_on_1, tmp_off_1, tmp_on_2, tmp_off_2 : integer; -- zmienne pomocnicze 
													-- na czasy wlaczenia i wylaczania w minutach
begin
	tmp := 60*to_integer(unsigned(clk_h)) + to_integer(unsigned(clk_m));
	
	if (wl_h < 4) then
		-- ustalenie punkt�w zmiany stanu �wiat�a na 24h osi czasu --
		tmp_on_1 := 60*to_integer(unsigned(wl_h)) + to_integer(unsigned(wl_m));
		tmp_off_1 := tmp_on_1 + 60*8; -- 8h po tmp_on_1 wy��cza si�
		tmp_on_2 := tmp_on_1 + 60*12; -- w��cza si� 12h p�niej ni� tmp_on_1
		tmp_off_2 := tmp_on_2 + 60*8; -- 8h po tmp_on_2 wy��cza si�
		-- zachowanie �wiat�a w zale�no�ci, w zale�no�ci od aktualnej godziny --
		if ((tmp >= tmp_on_1 and tmp < tmp_off_1) or (tmp >= tmp_on_2 and tmp < tmp_off_2)) then
			state <= '1';
		else
			state <= '0';
		end if;
	
	elsif (wl_h >= 12 and wl_h <16 ) then
		tmp_on_2 := 60*to_integer(unsigned(wl_h)) + to_integer(unsigned(wl_m));
		tmp_off_2 := tmp_on_2 + 60*8; -- 8h po tmp_on_2 wy��cza si�
		tmp_on_1 := tmp_on_2 - 60*12; -- w��cza si� 12h wcze�niej ni� tmp_on_1
		tmp_off_1 := tmp_on_1 + 60*8; -- 8h po tmp_on_1 wy��cza si�
		if ((tmp >= tmp_on_1 and tmp < tmp_off_1) or (tmp >= tmp_on_2 and tmp < tmp_off_2)) then
			state <= '1';
		else
			state <= '0';
		end if;
	
	elsif (wl_h >= 4 and wl_h < 12) then
		tmp_on_1 := 60*to_integer(unsigned(wl_h)) + to_integer(unsigned(wl_m));
		tmp_off_1 := tmp_on_1 - 60*4; -- 4h przed tmp_on_1 wy��cza si�
		tmp_on_2 := tmp_on_1 + 60*12; -- w��cza si� 12h p�niej ni� tmp_on_1
		tmp_off_2 := tmp_on_2 - 60*4; -- 4h przed tmp_on_2 wy��cza si�
		if ((tmp < tmp_off_1) or (tmp >= tmp_on_1 and tmp < tmp_off_2) or (tmp >= tmp_on_2)) then
			state <= '1';
		else
			state <= '0';
		end if;
	
	elsif (wl_h >= 16) then
		tmp_on_2 := 60*to_integer(unsigned(wl_h)) + to_integer(unsigned(wl_m));
		tmp_off_2 := tmp_on_2 - 60*4; -- 4h przed tmp_on_2 wy��cza si�
		tmp_on_1 := tmp_on_2 - 60*12; -- w��cza si� 12h wcze�niej ni� tmp_on_2
		tmp_off_1 := tmp_on_1 - 60*4; -- 4h przed tmp_on_1 wy��cza si�
		if ((tmp < tmp_off_1) or (tmp >= tmp_on_1 and tmp < tmp_off_2) or (tmp >= tmp_on_2)) then
			state <= '1';
		else
			state <= '0';
		end if;

	end if;
end swiatlo;
--------------------------------------------------------------------------------------

-- Uk�ad -----------------------------------------------------------------------------
begin
	process (Clk)
		begin
		zegarek (Clk, time_h, time_m, time_s);
		grzalka (temperature, state_grzalka);
		swiatlo (time_h, time_m, light_h, light_m, state_swiatlo);
	end process;
end Behavioral;
--------------------------------------------------------------------------------------
