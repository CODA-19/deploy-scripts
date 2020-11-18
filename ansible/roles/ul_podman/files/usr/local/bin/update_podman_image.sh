#!/bin/bash


# ** OSBOLETE ** DO NOT USE ** KEPT FOR ARCHEOLOGICAL PURPOSES **
# ** OSBOLETE ** DO NOT USE ** KEPT FOR ARCHEOLOGICAL PURPOSES **
# ** OSBOLETE ** DO NOT USE ** KEPT FOR ARCHEOLOGICAL PURPOSES **


#
# Updates a podman image and invokes systemctl restart as needed
#
# returns:
#  0 if no error occured
#  1 if some parameters are missing
#  2 if podman / skopeo fails for whatever reason (connection timed out, remote image not found...)
#
# TODO: make this re-entrant, pulling images can take some time
#
# History
# -------
#
# 2020-11-01 - v1.0 - Adrien Dessemond <adrien.dessemond@dti.ulaval.ca>
# Initial release

usage()
{
  echo "$0 <registry> <image_name> <image_tag>  <service_to_restart_on_update>"
  exit 1
}

### Start of script

# Source proxy variables if any defined

[[ -f /etc/profile.d/proxy.sh ]] && source /etc/profile.d/proxy.sh

# Not enough args => show some help and exit
[[ $# < 4 ]] && usage

# Make command line arguments a bit more human-readable :)
IMAGE_REGISTRY="$1"
IMAGE_NAME="$2"
IMAGE_TAG="$3"
SERVICE_NAME="$4"

IMAGE_MUST_BE_PULLED=0
TIMESTAMP_FILE=${IMAGE_NAME/\//_}

# Inspect the remote image creation date. With podman/skopeo, the only way to  catch an error
# condition is to scan what is returned for well-known strings :(
# In the case of a non-existing image, simply exit (the error message will say "unknown" somewhere)

CURRENT_IMAGE_TIMESTAMP=`/bin/skopeo inspect docker://${IMAGE_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} | jq ".Created"`
[[ ${CURRENT_IMAGE_TIMESTAMP} =~ unknown ]] && exit 2

# If no local image exists => unconditionnally pull. Likewise, if we we have no timestamp file, assume nothing
# about what locally exists and pull again (at worst nothing will be downloaded)
if [[ ( -z `podman images | grep ${IMAGE_NAME} | grep ${IMAGE_TAG}` ) || ( !  -f /tmp/${TIMESTAMP_FILE}.last ) ]]
then
    IMAGE_MUST_BE_PULLED=1
else
    # At this point, a local image exists and we *might* have its timepstamp file. Let see if we have a match or not.
    # In the the former case, do not pull anything, else refresh the local image. If the timestamp file does not exist
    # it will be created (and will be empty), if the timestamp file exists its contents will remain unchanged.

    touch  /tmp/${TIMESTAMP_FILE}.last
    LAST_IMAGE_TIMESTAMP=`cat /tmp/${TIMESTAMP_FILE}.last`

    # If timestamps match => exit 0
    [[ ${LAST_IMAGE_TIMESTAMP} != ${CURRENT_IMAGE_TIMESTAMP} ]] && IMAGE_MUST_BE_PULLED=1 || exit 0

fi

# An image does not exist or needs to be refreshed, do it!

if [[ ${IMAGE_MUST_BE_PULLED} ]]
then

    PODMAN_POOL_RESULT=`/bin/podman pull docker://${IMAGE_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} 2>&1`

    if [[ ! "${PODMAN_POOL_RESULT}" =~ "unable to pull" ]]
    then
        # So far so good! We have a success, update the timestamp file and restart the service that uses the image
        echo ${CURRENT_IMAGE_TIMESTAMP} > /tmp/${TIMESTAMP_FILE}.last

        # TODO: error condition returned?
        sudo systemctl restart ${SERVICE_NAME}
        exit 0
    fi
fi

# Something wrong happened when the image was pulled (e.g. timeout error, and so on)
exit 2
