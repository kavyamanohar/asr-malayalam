# Setting local system jobs (local CPU - no external clusters)
export train_cmd="run.pl --mem 6G"
export decode_cmd="run.pl --mem 6G"
export mkgraph_cmd="run.pl --mem 8G"
export cuda_cmd="run.pl --gpu 1"