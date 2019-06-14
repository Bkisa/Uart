library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic ( D : integer:=8 ; 
              M : integer   );
    port    ( clk, rst  : in  std_logic;
              start_i   : in  std_logic; 
              data_i    : in  std_logic_vector(D-1 downto 0);
              tx_o      : out std_logic; 
              tx_done_o : out std_logic );
end uart_tx;

architecture rtl of uart_tx is

    component timer is
        generic ( M : integer := 100 );
        port    ( clk,rst,en : in std_logic;
                  done       : out std_logic);
    end component;

    type   signal_type is (idle,start,data,stop);
    signal state : signal_type := idle;
    signal bit_count : integer :=0;
    signal done      : std_logic;
    signal en        : std_logic := '1';

begin

    tx1 : timer generic map ( M => M )
                port map    ( clk=>clk, rst => rst, en => en, done=>done );


transmitter : process(clk)

    begin
    if rising_edge(clk) then
        if rst = '1' then
            state     <= idle;
            tx_done_o <= '0';
            tx_o      <= '1';
            bit_count <=  0;
        else
            state     <= idle;
            tx_done_o <= '0';
            en<='1';
            tx_o      <= '1';
            
        case state is
            when idle =>
                en<='0';
                if start_i = '1' then        
                    en <= '1';
                    state <= start;
                    tx_o <= '0';
                else
                    state <= idle;
                end if;
            
            when start =>
                tx_o <= '0';
                if done = '1' then
                    state<=data;
                else
                    state <= start;
                end if;
            
            
            when data =>
                tx_o <= data_i(bit_count);
                    if done = '1' then             
                        bit_count <= bit_count + 1;
                        if bit_count = 7 then
                            state <= stop;
                            bit_count <= 0;
                        else      
                            state <= data;              
                        end if;
                    else
                        state <= data;
                    end if;
            
            when stop =>
                tx_o <= '1';
                    if done = '1' then               
                        tx_done_o <= '1';
                        state <= idle;
                        bit_count <= 0;
                        en <= '0';
                    else
                        state <= stop;
                    end if;
            
            when others =>
                state <= idle;
                
            end case;
        end if;
    end if;
end process;

end rtl ;
