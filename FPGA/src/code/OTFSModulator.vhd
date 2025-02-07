----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.03.2023 11:20:45
-- Design Name: 
-- Module Name: OTFS - Behavioral
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

entity OTFSModulator is
    port(
        Clk : in std_logic;
        Srst : in std_logic;
        
        Start : in std_logic;
        QAMDataValid : in std_logic;
        QAMDataRe : in std_logic_vector(11 downto 0);
        QAMDataIm : in std_logic_vector(11 downto 0);
        
        OTFSTxDataValid : out std_logic;
        OTFSTxDataRe : out std_logic_vector(15 downto 0);
        OTFSTxDataIm : out std_logic_vector(15 downto 0)
    );
end OTFSModulator;

architecture Behavioral of OTFSModulator is
    
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
    
    type StateType is (IDLE, FEED_FFT_DATA);
    signal State : StateType := IDLE;
    
    type StateType2 is (IDLE, RECORD_IFFT_DATA, OUTPUT_OTFS_DATA_0, OUTPUT_OTFS_DATA_1, OUTPUT_OTFS_DATA_2, OUTPUT_OTFS_DATA_3, OUTPUT_OTFS_DATA_4);
    signal RecState : StateType2 := IDLE;
    
    signal wea : std_logic_vector(0 downto 0) := "0" ;
    signal addra : std_logic_vector(11 downto 0) := (others => '0');
    signal dina : std_logic_vector(31 downto 0) := (others => '0');
    signal addrb : std_logic_vector(11 downto 0) := (others => '0');
    signal doutb : std_logic_vector(31 downto 0);
    
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
    
    signal DataCount : std_logic_vector(15 downto 0);
    
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
      
    process(Clk) begin
        if rising_edge(Clk) then
            s_axis_data_tvalid <= '0';
            s_axis_data_tlast <= '0';
            s_axis_data_tdata <= (others => '0');
            s_axis_config_tdata <= (others => '0'); 
            s_axis_config_tvalid <= '0';
            if(Srst = '1') then
                State <= IDLE;
            else
                case(State) is
                    when IDLE =>
                        State <= IDLE;
                        DataCount <= (others => '0');
                        if(Start = '1') then
                            State <= FEED_FFT_DATA;
                            s_axis_config_tdata <= (others => '0'); -- ifft
                            s_axis_config_tvalid <= '1';
                        end if; 
                         
                    when FEED_FFT_DATA =>
                        state <= FEED_FFT_DATA;
                        if(QAMDataValid = '1') then
                            s_axis_data_tvalid <= '1';
                            s_axis_data_tdata <= std_logic_vector(resize(signed(QAMDataIm),16)) & std_logic_vector(resize(signed(QAMDataRe),16));
                            DataCount <= std_logic_vector(unsigned(DataCount) + 1);
                            if (DataCount(5 downto 0) = "111111") then
                                s_axis_data_tlast <= '1';
                            end if;
                            if (unsigned(DataCount) = 4095) then
                                State <= IDLE;
                            end if; 
                        end if;
                        
                    when others =>
                        State <= IDLE; 
                end case;
            end if;
        end if;
    end process;
    
    process(Clk)
    begin
        if rising_edge(Clk) then
            OTFSTxDataValid <= '0';
            OTFSTxDataRe <= (others => '0');
            OTFSTxDataIm <= (others => '0');
            wea <= "0";
            dina <= (others => '0');
            case(RecState) is
                when IDLE =>
                    RecState <= IDLE;
                    addra <= (others => '1');
                    if(Start = '1') then
                        RecState <= RECORD_IFFT_DATA;
                    end if;
                     
                when RECORD_IFFT_DATA =>
                    RecState <= RECORD_IFFT_DATA;
                    addrb <= (others => '0');
                    if(m_axis_data_tvalid = '1') then
                        wea <= "1";
                        dina <= m_axis_data_tdata(42 downto 27) & m_axis_data_tdata(18 downto 3);
                        addra <= std_logic_vector(unsigned(addra) + 1);
                        if (unsigned(addra) = 4094) then
                            RecState <= OUTPUT_OTFS_DATA_0;
                        end if;
                    end if;   
                      
                when OUTPUT_OTFS_DATA_0 => 
                    RecState <= OUTPUT_OTFS_DATA_1;
                    addrb <= std_logic_vector(to_unsigned(64,12));
                    
                when OUTPUT_OTFS_DATA_1 =>
                    RecState <= OUTPUT_OTFS_DATA_2;
                    addrb <= std_logic_vector(to_unsigned(128,12));
                     
                when OUTPUT_OTFS_DATA_2 => 
                    RecState <= OUTPUT_OTFS_DATA_2;
                    OTFSTxDataValid <= '1';
                    OTFSTxDataRe <= doutb(15 downto 0);
                    OTFSTxDataIm <= doutb(31 downto 16);
                    addrb <= std_logic_vector(unsigned(addrb) + 64);
                    if (addrb(11 downto 6) = "111111") then
                        addrb(11 downto 6) <= (others => '0');
                        addrb(5 downto 0) <= std_logic_vector(unsigned(addrb(5 downto 0)) + 1);
                        if (addrb(5 downto 0) = "111111") then
                            RecState <= OUTPUT_OTFS_DATA_3;
                        end if;
                    end if;
                    
                when OUTPUT_OTFS_DATA_3 =>
                    RecState <= OUTPUT_OTFS_DATA_4;
                    OTFSTxDataValid <= '1';
                    OTFSTxDataRe <= doutb(15 downto 0);
                    OTFSTxDataIm <= doutb(31 downto 16);
                    
                when OUTPUT_OTFS_DATA_4 => 
                    RecState <= IDLE;
                    OTFSTxDataValid <= '1';
                    OTFSTxDataRe <= doutb(15 downto 0);
                    OTFSTxDataIm <= doutb(31 downto 16);
                    
            end case;
        end if;
    end process;

end Behavioral;
