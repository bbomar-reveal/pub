apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: podinfo
  namespace: argocd
spec:
  goTemplate: true
  goTemplateOptions: ["missingkey=error"]
  generators:
    - clusters:
        selector:
          matchExpressions:
            - { key: cluster, operator: In, values: [dev, uat, prod] }
  template:
    metadata:
      name: podinfo
    spec:
      project: default
      source:
        repoURL: https://github.com/bbomar-reveal/pub.git
        targetRevision: HEAD
        path: 'apps/podinfo/stages/{{ index .metadata.labels "cluster" }}'
        helm:
          valueFiles:
            - ../../base/values.yaml
            - values.yaml
      destination:
        server: https://kubernetes.default.svc
        namespace: podinfo
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
          - ServerSideApply=true