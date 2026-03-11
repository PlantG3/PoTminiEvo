#!/bin/bash
chr=chr1
indir=01o_$chr
outtmp=02o_${chr}.synteny.tmp.bed
outbed=02o_${chr}.synteny.bed
if [ -f $outbed ]; then
	rm $outbed
fi
for chrcompDir in $indir/T*; do
	chrcomp=`echo $chrcompDir | sed 's/.*\///'`
	curbed=02_${chrcomp}.tmp.bed
	# syntenic regions
	awk '$11=="SYNAL"' $chrcompDir/03_${chrcomp}_T_B71.v2syri.out | awk '{ print $1 "\t" $2 -1 "\t" $3 }' > $curbed
	if [ -f $outbed ]; then
		cp $outbed $outtmp
		bedtools intersect -a $outtmp -b $curbed -wb | \
			cut -f 1-3 | awk '($3-$2) > 10000' \
			| sort -k2n | bedtools merge -i - \
			>$outbed
	else
		awk '($3-$2) > 10000' $curbed | sort -k2n > $outbed
	fi
	rm $curbed
done
rm $outtmp
