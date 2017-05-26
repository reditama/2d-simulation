#!/bin/sh

##Description: bash script for oil palm 2d simulation

#########################
# The command line help #
#########################
display_help() {
	echo "Usage: $0 [options...] -i <input.(sam/bam)> -t <target_seqs.fa>" >&2
        echo
	echo "Required arguments"
	echo "    -i, --input		input file in SAM/BAM alignment format"
	echo "    -t, --input		target sequence file in fasta format"
	echo
	echo "Optional arguments"
        echo "    -h, --help		print this help message"
	echo "    -s, --strand  	apply alignment strand filter"
	echo "                  	(fr): forward->reverse alignments"
	echo "                  	(rf): reverse->forward alignments"
	echo "                  	(f) : forward alignments"
        echo "                   	(r) : reverse alignments" 
        echo "    -T, --threshold 	minimum expression value to be plotted (in TPM)"
	echo 
        exit 1
}

########################################
# Command line argument implementation #
########################################
while :
do
	case "$1" in
	  -i | --input)
	      if [ $# -ne 0 ]; then
	        input="$2"
              fi
	      shift 2
	      ;;
	  -t | --target)
                target="$2"
              shift 2
	      ;;
	  -h | --help)
	      display_help
	      exit 0
	      ;;
	  -s | --strand)
	      strand="$2"
	      shift 2
	      ;;
	  -T | --threshold)
	      threshold="$2"
	      shift 2
	      ;;
	  --) # End of all options
	      shift
	      break
	      ;;
          -*)
	      echo "Error: Unknown option: $1" >&2
	      ## or call function display_help
              #display_help
	      exit 1
	      ;;
	  *)  #No more options
	      break
              
	      ;;
         esac
done

	

########################
# ALIGNMENT EXTRACTION # 
########################

if [ "$input" = "" ]; then
	echo "Please specify input file"
	echo Type $0 -h to see list of commands
	exit 1
	else
	break
fi

if [ "$target" = "" ]; then
	echo "Please specify target file"
	echo type $0 -h to see list of commands
	exit 1
	else
	break
fi


if [ "$strand" = "" ]; then
	str=""
	break
else if [ "$strand" = "fr" ]; then
	str="--fr-stranded"
	break
else if [ "$strand" = "rf" ]; then
	str="--rf-stranded"
	break
else if [ "$strand" = "f"]; then
	str="--f-stranded"
	break
else if [ "$strand" = "r"]; then
	str="--r-stranded"
	break
else
	echo "Not a valid strand filter option"
	exit 1
	fi
	fi
	fi
	fi
fi


echo "=======EXTRACT ALIGNMENT========="
echo "Input (SAM/BAM) file:" $input
echo "Target fasta file:" $target
echo "Strand type:" $str
echo ""
echo "================================="
express $str $target $input --no-update-check
echo "================================="

#############################
# EXPRESS OUTPUT CONVERSION #
#############################

input1=results.xprs
tpm_min=50
output1=xprs_out.csv

echo "=====CONVERT EXPRESS OUTPUT======"
echo Input file: $input1
echo Output file: $output1
echo Expression threshold: $threshold
echo ""
echo "================================="
Rscript xprs.r -i $input1 -t $tpm_min -o $output1
echo "================================="
echo ""
echo "->END OF CONVERT EXPRESS OUTPUT<-"
echo ""

##2D PLOTTING##
input2=$output1
output2=plot_xprs.png
imres=l
logbase=10

echo "=========MODEL CONSTRUCTION======="
echo Input file: $input2
echo Output file: $output2
echo ""
echo "=================================="
Rscript 2d.r -i $input2 -o $output2 -r $imres -b $logbase -l y -m n
echo "=================================="
echo ""
echo "--->END OF MODEL CONSTRUCTION<---"
