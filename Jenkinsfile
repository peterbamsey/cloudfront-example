pipeline {
    agent any

    options {
        timeout(time: 1, unit: 'HOURS')
    }

    parameters {
        string(name: 'environment', defaultValue: 'default', description: 'The environment to deploy to - e.g prod or beta')
        string(name: 'region', defaultValue: '', description: 'The AWS region which the resources are deployed in')
        string(name: 'domain', defaultValue: 'bamsey.net', description: 'The root domain of the e.g bamsey.net')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TF_IN_AUTOMATION      = '1'
    }

    stages {
        stage ('Initialize') {
            steps {
            echo 'Placeholder.'
        }
    }
}
