#!/bin/bash
### usage : This.sh SampleList.txt ###

# input
sample_dir_list=$1

# constant
script_dir=/home/zunuan/script

while IFS="" read -r sample_dir || [[ -n "$sample_dir" ]]
do
  DATA_DIR=/home/zunuan/data
  CURRENT="0.raw"
  SAMPLE=$(basename $(dirname $sample_dir))  # ex) PGPC-02, NA12878-it1
  SOURCE=$(basename $sample_dir)             # ex) 0.blood
  NEXT="1.fastp"

  ############
  # pipeline #
  ############

  echo "Mainscript : Running 2_picard_SortSam_RGAdd_MarkDup.sh"
  CURRENT="2.aligned"
  NEXT="3.picard"
  ${script_dir}/2_picard_SortSam_RGAdd_MarkDup.sh \
	  $DATA_DIR \
          $CURRENT \
          $SAMPLE \
          $SOURCE \
          $NEXT
  echo "Mainscript : 2_picard_SortSam_RGAdd_MarkDup.sh Done."

  echo "Mainscript : Running 3_gatk_recal_LA.sh"
  CURRENT="3.picard"
  NEXT="4.preproccessed"
  ${script_dir}/3_gatk_recal_LA.sh \
          $DATA_DIR \
          $CURRENT \
          $SAMPLE \
          $SOURCE \
          $NEXT
  echo "Mainscript : 3_gatk_recal_LA.sh Done."

  echo "Mainscript : Running 4_gatk_HaplotypeCaller.sh"
  CURRENT="4.preproccessed"
  NEXT="5.variant_calling"
  ${script_dir}/4_gatk_HaplotypeCaller.sh \
	  $DATA_DIR \
          $CURRENT \
          $SAMPLE \
          $SOURCE \
          $NEXT
  echo "Mainscript : 4_gatk_HaplotypeCaller.sh Done."

  echo "Mainscript : Running 5_gatk_1D_CNN_FilterTranch.sh"
  CURRENT="5.variant_calling"
  NEXT="6.filtered_variants"
  ${script_dir}/5_gatk_1D_CNN_FilterTranch.sh \
          $DATA_DIR \
          $CURRENT \
          $SAMPLE \
          $SOURCE \
          $NEXT
  echo "Mainscript : 5_gatk_1D_CNN_FilterTranch.sh Done."

  echo "Mainscript : Running 6_gatk_Funcotator_GnomADonly.sh"
  CURRENT="6.filtered_variants"
  NEXT="7.funcotated"
  ${script_dir}/6_gatk_Funcotator_GnomADonly.sh \
          $DATA_DIR \
          $CURRENT \
          $SAMPLE \
          $SOURCE \
          $NEXT
  echo "Mainscript : 6_gatk_Funcotator_GnomADonly.sh Done."

  echo "Mainscript : Running 7_BinVariantsUsingAnnot.sh"
  CURRENT="7.funcotated"
  NEXT="8.binned_variants"
  ${script_dir}/7_BinVariantsUsingAnnot.sh \
          $DATA_DIR \
          $CURRENT \
          $SAMPLE \
          $SOURCE \
          $NEXT
  echo "Mainscript : 7_BinVariantsUsingAnnot.sh Done."

  echo "Mainscript : Running 8_gatk_Concordance.sh"
  CURRENT="8.binned_variants"
  NEXT="9.concordance"
  ${script_dir}/8_gatk_Concordance.sh \
          $DATA_DIR \
          $CURRENT \
          $SAMPLE \
          $SOURCE \
          $NEXT
  echo "Mainscript : 8_gatk_Concordance.sh Done."

done < $sample_dir_list

echo "script termineated."
