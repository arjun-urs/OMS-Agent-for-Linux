require 'fluent/test'
require_relative '../../../source/code/plugins/in_dsc_monitor'
require 'flexmock/test_unit'

class DscMonitorTest < Test::Unit::TestCase
  include FlexMock::TestCase
  
  CHECK_IF_DPKG = "which dpkg > /dev/null 2>&1; echo $?" 
  CHECK_DSC_INSTALL = "dpkg --list omsconfig > /dev/null 2>&1; echo $?"
  CHECK_DSC_STATUS = "/opt/microsoft/omsconfig/Scripts/TestDscConfiguration.py"

  def setup
    Fluent::Test.setup
  end

  def teardown
    super
    Fluent::Engine.stop
  end

  CONFIG = %[
    tag oms.mock.dsc 
    check_install_interval 2 
    check_status_interval 2
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::DscMonitoringInput).configure(conf)
  end


  def test_dsc_check_failure_message
    dsc_statuscheck_fail_message = "Two successive configuration applications from \
OMS Settings failed – please report issue to github.com/Microsoft/PowerShell-DSC-for-Linux/issues"

    flexmock(Fluent::DscMonitoringInput).new_instances do |instance|
      instance.should_receive(:`).with(CHECK_IF_DPKG).and_return(0)
      instance.should_receive(:`).with(CHECK_DSC_INSTALL).and_return(0)
      instance.should_receive(:`).with(CHECK_DSC_STATUS).and_return("Mock DSC config check")
    end

    d = create_driver
    d.run(num_waits = 90)
    emits = d.emits

    assert_equal(true, emits.length > 0)
    assert_equal("oms.mock.dsc", emits[0][0])
    assert_instance_of(Float, emits[0][1])
    assert_equal(dsc_statuscheck_fail_message, emits[0][2]["message"])
  end


  def test_dsc_check_success_emits_no_messages
    result =
	"instance of TestConfiguration
	{
	ReturnValue=0
	InDesiredState=true
	ResourceId={}
	}"
 
    flexmock(Fluent::DscMonitoringInput).new_instances do |instance|
      instance.should_receive(:`).with(CHECK_IF_DPKG).and_return(0)
      instance.should_receive(:`).with(CHECK_DSC_INSTALL).and_return(0)
      instance.should_receive(:`).with(CHECK_DSC_STATUS).and_return(result)
    end

    d = create_driver
    d.run(num_waits = 90)
    emits = d.emits

    assert_equal(0, emits.length)
  end

end
