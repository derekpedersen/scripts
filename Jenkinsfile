pipeline {
    agent {
        label 'build-base-stable'
    }

    options {
        skipDefaultCheckout true
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                dir("${env.WORKSPACE}") {
                    checkout scm
                }
            }
        }

        stage('Prepare environment') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh '''
                        #!/usr/bin/env bash
                        set -euo pipefail
                        bash --version
                        uname -a
                        test -d bash
                        test -d tools
                        test -d helm
                    '''
                }
            }
        }

        stage('Validate bash scripts') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh '''
                        #!/usr/bin/env bash
                        set -euo pipefail

                        for f in bash/*.bash; do
                            echo "  - ${f}"
                            bash -n "$f"
                        done
                    '''
                }
            }
        }

        stage('Validate tools scripts') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh '''
                        #!/usr/bin/env bash
                        set -euo pipefail

                        for f in tools/*.sh; do
                            echo "  - ${f}"
                            bash -n "$f"
                        done
                    '''
                }
            }
        }

        stage('Validate helm scripts') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh '''
                        #!/usr/bin/env bash
                        set -euo pipefail

                        for f in helm/*.sh; do
                            echo "  - ${f}"
                            bash -n "$f"
                        done
                    '''
                }
            }
        }

        stage('Smoke test installer bundles') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh '''
                        #!/usr/bin/env bash
                        set -euo pipefail

                        for bundle in default services cloud; do
                            echo "Testing bundle: ${bundle}"
                            bash ./tools/install.sh "$bundle" --dry-run
                        done
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Jenkins validation for repo scripts completed.'
        }
    }
}
