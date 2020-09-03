#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh

# Kavya Manohar(2020)
# To extract features

#USAGE
#      ./extractfeatures.sh <data_dir> <train_dir or test_dir>

if [ "$#" -ne 2 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <data_dir> <train_dir or test_dir>"
    exit 1
fi

data_dir=$1
folder=$2
echo "Feature extractiorn from $folder"
#Create feature vectors
./steps/make_mfcc.sh --nj 4 $data_dir/$folder exp/make_mfcc/$folder mfcc

#Copy the feature in text file formats for human reading
copy-feats ark:./mfcc/raw_mfcc_$folder.1.ark ark,t:./mfcc/raw_mfcc_$folder.1.txt


# #Create Mean Variance Tuning
steps/compute_cmvn_stats.sh $data_dir/$folder exp/make_mfcc/$folder mfcc
