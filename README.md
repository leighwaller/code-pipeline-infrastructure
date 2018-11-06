# Code Pipeline infrastructure

Contains terraform templates that provision the AWS infrastructure for a CI/CD pipeline.
The resulting pipeline has a stage for source and one for build.

More information about terraform can be found here [http://www.terraform.io]

## Resources Created
* CodeCommit repository
* CodeBuild project
* CodePipeline project
* S3 bucket for storing build artifacts
* IAM Roles for service interaction
* KMS Key for encryption at rest

## Usage
When running the following commands replace <my-project-name> with the actual name of your project.

#### Initialise terraform (Only required when new providers added):
```
terraform init
```

#### Validate the templates
```
terraform validate --var project_name <my-project-name>
```

#### Show changes before creating (Optional)
```
terraform plan
```

#### Create or Update the stack
```
terraform apply --var project_name <my-project-name>
```

#### View outputs
```
terraform output
```

#### Destroy
```
terraform destroy
```

