#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh
basepath='.'

# Kavya Manohar(2020)
# Decoding Scripts

#USAGE
#      ./test.sh <data_dir> <test_dir>

if [ "$#" -ne 3 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <data_dir> <test_dir> <model_dir>"
    exit 1
fi

data_dir=$1
test_dir=$2
model_dir=$3
nj=4

if [[ "$model_dir" != "exp/DNN2"* ]];
then
echo
# echo "===== DECODING GMM-HMM====="
echo
# steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" $model_dir/graph $data_dir/$test_dir $model_dir/decode_$test_dir
else
# echo
# echo "===== DECODING NN2 ====="
# echo
# steps/nnet2/decode.sh --cmd "$decode_cmd" --nj "$nj" \
#  $model_dir/graph $data_dir/$test_dir \
#   $model_dir/decode_$test_dir

echo
echo "===== DECODING NN3 TDNN ====="
echo
steps/nnet3/decode.sh --cmd "$decode_cmd" --nj "$nj" \
 $model_dir/graph $data_dir/$test_dir \
  $model_dir/decode_$test_dir

fi

mkdir RESULT
echo "Saving Results"
model=$(basename $model_dir)
cat $model_dir/decode_$test_dir/scoring_kaldi/best_wer >> RESULT/$model\_$test_dir.txt


echo ============================================================================
echo "                   End of Script             	        "
echo ============================================================================
