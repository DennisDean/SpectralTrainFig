function varargout = GetMatchedSleepEdfXmlFiles (varargin)
%GetMatchedSleepFiles Search recursively for EDF and XML(annotations) files
%      GetMatchedSleepFiles is a function for identifying EDF and
%      annotation (XML) files often collected as part of a sleep study. 
%      The file list can be exported to an Excel file or returned as a cell array.
%
%  Sleep Background:
%
%      Multiple signals for a single subject are stored in European Data 
%      Format (EDF) file. Technican scored sleep stages and sleep events are 
%      stored in XML format. The program searches a target directory for EDF 
%      and XML files.  
%
%  Assumptions:
%  
%       The search function assumes the following naming the convention:
%
%                         EDF: 'SubjectNamingConvention'.EDF
%                         XML: 'SubjectNamingConvention'.EDF.xml
%
%      The search is not case sensitive and 'EDF' can not be a substring of 
%      'SubjectNamingConvention'.
%
%  Function Prototypes:
%                         GetMatchedSleepFiles (SourceFolder, ouputPathFn)
%       matchedFileInfo = GetMatchedSleepFiles (SourceFolder, ouputPathFn);
%
%  Input:
%         SourceFolder:   Folder to search recursively for paired EDF and XML
%                         files
%          ouputPathFn:   An EXCEL file name, which can include a path
%                         ('./resultFolder/fileList.xls')
%
%  Output:  
%      matchedFileInfo:   A cell array with a row for each matched EDF/XML file
%                         pair.  The 11 columns correspond to: 
%
%                        'ID', 
%                        'EDF Name', 'EDF Date', 'EDF Bytes', 
%                        'EDF Folder Date Num',  'EDF Folder'
%                        'XML Name', 'XML Date', 'XML Bytes', 
%                        'XML Folder Date Num',  'XML Folder'
%
%                        Excel output has same structure
%                         
%  Dependencies:
%         BlockEdfLoadClass.m (54227)
%         http://www.mathworks.com/matlabcentral/fileexchange/45227-blockedfloadclass
%
%         dirr.m (8682)
%         http://www.mathworks.com/matlabcentral/fileexchange/8682-dirr--find-files-recursively-filtering-name--date-or-bytes-
%
%
% Version: 0.1.03
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
% File created: November 25, 2012
% Last update:  January 16, 2015 
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

% Program parameters
xmlSuffix = '-profussion.xml';
tableLabels = {'ID', ... 
               'EDF Name', 'EDF Date', 'EDF Bytes', ... 
               'EDF Folder Date Num',  'EDF Folder' ... 
               'XML Name', 'XML Date', 'XML Bytes', ... 
               'XML Folder Date Num',  'XML Folder' };

% Process input
if nargin == 2
    % Use same varaibles for EDF and XML folder
    sourceFolder = varargin{1};
    destFolder = varargin{2};
    
    % Set XML folder
    xmlSourceFolder = sourceFolder;
elseif nargin == 3
    % Use different folders for EDF and XML folders 
    % EDF Variables
    sourceFolder = varargin{1};
    destFolder = varargin{2};
    
    % XML Variables
    xmlSourceFolder = varargin{3};
elseif nargin == 4
    % Use different folders for EDF and XML folders 
    % EDF Variables
    sourceFolder = varargin{1};
    destFolder = varargin{2};
    
    % XML Variables
    xmlSourceFolder = sourceFolder;  
    xmlSuffix = varargin{4};  
    
else
    % Echo functin prototypes to console
    fprintf('\tGetMatchedSleepFiles (SourceFolder, DestinationFolder)\n');
    fprintf('\nmatchedFileInfo = GetMatchedSleepFiles (SourceFolder, DestinationFolder)\n');
    error;
end

%----------------------------------------------- Search EDF and XML folders

% Search source folder
fileListCellwLabels = GetEdfFileListInfo(sourceFolder);

% Split files in two
fnList = fileListCellwLabels(2:end,1);
oddFiles = [2:2:size(fileListCellwLabels,1)]';
evenFiles = [3:2:size(fileListCellwLabels,1)]';
numMatchedFiles = (size(fileListCellwLabels, 1)-1)/2;

% Search XML source folder
xmlFileListCellwLabels = GetXmlFileListInfo(xmlSourceFolder);
xmlFnList = xmlFileListCellwLabels(2:end,1);

% ------------------------------------------------- Check for matched pairs

% % Try to find matched file pairs
% numOddFiles = length(oddFiles);
% numEvenFiles = length(evenFiles);

% Check for EDF extension
edfExtF = @(x)strcmp(upper(x(end-3:end)),'.EDF');
edfExtensionIndex = find(cellfun(edfExtF, fnList));

% Get EDF file prefix
edfFnPrefixF = @(x)x(1:end-4);
edfFnList = fnList(edfExtensionIndex);
edfPrefixStr = cellfun(edfFnPrefixF, edfFnList, ...
    'UniformOutput', 0);
edfPrefixLength = length(edfPrefixStr{1});
edfPrefixLengthArray = cellfun(@length, edfPrefixStr, ...
    'UniformOutput', 0);

% Check for XML extension
xmlExtF = @(x)strcmp(upper(x(end-3:end)),'.XML');
xmlExtensionIndex = find(cellfun(xmlExtF, xmlFnList));   

% Get XML file prefix
xmlFnPrefixF = @(x)x(1:end-length(xmlSuffix));
xmlFnList = xmlFnList(xmlExtensionIndex);
xmlPrefixStr = cellfun(xmlFnPrefixF, xmlFnList, ...
    'UniformOutput', 0);

% check if matched EDF pair exists
checkForPairF = @(x)find(cell2mat(strfind(xmlPrefixStr, x)));   
edfPairExists = (cellfun(checkForPairF, edfPrefixStr, ...
    'UniformOutput', 0));
edfPairExists = ~cellfun(@isempty, edfPairExists);
edfPairExistsIndexFlag = edfPairExists > 0;

% check if matched XML pair exists
checkForPairF = @(x)(cell2mat(strfind(edfPrefixStr, x)));   
xmlPairExists = (cellfun(checkForPairF, xmlPrefixStr, ...
    'UniformOutput', 0));
xmlPairExists = ~cellfun(@isempty, xmlPairExists);

% Create summaries for presentation
numPairedEdfXmlFiles = sum(1==edfPairExists);
pairedEdfFileListEntryIndex = edfExtensionIndex(edfPairExists);

% Find matched XML entry
checkForPairF = @(x)find(~cellfun(@isempty, strfind(xmlPrefixStr,x)));  
edfPairingExists = cellfun(checkForPairF, edfPrefixStr,  'UniformOutput', 0);
edfPairXmlFnIndex = ...
    xmlExtensionIndex(cell2mat(edfPairingExists(edfPairExistsIndexFlag)));

% Identify EDF names and entries that don't have a matched pair 
if sum(0==edfPairExists)>0
    % Find EDF's with out pairs
    edfWithNoPairIndexes = find(0==edfPairExists);
    numEdfWithNoPairIndexes = length(edfWithNoPairIndexes);

    % Print EDF names for which an XML file could not be found
    fprintf('EDF File names for which an XML file could not be found\n');
    for f = 1:numEdfWithNoPairIndexes
        fprintf('\t%s\n', edfFnList{f})
    end
    fprintf ('Number of EDF files for which a matched XML file could not be found: %.0f\n',numEdfWithNoPairIndexes);
end

% Identify XML names and entries that don't have a matched pair 
if sum(0==xmlPairExists)>0
    % Find XML's with out pairs
    xmlWithNoPairIndexes = find(0==xmlPairExists);
    numXmlWithNoPairIndexes = length(xmlWithNoPairIndexes);

    % Print EDF names for which an XML file could not be found
    fprintf('\nXML File names for which an EDF file could not be found\n');
    for f = 1:numXmlWithNoPairIndexes
        fprintf('\t%s\n', xmlFnList{f})
    end
    fprintf ('Number of XML files for which a matched EDF file could not be found: %.0f\n\n',numXmlWithNoPairIndexes);
end

%------------------------------------------ Move Filelist in to Output Cell
% Create matched return
numMatchedFiles = numPairedEdfXmlFiles;
numCols = size(fileListCellwLabels, 2);
splitFileListCellwLabels = cell(numMatchedFiles+1, (2*numCols+1));

% Add Labels
splitFileListCellwLabels(1,1:end) = tableLabels;
splitFileListCellwLabels(2:end, 1) = num2cell([1:1:numMatchedFiles]');

% Move file listing information into appropraite slot
for f = 1:numMatchedFiles
    edfFnIndex = pairedEdfFileListEntryIndex(f);
    xmlFnIndex = edfPairXmlFnIndex(f);
    splitFileListCellwLabels(1+f,2:6) = fileListCellwLabels(1+edfFnIndex, 1:5);
    splitFileListCellwLabels(1+f,7:11) = xmlFileListCellwLabels(1+xmlFnIndex, 1:5);
end

% Process output
varargout = {};
if nargout == 0;
    xlswrite(destFolder,splitFileListCellwLabels); 
elseif nargout == 1
    varargout{1} = {splitFileListCellwLabels};
end
%--------------------------------------------------------- Support function
% Functions were writen as part of the the BlockEdfLoadClass
% 
%---------------------------------------------- Folder navigation functions
%--------------------------------------------------- GetEdfFileList
function varargout = GetEdfFileList(folder)
    % Get EDF file information
    fileListCellwLabels = ...
        BlockEdfLoadClass.GetEdfFileListInfo(folder);
    fileListCell = fileListCellwLabels(2:end,:);

    % Generate file list 
    fileList = arrayfun(...
        @(x)strcat(fileListCell{x,end},'\',fileListCell{x,1}), ...
            [1:size(fileListCell,1)], 'UniformOutput', false);
    fn = fileListCell(:,1);

    % Return content determined by number of calling arguments    
    if nargout == 1
        varargout{1} = fileList;
    elseif nargout == 2
        varargout{1} = fileList;
        varargout{2} = fn;
    else
        fprintf('filelist = obj.GetEdfFileList(folder)\n');
        fprintf('[filelist fn] = obj.GetEdfFileList(folder)\n');
        msg = 'Number of output arguments not supported';
        error(msg);
    end
end
%----------------------------------------------- GetEdfFileListInfo
function varargout = GetEdfFileListInfo(varargin)
    % Create default value
    value = [];
    folderPath = '';
    xlsOut = 'edfFileList.xls';

    % Process input
    if nargin ==0
        % Open window
        folderPath = uigetdir(cd,'Set EDF search folder');    
        if folderPath == 0
            error('User did not select folder');
        end
    elseif nargin == 1
        % Set EDF search path
        folderPath = varargin{1};
    else
        fprintf('fileStruct = obj.locateEDFs(path| )\n');
    end

    % Get File List
    fileTree  = dirr(folderPath, '\.edf');
    [fileList fileLabels]= flattenFileTree(fileTree, folderPath);
    fileList = [fileLabels;fileList];

    % Write output to xls file
    if nargout == 0
        xlsOut = strcat(folderPath, '\', xlsOut);
        xlswrite('edfFileList.xls',[fileLabels;fileList]);
    else
        varargout{1} = fileList;
    end

    %---------------------------------------------- FlattenFileTree
    function varargout = flattenFileTree(fileTree, folder)
        % Process recursive structure created by dirr (See MATLAB Central)
        % find directory and file entries
        dirMask = arrayfun(@(x)isstruct(fileTree(x).isdir) == 1, ...
            [1:length(fileTree)]);
        fileMask = ~dirMask;

        % Recurse on each directory entry
        fileListD = {};
        if sum(int16(dirMask)) > 0
           dirIndex = find(dirMask);
           for d = dirIndex
               folderR = strcat(folder,'\',fileTree(d).name);
               fileListR = flattenFileTree(fileTree(d).isdir, folderR);
               fileListD = [fileListD; fileListR];
           end 
        end

        % Merge current and recursive list
        fileList = {};
        if sum(int16(fileMask)) > 0
           fileIndex = find(fileMask);
           for f = fileIndex
               entry = {fileTree(f).name ...
                        fileTree(f).date  ...
                        fileTree(f).bytes  ...
                        fileTree(f).datenum ...
                        folder};
               fileList = [fileList; entry];
           end   
        end

        % Merg diretory and file list
        fileList = [fileList; fileListD];

        % Pass file list labels on export
        if nargout == 1
            varargout{1} = fileList;
        elseif nargout == 2
            varargout{1} = fileList;
            varargout{2} = ...
                {'name', 'date', 'bytes',  'datenum', 'folder'};
        end
    end
end
%----------------------------------------------------------- GetXmlFileList
function varargout = GetXmlFileList(folder)
    % Get EDF file information
    fileListCellwLabels = GetXmlFileListInfo(folder);
    fileListCell = fileListCellwLabels(2:end,:);

    % Generate file list 
    fileList = arrayfun(...
        @(x)strcat(fileListCell{x,end},'\',fileListCell{x,1}), ...
            [1:size(fileListCell,1)], 'UniformOutput', false);
    fn = fileListCell(:,1);

    % Return content determined by number of calling arguments    
    if nargout == 1
        varargout{1} = fileList;
    elseif nargout == 2
        varargout{1} = fileList;
        varargout{2} = fn;
    else
        fprintf('filelist = obj.GetEdfFileList(folder)\n');
        fprintf('[filelist fn] = obj.GetEdfFileList(folder)\n');
        msg = 'Number of output arguments not supported';
        error(msg);
    end
end
%------------------------------------------------------- GetXmlFileListInfo
function varargout = GetXmlFileListInfo(varargin)
    % Create default value
    value = [];
    folderPath = '';
    xlsOut = 'edfFileList.xls';

    % Process input
    if nargin ==0
        % Open window
        folderPath = uigetdir(cd,'Set EDF search folder');    
        if folderPath == 0
            error('User did not select folder');
        end
    elseif nargin == 1
        % Set EDF search path
        folderPath = varargin{1};
    else
        fprintf('fileStruct = obj.locateEDFs(path| )\n');
    end

    % Get File List
    fileTree  = dirr(folderPath, '\.xml');
    [fileList fileLabels]= flattenFileTree(fileTree, folderPath);
    fileList = [fileLabels;fileList];

    % Write output to xls file
    if nargout == 0
        xlsOut = strcat(folderPath, '\', xlsOut);
        xlswrite('xmlFileList.xls',[fileLabels;fileList]);
    else
        varargout{1} = fileList;
    end

    %---------------------------------------------- FlattenFileTree
    function varargout = flattenFileTree(fileTree, folder)
        % Process recursive structure created by dirr (See MATLAB Central)
        % find directory and file entries
        dirMask = arrayfun(@(x)isstruct(fileTree(x).isdir) == 1, ...
            [1:length(fileTree)]);
        fileMask = ~dirMask;

        % Recurse on each directory entry
        fileListD = {};
        if sum(int16(dirMask)) > 0
           dirIndex = find(dirMask);
           for d = dirIndex
               folderR = strcat(folder,'\',fileTree(d).name);
               fileListR = flattenFileTree(fileTree(d).isdir, folderR);
               fileListD = [fileListD; fileListR];
           end 
        end

        % Merge current and recursive list
        fileList = {};
        if sum(int16(fileMask)) > 0
           fileIndex = find(fileMask);
           for f = fileIndex
               entry = {fileTree(f).name ...
                        fileTree(f).date  ...
                        fileTree(f).bytes  ...
                        fileTree(f).datenum ...
                        folder};
               fileList = [fileList; entry];
           end   
        end

        % Merg diretory and file list
        fileList = [fileList; fileListD];

        % Pass file list labels on export
        if nargout == 1
            varargout{1} = fileList;
        elseif nargout == 2
            varargout{1} = fileList;
            varargout{2} = ...
                {'name', 'date', 'bytes',  'datenum', 'folder'};
        end
    end
end
end

