#include <MsgBoxConstants.au3>
#include <APIErrorsConstants.au3>

Const $g_sShareUNCkey = "share"
Const $g_sDriveFriendlyNameKey = "friendlyName"
Const $g_sKeyNotFound = "KEY NOT FOUND"
Const $g_iDriveMapAddShowAuthDlg = 8
Const $DEBUG = 0

_DoAllMappings(@ScriptDir & '\example.ini')


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
	local $iAttempts = 1
	local $iMaxAttemps = 3
	local $iError = -1, $iExtended

	#CS 
	Success: 	1. (See Remarks)
	Failure: 	0 if a new mapping could not be created and sets the @error flag to non-zero.
	@error: 	1 = Undefined / Other error. @extended set with Windows API return
	2 = Access to the remote share was denied
	3 = The device is already assigned
	4 = Invalid device name
	5 = Invalid remote share
	6 = Invalid password
	#CE
	
	do 
		DriveMapAdd($sDriveLetter, $sShareUNC, $g_iDriveMapAddShowAuthDlg )
		$iError = @error
		$iExtended = @extended
		$iAttempts += 1
		select
			case 0=$iError
				if $DEBUG then msgbox($MB_SYSTEMMODAL, "", "$sDriveLetter=" & $sDriveLetter & "    $sDriveName=" & $sDriveName)
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
	
	msgbox($MB_SYSTEMMODAL, "Error connecting to network drive", "$sDriveLetter=" & $sDriveLetter & "    $sDriveName=" & $sDriveName & " @error=" & $iError & " @extended=" & $iExtended)
	return 0
EndFunc


