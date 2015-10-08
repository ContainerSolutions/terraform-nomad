# Container Solutions Terraform Nomad

How to set up a Nomad cluster on the Google Cloud using Terraform

### Install Terraform

* These scripts require Terraform 0.6.3 or greater
* Follow the instructions on <https://www.terraform.io/intro/getting-started/install.html> to set up Terraform on your machine.

### Get your Google Cloud JSON Key
- Visit https://console.developers.google.com
- Navigate to APIs & Auth -> Credentials -> Service Account -> Generate new JSON key
- The file will be downloaded to your machine

### Get Google Cloud SDK
- Visit https://cloud.google.com/sdk/
- Install the SDK, login and authenticate with your Google Account.

### Add your SSH key to the Project Metadata
- Back in the Developer Console, go to Compute - Compute Engine - Metadata and click the SSH Keys tab. Add your public SSH key there.
- Use the path to the private key and the username in the next step as `gce_ssh_user` and `gce_ssh_private_key_file`

### Prepare variables.tf

Copy the`variables.tf.example` file to `varables.tf` and adjust to your situation

### Create Terraform plan

Create the plan and save it to a file. 

```
terraform plan -out my.plan -module-depth=1
```

### Create the cluster

Once you are satisfied with the plan, apply it.

```
terraform apply my.plan
```

### Start nomad on the nodes

Log in to the nodes. There is a default server.hcl there, copied from the resources dir, that you can use to start the node.
Start the agent, specifying the address of eth0 to bind to.
` sudo nomad agent -config server.hcl -bind=10.11.12.4`

### Join the nodes

From one of the nodes, connect to the others.

`sudo nomad server-join -address http://$OTHER_SERVER:4646 $MYADDRESS`

You should see the servers joining in the logs. Repeat this step for all servers in the cluster.

### Destroy the cluster
When you're done, clean up the cluster with
```
terraform destroy
```

## To do

- Automate starting of nomad daemon
- Discover other nodes
- Automating joining of other nodes

 
