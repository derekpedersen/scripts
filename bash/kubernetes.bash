```bash
#!/usr/bin/env bash

# ============================================================
# Kubernetes Bash Helpers
# ============================================================
#
# Add to ~/.bashrc:
#
#   source ~/.kube-functions.sh
#
# Or put this file somewhere like:
#
#   ~/.config/bash/kubernetes.sh
#
# ============================================================

# ------------------------------------------------------------
# Basic shortcuts
# ------------------------------------------------------------

alias k='kubectl'

# Current context
kctx() {
    kubectl config current-context
}

# List contexts
kctxs() {
    kubectl config get-contexts
}

# Switch context
kuse() {
    kubectl config use-context "$1"
}

# Current namespace
kns() {
    kubectl config view --minify --output 'jsonpath={..namespace}'
    echo
}

# List namespaces
knamespaces() {
    kubectl get namespaces "$@"
}

# Set namespace for current context
kuse-ns() {
    if [[ -z "$1" ]]; then
        echo "Usage: kuse-ns <namespace>"
        return 1
    fi

    kubectl config set-context --current --namespace="$1"
    echo "Namespace: $1"
}

# Alias for kuse-ns
ksetns() {
    kuse-ns "$@"
}


# ------------------------------------------------------------
# Pods
# ------------------------------------------------------------

# List pods
kpods() {
    kubectl get pods "$@"
}

# List pods across all namespaces
kpodsa() {
    kubectl get pods -A "$@"
}

# Watch pods
kwatch() {
    kubectl get pods -w "$@"
}

# Pods with more information
kpodwide() {
    kubectl get pods -o wide "$@"
}

# Describe a pod
kdescribe() {
    if [[ -z "$1" ]]; then
        echo "Usage: kdescribe <pod>"
        return 1
    fi

    kubectl describe pod "$1"
}

# Get pod YAML
kyaml() {
    if [[ -z "$1" ]]; then
        echo "Usage: kyaml <pod>"
        return 1
    fi

    kubectl get pod "$1" -o yaml
}


# ------------------------------------------------------------
# Pod debugging
# ------------------------------------------------------------

# Find unhealthy/problematic pods
kbad() {
    kubectl get pods -A | \
        grep -Ev 'Running|Completed|STATUS'
}

# Find CrashLoopBackOff pods
kcrash() {
    kubectl get pods -A | grep 'CrashLoopBackOff'
}

# Find pending pods
kpending() {
    kubectl get pods -A | grep 'Pending'
}

# Find pods that have restarted
krestarts() {
    kubectl get pods -A | awk '
        NR == 1 || $4 != 0
    '
}

# Show pods sorted by restart count
krestartsort() {
    kubectl get pods -A --sort-by='.status.containerStatuses[0].restartCount'
}

# Show pod status with node information
kpodstatus() {
    kubectl get pods -A -o wide
}


# ------------------------------------------------------------
# Logs
# ------------------------------------------------------------

# Pod logs
klogs() {
    if [[ -z "$1" ]]; then
        echo "Usage: klogs <pod> [kubectl logs options]"
        return 1
    fi

    kubectl logs "$@"
}

# Follow logs
klogsf() {
    if [[ -z "$1" ]]; then
        echo "Usage: klogsf <pod>"
        return 1
    fi

    kubectl logs -f "$@"
}

# Previous container logs
klogsp() {
    if [[ -z "$1" ]]; then
        echo "Usage: klogsp <pod>"
        return 1
    fi

    kubectl logs --previous "$@"
}

# Follow logs for all containers in a pod
klogsall() {
    kubectl logs "$1" --all-containers=true -f
}

# Logs for a deployment
klogs-deploy() {
    if [[ -z "$1" ]]; then
        echo "Usage: klogs-deploy <deployment>"
        return 1
    fi

    kubectl logs deployment/"$1" -f
}


# ------------------------------------------------------------
# Shell / exec
# ------------------------------------------------------------

# Shell into a pod
kexec() {
    if [[ -z "$1" ]]; then
        echo "Usage: kexec <pod>"
        return 1
    fi

    kubectl exec -it "$1" -- /bin/sh
}

# Bash into a pod
kexecbash() {
    if [[ -z "$1" ]]; then
        echo "Usage: kexecbash <pod>"
        return 1
    fi

    kubectl exec -it "$1" -- /bin/bash
}


# ------------------------------------------------------------
# Deployments
# ------------------------------------------------------------

# List deployments
kdep() {
    kubectl get deployments "$@"
}

# Restart deployment
krestart() {
    if [[ -z "$1" ]]; then
        echo "Usage: krestart <deployment>"
        return 1
    fi

    kubectl rollout restart deployment "$1"
}

# Rollout status
krollout() {
    if [[ -z "$1" ]]; then
        echo "Usage: krollout <deployment>"
        return 1
    fi

    kubectl rollout status deployment "$1"
}

# Deployment history
khistory() {
    if [[ -z "$1" ]]; then
        echo "Usage: khistory <deployment>"
        return 1
    fi

    kubectl rollout history deployment "$1"
}

# Roll back deployment
krollback() {
    if [[ -z "$1" ]]; then
        echo "Usage: krollback <deployment>"
        return 1
    fi

    echo "WARNING: Rolling back deployment '$1'."
    read -r -p "Continue? [y/N] " answer

    [[ "$answer" =~ ^[Yy]$ ]] || {
        echo "Cancelled."
        return 1
    }

    kubectl rollout undo deployment "$1"
}

# Scale deployment
kscale() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: kscale <deployment> <replicas>"
        return 1
    fi

    kubectl scale deployment "$1" --replicas="$2"
}


# ------------------------------------------------------------
# Services / networking
# ------------------------------------------------------------

# Services
ksvc() {
    kubectl get services "$@"
}

# Ingresses
king() {
    kubectl get ingress "$@"
}

# Port-forward
kport() {
    if [[ -z "$1" ]]; then
        echo "Usage: kport <resource> <local-port>:<remote-port>"
        echo "Example: kport svc/api 8080:80"
        return 1
    fi

    kubectl port-forward "$@"
}

# Show endpoints
kendpoints() {
    kubectl get endpoints "$@"
}

# Show network-related resources
knet() {
    kubectl get svc,ingress,endpoints "$@"
}


# ------------------------------------------------------------
# Nodes
# ------------------------------------------------------------

# List nodes
knodes() {
    kubectl get nodes "$@"
}

# Wide node list
knodeswide() {
    kubectl get nodes -o wide "$@"
}

# Describe node
knode() {
    if [[ -z "$1" ]]; then
        echo "Usage: knode <node>"
        return 1
    fi

    kubectl describe node "$1"
}


# ------------------------------------------------------------
# Events / troubleshooting
# ------------------------------------------------------------

# Events sorted chronologically
kevents() {
    kubectl get events --sort-by='.lastTimestamp' "$@"
}

# Recent events
kevents-recent() {
    kubectl get events \
        --sort-by='.lastTimestamp' \
        "$@" |
        tail -30
}

# Warning events only
kerrors() {
    kubectl get events -A \
        --field-selector type=Warning \
        --sort-by='.lastTimestamp'
}

# Events for a particular namespace
knsevents() {
    if [[ -z "$1" ]]; then
        echo "Usage: knsevents <namespace>"
        return 1
    fi

    kubectl get events \
        -n "$1" \
        --sort-by='.lastTimestamp'
}


# ------------------------------------------------------------
# Resources / metrics
# ------------------------------------------------------------

# All resources in current namespace
kall() {
    kubectl get all "$@"
}

# All resources across namespaces
kalla() {
    kubectl get all -A "$@"
}

# CPU/memory usage for pods
ktop() {
    kubectl top pods "$@"
}

# CPU/memory usage for nodes
ktopn() {
    kubectl top nodes "$@"
}

# Wide output for any resource
kwide() {
    kubectl get "$@" -o wide
}


# ------------------------------------------------------------
# ConfigMaps / Secrets
# ------------------------------------------------------------

kcm() {
    kubectl get configmaps "$@"
}

ksecret() {
    kubectl get secrets "$@"
}

# Show secret metadata without exposing values
ksecret-info() {
    if [[ -z "$1" ]]; then
        echo "Usage: ksecret-info <secret>"
        return 1
    fi

    kubectl describe secret "$1"
}


# ------------------------------------------------------------
# Rollouts
# ------------------------------------------------------------

# Wait for deployment rollout
kwait() {
    if [[ -z "$1" ]]; then
        echo "Usage: kwait <deployment>"
        return 1
    fi

    kubectl rollout status deployment "$1" --watch
}

# Show rollout history
krollouts() {
    kubectl rollout history deployment "$1"
}

# Undo latest rollout
kundo() {
    if [[ -z "$1" ]]; then
        echo "Usage: kundo <deployment>"
        return 1
    fi

    echo "WARNING: Rolling back deployment '$1'."
    read -r -p "Continue? [y/N] " answer

    [[ "$answer" =~ ^[Yy]$ ]] || {
        echo "Cancelled."
        return 1
    }

    kubectl rollout undo deployment "$1"
}


# ------------------------------------------------------------
# Resource inspection
# ------------------------------------------------------------

# Get resource by name
kget() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: kget <resource> <name>"
        echo "Example: kget pod api-123"
        return 1
    fi

    kubectl get "$1" "$2"
}

# Describe any resource
kdesc() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: kdesc <resource> <name>"
        echo "Example: kdesc deployment api"
        return 1
    fi

    kubectl describe "$1" "$2"
}

# Get YAML for any resource
kgetyaml() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: kgetyaml <resource> <name>"
        return 1
    fi

    kubectl get "$1" "$2" -o yaml
}


# ------------------------------------------------------------
# Cluster overview
# ------------------------------------------------------------

kinfo() {
    echo "========================================"
    echo " Kubernetes Cluster"
    echo "========================================"
    echo "Context:   $(kubectl config current-context)"
    echo "Namespace: $(kns)"
    echo

    echo "Nodes:"
    kubectl get nodes
    echo

    echo "Pods:"
    kubectl get pods
}

# Quick cluster health check
khealth() {
    echo "=== Context ==="
    kubectl config current-context
    echo

    echo "=== Nodes ==="
    kubectl get nodes
    echo

    echo "=== Problem Pods ==="
    kbad || true
    echo

    echo "=== Warnings ==="
    kerrors || true
}


# ------------------------------------------------------------
# Interactive pod picker
# ------------------------------------------------------------

# Requires fzf
kpod() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "kpod requires fzf."
        echo "Install fzf first."
        return 1
    fi

    local pod

    pod=$(kubectl get pods \
        --no-headers \
        -o custom-columns=':metadata.name' |
        fzf)

    [[ -n "$pod" ]] || return 0

    echo "Selected pod: $pod"
    kubectl describe pod "$pod"
}

# Interactive pod shell
kpod-shell() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "kpod-shell requires fzf."
        return 1
    fi

    local pod

    pod=$(kubectl get pods \
        --no-headers \
        -o custom-columns=':metadata.name' |
        fzf)

    [[ -n "$pod" ]] || return 0

    kubectl exec -it "$pod" -- /bin/sh
}

# Interactive pod logs
kpod-logs() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "kpod-logs requires fzf."
        return 1
    fi

    local pod

    pod=$(kubectl get pods \
        --no-headers \
        -o custom-columns=':metadata.name' |
        fzf)

    [[ -n "$pod" ]] || return 0

    kubectl logs -f "$pod"
}


# ------------------------------------------------------------
# Namespace-wide debugging
# ------------------------------------------------------------

kdebug() {
    echo "========================================"
    echo " Kubernetes Debug"
    echo "========================================"

    echo
    echo "Context:"
    kubectl config current-context

    echo
    echo "Namespace:"
    kns

    echo
    echo "Pods:"
    kubectl get pods -o wide

    echo
    echo "Deployments:"
    kubectl get deployments

    echo
    echo "Services:"
    kubectl get services

    echo
    echo "Recent warnings:"
    kubectl get events \
        --field-selector type=Warning \
        --sort-by='.lastTimestamp' |
        tail -20
}


# ------------------------------------------------------------
# Useful aliases
# ------------------------------------------------------------

alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ke='kubectl exec -it'
alias ka='kubectl apply'
alias kdel='kubectl delete'

# Frequently used resource shortcuts
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'
alias kgi='kubectl get ingress'
alias kgcm='kubectl get configmaps'
alias kgsec='kubectl get secrets'

