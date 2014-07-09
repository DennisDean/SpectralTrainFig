classdef SpectralTrainClass
    %SpectralTrainClass Spectral analysis program
    %
    %       A flexible spectral analysis program developed to analyze sleep
    %   studies.  A spectral threshold artifact detection approach is 
    %   included and modeled after the appraoch described in Buckelmuller
    %   et al. 2006. 
    %
    %       The program builds on the program developed by our Case
    %   Western Reserve University Colleagues for the Sleep Heart Health
    %   Study.  The Case Western Reserve University team is led by Dr. Kenneth 
    %   A. Loparo. Dr. Daniel Aeschbach provided technical guidance during the 
    %   development and validation of the program.  Leila Tarokh provided an
    %   an outline of the spectral and coherence analysis pipeline. 
    %
    %       The Class serves as the functional component of a simplified
    %   GUI, SpectralTrainFig, for running spectral analysis on batches of 
    %   sleep studies. 
    % 
    %
    % Reccomendations:
    %
    %   Do the example in the SpectralTrainFig getting started guide to get 
    %   an overview of the programs features. Experienced programmer will
    %   want to take a look at the
    %
    %   SpectralTrainFig gettting started:
    %        https://github.com/DennisDean/SpectralTrainFig
    % 
    %   Please feel free to contact me if you want to discuss enhancements
    %   you would like to make.  We would like to include them in future
    %   releases.
    %
    % 
    % Input:
    %
    %    stcStruct:
    %
    %        analysisDescription:
    %             Brief analysis description 
    %        StudyEdfFileListResultsFn:
    %             File name for generated EDF/XML file list
    %        xlsFileContentCheckSummaryOut:
    %             File name for to write signal check information
    %        SR:
    %             Signal Sampling rate (No checks in place)
    %        requiredSignals:
    %             Cell array of signal labels to be loaded
    %        analysisSignals:
    %             Cell array of signal to analyze
    %        referenceSignals:
    %             Cell array of reference signals
    %        StudySpectrumSummary:
    %        StudyBandSummary:
    %        StudyEdfDir:
    %        StudyEdfResultDir:
    %        checkFile:
    %
    %    bandFn (optional):
    %
    %        An EXCEL file that describes the spectral bands to analyze.
    %        See the example file included in the release.  Note that the
    %        bandFn option was introduced to support the associated GUI.
    %    
    %        An example of the file follows:
    % 
    %        bandsOfInterest	bandsOfInterestLabels	bandStart	bandEnd	bandsOfInterestLatex	bandColors
    %        Delta	            Delta	                1	        4	    $\delta$	            [ 220  230  242 ]/255
    %        Theta	            Theta	                4	        8	    $\theta$	            [ 242  220  219 ]/255
    %
    %        Column Labels:
    %
    %               bandsOfInterest: Text describing band   
    %         bandsOfInterestLabels: Short text label for band
    %                     bandStart: Band start in Hertz (inclusive)
    %                       bandEnd: Band end in Hertz (inclusive)
    %          bandsOfInterestLatex: Short Latex labels used in figures.
    %                                Supports Greek letting
    %                    bandColors: RGB color used for identifying band 
    %                                range in figure.
    %
    % 
    % User Parameters
    %
    %    Artifact Detection
    %       artifactTh: artifact detection thresholds [deltaTh BetaTh]
    %   
    %    Run Flags/Options
    %       GENERATE_FILE_LIST = 1;
    %       TEST_REQUIRED_SIGNALS_ARE_PRESENT = 1;
    %       HANNING_ADJUSTMENT = 0;
    %       AVERAGE_ADJACENT_BANDS = 1;
    %       START_ANALYSIS_FOR_EACH_FILE  = 1;
    %       APPLY_ARTIFACT_REJECTION = 1;
    %       COMPUTE_TOTAL_POWER = 1;
    %       SUMMARIZE_BANDS = 1;
    %       OUTPUT_AVERAGE_SPECTROGRAMS = 1;
    %       PLOT_COMPREHENSIVE_SPECTRAL_SUMMARY = 1;
    %       PLOT_CALIBRATION_TEST = 0;
    %       PLOT_HYPNOGRAM = 0;
    %       PLOT_ARTIFACT_SUMMARY = 1;
    %       PLOT_SPECTRAL_SUMMARY = 1;
    %       PLOT_NREM_REM_SPECTRUM = 1;
    %       PLOT_BAND_ACTIVITY = 1;
    %       EXPORT_INDIVIDUAL_BAND_SUMMARY = 1;
    %       EXPORT_BAND_SUMMARY = 1;
    %       EXPORT_SPECTRAL_DETAILS = 1;
    %       EXPORT_TOTAL_POWER = 0;
    %       VALIDATION_PLOTS = 0;
    %       CREATE_POWER_POINT_SUMMARY = 1;   
    %
    %    Sleep Scoring Parameter (See Public Properties for additional details)
    %       scoreKey
    %
    %   Spectral Parameters (See Public Properties for additional details)
    %         spectralBinWidth
    %         noverlap
    %         windowFunctionIndex                          
    %         maxAnalysisFrequency = 25;   
    %         bandsOfInterest
    %         bandsOfInterestLabels
    %         bandsOfInterestLatex
    %         bandColors 
    %
    %   Coherence Parameters
    %         COHERENCE_COMPUTE_COHERENCE = 0;
    %         CREATE_COHERENCE_POWER_POINT_SUMMARY = 1;
    %         
    %   Figure Parameters
    %         figPos = [-1919, 1, 1920, 1004]: Figure placement during run
    %         map = jet(64): Default contour map
    %         freqDisplayMax = 25: Maximumum display frequency
    %         freqDisplayInc = 5;
    %         folderSeperator = '\';
    %         fontSize = 14;
    %         imageResolution = 100;
    %         artifactLineWidth = 1;
    %         plotLineWidth = 2.0;   
    %         
    %   Operation Parameters
    %         startFile = 1: Start analysis at file #
    %
    % Constructor:
    %      stcObj = SpectralTrainClass(stcStruct)
    %      stcObj = SpectralTrainClass(stcStruct, bandFn)
    %                 note: contructor with bandFn not tested yet
    % Public Methods:
    %      obj = computeSpectralTrain
    %
    % Static Methods:
    %      CreateSignalPPT (figs, pptFn, titleStr, imageResolution)
    %      CloseChildrenFigures
    %      bandStruct = LoadBandSettings(bandFn)
    %
    % User Configured/Seleted Output files
    % 
    %    Individual Subject Summaries
    %
    %        Detail Spectral Output (*.'signalLabel'.detail.spetral.xlsx):
    %            Epoch by epoch spectral results. Artifact detection
    %            information is included in this study.
    %
    %        Subject Band Summary (*.band.sum.xlsx):
    %            User selected band summaries for REM/NREM
    %    
    %        Subject Total Power (*total.power.xlsx):
    %            Total power across user defined spectral bands are
    %            presented
    %
    %        Subject Average Spectral Output (*.spectral.ppt)
    %            User selected spectral figures are saved to single power
    %            point file. Up to seven types of figures can be generated.
    %            The number of generated figure is dependent on the number
    %            of signals and type of summaries requested. See the
    %            parameter section for plotting flags.
    %    
    %    Summary Files
    %
    %         Run File List (*._FileList.xlsx):
    %            Auto generated file list. There is a flag to turn off the
    %            file generation, which allows for the generated file to be
    %            edited. 
    %    
    %         File List with Checks (*EdfHeaderLabelSummaryWithChecks.xlsx)
    %            Results of signal label check.  File provides a listing of
    %            the signal labels available for each subject. The checks
    %            were orignally develop and deployed as part of
    %            BlockEdfSummarizeFig. BlockEdfSummarizeFig is a simple GUI 
    %            for performing EDF and XML checks on large numbers of files. 
    % 
    %         Group Band Summary (*SpectralBandSummary.xlsx):
    %            Spectral band summary for all subjects.  The spectral bands 
    %            are user specified.
    %
    %         Group Spectral Summary (*GroupSpectralSummary.xlsx):
    %            Contains average NREM/REM spectra and artifact detection
    %            information for each subject.
    %
    %
    % Additional information can be found:
    %
    %   https://github.com/DennisDean/SpectralTrain/blob/master/README.md
    %
    %
    % Related websites:
    %
    %   National Sleep Research Resource:
    %      https://sleepdata.org/
    %
    %   Data Access and Visulation for Sleep Toolbox
    %      https://github.com/DennisDean/DAVS-Toolbox/blob/master/README.md
    %
    %   BlockEdfSummarizeFig:
    %      https://github.com/DennisDean/BlockEdfSummarizeFig/blob/master/README.md
    %
    %   Authors MATLAB File Exchange Contributions:
    %      http://www.mathworks.com/matlabcentral/fileexchange/?term=authorid:113409
    %
    %   Sleep@Partners Healthcare, Legacy EDF Tools website:
    %      http://sleep.partners.org/edf/
    %
    %
    % Acknowledgements:
    %
    %   dirr:      Used to create EDF/XMl file lists for processing
    %     http://www.mathworks.com/matlabcentral/fileexchange/8682-dirr--find-files-recursively-filtering-name--date-or-bytes-
    %
    %   moving:    Used to compute running band averages for the artifact detection computations.
    %     http://www.mathworks.com/matlabcentral/fileexchange/8251-moving-averages---moving-median-etc
    %
    %   panel:     Used to create a summary figure for review.
    %     http://www.mathworks.com/matlabcentral/fileexchange/20003-panel
    %
    %   saveppt2:  Used to create PPT summaries from MATLAB figures.
    %     http://www.mathworks.com/matlabcentral/fileexchange/19322-saveppt2
    %
    %
    % Funding:
    %  
    %   National Institute of Health Research Supplement to Promote 
    %   Diversity in Health-Related Research for Individuals in Postdoctoral 
    %   Training (NIH 3R01HL098433-02S1)
    %   
    %   Research agreement with Emma B. Bradley Hospital/Brown University, 
    %   Sleep for Science Sleep Research  Laboratory funded by the Periodic 
    %   Breathing Foundation. The Impact of Sleep and Breathing Dysregulation 
    %   Measured from Plethysmography on ADHD Outcomes in Pre-pubescent Children
    %    
    %   National Intitutes of Health - National Heart, Lung, and Blood Institute
    %   National Sleep Research Resource (HL114473)
    %
    %
    % Version: 0.1.12
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
    % Last updated: July 9, 2014 
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
    
    %---------------------------------------------------- Public Properties
    properties (Access = public)
        % Input Structure
        stcStruct                       % Spectral Train Class Structure  
        referenceMethodIndex = 1        % 1: Subtract single ref from each
                                        % 2: Reference for each single
                                        % 3: Substract reference signal
                                        %    average
        
        % Artifact Detection Threshold
        artifactTH = [2.5 2.0];
        
        % Analysis parameters
        GENERATE_FILE_LIST = 1;
        TEST_REQUIRED_SIGNALS_ARE_PRESENT = 1;
        HANNING_ADJUSTMENT = 0;
        AVERAGE_ADJACENT_BANDS = 1;
        START_ANALYSIS_FOR_EACH_FILE  = 1;
        APPLY_ARTIFACT_REJECTION = 1;
        COMPUTE_TOTAL_POWER = 1;
        SUMMARIZE_BANDS = 1;
        OUTPUT_AVERAGE_SPECTROGRAMS = 1;
        PLOT_COMPREHENSIVE_SPECTRAL_SUMMARY = 1;
        PLOT_CALIBRATION_TEST = 0;
        PLOT_HYPNOGRAM = 0;
        PLOT_ARTIFACT_SUMMARY = 1;
        PLOT_SPECTRAL_SUMMARY = 1;
        PLOT_NREM_REM_SPECTRUM = 1;
        PLOT_BAND_ACTIVITY = 1;
        EXPORT_INDIVIDUAL_BAND_SUMMARY = 1;
        EXPORT_BAND_SUMMARY = 1;
        EXPORT_SPECTRAL_DETAILS = 1;
        EXPORT_TOTAL_POWER = 0;
        VALIDATION_PLOTS = 0;
        CREATE_POWER_POINT_SUMMARY = 1;
        
        % Coherence parameters
        COHERENCE_COMPUTE_COHERENCE = 0;
        CREATE_COHERENCE_POWER_POINT_SUMMARY = 1;
        
        % Annotation Specification
        scoreKey = { ...
            { 'Awake' ,      0,  'W'}; ...
            { '1' ,          1,  '1'}; ...
            { '2' ,          2,  '2'}; ...
            { '3' ,          3,  '3'}; ...
            { '4' ,          4,  '4'}; ...
            { 'REM' ,        5,  'R'}; ...
            { 'X' ,          9,  'X'}; ...
            { 'X',          10,  'X'}; ...
        };
    
            
        % Spectral Parameters
        spectralBinWidth = 4;              % Spectral bin width in seconds
        noverlap = 10;                     % Number of bins
        windowFunctionIndex = 1;           % 1: 50% Taper, tukey window
                                           % 2: 90% Taper, tukey window
                                           % 3: Hanning window
                                           % 4: Barlett window                                   
        maxAnalysisFrequency = 25;         % Maximum frequency to save
        
        % Bands of Interest
        bandsOfInterest = { ...
            { 'Slow Oscillations',  [ 0.5,1.0]};...
            { 'Delta',              [ 1.0,4.0]};...
            { 'Theta',              [ 4.0,8.0]};...
            { 'Alpha',              [ 8.0,12.0]};...
            { 'Sigma',              [12.0,15.0]};...
            { 'Slow Sigma',         [12.0,13.5]};...
            { 'Fast Sigma',         [13.5,15.0]};...
            { 'Beta',               [15.0,20.0]}...
        };
        bandsOfInterestLabels = { ...
             'SlwOsc';...
             'Delta';...
             'Theta';...
             'Alpha';...
             'Sigma';...
             'SlwSig';...`
             'FstSig';...
             'Beta';... 
        };
        bandsOfInterestLatex = { ...
             '$1$';...
             '$\delta$';...
             '$\theta$';...
             '$\alpha$';...
             '$\sigma$';...
             '$\sigma_s$';...
             '$\sigma_f$';...
             '$\beta$';... 
        };
        bandColors = [...
            [ 198  217  241 ];...
            [ 220  230  242 ];...
            [ 242  220  219 ];...
            [ 235  241  222 ];...
            [ 230  224  236 ];...
            [ 219  238  244 ];...
            [ 253  234  218 ];...
            [ 230  224  236 ]...
        ]/255;   
        
        % Figure Position
        figPos = [-1919, 1, 1920, 1004];
        map = jet(64);
        freqDisplayMax = 25;
        freqDisplayInc = 5;
        folderSeperator = '\';
        fontSize = 14;
        imageResolution = 100;
        artifactLineWidth = 1;
        plotLineWidth = 2.0;   
        
        % Operation Parameters
        startFile = 1;
    end
    %------------------------------------------------ Dependent Properties
    properties (Dependent = true)
    end
    %--------------------------------------------------- Private Properties
    properties (Access = protected)
        % Input variables
        analysisDescription
        StudyEdfFileListResultsFn
        xlsFileContentCheckSummaryOut
        SR
        requiredSignals
        analysisSignals
        referenceSignals
        StudySpectrumSummary
        StudyBandSummary
        StudyEdfDir
        StudyEdfResultDir
        checkFile
        
        % Optional input
        bandFn = '';
        
        % Unit Strings
        microVoltStr = 'uV';
        milleVoltStr = 'mV';
        voltStr = 'V';
        analysisEegUnits = 'uV';

        % Artifact Detection
        numMovingAvg30secEpochs = 15;
        deltaBand = [0.6 4.6];
        betaBand = [40.0 60];
        swaBand = [0.5 5.5];
    end
    %------------------------------------------------------- Public Methods
    methods
        %------------------------------------------------------ Constructor
        function obj = SpectralTrainClass(varargin)
            if nargin == 1
                stcStruct = varargin{1};
            elseif nargin ==2
                stcStruct = varargin{1};
                bandFn = varargin{2};
            else
                fprintf('stcObj = SpectralTrainClass(stcStruct)\n');
                return
            end
            
            % Assign variables
            obj.analysisDescription = stcStruct.analysisDescription;
            obj.StudyEdfFileListResultsFn = ...
                stcStruct.StudyEdfFileListResultsFn;
            obj.xlsFileContentCheckSummaryOut = ...
                stcStruct.xlsFileContentCheckSummaryOut;
            obj.requiredSignals = stcStruct.requiredSignals;
            obj.analysisSignals = stcStruct.analysisSignals;
            obj.referenceSignals = stcStruct.referenceSignals;
            obj.StudySpectrumSummary = stcStruct.StudySpectrumSummary;
            obj.StudyBandSummary = stcStruct.StudyBandSummary;
            obj.StudyEdfDir = stcStruct.StudyEdfDir;
            obj.StudyEdfResultDir = stcStruct.StudyEdfResultDir;
            obj.checkFile = stcStruct.checkFile;
            obj.StudyEdfFileListResultsFn = ...
                stcStruct.StudyEdfFileListResultsFn;
            
            % Process band information
            if nargin == 2
                % Band Structure
                try
                    obj.bandFn = bandFn; 
                    bandStruct = obj.LoadBandSettings(bandFn);
                    obj.bandsOfInterest = bandStruct.bandsOfInterest;
                    obj.bandsOfInterestLabels = bandStruct.bandsOfInterestLabels;
                    obj.bandsOfInterestLatex = bandStruct.bandsOfInterestLatex;
                    obj.bandColors = bandStruct.bandColors;
                catch
                    % Let user know, settings could not beloaded
                    errMsg = 'Could not load and assign band settings';
                    error(errMsg);
                end
            end
        end
        %--------------------------------------------- computeSpectralTrain
        function obj = computeSpectralTrain(varargin)
            
            % Proces input
            obj = varargin{1};

            % Analysis Flags
            GENERATE_FILE_LIST = obj.GENERATE_FILE_LIST;
            TEST_REQUIRED_SIGNALS_ARE_PRESENT = ...
                obj.TEST_REQUIRED_SIGNALS_ARE_PRESENT;
            HANNING_ADJUSTMENT = obj.HANNING_ADJUSTMENT;
            AVERAGE_ADJACENT_BANDS = obj.AVERAGE_ADJACENT_BANDS;
            START_ANALYSIS_FOR_EACH_FILE  = ...
                obj.START_ANALYSIS_FOR_EACH_FILE;
            APPLY_ARTIFACT_REJECTION = obj.APPLY_ARTIFACT_REJECTION;
            COMPUTE_TOTAL_POWER = obj.COMPUTE_TOTAL_POWER;
            SUMMARIZE_BANDS = obj.SUMMARIZE_BANDS;
            OUTPUT_AVERAGE_SPECTROGRAMS = ...
                obj.OUTPUT_AVERAGE_SPECTROGRAMS;
            PLOT_CALIBRATION_TEST = obj.PLOT_CALIBRATION_TEST;
            PLOT_HYPNOGRAM = obj.PLOT_HYPNOGRAM;
            PLOT_ARTIFACT_SUMMARY = obj.PLOT_ARTIFACT_SUMMARY;
            PLOT_SPECTRAL_SUMMARY = obj.PLOT_SPECTRAL_SUMMARY;
            PLOT_NREM_REM_SPECTRUM = obj.PLOT_NREM_REM_SPECTRUM;
            PLOT_BAND_ACTIVITY = obj.PLOT_BAND_ACTIVITY;
            EXPORT_BAND_SUMMARY = obj.EXPORT_BAND_SUMMARY;
            EXPORT_SPECTRAL_DETAILS = obj.EXPORT_SPECTRAL_DETAILS;
            VALIDATION_PLOTS = obj.VALIDATION_PLOTS;
            COHERENCE_COMPUTE_COHERENCE = obj.COHERENCE_COMPUTE_COHERENCE;
            
            % Signal Unit's and conversion parameters
            microVoltStr = obj.microVoltStr;
            milleVoltStr = obj.milleVoltStr;
            voltStr = obj.voltStr;
            analysisEegUnits = obj.analysisEegUnits;
            powerUnits = sprintf('%s^2', analysisEegUnits);
            powerDensityUnits = sprintf('%s^2/Hz', analysisEegUnits);
            logPowerUnits = sprintf('log10(%s^2)', analysisEegUnits);
            logPowerDensityUnits = sprintf('log10(%s^2/Hz)', analysisEegUnits);
            CONVERT_UNITS = 1;

            % Frequency Spectrum Value
            spectralBinWidth = obj.spectralBinWidth;
            maxAnalysisFrequency = obj.maxAnalysisFrequency;
            binLabel = sprintf('binWidth = %.0f sec',spectralBinWidth);

            % Artifact Detection Parameters
            numMovingAvg30secEpochs = obj.numMovingAvg30secEpochs;
            artifactTH = obj.artifactTH;
            deltaBand = obj.deltaBand;
            betaBand = obj.betaBand;
            swaBand = obj.swaBand;

            % Output Paramters
            map = obj.map;
            freqDisplayMax = obj.freqDisplayMax;
            freqDisplayInc = obj.freqDisplayInc;
            figPos = obj.figPos;
            folderSeperator = obj.folderSeperator;
            fontSize = obj.fontSize;
            imageResolution = obj.imageResolution;
            artifactLineWidth = obj.artifactLineWidth;
            plotLineWidth = obj.plotLineWidth;

            % Annotation Specification
            scoreKey = obj.scoreKey;
            
            % Bands of Interest
            bandsOfInterest = obj.bandsOfInterest;
            bandsOfInterestLabels = obj.bandsOfInterestLabels;
            bandsOfInterestLatex = obj.bandsOfInterestLatex;
            bandColors = obj.bandColors;    
            numBandColors = size(bandColors, 1);
            numBandsOfInterest = length(bandsOfInterest);

            %% Analysis input 

            % Get analysis variabiles
            analysisDescription = obj.analysisDescription;
            StudyEdfFileListResultsFn = obj.StudyEdfFileListResultsFn;
            xlsFileContentCheckSummaryOut = obj.xlsFileContentCheckSummaryOut;
            SR = obj.SR;
            requiredSignals = obj.requiredSignals;
            analysisSignals = obj.analysisSignals;
            referenceSignals = obj.referenceSignals;
            StudySpectrumSummary = obj.StudySpectrumSummary;
            StudyBandSummary = obj.StudyBandSummary;
            StudyEdfDir = obj.StudyEdfDir;
            StudyEdfResultDir = obj.StudyEdfResultDir;
            checkFile = obj.checkFile;
            StudyEdfFileListResultsFn = obj.StudyEdfFileListResultsFn;
            
            % Echo staus to console
            fprintf('%s\n\n',analysisDescription);
            
            %% Generate File list
            edfFileList = {};
            xmlFileList = {};
            edfFolderList = {};
            xmlFolderList = {};
            if GENERATE_FILE_LIST == 1
                % Echo status to console
                fprintf('Getting matched EDF/XML files\n');

                % Write excel output with no arguments 
                GetMatchedSleepFiles(StudyEdfDir, checkFile);
                
                % Save file location information
                matchedCell = GetMatchedSleepFiles(StudyEdfDir, checkFile);
                matchedCell = matchedCell{1};
                edfFolderList = matchedCell(2:end, 6);
                xmlFolderList = matchedCell(2:end, 11);
                edfFileList = matchedCell(2:end, 2);
                xmlFileList = matchedCell(2:end, 7);
            end

            %% Test files can be opened and signals are present
            checkValues = [];
            if TEST_REQUIRED_SIGNALS_ARE_PRESENT == 1
                % Echo status to console
                fprintf('Checking EDFs for required signals\n');

                % Write excel output with no arguments
                % Create class
                tempXlsFileContentCheckSummaryOut = ...
                    strcat(StudyEdfResultDir, xlsFileContentCheckSummaryOut);
                besObj = BlockEdfSummarizeClass(checkFile, tempXlsFileContentCheckSummaryOut);
                besObj = besObj.summarizeSignalLabels(requiredSignals);
                
                % Get check results
                checkValues = besObj.checkValues;
                
                % Echo status to console
                if or(isempty(checkValues), length(edfFileList)>sum(checkValues))
                    checkIndexes = find(checkValues == 0)
                    errMsg = sprintf('Signal Check error: Check signal labels\n');
                    warning(errMsg);
                    return
                end
            end        
            %% Compute Coherence for each file
            if START_ANALYSIS_FOR_EACH_FILE == 1
                % Echo status to console
                fprintf('Loading file information and setting up analysis variables\n');

                % Operation Flags
                COHERENCE_COMPUTE_SPECTRAL = 1;
                COHERENCE_COMPUTE_ARTIFACT_DETECTION = 1;
                ECHO_STATUS_TO_CONSOLE = 1;

                % Coherence visualization
                freqDisplayMax = maxAnalysisFrequency;
                freqDisplayInc = 5;
                numColors = 256;

                % Load edf infromation from xls file
                fnPath = strcat(StudyEdfResultDir, xlsFileContentCheckSummaryOut);
                [num txt raw] = xlsread(fnPath);

                % Assume Check file is at end
                fnIndex = 2;
                checkIndex = size(raw, 2);
                edfFNames = txt(2:end, fnIndex);  
                check = num(:, checkIndex);
                numFiles = length(edfFNames);
                signalLabels = requiredSignals;
                numAnalysisSignals = length(analysisSignals);
                epochWidth = 30;

                % Load annotaion information from xls file
                [num txt raw] = xlsread(checkFile);
                xmlFnIndex = 7;
                xmlPathIndex =11;
                xmlFNames = txt(2:end, xmlFnIndex);
                xmlPath = txt(2:end, xmlPathIndex);


                % Initialize Summary Varaibles
                figCell = {};
                bandSubjectCell = cell(numFiles,14);
                bandSubjectCell = {};
                spectrumSubjectCell = {};
                spectrumVerticalLabels = {};

                % Analyze selected subjects
                processStart = obj.startFile;  
                % numFiles = 2;
                processFiles = numFiles;
                
                % Calculate the number of signals to analyze
                processNsignals = numAnalysisSignals;
                for f = processStart:processFiles
                    
                    % Check if signals are present
                    if isempty(checkValues)
                        continue;
                    elseif checkValues(f) == 0
                        fprintf('\t%.0f. Skipping data from: %s, %s\n', f, edfFNames{f},...
                            datestr(now));
                        continue;
                    end
                    
                    %% Load data
                    % Define test file
                    edfFn = strcat(edfFolderList{f}, folderSeperator, edfFileList{f});
                    figs = [];

                    % Echo status to console
                    fprintf('%.0f. Loading data from: %s, %s\n', f, edfFNames{f},...
                            datestr(now));

                    % Load data
                    edfObj = BlockEdfLoadClass(edfFn, signalLabels);
                    edfObj.numCompToLoad = 3;      % Don't return object
                    edfObj.SWAP_MIN_MAX = 1;       % Fix SOF data
                    edfObj = edfObj.blockEdfLoad;  % Load data

                    % Reference signal
                    signalCell = edfObj.edf.signalCell;
                    if ~isempty(referenceSignals)
                        % Approaches are written; but haven't been tested
                        if obj.referenceMethodIndex == 1
                            % Substract single reference from each
                            numRefSignals = length(obj.referenceSignals);
                            numAnalSignals = length(obj.analysisSignals);
                            ref = signalCell{numAnalSignals+1};
                            for s = 1:numAnalSignals
                                signalCell{s} = signalCell{s}-ref;
                            end
                        elseif obj.referenceMethodIndex == 2
                            % Subtract specified reference from each signal
                            numAnalSignals = length(obj.analysisSignals);
                            ref = signalCell(numAnalSignals+1:end);
                            for s = 1:numAnalSignals
                                signalCell{s} = signalCell{s}-ref{s};
                            end 
                        elseif obj.referenceMethodIndex == 3
                            % Substract reference signal average
                            numAnalSignals = length(obj.analysisSignals);
                            numRefSignals = length(obj.referenceSignals);
                            ref = mean(cell2mat(...
                                signalCell(numAnalSignals+1:end)),2);
                            for s = 1:numAnalSignals
                                signalCell{s} = signalCell{s}-ref;
                            end 
                        else
                            % Substract single reference from each
                            numRefSignals = length(obj.referenceSignals);
                            numAnalSignals = length(obj.analysisSignals);
                            ref = signalCell{numAnalSignals+1};
                            for s = 1:numAnalSignals
                                signalCell{s} = signalCell{s}-ref;
                            end
                        end
                    end

                    % Check signal dimensions are consistant
                    physical_dimension = edfObj.physical_dimension;
                    physical_dimension = unique(physical_dimension);
                    if length(physical_dimension) >1
                        warnMsg = 'Physical Dimension is not constant across channels';
                        warning(warnMsg)
                        return
                    end
                    eegEdfUnits = physical_dimension{1};

                    % Convert units to microVolts
                    if CONVERT_UNITS == 0;
                        % No scaling required
                        fprintf('\tUnit conversion not requested, %s\n', eegEdfUnits);
                    elseif strcmp(analysisEegUnits,eegEdfUnits) == 1
                        fprintf('\tUnit conversion not necessary, %s\n', eegEdfUnits);
                    elseif strcmp(analysisEegUnits, microVoltStr)
                        % Need to convert to milli volts
                        mV_to_uV_F = @(x)x.*1000;
                        signalCell = cellfun(mV_to_uV_F, signalCell, ...
                            'UniformOutput', 0);
                        fprintf('\tUnit conversion from %s to %s\n', ...
                            eegEdfUnits, analysisEegUnits);
                    elseif strcmp(analysisEegUnits, milleVoltStr)
                        % Need to scale signals to microVolt
                        uV_to_mV_F = @(x)x*1000;
                        signalCell = cellfun(uV_to_mV_F, signalCell, ...
                            'UniformOutput', 0);
                        fprintf('\tUnit conversion from %s to %s\n', ...
                            eegEdfUnits, analysisEegUnits);
                    elseif strcmp(analysisEegUnits, voltStr)
                        % Need to scale signals to volt
                        uV_to_V_F = @(x)x./1000./1000;
                        signalCell = cellfun(uV_to_V_F, signalCell, ...
                            'UniformOutput', 0);
                        fprintf('\tUnit conversion from %s to %s\n', ...
                            eegEdfUnits, analysisEegUnits);                
                    else
                        % Units are not supported
                        warnMsg = sprintf('Signal units are not supported: %s',...
                            eegEdfUnits);
                        warning(warnMsg)
                        return
                    end

                    % Get signal information
                    num30SecEpochs = edfObj.num30SecEpochs;
                    samplingRate = unique(edfObj.sample_rate);
                    numSigPts = length(signalCell{1});
                    numPtsPer30secEpoch = samplingRate*epochWidth;
                    returnedNum30SecEpochs = edfObj.returnedNum30SecEpochs;

                    % Check that signals are consitantly sampled
                    if length(samplingRate)> 1
                        warnMsg = 'Sampling rate is not constant across channels';
                        warning(warnMsg)
                        return
                    end
                    SR = samplingRate;

                    % Spectral Analysis Parameters
                    if obj.windowFunctionIndex == 1
                        windowFunctionLabel = '50% Taper - tukeywin';
                        spectralWindowFun = tukeywin(spectralBinWidth*SR, 0.50);
                    elseif obj.windowFunctionIndex == 2
                        windowFunctionLabel = '90% Taper - tukeywin';
                        spectralWindowFun = hanning(spectralBinWidth*SR);
                    elseif obj.windowFunctionIndex == 3
                        windowFunctionLabel = 'hanning';
                        spectralWindowFun = hanning(spectralBinWidth*SR);
                    elseif obj.windowFunctionIndex == 3
                        windowFunctionLabel = 'barlett';
                        spectralWindowFun = bartlett(spectralBinWidth*SR);
                    else
                        % Choose default setting
                        windowFunctionLabel = '50% Taper - tukeywin';
                        spectralWindowFun = tukeywin(spectralBinWidth*SR, 0.50);
                    end
                    noverlap = obj.noverlap;

                    
                    %% Load Annotations
                    xmlFn = strcat(xmlPath{f}, folderSeperator, xmlFNames{f});
                    xmlFn = strcat(xmlFolderList{f}, folderSeperator, xmlFileList{f});
                    
                    lcaObj = loadCompumedicsAnnotationsClass(xmlFn);
                    lcaObj.scoreKey = scoreKey;
                    lcaObj.GET_SCORED_EVENTS = 0;
                    
                    % Prepare for load failure
                    errMsg = sprintf('Could not load XML file:%s\n', ...
                        xmlFNames{f});
                    try
                        lcaObj = lcaObj.loadFile;   
                    catch
                        % write message to console and skip subject
                        fprintf('%s',errMsg);
                        continue
                    end
                    numericHypnogram = lcaObj.numericHypnogram;
                    characterHypnogram = lcaObj.characterHypnogram;
                    wakeMask = numericHypnogram==0;
                    sleepMask = and(numericHypnogram>=1, numericHypnogram<=5);
                    nremMask = and(numericHypnogram>=1, numericHypnogram<=4);
                    remMask = numericHypnogram==5;

                    % Create hypnogram
                    if PLOT_HYPNOGRAM == 14
                        lcaObj.position = figPos;
                        lcaObj = lcaObj.plotHypnogram;
                        figs = [figs;lcaObj.figId];
                    end

                    %% Compute spectrogram
                    if COHERENCE_COMPUTE_SPECTRAL == 1
                        if VALIDATION_PLOTS == 1
                            getDataF = @(x)signalCell{x};
                            data = cell2mat(arrayfun(getDataF, [1:processNsignals], ...
                                'UniformOutput', 0));
                            fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                            set(fid, 'Position', figPos);
                            plot(([1:SR]')*ones(1,processNsignals)/SR, data(1:SR,:), ...
                                'LineWidth',2) ;
                            box('on');
                            title(sprintf('Validation Data - %s',edfFNames{f}), ...
                                'Interpreter', 'none', 'FontWeight','bold', ...
                                'FontSize',14);
                            xlabel('Time (sec)','FontWeight','bold','FontSize',14);
                            ylabel(sprintf('Amplitude (%s)', analysisEegUnits), ...
                                'FontWeight','bold','FontSize',14);

                            % Format Axis
                            set(gca, 'LineWidth',plotLineWidth);
                            set(gca, 'Layer','top');
                            set(gca, 'FontWeight','bold');
                            set(gca, 'FontSize',fontSize);
                        end           

                        % Zero Signal by 30 second epochs
                        dataAvg = reshape(signalCell{1}(1:numPtsPer30secEpoch*returnedNum30SecEpochs),...
                            returnedNum30SecEpochs, numPtsPer30secEpoch);
                        dataAvg =reshape((mean(dataAvg,2)*ones(1, numPtsPer30secEpoch))', ...
                            returnedNum30SecEpochs*numPtsPer30secEpoch,1);
                        dataZeroed = ...
                            signalCell{1}(1:numPtsPer30secEpoch*returnedNum30SecEpochs)...
                            -dataAvg;...            

                        % Compute overall spectrum
                        data = reshape(dataZeroed, 1, ...
                            numPtsPer30secEpoch, returnedNum30SecEpochs);
                        [pxx,freq,pxxc] = ...
                            pwelch(data,spectralWindowFun,noverlap,spectralBinWidth*SR,SR);

                        % Set frequency display 
                        fIdx = find(freq<= freqDisplayMax);

                        % Smooth results
                        if AVERAGE_ADJACENT_BANDS == 1
                            % Recompute frequency
                            freq = freq(1:2:end);
                            fIdx = find(freq<= freqDisplayMax);
                        end

                        % Compute artifact detection boundaries
                        % Check: f([deltaStart, deltaEnd, betaStart, betaEnd])
                        deltaStart = find(deltaBand(1)<= freq);
                        deltaStart = deltaStart(1);
                        deltaEnd = find(deltaBand(2) > freq);
                        deltaEnd = deltaEnd(end);
                        betaStart = find(betaBand(1)<= freq);
                        betaStart = betaStart(1);
                        betaEnd = find(betaBand(2) > freq);
                        betaEnd = betaEnd(end);
                        swaStart = find(swaBand(1)<= freq);
                        swaStart = swaStart(1);
                        swaEnd = find(swaBand(2) > freq);
                        swaEnd = swaEnd(end);

                        % Compute pwelch for multiple signals
                        fprintf('\tBegining spectral analysis\n');
                        pxxCell = cell(processNsignals, 1);
                        pxxCell30 = cell(processNsignals, 1);  % 30 second summary
                        artifactCell = cell(processNsignals, 1);
                        bandSummary = [];
                        for s = 1:processNsignals
                            % Echo status to console
                            fprintf('\t\tComputing spectrogram for %s\n',signalLabels{s});

                            % Zero Signal by 30 second epochs
                            dataAvg = reshape(signalCell{s}(1:numPtsPer30secEpoch*returnedNum30SecEpochs),...
                                returnedNum30SecEpochs, numPtsPer30secEpoch);
                            dataAvg =reshape((mean(dataAvg,2)*ones(1, numPtsPer30secEpoch))', ...
                                returnedNum30SecEpochs*numPtsPer30secEpoch,1);
                            dataZeroed = ...
                                signalCell{s}(1:numPtsPer30secEpoch*returnedNum30SecEpochs)...
                                -dataAvg;...
                            dataZeroed = ...
                                signalCell{s}(1:numPtsPer30secEpoch*returnedNum30SecEpochs)...
                                -0;...
                                
                            % Compute spectrogram with pwelch method
                            signalData = reshape(dataZeroed, 1, ...
                                numPtsPer30secEpoch, returnedNum30SecEpochs);
                            pwelchF = @(x)pwelchWrap((signalData(:,:,x)),...
                                spectralWindowFun,noverlap,spectralBinWidth*SR,SR);
                            pxxCell{s} = cell2mat(arrayfun(pwelchF, ...
                                [1:returnedNum30SecEpochs],'UniformOutput', 0));

                            % Adjust energy
                            if HANNING_ADJUSTMENT == 1
                                pxxCell{s} = pxxCell{s}*sqrt(8/3); 
                            end

                            % Smooth results
                            if AVERAGE_ADJACENT_BANDS == 1
                                % Average adjacent cells and remove zero
                                pxx = pxxCell{s}; 
                                pxx = [pxx(1,:); (pxx(2:2:end,:)+pxx(3:2:end,:))/2];
                                pxxCell{s} = pxx;
                            end

                            % Original computation from Leila
                            % SWA in power density units
                            swaSpectrum = (...
                                (pxxCell{s}(swaStart:swaEnd, :)));

                            % Compute artifact detection
                            deltaSpectrum = sum(pxxCell{s}(deltaStart:deltaEnd,:),1);
                            deltaMovingRatio = deltaSpectrum./moving(deltaSpectrum, numMovingAvg30secEpochs)';
                            betaSpectrum = sum(pxxCell{s}(betaStart:betaEnd,:));
                            betaMovingRatio = betaSpectrum./moving(betaSpectrum, numMovingAvg30secEpochs)';

                            % Identify Artifacts
                            deltaArtifactMask = deltaMovingRatio > artifactTH(1);
                            deltaArtifactIndex = find(deltaArtifactMask);
                            betaArtifactMask = betaMovingRatio > artifactTH(2);
                            betaArtifactIndex = find(betaArtifactMask);

                            % Zero out artifact detection
                            if APPLY_ARTIFACT_REJECTION == 0
                                deltaArtifactMask(:) = 0;
                                deltaArtifactIndex = [];
                                betaArtifactMask(:) = 0;
                                betaArtifactIndex = [];
                            end

                            % Save artifact detection
                            artifact.deltaSpectrum = deltaSpectrum;
                            artifact.deltaMovingRatio = deltaMovingRatio;
                            artifact.deltaArtifactMask = deltaArtifactMask;
                            artifact.deltaArtifactIndex = deltaArtifactIndex;
                            artifact.numDeltaArtifacts = length(deltaArtifactIndex);
                            artifact.betaSpectrum = betaSpectrum;
                            artifact.betaMovingRatio = betaMovingRatio;
                            artifact.betaArtifactMask = betaArtifactMask;
                            artifact.betaArtifactIndex = betaArtifactIndex;
                            artifact.numBetaArtifacts = length(betaArtifactIndex);
                            artifact.swaSpectrum = swaSpectrum;
                            artifact.artifactMask = ...
                                or(deltaArtifactMask, betaArtifactMask)';
                            artifactCell{s} = artifact;
                        end

                        if COMPUTE_TOTAL_POWER == 1
                            % Echo status to console
                            fprintf('\tSummarizing Total Power for %s\n',signalLabels{s});         

                            % Create Total Power Summary
                            totalSummary = cell(processNsignals+3, 1+6*3);
                            for s = 1:processNsignals
                                % Echo status to console
                                fprintf('\t\tProcessing: %s\n',signalLabels{s});       

                                % Get Frequency Analysis Range
                                analFreqIndex = find(maxAnalysisFrequency >= freq);
                                analFreqVal = freq(analFreqIndex);

                                % Crop data
                                pxx = pxxCell{s};
                                pxx = pxx(analFreqIndex,:);

                                if PLOT_CALIBRATION_TEST == 1
                                    % Create figure
                                    fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                                    figs = [figs;fid];
                                    set(fid, 'Position', figPos);

                                    % Plot Power Density
                                    subplot(2,1,1,'LineWidth',2,'FontWeight','bold',...
                                        'FontSize',14)
                                    plot(analFreqVal, mean(pxx(:, sleepMask), 2), ...
                                        'LineWidth',2);
                                    box('on');
                                    titleStr = sprintf('%s - %s - pwelch(%.0f) - Hanning window',...
                                        edfFNames{f}, signalLabels{s}, spectralBinWidth);
                                    title(titleStr, 'Interpreter', 'None', ...
                                        'FontWeight','bold', 'FontSize',14);
                                    ylabel(sprintf('Power Density (%s)',powerDensityUnits), ...
                                        'FontWeight','bold','FontSize',14);

                                    % Format Axis
                                    set(gca, 'LineWidth',plotLineWidth);
                                    set(gca, 'Layer','top');
                                    set(gca, 'FontWeight','bold');
                                    set(gca, 'FontSize',fontSize);

                                    % Plot Power
                                    P = pxx/spectralBinWidth;
                                    subplot(2,1,2)
                                    plot(analFreqVal, mean(P(:, sleepMask), 2), ...
                                        'LineWidth',2);
                                    box('on');
                                    ylabel(sprintf('Power (%s)', powerUnits), ...
                                        'FontWeight','bold','FontSize',14);
                                    xlabel('Frequency (Hz)', 'FontWeight','bold',...
                                        'FontSize',14); 

                                    % Format Axis
                                    set(gca, 'LineWidth',plotLineWidth);
                                    set(gca, 'Layer','top');
                                    set(gca, 'FontWeight','bold');
                                    set(gca, 'FontSize',fontSize);
                                end

                                % Compute Power During Sleep
                                P = pxx/spectralBinWidth;
                                PtotalSleep = mean(sum(P(:,sleepMask),1));
                                PtotalZeroTopSleep = PtotalSleep*2;
                                PtotalDensitySleep = PtotalSleep*spectralBinWidth;

                                % Compute Power During NREM
                                PtotalNREM = mean(sum(P(:,nremMask),1));
                                PtotalZeroTopNREM = PtotalNREM*2;
                                PtotalDensityNREM = PtotalNREM*spectralBinWidth;                    

                                % Compute Power During REM
                                PtotalREM = mean(sum(P(:,remMask),1));
                                PtotalZeroTopREM = PtotalREM*2;
                                PtotalDensityREM = PtotalREM*spectralBinWidth;                       

                                % Record values
                                totalSummary (3+s,2:end) = ...
                                    num2cell(...
                                       [PtotalZeroTopSleep,         PtotalSleep,         PtotalDensitySleep, ...
                                        log10(PtotalZeroTopSleep),  log10(PtotalSleep),  log10(PtotalDensitySleep),...
                                        PtotalZeroTopNREM,          PtotalNREM,          PtotalDensityNREM, ...
                                        log10(PtotalZeroTopNREM),   log10(PtotalNREM),   log10(PtotalDensityNREM),...
                                        PtotalZeroTopREM,           PtotalREM,           PtotalDensityREM, ...
                                        log10(PtotalZeroTopREM),    log10(PtotalREM),    log10(PtotalDensityREM),...
                                       ]);
                            end

                            % Add labels to table               
                            totalSummary(1,:) = ...
                                {edfFNames{f},...
                                 'Sleep',        '',        '',...
                                 '',             '',        '', ...
                                 'NREM',         '',        '',...
                                 '',             '',        '', ...                     
                                 'REM',          '',        '',...
                                 '',             '',        '', ...                     
                                 };
                             totalSummary(2,:) = ...
                                {binLabel,...
                                 'Power (zero top)',        'Power',        'Power Density',...
                                 'log10(Power) (zero top)', 'log10(Power)', 'log10(Power Density)', ...
                                 'Power (zero top)',        'Power',        'Power Density',...
                                 'log10(Power) (zero top)', 'log10(Power)', 'log10(Power Density)', ...                     
                                 'Power (zero top)',        'Power',        'Power Density',...
                                 'log10(Power) (zero top)', 'log10(Power)', 'log10(Power Density)', ...                     
                                 };
                            totalSummary(3,:) = ...
                                {'Signal',...
                                 powerUnits,    powerUnits,    powerDensityUnits, ...
                                 logPowerUnits, logPowerUnits, logPowerDensityUnits, ...
                                 powerUnits,    powerUnits,    powerDensityUnits, ...
                                 logPowerUnits, logPowerUnits, logPowerDensityUnits, ...                     
                                 powerUnits,    powerUnits,    powerDensityUnits, ...
                                 logPowerUnits, logPowerUnits, logPowerDensityUnits, ...                    
                                 };
                            totalSummary(4:end, 1) = analysisSignals';

                            % Write Total Power Summary
                            
                            if obj.EXPORT_TOTAL_POWER == 1
                                totalPowerFn = strcat...
                                    (StudyEdfResultDir, edfFNames{f},'total.power.xlsx');
                                xlswrite(totalPowerFn, totalSummary);

                                % Echo Status to console
                                fprintf('\t\tTotal power written to: %s\n',totalPowerFn);  
                            end
                         end


                        % Export Excel File of Spectral File
                        if EXPORT_SPECTRAL_DETAILS == 1
                            % Echo status to console
                            fprintf('\tExporting detail spectral analysis results\n');

                            % Process each signals
                            for s = 1:processNsignals
                                %Create data string
                                epochId = [1:1:returnedNum30SecEpochs]';
                                pxx = pxxCell{s}';
                                spectralOut = [epochId, epochId, numericHypnogram, ...
                                    pxx(:,fIdx), ...
                                    pxx(:,fIdx)/spectralBinWidth,...
                                    sleepMask, nremMask, remMask,...
                                    artifactCell{s}.deltaArtifactMask', ...
                                    artifactCell{s}.betaArtifactMask', ...
                                    artifactCell{s}.artifactMask];
                                spectralOut = num2cell(spectralOut);
                                spectralOut(:,2) = cellstr(characterHypnogram);

                                % Create Frequency
                                createLabelF  = @(x)sprintf('%.2f Hz',freq(x)); 
                                labelCell = arrayfun(createLabelF, fIdx', ...
                                    'UniformOutput', 0);
                                labelCell = ['epochId', 'charHypno', 'numHypno',...
                                  labelCell(:)', labelCell(:)' ...
                                  'sleepMask', 'nremMask', 'remMask', ...
                                  'deltaArtifactMask', 'betaArtifactMask', 'artifactMask'];
                                labelCell1 = cell(1,length(labelCell));
                                labelCell1(1) = {binLabel};
                                labelCell1(4+length(fIdx)) = {sprintf('Power (%s)', powerUnits)}; 
                                labelCell1(4) = ...
                                    {sprintf('Power Density (%s)', powerDensityUnits)}; 
                                spectralOut = [labelCell1; labelCell; spectralOut];

                                % Save summary
                                specDetailXlsFn = sprintf('%s.%s.detail.spectral.xlsx',...
                                     edfFNames{f}, signalLabels{s});
                                specDetailXlsFn = ...
                                    strcat(StudyEdfResultDir, specDetailXlsFn);
                                xlswrite(specDetailXlsFn, spectralOut);
                                fprintf('\t\t%.0f. %s\n', s, specDetailXlsFn);
                            end
                        end

                        % Summarize Bands
                        if SUMMARIZE_BANDS == 1
                            % Echo status to console
                            fprintf('\tExporting detail spectral analysis results\n');

                            % Get Band Information
                            bandSummary = [];  % Band line entry
                            slab = {};   % Signal summary
                            bLab = {};   % band summary
                            bandSumCell = cell(processNsignals*numBandsOfInterest+2,14+2);
                            resultLabels = cell(processNsignals*numBandsOfInterest,2);

                            % Process each signal
                            for s = 1:processNsignals           
                                for boi = 1:numBandsOfInterest
                                    % Band Info
                                    band = bandsOfInterest{boi}{2};
                                    bandLabel = bandsOfInterest{boi}{1};

                                    % Get spectrum information   
                                    % Compute band power
                                    artifactMask = artifactCell{s}.artifactMask;
                                    zeroMask = or(wakeMask, artifactMask);
                                    bandMask = and(band(1) <= freq, freq <= band(2));
                                    sleepIndex = and(~artifactMask, sleepMask);
                                    bandSpectrumSleep = mean(sum(pxxCell{s}(bandMask, sleepIndex),1));
                                    bandSpectrumSleep = mean(sum(pxxCell{s}(bandMask, sleepIndex),1));
                                    bandSpectrumSleepLog = log10(bandSpectrumSleep);
                                    bandSpectrumSleepLog = mean(log10(mean(pxxCell{s}(bandMask, sleepIndex),2)));
                                    bandSpectrumSleep = 10.^(bandSpectrumSleepLog);
                                    
                                    nremIndex = and(~artifactMask, nremMask);                    
                                    bandSpectrumNrem = mean(sum(pxxCell{s}(bandMask, nremIndex),1));
                                    bandSpectrumNremLog = log10(bandSpectrumNrem);
                                    bandSpectrumNremLog = mean(log10(mean(pxxCell{s}(bandMask, nremIndex),2)));
                                    bandSpectrumNrem = 10.^(bandSpectrumNremLog);                                    %bandSpectrumNrem = mean(mean(pxxCell{s}(bandMask, nremIndex),1));
                                    
                                    remIndex = and(~artifactMask, remMask);
                                    bandSpectrumRem = mean(sum(pxxCell{s}(bandMask, remIndex),1));
                                    bandSpectrumRemLog = log10(bandSpectrumRem);
                                    bandSpectrumRemLog = mean(log10(mean(pxxCell{s}(bandMask, remIndex),2)));
                                    bandSpectrumRem = 10.^(bandSpectrumRemLog);
                                    
                                    % Record Artifact Summary
                                    sleepArtifactCount = sum(and(artifactMask, sleepMask));
                                    nremArtifactCount = sum(and(artifactMask, nremMask));
                                    remArtifactCount = sum(and(artifactMask, remMask));
                                    sleepEpochCount  = sum(sleepMask);
                                    nremEpochCount = sum(nremMask);
                                    remEpochCount = sum(remMask);

                                    % Record Band Summary
                                    bandSummary = [bandSummary; [ ...
                                        band(1),             band(2)...
                                        bandSpectrumSleep,   bandSpectrumSleepLog ...
                                        bandSpectrumNrem,    bandSpectrumNremLog ...
                                        bandSpectrumRem,     bandSpectrumRemLog ...
                                        sleepArtifactCount,  sleepEpochCount ...
                                        nremArtifactCount,   nremEpochCount ...
                                        remArtifactCount,    remEpochCount ]];
                                    slab = [slab; signalLabels{s}];
                                end 
                                bLab = [bLab; bandsOfInterestLabels];
                            end


                            % Create Band Summary        
                            bandSumCell(1,:) = ...
                                {edfFNames{f}, binLabel, 'Band Start',...
                                 'Band End', 'Sleep', 'Log(Sleep)', ...
                                 'NREM', 'Log(NREM)', 'REM', 'Log(REM)',...
                                 '', '', ...
                                 '', '', ...
                                 '', ''};
                            bandSumCell(2,:) = ...
                                {'Signal', 'Band', '(Hz)',...
                                 '(Hz)', powerUnits, logPowerUnits, ...
                                 powerUnits, logPowerUnits, powerUnits, logPowerUnits,...
                                 '# Art(Slp)', '# Slp Epochs', ...
                                 '# Art(NREM)', '# NREM Epochs', ...
                                 '# Art(REM)', '# REM Epochs'};                 
                            bandSumCell (3:end,1) = slab;
                            bandSumCell (3:end,2) = bLab;
                            bandSumCell (3:end,3:end) = num2cell(bandSummary);

                            if obj.EXPORT_INDIVIDUAL_BAND_SUMMARY == 1
                                % Write Band Summary
                                bandSumFn = strcat(edfFNames{f},'.band.sum.xlsx');
                                bandSumPathFn = strcat(StudyEdfResultDir, bandSumFn);
                                xlswrite(bandSumPathFn , bandSumCell);

                                % Echo status to console
                                fprintf('\tBand summary written to: %s\n',bandSumFn); 
                            end 
                            if obj.EXPORT_BAND_SUMMARY == 1
                                % Save results summary for later
                                bandSubjectCell{f} = bandSumCell;
                            end
                        end

                        %%  Plot Multiple Estimate
                        % Echo status to console
                        fprintf('\tCreating summary figures for each signal: number of figures depends of run flags\n'); 

                        for s = 1:processNsignals
                            %% Create artifact summary figure
                            if PLOT_ARTIFACT_SUMMARY == 1
                                fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                                set(fid,'Position', figPos);
                                figs = [figs;fid];

                                % Set 
                                % Get artifact summary
                                artifact = artifactCell{s};
                                deltaSpectrum = artifact.deltaSpectrum;
                                deltaArtifactIndex = artifact.deltaArtifactIndex;
                                betaSpectrum = artifact.betaSpectrum;
                                betaArtifactIndex = artifact.betaArtifactIndex;                

                                subplot(2,1,1);
                                plot(log10(deltaSpectrum), ...
                                    'LineWidth', plotLineWidth);
                                title(sprintf('%s - Artifact Delta Band (0.6 to 4.6 Hz)', signalLabels{s}),...
                                   'FontWeight','bold','FontSize',fontSize, ...
                                   'Interpreter', 'None');
                                xlabel('Epoch Number','FontWeight','bold','FontSize',fontSize);
                                ylabel(sprintf('Density (%s^2)',analysisEegUnits),...
                                    'FontWeight','bold','FontSize',fontSize);
                                %set(gca,'yscale', 'log');
                                v = axis;
                                v(2) = length(deltaSpectrum);
                                axis(v);
                                for l= 1:length(deltaArtifactIndex)
                                   line([deltaArtifactIndex(l) deltaArtifactIndex(l)], ...
                                      v(3:4), 'color', [1 0 0], ...
                                      'LineWidth',artifactLineWidth); 
                                end

                                % Format Axis
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);

                                % Replot to put data on top
                                hold on
                                plot(log10(deltaSpectrum));
                                axis(v);

                                % Plot Artifact-Beta time course
                                subplot(2,1,2);
                                plot(log10(betaSpectrum), 'LineWidth', plotLineWidth);
                                title(sprintf('%s - Artifact Beta Band (40 to 60 Hz)', signalLabels{s}),...
                                    'FontWeight','bold','FontSize',fontSize, ...
                                   'Interpreter', 'None');
                                xlabel('Epoch Number','FontWeight','bold','FontSize',fontSize);
                                ylabel(sprintf('Density (%s^2/Hz)',analysisEegUnits),'FontWeight','bold','FontSize',fontSize);
                                %set(gca,'yscale', 'log');
                                v = axis;
                                v(2) = length(betaSpectrum);
                                axis(v);
                                for l= 1:length(betaArtifactIndex)
                                   line([betaArtifactIndex(l) betaArtifactIndex(l)], ...
                                      v(3:4), 'color', [1 0 1], ...
                                      'LineWidth', artifactLineWidth); 
                                end

                                % Format Axis
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);

                                % Replot to put data on top
                                hold on
                                plot(log10(betaSpectrum), 'LineWidth', plotLineWidth);
                                axis(v);                  
                            end % Plot Artifact Summary

                            %% Create Figure - Panel (contour, SWA and Hypnogram)
                            if PLOT_SPECTRAL_SUMMARY == 1;
                                fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                                set(fid,'Position', figPos);
                                figs = [figs;fid];

                                %------------------------------------ Plot contour plot
                                subplot(3,1,1);
                                % Get data and zero wake values
                                pxxEpoch = log10(pxxCell{s});
                                % pxxEpoch(:, wakeMask) =zeros(length(freq), sum(wakeMask));

                                % Plot Data
                                scalingFactorForEffect = 4;
                                set(gca,'Ydir', 'Reverse');
                                imagesc(flipud(pxxEpoch(fIdx,:))*scalingFactorForEffect);
                                colormap(map); 
                                colorbar;

                                % Annotate
                                title(signalLabels{s},'FontWeight','bold','FontSize',fontSize+4, ...
                                   'Interpreter', 'None');
                                ylabel('Frequency (Hz)','FontWeight','bold','FontSize',fontSize);

                                % Add axis labels
                                axisVal = [0:freqDisplayInc:freqDisplayMax]';
                                getIndexF = @(x) find(freq == x);
                                axisIndex = arrayfun(getIndexF, axisVal, ...
                                    'UniformOutput', 1);
                                set(gca, 'YTick', axisIndex);
                                set(gca, 'YTickLabel', num2str(flipud(axisVal)));
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);          

                                vold = axis;
                                %------------------------------ Plot slow wave activity
                                subplot(3,1,2);

                                % Get data
                                swaSpectrum = (artifact.swaSpectrum);
                                epochNum = [1:returnedNum30SecEpochs];

                                % Remove artifacts and wake
                                removeMask = or...
                                    (deltaArtifactMask',betaArtifactMask');
                                removeMask = or...
                                    (removeMask, wakeMask);
                                if sum(removeMask)>0
                                    swaSpectrum(:,removeMask) = [];
                                    epochNum(removeMask) = [];
                                end
                                swaSpectrum = sum(swaSpectrum,1);



                                plot(epochNum, log10(swaSpectrum), 'LineWidth', plotLineWidth); 

                                % Plot artifacts
                                v = axis();
                                v(1:2) = vold(1:2);
                                axis(v);

                                lineStart = v(4)-(v(4)-v(3))*0.15;
                                plotDeltaArtifactMask = and(artifact.deltaArtifactMask, ...
                                    artifact.deltaArtifactMask);
                                plotDeltaArtifactMask = ...
                                    and(plotDeltaArtifactMask, sleepMask');
                                plotDeltaArtifactIndex = find(plotDeltaArtifactMask);
                                for l= 1:length(plotDeltaArtifactIndex)
                                   line([plotDeltaArtifactIndex(l) plotDeltaArtifactIndex(l)], ...
                                      [lineStart v(4)], 'color', [1 0 0],...
                                      'LineWidth', artifactLineWidth); 
                                end
                                plotBetaArtifactMask = and(artifact.betaArtifactMask, ...
                                    artifact.betaArtifactMask);
                                plotBetaArtifactMask = ...
                                    and(plotBetaArtifactMask, sleepMask');
                                plotBetaArtifactIndex = find(plotBetaArtifactMask);
                                for l= 1:length(plotBetaArtifactIndex)
                                   line([plotBetaArtifactIndex(l) plotBetaArtifactIndex(l)], ...
                                      [lineStart v(4)], 'color', [1 0 1],...
                                      'LineWidth', artifactLineWidth); 
                                end
                                deltaBetaArtifactMask = and(artifact.deltaArtifactMask, ...
                                    artifact.betaArtifactMask);
                                deltaBetaArtifactMask = ...
                                    and(deltaBetaArtifactMask, sleepMask');
                                deltaBetaArtifactIndex = find(deltaBetaArtifactMask);
                                for l= 1:length(deltaBetaArtifactIndex)
                                   line([deltaBetaArtifactIndex(l) deltaBetaArtifactIndex(l)], ...
                                      [lineStart v(4)], 'color', [0 0 0],...
                                      'LineWidth', artifactLineWidth); 
                                end
                                axis(v);

                                title('SWA (0.5-4.5 Hz)','FontWeight','bold',...
                                    'FontSize',fontSize, 'Interpreter', 'None');
                                yLabelStr = sprintf('log10(Density (%s^2/Hz))', analysisEegUnits);
                                ylabel(yLabelStr, 'FontWeight','bold','FontSize',fontSize);

                                % Format Axis
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);

                                %--------------------------------------- Plot Hypnogram
                                subplot(3,1,3);
                                plot(numericHypnogram, 'LineWidth', plotLineWidth);

                                % Change axis
                                v = axis();
                                v(2) = length(betaSpectrum);
                                v(3:4) = [-2.5 5.5];
                                axis(v)

                                % Add annotations
                                title('Hypnogram', 'FontWeight','bold','FontSize',fontSize, ...
                                   'Interpreter', 'None');
                                xlabel('Epoch Number', 'FontWeight','bold','FontSize',fontSize);
                                ylabel('Stage', 'FontWeight','bold','FontSize',fontSize);

                                % Set x axis
                                box(gca,'on');
                                hold(gca,'all');            
                                set(gca, 'YTick', [-2:1:5]);
                                set(gca, 'YTickLabel', ...
                                    {'U', 'M', 'W', '1', '2', '3', '4', 'R'});

                                % Format Axis
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);

                            end % Plot Spectral Summary Panel
                            
                            %% Create Figure - Panel (contour, SWA, Hypnogram and Spectra)
                            if obj.PLOT_COMPREHENSIVE_SPECTRAL_SUMMARY == 1;
                                % Create figure
                                fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                                set(fid,'Position', figPos);
                                figs = [figs;fid];
                                
                                % Turn off position warning, from panel
                                % call
                                set(fid, 'PaperPositionMode' ,'auto')
                                %------------------------------------ Panel
                                % Create panel
                                p = panel();
                                h1 = 20;
                                h2 = 60;
                                t = 1;
                                d = t*2+h2*3;
                                p.pack('v', {t/(d+h1+1) 1/(d+h1+1) []});
                                p(3).pack('h', {75/105 1/105 []});
                                p(3,1).pack('v', {h2/d t/d h2/d t/d []});
                                
                                %------------------------------ Title Panel
                                % Add plot title
                                titleStr = sprintf('%s - %s - %.0f sec bin - %s Hz', ....
                                     edfFNames{f}, signalLabels{s}, spectralBinWidth, num2str(freq(2)));
                                title(titleStr,'FontWeight','bold','FontSize',fontSize*3/2,...
                                    'Interpreter', 'None');
                                box off
                                axis('off');
                                
                                %------------------------------------ Plot contour plot
                                % Select active panel frame
                                p(3,1,1).select();
                                
                                % Get data and zero wake values
                                pxxEpoch = log10(pxxCell{s});
                                %pxxEpoch(:, wakeMask) =zeros(length(freq), sum(wakeMask));

                                % Plot Data
                                set(gca,'Ydir', 'Reverse');
                                imagesc(flipud(pxxEpoch(fIdx,:)));
                                colormap(map); 
                                % colorbar;
                                v = axis;
                                v(1) = 0;
                                v(2) = size(pxxEpoch,2);
                                v(3) = 0;
                                v(4) = length(fIdx);
                                vold = v;
                                
                                % Annotate
                                title(signalLabels{s},'FontWeight','bold','FontSize',fontSize, ...
                                   'Interpreter', 'None');
                                ylabel('Frequency (Hz)','FontWeight','bold','FontSize',fontSize);

                                % Add axis labels
                                axisVal = [0:freqDisplayInc:freqDisplayMax]';
                                getIndexF = @(x) find(freq == x);
                                axisIndex = arrayfun(getIndexF, axisVal, ...
                                    'UniformOutput', 1);
                                set(gca, 'YTick', axisIndex);
                                set(gca, 'YTickLabel', num2str(flipud(axisVal)));
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);          

                                hold on
                                % Add wake boundaries
                                wakeStart = find(wakeMask(1:end-1)<wakeMask(2:end));
                                wakeEnd = find(wakeMask(1:end-1)>wakeMask(2:end));
                                for l = 1:length(wakeStart)
                                    line([wakeStart(l) wakeStart(l)], [0 length(fIdx)],...
                                        'Color', [1 1 1], 'LineWidth',0.5);
                                end
                                for l = 1:length(wakeEnd)
                                    line([wakeEnd(l) wakeEnd(l)], [0 length(fIdx)],...
                                        'Color', [1 1 1], 'LineWidth',0.5);
                                end      
                                
                                % Add lines to highlight spindle frequency
                                spindleFreq = [12 15]/freq(2);
                                line([0 v(2)], ...
                                    [v(4)-spindleFreq(1) v(4)-spindleFreq(1)],...
                                    'Color', [1 1 1], 'LineWidth',1);
                                line([0 v(2)], ...
                                    [v(4)-spindleFreq(2) v(4)-spindleFreq(2)],...
                                    'Color', [1 1 1], 'LineWidth', 1);
                                
                                % outline plot area
                                axis(v);
                                box on;
                                %------------------------------ Plot slow wave activity
                                % Select active panel frame
                                p(3,1,5).select();

                                % Get data
                                swaSpectrum = (artifact.swaSpectrum);
                                epochNum = [1:returnedNum30SecEpochs];

                                % Remove artifacts and wake
                                removeMask = or...
                                    (deltaArtifactMask',betaArtifactMask');
                                removeMask = or...
                                    (removeMask, wakeMask);
                                if sum(removeMask)>0
                                    swaSpectrum(:,removeMask) = [];
                                    epochNum(removeMask) = [];
                                end
                                swaSpectrum = sum(swaSpectrum,1);

                                % Plot Slow Wave Activity
                                plot(epochNum, log10(swaSpectrum), 'LineWidth', plotLineWidth); 

                                % Plot artifacts
                                v = axis();
                                v(1:2) = vold(1:2);
                                axis(v);

                                % Plot delta artifact
                                lineStart = v(4)-(v(4)-v(3))*0.15;
                                plotDeltaArtifactMask = and(artifact.deltaArtifactMask, ...
                                    artifact.deltaArtifactMask);
                                plotDeltaArtifactMask = ...
                                    and(plotDeltaArtifactMask, sleepMask');
                                plotDeltaArtifactIndex = find(plotDeltaArtifactMask);
                                for l= 1:length(plotDeltaArtifactIndex)
                                   line([plotDeltaArtifactIndex(l) plotDeltaArtifactIndex(l)], ...
                                      [lineStart v(4)], 'color', [1 0 0],...
                                      'LineWidth', artifactLineWidth); 
                                end
                                
                                % Plot beta artifact
                                plotBetaArtifactMask = and(artifact.betaArtifactMask, ...
                                    artifact.betaArtifactMask);
                                plotBetaArtifactMask = ...
                                    and(plotBetaArtifactMask, sleepMask');
                                plotBetaArtifactIndex = find(plotBetaArtifactMask);
                                for l= 1:length(plotBetaArtifactIndex)
                                   line([plotBetaArtifactIndex(l) plotBetaArtifactIndex(l)], ...
                                      [lineStart v(4)], 'color', [1 0 1],...
                                      'LineWidth', artifactLineWidth); 
                                end
                                deltaBetaArtifactMask = and(artifact.deltaArtifactMask, ...
                                    artifact.betaArtifactMask);
                                deltaBetaArtifactMask = ...
                                    and(deltaBetaArtifactMask, sleepMask');
                                deltaBetaArtifactIndex = find(deltaBetaArtifactMask);
                                for l= 1:length(deltaBetaArtifactIndex)
                                   line([deltaBetaArtifactIndex(l) deltaBetaArtifactIndex(l)], ...
                                      [lineStart v(4)], 'color', [0 0 0],...
                                      'LineWidth', artifactLineWidth); 
                                end
                                axis(v);
                                
                                % Add plot annotaions
                                title('SWA (0.5-4.5 Hz)','FontWeight','bold',...
                                    'FontSize',fontSize, 'Interpreter', 'None');
                                yLabelStr = sprintf('log10(Density (%s^2/Hz))', analysisEegUnits);
                                ylabel(yLabelStr, 'FontWeight','bold','FontSize',fontSize);
                                xlabel('Epoch Number', 'FontWeight','bold','FontSize',fontSize);
                                
                                % Format Axis
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);

                                % Outline plot
                                box on;
                                
                                %--------------------------------------- Plot Hypnogram
                                % Select active panel
                                p(3,1,3).select();
                                
                                % Plot Hypnogram
                                plot(numericHypnogram, 'LineWidth', plotLineWidth);

                                % Change axis
                                v = axis();
                                v(2) = length(betaSpectrum);
                                v(3:4) = [-2.5 5.5];
                                axis(v)

                                % Add annotations
                                title('Hypnogram', 'FontWeight','bold','FontSize',fontSize, ...
                                   'Interpreter', 'None');
                                
                                ylabel('Stage', 'FontWeight','bold','FontSize',fontSize);

                                % Set x axis
                                box(gca,'on');
                                hold(gca,'all');            
                                set(gca, 'YTick', [-2:1:5]);
                                set(gca, 'YTickLabel', ...
                                    {'U', 'M', 'W', '1', '2', '3', '4', 'R'});

                                % Format Axis
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);
                                box on;
                                
                                %------------------- Plot NREM/REM Spectrum
                                % Select active panel
                                p(3,3).select();

                                % Get data and zero wake values
                                pxxEpoch = pxxCell{s}(fIdx, :);

                                % Artifact Mask
                                artifactMask = artifactCell{s}.artifactMask;

                                % Convert from Power Density^2 to Power                     
                                nremData = ( mean(...
                                    pxxEpoch(:, and(nremMask,~artifactMask)),2));
                                remData = ( mean(...
                                    pxxEpoch(:, and(remMask,~artifactMask)),2));                    

                                % Plot Data
                                plot(freq(fIdx),log10(nremData),...
                                    'k', 'LineWidth',plotLineWidth); hold on;
                                plot(freq(fIdx),log10(remData),...
                                    'b', 'LineWidth',plotLineWidth);

                                % save average spectrums
                                spectrumSubjectCellLabel2 = [freq(fIdx)',freq(fIdx)'];
                                spectrumSubjectCellLabel1 = ...
                                    cell(1, length(spectrumSubjectCellLabel2));
                                spectrumSubjectCellLabel1{1} = ...
                                    sprintf('NREM - Power Density - %s^2.Hz', analysisEegUnits);
                                spectrumSubjectCellLabel1{1+length(fIdx)} =  ...
                                    sprintf('REM - Power Density - %s^2.Hz', analysisEegUnits);
                                spectrumSubjectCell = [spectrumSubjectCell; ...
                                    num2cell([nremData', remData'])];
                                spectrumVerticalLabels = [spectrumVerticalLabels; ...
                                    {edfFNames(f), signalLabels{s}}];

                                % Add annotations
                                titleStr = sprintf('Density Spectra');
                                title(titleStr,'FontWeight','bold','FontSize',fontSize,...
                                    'Interpreter', 'None');
                                xlabel('Frequency (Hz)', 'FontWeight','bold','FontSize',fontSize);
                                ylabel(sprintf('Log10 ( Density )  (%s^2/Hz)',...
                                    analysisEegUnits), 'FontWeight','bold','FontSize',fontSize);

                                % Plot Band Specification
                                v = axis; h = v(4)-v(3);
                                for boi = 1:numBandsOfInterest
                                   band = bandsOfInterest{boi}{2};
                                   w = band(2)-band(1);
                                   rectangle('Position',[band(1),v(3),w,h], ...
                                    'FaceColor', bandColors(mod(boi-1, numBandColors)+1,:)); 
                                   th = v(4) - diff(v(3:4))*0.05;
                                   text(mean(band), th, bandsOfInterestLatex{boi}, ...
                                       'Interpreter', 'Latex', 'FontSize', fontSize+4,...
                                       'HorizontalAlignment','center');
                                end

                                % Re-Plot Data
                                plot(freq(fIdx),log10(nremData),...
                                    'k', 'LineWidth',plotLineWidth); hold on;
                                plot(freq(fIdx),log10(remData),...
                                    'b', 'LineWidth',plotLineWidth);

                                % Format Axis
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);
                                box on;
                                
                                % Add legend
                                legend('NREM','REM' );
                                legend('boxoff')
                            end % Plot Comprehensive Spectral Summary Panel
                

                            if PLOT_NREM_REM_SPECTRUM == 1
                                % Create Figure
                                fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                                set(fid,'Position', figPos);
                                figs = [figs;fid];
                                subplot(1,1,1);

                                % Get data and zero wake values
                                pxxEpoch = pxxCell{s}(fIdx, :);

                                % Artifact Mask
                                artifactMask = artifactCell{s}.artifactMask;

                                % Convert from Power Density^2 to Power                     
                                nremData = ( mean(...
                                    pxxEpoch(:, and(nremMask,~artifactMask)),2));
                                remData = ( mean(...
                                    pxxEpoch(:, and(remMask,~artifactMask)),2));                    

                                % Plot Data
                                plot(freq(fIdx),log10(nremData),...
                                    'k', 'LineWidth',plotLineWidth); hold on;
                                plot(freq(fIdx),log10(remData),...
                                    'b', 'LineWidth',plotLineWidth);

                                if obj.PLOT_COMPREHENSIVE_SPECTRAL_SUMMARY ~= 1
                                    % save average spectrums
                                    spectrumSubjectCellLabel2 = [freq(fIdx)',freq(fIdx)'];
                                    spectrumSubjectCellLabel1 = ...
                                        cell(1, length(spectrumSubjectCellLabel2));
                                    spectrumSubjectCellLabel1{1} = ...
                                        sprintf('NREM - Power Density - %s^2.Hz', analysisEegUnits);
                                    spectrumSubjectCellLabel1{1+length(fIdx)} =  ...
                                        sprintf('REM - Power Density - %s^2.Hz', analysisEegUnits);
                                    spectrumSubjectCell = [spectrumSubjectCell; ...
                                        num2cell([nremData', remData'])];
                                    spectrumVerticalLabels = [spectrumVerticalLabels; ...
                                        {edfFNames(f), signalLabels{s}}];
                                end
                                
                                % Add annotations
                                titleStr = sprintf('%s Density Spectrum (bin width = %.0f sec, resolution = %s Hz), %s', ....
                                    signalLabels{s}, spectralBinWidth, num2str(freq(2)), edfFNames{f});
                                title(titleStr,'FontWeight','bold','FontSize',fontSize,...
                                    'Interpreter', 'None');
                                xlabel('Frequency (Hz)', 'FontWeight','bold','FontSize',fontSize);
                                ylabel(sprintf('Log10 ( Density )  (%s^2/Hz)',...
                                    analysisEegUnits), 'FontWeight','bold','FontSize',fontSize);

                                % Plot Band Specification
                                v = axis; h = v(4)-v(3);
                                for boi = 1:numBandsOfInterest
                                   band = bandsOfInterest{boi}{2};
                                   w = band(2)-band(1);
                                   rectangle('Position',[band(1),v(3),w,h], ...
                                    'FaceColor', bandColors(mod(boi-1, numBandColors)+1,:)); 
                                   th = v(4) - diff(v(3:4))*0.05;
                                   text(mean(band), th, bandsOfInterestLatex{boi}, ...
                                       'Interpreter', 'Latex', 'FontSize', fontSize+4,...
                                       'HorizontalAlignment','center');
                                end

                                % Re-Plot Data
                                plot(freq(fIdx),log10(nremData),...
                                    'k', 'LineWidth',plotLineWidth); hold on;
                                plot(freq(fIdx),log10(remData),...
                                    'b', 'LineWidth',plotLineWidth);

                                % Format Axis
                                set(gca, 'LineWidth',plotLineWidth);
                                set(gca, 'Layer','top');
                                set(gca, 'FontWeight','bold');
                                set(gca, 'FontSize',fontSize);

                                % Add legend
                                legend('NREM','REM' );
                                legend('boxoff')
                            end

                            % Plot Band Activity across study
                            if PLOT_BAND_ACTIVITY == 1
                                % Create each plot
                                for boi = 1:numBandsOfInterest
                                    fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                                    set(fid,'Position', figPos);
                                    figs = [figs;fid];
                                    subplot(2,1,1);

                                    % Band Info
                                    band = bandsOfInterest{boi}{2};
                                    bandLabel = bandsOfInterest{boi}{1};

                                    % Get spectrum information       
                                    artifactMask = artifactCell{s}.artifactMask;
                                    zeroMask = or(wakeMask, artifactMask);
                                    bandMask = and(band(1) <= freq, freq < band(2));
                                    bandPower = sum(pxxCell{s}(bandMask, :),1);
                                    epochNum = [1:returnedNum30SecEpochs];                       

                                    % Create mask for removing bad values
                                    displaySleepMask = sleepMask;
                                    displayNumericHypnogram = numericHypnogram;
                                    dsiplayBandPower = bandPower;
                                    if sum(zeroMask)>0
                                        % Remove Bad data
                                        dsiplayBandPower(zeroMask) = [];
                                        epochNum(zeroMask) = [];
                                        displaySleepMask(zeroMask) = [];
                                        displayNumericHypnogram(zeroMask) = [];
                                    end                       
                                    minXaxisVal = min(epochNum);
                                    maxXaxisVal = max(epochNum);

                                    % Determine segments of sleep data to plot
                                    sleepStart = find(zeroMask(1:end-1)>zeroMask(2:end));
                                    sleepEnd  = find(zeroMask(1:end-1)<zeroMask(2:end));
                                    if length(sleepStart) > length(sleepEnd)
                                        % Add final sleep
                                        sleepEnd = [sleepEnd; length(zeroMask)];
                                    elseif length(sleepStart) < length(sleepEnd) 
                                        % Add starting sleep
                                        sleepStart = [1; sleepStart];                            
                                    end
                                    numLineSegmentsToPlot = length(sleepStart);

                                    % Plot each line segment
                                    for ls = 1:numLineSegmentsToPlot
                                        plot([sleepStart(ls):sleepEnd(ls)], ...
                                            log10(bandPower(sleepStart(ls):sleepEnd(ls))), ...
                                            'LineWidth',plotLineWidth, ...
                                            'Color', [ 0 0 1 ]);    
                                        hold on
                                    end

                                    % Plot artifacts
                                    v = axis;
                                    v(1) = minXaxisVal;
                                    v(2) = maxXaxisVal;
                                    axis(v);

                                    lineStart = v(4)-(v(4)-v(3))*0.15;
                                    plotDeltaArtifactMask = and(artifact.deltaArtifactMask, ...
                                        artifact.deltaArtifactMask);
                                    plotDeltaArtifactMask = ...
                                        and(plotDeltaArtifactMask, sleepMask');
                                    plotDeltaArtifactIndex = find(plotDeltaArtifactMask);
                                    for l= 1:length(plotDeltaArtifactIndex)
                                       line([plotDeltaArtifactIndex(l) plotDeltaArtifactIndex(l)], ...
                                          [lineStart v(4)], 'color', [1 0 0],...
                                          'LineWidth', artifactLineWidth); 
                                    end
                                    plotBetaArtifactMask = and(artifact.betaArtifactMask, ...
                                        artifact.betaArtifactMask);
                                    plotBetaArtifactMask = ...
                                        and(plotBetaArtifactMask, sleepMask');
                                    plotBetaArtifactIndex = find(plotBetaArtifactMask);
                                    for l= 1:length(plotBetaArtifactIndex)
                                       line([plotBetaArtifactIndex(l) plotBetaArtifactIndex(l)], ...
                                          [lineStart v(4)], 'color', [1 0 1],...
                                          'LineWidth', artifactLineWidth); 
                                    end
                                    deltaBetaArtifactMask = and(artifact.deltaArtifactMask, ...
                                        artifact.betaArtifactMask);
                                    deltaBetaArtifactMask = ...
                                        and(deltaBetaArtifactMask, sleepMask');
                                    deltaBetaArtifactIndex = find(deltaBetaArtifactMask);                      
                                    for l= 1:length(deltaBetaArtifactIndex)
                                       line([deltaBetaArtifactIndex(l) deltaBetaArtifactIndex(l)], ...
                                          [lineStart v(4)], 'color', [0 0 0],...
                                          'LineWidth', artifactLineWidth); 
                                    end

                                    % Add Annotations
                                    titleStr = sprintf('%s - %s (%0.1f-%0.1f Hz), %s', ...
                                        signalLabels{s},bandLabel, band(1), band(2), ...
                                        edfFNames{f});
                                    title(titleStr,'FontWeight','bold','FontSize',fontSize,...
                                    'Interpreter', 'None');
                                    ylabel(sprintf('log10(Density) (%s^2/Hz)',analysisEegUnits), 'FontWeight','bold','FontSize',fontSize);
                                    xlabel('Epoch', 'FontWeight','bold','FontSize',fontSize);

                                    % Format Axis
                                    set(gca, 'LineWidth',plotLineWidth);
                                    set(gca, 'Layer','top');
                                    set(gca, 'FontWeight','bold');
                                    set(gca, 'FontSize',fontSize);

                                    % Set x axis to displayed data
                                    v(1:2) = [minXaxisVal, maxXaxisVal];

                                    % Plot Hypnogram
                                    subplot(2,1,2); 

                                    % Plot Hypnogram
                                    tempAxis = [1:length(numericHypnogram)]';
                                    plot(tempAxis(minXaxisVal:maxXaxisVal), ...
                                         numericHypnogram(minXaxisVal:maxXaxisVal), ...
                                        'LineWidth', plotLineWidth);

                                    % Reset Y axis to show all hypnogram states
                                    v = axis();
                                    v(1:2) = [minXaxisVal, maxXaxisVal];
                                    v(3:4) = [-2.5 5.5];
                                    axis(v);

                                    % Add annotations
                                    title('Hypnogram', 'FontWeight','bold','FontSize',fontSize, ...
                                       'Interpreter', 'None');
                                    xlabel('Epoch Number', 'FontWeight','bold','FontSize',fontSize);
                                    ylabel('Stage', 'FontWeight','bold','FontSize',fontSize);

                                    % Set x axis
                                    box(gca,'on');
                                    hold(gca,'all');            
                                    set(gca, 'YTick', [-2:1:5]);
                                    set(gca, 'YTickLabel', ...
                                        {'U', 'M', 'W', '1', '2', '3', '4', 'R'});

                                    % Format Axis
                                    set(gca, 'LineWidth',plotLineWidth);
                                    set(gca, 'Layer','top');
                                    set(gca, 'FontWeight','bold');
                                    set(gca, 'FontSize',fontSize);
                                end % For each band of interest
                            end % Plot band activity

                        end % For each signal

                        %% Save results
                        % Save numeric values

                        % Save figures
                        figs = figs;
                        pptFn = strcat(edfFNames{f},'.spectral.ppt');
                        pptPathFn = strcat(StudyEdfResultDir, pptFn);
                        titleStr = sprintf('%s - %s', 'Spectral', edfFNames{f});
                        imageResolution = imageResolution;
                        
                        if obj.CREATE_POWER_POINT_SUMMARY == 1
                            obj.CreateSignalPPT ...
                                (figs, pptPathFn, titleStr, imageResolution)
                        end
                        % Echo status to console
                        fprintf('\tGenerated figures saved to PowerPoint: %s\n', pptFn); 

                        % Close Figures
                        obj.CloseChildrenFigures;
                    end
                    %% Compute Coherence Estimate
                    if COHERENCE_COMPUTE_COHERENCE == 1
                        % Compute coherence with pwelch for multiple signals
                        fprintf('\tBegining coherence analysis\n');    

                        % Caluculate Coherence Parameters
                        numChan = length(analysisSignals);
                        signalPerm = combnk([1:numChan],2); 
                        numPerm = size(signalPerm, 1);
                        samplingRate = unique(edfObj.sample_rate);

                        % Check that EEG is samples at same rate
                        if length(samplingRate) > 1
                            warnMsg = 'Sampling rate is not constant across channels';
                            warning(warnMsg)
                            return    
                        end
                        SR = samplingRate;

                        % Orignial Variables
                        numSignalPts = length(signalCell{1});
                        epoch = 30;
                        epochPt = epoch*SR;
                        numCompleteEpochs = floor(numSignalPts/epochPt);
                        lastCompleteEpochPt = numCompleteEpochs*epochPt;

                        % Calculate average coherence for reference
                        s1 = signalCell{1}(1:numPtsPer30secEpoch*returnedNum30SecEpochs);
                        s2 = signalCell{2}(1:numPtsPer30secEpoch*returnedNum30SecEpochs);
                        [Cxy, Freq] = mscohere(s1, s2,hanning(5*SR),0,5*SR,SR);  

                        % Compute coherence with pwelch for multiple signals
                        fprintf('\t\tComputing coherence for each signal pair (N = %.0f)\n', numPerm);              

                        % Compute coherence for each pair
                        numPermCompute = numPerm;
                        CxyCell = cell(1,numPermCompute);
                        for c = 1:numPermCompute
                            % Get Signals
                            s1 = signalCell{signalPerm(c,1)}(1:numPtsPer30secEpoch*returnedNum30SecEpochs);
                            s1 = reshape(s1(1:lastCompleteEpochPt), 1, epochPt, numCompleteEpochs);
                            s2 = signalCell{signalPerm(c,2)}(1:numPtsPer30secEpoch*returnedNum30SecEpochs);    
                            s2 = reshape(s2(1:lastCompleteEpochPt), 1, epochPt, numCompleteEpochs);

                            % Compute and Store Coherence
                            cohF = @(x)mscohereWrap(s1(:,:,x), s2(:,:,x),hanning(5*SR),0,5*SR,SR);
                            CxyEpoch = cell2mat(arrayfun(cohF, [1:numCompleteEpochs],'UniformOutput', 0));
                            CxyCell{c} = CxyEpoch;

                            % Echo status to floor
                            if ECHO_STATUS_TO_CONSOLE == 1
                               if or(rem(c,10) == 0, c==1)
                                   % Echo staus every ten combinations
                                   fprintf('\t\t\t%.0f. Computing coherence (%s, %s), %s\n',...
                                       c, requiredSignals{signalPerm(c,1)}, ...
                                       requiredSignals{signalPerm(c,2)}, ...
                                       datestr(now, 'HH:MM:SS'));
                               end
                            end      
                        end

                        % Add Frequency axis labels
                        axisVal = [0:freqDisplayInc:freqDisplayMax]';
                        getIndexF = @(x) find(Freq == x);
                        maxAxisIndex = arrayfun(getIndexF, freqDisplayMax);
                        axisIndex = arrayfun(getIndexF, axisVal);

                        % Plot coherence for each pair
                        cohFid = [];
                        avgCohSpectra = [];
                        cohSignals = {};
                        for c = 1:numPermCompute
                            % Get data
                            Cxy = CxyCell{c};
                            CxyEpochMatrix = Cxy(1:maxAxisIndex,:);

                            % Create figure
                            maxCorr = max(max(CxyEpochMatrix));
                            fid = imageColorMap( jet(numColors), [0 1], CxyEpochMatrix, figPos);
                            cohFid = [cohFid; fid];

                            % Annotate
                            titleStr = sprintf('Coherence - Welsch - %s - %s', ...
                                signalLabels{signalPerm(c,1)}, signalLabels{signalPerm(c,2)}); 
                            title(titleStr,...
                                    'Interpreter', 'None');
                            xlabel('Epoch');
                            ylabel('Frequency(Hz)');  

                            % Format GCA
                            set(gca, 'YTick', axisIndex);
                            set(gca, 'YTickLabel', num2str(flipud(axisVal)));
                            set(gca, 'LineWidth', 2);
                            set(gca, 'FontWeight', 'bold');
                            set(gca, 'FontSize',14);                          
                            
                            %% Create Coherence Spectrum
                            fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                            set(fid,'Position', figPos);
                            cohFid = [cohFid; fid];
                            subplot(1,1,1);

                            % Get data and zero wake values
                            pxxEpoch = CxyEpochMatrix;                            
                            
                            % Artifact Mask
                            artifactMask = artifactCell{s}.artifactMask;

                            % Convert from Power Density^2 to Power                     
                            nremData = mean(...
                                pxxEpoch(:, and(nremMask,~artifactMask)),2);
                            remData = mean(...
                                pxxEpoch(:, and(remMask,~artifactMask)),2);   

                            % Plot Data
                            plot(freq(fIdx),nremData(fIdx),...
                                'k', 'LineWidth',plotLineWidth); hold on;
                            plot(freq(fIdx),remData(fIdx),...
                                'b', 'LineWidth',plotLineWidth);

                            % Add annotations
                            titleStr = sprintf('Coherence - Welsch - %s - %s', ...
                                signalLabels{signalPerm(c,1)}, signalLabels{signalPerm(c,2)}); 
                            title(titleStr,'FontWeight','bold','FontSize',fontSize,...
                                'Interpreter', 'None');
                            xlabel('Frequency (Hz)', 'FontWeight','bold','FontSize',fontSize);
                            ylabel('Coherence', ...
                                'FontWeight','bold','FontSize',fontSize);
                            curCohSignals = {signalLabels{signalPerm(c,1)}, ...
                                signalLabels{signalPerm(c,2)}};

                            % Plot Band Specification
                            v = axis; h = v(4)-v(3);
                            for boi = 1:numBandsOfInterest
                               band = bandsOfInterest{boi}{2};
                               w = band(2)-band(1);
                               rectangle('Position',[band(1),v(3),w,h], ...
                                'FaceColor', bandColors(mod(boi-1, numBandColors)+1,:)); 
                               th = v(4) - diff(v(3:4))*0.05;
                               text(mean(band), th, bandsOfInterestLatex{boi}, ...
                                   'Interpreter', 'Latex', 'FontSize', fontSize+4,...
                                   'HorizontalAlignment','center');
                            end                
                            
                            % Re-Plot Data
                            plot(freq(fIdx),nremData(fIdx),...
                                'k', 'LineWidth',plotLineWidth); hold on;
                            plot(freq(fIdx),remData(fIdx),...
                                'b', 'LineWidth',plotLineWidth);

                            % Format Axis
                            set(gca, 'LineWidth',plotLineWidth);
                            set(gca, 'Layer','top');
                            set(gca, 'FontWeight','bold');
                            set(gca, 'FontSize',fontSize);

                            % Reset axis
                            axis(v);
                            % Add legend
                            legend('NREM','REM');    
                            
                            % Record Average Spectra
                            avgCohSpectra = [avgCohSpectra; ...
                                nremData(fIdx)',remData(fIdx)'];
                            cohSignals = [cohSignals; curCohSignals];
                        end    
                        
                        %% Save results
%                         % Save numeric values in matlab format
%                         coherenceResultFN = ...
%                             strcat(obj.StudyEdfResultDir, edfFNames{f},'.coherence.mat');
%                         saveCmd = sprintf('save ''%s''  Freq  CxyEpochMatrix;',coherenceResultFN);
%                         eval(saveCmd);
%                         
%                         % Save epoch by epcoh coherence in excel format
%                         coherenceResultFN = ...
%                             strcat(obj.StudyEdfResultDir, edfFNames{f},'.coherence.epoch.xlsx');
%                         xlswrite(coherenceResultFN, CxyEpochMatrix(fIdx,:)');
%                         
                        % Create Average signal labels for output
                        
                        
                        % Save average coherence spectra
                        coherenceResultFN = ...
                            strcat(obj.StudyEdfResultDir, edfFNames{f},'.coherence.nrem.rem.xlsx');
                        avgCohOut = [cohSignals,num2cell(avgCohSpectra)];
                        avgCohLabels = cell(1,size(avgCohOut,2));
                        avgCohLabels{1} = ' ';
                        avgCohLabels{2} = ' ';
                        avgCohLabels{3} = ...
                            sprintf('NREM(%s)',obj.analysisEegUnits);
                        avgCohLabels{3+length(fIdx)} = ...
                            sprintf('REM(%s)',obj.analysisEegUnits);
                        freqLabels = arrayfun(@(x)sprintf('%.2f Hz',x),freq(fIdx),...
                            'UniformOutput', 0)';
                        avgCohLabels2 = [{'Signal 1'}, {'Signal 2'},...
                            freqLabels, freqLabels];
                        avgCohOut = [ avgCohLabels; avgCohLabels2; ...
                            avgCohOut];
                        xlswrite(coherenceResultFN, avgCohOut);
                                              
                        % Save Figures
                        if obj.CREATE_COHERENCE_POWER_POINT_SUMMARY == 1
                            % Save figures
                            figs = [figs;cohFid];
                            pptFn = strcat(StudyEdfResultDir, edfFNames{f},'.coherence.ppt');
                            titleStr = sprintf('%s - %s', 'Coherence', edfFNames{f});
                            imageResolution = imageResolution;
                            obj.CreateSignalPPT (cohFid, pptFn, titleStr, imageResolution)
                        end
                        
                        % Close Figures
                        obj.CloseChildrenFigures;
                    end % Compute coherence
                end % For each file

                %% Dataset summaries

                % Export Band Summaries
                if and(EXPORT_BAND_SUMMARY == 1, SUMMARIZE_BANDS == 1)
                    % Create a data set band summary with each line corresponding to 
                    % a data set. Summaries for multiple signals are stored on the same
                    % line.

                    % Create Master File
                    numSubjects = processFiles-processStart+1;
                    numSignals = processNsignals;
                    numBands = numBandsOfInterest; 
                    numEntryPerBand = 8;
                    numCols = 1 + numSignals*numBands*numEntryPerBand + 6;
                    numBandTableHeadLines = 2;
                    numSubjectBandSummaryHeadLines = 3;
                    bandSubjectSummaryCell = cell(numSubjects+numSubjectBandSummaryHeadLines,numCols);
                    for f = processStart:processFiles
                        % Label Entry
                        entryIndex = f-processStart+1;
                        bandSubjectSummaryCell(numSubjectBandSummaryHeadLines+entryIndex,1) = {edfFNames{f}};

                        % Move Results   
                        bandTable = bandSubjectCell{entryIndex};
                        bandResults = bandTable(numBandTableHeadLines+1:end,3:3+numEntryPerBand-1);
                        bandResults = reshape(bandResults', 1, prod(size(bandResults)));
                        bandSubjectSummaryCell(numSubjectBandSummaryHeadLines+entryIndex,2:1+length(bandResults)) = bandResults;

                        % Add Artifact Detection Information
                        bandSubjectSummaryCell...
                            (numSubjectBandSummaryHeadLines+entryIndex,end-5:end) = ...
                            bandTable(numBandTableHeadLines+1,end-5:end);
                    end

                    % Add labels
                    bandTable = bandSubjectCell{1};

                    % Get Label Information from Subject Table
                    entryLabels = bandTable(1,3:3+numEntryPerBand-1);
                    unitsLabels = bandTable(2,3:3+numEntryPerBand-1);
                    signalLab = bandTable(numBandTableHeadLines+1:end,1);
                    bandLab = bandTable(numBandTableHeadLines+1:end,2);

                    % Add Lablels
                    bandSubjectSummaryCell{1,1} =  bandTable{1,2};
                    bandSubjectSummaryCell{numSubjectBandSummaryHeadLines,1} = 'File Name';
                    for b = 1:length(signalLab) 
                        % Get band boundary
                        st = 2+(b-1)*length(entryLabels);
                        bandId = rem(b,numBands);
                        if (bandId == 0) bandId = numBands; end;
                        bandBoundary = bandsOfInterest{bandId}{2};

                        % Add label string
                        bandStr = sprintf('%s-%s(%s-%sHz)', ...
                            signalLab{b},  bandLab{b}, ...
                            num2str(bandBoundary(1)), num2str(bandBoundary(2)));
                        bandSubjectSummaryCell(1,st) = {bandStr};
                        bandSubjectSummaryCell(2,st:st-1+length(entryLabels)) = entryLabels;
                        bandSubjectSummaryCell(3,st:st-1+length(entryLabels)) = unitsLabels;
                    end
                    bandSubjectSummaryCell(1,end-5) = {'Artifact Detection'};
                    bandSubjectSummaryCell(2,end-5:end) = bandTable(numBandTableHeadLines,end-5:end);

                    % Write Master Summary file
                    bandFile = strcat(StudyEdfResultDir, StudyBandSummary);
                    xlswrite(bandFile, bandSubjectSummaryCell);
                end

                % Export Average spectrograms
                if and(OUTPUT_AVERAGE_SPECTROGRAMS == 1, PLOT_NREM_REM_SPECTRUM == 1)
                    % Create data identifiers
                    numResultRows = processFiles*length(analysisSignals);
                    verticalLabels = cell(numResultRows+2,3);
                    verticalLabels(2,1) = {'Entry Id'};
                    verticalLabels(2,2) = {'File Name'};
                    verticalLabels(2,3) = {'Signal Label'};
                    verticalLabels(3:end,1) = num2cell([1:numResultRows]');
                    verticalLabels(3:end,2:3) = spectrumVerticalLabels;


                    % Concatenate Spectrum labels and data
                    hzLabelF = @(x)sprintf('%s Hz', num2str(x));
                    spectrumSubjectCellLabel2 = ...
                        arrayfun(hzLabelF,spectrumSubjectCellLabel2, ...
                        'UniformOutput', 0);
                    spectrumSubjectCell = [...
                        spectrumSubjectCellLabel1; ...
                        spectrumSubjectCellLabel2; ...
                        spectrumSubjectCell];
                    spectrumSubjectCell = [verticalLabels, spectrumSubjectCell];

                    % Add File names
                    numSignals = length(analysisSignals);
                    numfiles = length(edfFNames);
                    spectraFileNames = cell(numSignals*numfiles, 1);
                    for f = 1: numfiles
                        for s = 1:numSignals
                            spectraFileNames{(f-1)*numSignals+s} = edfFNames{f};
                        end
                    end
                    spectrumSubjectCell(3:end,2) = spectraFileNames;

                    % Export spectrum to file 
                    spectralFile = strcat(StudyEdfResultDir, StudySpectrumSummary);
                    xlswrite(spectralFile, spectrumSubjectCell);
                end

            end
        end
    end
     %------------------------------------------------ Dependent Properties
    methods(Static)   
       %--------------------------------------------------- CreateSignalPPT
       function CreateSignalPPT (figs, pptFn, titleStr, imageResolution)
           % Create Power Point From Created Figures

           % Create Combined powerpoint
           if ~isempty(figs)
               % Set output file name
               ppt = saveppt2(pptFn,'init', 'res', imageResolution); 
               saveppt2('ppt', ppt, 'f', 0,'Title', titleStr);

               % Add signal Seperator
               for f = 1:length(figs)
                  figure(figs(f));
                  saveppt2('ppt', ppt );
               end

               % Create Power Point
               saveppt2(pptFn,'ppt',ppt,'close');
           end       
       end
       %---------------------------------------------- CloseChildrenFigures
       function CloseChildrenFigures
        %CloseChildrenFigures Close children figures, leave GUIs open
        %   An alternative to close all, which may close GUIs for some 
        %   versions of MATLAB

            % Identify figure handles not assoicated with a figure
            hands     = get (0,'Children');   % locate fall open figure handles
            hands     = sort(hands);          % sort figure handles
            numfigs   = size(hands,1);        % number of open figures
            indexes   = find(hands-round(hands)==0);

            % Close selected indexes
            close(hands(indexes));
       end
       %-------------------------------------------------- LoadBandSettings
       function bandStruct = LoadBandSettings(bandFn)
            % Load File
            [num txt raw] = xlsread(bandFn);

            % Put unprocesses values into temporary variables
            bandsOfInterest = txt(2:end,1);
            bandsOfInterestLabels = txt(2:end,2);
            bandStart = cell2mat(raw(2:end,3));
            bandEnd = cell2mat(raw(2:end,4));
            bandsOfInterestLatex = txt(2:end,5);
            bandColors = txt(2:end,6);

            % Restructure column input
            bandColors = cell2mat(cellfun(@eval, bandColors, 'UniformOutput', false));
            band = [bandStart, bandEnd];
            temp ={};
            for e = 1:length(bandStart);
                temp(e) = {{ bandsOfInterest{e}, band(e,:)}};
            end
            bandsOfInterest = temp;
            
            % Create structure to return
            bandStruct.bandsOfInterest = bandsOfInterest;
            bandStruct.bandsOfInterestLabels = bandsOfInterestLabels;
            bandStruct.bandsOfInterestLatex = bandsOfInterestLatex;
            bandStruct.bandColors = bandColors;
       end
    end
end

