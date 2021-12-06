# yomo source for noise-example
This is part of the [example-noise](https://github.com/yomorun/example-noise), which describes how to write a **[noise-source](https://github.com/yomorun/yomo-source-noise-example)** to receive data from the device, and send it to the back-end workflow engine(**[noise-zipper](https://github.com/yomorun/yomo-zipper-noise-example)**) after it has been transformed and encoded.

![arch1.png](https://github.com/yomorun/example-noise/raw/main/docs/arch1.png?raw=true)

## 🚀 Getting Started



### Example (noise)

This example shows how to use the component reference method to make it easier to receive MQTT messages using starter and convert them to the YoMo protocol for transmission to the Zipper service.

#### 1. Init Project

```bash
go mod init source
go get github.com/yomorun/yomo-source-noise-example
```

#### 2. create app.go

```go
package main

import (
	"encoding/json"
	"log"
	"os"

	"github.com/yomorun/yomo-source-mqtt-starter/pkg/utils"
	"github.com/yomorun/yomo-source-mqtt-starter/pkg/receiver"
)

type NoiseData struct {
	Noise float32 `json:"noise"` // Noise value
	Time  int64   `json:"time"` // Timestamp (ms)
	From  string  `json:"from"` // Source IP
}

func main() {
	handler := func(topic string, payload []byte, writer receiver.ISourceWriter) error {
		log.Printf("receive: topic=%v, payload=%v\n", topic, string(payload))

		// 1.get data from MQTT
		var raw map[string]int32
		err := json.Unmarshal(payload, &raw)
		if err != nil {
			log.Printf("Unmarshal payload error:%v", err)
		}

		// 2.generate json-codec format
		noise := float32(raw["noise"])
		data := NoiseData{Noise: noise, Time: utils.Now(), From: utils.IpAddr()}
		sendingBuf, _ := json.Marshal(data)

		// 3.send data to remote workflow engine
		_, err = writer.Write(sendingBuf)
		if err != nil {
			log.Printf("stream.Write error: %v, sendingBuf=%#x\n", err, sendingBuf)
			return err
		}

		log.Printf("write: sendingBuf=%#v\n", sendingBuf)
		return nil
	}

	receiver.CreateRunner(os.Getenv("YOMO_SOURCE_MQTT_ZIPPER_ADDR")).
		WithServerAddr(os.Getenv("YOMO_SOURCE_MQTT_SERVER_ADDR")).
		WithHandler(handler).
		Run()
}
```

- YOMO_SOURCE_MQTT_ZIPPER_ADDR: Set the service address of the remote noise-zipper.
- YOMO_SOURCE_MQTT_SERVER_ADDR: Set the external service address of this noise-source.
- The data to be sent needs to be encoded using JSON codec.

#### 3. run

```go
YOMO_SOURCE_MQTT_ZIPPER_ADDR=localhost:9999 YOMO_SOURCE_MQTT_SERVER_ADDR=0.0.0.0:1883 go run main.go
```



### Container

#### Docker Image

The case provides [Dockefile](https://github.com/yomorun/yomo-source-noise-example/blob/main/Dockerfile) files for packaging into images.

Also, you can get the official packaged image (**[noise-source](https://hub.docker.com/r/yomorun/noise-source)**) from the mirror repository.

```bash
docker pull yomorun/noise-source
```



#### Docker run

You can run the service with the following command: 

```bash
docker run --rm --name noise-source -p 1883:1883 \
  -e YOMO_SOURCE_MQTT_ZIPPER_ADDR=192.168.108.100:9999 \
  -e YOMO_SOURCE_MQTT_SERVER_ADDR=0.0.0.0:1883 \
  yomorun/noise-source:0.0.6
```

