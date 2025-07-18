properties(
    [
        githubProjectProperty(
            displayName: 'docker-internxt-cli',
            projectUrlStr: 'https://github.com/ruepp-jenkins/docker-internxt-cli'
        ),
        disableConcurrentBuilds()
    ]
)

pipeline {
    agent {
        label 'docker'
    }

    environment {
        IMAGE_FULLNAME = 'ruepp/internxt-cli'
        DOCKER_API_PASSWORD = credentials('DOCKER_API_PASSWORD')
    }

    triggers {
        URLTrigger(
            cronTabSpec: 'H/30 * * * *',
            entries: [
                URLTriggerEntry(
                    url: 'https://registry.npmjs.org/@internxt/cli/latest',
                    contentTypes: [
                        JsonContent(
                            [
                                JsonContentEntry(jsonPath: '$.version')
                            ]
                        )
                    ]
                ),
                URLTriggerEntry(
                    url: 'https://hub.docker.com/v2/namespaces/library/repositories/node/tags/lts',
                    contentTypes: [
                        JsonContent(
                            [
                                JsonContentEntry(jsonPath: '$.last_updated')
                            ]
                        )
                    ]
                )
            ]
        )
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: env.BRANCH_NAME, url: env.GIT_URL
            }
        }
        stage('Build') {
            steps {
                sh 'chmod +x scripts/*.sh'
                sh './scripts/start.sh'
            }
        }
    }

    post {
        always {
            discordSend result: currentBuild.currentResult,
                description: env.GIT_URL,
                link: env.BUILD_URL,
                title: JOB_NAME,
                webhookURL: DISCORD_WEBHOOK
            cleanWs()
        }
    }
}
