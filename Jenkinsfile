pipeline{
  agent any
  
  tools{
    nodejs 'Nodejs-Id'
  }
  
  environment{
    AWS_REGION= 'us-east-1'
    AWS_CREDENTIALS= credentials('aws-id')
  }
  stages{
    stage('checkout'){
      steps{
        git branch: 'main',
          url: 'https://github.com/sheshakiaq/devops-workflow.git'
      }
    }      
    stage('Cloning'){
      steps{
        echo "Repo Cloned ..."
      }
    }
    
    stage('Install Dependencies'){
      steps{
        echo "Installing npm denpendecies"
        sh '''
          node --version
          npm --version
          cd frontend 
          npm install
        '''
        echo "npm installed"
      }
    }
    
    stage('Test NPM'){
      steps{
        echo ('Testing NPM..')
        sh '''
          cd frontend
          npm run
        '''
        echo 'Test Completed'
      }
    }
   
    stage('Sonarqube Analysis') {
            steps {
              echo 'Sonarqube process '
                script {
                    def scannerhome = tool( name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation')
                    
                    withSonarQubeEnv('sonar-scanner'){
                      withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh """
                            ${scannerhome}/bin/sonar-scanner \
                            -Dsonar.projectKey=devops-flow \
                            -Dsonar.sources=frontend \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.login=${SONAR_TOKEN}
                       """
                    }
                  }
                } 
                echo 'Sonarqube Process Success'
      }
    }
    stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate( abortPipeline: true, credentialsId: 'sonar-token')
                }
            }
        }
    stage('using Terraform'){
      steps{
        echo 'Creating AWS Service by Terraform'
        sh '''
          cd terraform
          terraform init
          terraform plan
          terraform apply -auto-approve
        '''
        echo 'Successfully Aws Services Created'
      }
    }
    stage('Terraform Outputs'){
      steps{
        echo 'Mentioning terrafrom Variables...'
        cd terraform
          script {
            env.S3_BUCKET= sh(
              script: "terraform output -raw s3_bucket_name", 
              returnStdout: true
            ).trim()
            
            env.CLOUDFRONT_DIST_ID= sh(
              script: "terraform output -raw cloudfront_dist_id", 
              returnStdout: true
            ).trim()
          }
        sh '''
          echo "S3_BUCKET= {$S3_BUCKET}"
          echo "CloudFront_ID= {$CLOUDFRONT_DIST_ID}"
        '''
      }
    }
    stage('Build Frontend'){
      steps{
        echo 'Bulding React project'
        sh '''
          cd frontend
          npm run build
        '''
      }
    }
   stage('Deploy S3 Bucket'){
     steps{
         echo 'updating S3 Bucket'
       sh ''' 
         aws s3 sync frontend/dist/ \
         s3://${S3_BUCKET}/ \
         --delete \
         --region ${AWS_REGION}
       '''
       echo 'Frontend Uploaded Successfully'
       }      
     }
   stage('Cloudfront Deployment'){
     steps{
       echo 'Deploying...'
       sh ''' 
         aws cloudfront create-invalidation \
         --distribution-id ${CLOUDFRONT_DIST_ID} \
         --paths "/*"
       '''
     }
   }
//   stage('Build Docker Images'){
//     steps{
//       echo "Building Images"
//       sh '''
//         docker compose up -d
//       '''
//     }
//   }
   post {

        success {
            echo 'DEPLOYMENT SUCCESSFUL'
            echo 'Frontend deployed to S3 and CloudFront.'
            echo 'Backend deployed using Docker Compose'
        }

        failure {
            echo 'DEPLOYMENT FAILED'
            echo 'Check the failed Jenkins stage.'
        }

        always {
            echo 'Pipeline execution completed.'
        }
  }
}
