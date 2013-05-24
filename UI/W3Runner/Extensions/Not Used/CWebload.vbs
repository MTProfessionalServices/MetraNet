' ---------------------------------------------------------------------------------------------------------------------------
'
' Copyright 2002 by W3Runner.com.
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND W3Runner.com. MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, W3Runner.com. Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with W3Runner.com.,
' and USER agrees to preserve the same.
'
' ---------------------------------------------------------------------------------------------------------------------------
'
' NAME          : CWebLoad
' DESCRIPTION   : Start instances of W3Runner which will execute the a function in the current script.
'                 The idea behind this class is not to compete with WebLoad testing tool but
'                 just to prove how open is W3Runner.
' SAMPLE        :
'
' ---------------------------------------------------------------------------------------------------------------------------

Class CWebLoad

    Private m_lngMaxInstance
    Private m_lngMaxWidth
    Private m_lngMaxHeight
    Private m_strFunction

    Public VerticalMode
    Public FullScreen
    Public WaitTimeBetweenInstance

    Public Function Initialize(lngMaxInstance, strFunction) ' As Boolean

        Dim i ' As Long
        Dim lngTop                                      ' As Long
        Dim lngLeft                             ' As Long

        W3Runner.MoveMouseCursor = FALSE
        Page.AutoFocus       = FALSE

        m_lngMaxInstance = lngMaxInstance
        m_strFunction    = strFunction
        m_lngMaxWidth    = CLng( (Screen.Width  / Screen.TwipsPerPixelX) / (m_lngMaxInstance / 2) )
        m_lngMaxHeight   = CLng( (Screen.Height / Screen.TwipsPerPixelY) / 2 )

        For i = 1 To m_lngMaxInstance\2

            lngLeft = (i - 1) * m_lngMaxWidth
            lngTop  = 0

            ExecuteInstanceOfTheScript i,lngLeft, lngTop

            lngTop = m_lngMaxHeight

            ExecuteInstanceOfTheScript i,lngLeft, lngTop
        Next
        Initialize = True
    End Function

    Private Sub Class_Initialize()
        WaitTimeBetweenInstance = 1
        VerticalMode = True
        FullScreen = False
    End Sub

    Private Sub Class_Terminate()
    End Sub

    Private Function ExecuteInstanceOfTheScript(lngIndex,lngLeft, lngTop) '  As Boolean

        Dim strParameter
        Dim lngWidth
        Dim lngHeight
        Dim strFileName
        Dim strFunction
        Dim strW3RunnerPath

        strFileName   = Page.ScriptFileName
        strFunction   = m_strFunction
        lngWidth      = m_lngMaxWidth
        lngHeight     = m_lngMaxHeight

        strParameter    = PreProcess("-file [DC][FILE][DC] -function [DC][FUNCTION][DC] -left [LEFT] -top [TOP] -width [WIDTH] -height [HEIGHT] -fullscreen [FULLSCREEN] -WebLoadInstanceId [WEBLOADINSTANCEID]", Array("FILE", strFileName, "FUNCTION", strFunction, "DC", """", "TOP", lngTop, "LEFT", lngLeft, "WIDTH", lngWidth, "HEIGHT", lngHeight, "FULLSCREEN", FullScreen, "WEBLOADINSTANCEID", lngIndex))
        strW3RunnerPath = W3Runner.Environ(w3rW3RUNNER_PATH) & "\W3RunnerRT.exe"

        W3Runner.TRACE "Execute another instance of W3Runner " & strW3RunnerPath & " " & strParameter

        Page.Helper.Execute strW3RunnerPath, strParameter, False, vbNormalFocus
        W3Runner.Wait WaitTimeBetweenInstance

        ExecuteInstanceOfTheScript = True
    End Function

END CLASS


