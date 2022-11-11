FROM golang:1.18

WORKDIR /usr/src/k8-radius-proxy

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN go build -v -o /usr/local/bin/k8-radius-proxy ./...

CMD ["/usr/local/bin/k8-radius-proxy", "12345"]
