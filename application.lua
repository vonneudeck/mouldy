local sda = 6
local scl = 5

function receiver(sck, data)
  print(data)
  sck:close()
end

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
  return response
end


bme280.init(sda, scl)

srv = net.createServer(net.TCP, 20) -- 20s timeout

if srv then
  srv:listen(80, function(conn)
    conn:on("receive", receiver)
    conn:send(response()) 
    conn:close()
  end)
end
