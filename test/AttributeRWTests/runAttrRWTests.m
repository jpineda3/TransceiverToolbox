function results = runAttrRWTests(BoardName)
    import matlab.unittest.parameters.Parameter
    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.XMLPlugin

    if nargin == 0
        error('BoardName cannot be empty to run Attribute Read Write tests');
    end
    
    switch BoardName
        case "pluto"
            device = {'Pluto'};
        case {"zynq-adrv9361-z7035-bob-cmos", ...
                "socfpga_cyclone5_sockit_arradio", ...
                "zynq-zed-adv7511-ad9361-fmcomms2-3", ...
                "zynq-zc702-adv7511-ad9361-fmcomms2-3", ...
                "zynq-zc706-adv7511-ad9361-fmcomms2-3", ...
                "zynqmp-zcu102-rev10-ad9361-fmcomms2-3", ...
                "zynq-adrv9361-z7035-fmc", ...
                "zynq-adrv9361-z7035-box", ...
                "zynq-adrv9361-z7035-bob"}
            device = {'AD9361'};
        case {"zynq-zc702-adv7511-ad9364-fmcomms4", ...
                "zynq-zc706-adv7511-ad9364-fmcomms4", ...
                "zynqmp-zcu102-rev10-ad9364-fmcomms4", ...
                "zynq-adrv9364-z7020-box", ...
                "zynq-adrv9364-z7020-bob", ...
                "zynq-adrv9364-z7020-bob-cmos", ...
                "zynq-zed-adv7511-ad9364-fmcomms4"}
            device = {'AD9364'};
        otherwise
            error('%s unsupported for Attribute Read Write tests', BoardName);
    end
    
    % run parameterized attribute read-write tests
    switch device{1}
        case 'AD9361'
            suite = TestSuite.fromClass(?AD9361Tests, 'ProcedureName', 'testAD9391AttributeSingleValue');
        case strcmp(device,'ADRV9009')
            suite = TestSuite.fromClass(?ADRV9009Tests, 'ProcedureName', 'testADRV9009AttributeSingleValue');
    end

    xmlFile = 'AttrRWTestResults.xml';
    disp(pwd);
    runner = TestRunner.withTextOutput('LoggingLevel',4);
    % runner.addPlugin(details_recording_plugin);
    plugin = XMLPlugin.producingJUnitFormat(xmlFile);
    runner.addPlugin(plugin);
    results = runner.run(suite);

    % try
    %     log_lte_evm_test(results);
    % catch
    %     warning('telemetry not found');
    % end
    
    % if ~usejava('desktop')
    %     exit(any([results.Failed]));
    % end
end