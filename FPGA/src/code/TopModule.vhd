----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2023 14:02:40
-- Design Name: 
-- Module Name: TopModule - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TopModule is
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
end TopModule;

architecture Behavioral of TopModule is
    
    component RandomBitGenerator is
        port(
            Clk : in std_logic;
            SRst : in std_logic;
            Start : in std_logic;
            ModulationOrder : in std_logic_vector(2 downto 0);
            RandomBitValid : out std_logic;
            RandomBit : out std_logic
        );
    end component;

    component OTFSTx is
        port(
            Clk : in std_logic;
            SRst : in std_logic;
            Start : in std_logic;
            
            DataValid : in std_logic;
            DataIn : in std_logic;
            
            ModDataOutValid : out std_logic;
            FrameBeginnigIndicator : out std_logic;
            FrameNum : out std_logic_vector(7 downto 0);
            DataNum : out std_logic_vector(7 downto 0);
            ModDataOutRe : out std_logic_vector(11 downto 0);
            ModDataOutIm : out std_logic_vector(11 downto 0);
            
            OTFSTxDataValid : out std_logic;
            OTFSTxDataRe : out std_logic_vector(15 downto 0);
            OTFSTxDataIm : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component OTFSRx is
        port(
            Clk : in std_logic;
            Srst : in std_logic;
            Start : in std_logic;
            
            RecSigDataValid : in std_logic;
            RecSigRe : in std_logic_vector(15 downto 0);
            RecSigIm : in std_logic_vector(15 downto 0);
            
            OTFSRxDemodValid : out std_logic;
            OTFSRxDemodRe : out std_logic_vector(23 downto 0);
            OTFSRxDemodIm : out std_logic_vector(23 downto 0);
            
            QAMDemodDataValid : out std_logic;
            QAMDemodData : out std_logic_vector(4 downto 0)
        );
    end component;
    
    signal RandomBitValid : std_logic;
    signal RandomBit : std_logic;
    
    signal ModDataOutValidReg : std_logic;
    signal FrameBeginnigIndicatorReg : std_logic;
    signal FrameNumReg : std_logic_vector(7 downto 0);
    signal DataNumReg : std_logic_vector(7 downto 0);
    signal ModDataOutReReg : std_logic_vector(11 downto 0);
    signal ModDataOutImReg : std_logic_vector(11 downto 0);
    signal OTFSDataValidReg : std_logic;
    signal OTFSDataReReg : std_logic_vector(15 downto 0);
    signal OTFSDataImReg : std_logic_vector(15 downto 0);
    
begin
    
    U0 : RandomBitGenerator
        port map(
            Clk => Clk,
            SRst => SRst,
            Start => Start,
            ModulationOrder => ModulationOrder,
            RandomBitValid => RandomBitValid,
            RandomBit => RandomBit
        );
    
    QAMModDataOutValid <= ModDataOutValidReg;
    QAMFrameBeginnigIndicator <= FrameBeginnigIndicatorReg;
    QAMFrameNum <= FrameNumReg;
    QAMDataNum <= DataNumReg;
    QAMModDataOutRe <= ModDataOutReReg;
    QAMModDataOutIm <= ModDataOutImReg;
    
    OTFSTxDataValid <= OTFSDataValidReg;
    OTFSTxDataRe <= OTFSDataReReg;
    OTFSTxDataIm <= OTFSDataImReg;     
    U1 : OTFSTx
        port map(
            Clk => Clk,
            SRst => SRst,
            Start => Start,
            
            DataValid => RandomBitValid,
            DataIn => RandomBit,
            
            ModDataOutValid => ModDataOutValidReg,
            FrameBeginnigIndicator => FrameBeginnigIndicatorReg,
            FrameNum => FrameNumReg,
            DataNum => DataNumReg,
            ModDataOutRe => ModDataOutReReg,
            ModDataOutIm => ModDataOutImReg,
            
            OTFSTxDataValid => OTFSDataValidReg,
            OTFSTxDataRe => OTFSDataReReg,
            OTFSTxDataIm => OTFSDataImReg
        );
        
    U2 : OTFSRx
        port map(
            Clk => Clk,
            Srst => Srst,
            Start => Start,
            
            RecSigDataValid => OTFSDataValidReg,
            RecSigRe => OTFSDataReReg,
            RecSigIm => OTFSDataImReg,
            
            OTFSRxDemodValid => OTFSRxDemodValid,
            OTFSRxDemodRe => OTFSRxDemodRe,
            OTFSRxDemodIm => OTFSRxDemodIm,
            
            QAMDemodDataValid => QAMDemodDataValid,
            QAMDemodData => QAMDemodData
        );
         
end Behavioral;
