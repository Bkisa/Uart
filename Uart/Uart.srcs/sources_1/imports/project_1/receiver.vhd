library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity receiver is generic ( D : integer := 8;
                             M : integer    );
                      port ( clk, rst : in  std_logic;
                             rx_i     : in  std_logic; 
                             shift    : in std_logic;
                             data_received_o       : out std_logic_vector(D-1 downto 0); 
                             data_received_ready_o : out std_logic );
end receiver;

architecture Behavioral of receiver is

    component uart_rx    generic ( M : integer ;
                                   D : integer := 8 );
    
    port   (clk, rst   : in std_logic;
            rx_i       : in std_logic;
            data_o     : out std_logic_vector(D-1 downto 0);
            rx_ready_o : out std_logic );
    end component;
                 
type state_type is (idle, buffdata,checkzero,checkone, senddata, stop);
signal state      : state_type:=idle;                              
signal timertick  : std_logic; 
signal en         : std_logic;
signal rx_ready_o : std_logic;
signal rx_buff    : std_logic_vector(7 downto 0);
signal tmp_buff   : std_logic_vector(127 downto 0) := (others => '0');
signal cnt        : integer:=0;
 
begin
rx  : uart_rx generic map (M => M) 
              port map(clk=>clk, rst=>rst, rx_i=>rx_i, data_o=>rx_buff, rx_ready_o=>rx_ready_o );     
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(rst='1') then
                state<=idle;
                data_received_ready_o<='0';
                data_received_o<=(others=>'0');
            else
                data_received_ready_o <= '0';
            
            case state is
                when idle =>
                    if(rx_ready_o='1') then
                        if(rx_buff="00000000") then
                            state<=checkzero;
                            cnt<=0;
                        end if;
                    end if; 
                
                when checkzero =>
                    if(rx_ready_o='1') then
                        if rx_buff="00000000" then
                            state<=buffdata;
                        end if;     
                    end if;   
                
                when buffdata =>
                    if(rx_ready_o='1') then
                        tmp_buff<=rx_buff & tmp_buff(127 downto 8);
                        cnt<=cnt+1;
                            if(cnt=15) then
                                cnt<=0;
                                state<=checkone;
                            end if;
                    end if;
                
                when checkone =>
                    if(rx_ready_o='1') then
                        if rx_buff="11111111" then
                            cnt <= cnt + 1;
                                if (cnt = 1 ) then
                                    cnt <= 0;
                                    state<=senddata;
                                    tmp_buff<="00000000" & tmp_buff(127 downto 8);
                                    data_received_o<=tmp_buff(7 downto 0);
                                    data_received_ready_o <= '1';
                                end if; 
                        end if ;  
                    end if ;
                
                when senddata =>
                    if(shift='1') then
                        data_received_o<=tmp_buff(7 downto 0);
                        data_received_ready_o <= '1';
                        tmp_buff<="00000000" & tmp_buff(127 downto 8);
                        cnt<=cnt+1;
                            if(cnt=15) then
                                state<=stop;
                            end if;
                    end if;    
                
                when stop =>
                    data_received_ready_o <= '0';
                    state <= idle;
                    cnt <= 0;            
            end case;        
            end if;
        end if;        
    end process;    

end Behavioral;
