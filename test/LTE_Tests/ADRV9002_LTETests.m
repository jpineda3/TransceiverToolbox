classdef ADRV9002_LTETests < LTETests
    properties (TestParameter)
        LOFreqs = {2400e6};
    end
    
    properties
        uri = 'ip:analog';
        author = 'ADI';
    end
    
    properties (Access = protected)
        Tx
        Rx
    end
    
    properties
        DeviceName
        LOFreq
        TMN
        BW
    end
    
    properties (Constant)
        filters_dir = 'adrv9002_profiles';
    end
    
    properties % demodulation-related
        TestSettings = ...
            struct(...
            'TxGain', -10,...
            'Backoff', -3, ...
            'RxGainMode', 'automatic')
    end
    
    properties (ClassSetupParameter)
        Device = {'ADRV9002'};
    end
    
    methods (TestClassSetup)
        function CheckForHardware(testCase, Device)
            if isempty(getenv('IIO_URI')) && strcmp(Device, 'Pluto')
                testCase.uri = 'ip:pluto';
            end
            % check tx
            dev = @()adi.(genvarname(Device)).Tx;
            testCase.CheckDevice('ip', dev, testCase.uri(4:end), true);
            % check rx
            dev = @()adi.(genvarname(Device)).Rx;
            testCase.CheckDevice('ip', dev, testCase.uri(4:end), false);
            
            testCase.DeviceName = Device;
        end
    end
    
    methods(Access = protected)
        function ConfigHW(testCase)
            disp('at ADR9002_LTETests, ConfigHW')
            % tx setup
            testCase.Tx = adi.(genvarname(testCase.DeviceName)).Tx;
            testCase.Tx.CenterFrequencyChannel0 = testCase.LOFreq;
            testCase.Tx.AttenuationChannel0 = testCase.TestSettings.TxGain;
            testCase.Tx.EnableCyclicBuffers = true;
            testCase.Tx.EnableCustomProfile = true;
            testCase.Tx.uri = testCase.uri;
            % testCase.Tx(1)
            % disp(properties(testCase.Tx))
            
            % rx setup
            testCase.Rx = adi.(genvarname(testCase.DeviceName)).Rx;
            testCase.Rx.uri = testCase.uri;
            testCase.Rx.CenterFrequencyChannel0 = testCase.LOFreq;
            testCase.Rx.EnableCustomProfile = true;
            % disp(testCase.TestSettings.RxGainMode)
            % testCase.Rx.GainControllerSourceChannel0 = ...
                % testCase.TestSettings.RxGainMode;
            testCase.Rx.kernelBuffersCount = 1;
            testCase.Rx.SamplesPerFrame = ...
                testCase.setRxSamplesPerFrame(testCase.BW);

            % configure custom filter settings
            disp(fullfile(testCase.root, testCase.filters_dir, 'LTE5_MHz.ftr')); disp(testCase.root);
            % switch (testCase.BW)
            %     case '5MHz'
            %         testCase.Tx.CustomFilterFileName = ...
            %             fullfile(testCase.root, testCase.filters_dir, 'LTE5_MHz.ftr');
            %     case '10MHz'
            %         testCase.Tx.CustomFilterFileName = ...
            %             fullfile(testCase.root, testCase.filters_dir, 'LTE10_MHz.ftr');
            %     case '15MHz'
            %         testCase.Tx.CustomFilterFileName = ...
            %             fullfile(testCase.root, testCase.filters_dir, 'LTE15_MHz.ftr');
            %     case '20MHz'
            %         testCase.Tx.CustomFilterFileName = ...
            %             fullfile(testCase.root, testCase.filters_dir, 'LTE20_MHz.ftr');
            %     otherwise
            %         st = dbstack;
            %         error('unsupported BW option in LTE test harness - %s\n', testCase.BW);
            % end
            % testCase.Rx.CustomFilterFileName = testCase.Tx.CustomFilterFileName;
            testCase.Rx.uri = testCase.Tx.uri;
            % testCase.Rx();
        end
    end
    
    methods(Test)
        function TestAcrossLOFreqsTMNsBWs(testCase, LOFreqs, TMNs, BWs)
            % run test
            testCase.LOFreq = LOFreqs;
            testCase.TMN = TMNs;
            testCase.BW = BWs;
            testCase.RunTest();
        end
    end
end