# find JSON information on proposed matches

### Import samples table
import pandas as pd  
samples = pd.read_table('/groups/nordborg/projects/cegs/16Vs6C/Data/Transcriptome/RawData/samples.txt')
#samples.head()

### Create list with all samples names
all_samples = samples['basename'].to_list()
#print(all_samples)
#len(all_samples)

### Import path for every json file
import os
files = []

for file in os.listdir('/scratch-cbe/users/pieter.clauw/16vs6/Results/Transcriptome/genotyping/snpmatch/'):
    if '.json' in file:
        files.append(file)

#print(len(files))

### Do comparison between expected and calculated acn, create output table
data = []

for smpl in all_samples:
    for jsonfile in files:
        if smpl in jsonfile:
            row = [smpl] #sample name
            with open(os.path.join('/scratch-cbe/users/pieter.clauw/16vs6/Results/Transcriptome/genotyping/snpmatch', jsonfile), 'r') as f:
                match = json.load(f)
                match = pd.DataFrame(match['matches'])
            acn = samples.loc[samples['basename'] == smpl, 'accession'].iloc[0] # expected acn
            row.append(acn)
            if str(acn) in set(match[0]):
                row.append('Yes') #yn
                row.append(match.index[match[0] == str(acn)][0] + 1) #rank
            else: 
                row.append('No') #yn
                row.append('/') #rank
            if len(match) == 1:  #unique hit
                row.append('Yes')
            else:
                row.append('No')
            row.append(match.loc[0,0]) #acn with highest probability
            data.append(row)
            
df = pd.DataFrame(data, columns = ['Sample', 'Expected_acn', 'Match', 'Rank', 'Unique_hit', 'Acn_highest_prob'])

# Write output table 
df.to_csv(r'Acn_matching.txt', header= True, index=None, sep=' ', mode='a')



