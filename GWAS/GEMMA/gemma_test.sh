# playground for gemma


# MODULES #
ml gemma/0.98.1-foss-2018b
ml plink/1.9b_6.10-x86_64
reformK=~/GitRepos/GWAStoolbox/GEMMA/kinshipMatrix.py
multiPhenoFAM=~/GitRepos/GWAStoolbox/GEMMA/multiPhenoFAM.py


# DATA #
GENO=~/GitRepos/GEMMA/example/mouse_hs1940.geno.txt.gz
PHENO=~/GitRepos/GEMMA/example/mouse_hs1940.pheno.txt
ANNO=~/GitRepos/GEMMA/example/mouse_hs1940.anno.txt
K=./output/mouse_hs1940.cXX.txt


# compute Kinship matrix
gemma -g $GENO -p $PHENO \
        -gk -o mouse_hs1940
# run univariate LMM
gemma -g $GENO \
        -p $PHENO -n 1 -a $ANNO \
            -k $K -lmm -o mouse_hs1940_CD8_lmm



# ARABIDOPSIS #

# BIMBAM
OUT=/scratch-cbe/users/pieter.clauw/16vs6/GEMMA_TEST/Data/GEMMA

## phenotype
i=2
j=$(expr $i + 1)
allphenotypes=/groups/nordborg/user/pieter.clauw/Documents/Experiments/UltimateQandD/Data/Metabolites/GWAS/metabolites.csv
trait=$(head -n 1 $allphenotypes | cut -d',' -f $i | cut -d'_' -f 1)
PHENO=/tmp/${trait}_16vs6.csv

awk -F ',' -v OFS='\t' -v t1="$i" -v t2="$j" 'NR==1 {print "FID","IID",$t1,$t2}  NR>1 {print $1,$1,$t1,$t2}' $allphenotypes > $PHENO
# awk -F ',' -v OFS='\t' -v t1="$i" -v t2="$j" '{print $1,$1,$t1,$t2}' $allphenotypes > $PHENO

# split phenotypes



## genotype
VCF=/scratch-cbe/users/pieter.clauw/SNPs/1001genomes_snp-short-indel_only_ACGTN.vcf.gz

## recode to bimbam
# plink --vcf $VCF --pheno $PHENO --recode-bimbam --snps-only --out $OUT --prune --allow-no-sex

## recode to PLINK .bed .bim .fam
plink --vcf $VCF --pheno $PHENO --make-bed --snps-only --out $OUT --prune --allow-no-sex --all-pheno 

fam=/scratch-cbe/users/pieter.clauw/16vs6/GEMMA_TEST/Data/GEMMA.fam 

## write multivariable .fam file
python $multiPhenoFAM -F $fam -P $allphenotypes -C $i $j

# reformat kinship matrix
Khdf='/groups/nordborg/projects/nordborg_common/datasets/genotypes_for_pygwas/1.0.0/1001genomes/kinship_ibs_binary_mac5.h5py'
K=${OUT}.K.txt
geno=${OUT}.recode.geno.txt

python $reformK -K $Khdf -G $geno -O $K

pheno=${OUT}.recode.pheno.txt

# univariate GEMMA
gemma -bfile $OUT -k $K -lmm 4 -o 'univar'


# multivariate GEMMA
mv -v $fam ${fam}.univariate
mv -v ${fam}.multivar $fam
gemma -bfile $OUT -k $K -lmm 4 -n 1 2 -o MULTIVAR_TE -maf 0.05

#TODO:
# do I need gxe test or is this for environment confoudning with genetype?
# seems like the latter, await results of test roudn see if we get phenotype specific betas
gxe=${OUT}.gxe
n=$(wc -l < $fam)


printf '0\t1\n%.0s' {1..241} > $gxe
gemma -bfile $OUT -k $K -lmm 4 -n 1 2 -o MULTIVAR_GXE -maf 0.05 -gxe $gxe
# TODO
# for gxe put phenoptyes under each other (replciates of accesisons), then make gxe file as number of phenptypes*number acccessions column indicating 1 or 0
# also remake K matrix etc.
# can be skipped at first and check betas and differences between betas for the different phenotypes.






