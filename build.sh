#!/bin/bash

# This script automates the process of building and deploying a Docker image
# to Google Cloud Artifact Registry and then deploying it to Google Cloud Run.

# Set the project ID. If the PROJECT_ID environment variable is not set,
# it defaults to the current gcloud project.
PROJECT_ID="qwiklabs-gcp-00-ffeaf67fc97f"

# Define the location for the Artifact Registry repository.
LOCATION="us"

# Define the name of the Artifact Registry repository.
REPOSITORY="cooking-images"

# Construct the full path to the Artifact Registry repository.
FULL_REPO="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}"

# Define the name of the Docker image.
IMAGE_NAME="recipe-web-app"

# Check if the Artifact Registry repository exists.
# The command `gcloud artifacts repositories describe` is used to check for existence.
# `&>/dev/null` redirects both standard output and standard error to /dev/null,
# effectively suppressing any output from the command.
if ! gcloud artifacts repositories describe "${REPOSITORY}" --location="${LOCATION}" --project="${PROJECT_ID}" &>/dev/null; then
    # If the repository does not exist, print a message.
    echo "Repository '$REPOSITORY' does not exist. Creating..."

    # Create the Artifact Registry repository.
    gcloud artifacts repositories create "${REPOSITORY}" \
        --repository-format=docker \
        --location="${LOCATION}" \
        --project="${PROJECT_ID}"
    # Print a success message after creating the repository.
    echo "Repository '$FULL_REPO' created successfully."
else
    # If the repository already exists, print a message.
    echo "Repository '$FULL_REPO' already exists."
fi

# Build and push the Docker image to Artifact Registry.
# `gcloud builds submit` builds the image from the current directory (.)
# and tags it with the specified repository and image name.
gcloud builds submit --tag $FULL_REPO/$IMAGE_NAME:latest .

# Deploy the Docker image to Google Cloud Run.
# `gcloud run deploy` deploys the image to a managed Cloud Run service.
# --platform=managed specifies that it's a managed service.
# --allow-unauthenticated allows unauthenticated access to the service.
# --image specifies the image to deploy.
# --region specifies the region for deployment.
# --port specifies the port that the service listens on.
gcloud run deploy $IMAGE_NAME \
    --platform=managed \
    --allow-unauthenticated \
    --image=$FULL_REPO/$IMAGE_NAME:latest --region=us-central1 --port=8501
