%Agilent34405A_visadev  Agilent/Keysight 34405A multimeter driver.
% Port of Agilent34405A.m to the modern VISA interface (visadev/visadevlist,
% writeline/readline). The legacy visa()/instrhwinfo('visa') interface was
% removed in recent MATLAB releases. Method names and usage are unchanged.
%
% Changes vs. the original besides the transport:
%   - Handle class, so state changes made by setState persist on the object.
%   - State comparisons use strcmp (the original char ~= comparison errors
%     when the two state strings have different lengths).
%   - Constructor optionally accepts a VISA resource name.
classdef Agilent34405A_visadev < handle
    properties
       visaAddress;
       v;
       sampleCount;
       state = Agilent34405AStates.DCV;   %Default to DCV
       numSamples = 512;
       triggerCount = 8;
    end

    methods
        function obj = Agilent34405A_visadev(varargin)
            if numel(varargin) == 0
                obj.visaAddress = Agilent34405A_visadev.findAddress();
            else
                obj.visaAddress = char(varargin{1});
            end
            try
                obj.v = visadev(obj.visaAddress);
            catch err
                error('Cannot instantiate Agilent 34405A at %s: %s', obj.visaAddress, err.message);
            end
            configureTerminator(obj.v, "LF");
            obj.sampleCount = 10;
            writeline(obj.v, '*SYST:REM');
            writeline(obj.v, "SYST:BEEP:STAT 0");
        end

        function conf = getCurrentConfig(obj)
            conf = obj.query('CONF?');
        end

        function vdc = readDCV(obj)
            if ~strcmp(obj.state, Agilent34405AStates.DCV)
                obj.setState(Agilent34405AStates.DCV);
            end
            vdc = str2double(obj.query('READ?'));
        end

        function vdc = readACV(obj)
            if ~strcmp(obj.state, Agilent34405AStates.ACV)
                obj.setState(Agilent34405AStates.ACV);
            end
            vdc = str2double(obj.query('READ?'));
        end

        function I = readDCI(obj)
            if ~strcmp(obj.state, Agilent34405AStates.DCI)
                obj.setState(Agilent34405AStates.DCI);
            end
            I = str2double(obj.query('READ?'));
        end

        function I = readACI(obj)
            if ~strcmp(obj.state, Agilent34405AStates.ACI)
                obj.setState(Agilent34405AStates.ACI);
            end
            I = str2double(obj.query('READ?'));
        end

        function T = readTemp(obj)
            if ~strcmp(obj.state, Agilent34405AStates.TEMP)
                obj.setState(Agilent34405AStates.TEMP);
            end
            T = str2double(obj.query('READ?'));
        end

        function r = read2WRes(obj)
            if ~strcmp(obj.state, Agilent34405AStates.R2W)
                obj.setState(Agilent34405AStates.R2W);
            end
            r = str2double(obj.query('READ?'));
        end

        function c = readCont(obj)
            if ~strcmp(obj.state, Agilent34405AStates.CONT)
                obj.setState(Agilent34405AStates.CONT);
            end
            c = str2double(obj.query('READ?'));
        end

        function d = readDiode(obj)
            if ~strcmp(obj.state, Agilent34405AStates.DIODE)
                obj.setState(Agilent34405AStates.DIODE);
            end
            d = str2double(obj.query('READ?'));
        end

        function c = readCapacitance(obj)
            if ~strcmp(obj.state, Agilent34405AStates.CAP)
                obj.setState(Agilent34405AStates.CAP);
            end
            c = str2double(obj.query('READ?'));
        end

        function f = readFrequency(obj)
            if ~strcmp(obj.state, Agilent34405AStates.FREQ)
                obj.setState(Agilent34405AStates.FREQ);
            end
            f = str2double(obj.query('READ?'));
        end

        function f = readPeriod(obj)
            if ~strcmp(obj.state, Agilent34405AStates.PERIOD)
                obj.setState(Agilent34405AStates.PERIOD);
            end
            f = str2double(obj.query('READ?'));
        end

        function s = scan(obj)
            if ~strcmp(obj.state, Agilent34405AStates.SCAN)
                obj.setState(Agilent34405AStates.SCAN);
            end
            s = str2double(obj.query('READ?'));
        end

        function setScale(obj, state, range)
            %Use: obj.setScale(Agilent34405AStates.STATE, [min max]);
            writeline(obj.v, ['CONF:' state ' ' num2str(range(2)) ',' num2str(range(1))]);
        end

        function setTriggerSource(obj, source)
            writeline(obj.v, ['TRIG:SOUR ' source]);
        end

        function setLocal(obj)
            writeline(obj.v, 'SYST:LOC');
        end

        function retVal = sendCommand(obj, command)
            if contains(command, '?')
                retVal = obj.query(command);
            else
                writeline(obj.v, command);
                retVal = 0;
            end
        end

        function setState(obj, state)
            if isvalid(obj.v)
                obj.state = state;
                writeline(obj.v, ['CONF:' obj.state]);
            else
                error('Agilent 34405A object not valid');
            end
        end

        function setSampleCount(obj)
            writeline(obj.v, ['SAMP:COUN ' num2str(obj.sampleCount)]);
        end

        function setTriggerCount(obj)
            writeline(obj.v, ['TRIG:COUN ' num2str(obj.triggerCount)]);
        end

        function config = getConfig(obj)
            config = obj.query('CONF?');
        end

        function setBeep(obj, beep)
            switch(beep)
                case true
                    writeline(obj.v, 'SYST:BEEP:STAT:ON');
                case false
                    writeline(obj.v, 'SYST:BEEP:STAT:OFF');
            end
        end

        function reset(obj)
            writeline(obj.v, '*RST');
        end

        function selfTest(obj)
            ret = str2double(obj.query('*TST?'));
            if(ret == 0)
                disp(['No errors found in self-test, code:' num2str(ret)]);
            else
                disp(['Error code: ' num2str(ret)]);
            end
        end

        function t = approxTime(obj, stat)
            tic;
            obj.setState(stat);
            obj.setSampleCount();
            obj.setTriggerCount();
            obj.query('READ?');
            t = toc;
        end

        function bool = deInit(obj)
            if ~isempty(obj.v) && isvalid(obj.v)
                writeline(obj.v, 'SYST:LOC');
                obj.reset();
                delete(obj.v);
                obj.v = [];
                bool = 1;
            else
                bool = 0;
            end
        end
    end

    methods (Access = private)
        function resp = query(obj, command)
            writeline(obj.v, command);
            resp = char(strtrim(readline(obj.v)));
        end
    end

    methods (Static)
        function address = findAddress()
            % Returns the VISA resource name of the first USB instrument,
            % preferring one whose model reports 34405.
            list = visadevlist;
            if isempty(list)
                error('No VISA instruments found.');
            end
            names = string(list.ResourceName);
            isUSB = startsWith(names, "USB");
            is34405 = isUSB & contains(string(list.Model), "34405");
            if any(is34405)
                address = char(names(find(is34405, 1)));
            elseif any(isUSB)
                address = char(names(find(isUSB, 1)));
            else
                error('No USB VISA instrument found.');
            end
        end
    end
end
