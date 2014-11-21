##Spectral and Coherence SOP

## Purpose

Procedures for using SpectralTrainFig to analyze sleep cohort data are described below.  Emphasis is on the procedures and assigned responsiblities to insure that the input and generated data are suitable for secondary analyes.

## Scope

The document describes responsibilites, procedures and references relative to the flow of information starting with identifying a dataset to analayze to making data available for data analysis.

## Responsiblities

1. Data Preparer.  SpectralTrainFig requires a sleep study (edf) and an annotation file (XML) for each subject/condition to be analyzed. The data should be organized in a folder.  The Data Preparer should consult the investigator assigned to the analysis about checks needed to be vperformed to the data prior to analysis. The data preparer should check that the conditions required for conducting the analysis are met (ex. sampling rate and required signals). BlockEdfSummarize has been developed to perform a wide range of checks.  If additional checks are required are not currently available, the informatics and research development team should be consulted.
2. Senior Technician. The senior technician is responsible for insuring that spectral analysis SOPs are followed, to perform initial manual adjudication of all studies process, coordinate with the investigators responsible for reviewing problematic studies, and insuring that results are transferred with appropriate documentation to the informatics team/investigator for posting/analysis. The senior technician will also document the data and software issues identified. All data issues will be investigated by the senior technician.  The senior technician will take the lead in resolving data issues; which should results in the data excluded from analysis, a change in operating procedure, or a coordinated effort to update the analysis programs to resolve the issue for future analyses. A folder labeled with change date and containing each update of the analysis software (compiled and source code) will also be kept.
3. Data Review and Analysis Developer. The developer creates computer source code that processes some aspect of electronic data. The developer will insure that source code is versioned, documented and tested with a plan approved by a/the chief architect/Developer. Source code, results of testing and documentation will be archived on the network drives according to project requirements.  Migrating support materials to a GitHub site is encourages so that public review is possible. GitHub release sections will be used to document program change history (either local or public depending on project).  
4. Chief Data Review and Analysis Architect/Developer. The data review and analysis developer is responsible for insuring that all software tools are versioned, verified and validated.  When additional programmers, analysis and research assistants are required; the architect and developer will be responsible for supervising, reviewing and certifying the work. A major responsibility of the Chief Architect/Developer is to review source code, documentation, and testing procedure.  Aspects of operating procedures pertaining to technical requirements will be reviewed to insure software tools are consistent with operational requirements. The chief developer will write methods sections for grants and papers. Program validations will be documented as reports or scientific publications as required. 
5. Chief Technician/Project Manager. The project Manager is responsible for insuring that procedures are consistently followed across projects, allocating resources to resolve issues as they arise, and recruiting domain experts to consult/resolve new issues that cannot be resolve by the current staff complement.
6. Investigators/Adjudication Experts. Investigators are responsible for specifying deviations from established SOPs that may be required for a particular analysis, resolving new issues that may arise as data sets are processed and insuring appropriate quality control is performed on the results prior to analysis.
7. Statistical Core.  The statistical core is responsible for working with developers to develop verified statistical scripts for performing standard analyses and preparing data/results for posting. The statistical core also share testing/documentation responsibilities described in the developer sections (3 and 4). The statistical core will create data dictionary that describe the variables that will be made available with each data set.
8. Informatics Core. The informatics core is responsible for working with the statistical core to make data/results available through a WWW interface. The informatics core also shares the testing/documentation responsibilities described in the developer sections (3 and 4).
9. Spectral Analysis Working Group.  The primary goal of the working group is to insure consistent procedures are maintained across analyses and that quality control procedures are updated as necessary. The spectral analysis working group consists of individuals with key responsibilities along the spectral analysis pipeline. The group will meet once a month to review documentation, issues and analyses as necessary. When changes to the procedures and tools are required, the working group will define time lines for change implementation and will review documentation verifying changes were implemented as defined.  
## Procedures

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

## References
[SpectralTrainFig](https://github.com/DennisDean/SpectralTrainFig)
[BlockEdfSummarizeFig](https://github.com/DennisDean/BlockEdfSummarizeFig)
Manual Adjudication and Training Manual

