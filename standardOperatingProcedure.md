Spectral and Coherence
Standard Operating Procedure
============================

The spectral and coherence SOP describes a data preparation/review, data analysis and results review phase.

### Data Preparation and Review
The data preparation and review phase includes the step and checks required to prepare the data for analysis.  The current version is designed to work with Compumedics Profusion exports that include both an [EDF](http://en.wikipedia.org/wiki/European_Data_Format) and annotation (XML) file.  In our experience EDF exports from other systems work seemlessly with our tools.  The class based annotation loader ([LoadCompumedicsAnnotations](https://github.com/DennisDean/LoadCompumedicsAnnotationsClass/blob/master/README.md]) can be revised to support other commercial file formats.

#### BlockEdfSummarizeFig
BlockEdfSummarizeFig is a utility designed to quickly summarize the contents of a folder which contains Compumedics EDF/XML exports.  The program assumes the EDF files are writtedn in the form *.EDF and that the annotation file is written as *.EDF.XML. EDF and XML files for the same subject should be in the same folder. All three summary files created by BlockEdfSummarizeFig should be reviewed prior to initiating data analysis. Steps required to generate each summary files are described below.


**Getting Started**

1. *Open/Install BlockEdfSummarizeFig*. [BlockEdfsummarizeFig](https://github.com/DennisDean/BlockEdfSummarizeFig) is available as MATLAB [source code](https://github.com/DennisDean/BlockEdfSummarizeFig) and as a [MATLAB APP](https://github.com/DennisDean/BlockEdfSummarizeFig/releases). Information on how to install a MATLAB APP can be found on the (MATLAB website)[http://www.mathworks.com/help/matlab/apps_bt44d44-1.html]. We reccomend that you make a shortcut on the MATLAB toolbar that switches to the BlockEdfSummariFig folder and starts BlockEdfSummarizeLoad.

2. *Run BlockEdfSummarizeFig*. Use the shorcut described in 1. or click on the APP from the APP menu (depends on the setup).

3. *Select the folder to summarize*.  Click on the elipses (...) to the right of the 'EDF Folder' edit text box.

4. *Select the folder to write summary reports*. Click on the 'Folder' button to select the location that the EXCEL files will be written to.


**Generate Summary Reports**

5. *Generate the file list*.  Click on the button labeled 'Create File List'.  A message will be written to the console when the file is generated.

6. *Generate the EDF Check Summary*. Click on the button labeled 'EDF Check'. The output includes a brief summary of deviations and serverity from the EDF file format.

7. *Generate the EDF Signal Summary*. Click on the button labeled 'Signal' that generates and EXCEL file lists the signal contents for each EDF

8. *Generate the XML Check Summary*. Click on the button labeled 'XML Check' that generates and EXCEL file that checks whether the XML file can be loaded with out an error.

**Review Summary Reports*

9. *Review file list*. The file list should list *.edf files and *.edf.xml files in the appropriate column.  The data folder needs to be review if the an error is generated or if the filenames are organized as expected.  The two most common reasons for an issue to arise is tht the naming convention is not followed or when a file is missing.

10. *Review EDF Check Summary*. Files that generate an unexpected error/warning should be reviewed with an EDF viewer/checker. We reccomend using [BlockEdfSignalRasterView](http://www.mathworks.com/matlabcentral/fileexchange/46420-blockedfsignalrasterview) to check and review the EDF content. 

11. *Review Signal Summary*. Check that each file contains the signal labels required for the anlaysis. See the project leader/scientific lead if you are not sure which labels to check for.  The signal label check list should include the signal and reference label.

12. *Review the XML Check Summary*. Any file where the check flag is set to 1 should be reviewed.  In absence of an XML checker, the XML file marked with a 1 should be replaced from the central archive or re-exported from compumedics.

