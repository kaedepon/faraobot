require 'rubygems'
require 'win32/daemon'
include Win32

class Daemon
  def service_main
    require 'C:\faraobot\faraobot.rb'
  end
 
  def service_stop
    exit!
  end
end
 
Daemon.mainloop