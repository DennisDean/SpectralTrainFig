SpectralTrainFig
================

#### Overview
SpectralTrainFig is a graphical user interface that allows a user to select a folder of [EDF](http://en.wikipedia.org/wiki/European_Data_Format)/XML files to apply [spectral analysis](http://en.wikipedia.org/wiki/Spectral_estimation) to [electroencephlography signals (EEG)](http://en.wikipedia.org/wiki/Electroencephalography). The spectral analysis program includes a spectral threshold artifact detection scheme described in the [literature](http://www.ncbi.nlm.nih.gov/pubmed/16388912). SpectralTrainFig is a user friendly approach to the SpectralAnalysisClass function. The GUI versions allows a user to perform spectral or coherence analysis without having to do any progremming. EXCEL and PowerPoint summaries are configured by user defined settings and specified spectral bands. Detail epoch by epoch and subject summaries are provided for both NREM and REM states. Additional details are described below.

#### Getting Started
Brief getting started guides are provided if you want to work with the [source code](https://github.com/DennisDean/SpectralTrainFig/blob/master/QuickStartSouceCode.md) or the easy to use [MATLAB App](https://github.com/DennisDean/SpectralTrainFig/blob/master/QuickStartNoSourceCode.md).

Did you execute the examples in the getting started guide and want to setup a large run? 
Review our [standard operating procedure (SOP)](https://github.com/DennisDean/SpectralTrainFig/blob/master/standardOperatingProcedure.md) for additional operational details for applying spectral and coherence analysis to a large number of EDF files.

### Parameters

##### Description
*Analysis Description*. Enter a brief analysis description.

*Output File Prefix*. Enter a prefix that will be used to start each file written by the program.

*Data Folder*. Select a folder containing EDF and XML files

*Results Folder*. Select a folder to write program generated files to.

##### Analysis Parameters
*Analysis Signals*. Enter signal labels that are to be analyzed as a cell string (ex. {'C3', 'C2', 'C3-A1'}. All of the EDF files opened during the analysis are expected to contain signals with the specified labels. Use your favorite EDF utility to determine the signal labels.  You can use [SignalRasterViewerFig](http://www.mathworks.com/matlabcentral/fileexchange/46420-blockedfsignalrasterview) to list the signal labels and to view the signals.

*Reference Signals*. Enter the labels of the reference signals as a cell string (ex. {'A1', 'M1', 'M2'}).

*Reference Methods*.  Select one of three approaches to referencing the signal.  
-  *Single reference signal*. Enter a single signal label as cell string (ex. {'M1'}).  The reference signal is subtracted from each analysis signal. Entering a null cell string is interpreted as not to reference the analysis signals (ex. {})). 
-  *Reference for each analysis signal*. Enter a reference for each signal as a cell string (ex. {'M1','M1','M2','M3'}). A signal label can be used multiple times.
-  *Average of reference signals*.  The average of the signals listed in the cell array is substracted from each analysis signals.

*Spectral Settings*
-    Default.  The default settings include a 10x4 second sub-epochs, a 50% [tukey window] (http://en.wikipedia.org/wiki/Window_function#Tukey_window) and a 30 second sleep staging scoring window.
-    SHHS.  The settings used for the [Sleep Heart Health Study](http://www.ncbi.nlm.nih.gov/pubmed/9493915) can be selected. The settings are 6x5 second sub-epochs, a [hanning window](http://en.wikipedia.org/wiki/Hann_function) and a 30 second sleep staging scoring window.

*Artifact Detection*
-    Delta (0.6-4.6 Hz). Set the multiplicative threshold for the delta band. The default value is 2.5.
-    Beta (40-60 Hz). Set the multiplicative thresold for the beta band. The defaults to 2.0.

*Monitor Id*. Select the monitor to display the figures created during processing.

*Start*. Select the file Id to start. The option is provided in order to trouble shoot a failed fun. Review the autogenerated file lists to identify files or review the error message.

##### GUI Funciton Button
*Close All*. Closes all open figures

*About*. Displays graphical user interface description and copyright notice.

*Set Bands*. Load an Excel file with a list of spectral bands to analyze/report on.  Examples of the Excel spreadsheet can be found in the release section. The spectral analysis band summaries include slow oscilations (0.5-1 Hz), delta (1-4 Hz), theta (4-8 Hz), alpha (8-12 Hz), sigma (12-15 Hz), slow sigma (12-13.5), fast sigma (13.5-15 Hz) and beta (15-20 Hz). The default Excel file can be downloaded from [here](https://github.com/DennisDean/SpectralTrainFig/releases/download/0.1.00/bandAnalysisSettings.xlsx).
 
*Bands*. Start batch processing. Compute and report band summaries by subject and create a summary across subjects.

*Go (min)*. Reccomended batch processing option.  Visual (PPT) and numeric (XLS) summaries are created across subjects.  Visual summary allows for a rapid review of all subjects.

*Go (all)*.  Detail visual (PPT) and numeric (XLS) summaries by subject and across subjects.

*Compute Coherence*. Select check box to compute coherence between each pair of analysis signals.  Warning: the number of signal pair increases rapidly as the number of analysis signals grow. 

### Technical Overview
The functional component of the GUI is implemented as a single [class](http://en.wikipedia.org/wiki/Object-oriented_programming), which builds on the data access classes developed as part of the [Data Access and Visaulization (DAVS) Toolbox](https://github.com/DennisDean/DAVS-Toolbox). Most of the key components are written as classes. The class structure provides error checking and visual/numeric reporting capabilities and allows for the rapid development of a lean GUI. The use of PowerPoint and Excel as the standard ouput file type was selected so that research assistants with little programming experience can pre-screen large number of results. Many of the reccomendations for writing fast MATLAB script files are used in the program. The current time to process a single subject is currently 1 to 10 seconds on a medium size work station, depending on the number of outputs written to disk.  

#### MATLAB APP
The [MATLAB APP](http://www.mathworks.com/discovery/matlab-apps.html) is a great way to get started with spectral analysis of sleep studies. See the [release section](https://github.com/DennisDean/SpectralTrainFig/releases) for the most recent APP version.  Installing the APP version of [SignalRasterView](http://www.mathworks.com/matlabcentral/fileexchange/46420-blockedfsignalrasterview) is a quick way to review an EDF's content and to determine the signal labels. See the release section for the MATLAB App and sample data.  

#### Requirements
MATLAB 2013b or later, the MATLAB's Signal Processing toolbox and the MATLAB's Statistics toolbox are required. The [pwelch](http://www.mathworks.com/help/signal/ref/pwelch.html) function is used to compute  [EEG](http://en.wikipedia.org/wiki/Electroencephalography) spectra. The PPT generation functionality requires a MS Windows operating system. The memory and hard disk requirements are dependent on the size and number of sleep studies to be analyzed. The program can run on a laptop with 8 Gb of RAM.  The preferred configuration for a large number of studies is 16-32 Gb of RAM. Similarly, the required disk space is dependent on the number of signals processed, the number files selected and the number of ouputs generated by the program. 

#### Acknowledgments
Dozens of researchers, computer scientists, enginginners, technicians and research assistants assisted in the development of this program.

SpectralTrainFig uses several utilities available from the MATLAB file exchange area including:
-    [dirr](http://www.mathworks.com/matlabcentral/fileexchange/8682-dirr--find-files-recursively-filtering-name--date-or-bytes-) Used to create EDF/XMl file lists for processing
-    [moving](http://www.mathworks.com/matlabcentral/fileexchange/8251-moving-averages---moving-median-etc). Used to compute running band averages for the artifact detection computations.
-    [panel](http://www.mathworks.com/matlabcentral/fileexchange/20003-panel). Used to create a summary figure for review.
-    [saveppt2](http://www.mathworks.com/matlabcentral/fileexchange/19322-saveppt2). Used to create PPT summaries from MATLAB figures.

#### Related links
- [National Sleep Research Resource](https://sleepdata.org/)
- [Data Access and Visualization for Sleep Toolbox](https://github.com/DennisDean/DAVS-Toolbox)
- [My MATLAB File Exchange Contributions](http://www.mathworks.com/matlabcentral/fileexchange/?term=authorid:113409)
