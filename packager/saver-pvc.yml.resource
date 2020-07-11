## Persistent volume configuration to save katas and groups

pvc:
  name: saver-data

## adapt required storage capacity to your needs:
  storage: 25Gi

## uncomment the next block and configure the target label to reuse existing persistent volume
  
#  matchLabels:
#    target: "persistent-volume-label"
