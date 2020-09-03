#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh

#Choose the Phonetic modeling here

if [ "$#" -ne 1 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <data_dir>
    exit 1
fi

train_dict=dict
train_lang=lang_bigram
exp=exp
data_dir=$1


echo ============================================================================
echo "     Acoustic Model Training    	        "
echo ============================================================================

train_folder=train
nj=2


echo "===== MONO TRAINING ====="
# echo

steps/train_mono.sh --nj $nj --cmd "$train_cmd"  $data_dir/$train_folder data/$train_lang $exp/mono  || exit 1
utils/mkgraph.sh --mono data/$train_lang $exp/mono $exp/mono/graph || exit 1


# echo
# echo "===== MONO ALIGNMENT ====="
# echo
# steps/align_si.sh --nj $nj --cmd "$train_cmd" data/$train_folder data/$train_lang $exp/mono $exp/mono_ali || exit 1

# echo
# echo "===== TRI1 (first triphone pass) TRAINING ====="
# echo
# for sen in 150 ; do 
# for gauss in 12000 ; do 

# echo "========================="
# echo " Sen = $sen  Gauss = $gauss"
# echo "========================="

# steps/train_deltas.sh --boost_silence 1.25 --cmd "$train_cmd" $sen $gauss data/$train_folder data/$train_lang $exp/mono_ali $exp/tri_$sen\_$gauss || exit 1
# utils/mkgraph.sh data/$train_lang $exp/tri_$sen\_$gauss $exp/tri_$sen\_$gauss/graph || exit 1
                

# done;done



# show-alignments data/lang_bigram/phones.txt exp/mono/40.mdl 'ark:gunzip -c exp/mono/ali.4.gz|'  > "alignment.txt"

# echo "===== TRI_LDA (second triphone pass) ALIGNMENT ====="

# steps/align_si.sh --nj $nj --cmd "$train_cmd" data/$train_folder/ data/$train_lang $exp/tri_200_16000 $exp/tri1_200_16000_ali

# echo "===== TRI_LDA (second triphone pass) LDA Training ====="
# echo

# for sen in 400; do 
# for gauss in 17000 ; do 

# echo "========================="
# echo " Sen = $sen  Gauss = $gauss"
# echo "========================="

# steps/train_lda_mllt.sh --boost_silence 1.25 --splice-opts "--left-context=2 --right-context=2" $sen $gauss data/$train_folder data/$train_lang $exp/tri1_200_16000_ali $exp/tri_$sen\_$gauss\_lda
# utils/mkgraph.sh data/$train_lang $exp/tri_$sen\_$gauss\_lda $exp/tri_$sen\_$gauss\_lda/graph 

# done; done


# echo "===== TRI_SAT (third triphone pass) ALIGNMENT ====="
# echo
# steps/align_si.sh --nj $nj --cmd "$train_cmd" data/$train_folder/ data/$train_lang $exp/tri_400_17000_lda $exp/tri_400_17000_lda_ali

# echo "===== TRI_SAT (third triphone pass) SAT Training ====="
# echo

# for sen in 550  ; do 
# for gauss in 18000; do 
# echo "========================="
# echo " Sen = $sen  Gauss = $gauss"
# echo "========================="


# steps/train_sat.sh --boost_silence 1.25 --cmd "$train_cmd" \
# $sen $gauss data/$train_folder data/$train_lang $exp/tri_400_17000_lda_ali $exp/tri_$sen\_$gauss\_sat || exit 1;
# utils/mkgraph.sh data/$train_lang $exp/tri_$sen\_$gauss\_sat $exp/tri_$sen\_$gauss\_sat/graph 

# done; done


echo ============================================================================
echo "                    DNN Hybrid Training                   "
echo ============================================================================

# steps/align_si.sh --nj "$nj" --cmd "$train_cmd" data/$train_folder/ data/$train_lang exp/tri_400_17000_lda exp/tri_400_17000_lda_ali || exit 1;

# DNN hybrid system training parameters

# for hiddenlayersize in 2 ; do 
# for minibatchsize in 64; do 
# for nodes in 128; do
# for numepochs in 10 ; do
# echo "========================="
# echo " hiddenlayer = $hiddenlayersize  minibatchsize = $minibatchsize nodes = $nodes numepochs=$numepochs "
# # echo "========================="

# steps/nnet2/train_tanh.sh --mix-up 5000 --initial-learning-rate 0.015 \
#  --final-learning-rate 0.002 --num-hidden-layers $hiddenlayersize --minibatch-size $minibatchsize --hidden-layer-dim $nodes \
#  --num-jobs-nnet "$nj" --cmd "$train_cmd" --num-epochs $numepochs \
#   data/$train_folder/ data/$train_lang $exp/tri_400_17000_lda_ali $exp/DNN_tri_lda_aligned_layer_$hiddenlayersize\_$nodes\_$numepochs

# done; done; done; done

# echo ============================================================================
# echo "                    TDNN Hybrid Training tri3 Aligned                  "
# echo ============================================================================
# #Note: Check the  steps/nnet3/tdnn/train.sh to know whether we are using i-vectors or not

# steps/nnet3/train_tdnn.sh --cmd "$train_cmd" --num-epochs 4 --minibatch-size 128 --use-gpu false \
# --num-jobs-initial 4 --num-jobs-final 4 --initial-effective-lrate 0.0015 --final-effective-lrate 0.002 --align-use-gpu no  \
# data/train2/ data/$train_lang exp/tri_sat_ali exp/TDNN_tri_sat_aligned

echo ============================================================================
echo "                   End of Script             	        "
echo ============================================================================
