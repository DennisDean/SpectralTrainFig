Spectral and Coherence Standard Operating Procedure
===================================================

The spectral and coherence SOP describes a data preparation/review, data analysis and results review phase.

#### Data Preparation and Review
The data preparation and review phase includes the step and checks required to prepare the data for analysis.  The current version is designed to work with Comumedics Profusion exports that include both an (EDF)[http://en.wikipedia.org/wiki/European_Data_Format] and annotation (XML) file.  In our experience EDF exports from other systems work seemlessly with our tools.  The class based annotation loader ([LoadCompumedicsAnnotations](https://github.com/DennisDean/LoadCompumedicsAnnotationsClass/blob/master/README.md]) can be revised to support other commercial file formats.

##### BlockEdfSummarizeFig
BlockEdfSummarizeFig is a utility designed to quickly summarize the contents of a folder which contains Compumedics EDF/XML exports.  The program assumes the EDF files are writtedn in the form *.EDF and that the annotation file is written as *.EDF.XML. All three summary files created by BlockEdfSummarizeFig should be reviewed prior to initiating data analysis. Steps required to generate each summary files are described below.

1. Open/Install BlockEdfSummarizeFig. (BlockEdfsummarizeFig)https://github.com/DennisDean/BlockEdfSummarizeFig] is available as MATLAB (source code)[https://github.com/DennisDean/BlockEdfSummarizeFig] and as a (MATLAB APP)[https://github.com/DennisDean/BlockEdfSummarizeFig/releases]. Information on how to instal a MATLAB APP can be found on the (MATLAB website)[http://www.mathworks.com/help/matlab/apps_bt44d44-1.html]. We reccomend that you make a shortcut on the MATLAB toolbar that switches to the BlockEdfSummariFig folder and starts BlockEdfSummarizeLoad.
2. Run BlockEdfSummarizeFig. Use the shorcut described in 1. or click on the APP from the APP menu (depends on the setup).
3. Select the folder to summarize.  Click on the elipses (...) to the right of the 'EDF Folder' edit text box.
4. Select the folder to write summary reports. Click on the 'Folder' button to select the location that the EXCEL files will be written to.
5. Generate the file list.  Click on the button labeled 'Create File List'.  A message will be written to the console when the file is generated.  Open the file

