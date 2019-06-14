library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity uart_rx is
    generic ( M : integer ;
              D : integer := 8 );

    port    ( clk, rst: in std_logic;
              rx_i     : in std_logic;
              data_o   : out std_logic_vector(D-1 downto 0);
              rx_ready_o : out std_logic );
           
end uart_rx;

architecture Behavioral of uart_rx is

    component timer is
        generic ( M : integer:=100 );
        port    ( clk, rst, en : in std_logic;
                          done : out std_logic );
    end component;

    type state_type is (idle, start, data, stop);
    signal state     : state_type := idle;
    signal bit_count : integer := 0;
    signal buff      : std_logic_vector(D-1 downto 0):=(others=>'0');
    signal en, done0, txo : std_logic ;

begin
    tim : timer generic map ( M => M/2 )
                port map    ( clk => clk, rst => rst, en => en, done => done0 );
                
process (clk) is
    begin
        if rising_edge (clk) then
            if rst = '1' then
                state <= idle;
                rx_ready_o <= '0';
                bit_count <= 0;
                data_o <= (others=>'0');
                en <= '0';
            else
                en <= '1';
                rx_ready_o <= '0';
                
                case state is
                
                    when idle =>
                        en <= '0';
                        if rx_i = '0' then
                            state <= start;
                            en <= '1';
                            bit_count <= 0;
                        end if; 
                         
                    when start =>
                        if(done0 = '1') then
                            state <= data;                              
                        end if;
                        
                    when data =>
                        if bit_count = 2*D+1 then
                            state <= stop;
                            bit_count <= 0;
                        else
                        if done0 = '1' then
                            bit_count <= bit_count + 1; 
                            if(bit_count mod 2 = 1) then
                                buff<= rx_i & buff(D-1 downto 1);  
                            end if;     
                        end if;
                        end if;
                        
                    when stop =>
                        if done0 = '1' then
                            rx_ready_o <= '1';
                            en <= '0';
                            data_o<=buff;
                            state <= idle;
                            bit_count <= 0;
                        end if;
                    
                end case;
            end if;
        end if;
end process;
     
end Behavioral;