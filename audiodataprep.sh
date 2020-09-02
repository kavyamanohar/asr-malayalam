#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh

# Kavya Manohar(2020)
# For audio data preparation


# USAGE:
#
#      ./audiodataprep.sh <audiocorpus_directory>
#
# INPUT:
#
#   audiocorpus_directory
        # └── audio
        #   └──utt1.wav
        #   └──utt2.wav
        #   └──transcript.tsv (utt_id   spk_id   transcript)
#   data_directory (after running createLm.sh successfully)

# OUTPUT:

if [ "$#" -ne 2 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <audiocorpus_directory> <data_dir>"
    exit 1
fi

audio_corpus=$1
data_dir=$2

#Read path of wave files and store it as a temporary file wavefilepaths.txt 
realpath $audio_corpus/audio/*.wav > $data_dir/train/wavefilepaths.txt

# echo "Creating the list of utterence IDs"

# #The function is to extract the utterance id
# cat ./data/$folder/wavefilepaths.txt | xargs -l basename -s .wav > ./data/$folder/utt


# echo "Creating the list of utterence IDs mapped to absolute file paths of wavefiles"


# #Create wav.scp mapping from uttrence id to absolute wave file paths
# paste ./data/$folder/utt ./data/$folder/wavefilepaths.txt > ./data/$folder/wav.scp


# echo "Creating the list of speaker IDs"

# #Create speaker id list
# cat ./data/$folder/utt | cut -d 's' -f 1 > ./data/$folder/spk

# echo "Creating the list of Utterance IDs mapped to corresponding speaker Ids"

# #Create utt2spk
# paste ./data/$folder/utt ./data/$folder/spk > ./data/$folder/utt2spk

# echo "Creating the list of Speaker IDs mapped to corresponding list of utterance Ids"

# #Create spk2utt
# ./utils/utt2spk_to_spk2utt.pl ./data/$folder/utt2spk > ./data/$folder/spk2utt

# rm ./data/$folder/wavefilepaths.txt
