;License:
;	This script is distributed under the GNU General Public License 3.
;
;Author:
;	oscar.tejera
;
;Description:
;Simple dummy test suite
#include "lib/micro.au3"
#include "../drive-mapper.au3"

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

	Local $testSuite = _testSuite_("test-drive-mapper") ;Set test suite name and format (Default format is txt)

	Local $test	= _test_("Test _getIniFile")
	$test.step("example.ini", false)
	$test.step("nonexistent.ini", false)
	$test.addToSuite($testSuite) ;Add test case into the test suite
	$test = 0

	Local $test	= _test_("Test _DoAllMappings")
	$test.step("No tests implemented yet", false)
	$test.step("Not a valid ini file", false)
	$test.step("Missing a share value in ini file", false)
	$test.step("Missing a friendlyName value in ini file", false)
	$test.addToSuite($testSuite) ;Add test case into the test suite
	$test = 0
	
	Local $test	= _test_("Test _isValidDriveName")
	$test.step("'A:' is valid", $test.assertTrue(_isValidDriveName("A:")))
	$test.step("'AA:' is invalid", $test.assertFalse(_isValidDriveName("AA:")))
	$test.step("'1:' is invalid", $test.assertFalse(_isValidDriveName("1:")))
	$test.step("'A' is invalid", $test.assertFalse(_isValidDriveName("A")))
	$test.addToSuite($testSuite) ;Add test case into the test suite
	$test = 0

	#CS Local $test	= _test_("Test _RemoveOldMapping")
	$test.step("No tests implemented yet", false)
	$test.addToSuite($testSuite) ;Add test case into the test suite
	$test = 0
	#CE
	
	#CS Local $test	= _test_("Test _NewMapping")
	$test.step("No tests implemented yet", false)
	$test.addToSuite($testSuite) ;Add test case into the test suite
	$test = 0
	#CE	
	
	Local $test	= _test_("Test _isRetryRequired")
	# _isRetryRequired(ByRef iRetry,iError,iExtended)

	Local $iRetry = 3
	_isRetryRequired($iRetry,1,1)
	$test.step("Retry (de)increment", $test.assertEquals(2, $iRetry))

	# Suceeded and move on to next drive
	$test.step("Mapping succeeded", $test.assertFalse(_isRetryRequired(5,0,0)))

	# Failed and retry on this drive
	# 2 = Access to the remote share was denied
	# 3 = The device is already assigned
	# 4 = Invalid device name
	# 5 = Invalid remote share
	# 6 = Invalid password
	$test.step("Retry; Session credential", $test.assertTrue(_isRetryRequired(5,1,$ERROR_SESSION_CREDENTIAL_CONFLICT)))
	$test.step("Retry; Access denied     ", $test.assertTrue(_isRetryRequired(5,2,0)))
	$test.step("Retry; Invalid password  ", $test.assertTrue(_isRetryRequired(5,6,0)))

	# Failed and move on to next drive
	$test.step("Don't retry; Cancelled              ", $test.assertFalse(_isRetryRequired(5,1,$ERROR_CANCELLED)))
	$test.step("Don't retry; device already assigned", $test.assertFalse(_isRetryRequired(5,3,0)))
	$test.step("Don't retry; Invalid device name    ", $test.assertFalse(_isRetryRequired(5,4,0)))
	$test.step("Don't retry; Invalid remote share   ", $test.assertFalse(_isRetryRequired(5,5,0)))
	$test.step("Don't retry; last retry             ", $test.assertFalse(_isRetryRequired(1,2,0)))

	# Failed and give up on all drives
	
	$test.addToSuite($testSuite) ;Add test case into the test suite
	$test = 0

	Local $test	= _test_("Test _IsNormalFile")
	$test.step("example.ini", false)
	$test.step("nonexistent.ini", false)
	$test.step("directory @ScriptDir", false)
	$test.addToSuite($testSuite) ;Add test case into the test suite
	$test = 0

	$testSuite.stop()

	tearDown()
EndFunc







