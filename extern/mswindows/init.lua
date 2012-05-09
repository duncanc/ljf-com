
-- /!\ This is a DELIBERATELY MINIMAL, INCOMPLETE binding! /!\
-- do not take it too seriously, it is only here to support the com library

local bit = require 'bit'
local ffi = require 'ffi'

local mswindows = {}

-- miscellaneous things
ffi.cdef [[
  typedef int bool32;
  void* GetConsoleWindow();
  typedef struct RECT { int32_t left, top, right, bottom; } RECT;
]]

-- GUIDs
ffi.cdef [[
  typedef struct GUID { uint32_t Data1; uint16_t Data2, Data3; uint8_t Data4[8]; } GUID;
]]
local GUID = ffi.metatype('GUID', {
  __tostring = function(guid)
    if pcall(ffi.cast, ffi.typeof(guid), nil) and (guid == nil) then
      return '<NULL GUID>'
    end
    return string.format('%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x',
      guid.Data1,
      guid.Data2, guid.Data3,
      guid.Data4[0], guid.Data4[1], guid.Data4[2], guid.Data4[3],
      guid.Data4[4], guid.Data4[5], guid.Data4[6], guid.Data4[7])
  end
})
function mswindows.guid(v)
  local a, b, c, d1, d2, d3, d4, d5, d6, d7, d8 = string.match(v,
    '^{?(%x%x%x%x%x%x%x%x)%-?(%x%x%x%x)%-?(%x%x%x%x)%-?(%x%x)(%x%x)%-?(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)}?$')
  if not a then
    error('invalid guid string')
  end
  return GUID(tonumber(a, 16), tonumber(b, 16), tonumber(c, 16),
    {tonumber(d1, 16), tonumber(d2, 16), tonumber(d3, 16), tonumber(d4, 16),
    tonumber(d5, 16), tonumber(d6, 16), tonumber(d7, 16), tonumber(d8, 16)})
end

-- wide strings
ffi.cdef [[
  int WideCharToMultiByte(
    uint32_t codePage,
    uint32_t flags,
    const wchar_t* wide,
    int wide_count,
    char* out_multibyte,
    int multibyte_count,
    const char* defaultChar,
    bool32* out_usedDefaultChar);
  
  int MultiByteToWideChar(
    uint32_t codePage,
    uint32_t flags,
    const char* str,
    int sizeBytes,
    wchar_t* out_wstring,
    int wstring_size);
]]
local function utf8_len(str)
  local count = 0
  for i = 1, #str do
    if (bit.band(string.byte(str,i), 0xC0) ~= 0x80) then
      count = count + 1
    end
  end
  return count
end
function mswindows.wstring(utf8, len)
  len = len or (utf8_len(utf8)+1)
  local bufSize = ffi.C.MultiByteToWideChar(65001, 0, utf8, len, nil, 0)
  local buf = ffi.new('wchar_t[?]', bufSize)
  ffi.C.MultiByteToWideChar(65001, 0, utf8, len, buf, bufSize)
  return buf, bufSize
end
function mswindows.utf8(ptr, len)
  ptr = ffi.cast('const wchar_t*', ptr)
  local bufSize = ffi.C.WideCharToMultiByte(65001, 0, ptr, len or -1, nil, 0, nil, nil)
  if not len then
    bufSize = bufSize - 1
  end
  local buf = ffi.new('char[?]', bufSize)
  ffi.C.WideCharToMultiByte(65001, 0, ptr, len or -1, buf, bufSize, nil, nil)
  return ffi.string(buf, bufSize)
end

mswindows.ole32 = ffi.load 'ole32'

local module_meta = {
  __index = function(self, key)
    return ffi.C[key]
  end;
}

setmetatable(mswindows, module_meta)

return mswindows
