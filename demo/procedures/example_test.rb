load 'cosmos/tools/test_runner/test.rb'

# This Test demonstrates the usage of the setup and teardown methods
# as well as defining two tests. Notice that the setup and teardown
# methods must be called exactly that. Other test methods must start
# with 'test_' to be picked up by TestRunner.
class ExampleTest < Cosmos::Test
  # Setup the test case by doing stuff
  def setup
    puts "Running ExampleTest setup"
    wait(2)
  end




  # test_1 verifies requirement 1
  def test_case_with_long_name_1
    puts "Running test_1"
    Cosmos::Test.puts "This test verifies requirement 1"
    wait(2)
  end

  # test_2 verifies requirement 2
  def test_2
    puts "Running test_2"
    Cosmos::Test.puts "This test verifies requirement 2"
    if $manual
      answer = ask "Are you sure?"
    else
      answer = 'y'
    end
    wait(2)
  end

  def test_3xx
    wait 1
  end

  # Teardown the test case by doing other stuff
  def teardown
    puts "Running ExampleTest teardown"
    wait(2)
  end

  def helper_method

  end
end

# This is an ExampleTestSuite which only runs ExampleTest
class ExampleTestSuite < Cosmos::TestSuite
  def initialize
    super()
    add_test('ExampleTest')
  end
end

# ExampleTest2 runs test_3 and test_4.
class ExampleTest2 < Cosmos::Test
  def setup
    puts "Running ExampleTest2 setup"
    wait(2)
  end

  # ExampleTest2::test_2 is different from ExampleTest::test_2
  def test_2
    puts "another test_1 "
    raise "BAD"
    puts "continuing past the exception"
    wait 2
  end

  def test_3
    puts "Running test_3"
    raise SkipTestCase, "test_3 unimplemented"
    wait(2)
  end

  def test_4
    puts "Running test_4"
    if non_existent
      puts "can't get here"
    else
      puts "can't get here either"
    end
    wait(2)
  end

  def teardown
    puts "Running ExampleTest2 teardown"
    wait(2)
  end
end

class ExampleTestSuite2 < Cosmos::TestSuite
  def initialize
    super()
    add_test('ExampleTest2')
  end
end

class ExampleTestSuite3 < Cosmos::TestSuite
  # This setup applies to the entire test suite
  def setup
    puts "Running ExampleTestSuite3 setup"
    wait(2)
  end

  def initialize
    super()
    add_test_setup('ExampleTest')
    # This line raises a runtime error because ExampleTest3 has no setup method
    #add_test_setup('ExampleTest3')
    # This line raises a runtime error because ExampleTest3 has no test_50 method
    #add_test_case('ExampleTest3', 'test_50')
    add_test('ExampleTest')
    add_test('ExampleTest2')
    add_test_teardown('ExampleTest')
  end

  # This teardown applies to the entire test suite
  def teardown
    puts "Running ExampleTestSuite3 teardown"
    wait(2)
  end
end

class ExampleTest3 < Cosmos::Test
  def test_5
    puts "Running test_5"
    puts "\000\001\002"
    check_expression("false == true")
    wait(2)
  end

  def test_6
    puts "Running test_6"
    wait(2)
  end
end

class ExampleTestSuite4 < Cosmos::TestSuite
  # This setup applies to the entire test suite
  def setup
    puts "Running ExampleTestSuite4 setup"
    wait(2)
  end

  def initialize
    super()
    add_test_setup('ExampleTest')
    add_test_case('ExampleTest', 'test_2')
    add_test_case('ExampleTest', 'test_3xx')
    add_test_teardown('ExampleTest')
  end

  # This teardown applies to the entire test suite
  def teardown
    puts "Running ExampleTestSuite4 teardown"
    wait(2)
  end
end

class ExampleTestSuite5 < Cosmos::TestSuite
  def initialize
    super()
    add_test_teardown('ExampleTest')
  end

  # This teardown applies to the entire test suite
  def teardown
    puts "Running ExampleTestSuite5 teardown"
    wait(2)
  end
end

class EmptyTestSuite < Cosmos::TestSuite
  def initialize
    super()
  end
end

class EmptyTest < Cosmos::Test
end
