#!/bin/bash

###########################################################
# 0 - functions
function affiUsage {
    echo "usage: $0 {arvg}";
    echo "This script update all PeakForest PDF documents in this project";
    echo "{arvg}";
    echo "  -h or --help: display this help message";
    echo "  -t or --token: set the GitLab API token (mandatory; not set by default)";
    echo "  -b or --branch: the target branch for artifacts download (optional; default: \"dev\")";
    echo "e.g.:";
    echo "$0 -b dev -t YOUR_GITLAB_API_TOKEN  "
}

###########################################################
# I - read arvgs

# DIRECTORY="~/Workspace";
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GITLAB_SERVER="https://services.pfem.clermont.inra.fr/gitlab";
GITLAB_API_URL="api/v4/projects";

GITLAB_API_TOKEN="";
GITLAB_REF_NAME="dev"
GITLAB_JOB_NAME="documents-dev"

PDF_PATH="src/main/webapp/resources/docs/"
PDF_MOLNUM="PeakForest_mol_num.fr.pdf"

while [[ $# > 0 ]]
do
key="$1"

case $key in
    -t|--token)
    GITLAB_API_TOKEN="$2"
    shift # past argument
    ;;
    -b|--branch)
    GITLAB_REF_NAME="$2"
    shift # past argument
    ;;
    -h|--help)
    affiUsage
    exit 0;
    shift # past argument
    ;;
    *)
          # unknown option
    ;;
esac
shift # past argument or value
done

###########################################################
# II - run CMDs

# II.A - remove old ones

echo "[info] removing PDF...";
test -f $PDF_PATH/$PDF_MOLNUM && rm -rf  $PDF_PATH/$PDF_MOLNUM || echo "[info] no file to delete"

# II.B - get targeted artifacts
echo "[info] getting new PDF from gitlab...";
curl  --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "$GITLAB_SERVER/$GITLAB_API_URL/188/jobs/artifacts/$GITLAB_REF_NAME/download?job=$GITLAB_JOB_NAME" --output /tmp/artifacts.zip

# II.C - extract war files
echo "[info] unzip gitlab artifacts...";
unzip /tmp/artifacts.zip -d /tmp/peakforest_users_doc/

# II.D - copy PDF
echo "[info] copy PDF to current project target DIR...";
cp /tmp/peakforest_users_doc/documents/$PDF_MOLNUM $PDF_PATH/$PDF_MOLNUM

exit 0;
