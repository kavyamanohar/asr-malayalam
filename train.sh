#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh

# Kavya Manohar(2020)


if [ "$#" -ne 1 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <data_dir>"
    exit 1
fi

train_dict=dict
train_lang=lang_ngram
exp=exp
data_dir=$1

mono_sw=1
tri_sw=1
trilda_sw=1
trisat_sw=1
nn2_sw=1
nn3_sw=0


tri1sen=150
tri1gauss=12000
trildasen=400
trildagauss=17000
trisatsen=550
trisatgauss=18000

echo ============================================================================
echo "     Acoustic Model Training    	        "
echo ============================================================================

train_folder=train
nj=6

if [ $mono_sw == 1 ]; then


echo "===== MONO TRAINING ====="

steps/train_mono.sh --nj $nj --cmd "$train_cmd"  $data_dir/$train_folder $data_dir/$train_lang $exp/mono  || exit 1
utils/mkgraph.sh --mono data/$train_lang $exp/mono $exp/mono/graph || exit 1


fi

if [ $tri_sw == 1 ]; then

echo
echo "===== ALIGNMENT for TRI1 ====="
echo
steps/align_si.sh --nj $nj --cmd "$train_cmd" $data_dir/$train_folder $data_dir/$train_lang $exp/mono $exp/mono_ali || exit 1


echo
echo "===== TRI1 (first triphone pass) TRAINING ====="
echo

echo "========================="
echo " Sen = $tri1sen  Gauss = $tri1gauss"
echo "========================="

steps/train_deltas.sh --boost_silence 1.25 --cmd "$train_cmd" $tri1sen $tri1gauss $data_dir/$train_folder $data_dir/$train_lang $exp/mono_ali $exp/tri_$tri1sen\_$tri1gauss || exit 1
utils/mkgraph.sh data/$train_lang $exp/tri_$tri1sen\_$tri1gauss $exp/tri_$tri1sen\_$tri1gauss/graph || exit 1

fi

if [ $trilda_sw == 1 ]; then

echo "=====  ALIGNMENT for TRI_LDA (second triphone pass)====="

steps/align_si.sh --nj $nj --cmd "$train_cmd" $data_dir/$train_folder/ $data_dir/$train_lang $exp/tri_$tri1sen\_$tri1gauss $exp/tri_$tri1sen\_$tri1gauss\_ali


echo "========================="
echo " Sen = $trildasen  Gauss = $trildagauss"
echo "========================="

steps/train_lda_mllt.sh --boost_silence 1.25 --splice-opts "--left-context=2 --right-context=2" $trildasen $trildagauss $data_dir/$train_folder $data_dir/$train_lang $exp/tri_$tri1sen\_$tri1gauss\_ali $exp/tri_$trildasen\_$trildagauss\_lda
utils/mkgraph.sh $data_dir/$train_lang $exp/tri_$trildasen\_$trildagauss\_lda $exp/tri_$trildasen\_$trildagauss\_lda/graph 

fi


if [ $trisat_sw == 1 ]; then

echo "=====ALIGNMENT for TRI_SAT (third triphone pass)  ====="
echo
steps/align_si.sh --nj $nj --cmd "$train_cmd" $data_dir/$train_folder/ $data_dir/$train_lang $exp/tri_$trildasen\_$trildagauss\_lda $exp/tri_$trildasen\_$trildagauss\_lda_ali

echo "===== TRI_SAT (third triphone pass) SAT Training ====="
echo

echo "========================="
echo " Sen = $trisatsen  Gauss = $trisatgauss"
echo "========================="


steps/train_sat.sh --boost_silence 1.25 --cmd "$train_cmd" \
$trisatsen $trisatgauss $data_dir/$train_folder $data_dir/$train_lang $exp/tri_$trildasen\_$trildagauss\_lda_ali $exp/tri_$trisatsen\_$trisatgauss\_sat || exit 1;

utils/mkgraph.sh $data_dir/$train_lang $exp/tri_$trisatsen\_$trisatgauss\_sat $exp/tri_$trisatsen\_$trisatgauss\_sat/graph 

fi

if [ $nn2_sw == 1 ]; then

echo ============================================================================
echo "                    DNN Hybrid Training                   "
echo ============================================================================

# steps/align_si.sh --nj $nj --cmd "$train_cmd" $data_dir/$train_folder $data_dir/$train_lang $exp/tri_$trildasen\_$trildagauss\_lda $exp/tri_$trildasen\_$trildagauss\_lda_ali

#DNN hybrid system training parameters

for hiddenlayersize in 2 ; do 
for minibatchsize in 64; do 
for nodes in 128; do
for numepochs in 10 ; do
echo "========================="
echo " hiddenlayer = $hiddenlayersize  minibatchsize = $minibatchsize nodes = $nodes numepochs=$numepochs "
echo "========================="

steps/nnet2/train_tanh.sh --mix-up 5000 --initial-learning-rate 0.015 \
 --final-learning-rate 0.002 --num-hidden-layers $hiddenlayersize --minibatch-size $minibatchsize --hidden-layer-dim $nodes \
 --num-jobs-nnet "$nj" --cmd "$train_cmd" --num-epochs $numepochs \
  $data_dir/$train_folder $data_dir/$train_lang $exp/tri_$trildasen\_$trildagauss\_lda_ali $exp/DNN2_tri_lda_aligned_layer_$hiddenlayersize\_$nodes\_$numepochs


ln -rsv $exp/tri_$trildasen\_$trildagauss\_lda/graph $exp/DNN2_tri_lda_aligned_layer_$hiddenlayersize\_$nodes\_$numepochs/
done; done; done; done

fi

if [ $nn3_sw == 1 ]; then

echo ============================================================================
echo "                    TDNN Hybrid Training tri3 Aligned                  "
echo ============================================================================
#Note: Check the  steps/nnet3/tdnn/train.sh to know whether we are using i-vectors or not
numepochs=4

steps/nnet3/train_tdnn.sh --cmd "$train_cmd" --num-epochs $numepochs --minibatch-size 128 --use-gpu false \
--num-jobs-initial 4 --num-jobs-final 4 --initial-effective-lrate 0.0015 --final-effective-lrate 0.002 --align-use-gpu no  \
$data_dir/$train_folder $data_dir/$train_lang $exp/tri_$trildasen\_$trildagauss\_lda_ali $exp/TDNN_tri_lda_aligned_layer

ln -rsv $exp/tri_$trildasen\_$trildagauss\_lda/graph $exp/TDNN_tri_lda_aligned_$numepochs/

fi
echo ============================================================================
echo "                   End of Script             	        "
echo ============================================================================
