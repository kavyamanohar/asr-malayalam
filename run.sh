#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh


if [ "$#" -ne 1 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <input_dir>"
    exit 1
fi


## Remove existing data
rm -rf data
rm -rf exp
rm -rf mfcc

input_dir=$1
language_dir=$1/language
data_dir=./data
train_dir=$1/train

echo ============================================================================
echo "                  Running the script for Language Model Creation   	        "
echo ============================================================================

./createLM.sh $language_dir $data_dir

echo ============================================================================
echo "                  Preparing Audio Training Data   	        "
echo ============================================================================
rm -rf $data_dir/train
mkdir $data_dir/train
for d in $train_dir/* ; do
    echo "Corpus $d audio preparation"
    ./audiodataprep.sh $d $data_dir
done
echo ============================================================================
echo "                   End of Script             	        "
echo ============================================================================