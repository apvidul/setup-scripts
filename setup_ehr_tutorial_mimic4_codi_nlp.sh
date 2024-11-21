#!/bin/bash

# Set the location variable to the path where you want to create the MIMIC workspace
LOCATION="/n/scratch/users/<first_hms_id_char>/<HMSID>"

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
         "${LOCATION}/EHR_TUTORIAL_WORKSPACE/raw_data/nlp" \
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

# Create the SLURM script for setting up the Conda environment
cat <<EOF > ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/setup_conda_env.sh
#!/bin/bash
#SBATCH -p short
#SBATCH -t 0-2:00
#SBATCH -c 1
#SBATCH --mem=4G
#SBATCH -o ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/setup_conda_env.log

# Load the Miniconda module
module load miniconda3/23.1.0

# Check if conda is available after loading the module
if ! command -v conda &> /dev/null; then
  echo "Conda is not available. Please ensure the miniconda3/23.1.0 module is properly configured."
  exit 1
fi

# Download the Conda environment YAML file to the scripts directory
echo "Downloading the Conda environment YAML file..."
wget "https://raw.githubusercontent.com/apvidul/setup-scripts/refs/heads/main/ehrenv_environment.yml" -P "${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/"

# Set up the Conda environment
echo "Setting up the Conda environment from ehrenv_environment.yml..."
conda env create -f "${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/ehrenv_environment.yml"

# Reminder to activate the environment
echo "Conda environment setup complete. To activate the environment, use 'source activate ehrenv'."
EOF

# Submit the SLURM job for setting up the Conda environment
sbatch ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/setup_conda_env.sh

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

# Submit the SLURM job to download MIMIC data
sbatch ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_3_1.sh

echo "MIMIC data is currently being downloaded to '${LOCATION}/EHR_TUTORIAL_WORKSPACE/raw_data'. You can check the log file '${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_3_1.log' for progress. The download will approximately take 5-6 hours to complete."

# Create the SLURM script for downloading MIMIC Notes data to the NLP subfolder
cat <<EOF > ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_notes.sh
#!/bin/bash
#SBATCH -p short
#SBATCH -t 0-8:00
#SBATCH -c 1
#SBATCH --mem=2G
#SBATCH -o ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_notes.log

wget -r -N -c -np --user ${PHYSIONET_USERNAME} --password ${PHYSIONET_PASSWORD} https://physionet.org/files/mimic-iv-note/2.2/ -P ${LOCATION}/EHR_TUTORIAL_WORKSPACE/raw_data/nlp
EOF

# Submit the SLURM job to download MIMIC Notes data to the NLP subfolder
sbatch ${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_notes.sh

echo "MIMIC Notes data is currently being downloaded to '${LOCATION}/EHR_TUTORIAL_WORKSPACE/raw_data/nlp'. You can check the log file '${LOCATION}/EHR_TUTORIAL_WORKSPACE/scripts/download_mimic_notes.log' for progress. The download may take several hours to complete."
