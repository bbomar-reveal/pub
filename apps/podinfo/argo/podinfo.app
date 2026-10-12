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
      annotations:
        kargo.akuity.io/authorized-stage: podinfo:{{ index .metadata.labels "cluster" }}
    spec:
      project: default
      source:
        repoURL: https://github.com/bbomar-reveal/pub.git
        targetRevision: HEAD
        path: 'apps/podinfo/stages/{{ index .metadata.labels "cluster" }}'
        helm:
          parameters:
            - name: domainName
              value: '{{ index .metadata.labels "domainName" }}'
            - name: global.domainName
              value: '{{ index .metadata.labels "domainName" }}'
          valueFiles:
            - ../../base/values.yaml
            - values.yaml
          valuesObject:
            podinfo:
              ingress:
                hosts:
                  - host: 'podinfo.{{ index .metadata.labels "domainName" }}'
                    paths:
                      - path: /
                        pathType: ImplementationSpecific
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