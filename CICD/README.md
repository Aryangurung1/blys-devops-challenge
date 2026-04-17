# CI/CD Pipeline Automation

This folder contains the CI/CD deliverables requested in the challenge:

- a `Dockerfile`
- an `index.html`
- a pipeline configuration file

The pipeline is written for GitHub Actions and is designed to deploy the container into the ECS Fargate infrastructure created by the Terraform stack.

## Deliverables

- `Dockerfile`
  Builds a lightweight nginx-based image that serves the challenge landing page
- `index.html`
  Static page copied into the nginx container at build time
- `github-actions.yml`
  GitHub Actions workflow for build, push, validation placeholder, and ECS deployment

## What the Pipeline Does

The workflow covers the three things asked for in the task:

1. builds a Docker image
2. pushes that image to a registry
3. triggers an automated deployment to the existing ECS service

It also includes a dedicated placeholder stage for automated testing, linting, or security scanning before deployment.

## Pipeline Flow

### Quality Gate

The first job is intentionally reserved for checks that should happen before a production deployment. In this submission it is a placeholder so it can be adapted to the real application stack.

Typical checks I would add here:

- Dockerfile linting with Hadolint
- container scanning with Trivy
- static analysis with Semgrep

### Build and Push

The second job:

- checks out the repository
- authenticates to AWS using GitHub Secrets
- logs in to Amazon ECR
- builds the Docker image from the repository `Dockerfile`
- copies the application page from `index.html`
- tags it with the Git commit SHA
- also tags it as `latest`
- pushes both tags to ECR

Using the commit SHA gives a clean release trail and makes rollbacks easier than relying only on `latest`.

### Deploy to ECS

The deployment job:

- pulls the active ECS task definition
- updates the image for the target container
- registers a new task definition revision
- deploys it to the ECS service
- waits for service stability before marking the workflow successful

This keeps deployment aligned with the infrastructure already provisioned in AWS instead of rebuilding infrastructure during each release.

## GitHub Secrets and Variables

Yes, GitHub Secrets should be used here.

### Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

These are sensitive and should never be hardcoded in the workflow.

### GitHub Repository Variables

- `AWS_REGION`
- `ECR_REPOSITORY`
- `ECS_CLUSTER`
- `ECS_SERVICE`
- `ECS_TASK_FAMILY`
- `CONTAINER_NAME`

These are not secrets, but they are environment-specific. Keeping them as GitHub Variables makes the workflow cleaner and easier to reuse across environments.

## Suggested Values for This Project

Based on the infrastructure already created in AWS, the variables would look like this:

- `AWS_REGION = ap-south-1`
- `ECS_CLUSTER = blys-poc-prod-cluster`
- `ECS_SERVICE = blys-poc-prod-service`
- `ECS_TASK_FAMILY = blys-poc-prod-task`
- `CONTAINER_NAME = hello-world`

You will still need to create an ECR repository and set:

- `ECR_REPOSITORY = blys-poc-app`

or whatever repository name you choose in AWS.

## How to Use It in a Real Repository

GitHub Actions only runs workflows from `.github/workflows/`.

To use this pipeline in practice:

1. create the required GitHub Secrets
2. create the required GitHub Variables
3. create the Amazon ECR repository
4. push to `main` or trigger the workflow manually

## Improvements

If this pipeline were extended beyond the challenge, the next upgrades I would make are:

- replace static AWS keys with GitHub OIDC and an IAM role
- add real tests and Dockerfile linting in the quality gate
- add image vulnerability scanning as an enforced gate
- add deployment notifications and rollback guidance

## Screenshots

- GitHub Actions workflow run showing the CI/CD pipeline completed successfully

![GitHub Actions successful workflow run](img/image-1.png)

![alt text](img/image.png)
