classdef BlockEdfSummarizeClass
    %BlockEdfSummarizeClass Summarize contents of a list of EDF files
    %   Function takes a list of EDF/XML files created by the function 
    % GetMatchedSleepFiles and summarises the content into a single xls
    % file.
    %
    % EDF structures for BlockEdfLoad
    %    header:
    %       edf_ver
    %       patient_id
    %       local_rec_id
    %       recording_startdate
    %       recording_starttime
    %       num_header_bytes
    %       reserve_1
    %       num_data_records
    %       data_record_duration
    %       num_signals
    %    signalHeader (structured array with entry for each signal):
    %       signal_labels
    %       tranducer_type
    %       physical_dimension
    %       physical_min
    %       physical_max
    %       digital_min
    %       digital_max
    %       prefiltering
    %       samples_in_record
    %       reserve_2
    %
    %
    % Version: 0.1.02
    %
    % ---------------------------------------------
    % Dennis A. Dean, II, Ph.D
    %
    % Program for Sleep and Cardiovascular Medicine
    % Brigam and Women's Hospital
    % Harvard Medical School
    % 221 Longwood Ave
    % Boston, MA  02149
    %
    % File created: December 20, 2013
    % Last updated: December 20, 2013 
    %    
    % Copyright © [2013] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
    % WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
    % AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
    % PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
    % BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
    % INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
    % FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
    % AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
    % RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
    %    
    
    %---------------------------------------------------- Public Properties
    properties (Access = public)
        % Primary input
        xlsFileList                              % File input list
        xlsFileSummaryOut                        % Output file 
        
        % Check values
        checkValues = [];
    end
    %------------------------------------------------ Dependent Properties
    properties (Dependent = true)
    end
    %--------------------------------------------------- Private Properties
    properties (Access = protected)
        % Program constants
        folderSeparator = '\';

        % Input File Locations
        edfFnIndex = 2;
        edfPathIndex = 6;
        xmlFnIndex = 7;  
        xmlPathIndex = 11;
        
        % Signal Summary defaults
        signalField = 'signal_labels';
    end
    %------------------------------------------------------- Public Methods
    methods
        %------------------------------------------------------ Constructor
        function obj = BlockEdfSummarizeClass(varargin)
            % Process input arguments
            if nargin == 2
               obj.xlsFileList = varargin{1};
               obj.xlsFileSummaryOut = varargin{2};
            else
               % Number of arguments is not supported
               
            end
        end
        %-------------------------------------------------- summarizeHeader  
        function obj = summarizeHeader(obj)
            % Program constants
            folderSeparator = obj.folderSeparator;

            % File Locations
            edfFnIndex = obj.edfFnIndex;
            edfPathIndex = obj.edfPathIndex;
            xmlFnIndex = obj.xmlFnIndex;  
            xmlPathIndex = obj.xmlPathIndex;

            % XLS File name
            xlsFileList = obj.xlsFileList;
            xlsFileSummaryOut = obj.xlsFileSummaryOut;

            % Load xls file
            try 
                [num txt raw] = xlsread(xlsFileList);
            catch
                % Return
                errMsg = 'Could not open EDF/XML file list';
                warning(errMsg);
                return
            end
            
            % Prepare contents for summary
            edfFN = txt(2:end,edfFnIndex);
            edfPath = strcat(txt(2:end,edfPathIndex), folderSeparator);
            xmlFN = txt(2:end,xmlFnIndex);
            xmlPath = strcat(txt(2:end,xmlPathIndex), folderSeparator);

            % Get values
            numFiles = length(edfFN);
            
            try
                % Process each entry
                headerTable = cell(numFiles+1,10+2);
                for e = 1:numFiles
                    % Load header
                    edfObj = BlockEdfLoadClass(strcat(edfPath{e}, edfFN{e}));
                    edfObj.numCompToLoad = 1;   % Don't return object
                    edfObj = edfObj.blockEdfLoad;

                    % Get header information
                    headerTable(e+1,1) = {e};
                    headerTable(e+1,2) = edfFN(e);
                    headerTable(e+1,3:end) = struct2cell(edfObj.edf.header)'; 
                end
                catch
                    % Return
                    errMsg = sprintf('Could not complete EDF processing (%.0f, %s)',...
                        e, edfFN{e});
                    warning(errMsg);
                return 
            end
            
            try
                % Add headers
                headerTable(1,1) = {'File ID'};
                headerTable(1,2) = {'Edf FN'};
                headerTable(1,3:end) = fieldnames(edfObj.edf.header)';

                % XLS Write
                xlswrite(xlsFileSummaryOut, headerTable);
            catch
                % Return
                errMsg = sprintf('Could not write output file (%s)',...
                    xlsFileSummaryOut);
                warning(errMsg);
                return  
            end   
        end
        %-------------------------------------------------- summarizeSignals  
        function obj = summarizeSignalLabels(obj, varargin)
            % get default
            folderSeparator = obj.folderSeparator;
            signalField = obj.signalField;
            signalsToTestFor = {};
            
            % Process input
            if nargin == 1
                % Use default field
            elseif nargin == 2
               % Get field
               signalsToTestFor = varargin{1};
            elseif nargin == 3
               % Get field
               signalsToTestFor  = varargin{1};   
               signalField = varargin{2};              
            else
               % prototype not supported
               fprintf('obj = obj.summarizeSignalLabels\n');
               fprintf('obj = obj.summarizeSignalLabels(signalsToTestFor)\n');
               errMsg = 'summarizeSignalField: prototype not supported';
               warning(errMsg);
               return
            end
            
            % Program constants
            

            % File Locations
            edfFnIndex = obj.edfFnIndex;
            edfPathIndex = obj.edfPathIndex;
            xmlFnIndex = obj.xmlFnIndex;  
            xmlPathIndex = obj.xmlPathIndex;

            % XLS File name
            xlsFileList = obj.xlsFileList;
            xlsFileSummaryOut = obj.xlsFileSummaryOut;

            % Load xls file
            try 
                [num txt raw] = xlsread(xlsFileList);
            catch
                % Return
                errMsg = 'Could not open EDF/XML file list';
                warning(errMsg);
                return
            end
            
            % Prepare contents for summary
            edfFN = txt(2:end,edfFnIndex);
            edfPath = strcat(txt(2:end,edfPathIndex), folderSeparator);
            xmlFN = txt(2:end,xmlFnIndex);
            xmlPath = strcat(txt(2:end,xmlPathIndex), folderSeparator);

            % Get values
            numFiles = length(edfFN);
            
            try
                % Process each entry
                headerTable = cell(numFiles+1,10+2);
                for e = 1:numFiles
                    % Load header
                    edfObj = BlockEdfLoadClass(strcat(edfPath{e}, edfFN{e}));
                    edfObj.numCompToLoad = 1;   % Don't return object
                    edfObj = edfObj.blockEdfLoad;

                    % Get header information
                    headerTable(e+1,1) = {e};
                    headerTable(e+1,2) = edfFN(e);
                    headerTable(e+1,3:end) = struct2cell(edfObj.edf.header)'; 
                end
            catch
                    % Return
                    errMsg = sprintf('Could not complete EDF processing (%.0f, %s)',...
                        e, edfFN{e});
                    warning(errMsg);
                return 
            end
            
            % Repeat but this time get signal information
            try
                % Process each entry
                numSignals = cell2mat(headerTable(2:end,end));
                maxSignals = max(numSignals);
                headerTable = cell(numFiles+1,2+10+maxSignals);
                if ~isempty(signalsToTestFor)
                    headerTable = cell(numFiles+1,2+10+maxSignals+1);
                end
                for e = 1:numFiles
                    % Load header
                    edfObj = BlockEdfLoadClass(strcat(edfPath{e}, edfFN{e}));
                    edfObj.numCompToLoad = 2;   % Don't return object
                    edfObj = edfObj.blockEdfLoad;

                    % Get header information
                    headerTable(e+1,1) = {e};
                    headerTable(e+1,2) = edfFN(e);
                    headerTable(e+1,3:12) = struct2cell(edfObj.edf.header)'; 
                    
                    % Get signal header label
                    N = edfObj.edf.header.num_signals;
                    value = ...
                    arrayfun(@(x)getfield(edfObj.edf.signalHeader(x), signalField),[1:N], ...
                         'UniformOutput', 0); 
                    headerTable(e+1,13:12+length(value)) = (value); 
                    
                    % Check if signals are present
                    check = 0;
                    if ~isempty(signalsToTestFor)
                        intersection = sort(intersect(value, signalsToTestFor));
                        if length(intersection) == length(signalsToTestFor)
                            sigs = sort(signalsToTestFor);
                            cmpF = @(x)strcmp(intersection{x}, sigs{x});
                            check = arrayfun(cmpF, [1:length(sigs)],...
                                'uniformOutput', 1);
                            check = floor(sum(double(check))/length(check));
                        end
                        
                        % Set check value
                        headerTable(e+1,end) = {check}; 
                    end
                end
            catch
               % Return
                errMsg = sprintf('Could not complete EDF processing (%.0f, %s)',...
                   e, edfFN{e});
                warning(errMsg);
                return 
            end
            
            
            
            % Add header labels
            checkValues = [];
            try
                % Add headers
                headerTable(1,1) = {'File ID'};
                headerTable(1,2) = {'Edf FN'};
                headerTable(1,3:12) = fieldnames(edfObj.edf.header)';
                headerTable(1,13) = {signalField};
                
                % Check label if completed
                if ~isempty(signalsToTestFor)
                    headerTable(1,end) = {'Signal Check'}; 
                    checkValues = cell2mat(headerTable(2:end,end));
                    obj.checkValues = checkValues;
                end
                
                % XLS Write
                xlswrite(xlsFileSummaryOut, headerTable);
            catch
                % Return
                errMsg = sprintf('Could not write output file (%s)',...
                    xlsFileSummaryOut);
                warning(errMsg);
                return  
            end   
        end
    end
    %---------------------------------------------------- Private functions
    methods (Access=protected)

    end
    %------------------------------------------------- Dependent Properties
    methods   
    end
    methods(Static)

    end
end

