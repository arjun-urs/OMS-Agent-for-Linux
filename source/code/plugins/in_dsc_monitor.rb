require 'fluent/input'
require 'fluent/config/error'

module Fluent
  class DscMonitoringInput < Input
    Fluent::Plugin.register_input('dsc_monitor', self)

    config_param :tag, :string, :default=>nil
    config_param :check_install_interval, :time, :default=>86400
    config_param :check_status_interval, :time, :default=>1800
   
    CHECK_IF_DPKG = (%x(which dpkg > /dev/null 2>&1; echo $?)).to_i

    def configure(conf)
      super
      if !@tag 
        raise Fluent::ConfigError, "'tag' option is required on dsc_checks input"
      end
    end

    def start
      super
      @finished_check_install = false
      @finished_check_status = false
      @thread_check_install = Thread.new(&method(:run_check_install))
      @thread_check_status = Thread.new(&method(:run_check_status))
      @dsc_cache = DSCcache.new
    end

    def check_install
      if CHECK_IF_DPKG == 0
        %x(dpkg --list omsconfig > /dev/null 2>&1; echo $?).to_i
      else
        %x(rpm -qi omsconfig > /dev/null 2>&1; echo $?).to_i
      end
    end

    def run_check_install
      until @finished_check_install
        install_status = check_install
        @dsc_cache.set("install", install_status)
        sleep @check_install_interval
      end
    end

    def get_dsc_status
      begin
        dsc_status = %x(/opt/microsoft/omsconfig/Scripts/TestDscConfiguration.py)
      rescue => error
        OMS::Log.error_once("Unable to run TestDscConfiguration.py for dsc : #{error}")
      end
      if dsc_status.match("ReturnValue=0") and dsc_status.match("InDesiredState=true")
        return 0
      else
        return 1
      end
    end

    def run_check_status
      begin
      sleep @check_status_interval
      if @dsc_cache.get("install") == 0 
        dsc_status = get_dsc_status
        @dsc_cache.set("status", dsc_status)
        sleep @check_status_interval
 
        until @finished_check_status
          dsc_status = get_dsc_status
          if dsc_status == 1 and @dsc_cache.get("status") == 1
            router.emit(@tag, Time.now.to_f, {"message"=>"Two successive configuration applications from \
OMS Settings failed – please report issue to github.com/Microsoft/PowerShell-DSC-for-Linux/issues"})
          end
          @dsc_cache.set("status", dsc_status)
          sleep @check_status_interval
        end
      end 
      rescue => e
        $log.error e
      end
    end       

    def shutdown
      super
      @finished_check_install = true
      @finished_check_status = true
      @thread_check_install.join
      @thread_check_status.join
    end

  end

  class DSCcache
    def initialize
      @cache = {}
    end

    def get(key)
      if @cache.has_key?(key)
        @cache[key]
      else
        $log.error "#{@cache} cache does not contain the key #{key}"
      end
    end
 
    def set(key, value = nil)
      @cache[key] = value
    end

    def reset
      @cache = {}
    end  
  end

end
