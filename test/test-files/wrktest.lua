-- HTTP POST script which simulates a file upload
-- HTTP method, body, and adding a header
-- See https://tools.ietf.org/html/rfc1867

function read_txt_file(path)
    local file, errorMessage = io.open(path, "r")
    if not file then 
        error("Could not read the file:" .. errorMessage .. "\n")
    end

    local content = file:read "*all"
    file:close()
    return content
end

local Boundary = "----WebKitFormBoundaryePkpFF7tjBAqx29L"
local BodyBoundary = "--" .. Boundary
local LastBoundary = "--" .. Boundary .. "--"

local CRLF = "\r\n"

local FileBody = read_txt_file("eicar.com.txt.jpg")

-- We don't need different file names here because the test should
-- always replace the uploaded file with the new one. This will avoid
-- the problem with directories having too much files and slowing down
-- the application, which is not what we are trying to test here.
-- This will also avoid overloading wrk with more things do to, which
-- can influence the test results.
local Filename = "test.txt"

local ContentDisposition = "Content-Disposition: form-data; name=\"file\"; filename=\"" .. Filename .. "\""

wrk.method = "POST"
wrk.headers["Content-Type"] = "multipart/form-data; boundary=" .. Boundary
wrk.body = BodyBoundary .. CRLF .. ContentDisposition .. CRLF .. CRLF .. FileBody .. CRLF .. LastBoundary

--
-- THE FOLLOWING CODE IS MANUALLY INCLUDED FROM 'wrk_report.lua'
--

-- A script for `wrk` to write out test results in JSON format.

done = function(summary, latency, requests)
  io.write("JSON: {\n")
  io.write('"summary":{\n')

  -- summary = {
  --   duration = N,  -- run duration in microseconds
  --   requests = N,  -- total completed requests
  --   bytes    = N,  -- total bytes received
  --   errors   = {
  --     connect = N, -- total socket connection errors
  --     read    = N, -- total socket read errors
  --     write   = N, -- total socket write errors
  --     status  = N, -- total HTTP status codes > 399
  --     timeout = N  -- total request timeouts
  --   }
  -- }

  io.write(string.format('"duration":%d,\n', summary.duration))
  io.write(string.format('"requests":%d,\n', summary.requests))
  io.write(string.format('"bytes":%d,\n', summary.bytes))
  io.write('"errors":{')
  io.write(string.format('"connect":%d,', summary.errors.connect))
  io.write(string.format('"read":%d,', summary.errors.read))
  io.write(string.format('"write":%d,', summary.errors.write))
  io.write(string.format('"status":%d,', summary.errors.status))
  io.write(string.format('"timeout":%d', summary.errors.timeout))
  io.write('}\n')
  io.write('},\n')
  io.write('"latency":{\n')
  stats(latency)
  io.write('},\n')
  io.write('"requests":{\n')
  stats(requests)
  io.write('}\n')
  io.write("}\n")
end

function stats(obj)
  -- latency.min              -- minimum value seen
  -- latency.max              -- maximum value seen
  -- latency.mean             -- average value seen
  -- latency.stdev            -- standard deviation
  -- latency:percentile(99.0) -- 99th percentile value
  -- latency[i]               -- raw sample value

  io.write(string.format('"min":%g,\n', obj.min))
  io.write(string.format('"mean":%g,\n', obj.mean))
  io.write(string.format('"max":%g,\n', obj.max))
  io.write(string.format('"stdev":%g,\n', obj.stdev))
  io.write('"percentile":[')
  io.write(string.format('[1,%d],', obj:percentile(1)))
  io.write(string.format('[5,%d],', obj:percentile(5)))
  io.write(string.format('[10,%d],', obj:percentile(10)))
  io.write(string.format('[25,%d],', obj:percentile(25)))
  io.write(string.format('[50,%d],', obj:percentile(50)))
  io.write(string.format('[75,%d],', obj:percentile(75)))
  io.write(string.format('[90,%d],', obj:percentile(90)))
  io.write(string.format('[95,%d],', obj:percentile(95)))
  io.write(string.format('[99,%d]', obj:percentile(99)))
  io.write(']\n')
  io.flush()
end