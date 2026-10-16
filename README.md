# pub
Public stuff for stuff that's public

## for kargo
1. grab the helm repo
2. create directories
```
mkdir -p argo helm/stages/prod helm/stages/uat helm/stages/dev helm/stages/base kargo
```
3. Create a Chart.yaml and a values.yaml in each of the stages
4. Remember what is changing.  If you're updating an image, then a singular Chart.yaml
is fine, but if you're updating chart versions, then kargo needs a place to
make the changes.
5. 