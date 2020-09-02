#set-up for single machine or cluster based execution
. ./cmd.sh
#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh

# Kavya Manohar(2020)
# For creating langauage model grammar G.fst and phonetic lexicon L.fst


# USAGE:
#
#      ./createLM.sh <language_dir> <data_dir>
#
# INPUT:
#
#   language_dir/
#       lexicon.txt
#       lm_train.txt
#   
# OUTPUT:
#
#   data_dir/
        # ├── lang_bigram
        # │   ├── G.fst
        # │   ├── L_disambig.fst
        # │   ├── L.fst
        # │   ├── oov.int
        # │   ├── oov.txt
        # │   ├── phones
        # │   │   ├── align_lexicon.int
        # │   │   ├── align_lexicon.txt
        # │   │   ├── context_indep.csl
        # │   │   ├── context_indep.int
        # │   │   ├── context_indep.txt
        # │   │   ├── disambig.csl
        # │   │   ├── disambig.int
        # │   │   ├── disambig.txt
        # │   │   ├── extra_questions.int
        # │   │   ├── extra_questions.txt
        # │   │   ├── nonsilence.csl
        # │   │   ├── nonsilence.int
        # │   │   ├── nonsilence.txt
        # │   │   ├── optional_silence.csl
        # │   │   ├── optional_silence.int
        # │   │   ├── optional_silence.txt
        # │   │   ├── roots.int
        # │   │   ├── roots.txt
        # │   │   ├── sets.int
        # │   │   ├── sets.txt
        # │   │   ├── silence.csl
        # │   │   ├── silence.int
        # │   │   ├── silence.txt
        # │   │   ├── wdisambig_phones.int
        # │   │   ├── wdisambig.txt
        # │   │   ├── wdisambig_words.int
        # │   │   ├── word_boundary.int
        # │   │   └── word_boundary.txt
        # │   ├── phones.txt
        # │   ├── topo
        # │   └── words.txt
        # ├── local
        # │   ├── dict
        # │   │   ├── extra_phones.txt
        # │   │   ├── extra_questions.txt
        # │   │   ├── lexiconp.txt
        # │   │   ├── lexicon.txt
        # │   │   ├── nonsilence_phones.txt
        # │   │   ├── optional_silence.txt
        # │   │   ├── phones.txt
        # │   │   └── silence_phones.txt
        # │   ├── lang_bigram
        # │   │   ├── align_lexicon.txt
        # │   │   ├── lexiconp_disambig.txt
        # │   │   ├── lexiconp.txt
        # │   │   ├── lex_ndisambig
        # │   │   └── phone_map.txt
        # │   └── tmp_lang_bigram
        # │       ├── lm_phone_bg.ilm.gz
        # │       └── oov.txt
        # └── train
        # └── lm_train.txt

if [ "$#" -ne 2 ]; then
    echo "ERROR: $0"
    echo "USAGE: $0 <language_dir> <data_dir>"
    exit 1
fi

language_dir=$1
data_dir=$2

#Defines the names of silence phone and spoken noice phone
silencephone=SIL
spokennoicephone=SPN

dict_dir=${data_dir}/local/dict


kaldi_root_dir='../..'

train_dict=dict
train_lang=lang_bigram
train_folder=train


#Clearing data directory contents from prior execution of this script
rm -rf $data_dir/local/dict/
rm -rf $data_dir/local/$train_dict/lexiconp.txt $data_dir/local/$train_lang $data_dir/local/tmp_$train_lang $data_dir/$train_lang
rm -rf $data_dir/$train_folder/


mkdir -p $data_dir/local/dict
mkdir $data_dir/local/tmp_$train_lang
mkdir $data_dir/$train_folder


echo "$0: Looking for lexicon files in $language_dir"

for i in lexicon.txt; do
    echo "$language_dir/$i has the following contents"
    head $language_dir/$i
done;


echo ============================================================================
echo "                  Preparing the Lexicon Dictionary       	        "
echo ============================================================================

echo "!sil	$silencephone
<unk>	$spokennoicephone" > $dict_dir/lexicon.txt

echo "Creating the sorted lexicon file"
sort $language_dir/lexicon.txt | paste >> $dict_dir/lexicon.txt 

echo "Creating the list of Phones"
cat $dict_dir/lexicon.txt | cut -d '	' -f 2  - | tr ' ' '\n' | sort | uniq > $dict_dir/phones.txt

cat $dict_dir/phones.txt | sed /$silencephone/d | sed /$spokennoicephone/d > $dict_dir/nonsilence_phones.txt 


echo $silencephone > $dict_dir/optional_silence.txt 
echo $silencephone > $dict_dir/silence_phones.txt
echo $spokennoicephone >> $dict_dir/silence_phones.txt

touch $dict_dir/extra_phones.txt $dict_dir/extra_questions.txt

n_gram=2 # This specifies bigram or trigram. for bigram set n_gram=2 for tri_gram set n_gram=3

echo ============================================================================
echo "                   Creating  lexicon dictionary L.fst               	        "
echo ============================================================================


utils/prepare_lang.sh --num-sil-states 3 $dict_dir "<unk>" $data_dir/local/$train_lang $data_dir/$train_lang


echo ============================================================================
echo "                   Creating  n-gram LM G.fst           	        "
echo ============================================================================
echo "$0: Looking for language model training sentences files in $language_dir"
echo "$language_dir/lm_train.txt has the following contents"
head $language_dir/lm_train.txt

cat $language_dir/lm_train.txt > $data_dir/$train_folder/lm_train.txt

$kaldi_root_dir/tools/irstlm/bin/build-lm.sh -i $data_dir/$train_folder/lm_train.txt -n $n_gram -o  $data_dir/local/tmp_$train_lang/lm_phone_bg.ilm.gz

gunzip -c  $data_dir/local/tmp_$train_lang/lm_phone_bg.ilm.gz | utils/find_arpa_oovs.pl $data_dir/$train_lang/words.txt  >  $data_dir/local/tmp_$train_lang/oov.txt

gunzip -c $data_dir/local/tmp_$train_lang/lm_phone_bg.ilm.gz | grep -v '<s> <s>' | grep -v '<s> </s>' | grep -v '</s> </s>' | grep -v 'SIL' | $kaldi_root_dir/src/lmbin/arpa2fst - | fstprint | utils/remove_oovs.pl $data_dir/local/tmp_$train_lang/oov.txt | utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=$data_dir/$train_lang/words.txt --osymbols=$data_dir/$train_lang/words.txt --keep_isymbols=false --keep_osymbols=false | fstrmepsilon >  $data_dir/$train_lang/G.fst

$kaldi_root_dir/src/fstbin/fstisstochastic  $data_dir/$train_lang/G.fst 


echo ============================================================================
echo "                   End of Script             	        "
echo ============================================================================


