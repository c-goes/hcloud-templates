#!/usr/bin/env bash

set -euxo pipefail


if [ $# -eq 0 ]; then
    echo "Usage: $0 <image_to_delete>"
    exit 1
fi

echo "Deleting image $1"

id_of_image=$(hcloud image list -l "type=$1" -o noheader -o columns=id)


if [ -n "${id_of_image-}" ]; then
    echo "Deleting image $1"
    hcloud image delete  $id_of_image
else
    echo "Image $1 does not exist"
fi