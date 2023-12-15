#!/bin/bash

#TO-DO
#Check if samtools/1.19 is installed
#Add option to keep tmp folder

out=$1
bamfile=$2
ampfile=$3
sample_id=$4
nthreads=$5
awk_script=$6

mkdir -p ${out}/${sample_id}
mkdir -p ${out}/${sample_id}/tmp
mkdir -p ${out}/${sample_id}/filtered_qnames

out_qnames=${out}/${sample_id}/filtered_qnames
out_finalbam=${out}/${sample_id}
out=${out}/${sample_id}/tmp

if [ ! -e ${bamfile}.bai ]; then
        echo "Indexing the BAM file..."
        samtools index -@ ${nthreads} ${bamfile}
fi

echo "----------Runnning PRIMR----------"
echo ''
echo "------Filtering by Amplicon-------"

while read line; do

        region=$(echo ${line} | awk '{print $1":"$2"-"$3}')
        gene=$(echo ${line} | awk '{print $7}')
        name=${sample_id}'_'${gene}
        strand=$(echo ${line} | awk '{print $8}')
        samtools view -hb ${bamfile} ${region} -@ ${nthreads} -o ${out}/${name}.bam
        #samtools sort -n ${out}/${name}.bam -@ ${nthreads} -o ${out}/${name}.bam
        samtools sort -N ${out}/${name}.bam -@ ${nthreads} -o ${out}/${name}.bam # lexicographical ordering to match bash join default

        file=${out}/${name}.bam

        echo ${gene}

        samtools view ${file} -@ ${nthreads} | awk -f ${awk_script} > ${out}/corrected_${gene}.bed

        r1=${out}/${gene}_r1.txt
        r2=${out}/${gene}_r2.txt
        input=${out}/corrected_${gene}.bed
        output=${out}/corrected_${gene}_merged.bedpe

        awk -v r1=${r1} -v r2=${r2} '{if ($5 == 99 || $5 == 83) print > r1; else if ($5 == 147 || $5 == 163) print > r2}' ${input}

        LC_ALL=C join -j 4 ${r1} ${r2} > ${output}

        amp1_start=$(echo ${line} | awk '{print $2}')
        amp1_end=$(echo ${line} | awk '{print $3}')
        amp2_start=$(echo ${line} | awk '{print $4}')
        amp2_end=$(echo ${line} | awk '{print $5}')

        file=${output}
        output=${out_qnames}/${gene}_qnames.txt

        #R1_start=$3
        #R1_end=$4
        #R2_start=$8
        #R2_end=$9
        #cigar_R1=$6
        #cigar_R2=$11
        #qname=$1

        # if strand is + then
        # R1 start within amp1 and R1 end within amp1 AND R2 start within amp1 and end within amp2 AND cigar_R2 include N ($6 ~ /N/)
        # OR
        # R1 start within amp1 and R1 end within amp2 AND R2 start within amp1 and end within amp2 AND cigar_R1 include N
        # OR
        # R1 start within amp1 and R1 end within amp2 AND R2 start within amp2 and end within amp2 AND cigar_R1 include N and cigar_R2 include N
        if [ ${strand} == "+" ]; then
            awk -v amp1_start=${amp1_start} -v amp1_end=${amp1_end} -v amp2_start=${amp2_start} -v amp2_end=${amp2_end} -v gene=${gene} -v output=${output}\
                '{
                    if ( ($3 >= amp1_start && $3 <= amp1_end && $4 >= amp1_start  && $4 <= amp1_end && $8 >= amp1_start && $8 <= amp1_end && $9 >= amp2_start && $9 <= amp2_end && $11 ~ /N/) ||
                    ($3 >= amp1_start && $3 <= amp1_end && $4 >= amp2_start  && $4 <= amp2_end && $8 >= amp1_start && $8 <= amp1_end && $9 >= amp2_start && $9 <= amp2_end && $11 ~ /N/ && $6 ~ /N/) ||
                    ($3 >= amp1_start && $3 <= amp1_end && $4 >= amp2_start  && $4 <= amp2_end && $8 >= amp2_start && $8 <= amp2_end && $9 >= amp2_start && $9 <= amp2_end && $6 ~ /N/) )
                    {
                        print $1 ":" gene > output
                    }

                }' ${file}

        #else
        # R2 start within amp2 and R2 end within amp2 AND R1 start within amp2 and end within amp1 AND cigar_R1 include N ($6 ~ /N/)
        # OR
        # R2 start within amp2 and R2 end within amp1 AND R1 start within amp2 and end within amp1 AND cigar_R1 include N  and cigar_R2 include N
        # OR
        # R2 start within amp2 and R2 end within amp1 AND R1 start within amp1 and end within amp1 AND cigar_R2 include N ($6 ~ /N/)

        else
            awk -v amp1_start=${amp1_start} -v amp1_end=${amp1_end} -v amp2_start=${amp2_start} -v amp2_end=${amp2_end} -v gene=${gene} -v output=${output}\
                '{
                    if ( ($8 >= amp2_start && $8 <= amp2_end && $9 >= amp2_start && $9 <= amp2_end && $3 >= amp2_start && $3 <= amp2_end && $4 >= amp1_start && $4 <= amp1_end && $6 ~ /N/) ||
                    ($8 >= amp2_start && $8 <= amp2_end && $9 >= amp1_start && $9 <= amp1_end && $3 >= amp2_start && $3 <= amp2_end && $4 >= amp1_start && $4 <= amp1_end && $6 ~ /N/ && $11 ~ /N/) ||
                    ($8 >= amp2_start && $8 <= amp2_end && $9 >= amp1_start && $9 <= amp1_end && $3 >= amp1_start && $3 <= amp1_end && $4 >= amp1_start && $4 <= amp1_end && $11 ~ /N/) )
                    {
                        print $1 ":" gene > output
                    }

                }' ${file}

        fi

        file=${out}/${name}.bam


done < ${ampfile}


echo "------Merging Filtered Reads------"

cat ${out_qnames}/*qnames.txt > ${out_qnames}/qnames_${sample_id}.txt

echo "------Filtering Original BAM------"
samtools view ${bamfile} -@ ${nthreads} --qname-file ${out_qnames}/qnames_${sample_id}.txt -o ${out_finalbam}/${sample_id}_PRIMR_filtered.bam

echo "--------------DONE !--------------"

#rm ${out}/*
