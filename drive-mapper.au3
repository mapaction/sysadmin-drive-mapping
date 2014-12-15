#include <MsgBoxConstants.au3>
#include <APIErrorsConstants.au3>
#include <StringConstants.au3>

Const $g_sShareUNCkey = "share"
Const $g_sDriveFriendlyNameKey = "friendlyName"
Const $g_sKeyNotFound = "KEY NOT FOUND"
Const $g_iDriveMapAddShowAuthDlg = 8
Const $g_sDefaultIniFileName = "mappings.ini"
Const $DEBUG = 0

_DoAllMappings(_getIniFile())

func _getIniFile()
	local $inifile = ''
	if $CmdLine[0] > 0 then
		$inifile = $CmdLine[1]
	else
		$inifile = @ScriptDir & '\' & $g_sDefaultIniFileName
	endif
	
	_debugmsg("$inifile =" & $inifile)
	
	if _IsNormalFile($inifile) then
		_debugmsg("_IsNormalFile=True")
		return $inifile
	else
		_debugmsg("_IsNormalFile=False")
		Return SetError(999, 999, "Not a valid file")
	endif
endfunc


func _DoAllMappings($sFilePath)
	$oShell = ObjCreate("Shell.Application")
    $aSectionNames = IniReadSectionNames($sFilePath)
    if @error then
        Return SetError(1, 0)
    EndIf
	for $sDriveLetter in $aSectionNames
		if _isValidDriveName($sDriveLetter) then
			$sShareUNC = IniRead($sFilePath, $sDriveLetter, $g_sShareUNCkey, $g_sKeyNotFound)
			$sDriveName = IniRead($sFilePath, $sDriveLetter, $g_sDriveFriendlyNameKey, $g_sKeyNotFound)
			
			if _RemoveOldMapping($sDriveLetter, $sShareUNC) then
				_NewMapping($sDriveLetter, $sShareUNC, $sDriveName, $oShell)
			endif
			;DriveMapAdd ( "device", "remote share" [, flags = 0 [, "user" [, "password"]]] )
		;	msgbox("device" & & "  remote share" &
		endif
	next 
endfunc


func _isValidDriveName($sDriveName)
	return StringRegExp($sDriveName, "^[a-zA-Z]:$")
endfunc


Func _RemoveOldMapping($sDriveLetter, $sShareUNC)
	local $sCurrentUNC = DriveMapGet($sDriveLetter)
	if @error then
		; there is no drive mapped to this letter
        return 1
		if $sCurrentUNC = $sShareUNC then
			; The mapping already exists
			return 0
		else
			; Remove the drive letter
			return DriveMapDel($sDriveLetter)
		endif
    endif
EndFunc


Func _NewMapping($sDriveLetter, $sShareUNC, $sDriveName, $oShell)
	local $iAttempts = 3
	local $iError = -1, $iExtended

	do 
		DriveMapAdd($sDriveLetter, $sShareUNC, $g_iDriveMapAddShowAuthDlg )
		$iError = @error
		$iExtended = @extended
		$iAttempts
	until not _isRetryRequired($iAttempts, $iError, $iExtended)
#CS 		select
			case 0=$iError
				_debugmsg("$sDriveLetter=" & $sDriveLetter & "    $sDriveName=" & $sDriveName)
				$oShell.NameSpace($sDriveLetter).Self.Name =  $sDriveName
				return 1
			case (1=$iError) and ($iExtended=$ERROR_CANCELLED)
				msgbox($MB_SYSTEMMODAL, "", "Cancelled connecting to network drive")
				return 0
			case (1=$iError) and ($iExtended=$ERROR_SESSION_CREDENTIAL_CONFLICT)
				msgbox($MB_SYSTEMMODAL, "", "Wrong username and password")
			case (2=$iError) or (6=$iError)
			case else
				exitloop
		endselect
	until $iAttempts >= $iMaxAttemps
 #CE	
	# _debugmsg("Error connecting to network drive; $sDriveLetter=" & $sDriveLetter & "    $sDriveName=" & $sDriveName & " @error=" & $iError & " @extended=" & $iExtended)
	return 0
EndFunc

Func _isRetryRequired(ByRef $iRetryCnt, $iError, $iExtended)
	Local $b_rst
	
	$iRetryCnt = $iRetryCnt - 1
	
	select
		case 0 >= $iRetryCnt
			$b_rst = false
		case 0 = $iError
			$b_rst = false
			
		case (1=$iError) and ($iExtended=$ERROR_CANCELLED)
			_debugmsg("Cancelled connecting to network drive")
			$b_rst = false
		case (3=$iError) or (4=$iError) or (5=$iError)
			_debugmsg("Wrong username and password")
			$b_rst = false

		case (1=$iError) and ($iExtended=$ERROR_SESSION_CREDENTIAL_CONFLICT)
			_debugmsg("Wrong username and password")
			$b_rst = true
		case (2=$iError) or (6=$iError)
			_debugmsg("Wrong username and password")
			$b_rst = true
		case else
			_debugmsg("Unknown error")
			$b_rst = true
	endselect

	return $b_rst
EndFunc


Func _IsNormalFile($sFilePath)
	if fileexists($sFilePath) then
		local $sfileAtb = FileGetAttrib($sFilePath)
		_debugmsg("FileGetAttrib($sFilePath)=" & $sfileAtb)
		return StringInStr($sfileAtb, 'D', $STR_NOCASESENSE) == 0
	else
		_debugmsg("fileexists($sFilePath)=False")
		return false
	endif
EndFunc   ;==>IsFilee


func _debugmsg($sMsg)
	if $DEBUG then msgbox($MB_SYSTEMMODAL, "Drive Mapper Debug Message", $sMsg)
endfunc

