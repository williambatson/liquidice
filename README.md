# liquidice v2.1 - Setpup using Ubuntu Linux or equivelent
Running the Script

    Save the script to a file named liquidice.sh.
    Make the script executable
    Run the file

wget https://raw.githubusercontent.com/williambatson/liquidice/main/liquidice.sh

chmod +x liquidice.sh

sudo ./liquidice.sh


This script installs and sets up the following:
icecast2
LiquidSoap via opam plus liquidsoap modules
systat
creates user  'icecast' runing opam and liquidsoap as non root user: icecast
creates home directory at /home/icecast


change log......................
2.0.0
update liquidsoap install to use opam instead of apt repository for latest version and updates
2.1.0
added Liquidsoap dependencies cry, mad, lame, mm, taglib
