function runHWTests(board)

import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.parameters.Parameter
import matlab.unittest.plugins.ToUniqueFile;
import matlab.unittest.plugins.TAPPlugin;
import matlab.unittest.constraints.ContainsSubstring;
import matlab.unittest.selectors.HasName;
import matlab.unittest.selectors.HasProcedureName;
import matlab.unittest.plugins.DiagnosticsValidationPlugin

at = {'AD9361Tests','AD9363Tests','AD9364Tests'...
        'AD9371Tests','ADRV9009Tests','DAQ2Tests'};

    
if nargin == 0
    suite = testsuite(at);
else
    try
        switch board
            case "pluto"
                board = 'Pluto';
            case {"zynq-adrv9361-z7035-bob-cmos", ...
                    "socfpga_cyclone5_sockit_arradio", ...
                    "zynq-zed-adv7511-ad9361-fmcomms2-3", ...
                    "zynq-zc702-adv7511-ad9361-fmcomms2-3", ...
                    "zynq-zc706-adv7511-ad9361-fmcomms2-3", ...
                    "zynqmp-zcu102-rev10-ad9361-fmcomms2-3", ...
                    "zynq-adrv9361-z7035-fmc", ...
                    "zynq-adrv9361-z7035-box", ...
                    "zynq-adrv9361-z7035-bob", ...
                    "zync-zed-adv7511-ad9361-fmcomms5"}
                board = 'AD9361';
            case {"zynq-zc702-adv7511-ad9364-fmcomms4", ...
                    "zynq-zc706-adv7511-ad9364-fmcomms4", ...
                    "zynqmp-zcu102-rev10-ad9364-fmcomms4", ...
                    "zynq-adrv9364-z7020-box", ...
                    "zynq-adrv9364-z7020-bob", ...
                    "zynq-adrv9364-z7020-bob-cmos", ...
                    "zynq-zed-adv7511-ad9364-fmcomms4"}
                board = 'AD9364';
            case {"zynqmp-zcu102-rev10-adrv9002", ...
                    "zynq-zed-adv7511-adrv9002", ...
                    "zynq-zed-adv7511-adrv9002-vcmos", ...
                    "zynqmp-zcu102-rev10-adrv9002-vcmos"}
                board = {'ADRV9002'};
            case {"zynq-zc706-adv7511-fmcdaq2"}
                board = 'DAQ2';
        end
    end
    
    boards = lower(board);
    suite = testsuite(at);
    suite = selectIf(suite,HasProcedureName(ContainsSubstring(boards,'IgnoringCase',true)));
end

try
    
    runner = matlab.unittest.TestRunner.withTextOutput('OutputDetail',1);
%     runner.addPlugin(DiagnosticsValidationPlugin)
    xmlFile = 'HWTestResults.xml';
    plugin = XMLPlugin.producingJUnitFormat(xmlFile);
    
    runner.addPlugin(plugin);
    results = runner.run(suite);
    
    t = table(results);
    disp(t);
    disp(repmat('#',1,80));
    for test = results
        if test.Failed
            disp(test.Name);
        end
    end
catch e
    disp(getReport(e,'extended'));
    bdclose('all');
    exit(1);
end
% save(['BSPTest_',datestr(now,'dd_mm_yyyy-HH:MM:SS'),'.mat'],'t');
% bdclose('all');
exit(any([results.Failed]));
