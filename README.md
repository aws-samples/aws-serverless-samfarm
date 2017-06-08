# aws-serverless-samfarm
This repo contains the full code and templates needed to create a the Serverless SamFarm demo as shown in the What's New with AWS Lambda presentation at Re:Invent 2016.

There are three separate parts to this application: the api, the pipeline which detects, builds, and deploys changes, and the website. 
Lets start by getting that website up and running.

## Step 1

### Website
In the [website directory](website/) there are four files:

1. **[index.html](website/index.html):** This is the index file that our S3 bucket will be displaying.
2. **[app.js](website/app.js):** The heart of our website. We will be making some changes to this in a bit, but for now we can leave it alone.
3. **[squirrel.png](website/squirrel.png):** Our friend! SAM the squirrel.
4. **[website.yaml](website/website.yaml):** The CloudFormation template used to create the Amazon S3 bucket for the website.

To create the website stack.

[<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=myteststack&templateURL=https://awscomputeblogimages.s3-us-west-2.amazonaws.com/samfarm-website.yaml)

Once the stack is complete, we will need to keep track of the S3 bucket name and the URL for the website. 

Now we have all the seperate parts of our website, but lets get SAM up and running:

```bash
sh upload_website.sh <s3-bucket-name>
```

And visit the url you saved before. You should see something like this:

![SAM Screenshot](/img/sam-screenshot.png)

Ta-da, a working website! SAM the squirrel may be all alone right now, but we'll fix that in a bit.


## Step 2
### API
The Serverless API we are building! The [api directory](api/) contains five files. 

1. **[beta.json](api/beta.json):** The CloudFormation staging file. This will be used by CloudFormation to pass parameters to our CloudFormation template.
2. **[buildspec.yml](api/buildspec.yml):** This is used by CodeBuild in the build step of our pipeline. We will get to that later.
3. **[index.js](api/index.js):** The Lambda function code!
4. **[package.json](api/package.json):** The package.json that defines what packages we need for our Lambda function.
5. **[saml.yaml](api/saml.yaml):** SAML my YAML! This is the SAM template file that will be used to create our API gateway resource and Lambda function, hook them up together

Create a new github repo from the [api directory](api/) and place these files in there. This repo will be used for your automated CI/CD pipeline we build below.

## Step 3

### Pipeline
The pipeline is a full CI/CD serverless pipeline for building and deploying your api. In this example we are using CloudFormation to create the pipeline, all resources, and any permissions needed.

The following resources are created:

- An S3 bucket to store deployment artifacts.
- An AWS CodeBuild stage to build any changes checked into the repo.
- The AWS CodePipeline that will watch for changes on your repo, and push these changes through to build and deployment steps.
- All IAM roles and policies required.

The CloudFormation templates being used to create these resources can be found in [pipeline directory](pipeline/).

To create the pipeline stack, click the launch stack button below.

[<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=myteststack&templateURL=https://awscomputeblogimages.s3-us-west-2.amazonaws.com/samfarm-main.yaml)

## Step 4
### Update your website
If you have looked at the code in the website (or if you haven't, now is your chance!), you may have noticed that the website makes http requests to an api periodically to update the number of SAMs on the screen. Right now it is pointing at nothing, so lets update it to point it to brand spanking new API. In the [app.js](website/app.js), look for the line

```javascript
var GET_SAM_COUNT_URL = 'INSERT API GATEWAY URL HERE';
```

and update that to your API Gateway endpoint. It should be in the format:

```
https://<api-id>.execute-api.us-east-1.amazonaws.com/Prod/sam
```

Now lets update your S3 static website with this change:

```bash
sh upload_website.sh <s3-bucket-name>
```


## Step 5
### Start the party (or how I learned to stop worrying and push a change)
Now that we have our website, our code repository with our lambda function and our pipeline configured, lets see it in action. We are going to make two changes to our repository, first were going to setup our API for CORS, and second were going to update our Lambda function. Both changes will be made in the repo you created in Step 2.


#### CORS
Go to the beta.json file and update the following line:

```json
"OriginUrl": "*"
```

to the url for the S3 static site we created. Something like:

```json
"OriginUrl": "http://<s3-bucket-name>.s3-website-us-east-1.amazonaws.com"
```


#### Lambda Function
Go to index.js file the repo you made in Step 2 and update the line:

```javascript
var samCount = 1;
```

to

```javascript
var samCount = 15;
```

Commit and push the changes. 

Go back to the pipeline we generated in Step 3, you will see AWS CodePipeline automatically pick up your change, and start the build and deploy process. Voila! A completely version controlled, serverless, CI/CD solution to give a squirrel a few friends. Technology!
