pipeline{
    agent any
    environment {
      TOKEN_MON         = credentials('gh-token')
      LOGIN             = sh script:"vault login -method=github token=${TOKEN_MON}"
      DIGITALOCEN_TOKEN = sh(script:'vault kv get -field=do_token workshop/eosorio/DigitalOcean', returnStdout: true).trim()
    }
    stages {
        stage("init"){
            steps{
                echo 'init'
                sh 'cd terraform && terraform init -input=false'
            }
        }

        stage("validate") {
            steps{
                echo 'validating'
            }
        }

        stage("plan") {
            steps{
                echo 'Planning'
            }
        }

        stage("apply") {
            steps{
                echo 'Applying'
            }
        }

        stage("destroy") {
            steps{
                echo 'Bybye!'
            }
        }

    }
}
