----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2023 14:03:03
-- Design Name: 
-- Module Name: OTFSTx - Behavioral
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

entity OTFSTx is
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
end OTFSTx;

architecture Behavioral of OTFSTx is
    
    component QAMModulator_32QAM is
        port(
            Clk : in std_logic;
            SRst : in std_logic;
            Start : in std_logic;
            DataValidIn : in std_logic;
            Data : in std_logic;
            ModDataOutValid : out std_logic;
            FrameBeginnigIndicator : out std_logic;
            FrameNum : out std_logic_vector(7 downto 0);
            DataNum : out std_logic_vector(7 downto 0);
            ModDataOutRe : out std_logic_vector(11 downto 0);
            ModDataOutIm : out std_logic_vector(11 downto 0)
        );
    end component;
    
        component OTFSModulator is
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
    end component;
    
    signal ModDataOutReReg : std_logic_vector(11 downto 0);
    signal ModDataOutImReg : std_logic_vector(11 downto 0);
    signal ModDataOutValidReg : std_logic;
    
begin
    
    ModDataOutRe <= ModDataOutReReg;
    ModDataOutIm <= ModDataOutImReg;
    ModDataOutValid <= ModDataOutValidReg;    
    U1 : QAMModulator_32QAM
        port map(
            Clk => Clk,
            SRst => SRst,
            Start => Start,
            DataValidIn => DataValid,
            Data => DataIn,
            ModDataOutValid => ModDataOutValidReg,
            FrameBeginnigIndicator => FrameBeginnigIndicator,
            FrameNum => FrameNum,
            DataNum => DataNum,
            ModDataOutRe => ModDataOutReReg,
            ModDataOutIm => ModDataOutImReg
        );
               
    U2 : OTFSModulator
        port map(
            Clk => Clk,
            Srst => SRst,
            
            Start => Start,
            QAMDataValid => ModDataOutValidReg,
            QAMDataRe => ModDataOutReReg,
            QAMDataIm => ModDataOutImReg,
            
            OTFSTxDataValid => OTFSTxDataValid,
            OTFSTxDataRe => OTFSTxDataRe,
            OTFSTxDataIm => OTFSTxDataIm
        );

end Behavioral;
