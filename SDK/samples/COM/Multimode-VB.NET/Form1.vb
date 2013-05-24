Option Strict Off
Option Explicit On
Friend Class Form1
	Inherits System.Windows.Forms.Form
#Region "Windows Form Designer generated code "
	Public Sub New()
		MyBase.New()
		If m_vb6FormDefInstance Is Nothing Then
			If m_InitializingDefInstance Then
				m_vb6FormDefInstance = Me
			Else
				Try 
					'For the start-up form, the first instance created is the default instance.
					If System.Reflection.Assembly.GetExecutingAssembly.EntryPoint.DeclaringType Is Me.GetType Then
						m_vb6FormDefInstance = Me
					End If
				Catch
				End Try
			End If
		End If
		'This call is required by the Windows Form Designer.
		InitializeComponent()
	End Sub
	'Form overrides dispose to clean up the component list.
	Protected Overloads Overrides Sub Dispose(ByVal Disposing As Boolean)
		If Disposing Then
			If Not components Is Nothing Then
				components.Dispose()
			End If
		End If
		MyBase.Dispose(Disposing)
	End Sub
	'Required by the Windows Form Designer
	Private components As System.ComponentModel.IContainer
	Public ToolTip1 As System.Windows.Forms.ToolTip
	Public WithEvents ckSessionSet As System.Windows.Forms.CheckBox
	Public WithEvents txtSessions As System.Windows.Forms.TextBox
	Public WithEvents cbMeterType As System.Windows.Forms.ComboBox
	Public WithEvents txtUser As System.Windows.Forms.TextBox
	Public WithEvents txtPassword As System.Windows.Forms.TextBox
	Public WithEvents txtAmount As System.Windows.Forms.TextBox
	Public WithEvents btMeter As System.Windows.Forms.Button
	Public WithEvents txtUnits As System.Windows.Forms.TextBox
	Public WithEvents txtDescription As System.Windows.Forms.TextBox
	Public WithEvents txtAccount As System.Windows.Forms.TextBox
	Public WithEvents txtServer As System.Windows.Forms.TextBox
	'NOTE: The following procedure is required by the Windows Form Designer
	'It can be modified using the Windows Form Designer.
	'Do not modify it using the code editor.
	<System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(Form1))
		Me.components = New System.ComponentModel.Container()
		Me.ToolTip1 = New System.Windows.Forms.ToolTip(components)
		Me.ToolTip1.Active = True
		Me.ckSessionSet = New System.Windows.Forms.CheckBox
		Me.txtSessions = New System.Windows.Forms.TextBox
		Me.cbMeterType = New System.Windows.Forms.ComboBox
		Me.txtUser = New System.Windows.Forms.TextBox
		Me.txtPassword = New System.Windows.Forms.TextBox
		Me.txtAmount = New System.Windows.Forms.TextBox
		Me.btMeter = New System.Windows.Forms.Button
		Me.txtUnits = New System.Windows.Forms.TextBox
		Me.txtDescription = New System.Windows.Forms.TextBox
		Me.txtAccount = New System.Windows.Forms.TextBox
		Me.txtServer = New System.Windows.Forms.TextBox
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
		Me.Text = "COM SDK Client"
		Me.ClientSize = New System.Drawing.Size(306, 255)
		Me.Location = New System.Drawing.Point(3, 24)
		Me.MaximizeBox = False
		Me.MinimizeBox = False
		Me.StartPosition = System.Windows.Forms.FormStartPosition.WindowsDefaultLocation
		Me.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.BackColor = System.Drawing.SystemColors.Control
		Me.ControlBox = True
		Me.Enabled = True
		Me.KeyPreview = False
		Me.Cursor = System.Windows.Forms.Cursors.Default
		Me.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.ShowInTaskbar = True
		Me.HelpButton = False
		Me.WindowState = System.Windows.Forms.FormWindowState.Normal
		Me.Name = "Form1"
		Me.ckSessionSet.Text = "Use Session Sets"
		Me.ckSessionSet.Size = New System.Drawing.Size(105, 25)
		Me.ckSessionSet.Location = New System.Drawing.Point(64, 208)
		Me.ckSessionSet.TabIndex = 10
		Me.ckSessionSet.CheckState = System.Windows.Forms.CheckState.Checked
		Me.ckSessionSet.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.ckSessionSet.CheckAlign = System.Drawing.ContentAlignment.MiddleLeft
		Me.ckSessionSet.BackColor = System.Drawing.SystemColors.Control
		Me.ckSessionSet.CausesValidation = True
		Me.ckSessionSet.Enabled = True
		Me.ckSessionSet.ForeColor = System.Drawing.SystemColors.ControlText
		Me.ckSessionSet.Cursor = System.Windows.Forms.Cursors.Default
		Me.ckSessionSet.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.ckSessionSet.Appearance = System.Windows.Forms.Appearance.Normal
		Me.ckSessionSet.TabStop = True
		Me.ckSessionSet.Visible = True
		Me.ckSessionSet.Name = "ckSessionSet"
		Me.txtSessions.AutoSize = False
		Me.txtSessions.Size = New System.Drawing.Size(41, 25)
		Me.txtSessions.Location = New System.Drawing.Point(16, 208)
		Me.txtSessions.TabIndex = 9
		Me.txtSessions.Text = "10"
		Me.txtSessions.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtSessions.AcceptsReturn = True
		Me.txtSessions.TextAlign = System.Windows.Forms.HorizontalAlignment.Left
		Me.txtSessions.BackColor = System.Drawing.SystemColors.Window
		Me.txtSessions.CausesValidation = True
		Me.txtSessions.Enabled = True
		Me.txtSessions.ForeColor = System.Drawing.SystemColors.WindowText
		Me.txtSessions.HideSelection = True
		Me.txtSessions.ReadOnly = False
		Me.txtSessions.Maxlength = 0
		Me.txtSessions.Cursor = System.Windows.Forms.Cursors.IBeam
		Me.txtSessions.MultiLine = False
		Me.txtSessions.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.txtSessions.ScrollBars = System.Windows.Forms.ScrollBars.None
		Me.txtSessions.TabStop = True
		Me.txtSessions.Visible = True
		Me.txtSessions.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
		Me.txtSessions.Name = "txtSessions"
		Me.cbMeterType.Size = New System.Drawing.Size(121, 21)
		Me.cbMeterType.Location = New System.Drawing.Point(176, 16)
		Me.cbMeterType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		Me.cbMeterType.TabIndex = 7
		Me.cbMeterType.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.cbMeterType.BackColor = System.Drawing.SystemColors.Window
		Me.cbMeterType.CausesValidation = True
		Me.cbMeterType.Enabled = True
		Me.cbMeterType.ForeColor = System.Drawing.SystemColors.WindowText
		Me.cbMeterType.IntegralHeight = True
		Me.cbMeterType.Cursor = System.Windows.Forms.Cursors.Default
		Me.cbMeterType.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.cbMeterType.Sorted = False
		Me.cbMeterType.TabStop = True
		Me.cbMeterType.Visible = True
		Me.cbMeterType.Name = "cbMeterType"
		Me.txtUser.AutoSize = False
		Me.txtUser.Size = New System.Drawing.Size(113, 33)
		Me.txtUser.Location = New System.Drawing.Point(176, 64)
		Me.txtUser.TabIndex = 5
		Me.txtUser.Text = "Username"
		Me.txtUser.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtUser.AcceptsReturn = True
		Me.txtUser.TextAlign = System.Windows.Forms.HorizontalAlignment.Left
		Me.txtUser.BackColor = System.Drawing.SystemColors.Window
		Me.txtUser.CausesValidation = True
		Me.txtUser.Enabled = True
		Me.txtUser.ForeColor = System.Drawing.SystemColors.WindowText
		Me.txtUser.HideSelection = True
		Me.txtUser.ReadOnly = False
		Me.txtUser.Maxlength = 0
		Me.txtUser.Cursor = System.Windows.Forms.Cursors.IBeam
		Me.txtUser.MultiLine = False
		Me.txtUser.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.txtUser.ScrollBars = System.Windows.Forms.ScrollBars.None
		Me.txtUser.TabStop = True
		Me.txtUser.Visible = True
		Me.txtUser.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
		Me.txtUser.Name = "txtUser"
		Me.txtPassword.AutoSize = False
		Me.txtPassword.Size = New System.Drawing.Size(113, 33)
		Me.txtPassword.Location = New System.Drawing.Point(176, 112)
		Me.txtPassword.TabIndex = 6
		Me.txtPassword.Text = "Password"
		Me.txtPassword.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtPassword.AcceptsReturn = True
		Me.txtPassword.TextAlign = System.Windows.Forms.HorizontalAlignment.Left
		Me.txtPassword.BackColor = System.Drawing.SystemColors.Window
		Me.txtPassword.CausesValidation = True
		Me.txtPassword.Enabled = True
		Me.txtPassword.ForeColor = System.Drawing.SystemColors.WindowText
		Me.txtPassword.HideSelection = True
		Me.txtPassword.ReadOnly = False
		Me.txtPassword.Maxlength = 0
		Me.txtPassword.Cursor = System.Windows.Forms.Cursors.IBeam
		Me.txtPassword.MultiLine = False
		Me.txtPassword.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.txtPassword.ScrollBars = System.Windows.Forms.ScrollBars.None
		Me.txtPassword.TabStop = True
		Me.txtPassword.Visible = True
		Me.txtPassword.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
		Me.txtPassword.Name = "txtPassword"
		Me.txtAmount.AutoSize = False
		Me.txtAmount.Size = New System.Drawing.Size(113, 33)
		Me.txtAmount.Location = New System.Drawing.Point(176, 160)
		Me.txtAmount.TabIndex = 4
		Me.txtAmount.Text = "Result"
		Me.txtAmount.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtAmount.AcceptsReturn = True
		Me.txtAmount.TextAlign = System.Windows.Forms.HorizontalAlignment.Left
		Me.txtAmount.BackColor = System.Drawing.SystemColors.Window
		Me.txtAmount.CausesValidation = True
		Me.txtAmount.Enabled = True
		Me.txtAmount.ForeColor = System.Drawing.SystemColors.WindowText
		Me.txtAmount.HideSelection = True
		Me.txtAmount.ReadOnly = False
		Me.txtAmount.Maxlength = 0
		Me.txtAmount.Cursor = System.Windows.Forms.Cursors.IBeam
		Me.txtAmount.MultiLine = False
		Me.txtAmount.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.txtAmount.ScrollBars = System.Windows.Forms.ScrollBars.None
		Me.txtAmount.TabStop = True
		Me.txtAmount.Visible = True
		Me.txtAmount.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
		Me.txtAmount.Name = "txtAmount"
		Me.btMeter.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		Me.btMeter.Text = "Meter"
		Me.AcceptButton = Me.btMeter
		Me.btMeter.Size = New System.Drawing.Size(113, 33)
		Me.btMeter.Location = New System.Drawing.Point(176, 208)
		Me.btMeter.TabIndex = 8
		Me.btMeter.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.btMeter.BackColor = System.Drawing.SystemColors.Control
		Me.btMeter.CausesValidation = True
		Me.btMeter.Enabled = True
		Me.btMeter.ForeColor = System.Drawing.SystemColors.ControlText
		Me.btMeter.Cursor = System.Windows.Forms.Cursors.Default
		Me.btMeter.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.btMeter.TabStop = True
		Me.btMeter.Name = "btMeter"
		Me.txtUnits.AutoSize = False
		Me.txtUnits.Size = New System.Drawing.Size(145, 33)
		Me.txtUnits.Location = New System.Drawing.Point(16, 160)
		Me.txtUnits.TabIndex = 3
		Me.txtUnits.Text = "Units"
		Me.txtUnits.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtUnits.AcceptsReturn = True
		Me.txtUnits.TextAlign = System.Windows.Forms.HorizontalAlignment.Left
		Me.txtUnits.BackColor = System.Drawing.SystemColors.Window
		Me.txtUnits.CausesValidation = True
		Me.txtUnits.Enabled = True
		Me.txtUnits.ForeColor = System.Drawing.SystemColors.WindowText
		Me.txtUnits.HideSelection = True
		Me.txtUnits.ReadOnly = False
		Me.txtUnits.Maxlength = 0
		Me.txtUnits.Cursor = System.Windows.Forms.Cursors.IBeam
		Me.txtUnits.MultiLine = False
		Me.txtUnits.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.txtUnits.ScrollBars = System.Windows.Forms.ScrollBars.None
		Me.txtUnits.TabStop = True
		Me.txtUnits.Visible = True
		Me.txtUnits.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
		Me.txtUnits.Name = "txtUnits"
		Me.txtDescription.AutoSize = False
		Me.txtDescription.Size = New System.Drawing.Size(145, 33)
		Me.txtDescription.Location = New System.Drawing.Point(16, 112)
		Me.txtDescription.TabIndex = 2
		Me.txtDescription.Text = "Description"
		Me.txtDescription.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtDescription.AcceptsReturn = True
		Me.txtDescription.TextAlign = System.Windows.Forms.HorizontalAlignment.Left
		Me.txtDescription.BackColor = System.Drawing.SystemColors.Window
		Me.txtDescription.CausesValidation = True
		Me.txtDescription.Enabled = True
		Me.txtDescription.ForeColor = System.Drawing.SystemColors.WindowText
		Me.txtDescription.HideSelection = True
		Me.txtDescription.ReadOnly = False
		Me.txtDescription.Maxlength = 0
		Me.txtDescription.Cursor = System.Windows.Forms.Cursors.IBeam
		Me.txtDescription.MultiLine = False
		Me.txtDescription.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.txtDescription.ScrollBars = System.Windows.Forms.ScrollBars.None
		Me.txtDescription.TabStop = True
		Me.txtDescription.Visible = True
		Me.txtDescription.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
		Me.txtDescription.Name = "txtDescription"
		Me.txtAccount.AutoSize = False
		Me.txtAccount.Size = New System.Drawing.Size(145, 33)
		Me.txtAccount.Location = New System.Drawing.Point(16, 64)
		Me.txtAccount.TabIndex = 1
		Me.txtAccount.Text = "Account Name"
		Me.txtAccount.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtAccount.AcceptsReturn = True
		Me.txtAccount.TextAlign = System.Windows.Forms.HorizontalAlignment.Left
		Me.txtAccount.BackColor = System.Drawing.SystemColors.Window
		Me.txtAccount.CausesValidation = True
		Me.txtAccount.Enabled = True
		Me.txtAccount.ForeColor = System.Drawing.SystemColors.WindowText
		Me.txtAccount.HideSelection = True
		Me.txtAccount.ReadOnly = False
		Me.txtAccount.Maxlength = 0
		Me.txtAccount.Cursor = System.Windows.Forms.Cursors.IBeam
		Me.txtAccount.MultiLine = False
		Me.txtAccount.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.txtAccount.ScrollBars = System.Windows.Forms.ScrollBars.None
		Me.txtAccount.TabStop = True
		Me.txtAccount.Visible = True
		Me.txtAccount.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
		Me.txtAccount.Name = "txtAccount"
		Me.txtServer.AutoSize = False
		Me.txtServer.Size = New System.Drawing.Size(145, 33)
		Me.txtServer.Location = New System.Drawing.Point(16, 16)
		Me.txtServer.TabIndex = 0
		Me.txtServer.Text = "Server Name"
		Me.txtServer.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtServer.AcceptsReturn = True
		Me.txtServer.TextAlign = System.Windows.Forms.HorizontalAlignment.Left
		Me.txtServer.BackColor = System.Drawing.SystemColors.Window
		Me.txtServer.CausesValidation = True
		Me.txtServer.Enabled = True
		Me.txtServer.ForeColor = System.Drawing.SystemColors.WindowText
		Me.txtServer.HideSelection = True
		Me.txtServer.ReadOnly = False
		Me.txtServer.Maxlength = 0
		Me.txtServer.Cursor = System.Windows.Forms.Cursors.IBeam
		Me.txtServer.MultiLine = False
		Me.txtServer.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.txtServer.ScrollBars = System.Windows.Forms.ScrollBars.None
		Me.txtServer.TabStop = True
		Me.txtServer.Visible = True
		Me.txtServer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
		Me.txtServer.Name = "txtServer"
		Me.Controls.Add(ckSessionSet)
		Me.Controls.Add(txtSessions)
		Me.Controls.Add(cbMeterType)
		Me.Controls.Add(txtUser)
		Me.Controls.Add(txtPassword)
		Me.Controls.Add(txtAmount)
		Me.Controls.Add(btMeter)
		Me.Controls.Add(txtUnits)
		Me.Controls.Add(txtDescription)
		Me.Controls.Add(txtAccount)
		Me.Controls.Add(txtServer)
	End Sub
#End Region 
#Region "Upgrade Support "
	Private Shared m_vb6FormDefInstance As Form1
	Private Shared m_InitializingDefInstance As Boolean
	Public Shared Property DefInstance() As Form1
		Get
			If m_vb6FormDefInstance Is Nothing OrElse m_vb6FormDefInstance.IsDisposed Then
				m_InitializingDefInstance = True
				m_vb6FormDefInstance = New Form1()
				m_InitializingDefInstance = False
			End If
			DefInstance = m_vb6FormDefInstance
		End Get
		Set
			m_vb6FormDefInstance = Value
		End Set
	End Property
#End Region 
	'***************************************************************************
	'* Copyright 2000-2006 by MetraTech Corporation
	'* All rights reserved.
	'*
	'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
	'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
	'* example, but not limitation, MetraTech Corporation MAKES NO
	'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
	'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
	'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
	'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
	'*
	'* Title to copyright in this software and any associated
	'* documentation shall at all times remain with MetraTech Corporation,
	'* and USER agrees to preserve the same.
	'*
	'***************************************************************************/
	
	
	Private objSessionSet As COMMeterLib.SessionSet
	Private objSession As COMMeterLib.Session
	Private objResultSession As COMMeterLib.Session
	Private objParent As COMMeterLib.Session
	Private objMeter As COMMeterLib.Meter
	
	Private Sub Form1_Load(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles MyBase.Load
		With cbMeterType
			.Items.Add("Atomic")
			.Items.Add("Compound")
			.Items.Add("Secure")
			.Items.Add("Synchronous")
			.SelectedIndex = 0
		End With
	End Sub
	
    Private Sub cbMeterType_SelectedIndexChanged(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles cbMeterType.SelectedIndexChanged
        txtUser.Visible = False
        txtPassword.Visible = False
        txtAmount.Visible = False
        txtSessions.Visible = False
        If cbMeterType.Text = "Atomic" Then Text = "COM SDK Client: Atomic"
        If cbMeterType.Text = "Compound" Then Text = "COM SDK Client: Compound"
        If cbMeterType.Text = "Secure" Then
            Text = "COM SDK Client: Secure"
            txtUser.Visible = True
            txtPassword.Visible = True
        End If
        If cbMeterType.Text = "Synchronous" Then
            txtAmount.Visible = True
            Text = "COM SDK Client: Synchronous"
        End If
        If ckSessionSet.CheckState = 1 Then
            Text = Text & " with " & txtSessions.Text & "-Session Set"
            txtSessions.Visible = True
        End If
    End Sub

    Private Sub ckSessionSet_CheckStateChanged(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles ckSessionSet.CheckStateChanged
        cbMeterType_SelectedIndexChanged(cbMeterType, New System.EventArgs)
    End Sub

    Private Sub btMeter_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles btMeter.Click
        If Val(txtUnits.Text) / 1 > 0 Then
            'nothing
        Else
            MsgBox("Will meter with 100 units.", MsgBoxStyle.Information, "COM SDK Client")
            txtUnits.Text = "100"
            Me.Refresh()
        End If
        If cbMeterType.Text = "Atomic" Then MeterAtomic()
        If cbMeterType.Text = "Compound" Then MeterCompound()
        If cbMeterType.Text = "Secure" Then MeterSecure()
        If cbMeterType.Text = "Synchronous" Then MeterSynchronous()
    End Sub

    Private Sub Initialize()
        ' Create the meter object
        objMeter = New COMMeterLib.Meter

        ' start up the SDK
        objMeter.Startup()

        ' Set the timeout and number of server retries
        objMeter.HTTPTimeout = 30
        objMeter.HTTPRetries = 1
    End Sub

    Private Sub TestSession()
        ' create a test session
        objSession = objMeter.CreateSession("metratech.com/TestService")

        If cbMeterType.Text = "Synchronous" Then
            '   request a response session
            objSession.RequestResponse = True
        End If

        ' set the session properties
        objSession.InitProperty("AccountName", txtAccount.Text)
        objSession.InitProperty("Description", txtDescription.Text)
        objSession.InitProperty("Time", Now)
        objSession.InitProperty("Units", CDbl(txtUnits.Text))
        If cbMeterType.Text <> "Compound" Then

        Else
            CallChildren()
        End If

        ' Close the session
        objSession.Close()

        ' Shutdown the SDK
        objMeter.Shutdown()
    End Sub

    Private Sub TestSessionSet()

        Dim nSessions As Short
        Dim i As Short

        ' create a session set to hold the test sessions
        objSessionSet = objMeter.CreateSessionSet()

        nSessions = Val(txtSessions.Text)

        For i = 1 To nSessions 'Create the test sessions in the set
            objSession = objSessionSet.CreateSession("metratech.com/TestService")
            ' set the session properties
            If cbMeterType.Text = "Synchronous" Then
                '   request a response session
                objSession.RequestResponse = True
            End If
            objSession.InitProperty("AccountName", txtAccount.Text)
            objSession.InitProperty("Description", txtDescription.Text)
            objSession.InitProperty("Units", CDbl(txtUnits.Text))
            objSession.InitProperty("Time", Now)
        Next

        ' close the session
        objSessionSet.Close()

        ' Shutdown the SDK
        objMeter.Shutdown()
    End Sub

    Private Sub MeterAtomic()
        Try

            Initialize()

            ' priority, servername, port, secure, username, password
            objMeter.AddServer(0, txtServer.Text, COMMeterLib.PortNumber.DEFAULT_HTTP_PORT, False, "", "")

            If ckSessionSet.CheckState = 1 Then
                TestSessionSet()
            Else
                TestSession()
            End If

        Catch
            MsgBox(Err.Description, MsgBoxStyle.Exclamation, "COM SDK Client")
            Exit Sub
        End Try
        MsgBox("Metering Complete", MsgBoxStyle.Information, "COM SDK Client")
    End Sub

    Private Sub MeterCompound()
        Try
            Dim i As Short

            Initialize()

            ' priority, servername, port, secure, username, password
            objMeter.AddServer(0, txtServer.Text, COMMeterLib.PortNumber.DEFAULT_HTTP_PORT, False, "", "")

            ' create the parent session
            objParent = objMeter.CreateSession("metratech.com/testparent")

            If ckSessionSet.CheckState = 1 Then
                TestSessionSet()
            Else
                TestSession()
            End If

        Catch
            MsgBox(Err.Description, MsgBoxStyle.Exclamation, "COM SDK Client")
            Exit Sub
        End Try
        MsgBox("Metering Complete", MsgBoxStyle.Information, "COM SDK Client")
    End Sub

    Private Sub CallChildren()
        Dim objChild As COMMeterLib.Session
        Dim i As Short
        ' create some test children
        For i = 1 To 5
            ' create a child session
            objChild = objParent.CreateChildSession("metratech.com/TestService")

            ' set the session properties
            objChild.InitProperty("AccountName", txtAccount.Text)
            objChild.InitProperty("Description", txtDescription.Text)
            objChild.InitProperty("Units", CDbl(txtUnits.Text))
            objChild.InitProperty("Time", Now)
        Next
    End Sub

    Private Sub MeterSecure()
        Try
            Initialize()

            ' priority, servername, port, secure, username, password
            objMeter.AddServer(0, txtServer.Text, COMMeterLib.PortNumber.DEFAULT_HTTPS_PORT, True, txtUser.Text, txtPassword.Text)

            If ckSessionSet.CheckState = 1 Then
                TestSessionSet()
            Else
                TestSession()
            End If

        Catch
            MsgBox(Err.Description, MsgBoxStyle.Exclamation, "COM SDK Client")
            Exit Sub
        End Try
        MsgBox("Metering Complete", MsgBoxStyle.Information, "COM SDK Client")
    End Sub

    Private Sub MeterSynchronous()
        Try
            '   Dim objMeter As Meter
            Dim amount As Double

            Initialize()

            ' priority, servername, port, secure, username, password
            objMeter.AddServer(0, txtServer.Text, COMMeterLib.PortNumber.DEFAULT_HTTP_PORT, False, "", "")

            If ckSessionSet.CheckState = 1 Then
                TestSessionSet()
            Else
                TestSession()
            End If

            ' Get the result session
            objResultSession = objSession.ResultSession

            ' Get the property added by the test stage
            'UPGRADE_WARNING: Couldn't resolve default property of object objResultSession.GetProperty(). Click for more: 'ms-help://MS.VSCC.2003/commoner/redir/redirect.htm?keyword="vbup1037"'
            amount = objResultSession.GetProperty("_Amount", COMMeterLib.DataType.MTC_DT_DOUBLE)

            ' Display the property
            txtAmount.Text = CStr(amount)

        Catch
            MsgBox(Err.Description, MsgBoxStyle.Exclamation, "COM SDK Client")
            Exit Sub
        End Try
        MsgBox("Metering Complete", MsgBoxStyle.Information, "COM SDK Client")
    End Sub

    Private Sub txtAccount_Enter(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles txtAccount.Enter
        txtAccount.SelectionLength = Len(txtAccount.Text)
    End Sub
    Private Sub txtAmount_Enter(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles txtAmount.Enter
        txtAmount.SelectionLength = Len(txtAmount.Text)
    End Sub
    Private Sub txtDescription_Enter(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles txtDescription.Enter
        txtDescription.SelectionLength = Len(txtDescription.Text)
    End Sub
    Private Sub txtPassword_Enter(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles txtPassword.Enter
        txtPassword.SelectionLength = Len(txtPassword.Text)
    End Sub
    Private Sub txtServer_Enter(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles txtServer.Enter
        txtServer.SelectionLength = Len(txtServer.Text)
    End Sub
    Private Sub txtSessions_TextChanged(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles txtSessions.TextChanged
        cbMeterType_SelectedIndexChanged(cbMeterType, New System.EventArgs)
    End Sub
    Private Sub txtUnits_Enter(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles txtUnits.Enter
        txtUnits.SelectionLength = Len(txtUnits.Text)
    End Sub
    Private Sub txtUser_Enter(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles txtUser.Enter
        txtUser.SelectionLength = Len(txtUser.Text)
    End Sub
End Class