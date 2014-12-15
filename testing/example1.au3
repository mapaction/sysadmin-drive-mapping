;License:
;	This script is distributed under the MIT License 
;
;Author:
;	oscar.tejera
;
;Description:
;File test suite
#include "lib/micro.au3"

;Run suite
testSuite()

;Setup test suite
Func setUp()
	Global $sFileName = "File.txt"
	FileOpen($sFileName,2)
EndFunc

;Teardown test suite
Func tearDown()
	FileDelete($sFileName)
EndFunc

;TestSuite
Func testSuite()
	setUp()

	Local $testSuite = _testSuite_("FileTestSuite","html") ;Set test suite name and format (Default format is txt)

	;Test 1
	Local $test	= _test_("testFileExist")
	$test.step("Assert file exist", $test.assertFileExists($sFileName))
	$test.addToSuite($testSuite) ;Add test case in test suite
	$test = 0

	;Test 2
	Local $test = _test_("testFileEnconding")
	$test.step("Assert file enconding is ANSI", $test.assertEquals("ANSI",FileGetEncoding($sFileName)))
	$test.addToSuite($testSuite)
	$test = 0

	;Test 3
	Local $test = _test_("testFileWrite")
	FileWrite($sFileName,"Evariste Galois")
	$test.step("Assert file write", $test.assertEquals(1,_FileCountLines($sFileName)))
	$test.addToSuite($testSuite)
	$test = 0

	;Test 4
	Local $test = _test_("testFileReadLine")
	$test.step("Assert file read fail", $test.assertEquals("Pierre Fermat",FileReadLine($sFileName,1)))
	$test.step("Assert file read ok", $test.assertEquals("Evariste Galois",FileReadLine($sFileName,1)))
	$test.addToSuite($testSuite)
	$test = 0

	$testSuite.stop()

	tearDown()
EndFunc






