----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2023 16:31:15
-- Design Name: 
-- Module Name: TopModuleTb - Behavioral
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
use STD.textio.all;
use ieee.std_logic_textio.all;

entity TopModuleTb_VHDL is
--  Port ( );
end TopModuleTb_VHDL;

architecture Behavioral of TopModuleTb_VHDL is
    
    component TopModule is
        port(
            Clk : in std_logic;
            SRst : in std_logic;
            Start : in std_logic;
            ModulationOrder : in std_logic_vector(2 downto 0);
            
            QAMModDataOutValid : out std_logic;
            QAMFrameBeginnigIndicator : out std_logic;
            QAMFrameNum : out std_logic_vector(7 downto 0);
            QAMDataNum : out std_logic_vector(7 downto 0);
            QAMModDataOutRe : out std_logic_vector(11 downto 0);
            QAMModDataOutIm : out std_logic_vector(11 downto 0);
            
            OTFSTxDataValid : out std_logic;
            OTFSTxDataRe : out std_logic_vector(15 downto 0);
            OTFSTxDataIm : out std_logic_vector(15 downto 0);
            
            OTFSRxDemodValid : out std_logic;
            OTFSRxDemodRe : out std_logic_vector(23 downto 0);
            OTFSRxDemodIm : out std_logic_vector(23 downto 0);
            
            
            QAMDemodDataValid : out std_logic;
            QAMDemodData : out std_logic_vector(4 downto 0)
            
        );
    end component;
    
    Signal Clk : std_logic := '1';
    Signal SRst : std_logic := '0';
    Signal Start : std_logic := '0';
    Signal ModulationOrder : std_logic_vector(2 downto 0) := "000";
    Signal ModDataOutValid : std_logic;
    Signal FrameBeginnigIndicator : std_logic;
    Signal FrameNum : std_logic_vector(7 downto 0);
    Signal DataNum : std_logic_vector(7 downto 0);
    Signal ModDataOutRe : std_logic_vector(11 downto 0);
    Signal ModDataOutIm : std_logic_vector(11 downto 0);
    Signal OTFSDataValid : std_logic;
    Signal OTFSDataRe : std_logic_vector(15 downto 0);
    Signal OTFSDataIm : std_logic_vector(15 downto 0);
    Signal QAMDemodDataValid : std_logic;
    Signal QAMDemodData : std_logic_vector(4 downto 0);
    Signal OTFSRxDemodValid : std_logic;
    Signal OTFSRxDemodRe : std_logic_vector(23 downto 0);
    Signal OTFSRxDemodIm : std_logic_vector(23 downto 0);
    
    file OTFSDemodLogFile : text IS "OTFSDemodResult.txt";
    
begin
    
    DUT : TopModule
    port map(
        Clk => Clk,
        SRst => SRst,
        Start => Start,
        ModulationOrder => ModulationOrder,
        
        QAMModDataOutValid => ModDataOutValid,
        QAMFrameBeginnigIndicator => FrameBeginnigIndicator,
        QAMFrameNum => FrameNum,
        QAMDataNum => DataNum,
        QAMModDataOutRe => ModDataOutRe,
        QAMModDataOutIm => ModDataOutIm,
 
        OTFSTxDataValid => OTFSDataValid,
        OTFSTxDataRe => OTFSDataRe,
        OTFSTxDataIm => OTFSDataIm,
        
        OTFSRxDemodValid => OTFSRxDemodValid,
        OTFSRxDemodRe => OTFSRxDemodRe,
        OTFSRxDemodIm => OTFSRxDemodIm,
        
        QAMDemodDataValid => QAMDemodDataValid,
        QAMDemodData => QAMDemodData
    );

    Clk_Process:
    process
    begin
        Clk <= not Clk;
        wait for 5 ns;
    end process;
    
    Stimuli_Process:
    process
    begin
        SRst <= '1';
        wait for 100 ns;
        SRst <= '0';
        wait for 100 ns;
        Start <= '1';
        ModulationOrder <= "011";
        wait for 10 ns;
        Start <= '0';
        ModulationOrder <= "000";
        wait;
    end process;
    
    file_open(OTFSDemodLogFile, "OTFSDemodResult.txt",  write_mode);
    ModDataLogProcess:
    process(Clk)
        variable L : line;
    begin
        if rising_edge(Clk) then
            if (OTFSRxDemodValid = '1') then
                write(L, to_integer(signed(OTFSRxDemodRe)), right, 8);
                write(L, to_integer(signed(OTFSRxDemodIm)), right, 8);
                writeline(OTFSDemodLogFile, L);
            end if;
        end if;
    end process;

end Behavioral;
