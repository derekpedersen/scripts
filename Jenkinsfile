pipeline {
    agent {
        label 'build-base-stable'
    }

    options {
        skipDefaultCheckout true
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

        stage('Validate helm set-version behavior') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh '''
                        #!/usr/bin/env bash
                        set -euo pipefail

                        chart_tmp="$(mktemp)"
                        trap 'rm -f "$chart_tmp"' EXIT

                        cat > "$chart_tmp" <<'EOF'
apiVersion: v2
name: demo
description: temp fixture for CI validation
version: 0.1.0
appVersion: old
EOF

                        expected_sha="$(git rev-parse HEAD)"
                        CHART_FILE="$chart_tmp" bash ./helm/set-version.sh

                        echo "Resulting chart fixture:"
                        cat "$chart_tmp"

                        grep -Eq '^version: [0-9]{4}\.[0-9]{2}\.[0-9]{2}\.[0-9]{4}$' "$chart_tmp"
                        grep -Eq "^appVersion: ${expected_sha}$" "$chart_tmp"
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
