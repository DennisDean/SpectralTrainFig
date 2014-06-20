function varargout = SpectralTrainFig(varargin)
% SPECTRALTRAINFIG MATLAB code for SpectralTrainFig.fig
%      SPECTRALTRAINFIG, by itself, creates a new SPECTRALTRAINFIG or raises the existing
%      singleton*.
%
%      H = SPECTRALTRAINFIG returns the handle to a new SPECTRALTRAINFIG or the handle to
%      the existing singleton*.
%
%      SPECTRALTRAINFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECTRALTRAINFIG.M with the given input arguments.
%
%      SPECTRALTRAINFIG('Property','Value',...) creates a new SPECTRALTRAINFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpectralTrainFig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpectralTrainFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%
% GUI provides user easy acctess to SpectralTrainClass, which computes
% spectral and coherence from EDF and Annotation (XML) files stored in a
% folder.
%
% Version: 0.1.01
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
% File created: April 21, 2014
% Last updated: June 11, 2014 
%    
% Copyright © [2014] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
% WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
% AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
% PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
% BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
% FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
% AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
% RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpectralTrainFig

% Last Modified by GUIDE v2.5 19-Jun-2014 11:43:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpectralTrainFig_OpeningFcn, ...
                   'gui_OutputFcn',  @SpectralTrainFig_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SpectralTrainFig is made visible.
function SpectralTrainFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpectralTrainFig (see VARARGIN)

% Choose default command line output for SpectralTrainFig
handles.output = hObject;

% Clear edit text boxes
set(handles.e_description_analysis_description, 'String',' ');
set(handles.e_description_output_file_prefix, 'String',' ');
set(handles.e_description_data_folder, 'String',' ');
set(handles.e_description_result_folder, 'String',' ');
set(handles.e_analysis_parameters_analysis_signals, 'String',' ');
set(handles.e_analysis_parameters_reference_signals, 'String',' ');

% Inactivate buttons untill analysis folders are set
set(handles.pb_fig_band, 'enable','off');
set(handles.pb_fig_go_min, 'enable','off');
set(handles.pb_fig_go, 'enable','off');

% Set Defaults to SOF
set(handles.e_description_analysis_description, 'String','Spectral Analysis');
set(handles.e_description_output_file_prefix, 'String','study__');
set(handles.e_analysis_parameters_analysis_signals, 'String','{''C3''}');
set(handles.e_analysis_parameters_reference_signals, 'String','{''A2''}');

% Get Monitor Positions and set to first monitor
monitorPositionsStrCell = ConvertMonitorPosToFigPos;
set(handles.pm_analysis_parameters_monitor_id, ...
    'String', monitorPositionsStrCell);

% Inactivate button until data is loaded
set(handles.pb_fig_go_min, 'enable','off');
set(handles.pb_fig_go, 'enable','off');

% Define GUI variables
handles.folderSeperator = '\';
handles.data_folder_path = cd;
handles.data_folder_path_is_selected = 0;
handles.result_folder_path = cd;
handles.result_folder_path_is_selected = 0;


% Define Band Summary files
handles.band_setting_fn = '';
handles.band_setting_pn = strcat(cd, handles.folderSeperator);
handles.band_setting_fn_selected = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpectralTrainFig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpectralTrainFig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% redo but in pixel
% Set starting position in characters. Had problems with pixels
left_border = .8;
header = 2.0;
set(0,'Units','character') ;
screen_size = get(0,'ScreenSize');
set(handles.figure1,'Units','character');
dlg_size    = get(handles.figure1, 'Position');
pos1 = [ left_border , screen_size(4)-dlg_size(4)-1*header,...
    dlg_size(3) , dlg_size(4)];
set(handles.figure1,'Units','character');
set(handles.figure1,'Position',pos1);

% --- Executes on button press in pb_fig_go.
function pb_fig_go_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fig_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get handle information
band_setting_fn = handles.band_setting_fn;
band_setting_pn = handles.band_setting_pn;
band_setting_fn_selected = handles.band_setting_fn_selected;

% Get Analysis Information from interface
analysisDescription = ...
    get(handles.e_description_analysis_description, 'String');
outputFilePrefix = ...
    get(handles.e_description_output_file_prefix, 'String');
dataFolder =  strcat(...
    get(handles.e_description_data_folder, 'String'),...
    handles.folderSeperator);
resultFolder =  strcat(...
    get(handles.e_description_result_folder, 'String'), ...
    handles.folderSeperator);
analysisSignals =  eval(...
    get(handles.e_analysis_parameters_analysis_signals, 'String'));
referenceSignals =  eval(......
    get(handles.e_analysis_parameters_reference_signals, 'String'));
referenceMethod = get(handles.pm_reference_method, 'Value');
deltaThStr = ...
    get(handles.pm_analysis_parameters_delta, 'String');
deltaTh = str2num(deltaThStr{...
    get(handles.pm_analysis_parameters_delta, 'Value')});
betaThStr =  ...
    get(handles.pm_analysis_parameters_beta, 'String');
betaTh = str2num(betaThStr{...
    get(handles.pm_analysis_parameters_beta, 'Value')});
monitorIDStr =  ...
    get(handles.pm_analysis_parameters_monitor_id, 'String');
monitorID = eval(monitorIDStr{...
    get(handles.pm_analysis_parameters_monitor_id, 'Value')});
cb_fig_compute_coherence =  ...
    get(handles.cb_fig_compute_coherence, 'Value');
pm_analysis_spectral_settings =  ...
    get(handles.pm_analysis_spectral_settings, 'Value');
analysisStartStr =  ...
    get(handles.pm_analysis_start, 'String');
startFile = str2num(analysisStartStr{...
    get(handles.pm_analysis_start, 'Value')});

% Create spectral analysis structure
stcStruct.analysisDescription = analysisDescription;
stcStruct.StudyEdfFileListResultsFn = strcat(outputFilePrefix, ...
    '_FileList.xlsx');
stcStruct.StudyEdfDir = dataFolder; 
stcStruct.StudyEdfResultDir = resultFolder;
stcStruct.xlsFileContentCheckSummaryOut =  strcat(outputFilePrefix, ...
    '_FileLisWithCheck.xlsx');
stcStruct.analysisSignals = analysisSignals;
stcStruct.referenceSignals = referenceSignals;
stcStruct.requiredSignals = [analysisSignals referenceSignals];
stcStruct.StudySpectrumSummary = strcat( ...
    outputFilePrefix, 'SpectralSummary.xlsx');
stcStruct.StudyBandSummary = strcat( ...
    outputFilePrefix, 'BandSummary.xlsx');
stcStruct.checkFile = strcat(stcStruct.StudyEdfResultDir, ...
        stcStruct.StudyEdfFileListResultsFn);
    
% Create class object
stcObj = SpectralTrainClass(stcStruct);

% Define options for minimum reccomendedoutput 
stcObj.referenceMethodIndex = referenceMethod;
stcObj.SUMMARIZE_BANDS = 1;
stcObj.EXPORT_BAND_SUMMARY = 1;
stcObj.PLOT_CALIBRATION_TEST = 0;
stcObj.PLOT_HYPNOGRAM = 1;
stcObj.PLOT_ARTIFACT_SUMMARY = 1;
stcObj.PLOT_SPECTRAL_SUMMARY = 1;
stcObj.PLOT_NREM_REM_SPECTRUM = 1;
stcObj.OUTPUT_AVERAGE_SPECTROGRAMS = 1;
stcObj.PLOT_BAND_ACTIVITY = 1;
stcObj.artifactTH = [deltaTh betaTh];
stcObj.figPos = monitorID;
stcObj.GENERATE_FILE_LIST = 1;
stcObj.CREATE_POWER_POINT_SUMMARY = 1;
stcObj.EXPORT_SPECTRAL_DETAILS = 1;
stcObj.COMPUTE_TOTAL_POWER = 1;
stcObj.EXPORT_TOTAL_POWER = 1;

% Spectral parameters
if (pm_analysis_spectral_settings == 2)
    % Switch to SHHS settings
    stcObj.noverlap = 6;
    stcObj.spectralBinWidth = 5;
    stcObj.windowFunctionIndex = 3; % Hanning
    stcObj.AVERAGE_ADJACENT_BANDS = 0;
end

% Band settings
if band_setting_fn_selected == 1
    % Load band structure
    bandFn = strcat(band_setting_pn, band_setting_fn);
    bandStruct = stcObj.LoadBandSettings(bandFn);
    
    % Set band variables
    stcObj.bandsOfInterest = bandStruct.bandsOfInterest;
    stcObj.bandsOfInterestLabels = bandStruct.bandsOfInterestLabels;
    stcObj.bandsOfInterestLatex = bandStruct.bandsOfInterestLatex;
    stcObj.bandColors = bandStruct.bandColors;
end

% Compute Coherence
stcObj.COHERENCE_COMPUTE_COHERENCE = cb_fig_compute_coherence;

% Set start iterion
stcObj.startFile = startFile;

% Execute analysis
stcObj = stcObj.computeSpectralTrain;

% --- Executes on button press in pb_fig_about.
function pb_fig_about_Callback(~, eventdata, handles)
% hObject    handle to pb_fig_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SpectralTrainFigAbout

function e_description_analysis_description_Callback(hObject, eventdata, handles)
% hObject    handle to e_description_analysis_description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_description_analysis_description as text
%        str2double(get(hObject,'String')) returns contents of e_description_analysis_description as a double


% --- Executes during object creation, after setting all properties.
function e_description_analysis_description_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_description_analysis_description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_description_output_file_prefix_Callback(hObject, eventdata, handles)
% hObject    handle to e_description_output_file_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_description_output_file_prefix as text
%        str2double(get(hObject,'String')) returns contents of e_description_output_file_prefix as a double


% --- Executes during object creation, after setting all properties.
function e_description_output_file_prefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_description_output_file_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_description_data_folder_Callback(hObject, eventdata, handles)
% hObject    handle to e_description_data_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_description_data_folder as text
%        str2double(get(hObject,'String')) returns contents of e_description_data_folder as a double


% --- Executes during object creation, after setting all properties.
function e_description_data_folder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_description_data_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_description_result_folder_Callback(hObject, eventdata, handles)
% hObject    handle to e_description_result_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_description_result_folder as text
%        str2double(get(hObject,'String')) returns contents of e_description_result_folder as a double


% --- Executes during object creation, after setting all properties.
function e_description_result_folder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_description_result_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_description_data_folder.
function pb_description_data_folder_Callback(hObject, eventdata, handles)
% hObject    handle to pb_description_data_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get current data folder path
data_folder_path = handles.data_folder_path;

% Prompt user for folder
dialogTitle = 'Select Data Source Folder';
[folder_path folder_is_selected ] = ...
                      pb_select_data_folder(data_folder_path, dialogTitle);

% Check if a folder was selected
if folder_is_selected == 1
    % write file name to dialog box
    set(handles.e_description_data_folder, 'String', folder_path);
    guidata(hObject, handles);
    
    % Save file information to globals
    handles.data_folder_path = folder_path;
    handles.data_folder_path_is_selected = folder_is_selected;
    
    % Adjust buttons if necssary
    if and(logical(handles.data_folder_path_is_selected), ...
           logical(handles.result_folder_path_is_selected))
        set(handles.pb_fig_band, 'enable','on');
        set(handles.pb_fig_go_min, 'enable','on');
        set(handles.pb_fig_go, 'enable','on');
    end
    
    % Save new data
    guidata(hObject, handles);
end
% --- Executes on button press in pb_description_result_folder.
function pb_description_result_folder_Callback(hObject, eventdata, handles)
% hObject    handle to pb_description_result_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get current data folder path
result_folder_path = handles.result_folder_path;

% Prompt user for folder
dialogTitle = 'Select Result Folder';
[folder_path folder_is_selected ] = ...
                      pb_select_data_folder(result_folder_path, dialogTitle);

% Check if a folder was selected
if folder_is_selected == 1
    % write file name to dialog box
    set(handles.e_description_result_folder, 'String', folder_path);
    guidata(hObject, handles);
    
    % Save file information to globals
    handles.result_folder_path = folder_path;
    handles.result_folder_path_is_selected = folder_is_selected;
    
    % Adjust buttons if necssary
    if and(logical(handles.data_folder_path_is_selected), ...
           logical(handles.result_folder_path_is_selected))
        set(handles.pb_fig_band, 'enable','on');
        set(handles.pb_fig_go_min, 'enable','on');
        set(handles.pb_fig_go, 'enable','on');
    end
    
    % Save new data
    guidata(hObject, handles);
end

function e_analysis_parameters_analysis_signals_Callback(hObject, eventdata, handles)
% hObject    handle to e_analysis_parameters_analysis_signals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_analysis_parameters_analysis_signals as text
%        str2double(get(hObject,'String')) returns contents of e_analysis_parameters_analysis_signals as a double


% --- Executes during object creation, after setting all properties.
function e_analysis_parameters_analysis_signals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_analysis_parameters_analysis_signals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_analysis_parameters_reference_signals_Callback(hObject, eventdata, handles)
% hObject    handle to e_analysis_parameters_reference_signals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_analysis_parameters_reference_signals as text
%        str2double(get(hObject,'String')) returns contents of e_analysis_parameters_reference_signals as a double


% --- Executes during object creation, after setting all properties.
function e_analysis_parameters_reference_signals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_analysis_parameters_reference_signals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_fig_go_min.
function pb_fig_go_min_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fig_go_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get handle information
band_setting_fn = handles.band_setting_fn;
band_setting_pn = handles.band_setting_pn;
band_setting_fn_selected = handles.band_setting_fn_selected;

% Get Analysis Information from interface
analysisDescription = ...
    get(handles.e_description_analysis_description, 'String');
outputFilePrefix = ...
    get(handles.e_description_output_file_prefix, 'String');
dataFolder =  strcat(...
    get(handles.e_description_data_folder, 'String'),...
    handles.folderSeperator);
resultFolder =  strcat(...
    get(handles.e_description_result_folder, 'String'), ...
    handles.folderSeperator);
analysisSignals =  eval(...
    get(handles.e_analysis_parameters_analysis_signals, 'String'));
referenceSignals =  eval(......
    get(handles.e_analysis_parameters_reference_signals, 'String'));
referenceMethod = get(handles.pm_reference_method, 'Value');
deltaThStr = ...
    get(handles.pm_analysis_parameters_delta, 'String');
deltaTh = str2num(deltaThStr{...
    get(handles.pm_analysis_parameters_delta, 'Value')});
betaThStr =  ...
    get(handles.pm_analysis_parameters_beta, 'String');
betaTh = str2num(betaThStr{...
    get(handles.pm_analysis_parameters_beta, 'Value')});
monitorIDStr =  ...
    get(handles.pm_analysis_parameters_monitor_id, 'String');
monitorID = eval(monitorIDStr{...
    get(handles.pm_analysis_parameters_monitor_id, 'Value')});
cb_fig_compute_coherence =  ...
    get(handles.cb_fig_compute_coherence, 'Value');
pm_analysis_spectral_settings =  ...
    get(handles.pm_analysis_spectral_settings, 'Value');
analysisStartStr =  ...
    get(handles.pm_analysis_start, 'String');
startFile = str2num(analysisStartStr{...
    get(handles.pm_analysis_start, 'Value')});

% Create spectral analysis structure
stcStruct.analysisDescription = analysisDescription;
stcStruct.StudyEdfFileListResultsFn = strcat(outputFilePrefix, ...
    '_FileList.xlsx');
stcStruct.StudyEdfDir = dataFolder; 
stcStruct.StudyEdfResultDir = resultFolder;
stcStruct.xlsFileContentCheckSummaryOut =  strcat(outputFilePrefix, ...
    '_FileLisWithCheck.xlsx');
stcStruct.analysisSignals = analysisSignals;
stcStruct.referenceSignals = referenceSignals;
stcStruct.requiredSignals = [analysisSignals referenceSignals];
stcStruct.StudySpectrumSummary = strcat( ...
    outputFilePrefix, 'SpectralSummary.xlsx');
stcStruct.StudyBandSummary = strcat( ...
    outputFilePrefix, 'BandSummary.xlsx');
stcStruct.checkFile = strcat(stcStruct.StudyEdfResultDir, ...
        stcStruct.StudyEdfFileListResultsFn);
    
% Create class object
stcObj = SpectralTrainClass(stcStruct);

% Define options for minimum reccomendedoutput 
stcObj.referenceMethodIndex = referenceMethod;
stcObj.SUMMARIZE_BANDS = 1;
stcObj.EXPORT_BAND_SUMMARY = 1;
stcObj.PLOT_CALIBRATION_TEST = 0;
stcObj.PLOT_COMPREHENSIVE_SPECTRAL_SUMMARY = 1;
stcObj.PLOT_HYPNOGRAM = 0;
stcObj.PLOT_ARTIFACT_SUMMARY = 0;
stcObj.PLOT_SPECTRAL_SUMMARY = 0;
stcObj.PLOT_NREM_REM_SPECTRUM = 1;
stcObj.OUTPUT_AVERAGE_SPECTROGRAMS = 1;
stcObj.PLOT_BAND_ACTIVITY = 0;
stcObj.artifactTH = [deltaTh betaTh];
stcObj.figPos = monitorID;
stcObj.GENERATE_FILE_LIST = 1;
stcObj.CREATE_POWER_POINT_SUMMARY = 1;
stcObj.EXPORT_SPECTRAL_DETAILS = 0;
stcObj.COMPUTE_TOTAL_POWER = 0;
stcObj.EXPORT_TOTAL_POWER = 0;

% Coherence Parametes
stcObj.COHERENCE_COMPUTE_COHERENCE = cb_fig_compute_coherence;


% Spectral parameters
if (pm_analysis_spectral_settings == 2)
    % Switch to SHHS settings
    stcObj.noverlap = 6;
    stcObj.spectralBinWidth = 5;
    stcObj.windowFunctionIndex = 3; % Hanning
    stcObj.AVERAGE_ADJACENT_BANDS = 0;
end

% Band settings
if band_setting_fn_selected == 1
    % Load band structure
    bandFn = strcat(band_setting_pn, band_setting_fn);
    bandStruct = stcObj.LoadBandSettings(bandFn);
    
    % Set band variables
    stcObj.bandsOfInterest = bandStruct.bandsOfInterest;
    stcObj.bandsOfInterestLabels = bandStruct.bandsOfInterestLabels;
    stcObj.bandsOfInterestLatex = bandStruct.bandsOfInterestLatex;
    stcObj.bandColors = bandStruct.bandColors;
end

% Set start iterion
stcObj.startFile = startFile;

% Execute analysis
stcObj = stcObj.computeSpectralTrain;

% 
% % --- Executes on selection change in popupmenu1.
% function pm_analysis_parameters_delta_Callback(hObject, eventdata, handles)
% % hObject    handle to popupmenu1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from popupmenu1
% 
% % --- Executes on selection change in popupmenu1.
% function pm_analysis_parameters_delta_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to popupmenu1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from popupmenu1

% --- Executes on button press in pb_fig_set_bands.
function pb_fig_set_bands_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fig_set_bands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Start search in current path
current_xls_path = handles.band_setting_pn;

% Ask user to select a file
[xls_fn xls_pn xls_file_is_selected ] = ...
                                      pb_select_xls_file(current_xls_path);
 
% Record file information if new file is selected
if xls_file_is_selected == 1
    handles.band_setting_fn = xls_fn;
    handles.band_setting_pn = xls_pn;
    handles.band_setting_fn_selected = 1; 
    handles.current_xls_path = xls_pn;
end

% Update handles structure
guidata(hObject, handles);
% --- Executes on selection change in pm_analysis_parameters_monitor_id.
function pm_analysis_parameters_monitor_id_Callback(hObject, eventdata, handles)
% hObject    handle to pm_analysis_parameters_monitor_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_analysis_parameters_monitor_id contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_analysis_parameters_monitor_id


% --- Executes during object creation, after setting all properties.
function pm_analysis_parameters_monitor_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_analysis_parameters_monitor_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_analysis_parameters_delta.
function pm_analysis_parameters_delta_Callback(hObject, eventdata, handles)
% hObject    handle to pm_analysis_parameters_delta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_analysis_parameters_delta contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_analysis_parameters_delta


% --- Executes during object creation, after setting all properties.
function pm_analysis_parameters_delta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_analysis_parameters_delta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_analysis_parameters_beta.
function pm_analysis_parameters_beta_Callback(hObject, eventdata, handles)
% hObject    handle to pm_analysis_parameters_beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_analysis_parameters_beta contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_analysis_parameters_beta


% --- Executes during object creation, after setting all properties.
function pm_analysis_parameters_beta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_analysis_parameters_beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_fig_band.
function pb_fig_band_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fig_band (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get handle information
band_setting_fn = handles.band_setting_fn;
band_setting_pn = handles.band_setting_pn;
band_setting_fn_selected = handles.band_setting_fn_selected;

% Get Analysis Information from interface
analysisDescription = ...
    get(handles.e_description_analysis_description, 'String');
outputFilePrefix = ...
    get(handles.e_description_output_file_prefix, 'String');
dataFolder =  strcat(...
    get(handles.e_description_data_folder, 'String'),...
    handles.folderSeperator);
resultFolder =  strcat(...
    get(handles.e_description_result_folder, 'String'), ...
    handles.folderSeperator);
analysisSignals =  eval(...
    get(handles.e_analysis_parameters_analysis_signals, 'String'));
referenceSignals =  eval(......
    get(handles.e_analysis_parameters_reference_signals, 'String'));
referenceMethod = get(handles.pm_reference_method, 'Value');
deltaThStr = ...
    get(handles.pm_analysis_parameters_delta, 'String');
deltaTh = str2num(deltaThStr{...
    get(handles.pm_analysis_parameters_delta, 'Value')});
betaThStr =  ...
    get(handles.pm_analysis_parameters_beta, 'String');
betaTh = str2num(betaThStr{...
    get(handles.pm_analysis_parameters_beta, 'Value')});
monitorIDStr =  ...
    get(handles.pm_analysis_parameters_monitor_id, 'String');
monitorID = eval(monitorIDStr{...
    get(handles.pm_analysis_parameters_monitor_id, 'Value')});
cb_fig_compute_coherence =  ...
    get(handles.cb_fig_compute_coherence, 'Value');
pm_analysis_spectral_settings =  ...
    get(handles.pm_analysis_spectral_settings, 'Value');
analysisStartStr =  ...
    get(handles.pm_analysis_start, 'String');
startFile = str2num(analysisStartStr{...
    get(handles.pm_analysis_start, 'Value')});

% Create spectral analysis structure
stcStruct.analysisDescription = analysisDescription;
stcStruct.StudyEdfFileListResultsFn = strcat(outputFilePrefix, ...
    '_FileList.xlsx');
stcStruct.StudyEdfDir = dataFolder; 
stcStruct.StudyEdfResultDir = resultFolder;
stcStruct.xlsFileContentCheckSummaryOut =  strcat(outputFilePrefix, ...
    '_FileLisWithCheck.xlsx');
stcStruct.analysisSignals = analysisSignals;
stcStruct.referenceSignals = referenceSignals;
stcStruct.requiredSignals = [analysisSignals referenceSignals];
stcStruct.StudySpectrumSummary = strcat( ...
    outputFilePrefix, 'SpectralSummary.xlsx');
stcStruct.StudyBandSummary = strcat( ...
    outputFilePrefix, 'BandSummary.xlsx');
stcStruct.checkFile = strcat(stcStruct.StudyEdfResultDir, ...
        stcStruct.StudyEdfFileListResultsFn);    
    
% Create class object
stcObj = SpectralTrainClass(stcStruct);

% Define options for minimum reccomendedoutput 
stcObj.referenceMethodIndex = referenceMethod;
stcObj.SUMMARIZE_BANDS = 1;
stcObj.EXPORT_BAND_SUMMARY = 1;
stcObj.PLOT_CALIBRATION_TEST = 0;
stcObj.PLOT_HYPNOGRAM = 0;
stcObj.PLOT_ARTIFACT_SUMMARY = 0;
stcObj.PLOT_SPECTRAL_SUMMARY = 0;
stcObj.PLOT_NREM_REM_SPECTRUM = 1;
stcObj.OUTPUT_AVERAGE_SPECTROGRAMS = 1;
stcObj.PLOT_BAND_ACTIVITY = 0;
stcObj.artifactTH = [deltaTh betaTh];
stcObj.figPos = monitorID;
stcObj.GENERATE_FILE_LIST = 1;
stcObj.CREATE_POWER_POINT_SUMMARY = 0;
stcObj.EXPORT_INDIVIDUAL_BAND_SUMMARY = 0;

stcObj.EXPORT_SPECTRAL_DETAILS = 0;
stcObj.COMPUTE_TOTAL_POWER = 0;
stcObj.EXPORT_TOTAL_POWER = 0;

% Spectral parameters
if (pm_analysis_spectral_settings == 2)
    % Switch to SHHS settings
    stcObj.noverlap = 6;
    stcObj.spectralBinWidth = 5;
    stcObj.windowFunctionIndex = 3; % Hanning
    stcObj.AVERAGE_ADJACENT_BANDS = 0;
end

% Band settings
if band_setting_fn_selected == 1
    % Load band structure
    bandFn = strcat(band_setting_pn, band_setting_fn);
    bandStruct = stcObj.LoadBandSettings(bandFn);
    
    % Set band variables
    stcObj.bandsOfInterest = bandStruct.bandsOfInterest;
    stcObj.bandsOfInterestLabels = bandStruct.bandsOfInterestLabels;
    stcObj.bandsOfInterestLatex = bandStruct.bandsOfInterestLatex;
    stcObj.bandColors = bandStruct.bandColors;
end

% Set start iterion
stcObj.startFile = startFile;

% Coherence parameters
stcObj.COHERENCE_COMPUTE_COHERENCE = cb_fig_compute_coherence;

% Execute analysis
stcObj = stcObj.computeSpectralTrain;


% --- Executes on selection change in pm_reference_method.
function pm_reference_method_Callback(hObject, eventdata, handles)
% hObject    handle to pm_reference_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_reference_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_reference_method


% --- Executes during object creation, after setting all properties.
function pm_reference_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_reference_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_fig_compute_coherence.
function cb_fig_compute_coherence_Callback(hObject, eventdata, handles)
% hObject    handle to cb_fig_compute_coherence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_fig_compute_coherence


% --- Executes on selection change in pm_analysis_spectral_settings.
function pm_analysis_spectral_settings_Callback(hObject, eventdata, handles)
% hObject    handle to pm_analysis_spectral_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_analysis_spectral_settings contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_analysis_spectral_settings


% --- Executes during object creation, after setting all properties.
function pm_analysis_spectral_settings_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_analysis_spectral_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_analysis_start.
function pm_analysis_start_Callback(hObject, eventdata, handles)
% hObject    handle to pm_analysis_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_analysis_start contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_analysis_start


% --- Executes during object creation, after setting all properties.
function pm_analysis_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_analysis_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_close_all.
function pb_close_all_Callback(hObject, eventdata, handles)
% hObject    handle to pb_close_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SpectralTrainClass.CloseChildrenFigures
