#!/bin/bash

# Set the location variable to the path where you want to create the MIMIC workspace
LOCATION="/n/data1/hsph/biostat/celehs/lab/va67"

# If you would like to download and work in your home directory, you can update above to LOCATION="$HOME"

# Check if the workspace folder already exists
if [ -d "${LOCATION}/EHR_TUTORIAL_WORKSPACE" ]; then
  echo "EHR_TUTORIAL_WORKSPACE folder already exists here ${LOCATION}/EHR_TUTORIAL_WORKSPACE"
  exit 0
fi

# Create the workspace directory
mkdir "${LOCATION}/EHR_TUTORIAL_WORKSPACE"
echo "Workspace has been created here ${LOCATION}/EHR_TUTORIAL_WORKSPACE"

# Create the workspace subdirectories
echo "Creating raw_data, processed_data, and scripts subdirectories"
mkdir -p "${LOCATION}/EHR_TUTORIAL_WORKSPACE/raw_data" \
         "${LOCATION}/EHR_TUTORIAL_WORKSPACE/processed_data" \
         "${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts"
echo "Workspace has been set up here ${LOCATION}/EHR_TUTORIAL_WORKSPACE"

# Download and extract MIMIC Data Prep scripts from GitHub
echo "Downloading and extracting MIMIC Data Prep scripts from GitHub..."
wget https://github.com/apvidul/MIMIC-Data-Prep/archive/refs/heads/main.zip -O mimic-data-prep.zip
unzip -q mimic-data-prep.zip -d "${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts"
mv "${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/MIMIC-Data-Prep-main/"* "${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/"

# Cleanup unnecessary files and folders
rm -rf mimic-data-prep.zip "${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/MIMIC-Data-Prep-main"

echo -e "\n\033[1m========================\033[0m"
echo -e "\033[1mEnter Your PhysioNet Credentials\033[0m"
echo -e "\033[1m========================\033[0m"
echo -e "\033[1mNote: The following credentials will be saved in the file ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_3_1.sh and will be used to download the MIMIC data. Ensure you are using the correct credentials. You can remove this file once the download is complete.\033[0m"

# PhysioNet credentials
read -p "Enter your PhysioNet username: " PHYSIONET_USERNAME
read -p "Enter your PhysioNet password: " PHYSIONET_PASSWORD

# Create the SLURM script for downloading MIMIC data
cat <<EOF > ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_3_1.sh
#!/bin/bash
#SBATCH -p short
#SBATCH -t 0-8:00
#SBATCH -c 1
#SBATCH --mem=2G
#SBATCH -o ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_3_1.log

wget -r -N -c -np --user ${PHYSIONET_USERNAME} --password ${PHYSIONET_PASSWORD} https://physionet.org/files/mimiciv/3.1/ -P ${LOCATION}/EHR_TUTORIAL_WORKSPACE/raw_data
EOF

sbatch ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_3_1.sh

echo "MIMIC data is currently being downloaded to '${LOCATION}/EHR_TUTORIAL_WORKSPACE/raw_data'. You can check the log file '${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_3_1.log' for progress. The download will approximately take 5-6 hours to complete."

