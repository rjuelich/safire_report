#!/usr/bin/env python
'''
Conduct group analyses of procsurffast.csh output.
Must be run from folder containing the processed subjects.


import neuro
neuro.load("1.5.4")

import os
import csv
import sys
import argparse
import json
from lxml import etree
from numpy import median,average
from datetime import datetime
from glob import glob
import neuro.app as app
import neuro.config as config
from neuro.system import *
from neuro.filesystem import *
from neuro.strings import *
from neuro.arrays import *
from neuro.command import Command
from neuro.apps.xnat import Xnat 
from neuro.models.xml import XML
from pipes import quote
from StringIO import StringIO
import numpy as Numeric
import fnmatch

## --- enable debugging
config.debug = True

## --- parse command line arguments
parser = argparse.ArgumentParser(description="ProcSurfFast 2Dmatrix data pipeline")
parser.add_argument("-s", "--sid", required=True, help="CSV file name")
parser.add_argument("-q", "--quiet", action="store_true", help="Quiet all logging output")
parser.add_argument("-o", "--out-dir", default=(os.getcwd() + "/"), help="Output directory")
parser.add_argument("-i", "--input-dir", default=(os.getcwd() + "/"), help="Input data directory")
parser.add_argument("-p", "--pval", required=True, help="Log transformed P-value threshold (e.g., 1.301 = p < 0.05)")
parser.add_argument("-reg", "--regression", action="store_true", help="Run a regression in PlotFullMeanCorr_Matrix rather than an ANOVA")
parser.add_argument("-noCov", "--no-covariates", action="store_true", help="Run analyses WITHOUT covariates (e.g., Age, Gender)")
parser.add_argument("-dmri", "--define-fmri", default="AllBoldRuns", help="Input CSV file name to run procsurffast on select scans (e.g., SUBJNAME,17,18). Without this flag all runs in SUBJNAME/surf are processed.")
parser.add_argument("-a", "--already-ran", action="store_false", help="Already ran ComputeNetworkClusterCorrelation. Skip to PlotFullMeanCorr_Matrix")
parser.add_argument("-nm", "--no-matrix", action="store_true", help="Already ran PlotFullMeanCorr_Matrix 2D matrix step. Can be used in conjunction with --already-ran flag to skip to the --surface-maps analyses")
parser.add_argument("-subjsm", "--subj-surface-maps", action="store_true", help="Generate surface maps for each subject, each ROI. NOTE: Must be run if you intend to generate the group surface maps")
parser.add_argument("-grpsm", "--group-surface-maps", action="store_true", help="Generate surface maps for each ROI in the group analyses")

args = parser.parse_args(sys.argv[1:])
csv_file = args.sid
quiet = args.quiet
outdir = args.out_dir
indir = args.input_dir
PvalueThresh = args.pval
alreadyRan = args.already_ran
regStore = args.regression
no_covars = args.no_covariates
defMRI = args.define_fmri
surfmaps = args.group_surface_maps
subjsurfmaps = args.subj_surface_maps
nomatrix = args.no_matrix

## --- sets seed file location. NOTE: Files must end with .lh.txt or .rh.txt for the left and righ hemi files
cortex_seed_header=("/eris/sbdp/GSP_Subject_Data/Surface_ROIs/ROIList_networkcomponents_017.symmetric.")

## --- pulls off the .csv extension from the CSV filename
csv_namestrip = (os.path.splitext(csv_file)[0])

## --- get application logger
logger = app.getLogger()
logger.setFilename(outdir + csv_namestrip + "_analysis.log")

print("Running ProcSurfFast 2Dmatrix data pipeline")

if(quiet):
	logger.setDestination("null")

logger.info("Current User: " + os.getlogin())
logger.info("Time: " + strftime("%Y.%m.%d_%H:%M:%S_%Z"))
logger.info("Processing data for: " + csv_file)

## --- import csv file
csv_str = fileGetContents(csv_file)

if(csv_str.strip() == ""):
	logger.fatal("CSV file is empty")

## --- load the string into a file-like-object e.g., StringIO
stringio = StringIO(csv_str)

## --- read the csv and compile it into a list of lists
csvarray = list()
try:
	reader = csv.reader(stringio, delimiter=",")

	for row in reader:
		csvarray.append(row)
except Exception, e:
	logger.fatal("ERROR: Failed to convert survey CSV into an array (try examining the input CSV file)")

if(defMRI != "AllBoldRuns"): 
	## --- only include defMRI runs in the analyses
	print("Selecting bold runs from the following csv: " + defMRI)
	logger.info("Selecting bold runs from the following csv: " + defMRI)
	defMRI_str = fileGetContents(defMRI)
	if(defMRI_str.strip() == ""):
		print("ERROR: " + defMRI + " file is empty")
		logger.fatal("ERROR: " + defMRI + " file is empty")
	## --- load the string into a file-like-object e.g., StringIO
	defMRIio = StringIO(defMRI_str)
	
	## --- read the csv and compile it into a list of lists
	defMRIarray = list()
	try:
		defMRIreader = csv.reader(defMRIio, delimiter=",")	
		for row in defMRIreader:
			defMRIarray.append(row)
	except Exception, e:
		logger.fatal("ERROR: Failed to convert " + defMRI + "into an array (try examining the input CSV file)")
	## -- check to make sure the csvarray and defMRIarray subject names match
	for x in range(0,len(csvarray)): 
		if(defMRIarray[x][0] == csvarray[x][0]) == False:	
			print("ERROR: " + defMRI + " " + csv_file + " subject name mismatch in column one. Check the input CSV files")
			logger.fatal("ERROR: " + defMRI + " " + csv_file + " subject name mismatch in column one. Check the input CSV files")	

## --- Create output directory for surface data if --surface-maps flag is selected
surfYes = 0
surfLoc = ("Skipping")
if(surfmaps):
	## --- checks to make sure individual subject surface files are present
	if(subjsurfmaps == False):
		for rowtracker in range(len(csvarray)):
			row = csvarray[rowtracker]
			print("Checking surf_fcMRI files for " + row[0])
			if(defMRI == "AllBoldRuns"):
				liststore = ("")
			else:		
				line = defMRIarray[rowtracker]		
				if row[0] == line[0]:
					liststore = ("_runs_" + implode(line[1:],"_"))

			for hemi in ["lh","rh"]:
				cortex_seeds=(cortex_seed_header + hemi + ".txt")	
				roi_str = fileGetContents(cortex_seed_header + hemi + ".txt")
				if(roi_str.strip() == ""):
					logger.fatal(cortex_seeds + " file is empty")
				## --- load the string into a file-like-object e.g., StringIO
				stringio = StringIO(roi_str)
				## --- read the csv and compile it into a list of lists
				roiarray = list()
				try:
					reader = csv.reader(stringio, delimiter=",")
					for line in reader:
						roiarray.append(line)
				except Exception, e:	
					logger.fatal("ERROR: Failed to convert " + cortex_seeds + " into an array (try examining the input file)")
				## --- run through to check each ROI
				for roi in roiarray:
					if os.path.isfile(str(indir) + str(row[0]) + "/surf_fcMRI/" + hemi + "." + os.path.basename(roi[0]) + liststore + ".fcMRI.nii.gz") != True:
						print("ERROR: Data file is missing in " + indir + row[0] + "/surf_fcMRI/" + hemi + "." + os.path.basename(roi[0]) + liststore + ".fcMRI.nii.gz")
						logger.fatal("ERROR: Data file is missing in " + indir + row[0] + "/surf_fcMRI/" + hemi + "." + os.path.basename(roi[0]) + liststore + ".fcMRI.nii.gz") 

	surfYes = 1
	print("Using --surface-maps flag")
	logger.info("Using --surface-maps flag")
	## --- building output directory
	try:
		logger.info("Creating output directory: " + str(outdir) + "SurfMaps/")
		surfOut = mkdir(str(outdir) + "SurfMaps/")
		surfOut = outdir
		surfLoc = indir
	except Exception, e:
		print("ERROR: Failed to create output directory: " + str(outdir) + "SurfMaps/")
		print("ERROR: " + str(outdir) + "SurfMaps/ exists")
		logger.info("ERROR: Failed to create output directory: " + str(outdir) + "SurfMaps/")
		logger.info("ERROR: " + str(outdir) + "SurfMaps/ exists")
		surfOut = outdir
		surfLoc = indir

if(alreadyRan):
	inputbolds = {}
	inputbolds["lh"] = list()
	inputbolds["rh"] = list()

	for hemi in ["lh","rh"]:
		boldlist = open(outdir + hemi + "." + csv_namestrip + "_bold.list", "wb")
		sublist = open(outdir + csv_namestrip + "_subject.list", "wb")
		## --- build bold lists
		print("Creating bold input file: " + outdir + csv_namestrip + "_" + hemi + ".list")
		logger.info("Creating bold input file: " + outdir + csv_namestrip + "_" + hemi + ".list")
		

		if(defMRI == "AllBoldRuns"):
			for row in csvarray:
				try:
					for file in os.listdir(str(indir) + str(row[0]) + "/surf/"):
						if fnmatch.fnmatch(file, hemi + ".*_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_fsaverage6_sm6_fsaverage5.nii.gz"):	
							inputbolds[hemi].append(indir + str(row[0]) + "/surf/" + file)
				except Exception, e:
					print("ERROR: Data file is missing in " + str(indir) + str(row[0]) + "/surf/")
					logger.fatal("ERROR: Data file is missing in " + str(indir) + str(row[0]) + "/surf/") 

				sub_bold = open(outdir + csv_namestrip + "_" + row[0] + "_" + hemi + "_allruns_bold.list", "wb")				
				sub_bold.write(implode(inputbolds[hemi], " ") + "\n")
				sublist.write(str(row[0])+"\n")
				boldlist.write(implode(inputbolds[hemi], " ") + "\n")
				inputbolds[hemi] = list()

		else: 
			## --- only include defMRI runs in the analyses
			for row in defMRIarray:
				for boldrun in (row[1:]):
					filestore = (hemi + "." + row[0] + "_bld" + boldrun.zfill(3) + "_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_fsaverage6_sm6_fsaverage5.nii.gz")
					if os.path.exists(str(indir) + str(row[0]) + "/surf/" + filestore) == False:
						print("ERROR: Data file is missing in " + str(indir) + str(row[0]) + "/surf/" + filestore)
						logger.fatal("ERROR: Data file is missing in " + str(indir) + str(row[0]) + "/surf/" + filestore)
					try:
						for file in os.listdir(str(indir) + str(row[0]) + "/surf/"):
							if fnmatch.fnmatch(file, filestore):	
								inputbolds[hemi].append(indir + str(row[0]) + "/surf/" + file)
					except Exception, e:
						print("ERROR: Data file is missing in " + str(indir) + str(row[0]) + "/surf/")
						logger.fatal("ERROR: Data file is missing in " + str(indir) + str(row[0]) + "/surf/") 
				sub_bold = open(outdir + csv_namestrip + "_" + row[0] + "_" + hemi + "_runs_" + implode(row[1:],"_") +  "_bold.list", "wb")				
				sub_bold.write(implode(inputbolds[hemi], " ") + "\n")
				sublist.write(str(row[0])+"\n")
				boldlist.write(implode(inputbolds[hemi], " ") + "\n")
				inputbolds[hemi] = list()
		sub_bold.close()
		sublist.close()	
		boldlist.close()
	
	## --- generate the individual subject surface maps
	if(subjsurfmaps):
		logger.info("Running ComputeNetworkClusterCorrelation to generate subject surface maps on " + csv_file)
		print("Running ComputeNetworkClusterCorrelation to generate subject surface maps on " + csv_file)
		for rowtracker in range(len(csvarray)):
			row = csvarray[rowtracker]
	
			if(defMRI == "AllBoldRuns"):
				liststore = ("")
			else:		
				line = defMRIarray[rowtracker]		
				if row[0] == line[0]:
					liststore = ("_runs_" + implode(line[1:],"_"))

			for hemi in ["lh","rh"]:	
				logger.info("Computing " + hemi + " to " + hemi + " correlations")
				output_file = (indir + row[0] + "/surf_fcMRI/")
				cortex_seeds=(cortex_seed_header + hemi + ".txt")	
				boldvar1 = (outdir + csv_namestrip + "_" + row[0] + "_" + hemi + liststore + "_bold.list") 
				boldvar2 = (outdir + csv_namestrip + "_" + row[0] + "_" + hemi + liststore + "_bold.list")
				
				roi_str = fileGetContents(cortex_seed_header + hemi + ".txt")

				if(roi_str.strip() == ""):
					logger.fatal(cortex_seeds + " file is empty")
	
				## --- load the string into a file-like-object e.g., StringIO
				stringio = StringIO(roi_str)
	
				## --- read the csv and compile it into a list of lists
				roiarray = list()
				try:
					reader = csv.reader(stringio, delimiter=",")
				
					for line in reader:
						roiarray.append(line)
				except Exception, e:
					logger.fatal("ERROR: Failed to convert " + cortex_seeds + " into an array (try examining the input file)")
				## --- run through each ROI
				for roi in roiarray:
					print("Generating surface data for " + row[0] + " " + os.path.basename(roi[0]) + " " + liststore)
					roi2roi = Command("ComputeROIs2WholeBrainCorrelationWithRegression " + output_file + hemi + "." + os.path.basename(roi[0]) + liststore + ".fcMRI.nii.gz " + boldvar1 + " " + " " + boldvar1 + " " + roi[0] + " NONE NONE NONE")
					roi2roi.execute()
					logger.info("Completed command: " + roi2roi.getStdout())
					logger.info("Created corr_mat " + output_file)

	## --- run ComputeROIs2ROIsCorrelationWithRegression on each hemisphere
	logger.info("Running ComputeNetworkClusterCorrelation on " + csv_file)
	print("Running ComputeNetworkClusterCorrelation on " + csv_file)
	for hemi in ["lh","rh"]:	
		logger.info("Computing " + hemi + " to " + hemi + " correlations")
		output_file = (outdir + csv_namestrip + "_" + hemi + "_" + hemi + "_ROIList_networkcomponents_017.symmetric." + hemi + ".mat")
		cortex_seed1=(cortex_seed_header + hemi + ".txt")	
		boldvar1 = (outdir + hemi + "." + csv_namestrip + "_bold.list") 
		boldvar2 = (outdir + hemi + "." + csv_namestrip + "_bold.list") 	

		roi2roi = Command("ComputeROIs2ROIsCorrelationWithRegression " + output_file + " " + boldvar1 + " " + boldvar2 + " " + cortex_seed1 + " " + cortex_seed1 + " NONE NONE 1")
		roi2roi.execute()
		logger.info("Completed command: " + roi2roi.getStdout())
		logger.info("Created corr_mat " + output_file)

	## --- run ComputeROIs2ROIsCorrelationWithRegression across the hemispheres
	logger.info("Running cross-hemispheric correlation")
	print("Running cross-hemispheric correlation")

	output_file = (outdir + csv_namestrip + "_lh_rh_ROIList_networkcomponents_017.symmetric.lh_rh.mat")
	cortex_seed1=(cortex_seed_header + "lh.txt")
	cortex_seed2=(cortex_seed_header + "rh.txt")
	boldvar1 = (outdir + "lh." + csv_namestrip + "_bold.list") 
	boldvar2 = (outdir + "rh." + csv_namestrip + "_bold.list") 

	roi2roi = Command("ComputeROIs2ROIsCorrelationWithRegression " + output_file + " " + boldvar1 + " " + boldvar2 + " " + cortex_seed1 + " " + cortex_seed2 + " NONE NONE 1")
	
	roi2roi.execute()
	logger.info("Completed command: " + roi2roi.getStdout())
	print("Completed command: " + roi2roi.getStdout())

	logger.info("Created corr_mat " + output_file)

else: 
	print("Ran with --already-ran flag. Skipped ComputeROIs2ROIsCorrelationWithRegression")
	logger.info("Run with --already-ran flag. Skipped ComputeROIs2ROIsCorrelationWithRegression")

## --- Checks to make sure ComputeROIs2ROIsCorrelationWithRegression data exists
if (os.path.isfile(outdir + csv_namestrip + "_lh_rh_ROIList_networkcomponents_017.symmetric.lh_rh.mat"))==False:
	print("ERROR: ComputeROIs2ROIsCorrelationWithRegression output does not exist.")
	logger.fatal("ERROR: ComputeROIs2ROIsCorrelationWithRegression output does not exist.")
if (os.path.isfile(outdir + csv_namestrip + "_lh_lh_ROIList_networkcomponents_017.symmetric.lh.mat"))==False:
	print("ERROR: ComputeROIs2ROIsCorrelationWithRegression output does not exist.")
	logger.fatal("ERROR: ComputeROIs2ROIsCorrelationWithRegression output does not exist.")
if (os.path.isfile(outdir + csv_namestrip + "_rh_rh_ROIList_networkcomponents_017.symmetric.rh.mat"))==False:
	print("ERROR: ComputeROIs2ROIsCorrelationWithRegression output does not exist.")
	logger.fatal("ERROR: ComputeROIs2ROIsCorrelationWithRegression output does not exist.")

## --- run PlotFullMeanCorr_TwoGroupANOVA.
logger.info("PlotFullMeanCorr_Matrix_130311.m group analyses")
print("Running PlotFullMeanCorr_Matrix_130311.m group analyses")

#if (os.path.isfile(os.getcwd() + "/PlotFullMeanCorr_Matrix_130311.m"))==False:
#	print("ERROR: " + os.getcwd() + "PlotFullMeanCorr_Matrix_130311.m does not exist.")
#	logger.fatal("ERROR: " + os.getcwd() + "PlotFullMeanCorr_Matrix_130311.m does not exist.")

regYes = 1
if(regStore):
	regYes = 2
	print("Using --regression flag")
	logger.info("Using --regression flag")

ConsiderCovars = 1
if(no_covars):
	ConsiderCovars = 2
	print("Using --no-covariates flag")
	logger.info("Using --no-covariates flag")

matrixYes = 1
if(nomatrix):
	matrixYes = 0

## --- build and then run PlotFullMeanCorr_Matrix.m command
MatrixCommand = ("""matlab -nojvm -nosplash -nodesktop -nodisplay -r "try, PlotFullMean_Indiv_130530('""" + csv_namestrip + """','""" + csv_namestrip + """','""" + outdir + """',""" + PvalueThresh + """,""" + str(regYes) + """,""" + str(ConsiderCovars) + """,""" + str(surfYes) + """,'""" + surfLoc + """','""" + cortex_seed_header + """',""" + str(matrixYes) + """,'""" + defMRI + """'), catch, display('PlotFullMeanCorr_Matrix.m error check script'),end; exit;" """)

print("Command called: " + MatrixCommand)
logger.info("Command called: " + MatrixCommand)

matrix=Command(MatrixCommand)
matrix.execute()
logger.info("Completed command: " + matrix.getStdout())
print("Completed command: " + matrix.getStdout())
logger.info("Created 2D matrix results for csv_file")


