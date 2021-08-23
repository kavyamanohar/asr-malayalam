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
train_or_test_dir=$2
ncores=`nproc`
nj=$ncores
echo "Feature extractiorn from $train_or_test_dir"
#Create feature vectors
./steps/make_mfcc.sh --nj $nj $data_dir/$train_or_test_dir exp/make_mfcc/$train_or_test_dir mfcc
./utils/fix_data_dir.sh $data_dir/$2

#Copy the feature in text file formats for human reading
# copy-feats ark:./mfcc/raw_mfcc_$train_or_test_dir.1.ark ark,t:./mfcc/raw_mfcc_$train_or_test_dir.1.txt


# #Create Mean Variance Tuning
steps/compute_cmvn_stats.sh $data_dir/$train_or_test_dir exp/make_mfcc/$train_or_test_dir mfcc
