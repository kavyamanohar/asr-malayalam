This is a [kaldi](https://kaldi-asr.org/) based recipie for Malayalam speech recognition. You need a working Kaldi directory to run this script.

Details on how to run this script and the working is described here.

To install Kaldi, see the documentation [here](https://kaldi-asr.org/doc/install.html)

The source code of `/asr_malayalam` has to be placed in the `/egs` directory of Kaldi installation directory.

## USAGE

`./run.sh ./inputdirectory`

input directory has the following structure:

├── language -> symlink/to/language/model/source (contains lm_train.txt, lexicon.txt)
├── test
│   └── corpus1
│       ├── audio -> symlink/to/audio/files_directory (utt1.wav, utt2.wav)
│       └── metadata.tsv -> symlink/to/audio/files/metadata (metadata.tsv)
└── train
    ├── corpus2
    |      ├── audio -> symlink/to/audio/files_directory (utt1.wav, utt2.wav)
    |      └── metadata.tsv -> symlink/to/audio/files/metadata (metadata.tsv)
    └── corpus3
        ├── audio -> symlink/to/audio/files_directory (utt1.wav, utt2.wav)
        └── metadata.tsv -> symlink/to/audio/files/metadata (metadata.tsv)

metadata.tsv is a tab separated values of utterence_is, speaker_id, file_name in audio folder, transcript in Malayalam script.