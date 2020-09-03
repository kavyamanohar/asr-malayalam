#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh

# Kavya Manohar(2020)
# Malayalam ASR Training and Testing



if [ "$#" -ne 1 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <input_dir>"
    exit 1
fi


# Remove existing data
rm -rf data
rm -rf exp
rm -rf mfcc

input_dir=$1
language_dir=$1/language
data_dir=./data
train_dir=$1/train
test_dir=$1/test

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
    ./audiodataprep.sh $d $data_dir train
done

./utils/fix_data_dir.sh $data_dir/train


echo ============================================================================
echo "     MFCC Feature Extraction and Mean-Variance Tuning Files for Training  	        "
echo ============================================================================

./extractfeatures.sh $data_dir train

echo ============================================================================
echo "     Acoustic Model Training  	        "
echo ============================================================================

./train.sh $data_dir 

echo ============================================================================
echo "     Compiling Decoding Graphs  	        "
echo ============================================================================

echo ============================================================================
echo "     Testing Graphs  	        "
echo ============================================================================


for d in $test_dir/* ; do
    test_dir=$(basename $d)
    rm -rf $data_dir/$test_dir
    mkdir $data_dir/$test_dir
    ./audiodataprep.sh $d $data_dir $test_dir
    ./utils/fix_data_dir.sh $data_dir/$test_dir

echo ============================================================================
echo "     MFCC Feature Extraction and Mean-Variance Tuning Files for Training  	        "
echo ============================================================================

./extractfeatures.sh $data_dir $test_dir
./utils/fix_data_dir.sh $data_dir/$test_dir
nj=1

echo
echo "===== MONO DECODING ====="
echo
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/mono/graph data/$test_dir exp/mono/decode_$test_dir



done


echo ============================================================================
echo "                   End of Script             	        "
echo ============================================================================