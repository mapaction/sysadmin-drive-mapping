; Updated to add micro as a submodule
; https://github.com/AutoItMicro/MicroUnitTestingFramework
; Updated tests to match the updated Micro syntax
;
#include "../micro/micro.au3"
#include "../drive-mapper.au3"

#Region Test suite definition
$testSuite = newTestSuite("test-drive-mapper")

With $testSuite
	.ci = false
	.addTest(test_getIniFile())
	.addTest(test_DoAllMappings())
	.addTest(test_isValidDriveName())
	.addTest(test_isRetryRequired())
	.addTest(test_IsNormalFile())
	.finish()
EndWith

#EndRegion



func test_getIniFile()
	Local $test	= newTest("Test _getIniFile")
	$test.addStep("example.ini", false)
	$test.addStep("nonexistent.ini", false)
	; $test.addToSuite($testSuite) ;Add test case into the test suite
	return $test
endfunc
	
func test_DoAllMappings()
	Local $test	= newTest("Test _DoAllMappings")
	$test.addStep("No tests implemented yet", false)
	$test.addStep("Not a valid ini file", false)
	$test.addStep("Missing a share value in ini file", false)
	$test.addStep("Missing a friendlyName value in ini file", false)
	return $test
endfunc
	
func test_isValidDriveName()
	Local $test	= newTest("Test _isValidDriveName")
	$test.assertTrue("'A:' is valid", _isValidDriveName("A:"))
	$test.assertFalse("'AA:' is invalid", _isValidDriveName("AA:"))
	$test.assertFalse("'1:' is invalid",_isValidDriveName("1:"))
	$test.assertFalse("'A' is invalid",_isValidDriveName("A"))
	return $test
endfunc
	
func test_isRetryRequired()
	Local $test	= newTest("Test _isRetryRequired")
	# _isRetryRequired(ByRef iRetry,iError,iExtended)

	Local $iRetry = 3
	_isRetryRequired($iRetry,1,1)
	$test.assertEquals("Retry (de)increment", 2, $iRetry)

	# Suceeded and move on to next drive
	$test.assertFalse("Mapping succeeded", _isRetryRequired(5,0,0))

	# Failed and retry on this drive
	# 2 = Access to the remote share was denied
	# 3 = The device is already assigned
	# 4 = Invalid device name
	# 5 = Invalid remote share
	# 6 = Invalid password
	$test.assertTrue("Retry; Session credential", _isRetryRequired(5,1,$ERROR_SESSION_CREDENTIAL_CONFLICT))
	$test.assertTrue("Retry; Access denied     ", _isRetryRequired(5,2,0))
	$test.assertTrue("Retry; Invalid password  ", _isRetryRequired(5,6,0))

	# Failed and move on to next drive
	$test.assertFalse("Don't retry; Cancelled              ", _isRetryRequired(5,1,$ERROR_CANCELLED))
	$test.assertFalse("Don't retry; device already assigned", _isRetryRequired(5,3,0))
	$test.assertFalse("Don't retry; Invalid device name    ", _isRetryRequired(5,4,0))
	$test.assertFalse("Don't retry; Invalid remote share   ", _isRetryRequired(5,5,0))
	$test.assertFalse("Don't retry; last retry             ", _isRetryRequired(1,2,0))

	# Failed and give up on all drives
	# Decided that this was not necessay. The script could just keep running silently in the background.
	return $test
endfunc

func test_IsNormalFile()
	Local $test	= newTest("Test _IsNormalFile")
	$test.addStep("example.ini", false)
	$test.addStep("nonexistent.ini", false)
	$test.addStep("directory @ScriptDir", false)
	return $test
endfunc

