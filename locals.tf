locals {
  # the project local variable use prefix for each resource created
  project = "itlorenzosfientiinfo"
  # the domain local variable use for cloudfront alias
  # keep in mind to add manage DNS for this domain to validate DNS during the process of SSL Creation
  domain   = "info.lorenzosfienti.it"
  # the reponame where is located the project to deploy inside the bucket
  reponame = "lorenzosfienti/it.lorenzosfienti.info"
}
