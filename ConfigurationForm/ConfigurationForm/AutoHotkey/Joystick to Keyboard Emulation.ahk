﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent  ; Keep this script running until the user explicitly exits it.
;#Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Compile the library files
#Include Library\XInput.ahk
#Include Library\Gdip.ahk
#Include Library\ToolTipOptions.ahk
#Include Library\Delegate.ahk

; Compile the utility classes
#Include Utility\DataStructures.ahk
#Include Utility\Debug.ahk
#Include Utility\IniReader.ahk
#Include Utility\Graphics.ahk
#Include Utility\Calibrate.ahk
#Include Utility\Inventory.ahk

; Compile the input classes
#Include Input\Binding.ahk
#Include Input\Input.ahk
#Include Input\InputHelper.ahk
#Include Input\Controller.ahk

XInput_Init() ; Initialize XInput
Gdip_Startup()

global PI := 3.141592653589793 ; Define PI for easier use

global ConfigurationPath = "config.ini"
global ProfilePath = "profile.ini"

SetTimer, Startup, 750 ; The 'Init' function of the code essentially. It's at the very bottom.

; Toggles Debug Mode
$F3::
	DebugMode := !DebugMode
	if(DebugMode)
	{
		Tooltip, Debug mode enabled `nPress F3 to disable, 0, 80, 5
		Debug.UpdateLog := True
	}
	else
	{
		Tooltip, , , , 5
		Tooltip, , , , 7
		Tooltip, , , , 8
	}
return

; Reloades the config values when F5 is pressed
$F5::
	Calibrate.Init()
	;ReadConfig()
return

; Pauses the script and displays a message indicating so whenever F10 is pressed. The '$' ensures the hotkey can't be triggered with a 'Send' command
$F10::
	; Set the tooltip if it should be shown
	if(!IsPaused and ShowPausedNotification)
		Tooltip, Paused `nPress F10 to resume, 0, 0, 4
	; Remove the tooltip if it is currently shown
	else if(ShowPausedNotification)
		Tooltip, , , , 4

	IsPaused := !IsPaused	; Toggle the pause boolean
	Pause, , 1
return

; Closes the program. The '$' ensures the hotkey can't be triggered with a 'Send' command
$F12::
	SelectObject(Graphics.m_HDC, Graphics.m_OBM)
	DeleteObject(Graphics.m_HBM)
	DeleteDC(Graphics.m_HDC)
	Gdip_DeleteGraphics(Graphics.m_Graphic)
	Gdip_Shutdown(Graphics.m_Token)
	ExitApp
return

VibeOff:
	Loop, 4
	{
		if XInput_GetState(A_Index-1)
			XInput_SetState(A_Index-1, 0, 0) ;MAX 65535
	}
	SetTimer, VibeOff, Off
return

TriggerState:
	Graphics.SetActiveWinStats()

	Controller.RefreshState()
	Controller.ProcessInput()

	if(DebugMode)
		Debug.DrawTooltip()
return
; /TriggerState

SpamLoot:
	MouseGetPos, _prevX, _prevY
	MouseMove, % Graphics.ActiveWinStats.Center.X, % Graphics.ActiveWinStats.Center.Y
	Send {LButton Down}
	Send {LButton Up}
	MouseMove, % _prevX, % _prevY
return

Startup:
	Debug.Init()
	IniReader.Init()
	Graphics.Init()

	Calibrate()
	Inventory.Init()
	Controller.Init()

	SetTimer, TriggerState, 1
	SetTimer, Startup, off
return
