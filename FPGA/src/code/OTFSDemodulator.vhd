----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2023 14:50:19
-- Design Name: 
-- Module Name: OTFSDemodulator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity OTFSDemodulator is
    port(
        Clk : in std_logic;
        Srst : in std_logic;
        Start : in std_logic;
        
        RecSigDataValid : in std_logic;
        RecSigRe : in std_logic_vector(15 downto 0);
        RecSigIm : in std_logic_vector(15 downto 0);
        
        OTFSRxDemodValid : out std_logic;
        OTFSRxDemodRe : out std_logic_vector(23 downto 0);
        OTFSRxDemodIm : out std_logic_vector(23 downto 0)
    );
end OTFSDemodulator;

architecture Behavioral of OTFSDemodulator is
    
    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        clkb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;

    COMPONENT xfft_0
      PORT (
        aclk : IN STD_LOGIC;
        s_axis_config_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        s_axis_config_tvalid : IN STD_LOGIC;
        s_axis_config_tready : OUT STD_LOGIC;
        s_axis_data_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_data_tvalid : IN STD_LOGIC;
        s_axis_data_tready : OUT STD_LOGIC;
        s_axis_data_tlast : IN STD_LOGIC;
        m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
        m_axis_data_tvalid : OUT STD_LOGIC;
        m_axis_data_tready : IN STD_LOGIC;
        m_axis_data_tlast : OUT STD_LOGIC;
        event_frame_started : OUT STD_LOGIC;
        event_tlast_unexpected : OUT STD_LOGIC;
        event_tlast_missing : OUT STD_LOGIC;
        event_status_channel_halt : OUT STD_LOGIC;
        event_data_in_channel_halt : OUT STD_LOGIC;
        event_data_out_channel_halt : OUT STD_LOGIC
      );
    END COMPONENT;
    
    type StateType is (IDLE, RECORD_SIGNAL, FEED_FFT_DATA_0, FEED_FFT_DATA_1, FEED_FFT_DATA_2, FEED_FFT_DATA_3, FEED_FFT_DATA_4);
    signal State : StateType := IDLE;
    
    signal s_axis_config_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
    signal s_axis_config_tvalid : STD_LOGIC := '0';
    signal s_axis_config_tready : STD_LOGIC;
    signal s_axis_data_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal s_axis_data_tvalid : STD_LOGIC := '0';
    signal s_axis_data_tready : STD_LOGIC;
    signal s_axis_data_tlast : STD_LOGIC := '0';
    signal m_axis_data_tdata : STD_LOGIC_VECTOR(47 DOWNTO 0);
    signal m_axis_data_tvalid : STD_LOGIC;
    signal m_axis_data_tready : STD_LOGIC := '1';
    signal m_axis_data_tlast : STD_LOGIC;
    signal event_frame_started : STD_LOGIC;
    signal event_tlast_unexpected : STD_LOGIC;
    signal event_tlast_missing : STD_LOGIC;
    signal event_status_channel_halt : STD_LOGIC;
    signal event_data_in_channel_halt : STD_LOGIC;
    signal event_data_out_channel_halt : STD_LOGIC;
    
    signal wea : std_logic_vector(0 downto 0) := "0" ;
    signal addra : std_logic_vector(11 downto 0) := (others => '0');
    signal dina : std_logic_vector(31 downto 0) := (others => '0');
    signal addrb : std_logic_vector(11 downto 0) := (others => '0');
    signal doutb : std_logic_vector(31 downto 0);
    
    signal FFTDataCount : integer := 0;
    
begin
    
    bram_inst : blk_mem_gen_0
    PORT MAP (
        clka => Clk,
        wea => wea,
        addra => addra,
        dina => dina,
        clkb => Clk,
        addrb => addrb,
        doutb => doutb
    );
    
    fft_inst : xfft_0
      PORT MAP (
        aclk => Clk,
        s_axis_config_tdata => s_axis_config_tdata,
        s_axis_config_tvalid => s_axis_config_tvalid,
        s_axis_config_tready => s_axis_config_tready,
        s_axis_data_tdata => s_axis_data_tdata,
        s_axis_data_tvalid => s_axis_data_tvalid,
        s_axis_data_tready => s_axis_data_tready,
        s_axis_data_tlast => s_axis_data_tlast,
        m_axis_data_tdata => m_axis_data_tdata,
        m_axis_data_tvalid => m_axis_data_tvalid,
        m_axis_data_tready => m_axis_data_tready,
        m_axis_data_tlast => m_axis_data_tlast,
        event_frame_started => event_frame_started,
        event_tlast_unexpected => event_tlast_unexpected,
        event_tlast_missing => event_tlast_missing,
        event_status_channel_halt => event_status_channel_halt,
        event_data_in_channel_halt => event_data_in_channel_halt,
        event_data_out_channel_halt => event_data_out_channel_halt
      );
    
    OTFSRxDemodValid <= m_axis_data_tvalid;
    OTFSRxDemodRe <= m_axis_data_tdata(23 downto 0);
    OTFSRxDemodIm <= m_axis_data_tdata(47 downto 24);
    process(Clk)
    begin
        if rising_edge(Clk) then
            s_axis_data_tvalid <= '0';
            s_axis_data_tlast <= '0';
            s_axis_data_tdata <= (others => '0');
            wea <= "0";
            case(State) is
                when IDLE => 
                    State <= IDLE;
                    addra <= (others => '1');
                    if(Start = '1') then
                        State <= RECORD_SIGNAL;
                    end if;
                    
                when RECORD_SIGNAL => 
                    State <= RECORD_SIGNAL;
                    addrb <= (others => '0');
                    if(RecSigDataValid = '1') then
                        wea <= "1";
                        dina <= RecSigIm & RecSigRe;
                        addra <= std_logic_vector(unsigned(addra) + 1);
                        if (unsigned(addra) = 4094) then
                            State <= FEED_FFT_DATA_0;
                        end if;
                    end if;   
                    
                when FEED_FFT_DATA_0 =>
                    State <= FEED_FFT_DATA_1;
                    addrb <= std_logic_vector(to_unsigned(64,12));
                    
                when FEED_FFT_DATA_1 =>
                    State <= FEED_FFT_DATA_2;
                    addrb <= std_logic_vector(to_unsigned(128,12));
                    FFTDataCount <= 0;
                    
                when FEED_FFT_DATA_2 =>
                    State <= FEED_FFT_DATA_2;
                    s_axis_data_tvalid <= '1';
                    s_axis_data_tdata <= std_logic_vector(resize(signed(doutb(29 downto 18)),16)) & std_logic_vector(resize(signed(doutb(13 downto 2)),16));
                    FFTDataCount <= FFTDataCount + 1;
                    if (FFTDataCount = 63) then
                        FFTDataCount <= 0;
                        s_axis_data_tlast <= '1';
                    end if;
                    addrb <= std_logic_vector(unsigned(addrb) + 64);
                    if (addrb(11 downto 6) = "111111") then
                        addrb(11 downto 6) <= (others => '0');
                        addrb(5 downto 0) <= std_logic_vector(unsigned(addrb(5 downto 0)) + 1);
                        if (addrb(5 downto 0) = "111111") then
                            State <= FEED_FFT_DATA_3;
                        end if;
                    end if;
                
                when FEED_FFT_DATA_3 =>
                    State <= FEED_FFT_DATA_4;
                    s_axis_data_tvalid <= '1';
                    s_axis_data_tdata <= std_logic_vector(resize(signed(doutb(29 downto 18)),16)) & std_logic_vector(resize(signed(doutb(13 downto 2)),16));
                    
                when FEED_FFT_DATA_4 =>
                    State <= IDLE;
                    s_axis_data_tlast <= '1';
                    s_axis_data_tvalid <= '1';
                    s_axis_data_tdata <= std_logic_vector(resize(signed(doutb(29 downto 18)),16)) & std_logic_vector(resize(signed(doutb(13 downto 2)),16));
                    
                when others => 
                    State <= IDLE;
            end case;
        end if;
    end process;
    

end Behavioral;
