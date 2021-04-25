FROM yomorun/quic-mqtt:latest

COPY main.go .
RUN go get -d -v ./...

CMD ["sh", "-c", "go run main.go"]

