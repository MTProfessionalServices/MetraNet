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
	Public WithEvents btnSessionSet As System.Windows.Forms.Button
	Public WithEvents btnCompound As System.Windows.Forms.Button
	Public WithEvents txtAmount As System.Windows.Forms.TextBox
	Public WithEvents Label3 As System.Windows.Forms.Label
	Public WithEvents Frame3 As System.Windows.Forms.GroupBox
	Public WithEvents txtUnits As System.Windows.Forms.TextBox
	Public WithEvents txtDescription As System.Windows.Forms.TextBox
	Public WithEvents txtAccount As System.Windows.Forms.TextBox
	Public WithEvents Label4 As System.Windows.Forms.Label
	Public WithEvents Label1 As System.Windows.Forms.Label
	Public WithEvents Label2 As System.Windows.Forms.Label
	Public WithEvents Frame2 As System.Windows.Forms.GroupBox
	Public WithEvents txtPassword As System.Windows.Forms.TextBox
	Public WithEvents txtUser As System.Windows.Forms.TextBox
	Public WithEvents txtServer As System.Windows.Forms.TextBox
	Public WithEvents Label7 As System.Windows.Forms.Label
	Public WithEvents Label6 As System.Windows.Forms.Label
	Public WithEvents Label5 As System.Windows.Forms.Label
	Public WithEvents Frame1 As System.Windows.Forms.GroupBox
	Public WithEvents btnFail As System.Windows.Forms.Button
	Public WithEvents btnLocalMode As System.Windows.Forms.Button
	Public WithEvents btnSynchronous As System.Windows.Forms.Button
	Public WithEvents btnSecure As System.Windows.Forms.Button
	Public WithEvents btnSimple As System.Windows.Forms.Button
	'NOTE: The following procedure is required by the Windows Form Designer
	'It can be modified using the Windows Form Designer.
	'Do not modify it using the code editor.
	<System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
		Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(Form1))
		Me.components = New System.ComponentModel.Container()
		Me.ToolTip1 = New System.Windows.Forms.ToolTip(components)
		Me.ToolTip1.Active = True
		Me.btnSessionSet = New System.Windows.Forms.Button
		Me.btnCompound = New System.Windows.Forms.Button
		Me.Frame3 = New System.Windows.Forms.GroupBox
		Me.txtAmount = New System.Windows.Forms.TextBox
		Me.Label3 = New System.Windows.Forms.Label
		Me.Frame2 = New System.Windows.Forms.GroupBox
		Me.txtUnits = New System.Windows.Forms.TextBox
		Me.txtDescription = New System.Windows.Forms.TextBox
		Me.txtAccount = New System.Windows.Forms.TextBox
		Me.Label4 = New System.Windows.Forms.Label
		Me.Label1 = New System.Windows.Forms.Label
		Me.Label2 = New System.Windows.Forms.Label
		Me.Frame1 = New System.Windows.Forms.GroupBox
		Me.txtPassword = New System.Windows.Forms.TextBox
		Me.txtUser = New System.Windows.Forms.TextBox
		Me.txtServer = New System.Windows.Forms.TextBox
		Me.Label7 = New System.Windows.Forms.Label
		Me.Label6 = New System.Windows.Forms.Label
		Me.Label5 = New System.Windows.Forms.Label
		Me.btnFail = New System.Windows.Forms.Button
		Me.btnLocalMode = New System.Windows.Forms.Button
		Me.btnSynchronous = New System.Windows.Forms.Button
		Me.btnSecure = New System.Windows.Forms.Button
		Me.btnSimple = New System.Windows.Forms.Button
		Me.Text = "Meter Demo"
		Me.ClientSize = New System.Drawing.Size(601, 643)
		Me.Location = New System.Drawing.Point(4, 23)
		Me.StartPosition = System.Windows.Forms.FormStartPosition.WindowsDefaultLocation
		Me.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
		Me.BackColor = System.Drawing.SystemColors.Control
		Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Sizable
		Me.ControlBox = True
		Me.Enabled = True
		Me.KeyPreview = False
		Me.MaximizeBox = True
		Me.MinimizeBox = True
		Me.Cursor = System.Windows.Forms.Cursors.Default
		Me.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.ShowInTaskbar = True
		Me.HelpButton = False
		Me.WindowState = System.Windows.Forms.FormWindowState.Normal
		Me.Name = "Form1"
		Me.btnSessionSet.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		Me.btnSessionSet.Text = "Meter SessionSet"
		Me.btnSessionSet.Size = New System.Drawing.Size(185, 65)
		Me.btnSessionSet.Location = New System.Drawing.Point(368, 560)
		Me.btnSessionSet.TabIndex = 23
		Me.btnSessionSet.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.btnSessionSet.BackColor = System.Drawing.SystemColors.Control
		Me.btnSessionSet.CausesValidation = True
		Me.btnSessionSet.Enabled = True
		Me.btnSessionSet.ForeColor = System.Drawing.SystemColors.ControlText
		Me.btnSessionSet.Cursor = System.Windows.Forms.Cursors.Default
		Me.btnSessionSet.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.btnSessionSet.TabStop = True
		Me.btnSessionSet.Name = "btnSessionSet"
		Me.btnCompound.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		Me.btnCompound.Text = "Meter &Compound"
		Me.btnCompound.Size = New System.Drawing.Size(185, 65)
		Me.btnCompound.Location = New System.Drawing.Point(368, 472)
		Me.btnCompound.TabIndex = 22
		Me.btnCompound.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.btnCompound.BackColor = System.Drawing.SystemColors.Control
		Me.btnCompound.CausesValidation = True
		Me.btnCompound.Enabled = True
		Me.btnCompound.ForeColor = System.Drawing.SystemColors.ControlText
		Me.btnCompound.Cursor = System.Windows.Forms.Cursors.Default
		Me.btnCompound.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.btnCompound.TabStop = True
		Me.btnCompound.Name = "btnCompound"
		Me.Frame3.Text = "Result Properties"
		Me.Frame3.Size = New System.Drawing.Size(289, 65)
		Me.Frame3.Location = New System.Drawing.Point(40, 488)
		Me.Frame3.TabIndex = 13
		Me.Frame3.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Frame3.BackColor = System.Drawing.SystemColors.Control
		Me.Frame3.Enabled = True
		Me.Frame3.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Frame3.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Frame3.Visible = True
		Me.Frame3.Name = "Frame3"
		Me.txtAmount.AutoSize = False
		Me.txtAmount.Enabled = False
		Me.txtAmount.Size = New System.Drawing.Size(105, 33)
		Me.txtAmount.Location = New System.Drawing.Point(96, 16)
		Me.txtAmount.TabIndex = 15
		Me.txtAmount.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtAmount.AcceptsReturn = True
		Me.txtAmount.TextAlign = System.Windows.Forms.HorizontalAlignment.Left
		Me.txtAmount.BackColor = System.Drawing.SystemColors.Window
		Me.txtAmount.CausesValidation = True
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
		Me.Label3.TextAlign = System.Drawing.ContentAlignment.TopRight
		Me.Label3.Text = "Amount"
		Me.Label3.Size = New System.Drawing.Size(49, 17)
		Me.Label3.Location = New System.Drawing.Point(16, 24)
		Me.Label3.TabIndex = 14
		Me.Label3.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label3.BackColor = System.Drawing.SystemColors.Control
		Me.Label3.Enabled = True
		Me.Label3.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Label3.Cursor = System.Windows.Forms.Cursors.Default
		Me.Label3.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Label3.UseMnemonic = True
		Me.Label3.Visible = True
		Me.Label3.AutoSize = False
		Me.Label3.BorderStyle = System.Windows.Forms.BorderStyle.None
		Me.Label3.Name = "Label3"
		Me.Frame2.Text = "Metered Properties"
		Me.Frame2.Size = New System.Drawing.Size(289, 209)
		Me.Frame2.Location = New System.Drawing.Point(40, 240)
		Me.Frame2.TabIndex = 6
		Me.Frame2.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Frame2.BackColor = System.Drawing.SystemColors.Control
		Me.Frame2.Enabled = True
		Me.Frame2.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Frame2.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Frame2.Visible = True
		Me.Frame2.Name = "Frame2"
		Me.txtUnits.AutoSize = False
		Me.txtUnits.Size = New System.Drawing.Size(97, 33)
		Me.txtUnits.Location = New System.Drawing.Point(96, 152)
		Me.txtUnits.TabIndex = 12
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
		Me.txtDescription.Size = New System.Drawing.Size(177, 33)
		Me.txtDescription.Location = New System.Drawing.Point(96, 96)
		Me.txtDescription.TabIndex = 8
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
		Me.txtAccount.Size = New System.Drawing.Size(97, 33)
		Me.txtAccount.Location = New System.Drawing.Point(96, 40)
		Me.txtAccount.TabIndex = 7
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
		Me.Label4.Text = "Units"
		Me.Label4.Size = New System.Drawing.Size(25, 17)
		Me.Label4.Location = New System.Drawing.Point(40, 160)
		Me.Label4.TabIndex = 11
		Me.Label4.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label4.TextAlign = System.Drawing.ContentAlignment.TopLeft
		Me.Label4.BackColor = System.Drawing.SystemColors.Control
		Me.Label4.Enabled = True
		Me.Label4.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Label4.Cursor = System.Windows.Forms.Cursors.Default
		Me.Label4.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Label4.UseMnemonic = True
		Me.Label4.Visible = True
		Me.Label4.AutoSize = False
		Me.Label4.BorderStyle = System.Windows.Forms.BorderStyle.None
		Me.Label4.Name = "Label4"
		Me.Label1.TextAlign = System.Drawing.ContentAlignment.TopRight
		Me.Label1.Text = "Account Name"
		Me.Label1.Size = New System.Drawing.Size(73, 17)
		Me.Label1.Location = New System.Drawing.Point(8, 48)
		Me.Label1.TabIndex = 10
		Me.Label1.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label1.BackColor = System.Drawing.SystemColors.Control
		Me.Label1.Enabled = True
		Me.Label1.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Label1.Cursor = System.Windows.Forms.Cursors.Default
		Me.Label1.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Label1.UseMnemonic = True
		Me.Label1.Visible = True
		Me.Label1.AutoSize = False
		Me.Label1.BorderStyle = System.Windows.Forms.BorderStyle.None
		Me.Label1.Name = "Label1"
		Me.Label2.TextAlign = System.Drawing.ContentAlignment.TopRight
		Me.Label2.Text = "Description"
		Me.Label2.Size = New System.Drawing.Size(57, 17)
		Me.Label2.Location = New System.Drawing.Point(16, 104)
		Me.Label2.TabIndex = 9
		Me.Label2.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label2.BackColor = System.Drawing.SystemColors.Control
		Me.Label2.Enabled = True
		Me.Label2.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Label2.Cursor = System.Windows.Forms.Cursors.Default
		Me.Label2.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Label2.UseMnemonic = True
		Me.Label2.Visible = True
		Me.Label2.AutoSize = False
		Me.Label2.BorderStyle = System.Windows.Forms.BorderStyle.None
		Me.Label2.Name = "Label2"
		Me.Frame1.Text = "Connection Info"
		Me.Frame1.Size = New System.Drawing.Size(289, 193)
		Me.Frame1.Location = New System.Drawing.Point(40, 32)
		Me.Frame1.TabIndex = 5
		Me.Frame1.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Frame1.BackColor = System.Drawing.SystemColors.Control
		Me.Frame1.Enabled = True
		Me.Frame1.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Frame1.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Frame1.Visible = True
		Me.Frame1.Name = "Frame1"
		Me.txtPassword.AutoSize = False
		Me.txtPassword.Size = New System.Drawing.Size(121, 35)
		Me.txtPassword.Location = New System.Drawing.Point(104, 144)
		Me.txtPassword.TabIndex = 21
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
		Me.txtUser.AutoSize = False
		Me.txtUser.Size = New System.Drawing.Size(105, 33)
		Me.txtUser.Location = New System.Drawing.Point(104, 88)
		Me.txtUser.TabIndex = 20
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
		Me.txtServer.AutoSize = False
		Me.txtServer.Size = New System.Drawing.Size(113, 35)
		Me.txtServer.Location = New System.Drawing.Point(104, 32)
		Me.txtServer.TabIndex = 19
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
		Me.Label7.Text = "Password"
		Me.Label7.Size = New System.Drawing.Size(57, 17)
		Me.Label7.Location = New System.Drawing.Point(16, 152)
		Me.Label7.TabIndex = 18
		Me.Label7.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label7.TextAlign = System.Drawing.ContentAlignment.TopLeft
		Me.Label7.BackColor = System.Drawing.SystemColors.Control
		Me.Label7.Enabled = True
		Me.Label7.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Label7.Cursor = System.Windows.Forms.Cursors.Default
		Me.Label7.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Label7.UseMnemonic = True
		Me.Label7.Visible = True
		Me.Label7.AutoSize = False
		Me.Label7.BorderStyle = System.Windows.Forms.BorderStyle.None
		Me.Label7.Name = "Label7"
		Me.Label6.Text = "User Name"
		Me.Label6.Size = New System.Drawing.Size(57, 17)
		Me.Label6.Location = New System.Drawing.Point(16, 96)
		Me.Label6.TabIndex = 17
		Me.Label6.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label6.TextAlign = System.Drawing.ContentAlignment.TopLeft
		Me.Label6.BackColor = System.Drawing.SystemColors.Control
		Me.Label6.Enabled = True
		Me.Label6.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Label6.Cursor = System.Windows.Forms.Cursors.Default
		Me.Label6.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Label6.UseMnemonic = True
		Me.Label6.Visible = True
		Me.Label6.AutoSize = False
		Me.Label6.BorderStyle = System.Windows.Forms.BorderStyle.None
		Me.Label6.Name = "Label6"
		Me.Label5.Text = "Server"
		Me.Label5.Size = New System.Drawing.Size(33, 17)
		Me.Label5.Location = New System.Drawing.Point(24, 40)
		Me.Label5.TabIndex = 16
		Me.Label5.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label5.TextAlign = System.Drawing.ContentAlignment.TopLeft
		Me.Label5.BackColor = System.Drawing.SystemColors.Control
		Me.Label5.Enabled = True
		Me.Label5.ForeColor = System.Drawing.SystemColors.ControlText
		Me.Label5.Cursor = System.Windows.Forms.Cursors.Default
		Me.Label5.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.Label5.UseMnemonic = True
		Me.Label5.Visible = True
		Me.Label5.AutoSize = False
		Me.Label5.BorderStyle = System.Windows.Forms.BorderStyle.None
		Me.Label5.Name = "Label5"
		Me.btnFail.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		Me.btnFail.Text = "Meter &Failover"
		Me.btnFail.Size = New System.Drawing.Size(185, 65)
		Me.btnFail.Location = New System.Drawing.Point(368, 384)
		Me.btnFail.TabIndex = 4
		Me.btnFail.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.btnFail.BackColor = System.Drawing.SystemColors.Control
		Me.btnFail.CausesValidation = True
		Me.btnFail.Enabled = True
		Me.btnFail.ForeColor = System.Drawing.SystemColors.ControlText
		Me.btnFail.Cursor = System.Windows.Forms.Cursors.Default
		Me.btnFail.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.btnFail.TabStop = True
		Me.btnFail.Name = "btnFail"
		Me.btnLocalMode.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		Me.btnLocalMode.Text = "Meter &Local Mode"
		Me.btnLocalMode.Size = New System.Drawing.Size(185, 65)
		Me.btnLocalMode.Location = New System.Drawing.Point(368, 296)
		Me.btnLocalMode.TabIndex = 3
		Me.btnLocalMode.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.btnLocalMode.BackColor = System.Drawing.SystemColors.Control
		Me.btnLocalMode.CausesValidation = True
		Me.btnLocalMode.Enabled = True
		Me.btnLocalMode.ForeColor = System.Drawing.SystemColors.ControlText
		Me.btnLocalMode.Cursor = System.Windows.Forms.Cursors.Default
		Me.btnLocalMode.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.btnLocalMode.TabStop = True
		Me.btnLocalMode.Name = "btnLocalMode"
		Me.btnSynchronous.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		Me.btnSynchronous.Text = "Meter S&ynchronous"
		Me.btnSynchronous.Size = New System.Drawing.Size(185, 65)
		Me.btnSynchronous.Location = New System.Drawing.Point(368, 208)
		Me.btnSynchronous.TabIndex = 2
		Me.btnSynchronous.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.btnSynchronous.BackColor = System.Drawing.SystemColors.Control
		Me.btnSynchronous.CausesValidation = True
		Me.btnSynchronous.Enabled = True
		Me.btnSynchronous.ForeColor = System.Drawing.SystemColors.ControlText
		Me.btnSynchronous.Cursor = System.Windows.Forms.Cursors.Default
		Me.btnSynchronous.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.btnSynchronous.TabStop = True
		Me.btnSynchronous.Name = "btnSynchronous"
		Me.btnSecure.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		Me.btnSecure.Text = "Meter S&ecure"
		Me.btnSecure.Size = New System.Drawing.Size(185, 65)
		Me.btnSecure.Location = New System.Drawing.Point(368, 120)
		Me.btnSecure.TabIndex = 1
		Me.btnSecure.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.btnSecure.BackColor = System.Drawing.SystemColors.Control
		Me.btnSecure.CausesValidation = True
		Me.btnSecure.Enabled = True
		Me.btnSecure.ForeColor = System.Drawing.SystemColors.ControlText
		Me.btnSecure.Cursor = System.Windows.Forms.Cursors.Default
		Me.btnSecure.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.btnSecure.TabStop = True
		Me.btnSecure.Name = "btnSecure"
		Me.btnSimple.TextAlign = System.Drawing.ContentAlignment.MiddleCenter
		Me.btnSimple.Text = "Meter &Simple"
		Me.btnSimple.Size = New System.Drawing.Size(185, 57)
		Me.btnSimple.Location = New System.Drawing.Point(368, 40)
		Me.btnSimple.TabIndex = 0
		Me.btnSimple.Font = New System.Drawing.Font("Arial", 8!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.btnSimple.BackColor = System.Drawing.SystemColors.Control
		Me.btnSimple.CausesValidation = True
		Me.btnSimple.Enabled = True
		Me.btnSimple.ForeColor = System.Drawing.SystemColors.ControlText
		Me.btnSimple.Cursor = System.Windows.Forms.Cursors.Default
		Me.btnSimple.RightToLeft = System.Windows.Forms.RightToLeft.No
		Me.btnSimple.TabStop = True
		Me.btnSimple.Name = "btnSimple"
		Me.Controls.Add(btnSessionSet)
		Me.Controls.Add(btnCompound)
		Me.Controls.Add(Frame3)
		Me.Controls.Add(Frame2)
		Me.Controls.Add(Frame1)
		Me.Controls.Add(btnFail)
		Me.Controls.Add(btnLocalMode)
		Me.Controls.Add(btnSynchronous)
		Me.Controls.Add(btnSecure)
		Me.Controls.Add(btnSimple)
		Me.Frame3.Controls.Add(txtAmount)
		Me.Frame3.Controls.Add(Label3)
		Me.Frame2.Controls.Add(txtUnits)
		Me.Frame2.Controls.Add(txtDescription)
		Me.Frame2.Controls.Add(txtAccount)
		Me.Frame2.Controls.Add(Label4)
		Me.Frame2.Controls.Add(Label1)
		Me.Frame2.Controls.Add(Label2)
		Me.Frame1.Controls.Add(txtPassword)
		Me.Frame1.Controls.Add(txtUser)
		Me.Frame1.Controls.Add(txtServer)
		Me.Frame1.Controls.Add(Label7)
		Me.Frame1.Controls.Add(Label6)
		Me.Frame1.Controls.Add(Label5)
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
	Private Sub MeterSimple()
		
		Dim objSession As COMMeterLib.Session
		Dim objMeter As COMMeterLib.Meter
		
		' Create the meter object
		objMeter = New COMMeterLib.Meter
		
		' start up the SDK
		objMeter.Startup()
		
		' Set the timeout and number of server retries
		objMeter.HTTPTimeout = 30
		objMeter.HTTPRetries = 1
		
		' priority, servername, port, secure, username, password
		objMeter.AddServer(0, txtServer.Text, COMMeterLib.__MIDL___MIDL_itf_COMMeter_0000_0004.DEFAULT_HTTP_PORT, False, "", "")
		
		' create a test session
		objSession = objMeter.CreateSession("metratech.com/TestService")
		
		' set the session properties
		objSession.InitProperty("AccountName", txtAccount.Text)
		objSession.InitProperty("Description", txtDescription.Text)
		objSession.InitProperty("Units", CDbl(txtUnits.Text))
		objSession.InitProperty("Time", Now)
		
		' close the session
		objSession.Close()
		
		' shutdown the SDK
		objMeter.Shutdown()
		
	End Sub
	
	Private Sub MeterSessionSet()
		Dim i As Object
		
		Dim objSessionSet As COMMeterLib.SessionSet
		Dim objSession As COMMeterLib.Session
		Dim objMeter As COMMeterLib.Meter
		Dim nSessions As Short
		
		' Create the meter object
		objMeter = New COMMeterLib.Meter
		
		' start up the SDK
		objMeter.Startup()
		
		' Set the timeout and number of server retries
		objMeter.HTTPTimeout = 30
		objMeter.HTTPRetries = 1
		
		' priority, servername, port, secure, username, password
		objMeter.AddServer(0, txtServer.Text, COMMeterLib.__MIDL___MIDL_itf_COMMeter_0000_0004.DEFAULT_HTTP_PORT, False, "", "")
		
		' create a session set to hold the test sessions
		objSessionSet = objMeter.CreateSessionSet()
		
		nSessions = 10
		
		For i = 1 To nSessions ' Create the test sessions in the set
			objSession = objSessionSet.CreateSession("metratech.com/TestService")
			' set the session properties
			objSession.InitProperty("AccountName", txtAccount.Text)
			objSession.InitProperty("Description", txtDescription.Text)
			objSession.InitProperty("Units", CDbl(txtUnits.Text))
			objSession.InitProperty("Time", Now)
		Next 
		
		' close the session
		objSessionSet.Close()
		
		' shutdown the SDK
		objMeter.Shutdown()
		
	End Sub
	
	Private Sub MeterSynchronous()
		Dim amount As Object
		
		Dim objSession As COMMeterLib.Session
		Dim objResult As COMMeterLib.Session
		Dim objMeter As COMMeterLib.Meter
		
		' Create the meter object
		objMeter = New COMMeterLib.Meter
		
		' start up the SDK
		objMeter.Startup()
		
		' Set the timeout and number of server retries
		objMeter.HTTPTimeout = 30
		objMeter.HTTPRetries = 1
		
		' priority, servername, port, secure, username, password
		objMeter.AddServer(0, txtServer.Text, COMMeterLib.__MIDL___MIDL_itf_COMMeter_0000_0004.DEFAULT_HTTP_PORT, False, "", "")
		
		' create a test session
		objSession = objMeter.CreateSession("metratech.com/TestService")
		
		' Request a response session
		objSession.RequestResponse = True
		
		' set the session properties
		objSession.InitProperty("AccountName", txtAccount.Text)
		objSession.InitProperty("Description", txtDescription.Text)
		objSession.InitProperty("Units", CDbl(txtUnits.Text))
		objSession.InitProperty("Time", Now)
		
		' close the session
		objSession.Close()
		
		' Get the result session
		objResult = objSession.ResultSession
		
		' Get the property added by the test stage
		'UPGRADE_WARNING: Couldn't resolve default property of object objResult.GetProperty(). Click for more: 'ms-help://MS.VSCC/commoner/redir/redirect.htm?keyword="vbup1037"'
		'UPGRADE_WARNING: Couldn't resolve default property of object amount. Click for more: 'ms-help://MS.VSCC/commoner/redir/redirect.htm?keyword="vbup1037"'
		amount = objResult.GetProperty("_Amount", COMMeterLib.__MIDL___MIDL_itf_COMMeter_0252_0001.MTC_DT_DOUBLE)
		
		' Display the property
		'UPGRADE_WARNING: Couldn't resolve default property of object amount. Click for more: 'ms-help://MS.VSCC/commoner/redir/redirect.htm?keyword="vbup1037"'
		txtAmount.Text = amount
		
		' shutdown the SDK
		objMeter.Shutdown()
		
	End Sub
	
	Private Sub MeterSecure()
		
		Dim objSession As COMMeterLib.Session
		Dim objMeter As COMMeterLib.Meter
		
		' Create the meter object
		objMeter = New COMMeterLib.Meter
		
		' start up the SDK
		objMeter.Startup()
		
		' Set the timeout and number of server retries
		objMeter.HTTPTimeout = 30
		objMeter.HTTPRetries = 1
		
		' priority, servername, port, secure, username, password
		objMeter.AddServer(0, txtServer.Text, COMMeterLib.__MIDL___MIDL_itf_COMMeter_0000_0004.DEFAULT_HTTPS_PORT, True, txtUser.Text, txtPassword.Text)
		
		' create a test session
		objSession = objMeter.CreateSession("metratech.com/TestService")
		
		' set the session properties
		objSession.InitProperty("AccountName", txtAccount.Text)
		objSession.InitProperty("Description", txtDescription.Text)
		objSession.InitProperty("Units", CDbl(txtUnits.Text))
		objSession.InitProperty("Time", Now)
		
		' close the session
		objSession.Close()
		
		' shutdown the SDK
		objMeter.Shutdown()
		
	End Sub
	
	Private Sub MeterLocalMode()
		Dim i As Object
		
		Dim objSession As COMMeterLib.Session
		Dim objMeter As COMMeterLib.Meter
		
		' Create the meter object
		objMeter = New COMMeterLib.Meter
		
		' start up the SDK
		objMeter.Startup()
		
		' Set the timeout and number of server retries
		objMeter.HTTPTimeout = 30
		objMeter.HTTPRetries = 1
		
		' priority, servername, port, secure, username, password
		objMeter.AddServer(0, txtServer.Text, COMMeterLib.__MIDL___MIDL_itf_COMMeter_0000_0004.DEFAULT_HTTP_PORT, False, "", "")
		
		' turn on local mode by setting a file
		objMeter.LocalModePath = "C:\temp\comlocalmode.dat"
		
		' Meter 10 test sessions locally
		For i = 1 To 10
			' create a test session
			objSession = objMeter.CreateSession("metratech.com/TestService")
			
			' set the session properties
			objSession.InitProperty("AccountName", txtAccount.Text)
			objSession.InitProperty("Description", txtDescription.Text)
			objSession.InitProperty("Units", CDbl(txtUnits.Text))
			objSession.InitProperty("Time", Now)
			
			' close the session
			objSession.Close()
		Next i
		
		' turn off local mode
		objMeter.LocalModePath = ""
		
		' set a journal for replay
		' this is used to keep track of the status
		objMeter.MeterJournal = "c:\temp\meterstore.dat"
		
		' play it back
		objMeter.MeterFile("C:\temp\comlocalmode.dat")
		
		' shutdown the SDK
		objMeter.Shutdown()
		
		
	End Sub
	
	
	Private Sub MeterFailover()
		
		Dim objSession As COMMeterLib.Session
		Dim objMeter As COMMeterLib.Meter
		
		' Create the meter object
		objMeter = New COMMeterLib.Meter
		
		' start up the SDK
		objMeter.Startup()
		
		' Set the timeout and number of server retries
		objMeter.HTTPTimeout = 30
		objMeter.HTTPRetries = 2
		
		' add a primary server
		' priority, servername, port, secure, username, password
		objMeter.AddServer(5, "myserver", COMMeterLib.__MIDL___MIDL_itf_COMMeter_0000_0004.DEFAULT_HTTP_PORT, False, "", "")
		
		' add a backup server
		' priority, servername, port, secure, username, password
		objMeter.AddServer(0, txtServer.Text, COMMeterLib.__MIDL___MIDL_itf_COMMeter_0000_0004.DEFAULT_HTTP_PORT, False, "", "")
		
		
		' create a test session
		objSession = objMeter.CreateSession("metratech.com/TestService")
		
		' set the session properties
		objSession.InitProperty("AccountName", txtAccount.Text)
		objSession.InitProperty("Description", txtDescription.Text)
		objSession.InitProperty("Units", CDbl(txtUnits.Text))
		objSession.InitProperty("Time", Now)
		
		' close the session
		objSession.Close()
		
		' shutdown the SDK
		objMeter.Shutdown()
		
	End Sub
	
	Private Sub MeterCompound()
		Dim i As Object
		
		Dim objParent As COMMeterLib.Session
		Dim objChild As COMMeterLib.Session
		Dim objMeter As COMMeterLib.Meter
		
		' Create the meter object
		objMeter = New COMMeterLib.Meter
		
		' start up the SDK
		objMeter.Startup()
		
		' Set the timeout and number of server retries
		objMeter.HTTPTimeout = 30
		objMeter.HTTPRetries = 1
		
		' priority, servername, port, secure, username, password
		objMeter.AddServer(0, txtServer.Text, COMMeterLib.__MIDL___MIDL_itf_COMMeter_0000_0004.DEFAULT_HTTP_PORT, False, "", "")
		
		' create the parent session
		objParent = objMeter.CreateSession("metratech.com/testparent")
		
		' init the properties in the parent
		
		objParent.InitProperty("AccountName", txtAccount.Text)
		objParent.InitProperty("Description", txtDescription.Text)
		objParent.InitProperty("Time", Now)
		
		' create some test children
		For i = 1 To 5
			' create a child session
			objChild = objParent.CreateChildSession("metratech.com/TestService")
			
			' set the session properties
			objChild.InitProperty("AccountName", txtAccount.Text)
			objChild.InitProperty("Description", txtDescription.Text)
			objChild.InitProperty("Units", CDbl(txtUnits.Text))
			objChild.InitProperty("Time", Now)
			
		Next i
		
		' close the parent which will close all the children
		objParent.Close()
		
		' shutdown the SDK
		objMeter.Shutdown()
		
	End Sub
	
	
	Private Sub btnCompound_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles btnCompound.Click
		MeterCompound()
		MsgBox("Compound metering completed")
	End Sub
	
	Private Sub btnFail_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles btnFail.Click
		MeterFailover()
		MsgBox("Failover metering completed")
	End Sub
	
	Private Sub btnLocalMode_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles btnLocalMode.Click
		MeterLocalMode()
		MsgBox("Local Mode metering completed")
	End Sub
	
	Private Sub btnSecure_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles btnSecure.Click
		MeterSecure()
		MsgBox("Secure metering completed")
	End Sub
	
	Private Sub btnSessionSet_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles btnSessionSet.Click
		MeterSessionSet()
		MsgBox("SessionSet metering completed")
	End Sub
	
	Private Sub btnSimple_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles btnSimple.Click
		MeterSimple()
		MsgBox("Simple metering completed")
	End Sub
	
	Private Sub btnSynchronous_Click(ByVal eventSender As System.Object, ByVal eventArgs As System.EventArgs) Handles btnSynchronous.Click
		MeterSynchronous()
		MsgBox("Sychronous metering completed")
	End Sub
End Class