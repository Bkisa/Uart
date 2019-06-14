library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is

    generic ( M : integer := 100 );
    port    ( clk, rst, en : in std_logic;
                      done : out std_logic );

end timer;

architecture Behavioral of timer is

signal counter : unsigned(31 downto 0) := (others => '0');

begin
    process (clk) is
        begin
            if rising_edge (clk) then
                if rst = '1' then
                    counter <= to_unsigned(M-1, 32);
                elsif en = '1' then
                    done <= '0';
                    if counter = 0 then
                        done <= '1';
                        counter <= to_unsigned(M-1, 32);
                    else
                        counter <= counter - 1;
                    end if;
                end if;
            end if;
    end process;
    
end Behavioral;