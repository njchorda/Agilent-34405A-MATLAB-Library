%SDM3055 multimeter
classdef Agilent34405A
    properties
       visaAddress;
       v;
       sampleCount;
       state = Agilent34405AStates.DCV;   %Default to DCV
       numSamples = 512;            %Default to 10
       triggerCount = 8;            %Default to 1
    end
    
    methods
        function obj = Agilent34405A()
            obj.visaAddress = obj.findAddress();
            obj.v = visa('ni', obj.visaAddress);
            obj.v.EOSMode = 'read&write';
            obj.v.EOSCharCode = 'LF';  
            obj.sampleCount = 10;
            if (isvalid(obj.v) == 0)
                obj.deInit();
                error('Cannot instantiate Agilent 34405A');
            end
            fopen(obj.v);
            fprintf(obj.v, '*SYST:REM');
            fprintf(obj.v, "SYST:BEEP:STAT 0");
        end
        
        function conf = getCurrentConfig(obj)
            fprintf(obj.v, 'CONF?');
            conf = fscanf(obj.v);
        end
        
        function vdc = readDCV(obj)
            if obj.state ~= Agilent34405AStates.DCV
                obj.setState(Agilent34405AStates.DCV);
            end
            % obj.setState(Agilent34405AStates.DCV);
            % obj.setSampleCount;i 8
            % obj.setTriggerCount;
            % fprintf(obj.v, "SYST:BEEP:STAT 0");
            fprintf(obj.v, 'READ?');
            vdc = str2double(fscanf(obj.v));
            
        end
        
        function vdc = readACV(obj)
            if obj.state ~= Agilent34405AStates.ACV
                obj.setState(Agilent34405AStates.ACV);
            end
            fprintf(obj.v, 'READ?');
            vdc = str2double(fscanf(obj.v));
            
        end
        
        function I = readDCI(obj)
            if obj.state ~= Agilent34405AStates.DCI
                obj.setState(Agilent34405AStates.DCI);
            end
            fprintf(obj.v, 'READ?');
            I = str2double(fscanf(obj.v));
        end
        
        function I = readACI(obj)
            if obj.state ~= Agilent34405AStates.ACI
                obj.setState(Agilent34405AStates.ACI);
            end
            fprintf(obj.v, 'READ?');
            I = str2double(fscanf(obj.v));
        end
        
        function T = readTemp(obj)            
            if obj.state ~= Agilent34405AStates.TEMP
                obj.setState(Agilent34405AStates.TEMP);
            end
            fprintf(obj.v, 'READ?');
            T = str2double(fscanf(obj.v));
        end
            
        
        function r = read2WRes(obj)
            if obj.state ~= Agilent34405AStates.R2W
                obj.setState(Agilent34405AStates.R2W);
            end
            fprintf(obj.v, 'READ?');
            r = str2double(fscanf(obj.v)); 
        end

        function c = readCont(obj)
            if obj.state ~= Agilent34405AStates.CONT
                obj.setState(Agilent34405AStates.CONT);
            end
            fprintf(obj.v, 'READ?');
            c = str2double(fscanf(obj.v));
        end
        
        function d = readDiode(obj)
            if obj.state ~= Agilent34405AStates.DIODE
                obj.setState(Agilent34405AStates.DIODE);
            end
            fprintf(obj.v, 'READ?');
            d = str2double(fscanf(obj.v));
        end

        function c = readCapacitance(obj)
            if obj.state ~= Agilent34405AStates.CAP
                obj.setState(Agilent34405AStates.CAP);
            end
            fprintf(obj.v, 'READ?');
            c = str2double(fscanf(obj.v));
        end
        
        function f = readFrequency(obj)
            if obj.state ~= Agilent34405AStates.FREQ
                obj.setState(Agilent34405AStates.FREQ);
            end
            fprintf(obj.v, 'READ?');
            f = str2double(fscanf(obj.v));
        end
        
        function f = readPeriod(obj)
            if obj.state ~= Agilent34405AStates.PERIOD
                obj.setState(Agilent34405AStates.PERIOD);
            end
            fprintf(obj.v, 'READ?');
            f = str2double(fscanf(obj.v));
        end
        
        function s = scan(obj)
            if obj.state ~= Agilent34405AStates.SCAN
                obj.setState(Agilent34405AStates.SCAN);
            end
            fprintf(obj.v, 'READ?');
            s = str2double(fscanf(obj.v));
        end
        
        function setScale(obj, state, range)
            %Use: obj.setScale(SDM3055States.STATE, [min max]);
            strToWrite = strcat(['CONF:' state, ' ' num2str(range(2)) ',' num2str(range(1))]);
            fprintf(obj.v, strToWrite);
            clear strToWrite;
        end
        
        function setTriggerSource(obj, source)
           stringToWrite = strcat(['TRIG:SOUR ' source]);
           fprintf(obj.v, stringToWrite);
           clear stringToWrite;
        end
        
        function setLocal(obj)
            fprintf(obj.v, 'SYST:LOC');
        end
        
        function retVal = sendCommand(obj, command)
            if contains(command, '?') == 1
                fprintf(obj.v, command);
                retVal = fscanf(obj.v);
            else
                fprintf(obj.v, command);
                retVal = 0;
            end
        end
        
        function setState(obj, state)
            obj.state = state;
            if isvalid(obj.v) == 1
                fprintf(obj.v, strcat('CONF:', obj.state));
            else
                error('Agilent 34405A object not valid');
            end
        end
        
        function setSampleCount(obj)
            fprintf(obj.v, strcat('SAMP:COUN ', num2str(obj.sampleCount)));
        end
        
        function setTriggerCount(obj)
            fprintf(obj.v, strcat('TRIG:COUN ', num2str(obj.triggerCount)));
        end
        
        function config = getConfig(obj)
            fprintf(obj.v, 'CONF?');
            config = fscanf(obj.v);
        end
        
        function setBeep(obj, beep)
            switch(beep)
                case true
                    fprintf(obj.v, 'SYST:BEEP:STAT:ON');
                case false
                    fprintf(obj.v, 'SYST:BEEP:STAT:OFF');
            end
        end
        
        function reset(obj)
            fprintf(obj.v, '*RST');
        end
        
        function selfTest(obj)
           fprintf(obj.v, '*TST?');
           retStr = fscanf(obj.v);
           ret = str2double(retStr);
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
            fprintf(obj.v, 'READ?');
            fscanf(obj.v);
            t = toc;
        end
            
        
        function bool = deInit(obj)
            if(isvalid(obj.v) == 1)
                fprintf(obj.v, 'SYST:LOC');
                obj.reset();
                fclose(obj.v);
                delete(obj.v);
                clear obj.v;
                bool = 1;
            else
                bool = 0;
            end

        end
    end
        methods (Static)
        function address = findAddress()
            info = instrhwinfo('visa','ni');
            name = info.ObjectConstructorName{1};
            addressCell = extractBetween(name,'USB', 'INSTR', 'Boundaries', 'inclusive');
            address = addressCell{1};
        end
    end
end