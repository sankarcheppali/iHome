local module = {}
gpio.mode(1,gpio.OUTPUT)
gpio.mode(2,gpio.OUTPUT)
gpio.mode(3,gpio.OUTPUT)
gpio.mode(4,gpio.OUTPUT)
gpio.mode(5,gpio.OUTPUT)
gpio.mode(6,gpio.OUTPUT)
gpio.mode(7,gpio.OUTPUT)
gpio.mode(8,gpio.OUTPUT)  
m = nil
-- Sends a simple ping to the broker
local function send_ping()  
    m:publish(config.ENDPOINT .."/fromnode",gpio.read(1)..gpio.read(2)..gpio.read(3)..gpio.read(4),0,1)
    print("Published the status")
end

local function consume_data( payload )
    if payload=="<?ln1=1>" then
    gpio.write(1,gpio.HIGH)
    elseif payload=="<?ln2=1>" then
    gpio.write(2,gpio.HIGH)
    elseif payload=="<?ln3=1>" then
    gpio.write(3,gpio.HIGH)
    elseif payload=="<?ln4=1>" then
    gpio.write(4,gpio.HIGH)
    elseif payload=="<?ln1=0>" then
    gpio.write(1,gpio.LOW)
    elseif payload=="<?ln2=0>" then
    gpio.write(2,gpio.LOW)
    elseif payload=="<?ln3=0>" then
    gpio.write(3,gpio.LOW)
    elseif payload=="<?ln4=0>" then
    gpio.write(4,gpio.LOW)
    else
    print("No match found")
    end
    send_ping()
end
-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ENDPOINT .. "/tonode",0,function(conn)
        print("Successfully subscribed to data endpoint")
        send_ping()
    end)
end

local function mqtt_start()  
    m = mqtt.Client(config.ID, 120,config.USERNAME,config.PASSWORD)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(topic .. ": " .. data)
        consume_data(data)
        -- do something, we have received a message
      end
    end)
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1, function(con) 
        register_myself()
    end) 

end

function module.start()  
  mqtt_start()
end

return module  