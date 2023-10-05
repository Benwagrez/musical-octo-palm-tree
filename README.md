# musical-octo-palm-tree

Hey everyone! Welcome to my musical octo palm tree. This repository holds a lambda function deployment that monitors traffic to an application load balancer. Lets dive into it.

## Prerequisites
The following items are prerequisites for this deployment.
<ul>
    <li>Own and manage an S3 bucket which is actively receiving application load balancer logs.</li>
    <ul>
        <li>For simplicty these logs should be logically partitioned in the bucket by year/month/day.</li>
    </ul>
    <li>An AWS Athena database pointing to the application load balancer logs is required. This database needs to partition table data by day.</li>
    <li>An email registered with the AWS SES service to send notification emails. Note: the lambda function is currently configured to send emails from yourself, to yourself. Adjust accordingly</li>
</ul>

## Deployment Overview
Below details will be given regarding the Lambda deployment including deployment status, deployment cost, architecture, and usage.
<table>
    <tr>
        <th>Status</th><th>Deployment Cost</th>
    </tr>
    <tr>
        <td>WIP</td><td>Minor S3 storage costs / CloudFront Dist costs</td>
    </tr>
</table>

The architecture diagram for this diagram is displayed below:
WIP

Terraform Module:
module.lambda_deployment

The Python code relies on the ipwhois function. Below, the dict structure of the ipwhois output is displayed:
WIP

https://ipwhois.readthedocs.io/en/latest/RDAP.html


## Scripts
The following script is made for ease of management: package.sh
This script will be explained below.

### package.sh
Packages the python code and libraries into a deployment zip and launches a terraform apply.

## Contact
Reach out to me below for any questions:

Email: benwagrez@gmail.com
LinkedIn: https://www.linkedin.com/in/benwagrez/