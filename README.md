# Jenkins Pipeline Configuration for Docker and SonarQube and deploy the secure nginx image

This README provides step-by-step instructions for configuring a Jenkins pipeline to build a Docker image, perform static analysis, run SonarQube scans, and deploy your application. 

## Prerequisites

Before you start, ensure you have the following set up:

1. **Jenkins**:
   - A running Jenkins instance.
   - Docker installed on the Jenkins server.
   - Necessary Jenkins plugins installed:
     - **Docker Plugin**
     - **SonarQube Scanner Plugin**
     - **Pipeline Plugin**

2. **SonarQube**:
   - A running SonarQube instance.
   - A project created in SonarQube with a unique project key and key name must be replaced in Jenkinfile..

3. **GitHub Repository**:
   - A GitHub repository containing your Dockerfile and source code.

## Step 1: Configure Jenkins

1. **Add GitHub Credentials**:
   - Go to **Manage Jenkins** > **Manage Credentials**.
   - Add your GitHub credentials under **Global credentials**.

2. **Add SonarQube Server Configuration**:
   - Go to **Manage Jenkins** > **Configure System**.
   - Scroll down to the **SonarQube servers** section.
   - Add your SonarQube server details (URL and authentication token).

3. **Install Necessary Packages**:
   - Ensure that the following tools are installed on your Jenkins node:
     - Hadolint (for Dockerfile linting)
     - HTMLHint (for HTML linting)
   - You can add this as a step in your Jenkinsfile.

## Step 2: Create the Jenkinsfile

Create a `Jenkinsfile` in the root of your GitHub repository:

## Step 3: Run the Pipeline
Create a New Job:

In Jenkins, create a new pipeline job and point it to your GitHub repository.
Run the Pipeline:

Trigger the pipeline and monitor the output to ensure all stages are completed successfully.

## Step 4: Monitor SonarQube Results
Check SonarQube Dashboard:
After the pipeline runs, check the SonarQube dashboard for your project to view the analysis results.

## Troubleshooting
If you encounter issues, check the Jenkins console output for detailed error messages.
Ensure that the required ports for Docker and SonarQube are accessible.

## Conclusion
This guide walks you through setting up a Jenkins pipeline with Docker and SonarQube for your project. Feel free to customize the stages and configurations as per your project requirements.

## Expected result...
![image](https://github.com/user-attachments/assets/17a9a011-2f14-4967-90da-2dbc54e25932)

![image](https://github.com/user-attachments/assets/599759b5-e977-4924-ab3a-e9ec780b76ac)
