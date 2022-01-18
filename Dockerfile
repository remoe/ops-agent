# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Build as DOCKER_BUILDKIT=1 docker build -o /tmp/out .
# or DOCKER_BUILDKIT=1 docker build -o /tmp/out . --target=buster
# Generated tarball(s) will end up in /tmp/out

FROM centos:8 AS centos8-build

RUN set -x; yum -y update && \
    dnf -y install 'dnf-command(config-manager)' && \
    yum config-manager --set-enabled powertools && \
    yum -y install git systemd \
    autoconf libtool libcurl-devel libtool-ltdl-devel openssl-devel yajl-devel \
    gcc gcc-c++ make cmake bison flex file systemd-devel zlib-devel gtest-devel rpm-build systemd-rpm-macros \
    expect rpm-sign

ADD https://golang.org/dl/go1.17.linux-amd64.tar.gz /tmp/go1.17.linux-amd64.tar.gz
RUN set -xe; \
    tar -xf /tmp/go1.17.linux-amd64.tar.gz -C /usr/local

COPY . /work
WORKDIR /work
RUN ./pkg/rpm/build.sh

FROM scratch AS centos8
COPY --from=centos8-build /tmp/google-cloud-ops-agent.tgz /google-cloud-ops-agent-centos-8.tgz
COPY --from=centos8-build /google-cloud-ops-agent*.rpm /

FROM scratch
COPY --from=centos8 /* /
