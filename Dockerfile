FROM yomorun/quic-mqtt:0.7.0

COPY main.go .
RUN go get -d -v ./...

CMD ["sh", "-c", "go run main.go"]

