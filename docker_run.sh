#!/bin/bash
echo -e "Start docker SpacebaChat"

docker run unless-stopped --name Spacebarchat \
	-v $PWD/logs:/app/spacebar/.npm/ \
	-p 3001:3001 \
	freel/spacebarchat:0.0.1
