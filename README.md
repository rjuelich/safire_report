This repository contains all original source code used in creation of the "Structural and Functional Imaging Report" (SAFIRe). Please note that the code was never intended to run outside of the cluster environment in which it was developed.

# DESCRIPTION OF PACKAGE DATA FLOW & FUNCTIONALITY

 1. Queries remote Postgres database to identify any new/previously unprocessed raw MRI files.
 2. Creates requisite directory on local compute cluster, syncs raw MRI files from remote database, and unpacks raw files into appropriate local structure.
 3. Parses MRI header files to determine values for variables used in structural processing, compiles configuration file, and submits job to complete structural processing.
 4. Parses MRI header files to determine values for variables used in functional processing, compiles configuration file, and submits job to complete functional processing.
 5. Parses MRI header files to determine values for variables used in quality control assessment, compiles configuration file, and submits job to complete quality control.
 6. Parses all individual values of interest from all .txt output files generated during structural/functional/QC processing, and computes corresponding age/brain-volume normalized Z-scores.
 7. Renders inflated brain surface image files, and captures snapshots at multiple angles.
 8. Captures internal slices of 3-D image file used to assess native-brain to template coregistration quality.
 9. Creates HTML structures for compiling desired output into single page report.
10. Exports compiled HTML to single page PDF.   

* The above functionality has been fully integrated/automated, i.e., no manual intervention is needed from the time a new MRI session hits our remote storage database to when the completed PDF is synced to the appropriate study/subject folder in the lab's shared Dropbox.


# DESCRIPTION OF PACKAGE CONTENTS

commons: Assortment of bash/MATLAB/Python code used for data visualization (MATLAB), within-subject functional-connectivity analysis (Python), and text parsing/HTML-generation/packaging (bash).

HTML_TEMPLATES: Templates used during compilation of final HTML file.

ICONS: Icons used during compilation of final HTML file.

MODULES: Core modules used for data syncronization, processing, and HTML packaging.

NORMS: Collection of files used during age/brain-volume normalization.

Example_Output.pdf: Example output file.

safire_wrap.sh: Top level wrapper to deploy all underlying code.

