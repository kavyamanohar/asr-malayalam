#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh

# Kavya Manohar(2020)
# For audio data preparation


# USAGE:
#
#      ./audiodataprep.sh <audiocorpus_directory> <data_dir> <train_or_test_dir>
#
# INPUT:
#
#   audiocorpus_directory
        # └── audio
        #   └──utt1.wav
        #   └──utt2.wav
        # └──transcript.tsv (utt_id   spk_id   transcript)
#   data_directory (after running createLM.sh successfully)

# OUTPUT:

if [ "$#" -ne 3 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <audiocorpus_directory> <data_dir> <train_or_test_dir>"
    exit 1
fi

audio_corpus=$1
data_dir=$2
train_or_test_dir=$3

#Read path of wave files and store it to audiopath variable
audiopath=$(realpath $audio_corpus/audio)

echo "Creating the list of utterence IDs"
#The function is to extract the utterance id
awk '{print $1}' FS='\t' $audio_corpus/metadata.tsv > $data_dir/$train_or_test_dir/temputt


echo "Creating the list of speaker IDs"
#Create speaker id list
awk '{print $2}' FS='\t' $audio_corpus/metadata.tsv > $data_dir/$train_or_test_dir/tempspk

echo "Creating the list of utterence IDs mapped to absolute file paths of wavefiles"
awk '{print $3}' FS='\t' $audio_corpus/metadata.tsv > $data_dir/$train_or_test_dir/tempfilename
sed -e 's,^,'"$audiopath"/',' -i $data_dir/$train_or_test_dir/tempfilename
paste $data_dir/$train_or_test_dir/temputt $data_dir/$train_or_test_dir/tempfilename > $data_dir/$train_or_test_dir/tempwav.scp

echo "Creating the list of Utterance IDs mapped to corresponding speaker Ids"

paste $data_dir/$train_or_test_dir/temputt $data_dir/$train_or_test_dir/tempspk > $data_dir/$train_or_test_dir/temputt2spk

echo "Creating the list of Speaker IDs mapped to corresponding list of utterance Ids"

./utils/utt2spk_to_spk2utt.pl $data_dir/$train_or_test_dir/temputt2spk > $data_dir/$train_or_test_dir/tempspk2utt

echo "Creating the file of transcripts"
awk '{print $1 "\t" $4}' FS='\t' $audio_corpus/metadata.tsv > $data_dir/$train_or_test_dir/temptext


cat $data_dir/$train_or_test_dir/temputt >> $data_dir/$train_or_test_dir/utt
cat $data_dir/$train_or_test_dir/tempspk >> $data_dir/$train_or_test_dir/spk
cat $data_dir/$train_or_test_dir/temputt2spk >> $data_dir/$train_or_test_dir/utt2spk
cat $data_dir/$train_or_test_dir/tempspk2utt >> $data_dir/$train_or_test_dir/spk2utt
cat $data_dir/$train_or_test_dir/tempwav.scp >> $data_dir/$train_or_test_dir/wav.scp
cat $data_dir/$train_or_test_dir/temptext >> $data_dir/$train_or_test_dir/text

rm $data_dir/$train_or_test_dir/temp*