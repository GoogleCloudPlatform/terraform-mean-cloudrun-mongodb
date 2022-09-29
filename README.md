Cloud Run + MongoDB Atlas demo
================================================================================

This repo contains a demo that deploys a [MEAN Stack](https://www.mongodb.com/mean-stack)
application on Google Cloud using [Cloud Run](https://cloud.google.com/run) and
[MongoDB Atlas](https://www.mongodb.com/atlas).

This demo uses [Terraform](https://www.terraform.io/) to provision and configure
Atlas and Cloud Run and deploy [a sample application](https://github.com/mongodb-developer/mean-stack-example) behind a Google Cloud Load Balancer across three regions.

You should be able to deploy your own simple application with only minor changes
to this repo.

Getting Started
--------------------------------------------------------------------------------

In order to run this demo, you'll need a Google Cloud account, a MongoDB Atlas
account, credentials for both services, and a working Terraform installation.

A quick note on security: this demo uses your personal credentials for Google
Cloud and a highly privileged API key for Atlas. It also configures Atlas
to allow connections from any IP address. We do this to get you
up and running as fast as possible, but in the real world you should follow
Google Cloud's [best practices for service accounts](https://cloud.google.com/iam/docs/best-practices-service-accounts)
and Atlas's [documentation](https://www.mongodb.com/docs/atlas/atlas-ui-authorization/)
to properly secure your infrastructure.

With that out of the way, let's get started!

### MongoDB Atlas

If you don't already have a Atlas account, [sign up here](https://www.mongodb.com/cloud/atlas/register).
If you are prompted to create a database, look for the "I'll do this later" link
in the lower left corner. Once you're logged in, click on "Access Manager" at
the top and select "Organization Access".

Select the "API Keys" tab and click the "Create API Key" button. Give your new
key a short description and select the "Organization Owner" permission. Click
"Next" and then make a note of your public and private keys. This is your last
chance to see the private key, so be sure you've written it down somewhere safe.

Next, you'll need your Organization ID. Go to [the projects page](https://cloud.mongodb.com/v2#/org)
and click "Settings" in the list on the left side of the window to get to the
Organization Settings screen. Your organization ID is in a box in the upper-left
corner of the window. Copy your Organization ID and save it with your credentials.

That's everything for Atlas. Now you're ready to move on to setting up Google Cloud!

### Google Cloud

If you don't already have a Google Cloud account, [sign up here](https://accounts.google.com/SignUp).
You'll also need to [enable billing](https://console.cloud.google.com/billing)
and set up a billing account. This demo is designed to qualify for the
[free tier](https://cloud.google.com/free) but some of the services involved
require billing to be enabled. See [this page](https://cloud.google.com/billing/docs/how-to/manage-billing-account#create_a_new_billing_account)
for more information on setting up a billing account. Make a note of your Billing
Account ID, listed [here](https://console.cloud.google.com/billing).

We recommend using [Cloud Shell](https://cloud.google.com/shell) but if you prefer
to work locally you can do that too. If you'd like to use Cloud Shell, just click
this convenient button:

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/terraform-mean-cloudrun-mongodb)

This will open a Cloud Shell window and clone a copy of this repository. Cloud
Shell has your credentials built in, and Terraform is already installed, so
you're ready to move on to [Choosing Your Regions](#choosing-your-regions). You can also
[open Cloud Shell the normal way](https://cloud.google.com/shell/docs/using-cloud-shell)
but you'll need to clone this repo yourself.

If you want to work locally, you'll need to [install the `gcloud` tool](https://cloud.google.com/sdk/docs/install).
If you're on MacOS you can also install `gcloud` [via homebrew](https://formulae.brew.sh/cask/google-cloud-sdk).
Once the install is done, run `gcloud init` to set up your environment. More
information can be found [in the docs](https://cloud.google.com/sdk/docs/initializing).

### Installing Terraform

If you're using Cloud Shell, you've already got Terraform installed so feel free
to move on to the next section. Otherwise, [download Terraform](https://www.terraform.io/downloads)
and install it. A detailed walkthrough can be found [in this tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli).

### Choosing your regions

Next, select the regions for your infrastructure. For Atlas you only need to specify a single region. For Google Cloud you can choose from 1 to N number of regions. 

For this demo it's okay to choose somewhere close to you, but for production use you may want to choose a different
regions. If you need some advice, check out [Best Practices for Compute Engine regions selection](https://cloud.google.com/solutions/best-practices-compute-engine-region-selection).

For a list of available regions, refer Atlas's [Google Cloud provider documentation](https://www.mongodb.com/docs/atlas/reference/google-gcp/).
Choose a region that's close to you and that supports the `M0` cluster tier. Make
a note of both the Google Cloud region names and the Atlas region name, as you'll
need both in the next step.

### Configuring the demo

If you haven't already, clone this repo. Run `terraform init` to make sure
Terraform is working correctly and download the provider plugins.

Then, create a file in the root of the repository called `terraform.tfvars` with
the following contents, replacing placeholders as necessary:

    atlas_pub_key          = "<your Atlas public key>"
    atlas_priv_key         = "<your Atlas private key>"
    atlas_org_id           = "<your Atlas organization ID>"
    google_billing_account = "<your billing account ID>"

If you used the Open in Cloud Shell button, check to make sure that you're creating
the `terraform.tfvars` file in the root of the repository. The Cloud Shell
terminal will be in the right directory but the Cloud Shell editor may not.
Double-check to be sure you're creating the file in the same directory as this
README.

If you want to use the default regions (`us-central1`, `us-west1, and `us-east11` for Google Cloud and `US_CENTRAL` for Atlas) then you're ready to go. If
you selected a different region, adjust the following in your `terraform.tfvars` file:

    atlas_cluster_region = "<Atlas region ID>"
    
    variable "google_cloud_regions" {
        type          = map(string)
        description   = "a list of google cloud regions to deploy the cloud run service"
        default = {
            "region-1"  = "us-west1",
            "region-2"  = "us-east1",
            "region-3"  = "us-central1"
        }
    }

Run `terraform init` again to make sure there are no new errors. If you get an
error, check your `terraform.tfvars` file.

### Run it!

You're ready to deploy! You have two options: you can run `terraform plan` to
see a full listing of everything that Terraform wants to do without any risk of
accidentally creating those resources. If everything looks good, you can then
run `terraform apply` to execute the plan.

Alternately, you can just run `terraform apply` on its own and it will create
a plan and display it before prompting you to continue. You can learn more about
the `plan` and `apply` commands in [this tutorial](https://learn.hashicorp.com/tutorials/terraform/plan).

For this demo, we're going to just run `terraform apply`:

    $ terraform apply

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:

    # mongodbatlas_cluster.cluster will be created
    + resource "mongodbatlas_cluster" "cluster" {
        + auto_scaling_compute_enabled                    = (known after apply)
        + auto_scaling_compute_scale_down_enabled         = (known after apply)
        + auto_scaling_disk_gb_enabled                    = true
        + backing_provider_name                           = "GCP"

    [ ... snip ... ]

    Plan: 6 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value:

If everything looks good to you, type `yes` and press enter, then go grab a snack
while Terraform sets everything up for you! When it's done, Terraform will display
the URL of your application:

    [ ... snip ... ]
    Apply complete! Resources: 23 added, 0 changed, 0 destroyed.

    Outputs:

    load_balancer_ip_address = "34.149.215.8"

Wait a few minutes for the Load Balancer to come online, then visit that address via http in your browser and you'll see your app running. 

### Cleaning Up

When you're done, run `terraform destroy` to clean everything up:

    $ terraform destroy

    [ ... snip ... ]

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    - destroy

    Terraform will perform the following actions:

    [ ... snip ... ]

    Plan: 0 to add, 0 to change, 23 to destroy.

    Changes to Outputs:
    - app_url = "https://example.com" -> null

    Do you really want to destroy all resources?
    Terraform will destroy all your managed infrastructure, as shown above.
    There is no undo. Only 'yes' will be accepted to confirm.

    Enter a value:

If you're sure you want to tear everything down, type `yes` and press enter. This
will take a few minutes so now would be a great time for another break. When
Terraform is done everything it created will have been destroyed and you
will not be billed for any further usage. Note that you may still see the project
listed in the project selector in the Google Cloud console. You can confirm it
has been marked for deletion by going to the [Resources Pending Deletion](https://console.cloud.google.com/cloud-resource-manager?pendingDeletion=true)
page and looking for it there.

Next Steps
--------------------------------------------------------------------------------

You can use the code in this repository to deploy your own applications. Out of
the box, it will run any application that meets the following requirements:

- runs in a single container
- reads MongoDB connection string from an environment variable called `ATLAS_URI`

To try it with your own code, add a line to your `terraform.tfvars` file pointing
to your container image:

    app_image = '<your container URI>'

If you need to add or change the environment variables that get passed into the
container, take a look at the `google.tf` file. You can add additional `env` blocks
next to the `ATLAS_URI` block, and/or modify that block to fit your needs.

You can also add more `google_cloud_run_service` blocks to deploy additional
services on Cloud Run, just make sure to also include a `google_cloud_run_service_iam_binding`
block if that service needs to be accessible to the public. For more information,
see the [`google_cloud_run_service`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service)
and [`google_cloud_run_service_iam_binding`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam)
pages in the Terraform provider documentation, as well as the [Cloud Run IAM documentation](https://cloud.google.com/run/docs/securing/managing-access).
