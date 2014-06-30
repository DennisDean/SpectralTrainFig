##Spectral and Coherence SOP


The spectral and coherence standard operating procedure (SOP) describes a data preparation/review, data analysis and results review phase.

### Data Preparation and Review
The data preparation and review phase includes the step and checks required to prepare the data for analysis.  The current version is designed to work with Compumedics Profusion exports that include both an [EDF](http://en.wikipedia.org/wiki/European_Data_Format) and annotation (XML) file.  In our experience EDF exports from other systems work seemlessly with our tools.  The class based annotation loader ([LoadCompumedicsAnnotations](https://github.com/DennisDean/LoadCompumedicsAnnotationsClass/blob/master/README.md])) can be revised to support other commercial file formats. Information on loading other file formats can be found [here](http://sleep.partners.org/data-access/).

#### BlockEdfSummarizeFig
BlockEdfSummarizeFig is a utility designed to quickly summarize the contents of a folder that contains Compumedics EDF/XML exports.  The program assumes the EDF files are named in the form '*.EDF' and that the annotation files are named as '*.EDF.XML'. EDF and XML files for the same subject should be in the same folder. All three summary files created by BlockEdfSummarizeFig should be reviewed prior to initiating data analysis. Steps required to generate and review each summary file are described below.


**Getting Started**

1. *Open/Install BlockEdfSummarizeFig*. [BlockEdfsummarizeFig](https://github.com/DennisDean/BlockEdfSummarizeFig) is available as MATLAB [source code](https://github.com/DennisDean/BlockEdfSummarizeFig) and as a [MATLAB APP](https://github.com/DennisDean/BlockEdfSummarizeFig/releases). Information on how to install a MATLAB APP can be found on the [MATLAB website](http://www.mathworks.com/help/matlab/apps_bt44d44-1.html). We reccomend that you make a shortcut on the MATLAB toolbar that switches to the BlockEdfSummariFig folder and starts BlockEdfSummarizeLoad when using the source code version.

2. *Run BlockEdfSummarizeFig*. Use the shorcut described in 1. or click on the APP from the APP menu (depends on the setup).

3. *Select the folder to summarize*.  Click on the elipses (...) to the right of the 'EDF Folder' edit text box.

4. *Select the folder to write summary reports*. Click on the 'Folder' button to select the location that the EXCEL files will be written to.


**Generate Summary Reports**

5. *Generate the file list*.  Click on the button labeled 'Create File List'.  A message will be written to the console when the file is generated.

6. *Generate the EDF Check Summary*. Click on the button labeled 'EDF Check'. The output includes a brief summary of deviations and serverity from the EDF file format.

7. *Generate the EDF Signal Summary*. Click on the button labeled 'Signal' that generates and EXCEL file lists the signal contents for each EDF

8. *Generate the XML Check Summary*. Click on the button labeled 'XML Check' that generates and EXCEL file that checks whether the XML file can be loaded with out an error.

**Review Summary Reports**

9. *Review file list*. The file list should list '*.edf' files and '*.edf.xml' files in the appropriate column.  The data folder needs to be reviewed if the an error is generated or if the filenames are not organized as expected.  The naming convention is not followed and a file is missing are the two most common reasons warranting a review of the contents of the data folder.

10. *Review EDF Check Summary*. Files that generate an unexpected error/warning should be reviewed with an EDF viewer/checker. We reccomend using [BlockEdfSignalRasterView](http://www.mathworks.com/matlabcentral/fileexchange/46420-blockedfsignalrasterview) to check and review the EDF content. 

11. *Review Signal Summary*. Check that each file contains the signal labels required for the anlaysis. See the project leader/scientific lead if you are not sure which labels to check for.  The signal label check list should include the signal and reference label.

12. *Review the XML Check Summary*. Any file where the check flag is set to 1 should be reviewed.  In absence of an XML checker, the XML file marked with a 1 should be replaced from the central archive or re-exported from the Compumedics software.

### Data Analysis

SpectralTrainFig is used to perform spectral and coherence analysis.  The spectral analysis default values are set to the Division of Sleep and Circadian Disorders, Brigham and Women's Hospital, recommended values. The steps required to run an analysis includes identifying the data folder, setting the default results and initiating the analysis based on the amount ouput saved by the program. Seperate reccomendations are provided for running coherence analysis.

**Spectral Analysis**

1. *Set Analysis Description*. Enter a string that describes the analysis (optional)

2. *Set File Prefix*. Add cohort descriptor or other identifying text.  Adding the settings to the prefix can be helpful for reviewing studies that involve changing analysis settings

3. *Set Data Source Folder*. Click on the elipses (...) to the right of the 'Data Folder' edit box. Select the data folder.

4. *Set Result Folder*. Click on the elipses (...) to the right of the left of the 'Result Folder' edit box. Select the result folder.

5. *Set Spectral Analysis Parameters*. The spectral analysis parameters are set to our internal default. Parameters are deccribed in more detail here.

6. Load Analysis Bands. Load an analysis band EXCEL file if the number and/or frequency range of the analyais bands are to be changed.

7. *Initiate Spectral Analysis*. For most analyses, it is reccomended that you click on 'Go(min)' which provides enough output to visualy check the results for each subject, in addition to the EXCEL files which contain both subject and group summaries.  


**Coherence Analysis**
The coherence analysis steps are the same as for spectral analysis with two additions. The 'Coherence Analysis' check box at the bottom of GUI should be checked. Coherence analysis is hard coded to use 6x5 second sub-epochs. Spectral settings popup menu should be set to '6x5second sub-epochs, Hanning Window.'

*Warning*. Coherence analysis can be time consuming and may generate substantial ouput. As much as 2Gb of output can be generated. It is reccomended that spectral analysis is run first on the data set.  Once data organization and content issues are resolved, coherence analysis is likely to complete in one run.  

**Error Recovery**
Use the 'Start' popup menu to start the the analyiss at a particular file id (see generated file list in result folder). It is recommended that the subject's files are either removed or the data issue is fixed.  Note that if files are removed, the file lists generated in the previous run should be deleted. Group summaries require all the subjects to be analyzed in one run. Rerun analysis from begining once all data issues are resolved.


### Result Review
Review the MS PowerPoint Summaries and all of the group summary files (ex. bands and spectra). Identify spectra with non-physiological components or substantial missing data.  Substantial signal contamination (ECG, EMG, artifact) should be identfied for team review/exclusion prior to analysis. Please discuss specific review requirements with scientific lead, since hypothesis specific inclusion/exclusions may be required.
