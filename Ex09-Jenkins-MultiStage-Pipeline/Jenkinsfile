pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Creating virtual environment and installing dependencies...'
                sh '''
                python3 -m venv ${WORKSPACE}/venv
                ${WORKSPACE}/venv/bin/pip install --upgrade pip
                ${WORKSPACE}/venv/bin/pip install -r requirements.txt
                '''
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh '${WORKSPACE}/venv/bin/python -m unittest discover -s . -v'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh '''
                mkdir -p ${WORKSPACE}/python-app-deploy
                cp ${WORKSPACE}/app.py ${WORKSPACE}/test_app.py ${WORKSPACE}/python-app-deploy/
                ls -l ${WORKSPACE}/python-app-deploy
                '''
            }
        }
        stage('Run Application') {
            steps {
                echo 'Running application...'
                sh '''
                nohup ${WORKSPACE}/venv/bin/python ${WORKSPACE}/python-app-deploy/app.py > ${WORKSPACE}/python-app-deploy/app.log 2>&1 &
                echo $! > ${WORKSPACE}/python-app-deploy/app.pid
                sleep 3
                cat ${WORKSPACE}/python-app-deploy/app.log
                '''
            }
        }
        stage('Test Application') {
            steps {
                echo 'Testing application...'
                sh '''
                cd ${WORKSPACE}/python-app-deploy
                ${WORKSPACE}/venv/bin/python test_app.py
                echo "Live check of the running app:"
                curl -s http://localhost:5000/
                echo
                '''
            }
        }
    }

    post {
        always {
            sh 'kill $(cat ${WORKSPACE}/python-app-deploy/app.pid) 2>/dev/null || true'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for more details.'
        }
    }
}
