# KeyDB

No nonsense multi-arch Docker image of KeyDB for Kubernetes deployments.

* Includes properly tagged amd64 and arm64 multi-arch Docker manifest
* Doesn't fiddle with UID-s, leaves it up to Kubernetes security context
* Includes entrypoint which simplifies matters with Kubernetes
* Includes symlink for `redis-cli` for better usability

Designed to be used with [Codemowers' operator bundle](https://github.com/codemowers/operator-bundle)


# Usage

Example manifest, adjust according to your deployment:

```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-cluster-foobar
  namespace: redis-clusters
  labels:
    app.kubernetes.io/instance: foobar
    app.kubernetes.io/name: redis
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/instance: foobar
      app.kubernetes.io/name: redis
  template:
    metadata:
      labels:
        app.kubernetes.io/instance: foobar
        app.kubernetes.io/name: redis
    spec:
      volumes:
        - name: config
          secret:
            secretName: redis-cluster-foobar-secrets
      containers:
        - name: redis
          image: codemowers/keydb:6.3.2
          args:
            - '--maxmemory'
            - '536870912'
            - '--active-replica'
            - 'yes'
            - '--multi-master'
            - 'yes'
            - '--save'
            - ''
          env:
            - name: SERVICE_NAME
              value: redis-cluster-foobar-headless
            - name: REPLICAS
              value: >-
                redis-cluster-foobar-0
                redis-cluster-foobar-1
                redis-cluster-foobar-2
          volumeMounts:
            - name: config
              readOnly: true
              mountPath: /etc/redis
          imagePullPolicy: IfNotPresent
      restartPolicy: Always
      securityContext: {}
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app.kubernetes.io/name
                    operator: In
                    values:
                      - redis
                  - key: app.kubernetes.io/instance
                    operator: In
                    values:
                      - foobar
              topologyKey: topology.kubernetes.io/zone
      nodeSelector:
        dedicated: storage
      tolerations:
        - key: dedicated
          operator: Equal
          value: storage
          effect: NoSchedule
  serviceName: redis-cluster-foobar-headless
  podManagementPolicy: Parallel
```

Note that `redis-cluster-foobar-headless` secret must have `REDIS_PASSWORD` entry
and `redis.conf` entry which contains key-value pairs for `masterauth` and `requirepass`.
