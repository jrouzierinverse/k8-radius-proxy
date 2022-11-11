ARG from=golang:1.18
FROM ${from} as build

WORKDIR /usr/src/k8-radius-proxy

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN go build -v -o /usr/local/bin/k8-radius-proxy ./...

#Getting dictionaries

ARG DEBIAN_FRONTEND=noninteractive

#
#  Install build tools
#
RUN apt-get update
RUN apt-get install -y devscripts equivs git quilt gcc
WORKDIR /usr/src

#
#  Shallow clone the FreeRADIUS source
#
ARG source=https://github.com/FreeRADIUS/freeradius-server.git
ARG release=v3.2.x

RUN git clone --depth 1 --single-branch --branch ${release} ${source}
WORKDIR freeradius-server

#
#  Install build dependencies
#
RUN git checkout ${release}; \
    if [ -e ./debian/control.in ]; then \
        debian/rules debian/control; \
    fi; \
    echo 'y' | mk-build-deps -irt'apt-get -yV' debian/control

#
#  Build the server
#
RUN make -j2 deb
#
#  Clean environment and run the server
#
FROM ${from}
COPY --from=build /usr/src/*.deb /tmp/
COPY --from=build /usr/local/bin/k8-radius-proxy /usr/local/bin/k8-radius-proxy

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y /tmp/freeradius-common* \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/* /tmp/*.deb

EXPOSE 1812/udp 1813/udp
CMD ["/usr/local/bin/k8-radius-proxy"]
