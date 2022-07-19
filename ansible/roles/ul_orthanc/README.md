Useful command:

```
export PODMAN_PORTS="-p 8042:8042 -p 4242:4242"
export PODMAN_VOLUMES="-v /etc/orthanc/orthanc.json:/etc/orthanc/orthanc.json:Z"
export PODMAN_ENV="--env-file /etc/default/orthanc"

# Launch the service
podman run --rm -it ${PODMAN_PORTS} ${PODMAN_VOLUMES} ${PODMAN_ENV} --name orthanc docker.io/osimis/orthanc:22.7.0

# Launch bash shell to explore the image content
podman run --rm -it --entrypoint=bash docker.io/osimis/orthanc:22.7.0
```
