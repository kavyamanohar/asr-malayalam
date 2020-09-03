#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh
basepath='.'

# Kavya Manohar(2020)
# Decoding Scripts

#USAGE
#      ./test.sh <data_dir> <test_dir>

if [ "$#" -ne 2 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <data_dir> <test_dir>"
    exit 1
fi

data_dir=$1
test_dir=$2
nj=1

echo
echo "===== MONO DECODING ====="
echo
steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/mono/graph $data_dir/$test_dir exp/mono/decode_$test_dir

mkdir RESULT
echo "Saving Results"
cat exp/mono/decode_$test_dir/scoring_kaldi/best_wer >> RESULT/$test_dir.txt


echo ============================================================================
echo "                   End of Script             	        "
echo ============================================================================