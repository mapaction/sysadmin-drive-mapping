#include <MsgBoxConstants.au3>
#include <APIErrorsConstants.au3>
#include <StringConstants.au3>

Const $g_sShareUNCkey = "share"
Const $g_sDriveFriendlyNameKey = "friendlyName"
Const $g_sKeyNotFound = "KEY NOT FOUND"
Const $g_iDriveMapAddShowAuthDlg = 8
Const $g_sDefaultIniFileName = "mappings.ini"
Const $DEBUG = 0

_DoAllMappings(_getIniFile($CmdLine))

func _getIniFile($params)
	local $inifile = ''
	if IsArray($params) then
		if $params[0] > 0 then
			$inifile = $params[1]
		else
			Return SetError(998, 998, "Invalid command line parameters")
		endif
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
	_debugmsg("$aSectionNames" & UBound($aSectionNames))
	for $sDriveLetter in $aSectionNames
		if _isValidDriveName($sDriveLetter) then
			_debugmsg("$sDriveLetter " & $sDriveLetter)
			$sShareUNC = IniRead($sFilePath, $sDriveLetter, $g_sShareUNCkey, $g_sKeyNotFound)
			$sDriveName = IniRead($sFilePath, $sDriveLetter, $g_sDriveFriendlyNameKey, $g_sKeyNotFound)
			
			if _RemoveOldMapping($sDriveLetter, $sShareUNC) then
				if not _NewMapping($sDriveLetter, $sShareUNC, $sDriveName, $oShell) then
					# The user canceled the dialog so
					# do not attempt additional mappings
					exitloop
				endif
			endif
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

#
; Returns true if 
Func _NewMapping($sDriveLetter, $sShareUNC, $sDriveName, $oShell)
	local $iAttempts = 3
	local $iError = -1, $iExtended

	do 
		DriveMapAdd($sDriveLetter, $sShareUNC, $g_iDriveMapAddShowAuthDlg)
		$iError = @error
		$iExtended = @extended
		$iAttempts
	until not _isRetryRequired($iAttempts, $iError, $iExtended)
	
	# If sucessful apply the friendly name
	if 0=$iError then
		$oShell.NameSpace($sDriveLetter).Self.Name =  $sDriveName
	endif
	
	# If the user canceled the dialog return false so that additional mappings are not attempted
	if (1=$iError) and ($iExtended=$ERROR_CANCELLED) then
		return false
	else
		return true
	endif
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
EndFunc  

func _debugmsg($sMsg)
	if $DEBUG then msgbox($MB_SYSTEMMODAL, "Drive Mapper Debug Message", $sMsg)
endfunc

