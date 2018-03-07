local sda = 6
local scl = 5

function makepromlines(prefix, name, source)
  local buffer = {"# TYPE ", prefix, name, " gauge\n", prefix, name, " ", source, "\n"}
  local lines = table.concat(buffer)
  return lines
end

function metrics()
    local t, p, h, qnh = bme280.read(altitude)
    local d = bme280.dewpoint(h, t)
    -- this table contains the metric names and sources.
    local metricspecs = {
      "temperature_celsius", t/100,
      "airpressure_hectopascal", p/1000,
      "airpressure_sealevel_hectopascal", qnh/1000,
      "humidity_percent", h/1000,
      "dewpoint_celsius", d/100,
      }
    local metrics = {}
    for i = 1, #metricspecs, 2 do
      table.insert(metrics, makepromlines("nodemcu_", metricspecs[i], metricspecs[i+1]))
    end
    local body = table.concat(metrics)
    return body
end

function response()
  local header = "HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/plain; version=0.0.4\r\n\r\n"
  local response = header .. metrics()
  print("> " .. response)
  return response
end

i2c.setup(0, sda, scl, i2c.SLOW) -- call i2c.setup() only once

-- Setup according to recommendation in 3.5.1 of datasheet:
-- - 1x oversampling
-- - sleep mode (we enable forced mode when taking measurements)
-- - IIR filter off
bme280.setup(1, 1, 1, 0, nil, 0)

srv = net.createServer(net.TCP, 20) -- 20s timeout

if srv then
  srv:listen(80, function(conn)
    conn:on("receive", function(conn, data)
      print("< "  .. data)
      bme280.startreadout(0, function ()
        conn:send(response())
        conn:close()
      end)
    end)
  end)
end
