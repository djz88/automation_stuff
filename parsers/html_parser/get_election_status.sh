#/bin/bash
now=$(date +"%d_%h_%y_%H_%M_%S")
python3 html_parser.py  | tee jakub_election_$now.txt
