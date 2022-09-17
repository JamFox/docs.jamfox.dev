---
title: "Automated OpenStack image builds with Packer and GiLab CI/CD"
date: "2022-05-19"
---

The following is documentation for how to automate building, uploading and sharing images in OpenStack projects with Packer, Qemu via GiLab CI/CD pipelines using inherited settings using extended playbooks from templates and yml achors.

Requirements you need to replicate the following:

- Priviledged GitLab Runner with a tag: https://gitlab.cern.ch/gitlabci-examples/demo-privileged-runners
- GitLab docker-in-docker executor for the priviledged runner: https://docs.gitlab.com/ce/ci/docker/using_docker_build.html#use-docker-in-docker-executor
- TLS for docker-in-docker executor: https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#tls-enabled

Project structure:

```bash
$PROJECT_ROOT/
├── .gitlab-ci.yml
├── provisioning/
│   └── base/
│       ├── img1-ks.cfg
│       ├── img2-ks.cfg
│       └── img3-ks.cfg
│
├── scripts/
│   ├── img1/
│   │   └── provision.sh
│   ├── img2/
│   │   └── provision.sh
│   └── img3/
│       └── provision.sh
│
└── templates/
    ├── img1.json
    ├── img2.json
    └── img3.json
```

## Automated OpenStack image pipeline

`.gitlab-ci.yml` contains steps to build, upload and share image to appropriate projects.

Composed of stages:

- Build Images
- Upload Images
- Share Images

### Build stage

The image build CI stage section will build our images.

Image build yml:

```yml
############################## BUILD JOBS

# This script is not needed, if your container has the following already installed: 
# qemu qemu-img qemu-system-x86_64 qemu-ui-gtk curl jq packer 
.install-qemu-packer: &install-qemu-packer
    - apk add qemu qemu-img qemu-system-x86_64 qemu-ui-gtk curl jq
    - echo "Fetching packer"
    - current_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r .current_version)
    - wget https://releases.hashicorp.com/packer/${current_version}/packer_${current_version}_linux_amd64.zip
    - unzip packer_${current_version}_linux_amd64.zip
    - chmod +x packer

.default-build-settings:
  stage: Build Images
  tags: 
  - docker-privileged-xl
  image: docker:19.03.1
  services:
  - docker:19.03.1-dind
  variables:
      DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - *install-qemu-packer
  artifacts:
    paths:
      - images/*/*.qcow2
    expire_in: 1 week

build img1:
  extends:
    - .default-build-settings
  script:
    - PACKER_LOG=1 ./packer build -force templates/img1.json
  rules:
    - changes:
      - templates/img1.json
      - provisioning/img1-ks.cfg
    - when: manual
```

The job to build `img1` is called `build img1` and is an extension of `.default-build-settings`. All image build jobs should inherit `.default-build-settings` because it sets the settings needed for building images in a way which avoids code duplication. To add the same settings to another image job, we just make sure it contains:

```
  extends:
    - .default-build-settings
```

It will set:

- CI stage as `Build Images`
- CI tag as `docker-privileged-xl` so that it runs on the correct runner. (Change it to your runners tag)
- CI image as `docker:19.03.1` with `docker:19.03.1-dind` service (Change it to your runner container and service)
- `DOCKER_TLS_CERTDIR` variable to `/certs` for docker TLS. (Change it to your TLS path)
- `before_script` as `*install-qemu-packer` which installs `qemu` and the latest `packer` (This is not needed, if your container has the following already installed: qemu qemu-img qemu-system-x86_64 qemu-ui-gtk curl jq packer)
- Generated image at `images/*/*.qcow2` as artifact to be used in corresponding upload image job.

The settings to change for a secific images are:

- `script` which should match the json for building the image: `PACKER_LOG=1 ./packer build -force templates/<YOUR IMAGE JSON FILE NAME HERE>.json` 
- `rules` that should match json and ks.cfg for that image to make sure the pipeline is triggered only when you want. Example only trigger pipeline when the related files are changed or on schecule (See: https://docs.gitlab.com/ee/ci/jobs/job_control.html).  

### Upload stage

The image upload CI stage section will upload our built images from the previous stage. It will access the image built in the previous stage by using GitLab artifacts that we defined in the inherited settings of `.default-build-settings`. GitLab doc on artifacts: https://docs.gitlab.com/ee/ci/pipelines/job_artifacts.html

For the following to work you need to set some variables for OpenStack authentication. See: https://docs.openstack.org/python-openstackclient/latest/cli/authentication.html

These variables are (Change values to fit your environment):

```yml
# OpenStack Authentication URL 
OS_AUTH_URL: 'https://keystone.cern.ch/v3'
OS_DEFAULT_DOMAIN: default
# CERN OpenStack API Version 
OS_IDENTITY_API_VERSION: 3
# OpenStack Default project to authenticate to
OS_PROJECT_NAME: "$UPLOAD_PROJECT_NAME"
# OpenStack Default authentication method
# Password auth requires you to also set secret variables for user and password which are not included here. These would be OS_USERNAME and OS_PASSWORD
OS_AUTH_TYPE: v3password
```

Image upload yml:

```yml
############################## UPLOAD JOBS

.openstack-upload-image: &openstack-upload-image
    - echo "Getting image name from image path $IMAGE_PATH" 
    - export IMAGENAME_FULL=$(basename $IMAGE_PATH/*.qcow2)
    - echo $IMAGENAME_FULL
    - export IMAGENAME="[CICD] ${IMAGENAME_FULL%.*}"
    - echo $IMAGENAME
    - openstack --os-auth-type $OS_AUTH_TYPE image create --disk-format qcow2 --file ./$IMAGE_PATH/"$IMAGENAME_FULL" "$IMAGENAME"
    - echo "IMAGE_TO_SHARE=${IMAGENAME}" >> img.env

.default-upload-settings:
  image:
    name: gitlab-registry.cern.ch/linuxsupport/openstack-client:latest
    entrypoint: [""]
  stage: Upload Images
  script: 
    - *openstack-upload-image
  artifacts:
    reports:
      dotenv: img.env


upload img1: 
  extends:
    - .default-upload-settings
  needs: ["build img1"]
  dependencies: 
    - build img1
  variables:
    IMAGE_PATH: images/img1

```

The job to upload `img1` is called `build img1` and is an extension of `.default-upload-settings`. All image upload jobs should inherit `.default-upload-settings` because it sets the settings needed for uploading images in a way which avoids code duplication. To add the same settings to another image job, we just make sure it contains:

```
  extends:
    - .default-upload-settings
```

It will set:

- CI stage as `Upload Images`
- CI image to container with OpenStack CLI tools installed.
- `script` as `*openstack-upload-image` which uses artifact from corresponding build job that contains the built image and uploads it to the `$UPLOAD_PROJECT_NAME`.
- Uploaded image as dotenv variable artifact in `img.env` that will be used by corresponding share job.

The settings to change for a secific images are:

- `needs` which should match your previous build job name wrapped in brackets and quotes: `needs: ["<CORRESPONDING BUILD JOB NAME>"]`
- `dependencies` which should match your previous build.
- `variables` which should have `IMAGE_PATH` that matches your images output path set in your image json.

### Share stage

The image share CI stage section will share our built images from the previous stage to projects we need. It will access the image name variable from `img.env` that we set in the previous stage by using GitLab artifacts that we defined in the inherited settings of `.default-upload-settings`. GitLab doc on artifacts: https://docs.gitlab.com/ee/ci/pipelines/job_artifacts.html

NOTE: The account you use for authenticating to OpenStack projects MUST have permissions to accept the shared image in the project that you want the image to be shared to! The account authenticates and shares the image from `$UPLOAD_PROJECT_NAME` and then authenticates and accepts it from `$PROJECT_TO_SHARE`, so it needs access from both sides of this transaction.

Sharing images done according to CU doc: https://www.cac.cornell.edu/wiki/index.php?title=Share_An_Image_In_Openstack

Image share yml:

```yml
############################## SHARE JOBS

.openstack-share-image: &openstack-share-image
    - |+
      IFS=';' read -ra PROJECTS <<< "$PROJECT_TO_SHARE"
      while IFS=';' read -ra PROJECTS; do
        for PROJECT in "${PROJECTS[@]}"; do
          export OS_PROJECT_NAME=$UPLOAD_PROJECT_NAME
          echo "Sharing image $IMAGE_TO_SHARE from $OS_PROJECT_NAME to $PROJECT"
          export IMG_ID=$(openstack image list | fgrep "$IMAGE_TO_SHARE" | cut -d " " -f 2)
          echo "Got image $IMAGE_TO_SHARE ID: $IMG_ID"
          export SHARE_ID=$(openstack project list | fgrep "$PROJECT" | cut -d " " -f 2)
          echo "Got project $PROJECT ID: $SHARE_ID"
          openstack --os-auth-type $OS_AUTH_TYPE image set --shared $IMG_ID
          openstack --os-auth-type $OS_AUTH_TYPE image add project $IMG_ID $SHARE_ID
          export OS_PROJECT_NAME=$PROJECT
          echo "Accepting image share from $PROJECT"
          openstack --os-auth-type $OS_AUTH_TYPE image set --accept $IMG_ID 
          export OS_PROJECT_NAME=$UPLOAD_PROJECT_NAME
        done
      done <<< "$PROJECT_TO_SHARE"

.default-share-settings:
  image:
    name: gitlab-registry.cern.ch/linuxsupport/openstack-client:latest
    entrypoint: [""]
  stage: Share Images
  script: 
    - *openstack-share-image

.default-share-on-tag:
  rules:
    - if: '$CI_COMMIT_TAG != null'
      when: manual

share img1 to dev:
  extends:
    - .default-share-settings
  needs: ["upload img1"]
  dependencies: 
    - upload img1 
  variables:
    PROJECT_TO_SHARE: "$DEV_PROJECT_NAME"

share img1 to prod: 
  extends:
    - .default-share-settings
    - .default-share-on-tag
  needs: ["upload img1"]
  dependencies: 
    - upload img1 
  variables:
    PROJECT_TO_SHARE: "$PROD_PROJECT_NAME"
```

The job to share `img1` is called `share img1 to X` and is an extension of `.default-share-settings`. All image share jobs should inherit `.default-share-settings` because it sets the settings needed for sharing images in a way which avoids code duplication. To add the same settings to another image job, we just make sure it contains:

```
  extends:
    - .default-share-settings
```

It will set:

- CI stage as `Share Images`
- CI image to container with OpenStack CLI tools installed.
- `script` as `*openstack-share-image` which loops over the `$PROJECT_TO_SHARE` variable values which must be separated by ";" and shares them from `$UPLOAD_PROJECT_NAME` to each project value it finds in `$PROJECT_TO_SHARE`. This allows us to share image to multiple projects without code duplication.

If you wish to have images that are shared only when a tag is commited, then also inherit `.default-share-on-tag` which sets the rules to only allow this job to run, when a tag is commited. NOTE: with this setup, after commiting a tag, you must still trigger the job manually! Commiting a tag will just make it available.

The settings to change for a secific images are:

- `needs` which should match your previous upload job name wrapped in brackets and quotes: `needs: ["<CORRESPONDING BUILD JOB NAME>"]`
- `dependencies` which should match your previous upload.
- `variables` which should have `PROJECT_TO_SHARE` that points to a variable which has project name(s) separated by ";", if there are multiple projects.

### Full Pipeline

```yml
---

stages:
  - Build Images
  - Upload Images
  - Share Images

variables:
  # OpenStack project name to upload images to
  UPLOAD_PROJECT_NAME: 'BE ACC-linux'
  # OpenStack project name(s) to share uploaded images to for testing
  # For multiple names, use ";" as delimiter
  DEV_PROJECT_NAME: 'BE-LTS'
  # OpenStack project name(s) to share uploaded images to for prod
  # For multiple names, use ";" as delimiter
  PROD_PROJECT_NAME: 'BE ACC-VPC2016;Remote Operation Gateway'
  # CERN OpenStack Authentication URL 
  OS_AUTH_URL: 'https://keystone.cern.ch/v3'
  OS_DEFAULT_DOMAIN: default
  # CERN OpenStack API Version
  OS_IDENTITY_API_VERSION: 3
  # OpenStack Default project to authenticate to
  OS_PROJECT_NAME: "$UPLOAD_PROJECT_NAME"
  # OpenStack Default authentication method
  # Password auth requires you to set CICD variables for user and password
  OS_AUTH_TYPE: v3password


############################## BUILD JOBS

# This script is not needed, if your container has the following already installed: 
# qemu qemu-img qemu-system-x86_64 qemu-ui-gtk curl jq packer 
.install-qemu-packer: &install-qemu-packer
    - apk add qemu qemu-img qemu-system-x86_64 qemu-ui-gtk curl jq
    - echo "Fetching packer"
    - current_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r .current_version)
    - wget https://releases.hashicorp.com/packer/${current_version}/packer_${current_version}_linux_amd64.zip
    - unzip packer_${current_version}_linux_amd64.zip
    - chmod +x packer

.default-build-settings:
  stage: Build Images
  tags: 
  - docker-privileged-xl
  image: docker:19.03.1
  services:
  - docker:19.03.1-dind
  variables:
      DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - *install-qemu-packer
  artifacts:
    paths:
      - images/*/*.qcow2
    expire_in: 1 week

build img1:
  extends:
    - .default-build-settings
  script:
    - PACKER_LOG=1 ./packer build -force templates/img1.json
  rules:
    - changes:
      - templates/img1.json
      - provisioning/img1-ks.cfg
    - when: manual


############################## UPLOAD JOBS

.openstack-upload-image: &openstack-upload-image
    - echo "Getting image name from image path $IMAGE_PATH" 
    - export IMAGENAME_FULL=$(basename $IMAGE_PATH/*.qcow2)
    - echo $IMAGENAME_FULL
    - export IMAGENAME="[CICD] ${IMAGENAME_FULL%.*}"
    - echo $IMAGENAME
    - openstack --os-auth-type $OS_AUTH_TYPE image create --disk-format qcow2 --file ./$IMAGE_PATH/"$IMAGENAME_FULL" "$IMAGENAME"
    - echo "IMAGE_TO_SHARE=${IMAGENAME}" >> img.env

.default-upload-settings:
  image:
    name: gitlab-registry.cern.ch/linuxsupport/openstack-client:latest
    entrypoint: [""]
  stage: Upload Images
  script: 
    - *openstack-upload-image
  artifacts:
    reports:
      dotenv: img.env


upload img1: 
  extends:
    - .default-upload-settings
  needs: ["build img1"]
  dependencies: 
    - build img1
  variables:
    IMAGE_PATH: images/img1


############################## SHARE JOBS

.openstack-share-image: &openstack-share-image
    - |+
      IFS=';' read -ra PROJECTS <<< "$PROJECT_TO_SHARE"
      while IFS=';' read -ra PROJECTS; do
        for PROJECT in "${PROJECTS[@]}"; do
          export OS_PROJECT_NAME=$UPLOAD_PROJECT_NAME
          echo "Sharing image $IMAGE_TO_SHARE from $OS_PROJECT_NAME to $PROJECT"
          export IMG_ID=$(openstack image list | fgrep "$IMAGE_TO_SHARE" | cut -d " " -f 2)
          echo "Got image $IMAGE_TO_SHARE ID: $IMG_ID"
          export SHARE_ID=$(openstack project list | fgrep "$PROJECT" | cut -d " " -f 2)
          echo "Got project $PROJECT ID: $SHARE_ID"
          openstack --os-auth-type $OS_AUTH_TYPE image set --shared $IMG_ID
          openstack --os-auth-type $OS_AUTH_TYPE image add project $IMG_ID $SHARE_ID
          export OS_PROJECT_NAME=$PROJECT
          echo "Accepting image share from $PROJECT"
          openstack --os-auth-type $OS_AUTH_TYPE image set --accept $IMG_ID 
          export OS_PROJECT_NAME=$UPLOAD_PROJECT_NAME
        done
      done <<< "$PROJECT_TO_SHARE"

.default-share-settings:
  image:
    name: gitlab-registry.cern.ch/linuxsupport/openstack-client:latest
    entrypoint: [""]
  stage: Share Images
  script: 
    - *openstack-share-image

.default-share-on-tag:
  rules:
    - if: '$CI_COMMIT_TAG != null'
      when: manual

share img1 to dev:
  extends:
    - .default-share-settings
  needs: ["upload img1"]
  dependencies: 
    - upload img1 
  variables:
    PROJECT_TO_SHARE: "$DEV_PROJECT_NAME"

share img1 to prod: 
  extends:
    - .default-share-settings
    - .default-share-on-tag
  needs: ["upload img1"]
  dependencies: 
    - upload img1 
  variables:
    PROJECT_TO_SHARE: "$PROD_PROJECT_NAME"
```
