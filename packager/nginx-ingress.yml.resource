## ingress configuration

ingress:

## (recommended for minikube and if there is no registered domain or subdomain)
##  uncomment the next block to access cyber-dojo by the ip address:

default_enabled: true

## (recommended for the cloud cluster with certificate manager installed,
##  if there is a registered domain or subdomain)
##  uncomment the next block to access cyber-dojo by your registered domain
##  and configure your host names at its end:

#  tls_enabled: true
#  annotations:
#    kubernetes.io/ingress.class: "nginx"
#    cert-manager.io/cluster-issuer: "letsencrypt-production"
#  hosts:
#    - cyber-dojo.example.com
