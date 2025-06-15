// Định nghĩa cấu hình cho các services ứng dụng
// Hàm này trả về một map các cấu hình dựa trên môi trường
def getAppServiceConfigs(String environment) {
    return [
        "user-service": [
            chartPath: "application/user-service",
            helmReleaseNameSuffix: "-${environment}",
            valueFiles: ["values.yaml", "values.${environment}.yaml"],
            namespace: "default",
            imageMutable: true,
            createNamespace: true
        ],
        "team-service": [
            chartPath: "application/team-service",
            helmReleaseNameSuffix: "-${environment}",
            valueFiles: ["values.yaml", "values.${environment}.yaml"],
            namespace: "default",
            imageMutable: true,
            createNamespace: true
        ],
        "chat-service": [
            chartPath: "application/chat-service",
            helmReleaseNameSuffix: "-${environment}",
            valueFiles: ["values.yaml", "values.${environment}.yaml"],
            namespace: "default",
            imageMutable: true,
            createNamespace: true
        ],
        "meeting-service": [
            chartPath: "application/meeting-service",
            helmReleaseNameSuffix: "-${environment}",
            valueFiles: ["values.yaml", "values.${environment}.yaml"],
            namespace: "default",
            imageMutable: true,
            createNamespace: true
        ],
        "websocket-service": [
            chartPath: "application/websocket-service",
            helmReleaseNameSuffix: "-${environment}",
            valueFiles: ["values.yaml", "values.${environment}.yaml"],
            namespace: "default",
            imageMutable: true,
            createNamespace: true
        ],
        "frontend-service": [
            chartPath: "application/frontend-service",
            helmReleaseNameSuffix: "-${environment}",
            valueFiles: ["values.yaml", "values.${environment}.yaml"],
            namespace: "default",
            imageMutable: true,
            createNamespace: true
        ]
    ]
}

def deployAppService(String serviceName, String environment, String imageTag, Map config) {
    echo "Đang triển khai dịch vụ ứng dụng ${serviceName} vào môi trường ${environment} sử dụng chart tại ./${config.chartPath}"
    
    // Kiểm tra chart có tồn tại không
    if (!fileExists("./application/${serviceName}/Chart.yaml")) {
        error("Chart for ${serviceName} not found at ./application/${serviceName}/")
    }
    
    // Deploy service (đã loại bỏ HELM_DRIVER=configmaps)
    sh """
        helm upgrade --install ${serviceName}-${environment} ./application/${serviceName} \\
            --namespace ${config.namespace} \\
            --values ./application/${serviceName}/values.yaml \\
            --values ./application/${serviceName}/values.${environment}.yaml \\
            --set image.imageTag=${imageTag} \\
            --wait \\
            --timeout=600s
    """
    
    // Verify deployment
    sh """
        kubectl rollout status deployment/${serviceName} -n ${config.namespace} --timeout=300s
        kubectl get pods -n ${config.namespace} -l app.kubernetes.io/name=${serviceName}
    """
}


pipeline {
    agent {
    kubernetes {
        label 'jenkins-cd'
        namespace 'jenkins'
        yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  automountServiceAccountToken: true
  containers:
  - name: kubectl-helm-aws
    image: dtzar/helm-kubectl:latest  
    command:
    - sleep
    - infinity
    tty: true
    env:
    - name: HOME
      value: /home/jenkins
    securityContext:
      runAsUser: 0
      runAsGroup: 0
"""
        }
    }
    
    environment {
        AWS_REGION = 'ap-southeast-1'
        EKS_CLUSTER_NAME = 'doan-cluster-dev' // Cập nhật tên cluster của bạn
    }
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'prod'],
            description: 'Chọn môi trường triển khai'
        )
        choice(
            name: 'SERVICE',
            // Cập nhật danh sách services dựa trên keys của getAppServiceConfigs
            choices: ['all', 'chat-service', 'frontend-service', 'meeting-service', 'team-service', 'user-service', 'websocket-service'],
            description: 'Chọn dịch vụ ứng dụng để triển khai'
        )
        string(
            name: 'IMAGE_TAG',
            defaultValue: 'latest',
            description: 'Docker image tag to deploy'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Jenkins tự động checkout code từ Git repository
                checkout scm
                
                // Hoặc checkout từ specific repository
                // git branch: 'main', 
                //     credentialsId: 'git-credentials',
                //     url: 'https://github.com/your-org/k8s-repo.git'
            }
        }
        
        stage('Verify Chart Files') {
            steps {
                container('kubectl-helm-aws') {
                    script {
                        echo "Verifying application service chart directories based on configurations..."
                        def appServiceConfigs = getAppServiceConfigs(params.ENVIRONMENT)
                        
                        // Xác định services cần kiểm tra
                        def servicesToCheck = []
                        if (params.SERVICE == 'all') {
                            servicesToCheck = appServiceConfigs.keySet() as List
                        } else if (appServiceConfigs.containsKey(params.SERVICE)) {
                            servicesToCheck = [params.SERVICE]
                        }

                        if (servicesToCheck.isEmpty() && params.SERVICE != 'all') {
                            echo "Cảnh báo: Dịch vụ ứng dụng '${params.SERVICE}' không được cấu hình hoặc không phải 'all'. Sẽ không kiểm tra chart nào."
                        } else if (servicesToCheck.isEmpty() && params.SERVICE == 'all') {
                             echo "Thông tin: Không có dịch vụ ứng dụng nào được cấu hình trong getAppServiceConfigs. Sẽ không kiểm tra chart nào."
                        }

                        servicesToCheck.each { serviceName ->
                            def config = appServiceConfigs[serviceName]
                            echo "Checking chart for application service ${serviceName} at ./${config.chartPath}"
                            
                            // Using Groovy file check instead of bash
                            if (fileExists("./${config.chartPath}/Chart.yaml")) {
                                echo "✓ Chart.yaml found for ${serviceName}"
                            } else {
                                echo "✗ Chart.yaml NOT found for ${serviceName} at ./${config.chartPath}/Chart.yaml"
                                // Uncomment the line below if you want to fail the pipeline when chart is not found
                                // error("Chart not found for ${serviceName}")
                            }
                        }
                    }
                }
            }
        }
        
stage('Configure Kubernetes') {
    steps {
        container('kubectl-helm-aws') {
            script {
                echo "Configuring Kubernetes access..."
                withCredentials([string(credentialsId: 'k8s-token', variable: 'K8S_TOKEN')]) {
                    sh '''
                        # Set explicit EKS API URL
                        EKS_API_URL="https://60D987A0858DD749C546465804F98DE2.gr7.ap-southeast-1.eks.amazonaws.com"
                        
                        # Configure kubectl with explicit cluster URL
                        kubectl config set-cluster eks-cluster --server=${EKS_API_URL} --insecure-skip-tls-verify=true
                        
                        # Configure kubectl to use token authentication
                        echo "${K8S_TOKEN}" > /tmp/k8s_token
                        kubectl config set-credentials token-user --token=$(cat /tmp/k8s_token)
                        
                        # Set context to use the explicit cluster and user
                        kubectl config set-context eks-context --cluster=eks-cluster --user=token-user
                        
                        # Use the new context
                        kubectl config use-context eks-context
                        
                        # Clean up token file
                        rm /tmp/k8s_token
                        
                        # Verify tools
                        kubectl version --client
                        helm version
                        
                        # Test cluster connectivity
                        kubectl cluster-info
                    '''
                }
            }
        }
    }
}
        
        stage('Deploy Application Services') {
            steps {
                container('kubectl-helm-aws') {
                    script {
                        def servicesToDeploy = []
                        def appServiceConfigs = getAppServiceConfigs(params.ENVIRONMENT)

                        if (params.SERVICE == 'all') {
                            servicesToDeploy = appServiceConfigs.keySet() as List
                        } else {
                            if (appServiceConfigs.containsKey(params.SERVICE)) {
                                servicesToDeploy = [params.SERVICE]
                            } else {
                                error("Dịch vụ ứng dụng ${params.SERVICE} không được tìm thấy trong cấu hình.")
                            }
                        }

                        if (servicesToDeploy.isEmpty()) {
                            echo "Không có dịch vụ ứng dụng nào được chọn hoặc cấu hình để triển khai."
                        } else {
                            servicesToDeploy.each { serviceName ->
                                def serviceConfig = appServiceConfigs[serviceName]
                                if (serviceConfig) {
                                    deployAppService(serviceName, params.ENVIRONMENT, params.IMAGE_TAG, serviceConfig)
                                } else {
                                    echo "Cảnh báo: Không tìm thấy cấu hình cho dịch vụ ứng dụng ${serviceName}. Bỏ qua."
                                }
                            }
                        }
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                container('kubectl-helm-aws') {
                    script {
                        def appServiceConfigs = getAppServiceConfigs(params.ENVIRONMENT)
                        def servicesToCheck = []
                        if (params.SERVICE == 'all') {
                            servicesToCheck = appServiceConfigs.keySet() as List
                        } else {
                            if (appServiceConfigs.containsKey(params.SERVICE)) {
                                servicesToCheck = [params.SERVICE]
                            }
                        }
                        
                        if (servicesToCheck.isEmpty()) {
                            echo "Không có dịch vụ ứng dụng nào được chọn hoặc cấu hình để xác minh."
                        } else {
                            servicesToCheck.each { serviceName ->
                                def serviceConfig = appServiceConfigs[serviceName]
                                if (serviceConfig) {
                                    sh """
                                        echo "Kiểm tra deployment cho dịch vụ ứng dụng ${serviceName} trong namespace ${serviceConfig.namespace}:"
                                        kubectl get all -n ${serviceConfig.namespace} -l app.kubernetes.io/name=${serviceName}
                                        # Hoặc một label selector phù hợp hơn cho từng chart
                                    """
                                }
                            }
                            echo "Kiểm tra Helm releases cho các dịch vụ ứng dụng:"
                            // Liệt kê releases trong các namespace đã dùng cho app services
                            def namespacesUsed = (appServiceConfigs.values().collect { it.namespace } as Set).unique()
                            namespacesUsed.each { ns ->
                                sh "echo --- Releases in namespace ${ns} ---; helm list -n ${ns}"
                            }
                        }
                    }
                }
            }
        }
    }
    
   post {
    always {
        echo "Pipeline completed, skipping explicit workspace cleanup"
        // Let Jenkins handle workspace cleanup automatically
    }
    success {
        echo "Deployment successful for ${params.SERVICE} in ${params.ENVIRONMENT} environment"
    }
    failure {
        echo "Deployment failed for ${params.SERVICE} in ${params.ENVIRONMENT} environment"
    }
}
}