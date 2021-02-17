# CloudFront and Lambda@Edge Example
This project is an example of using a Lambda function to alter HTTP response headers for files requested from AWS's CDN service CloudFront.

## Overview
Using a Lambda function situated between a CloudFront distribution and a CloudFront origin (an S3 bucket in this case) we are able to intelligently manipulate the response to redirect the requester to a different location.

## How it looks
A normal request from a user for a file that exists at the target CDN takes the following journey:<br>
![File Found at CDN](/diagrams/cloudfront-example-1.jpg)
<br>
The user requests a file from `beta.cdn.bamsey.net` - index.html.  In this instance the file is available on the beta CDN and CloudFront makes and initial call to it's origin, the beta S3 bucket, requesting the file.  The S3 service responds with a HTTP 200 OK response and the payload is returned to the CDN.<br><br>In between the S3 bucket's response and the CDN we have a Lambda function which inspects the response headers.  This is configured as an `origin-response` Lambda, meaning it is executed when the origin responds to the request from the CDN (see more about CloudFront event types here: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-cloudfront-trigger-events.html)
<br><br>
As an example of manipulating the headers in action, our Lambda function will inspect the origin-response headers looking for headers HTTP 400 range:

```python
    if 400 <= int(response['status']) <= 499 and host.startswith("beta"):
        response['status'] = 302
        response['statusDescription'] = 'Found'

        # Drop the body as it is not required for redirects
        response['body'] = ''
        response['headers']['location'] = [{'key': 'Location', 'value': fallback_url}]

    return response
```  
It will additionally check the environment prefix of the Lambda function name and ensure that the HTTP header manipulation only occurs in the `beta` environment.  The same Lambda function is also deployed to a second environment `prod`. Which means that in the prod environment the header manipulation will not occur due to the differing environment prefix<br><br>
![File Found at CDN](/diagrams/cloudfront-example-2.jpg)
<br><br>
Therefore if we request a file from the `beta` CDN that does not exist the user will automatically be redirected to the `prod` CDN.
<br>
We can see this in action with curl.  At the `beta` CDN origin we have a single file at the route of the S3 bucket, `index.html`, containing the content `ok`:<br>  
```
$ curl -vL https://beta.cdn.bamsey.net/index.html
*   Trying 99.84.8.114...
* TCP_NODELAY set
* Connected to beta.cdn.bamsey.net (99.84.8.114) port 443 (#0)
...
> Host: beta.cdn.bamsey.net
> User-Agent: curl/7.61.0
> Accept: */*
...
< HTTP/2 200 
< content-type: text/plain
...
ok
```
<br>

Then if we request a file that does not exist on the `beta` CDN but does in the `prod` setup, we can see the Lamba altering the response headers and redirecting the user:

<br>

```
$ curl -Lv https://beta.cdn.bamsey.net/prod-index.html
*   Trying 99.86.255.125...
...
> GET /prod-index.html HTTP/2
> Host: beta.cdn.bamsey.net
> User-Agent: curl/7.61.0
> Accept: */*
...
< HTTP/2 302 
< content-type: application/xml
< content-length: 0
< location: http://prod.cdn.bamsey.net/prod-index.html
...
* Connection #0 to host beta.cdn.bamsey.net left intact
* Issue another request to this URL: 'http://prod.cdn.bamsey.net/prod-index.html'
*   Trying 52.84.95.115...
* TCP_NODELAY set
* Connected to prod.cdn.bamsey.net (52.84.95.115) port 80 (#1)
> GET /prod-index.html HTTP/1.1
> Host: prod.cdn.bamsey.net
> User-Agent: curl/7.61.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Content-Type: text/plain
< Content-Length: 7
...
* Connection #1 to host prod.cdn.bamsey.net left intact
prod ok
```

##Setup
This example project contains all the Terraform IaC to deploy the setup described above, including:
* Cloudfront CDN
* S3 bucket along with the index and prod-index.html files
* Python Lambda function
* ACM certificates
* Route 53 records
* Appropriate IAM roles and policies

The Terraform code expects an existing Route53 zone within your account to setup DNS records in.  It locates this by the domain name.

It also includes a Jenkins declarative pipeline which will setup a pipeline with the appropriate parameters to allow the two `beta` and `prod` environments described above.  As part of the Jenkins config, we have also included a Dockerfile.Terraform to build the container that Terraform executed within.
<br><br>
To run Jenkins locally you can follow the configuration steps here:  https://www.jenkins.io/doc/book/installing/docker/#downloading-and-running-jenkins-in-docker.  After the setup you will need ot install the standard plugins and create a Pipeline job that looks for the Pipeline config in SCM.
<br>  
Once Jenkins is setup and available you will need to add AWS Access key secrets to the Jenkins secrets store to match the environment variable names found in the Jenkinsfile. Initial configuration of the S3 state bucket needs to be handled manually.

###Versions
Tested with:
* Terraform v0.14.6 and AWS provider v3.28.0
* Jenkins 2.263.4
