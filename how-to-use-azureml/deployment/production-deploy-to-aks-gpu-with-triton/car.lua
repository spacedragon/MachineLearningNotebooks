wrk.method = "POST"
wrk.headers["Content-Type"] = "application/octet-stream"

file = io.open("car.jpg", "rb")
wrk.body = file:read("*a")

local counter = 1 
local threads = {} 
local iteration_start_time = os.time()

function setup(thread)
   thread:set("id", counter)
   table.insert(threads, thread)
   counter = counter + 1 

   iteration_start_time = os.time()
end 

function init(args)
   requests = 0
   responses = 0
   count_2xx = 0
   count_3xx = 0
   count_400 = 0
   count_401 = 0
   count_403 = 0
   count_404 = 0
   count_408 = 0
   count_429 = 0
   count_4xx = 0
   count_500 = 0
   count_500 = 0
   count_501 = 0
   count_502 = 0
   count_503 = 0
   count_504 = 0
   count_5xx = 0
   count_xxx = 0
   local msg = "thread %d created"
   print(msg:format(id)) 
end 
  
request = function()
   requests = requests + 1
   return wrk.format() 
end 
  
response = function(status, headers, body)
   responses = responses + 1
   local nstatus = tonumber(status)
   if nstatus < 300 then count_2xx = count_2xx + 1
   elseif nstatus < 400 then count_3xx = count_3xx + 1
   elseif nstatus == 400 then count_400 = count_400 + 1
   elseif nstatus == 401 then count_401 = count_401 + 1
   elseif nstatus == 403 then count_403 = count_403 + 1
   elseif nstatus == 404 then count_404 = count_404 + 1
   elseif nstatus == 408 then count_408 = count_408 + 1
   elseif nstatus == 429 then count_429 = count_429 + 1
   elseif nstatus < 500 then count_4xx = count_4xx + 1
   elseif nstatus == 500 then count_500 = count_500 + 1
   elseif nstatus == 501 then count_501 = count_501 + 1
   elseif nstatus == 502 then count_502 = count_502 + 1
   elseif nstatus == 503 then count_503 = count_503 + 1
   elseif nstatus == 504 then count_504 = count_504 + 1
   elseif nstatus < 600 then count_5xx = count_5xx + 1
   else count_xxx = count_xxx + 1
   end
end
  
function done(summary, latency, requests)
   total_requests = 0
   total_responses = 0
   total_2xx = 0
   total_3xx = 0
   total_400 = 0
   total_401 = 0
   total_403 = 0
   total_404 = 0
   total_408 = 0
   total_429 = 0
   total_4xx = 0
   total_500 = 0
   total_501 = 0
   total_502 = 0
   total_503 = 0
   total_504 = 0
   total_5xx = 0
   total_xxx = 0
   for index, thread in ipairs(threads) do
      local id = thread:get("id")
      local requests = thread:get("requests")
      local responses = thread:get("responses")
      if requests == responses then
        local msg = "thread %d made %d requests and got %d responses"
        print(msg:format(id, requests, responses))
      else
       local msg = "thread %d made %d requests and got %d responses, %d request(s) do(es) not see response"
       print(msg:format(id, requests, responses, requests-responses))
      end
      total_requests = total_requests + requests
      total_responses = total_responses + responses
      total_2xx = total_2xx + thread:get("count_2xx")
      total_3xx = total_3xx + thread:get("count_3xx")
      total_400 = total_400 + thread:get("count_400")
      total_401 = total_401 + thread:get("count_401")
      total_403 = total_403 + thread:get("count_403")
      total_404 = total_404 + thread:get("count_404")
      total_408 = total_408 + thread:get("count_408")
      total_429 = total_429 + thread:get("count_429")
      total_4xx = total_4xx + thread:get("count_4xx")
      total_500 = total_500 + thread:get("count_500")
      total_501 = total_501 + thread:get("count_501")
      total_502 = total_502 + thread:get("count_502")
      total_503 = total_503 + thread:get("count_503")
      total_504 = total_504 + thread:get("count_504")
      total_5xx = total_5xx + thread:get("count_5xx")
      total_xxx = total_xxx + thread:get("count_xxx")
   end
   print("------------------------------\n")
   local msg_missing = "Request = %d; Responses = %d; Missing requests: %d"
   print(msg_missing:format(total_requests, total_responses, total_requests - total_responses))
   print("------------------------------\n")
   local msg_status = "HTTP Status %s Count: %d"
   print(msg_status:format("2xx", total_2xx))
   print(msg_status:format("3xx", total_3xx))
   print(msg_status:format("400", total_400))
   print(msg_status:format("401", total_401))
   print(msg_status:format("403", total_403))
   print(msg_status:format("404", total_404))
   print(msg_status:format("408", total_408))
   print(msg_status:format("429", total_429))
   print(msg_status:format("4xx", total_4xx))
   print(msg_status:format("500", total_500))
   print(msg_status:format("501", total_501))
   print(msg_status:format("502", total_502))
   print(msg_status:format("503", total_503))
   print(msg_status:format("504", total_504))
   print(msg_status:format("5xx", total_5xx))
   print(msg_status:format("xxx", total_xxx))
   print("------------------------------\n")
   for _, p in pairs({ 50, 90, 95, 99, 99.9 }) do
      n = latency:percentile(p)
      print(string.format("%g%%,%.2fms", p, (n / 1000)))
   end
end
