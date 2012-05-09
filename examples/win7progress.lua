
local ffi = require 'ffi'
local mswin = require 'extern.mswindows'
local com = require 'extern.mswindows.com'
local taskbarlist = require 'extern.mswindows.taskbarlist'

local w7taskbar = com.new(taskbarlist.clsid, 'ITaskbarList3')

if not w7taskbar then
  error 'demo requires Windows 7'
end

ffi.cdef [[
  void* GetConsoleWindow();
]]

local hwnd = ffi.C.GetConsoleWindow()
if hwnd == nil then
  error 'unable to get console window handle'
end

local mode = 0

while true do
  mode = (mode % 4) + 1
  w7taskbar:SetProgressValue(hwnd, math.random(3, 8), 10)
  if (mode == 1) then
    w7taskbar:SetProgressState(hwnd, taskbarlist.TBPF_NORMAL)
  elseif (mode == 2) then
    w7taskbar:SetProgressState(hwnd, taskbarlist.TBPF_PAUSED)
  elseif (mode == 3) then
    w7taskbar:SetProgressState(hwnd, taskbarlist.TBPF_ERROR)
  elseif (mode == 4) then
    w7taskbar:SetProgressState(hwnd, taskbarlist.TBPF_INDETERMINATE)
  end
  io.write 'Enter X to stop or hit return to change status>> '
  local line = io.read('*l')
  if (not line) or line:lower() == 'x' then
    break
  end
end

w7taskbar:SetProgressState(hwnd, taskbarlist.TBPF_NOPROGRESS)
