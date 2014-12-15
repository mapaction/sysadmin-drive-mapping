;License:
;	This script is distributed under the MIT License 
;
;Author:
;	oscar.tejera
;
;Description:
;Simple dummy test suite
#include "lib/micro.au3"

;Run suite
testSuite()

;Setup test suite
Func setUp()
EndFunc

;Teardown test suite
Func tearDown()
EndFunc

;TestSuite
Func testSuite()
	setUp()

	Local $testSuite = _testSuite_("SimpleTestSuite","html") ;Set test suite name and format (Default format is txt)

	Local $test	= _test_("Test assertEquals")
	Local $y = Sqrt(9)
	$test.step("Square-root of 9 is 3", $test.assertEquals(3,$y))
	$test.addToSuite($testSuite) ;Add test case into the test suite
	$test = 0

	Local $OtherTest = _test_("Test assertNotEquals")
	$OtherTest.step("assertNotEquals", $OtherTest.assertNotEquals(3,"String"))
	$OtherTest.addToSuite($testSuite)
	$OtherTest = 0

	Local $OtherTest = _test_("Test assertFalse")
	$OtherTest.step("assertFalse", $OtherTest.assertFalse(false))
	$OtherTest.addToSuite($testSuite)
	$OtherTest = 0

	Local $test	= _test_("Test assertTrue")
	$test.step("assertTrue", $test.assertTrue(true))
	$test.addToSuite($testSuite)
	$test = 0

	Local $test	= _test_("Test assertType")
	$test.step("assertType", $test.assertType("int",2))
	$test.addToSuite($testSuite)
	$test = 0

	Local $test	= _test_("Test assertLessThan")
	$test.step("assertLessThan", $test.assertLessThan(1,2))
	$test.addToSuite($testSuite)
	$test = 0

	Local $test	= _test_("assertLessThanOrEqual")
	$test.step("assertLessThanOrEqual", $test.assertLessThanOrEqual(1,1))
	$test.addToSuite($testSuite)
	$test = 0

	Local $test	= _test_("assertGreaterThanOrEqual")
	$test.step("assertGreaterThanOrEqual", $test.assertGreaterThanOrEqual(2,1))
	$test.addToSuite($testSuite)
	$test = 0

	Local $test	= _test_("assertGreaterThan")
	$test.step("assertGreaterThan", $test.assertGreaterThan(2,1))
	$test.addToSuite($testSuite)
	$test = 0

	$testSuite.stop()

	tearDown()
EndFunc







