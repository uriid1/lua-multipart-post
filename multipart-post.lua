-- This lib based on https://github.com/ldb/lua-multipart-post
--[[
    ####--------------------------------####
    #--# Author:   by uriid1            #--#
    #--# license:  GNU GPL              #--#
    #--# telegram: @main_moderator      #--#
    #--# Mail:     appdurov@gmail.com   #--#
    ####--------------------------------####
--]]

local os = os
local string = string
local table = table
local pairs = pairs
local tostring = tostring

-- Formating
--
local function table_print_format(t_gen, p, s)
  if s == nil then
    t_gen[#t_gen + 1] = p
    return
  end

  -- If 's' is exists
  t_gen[#t_gen + 1] = string.format(p, s)
end

-- Append Data
--
local function append_data(t_gen, key, data, extra)
  table_print_format(t_gen, "content-disposition: form-data; name=\"%s\"", key)
  if extra.filename then
    table_print_format(t_gen, "; filename=\"%s\"", extra.filename)
  end

  if extra.content_type then
    table_print_format(t_gen, "\r\ncontent-type: %s", extra.content_type)
  end

  if extra.content_transfer_encoding then
    table_print_format(t_gen, "\r\ncontent-transfer-encoding: %s", extra.content_transfer_encoding)
  end

  table_print_format(t_gen, "\r\n\r\n")
  table_print_format(t_gen, data)
  table_print_format(t_gen, "\r\n")
end

-- Switch type
--
local t_switch_type = {
  ["string"] = function(val, key, t_gen)
    append_data(t_gen, key, val, {})
  end;

  ["table"] = function(val, key, t_gen)
    append_data(t_gen, key, val.data, {
      filename = val.filename or val.name;
      content_type = val.content_type or val.mimetype or "application/octet-stream";
      content_transfer_encoding = val.content_transfer_encoding or "binary";
    })
  end;

  ["number"] = function(val, key, t_gen)
    append_data(t_gen, key, val, {})
  end;

  ["boolean"] = function(val, key, t_gen)
    append_data(t_gen, key, tostring(val), {})
  end
}

local function switch_type(type, val, key, t_gen)
  if t_switch_type[type] == nil then
    error(string.format("unexpected type %s", type))
  end

  t_switch_type[type](val, key, t_gen)
end

-- Generate boundary
local gen_boundary = function()
  local t = {"BOUNDARY-"}
  
  for i = 2, 17 do
    t[i] = string.char(math.random(65, 90))
  end
  
  t[18] = "-BOUNDARY"
  
  return table.concat(t)
end

-- Encode
--
local function encode(request_body)
  if not request_body then
    return
  end

  -- Gen
  local boundary = gen_boundary()
  local t_gen = {}

  for key, val in pairs(request_body) do
    table_print_format(t_gen, "--%s\r\n", boundary)
    switch_type(type(val), val, key, t_gen)
  end
  table_print_format(t_gen, "--%s--\r\n", boundary)

  return table.concat(t_gen), boundary
end

return encode
