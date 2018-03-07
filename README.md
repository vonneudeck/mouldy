# mouldy

Mouldy is a simple [Prometheus](https://prometheus.io/docs/introduction/overview/) exporter for metrics from Bosch [BME280](https://www.bosch-sensortec.com/bst/products/all_products/bme280) sensors for [ESP8266](http://espressif.com/products/hardware/esp8266ex/overview/) based boards with [NodeMCU](https://nodemcu.readthedocs.io/en/master/) firmware. 

If you enjoy video introductions, watch the five minute mouldy [lightning talk](https://www.youtube.com/watch?v=Mk9xWqML5mA) from [PromCon2017](https://promcon.io/2017-munich).

I had a little mouldy spot in my apartment. After removing it I was told to air more often to avoid the dewpoint. I was curious how often would be enough, but I had no data about humidity/dewpoint in my apartment. Commercially available humidity measuring devices supporting Prometheus do not seem to be available and I did not want to fall back behind the comfort of it. Hence I bought a LoLin NodeMCU V3 and a Bosch BME280 sensor and put this together. I paid 20€ for parts, but if you can wait for shipping from China you can reduce that sum to 10€.

It connects to WiFi and whenever one makes a TCP connection to it, it returns temperature, humidity, air pressure, and dewpoint in the Prometheus text format version 0.0.4.

## Build it

Connect the sensor’s and the nodeMCU board’s pins:

BME280 | nodeMCU
------ | -------
VIN | 3V
GND | G
SCL | D5
SDA | D6

You can use other SCL/SDA pins, but D5 and D6 are convenient because you can then solder the sensor to the board without using wires.

## Run it

### Firmware

To run the exporter you need to have a NodeMCU [firmware](https://nodemcu.readthedocs.io/en/master/en/build/) built with these modules:

- file
- gpio
- net
- node
- uart
- wifi
- bme280
- i2c

For building I used the online [build service](https://nodemcu-build.com/) by Marcel Stör.  
For flashing I used [esptool](https://github.com/espressif/esptool).

### Use Docker Image
You can use the provided Docker image to flash the nodemcu firmware:

Build Docker Image:

```
docker build -t mouldy .
```

Flash nodemcu firmware:

```
docker run --device=/dev/ttyUSB0 mouldy sh -c 'esptool.py write_flash -fm dio \
  0x00000 bin/nodemcu_float_*.bin'
```

Uploading code via Docker doesn't work yet. Help welcome!

### Local configuration

Change the values of the vars ssid, wifipasswort and altitude (of the device’s position in meters) in location_example.lua and rename it to location.lua

Then upload all .lua-files to the nodeMCU and reboot it. I used [nodemcu-uploader](https://github.com/kmpm/nodemcu-uploader) for that. nodemcu-uploader also allows you to connect to the terminal and a few basic control functions like reboot. The nodemcu_update.sh might be handy for that. It is very basic, but safes time.

## To do

- [ ] TLS (see nodeMCU module tls)
- [ ] export the scrape count
- [ ] authorisation

