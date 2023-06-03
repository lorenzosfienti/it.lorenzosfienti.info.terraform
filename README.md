# it.lorenzosfienti.info.terraform

Repository of Terraform configuration of website <https://info.lorenzosfienti.it>

## Prerequisites

- [install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)
- [install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [create an aws profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) which allows you to manage all infrastructure resources.
- [create bucket directly to store the terraform state](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)

## AWS Profile

When you create AWS Profile keep in mind to create a specific user with a specific access key and access secret.
To store an AWS Profile inside your computer simply edit the file ~.aws/credentials and add at the end of file like this:

```sh
[NAME_PROFILE]
aws_access_key_id = ACCESS_KEY
aws_secret_access_key = ACCESS_SECRET
region=REGION_DEFAULT
```

After do this change in the file **providers.tf** the string **lorenzosfienti** in the profile attribute.

```hcl
profile = "lorenzosfienti"
```

## Terraform state file

About the Terraform state file, I suggest storing this file inside a bucket to prevent problems with the local state terraform file.

When you create this bucket directly into the console of AWS you need to change the configuration in the providers.tf file:

```hcl
backend "s3" {
    profile = "lorenzosfienti"
    bucket  = "lorenzosfienti-terraform"
    key     = "terraform-itlorenzosfientiinfo.tfstate"
    region  = "us-east-1"
}
```

- profile: Insert the name of the profile that you have created
- bucket: Insert the name of the bucket that you have created
- key: Insert a key unique to terraform state file for this project
- region: Insert the region where the bucket it's created

## Locals variables

There's two local variables:

- project: Insert a string unique for this project
- domain: Insert the domain of the project

## Installation

1.Clone the repository:

```sh
git https://github.com/lorenzosfienti/it.lorenzosfienti.info.terraform && cd it.lorenzosfienti.info.terraform
```

2.Modify the provider.tf and locals.tf files

3.Run the command to init the state file of terraform

```sh
terraform init
```

4.Run the command to apply the terraform configuration

```sh
terraform apply
```

5.If you remove the terraform configuration

```sh
terraform destroy
```

## Contributing

Contributions are welcomed and encouraged! Please follow these steps in the [Contributing Guidelines](./CONTRIBUTING.md), thank you!

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
