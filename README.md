SpectralTrainFig
================

SpectralTrainFig is a graphical user interface that allows a user to select a folder of EDF/XML files to process. The GUI is configured to apply spectral analysis to the electroencephlography signal (EEG). The default spectral analysis parameters include 10x4 second sub-epochs with a 50% tukey window. Alternatively the user can set the spectral analysis parameters to the ones used for the SHHS study (6x5 second with Hanning window). The user can adjust the artifact detection thresholds, which are preset to reccomended values.  SpectralTrainFig is a user friendly approach to the SpectralAnalysisClass function which provides access to 56 parameters (artifact detection, spectral analysis, and figure configurations). The output includes EXCEL and PowerPoint summaries which are configured by user defined settings and specified spectral bands. Detail epoch by epoch and subject summaries are provided for both NREM and REM states.  

#### MATLAB APP
See the release section for the MATLAB App and sample data. The MATLAB APP is a great way to get started with spectral analysis of sleep studies.

#### Requirements
The memory and hard disk requirements are dependent on the size and number of sleep studies to be analyzed. The program can run on a laptop with 8 Gb of RAM.  The preferred configurtion for a large number of studies is 16-32 Gb of RAM.   
