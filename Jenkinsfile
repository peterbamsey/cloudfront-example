pipeline {
    agent none

    options {
        timeout(time: 1, unit: 'HOURS')
    }

    parameters {
        choice(name: 'environment', choices: ['beta', 'prod'], description: 'The environment the resources will be deployed to e.g prod or beta')
        string(name: 'region', defaultValue: 'us-east-1', description: 'The AWS region which the resources are deployed in')
        string(name: 'domain', defaultValue: 'bamsey.net', description: 'The root domain of the e.g bamsey.net')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TF_IN_AUTOMATION      = '1'
    }

    stages {
        stage('Plan') {
            agent {
                dockerfile {
                    filename 'Dockerfile.Terraform'
                    args  '--entrypoint=\'\''
                }
            }
            steps {
                dir('infra') {
                    sh "terraform init -input=false -upgrade=true -backend-config \"bucket=terraform-state-cloudfront-example\" -backend-config \"key=environments/${params.environment}/terraform.tfstate\""
                    sh "terraform plan -refresh=true -input=false -out tfplan -var \"environment=${params.environment}\" -var \"region=${params.region}\" -var \"domain=${params.domain}\""
                    sh 'terraform show tfplan > tfplan.txt'
                }
            }
        }
        stage('Approval') {
            agent {
                dockerfile {
                    filename 'Dockerfile.Terraform'
                    args  '--entrypoint=\'\''
                }
            }
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                dir('infra') {
                    script {
                        def plan = readFile 'tfplan.txt'
                        input message: "Do you want to apply the plan?",
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                    }
                }
            }
        }
        stage('Apply') {
            agent {
                dockerfile {
                    filename 'Dockerfile.Terraform'
                    args  '--entrypoint=\'\''
                }
            }
            steps {
                dir('infra') {
                    sh "terraform apply -input=false -auto-approve -var \"environment=${params.environment}\" -var \"region=${params.region}\" -var \"domain=${params.domain}\""
                }
            }
        }
    }
    post{
        // Clean after build
        always {
            cleanWs(cleanWhenNotBuilt: true,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
        }
    }
}
