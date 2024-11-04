.PHONY: all
all: help

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
##@ Main


# .PHONY: bootstrap
# bootstrap: bootstrap-prod   ## flux bootstrap cluster flux-system

# .PHONY: apps-source-git
# apps-source-git: create-sources-git-prod  ## flux create git apps source repositories

# .PHONY: bootstrap-staging
# bootstrap-staging: flux-update ## flux bootstrap gitlab staging
# 	-kubectl create ns flux-system
# 	oc adm policy add-scc-to-user nonroot-v2 -z source-controller -n flux-system
# 	oc adm policy add-scc-to-user nonroot-v2 -z notification-controller -n flux-system
# 	flux bootstrap git \
# 	--url=ssh://git@gitlab.lab.okd.local/gitops/flux-infra.git \
# 	--branch=develop \
# 	--private-key-file=/root/.private/id_rsa_flux-staging \
# 	--path=clusters/staging \
# 	--silent

# .PHONY: bootstrap-prod
# bootstrap-prod: flux-update ## flux bootstrap gitlab staging
# 	# -kubectl create ns flux-system
# 	# oc adm policy add-scc-to-user nonroot-v2 -z source-controller -n flux-system
# 	# oc adm policy add-scc-to-user nonroot-v2 -z notification-controller -n flux-system
# 	# flux bootstrap git \
# 	# --url=ssh://git@gitlab.lab.okd.local/gitops/flux-infra.git \
# 	# --branch=main \
# 	# --private-key-file=/root/.private/id_rsa_flux-production \
# 	# --path=clusters/production \
# 	# --silent

# .PHONY: create-sources-git-prod
# create-sources-git-prod: ## icreate source git repositories
# 	@echo "flux create source git confluent-charts \
# 	--url=ssh://git@gitlab.lab.okd.local/helm/confluent.git \
# 	--branch=main \
# 	--private-key-file=/root/.private/id_rsa_flux-production \
# 	--silent \
# 	--namespace=confluent"
# 	@echo "flux create source git tomcat-metallb-chart \
# 	--url=ssh://git@gitlab.lab.okd.local/helm/tomcat-metallb.git \
# 	--branch=main \
# 	--private-key-file=/root/.private/id_rsa_flux-production \
# 	--silent \
# 	--namespace=tomcat-metallb"

# .PHONY: uninstall
# uninstall: ## uninstall
# 	flux uninstall --silent

PATH  := $(PATH):$(PWD)/bin
SHELL := env PATH=$(PATH) /bin/sh
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m | sed 's/x86_64/amd64/')

.PHONY: update
update: flux-update jq-update yq-update kubeconform-update kustomize-update helm-update ## update tools

.PHONY: flux-update
flux-update: ## flux update
	@wget -c $$(curl -s https://api.github.com/repos/fluxcd/flux2/releases | jq -r '.[0].assets[] | select(.browser_download_url | contains("_linux_amd64.tar.gz")) | .browser_download_url') -O - | tar xz -C /usr/local/bin
	@rm -f *tar.gz*
	flux -v
	
.PHONY: jq-update
jq-update: ## jq update
	@dnf update jq -y
	jq --version

.PHONY: yq-update
yq-update: ## yq update
	@wget -c $$(curl -s https://api.github.com/repos/mikefarah/yq/releases | jq -r '.[0].assets[] | select(.browser_download_url | contains("_linux_amd64.tar.gz")) | .browser_download_url') -O - | tar xz -C /usr/local/bin
	@mv /usr/local/bin/yq_linux_amd64 /usr/local/bin/yq
	@rm -f *tar.gz*
	@rm -f /usr/local/bin/yq.*
	yq -V

.PHONY: kubeconform-update
kubeconform-update: ## kubeconform update
	@wget -c $$(curl -s https://api.github.com/repos/yannh/kubeconform/releases | jq -r '.[0].assets[] | select(.browser_download_url | contains("-linux-amd64.tar.gz")) | .browser_download_url') -O - | tar xz -C /usr/local/bin
	@rm -f *tar.gz*
	kubeconform -v 

.PHONY: kustomize-update
kustomize-update: ## kustomize update
	@wget -c $$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases | jq -r '.[1].assets[] | select(.browser_download_url | contains("_linux_amd64.tar.gz")) | .browser_download_url') -O - | tar xz -C /usr/local/bin
	@rm -f *tar.gz*
	kustomize version

.PHONY: helm-update
helm-update: ## helm update
	@curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	@chmod 700 get_helm.sh
	@./get_helm.sh 
	@rm -f get_helm.sh
	helm version

.PHONY: k9s-update
k9s-update: ## k9s update
	@wget -c $$(curl -s https://api.github.com/repos/derailed/k9s/releases | jq -r '.[0].assets[] | select(.browser_download_url | contains("_Linux_amd64.tar.gz")) | .browser_download_url') -O - | tar xz -C /usr/local/bin
	@rm -f *tar.gz*
	kustomize version
