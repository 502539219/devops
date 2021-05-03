#!/usr/bin/env groovy

def mailRecipients = "DigitalConnectDevOpsJenkinsApprovers@ge.com"

pipeline {
    agent none
    environment {
        COMPLIANCEENABLED = true
    }
    parameters {
		string(name: 'BUCKET_NAME', defaultValue: '', description: 'name of the bucket (this name should be the bucket folder placed in git repo which you want to trigger)')
        // choice(name: 'DESTROY_TERRAFORM', choices: ['False','True'], description: 'If you want to run the destroy command for terraform')
	}
    options {
        buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '10', daysToKeepStr: '', numToKeepStr: '10'))
    }
    stages {
        stage('Dry run for s3 bucket creation') {
            agent {
				docker {
					image 'registry.gear.ge.com/digital-connect/ci-builder-tf-k8:1.1.0'
					label 'dind'
				}
			}
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'dc-jenkins-s3', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    script {
                    // Add Param Hack to workaround issue of parameters being null during first build
                    params.each { k, v -> env[k] = v }

                    sh "cd module && \
		            terraform version && \
                    terraform init -no-color -backend-config=../buckets/${BUCKET_NAME}/backend_config.tfvars -input=false && \
                    export TF_LOG=trace && \
                    terraform plan -no-color -input=false -var-file=../buckets/${BUCKET_NAME}/terraform.tfvars -out=${BUCKET_NAME}-tfplan && \
                    terraform show -no-color ${BUCKET_NAME}-tfplan > ../${BUCKET_NAME}-tfplan"

                    stash includes: 'module/s3.tf', name: 'terraform-module'
                    stash includes: "${BUCKET_NAME}-tfplan", name: 'terraform-plan'
                    }
                }                
            }
            post {
                success {
                    echo 'Dry run completed for s3 bucket'
                }
                failure {
                    echo 'Dry run failed for s3 bucket'
                }
                always {
                    deleteDir()
                }
            }
        }
        stage('Request for Approval') {
            agent {
                label 'dind'
			}
            steps {
                script {
                    unstash 'terraform-plan'
                    def jobName = currentBuild.fullDisplayName

                    // TODO: Wrap in Try Catch to handle timeout or user abort and notify accordingly
                    timeout(time:1, unit:'DAYS') {
                        emailext (
                            body: "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\"><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><title>Build from Jenkins</title><style type=\"text/css\">/*base css*/a{color:#4a72af}body{background-color:#e4e4e4}body,p{margin:0;padding:0}img{display:block}h1,h2,h3,h4,h5,h6{margin:0 0 .8em 0}h3{font-size:28px;color:#444!important;font-family:Arial,Helvetica,sans-serif}h4{font-size:22px;color:#4a72af!important;font-family:Arial,Helvetica,sans-serif}h5{font-size:18px;color:#444!important;font-family:Arial,Helvetica,sans-serif}p{font-size:12px;color:#444!important;font-family:\"Lucida Grande\",\"Lucida Sans\",\"Lucida Sans Unicode\",sans-serif;line-height:1.5}ol li img{display:inline;height:20px}/*div styles*/.news{text-align:center;padding-top:15px;}.content{width:720px;background-color:white;margin-left: auto; margin-right: auto ;}.round_border{margin-bottom:5px;-webkit-border-radius:6px;-moz-border-radius:6px;border-radius:6px;margin-top:0;font-size:14px;padding:6px;border:1px solid #ccc}.status{background-color:green;font-size:28px;font-weight:bold;color:white;width:720px;height:52px;margin-bottom:18px;text-align:center;vertical-align:middle;border-collapse:collapse;background-repeat:no-repeat}.status .info{color:white!important;text-shadow:0 -1px 0 rgba(0,0,0,0.3);font-size:32px;line-height:36px;padding:8px 0}.main img{width:38px;margin-right:16px;height:38px}.main table{font-size:14px;}.main table th{text-align:right;}.bottom-message{width:720px;cellpadding:5px;cellspacing:0px}.bottom-message .message{font-size:13px;color:#aaa;line-height:18px;text-align:center}.bottom-message .designed{font-size:13px;color:#aaa;line-height:18px;font-style: italic;text-align:right}img.cartoon {width: 36px; display:inline}</style></head><body><!-- news --><div class=\"content round_border\"><div class=\"status\"><p class=\"info\">Terraform Changes Require an Approval </p></div><!-- status --><div class=\"main round_border\"><table><tbody><tr><th>Job:</th><td>dc-aws-s3-creation</td></tr><tr><th>Source Code:</th><td>${GIT_URL}</td></tr><tr><th>Approval URL:</th><td><a href=\"${env.BUILD_URL}input\">Link</a></td></tr><tr><th>Approval Expiration:</th><td>1 Day</td></tr><tr><td colspan=\"2\">&nbsp;</td></tr></tbody></table></div><!-- main --><div class=\"artifacts round_border\"><b>Build Artifacts:</b><ul><li>See attached tfplan file to review the proposed changes.</li></ul></div></div><!-- content --></body></html>",
                            mimeType: 'text/html',
                            subject: "[Jenkins]Build#${BUILD_NUMBER} :: Terraform Change Approval Required for s3 resources",
                            to: "${mailRecipients}",
                            from: 'jenkins-robot@do-not-reply.com',
                            replyTo: "${mailRecipients}",
                            recipientProviders: [[$class: 'CulpritsRecipientProvider']],
                            attachmentsPattern: "${BUCKET_NAME}-tfplan"
                        )
                        input message:'After Reviewing the Terraform plan, do you want to Approve or Deny these changes?', submitter: "${Devops_Jenkins_Approver},503191968", submitterParameter: 'approver'
                    }
                }
            }
            post {
                success {
                    echo 'Terraform approval success.'
                }
                failure {
                    echo 'Terraform approval failure.'
                }
                always {
                    deleteDir()
                }
            }
        }
        stage('s3 bucket creation') {
            agent {
				docker {
					image 'registry.gear.ge.com/digital-connect/ci-builder-tf-k8:1.1.0'
					label 'dind'
				}
			}
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'dc-jenkins-s3', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    script {
                        // Add Param Hack to workaround issue of parameters being null during first build
                        params.each { k, v -> env[k] = v }             
                        sh "cd module && \
			            terraform init -no-color -backend-config=../buckets/${BUCKET_NAME}/backend_config.tfvars -input=false && \
                    	terraform apply -no-color -var-file=../buckets/${BUCKET_NAME}/terraform.tfvars -input=false -auto-approve"

                        stash includes: 'module/s3.tf', name: 'terraform-module'
                    }
                }
            }
            post {
                success {
                    echo 's3 bucket created Sucessfully'
                }
                failure {
                    echo 'Failed to create s3 bucket'
                }
                always {
                    deleteDir()
                }
            }
        }
    }
    post {
        success {
            script {
                echo 'The build has completed successfully. Notifying...'
                def jobName = currentBuild.fullDisplayName
                emailext (
                    body: '''${SCRIPT, template="groovy-html.template"}''',
                    mimeType: 'text/html',
                    subject: "[Jenkins] ${jobName}",
                    to: "${mailRecipients}",
                    from: 'jenkins-robot@do-not-reply.com',
                    replyTo: "${mailRecipients}",
                    recipientProviders: [[$class: 'CulpritsRecipientProvider']]
                )
            }
        }
        failure {
            script {
                echo 'The build was unsuccessful. Notifying...'
                def jobName = currentBuild.fullDisplayName
                emailext (
                    body: '''${SCRIPT, template="groovy-html.template"}''',
                    mimeType: 'text/html',
                    subject: "[Jenkins] ${jobName}",
                    to: "${mailRecipients}",
                    from: 'jenkins-robot@do-not-reply.com',
                    replyTo: "${mailRecipients}",
                    recipientProviders: [[$class: 'CulpritsRecipientProvider']]
                )
            }
        }
    }
}
