#!/bin/python
desc = ('''
In this script we create a table summarizing the most important quality checks for each salmon run
''')
### LIBRARIES ###
import pandas as pd
import argparse


### ARGUMENTS ###
parser = argparse.ArgumentParser(description = desc)
parser.add_argument(
        '-s', '--samples', help = 'list of metadata per sample', required = True, default = '/lustre/scratch/users/pieter.clauw/Transcriptome/6vs16/Data/samples.txt')

parser.add_argument(
        '-S', '--Salmon', help = 'Give file with all directories of results from salmon runs to be compared', required = True, default = '/lustre/scratch/users/pieter.clauw/Temp/salmonDirs.txt')

parser.add_argument(
        '-o', '--outputFile', help = 'output file (csv)', required = True)
args = parser.parse_args()

# Everything after the parameter will be take as a result value
columns = ['sample', 'accession', 'temperature', 'replicate', 'mappingRate']


openSalmon = open(args.Salmon, 'r')
salmonDirs = openSalmon.readlines()
openSalmon.close()
salmonDirs = [dir.rstrip() for dir in salmonDirs]

'''
iterate over sample list and output the required data to a pd.dataframe
'''

### FUNCTIONS ###
def getParameterValues(parameter, line):
	value = line.rstrip().split(parameter)[1]
	print(parameter + value)
	return value

def processLogfile(logFile):
	with open(logFile, 'r') as openlog:
		mapRate = str()
		for line in openlog:
			if 'Mapping rate' in line:
				mapRate = line.rstrip().split()[7]

	data = [sample, acn, temp, rep, mapRate]
	salmonQuality.loc[sample] = data
	



salmonQuality = pd.DataFrame(columns = columns)

with open(args.samples, 'r') as samples:
	next(samples)
	for line in samples:
		fields = line.rstrip().split('\t')
		if fields[10] != 'yes': continue # skip the samples that were not selected for transcriptome analysis
		sample = fields[0]
		acn = fields[1]
		temp = fields[2]
		rep = fields[3]
		base = fields[4]
		salmonDir = [dir for dir in salmonDirs if base in dir]
		logFiles = [dir + '/logs/salmon_quant.log' for dir in salmonDir]
		[processLogfile(logFile) for logFile in logFiles]

#TODO: write this as function

#write out pandas dataframe to txt
salmonQuality.to_csv(args.outputFile)
