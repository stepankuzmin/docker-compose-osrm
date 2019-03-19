#!/bin/bash

# Load up .env
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

# Set OSRM_FILENAME
OSM_EXTRACT_FILENAME=${OSM_EXTRACT_URL##*/}
OSRM_FILENAME=${OSM_EXTRACT_FILENAME//.*}.osrm
echo -e "\nOSRM_FILENAME=${OSRM_FILENAME}" >> .env

echo "Downloading extract $OSM_EXTRACT_URL"
wget $OSM_EXTRACT_URL
mkdir -p ./$DATA_DIR
mv $OSM_EXTRACT_FILENAME ./$DATA_DIR/

echo "Extracting $OSM_EXTRACT_FILENAME with $PROFILE"
docker run -t -v $(pwd)/$DATA_DIR:/data \
  osrm/osrm-backend:v$OSRM_VERSION \
  osrm-extract -p /opt/$PROFILE.lua /data/$OSM_EXTRACT_FILENAME

echo "Contracting $OSRM_FILENAME with $PROFILE"
docker run -t -v $(pwd)/$DATA_DIR:/data \
  osrm/osrm-backend:v$OSRM_VERSION \
  osrm-contract /data/$OSRM_FILENAME

echo "Starting OSRM"
docker-compose up -d osrm
