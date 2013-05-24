#define Win32
using Microsoft.VisualBasic;
using System.Data;
using Microsoft.VisualBasic.Compatibility;
using System;
using System.Collections;
using System.Windows.Forms;
using System.Diagnostics;
using System.Drawing;

namespace Project1
{
	internal class Form1 : System.Windows.Forms.Form
	{
		
		[STAThread]
		static void Main()
		{
			Application.Run(new Form1());
		}
		#region "Windows Form Designer generated code "
		public Form1()
		{
			if (m_vb6FormDefInstance == null)
			{
				if (m_InitializingDefInstance)
				{
					m_vb6FormDefInstance = this;
				}
				else
				{
					try
					{
						//For the start-up form, the first instance created is the default instance.
						if (System.Reflection.Assembly.GetExecutingAssembly().EntryPoint.DeclaringType == this.GetType())
						{
							m_vb6FormDefInstance = this;
						}
					}
					catch
					{
					}
				}
			}
			//This call is required by the Windows Form Designer.
			InitializeComponent();
		}
		//Form overrides dispose to clean up the component list.
		protected override void Dispose(bool Disposing)
		{
			if (Disposing)
			{
				if (components != null)
				{
					components.Dispose();
				}
			}
			base.Dispose(Disposing);
		}
		//Required by the Windows Form Designer
		private System.ComponentModel.Container components = null;
		public System.Windows.Forms.ToolTip ToolTip1;
		public System.Windows.Forms.CheckBox ckSessionSet;
		public System.Windows.Forms.TextBox txtSessions;
		public System.Windows.Forms.ComboBox cbMeterType;
		public System.Windows.Forms.TextBox txtUser;
		public System.Windows.Forms.TextBox txtPassword;
		public System.Windows.Forms.TextBox txtAmount;
		public System.Windows.Forms.Button btMeter;
		public System.Windows.Forms.TextBox txtUnits;
		public System.Windows.Forms.TextBox txtDescription;
		public System.Windows.Forms.TextBox txtAccount;
		public System.Windows.Forms.TextBox txtServer;
		//NOTE: The following procedure is required by the Windows Form Designer
		//It can be modified using the Windows Form Designer.
		//Do not modify it using the code editor.
		[System.Diagnostics.DebuggerStepThrough()]private void InitializeComponent()
		{
			System.Resources.ResourceManager resources = new System.Resources.ResourceManager(typeof(Form1));
			this.components = new System.ComponentModel.Container();
			base.Load += new System.EventHandler(Form1_Load);
			this.ToolTip1 = new System.Windows.Forms.ToolTip(components);
			this.ToolTip1.Active = true;
			this.ckSessionSet = new System.Windows.Forms.CheckBox();
			this.ckSessionSet.CheckStateChanged += new System.EventHandler(ckSessionSet_CheckStateChanged);
			this.txtSessions = new System.Windows.Forms.TextBox();
			this.txtSessions.TextChanged += new System.EventHandler(txtSessions_TextChanged);
			this.cbMeterType = new System.Windows.Forms.ComboBox();
			this.cbMeterType.SelectedIndexChanged += new System.EventHandler(cbMeterType_SelectedIndexChanged);
			this.txtUser = new System.Windows.Forms.TextBox();
			this.txtUser.Enter += new System.EventHandler(txtUser_Enter);
			this.txtPassword = new System.Windows.Forms.TextBox();
			this.txtPassword.Enter += new System.EventHandler(txtPassword_Enter);
			this.txtAmount = new System.Windows.Forms.TextBox();
			this.txtAmount.Enter += new System.EventHandler(txtAmount_Enter);
			this.btMeter = new System.Windows.Forms.Button();
			this.btMeter.Click += new System.EventHandler(btMeter_Click);
			this.txtUnits = new System.Windows.Forms.TextBox();
			this.txtUnits.Enter += new System.EventHandler(txtUnits_Enter);
			this.txtDescription = new System.Windows.Forms.TextBox();
			this.txtDescription.Enter += new System.EventHandler(txtDescription_Enter);
			this.txtAccount = new System.Windows.Forms.TextBox();
			this.txtAccount.Enter += new System.EventHandler(txtAccount_Enter);
			this.txtServer = new System.Windows.Forms.TextBox();
			this.txtServer.Enter += new System.EventHandler(txtServer_Enter);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.Text = "COM SDK Client";
			this.ClientSize = new System.Drawing.Size(306, 255);
			this.Location = new System.Drawing.Point(3, 24);
			this.MaximizeBox = false;
			this.MinimizeBox = false;
			this.StartPosition = System.Windows.Forms.FormStartPosition.WindowsDefaultLocation;
			this.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.BackColor = System.Drawing.SystemColors.Control;
			this.ControlBox = true;
			this.Enabled = true;
			this.KeyPreview = false;
			this.Cursor = System.Windows.Forms.Cursors.Default;
			this.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.ShowInTaskbar = true;
			this.HelpButton = false;
			this.WindowState = System.Windows.Forms.FormWindowState.Normal;
			this.Name = "Form1";
			this.ckSessionSet.Text = "Use Session Sets";
			this.ckSessionSet.Size = new System.Drawing.Size(105, 25);
			this.ckSessionSet.Location = new System.Drawing.Point(64, 208);
			this.ckSessionSet.TabIndex = 10;
			this.ckSessionSet.CheckState = System.Windows.Forms.CheckState.Checked;
			this.ckSessionSet.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.ckSessionSet.CheckAlign = System.Drawing.ContentAlignment.MiddleLeft;
			this.ckSessionSet.BackColor = System.Drawing.SystemColors.Control;
			this.ckSessionSet.CausesValidation = true;
			this.ckSessionSet.Enabled = true;
			this.ckSessionSet.ForeColor = System.Drawing.SystemColors.ControlText;
			this.ckSessionSet.Cursor = System.Windows.Forms.Cursors.Default;
			this.ckSessionSet.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.ckSessionSet.Appearance = System.Windows.Forms.Appearance.Normal;
			this.ckSessionSet.TabStop = true;
			this.ckSessionSet.Visible = true;
			this.ckSessionSet.Name = "ckSessionSet";
			this.txtSessions.AutoSize = false;
			this.txtSessions.Size = new System.Drawing.Size(41, 25);
			this.txtSessions.Location = new System.Drawing.Point(16, 208);
			this.txtSessions.TabIndex = 9;
			this.txtSessions.Text = "10";
			this.txtSessions.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.txtSessions.AcceptsReturn = true;
			this.txtSessions.TextAlign = System.Windows.Forms.HorizontalAlignment.Left;
			this.txtSessions.BackColor = System.Drawing.SystemColors.Window;
			this.txtSessions.CausesValidation = true;
			this.txtSessions.Enabled = true;
			this.txtSessions.ForeColor = System.Drawing.SystemColors.WindowText;
			this.txtSessions.HideSelection = true;
			this.txtSessions.ReadOnly = false;
			this.txtSessions.MaxLength = 0;
			this.txtSessions.Cursor = System.Windows.Forms.Cursors.IBeam;
			this.txtSessions.Multiline = false;
			this.txtSessions.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.txtSessions.ScrollBars = System.Windows.Forms.ScrollBars.None;
			this.txtSessions.TabStop = true;
			this.txtSessions.Visible = true;
			this.txtSessions.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.txtSessions.Name = "txtSessions";
			this.cbMeterType.Size = new System.Drawing.Size(121, 21);
			this.cbMeterType.Location = new System.Drawing.Point(176, 16);
			this.cbMeterType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			this.cbMeterType.TabIndex = 7;
			this.cbMeterType.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.cbMeterType.BackColor = System.Drawing.SystemColors.Window;
			this.cbMeterType.CausesValidation = true;
			this.cbMeterType.Enabled = true;
			this.cbMeterType.ForeColor = System.Drawing.SystemColors.WindowText;
			this.cbMeterType.IntegralHeight = true;
			this.cbMeterType.Cursor = System.Windows.Forms.Cursors.Default;
			this.cbMeterType.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.cbMeterType.Sorted = false;
			this.cbMeterType.TabStop = true;
			this.cbMeterType.Visible = true;
			this.cbMeterType.Name = "cbMeterType";
			this.txtUser.AutoSize = false;
			this.txtUser.Size = new System.Drawing.Size(113, 33);
			this.txtUser.Location = new System.Drawing.Point(176, 64);
			this.txtUser.TabIndex = 5;
			this.txtUser.Text = "Username";
			this.txtUser.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.txtUser.AcceptsReturn = true;
			this.txtUser.TextAlign = System.Windows.Forms.HorizontalAlignment.Left;
			this.txtUser.BackColor = System.Drawing.SystemColors.Window;
			this.txtUser.CausesValidation = true;
			this.txtUser.Enabled = true;
			this.txtUser.ForeColor = System.Drawing.SystemColors.WindowText;
			this.txtUser.HideSelection = true;
			this.txtUser.ReadOnly = false;
			this.txtUser.MaxLength = 0;
			this.txtUser.Cursor = System.Windows.Forms.Cursors.IBeam;
			this.txtUser.Multiline = false;
			this.txtUser.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.txtUser.ScrollBars = System.Windows.Forms.ScrollBars.None;
			this.txtUser.TabStop = true;
			this.txtUser.Visible = true;
			this.txtUser.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.txtUser.Name = "txtUser";
			this.txtPassword.AutoSize = false;
			this.txtPassword.Size = new System.Drawing.Size(113, 33);
			this.txtPassword.Location = new System.Drawing.Point(176, 112);
			this.txtPassword.TabIndex = 6;
			this.txtPassword.Text = "Password";
			this.txtPassword.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.txtPassword.AcceptsReturn = true;
			this.txtPassword.TextAlign = System.Windows.Forms.HorizontalAlignment.Left;
			this.txtPassword.BackColor = System.Drawing.SystemColors.Window;
			this.txtPassword.CausesValidation = true;
			this.txtPassword.Enabled = true;
			this.txtPassword.ForeColor = System.Drawing.SystemColors.WindowText;
			this.txtPassword.HideSelection = true;
			this.txtPassword.ReadOnly = false;
			this.txtPassword.MaxLength = 0;
			this.txtPassword.Cursor = System.Windows.Forms.Cursors.IBeam;
			this.txtPassword.Multiline = false;
			this.txtPassword.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.txtPassword.ScrollBars = System.Windows.Forms.ScrollBars.None;
			this.txtPassword.TabStop = true;
			this.txtPassword.Visible = true;
			this.txtPassword.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.txtPassword.Name = "txtPassword";
			this.txtAmount.AutoSize = false;
			this.txtAmount.Size = new System.Drawing.Size(113, 33);
			this.txtAmount.Location = new System.Drawing.Point(176, 160);
			this.txtAmount.TabIndex = 4;
			this.txtAmount.Text = "Result";
			this.txtAmount.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.txtAmount.AcceptsReturn = true;
			this.txtAmount.TextAlign = System.Windows.Forms.HorizontalAlignment.Left;
			this.txtAmount.BackColor = System.Drawing.SystemColors.Window;
			this.txtAmount.CausesValidation = true;
			this.txtAmount.Enabled = true;
			this.txtAmount.ForeColor = System.Drawing.SystemColors.WindowText;
			this.txtAmount.HideSelection = true;
			this.txtAmount.ReadOnly = false;
			this.txtAmount.MaxLength = 0;
			this.txtAmount.Cursor = System.Windows.Forms.Cursors.IBeam;
			this.txtAmount.Multiline = false;
			this.txtAmount.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.txtAmount.ScrollBars = System.Windows.Forms.ScrollBars.None;
			this.txtAmount.TabStop = true;
			this.txtAmount.Visible = true;
			this.txtAmount.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.txtAmount.Name = "txtAmount";
			this.btMeter.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
			this.btMeter.Text = "Meter";
			this.AcceptButton = this.btMeter;
			this.btMeter.Size = new System.Drawing.Size(113, 33);
			this.btMeter.Location = new System.Drawing.Point(176, 208);
			this.btMeter.TabIndex = 8;
			this.btMeter.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.btMeter.BackColor = System.Drawing.SystemColors.Control;
			this.btMeter.CausesValidation = true;
			this.btMeter.Enabled = true;
			this.btMeter.ForeColor = System.Drawing.SystemColors.ControlText;
			this.btMeter.Cursor = System.Windows.Forms.Cursors.Default;
			this.btMeter.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.btMeter.TabStop = true;
			this.btMeter.Name = "btMeter";
			this.txtUnits.AutoSize = false;
			this.txtUnits.Size = new System.Drawing.Size(145, 33);
			this.txtUnits.Location = new System.Drawing.Point(16, 160);
			this.txtUnits.TabIndex = 3;
			this.txtUnits.Text = "Units";
			this.txtUnits.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.txtUnits.AcceptsReturn = true;
			this.txtUnits.TextAlign = System.Windows.Forms.HorizontalAlignment.Left;
			this.txtUnits.BackColor = System.Drawing.SystemColors.Window;
			this.txtUnits.CausesValidation = true;
			this.txtUnits.Enabled = true;
			this.txtUnits.ForeColor = System.Drawing.SystemColors.WindowText;
			this.txtUnits.HideSelection = true;
			this.txtUnits.ReadOnly = false;
			this.txtUnits.MaxLength = 0;
			this.txtUnits.Cursor = System.Windows.Forms.Cursors.IBeam;
			this.txtUnits.Multiline = false;
			this.txtUnits.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.txtUnits.ScrollBars = System.Windows.Forms.ScrollBars.None;
			this.txtUnits.TabStop = true;
			this.txtUnits.Visible = true;
			this.txtUnits.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.txtUnits.Name = "txtUnits";
			this.txtDescription.AutoSize = false;
			this.txtDescription.Size = new System.Drawing.Size(145, 33);
			this.txtDescription.Location = new System.Drawing.Point(16, 112);
			this.txtDescription.TabIndex = 2;
			this.txtDescription.Text = "Description";
			this.txtDescription.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.txtDescription.AcceptsReturn = true;
			this.txtDescription.TextAlign = System.Windows.Forms.HorizontalAlignment.Left;
			this.txtDescription.BackColor = System.Drawing.SystemColors.Window;
			this.txtDescription.CausesValidation = true;
			this.txtDescription.Enabled = true;
			this.txtDescription.ForeColor = System.Drawing.SystemColors.WindowText;
			this.txtDescription.HideSelection = true;
			this.txtDescription.ReadOnly = false;
			this.txtDescription.MaxLength = 0;
			this.txtDescription.Cursor = System.Windows.Forms.Cursors.IBeam;
			this.txtDescription.Multiline = false;
			this.txtDescription.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.txtDescription.ScrollBars = System.Windows.Forms.ScrollBars.None;
			this.txtDescription.TabStop = true;
			this.txtDescription.Visible = true;
			this.txtDescription.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.txtDescription.Name = "txtDescription";
			this.txtAccount.AutoSize = false;
			this.txtAccount.Size = new System.Drawing.Size(145, 33);
			this.txtAccount.Location = new System.Drawing.Point(16, 64);
			this.txtAccount.TabIndex = 1;
			this.txtAccount.Text = "Account Name";
			this.txtAccount.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.txtAccount.AcceptsReturn = true;
			this.txtAccount.TextAlign = System.Windows.Forms.HorizontalAlignment.Left;
			this.txtAccount.BackColor = System.Drawing.SystemColors.Window;
			this.txtAccount.CausesValidation = true;
			this.txtAccount.Enabled = true;
			this.txtAccount.ForeColor = System.Drawing.SystemColors.WindowText;
			this.txtAccount.HideSelection = true;
			this.txtAccount.ReadOnly = false;
			this.txtAccount.MaxLength = 0;
			this.txtAccount.Cursor = System.Windows.Forms.Cursors.IBeam;
			this.txtAccount.Multiline = false;
			this.txtAccount.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.txtAccount.ScrollBars = System.Windows.Forms.ScrollBars.None;
			this.txtAccount.TabStop = true;
			this.txtAccount.Visible = true;
			this.txtAccount.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.txtAccount.Name = "txtAccount";
			this.txtServer.AutoSize = false;
			this.txtServer.Size = new System.Drawing.Size(145, 33);
			this.txtServer.Location = new System.Drawing.Point(16, 16);
			this.txtServer.TabIndex = 0;
			this.txtServer.Text = "Server Name";
			this.txtServer.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.txtServer.AcceptsReturn = true;
			this.txtServer.TextAlign = System.Windows.Forms.HorizontalAlignment.Left;
			this.txtServer.BackColor = System.Drawing.SystemColors.Window;
			this.txtServer.CausesValidation = true;
			this.txtServer.Enabled = true;
			this.txtServer.ForeColor = System.Drawing.SystemColors.WindowText;
			this.txtServer.HideSelection = true;
			this.txtServer.ReadOnly = false;
			this.txtServer.MaxLength = 0;
			this.txtServer.Cursor = System.Windows.Forms.Cursors.IBeam;
			this.txtServer.Multiline = false;
			this.txtServer.RightToLeft = System.Windows.Forms.RightToLeft.No;
			this.txtServer.ScrollBars = System.Windows.Forms.ScrollBars.None;
			this.txtServer.TabStop = true;
			this.txtServer.Visible = true;
			this.txtServer.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
			this.txtServer.Name = "txtServer";
			this.Controls.Add(ckSessionSet);
			this.Controls.Add(txtSessions);
			this.Controls.Add(cbMeterType);
			this.Controls.Add(txtUser);
			this.Controls.Add(txtPassword);
			this.Controls.Add(txtAmount);
			this.Controls.Add(btMeter);
			this.Controls.Add(txtUnits);
			this.Controls.Add(txtDescription);
			this.Controls.Add(txtAccount);
			this.Controls.Add(txtServer);
		}
		#endregion
		#region "Upgrade Support "
		private static Form1 m_vb6FormDefInstance;
		private static bool m_InitializingDefInstance;
		public static Form1 DefInstance
		{
			get
			{
				Form1 returnValue;
				if (m_vb6FormDefInstance == null || m_vb6FormDefInstance.IsDisposed)
				{
					m_InitializingDefInstance = true;
					m_vb6FormDefInstance = new Form1();
					m_InitializingDefInstance = false;
				}
				returnValue = m_vb6FormDefInstance;
				return returnValue;
			}
			set
			{
				m_vb6FormDefInstance = value;
			}
		}
		#endregion
		//***************************************************************************
		//* Copyright 2000-2006 by MetraTech Corporation
		//* All rights reserved.
		//*
		//* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
		//* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
		//* example, but not limitation, MetraTech Corporation MAKES NO
		//* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
		//* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
		//* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
		//* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
		//*
		//* Title to copyright in this software and any associated
		//* documentation shall at all times remain with MetraTech Corporation,
		//* and USER agrees to preserve the same.
		//*
		//***************************************************************************/
		
		
		private COMMeterLib.SessionSet objSessionSet;
		private COMMeterLib.Session objSession;
		private COMMeterLib.Session objResultSession;
		private COMMeterLib.Session objParent;
		private COMMeterLib.Meter objMeter;
		
		private void Form1_Load(System.Object eventSender, System.EventArgs eventArgs)
		{
			cbMeterType.Items.Add("Atomic");
			cbMeterType.Items.Add("Compound");
			cbMeterType.Items.Add("Secure");
			cbMeterType.Items.Add("Synchronous");
			cbMeterType.SelectedIndex = 0;
		}
		
		private void cbMeterType_SelectedIndexChanged(System.Object eventSender, System.EventArgs eventArgs)
		{
			txtUser.Visible = false;
			txtPassword.Visible = false;
			txtAmount.Visible = false;
			txtSessions.Visible = false;
			if (cbMeterType.Text == "Atomic")
			{
				Text = "COM SDK Client: Atomic";
			}
			if (cbMeterType.Text == "Compound")
			{
				Text = "COM SDK Client: Compound";
			}
			if (cbMeterType.Text == "Secure")
			{
				Text = "COM SDK Client: Secure";
				txtUser.Visible = true;
				txtPassword.Visible = true;
			}
			if (cbMeterType.Text == "Synchronous")
			{
				txtAmount.Visible = true;
				Text = "COM SDK Client: Synchronous";
			}
			if (System.Convert.ToInt32(ckSessionSet.CheckState) == 1)
			{
				Text = Text + " with " + txtSessions.Text + "-Session Set";
				txtSessions.Visible = true;
			}
		}
		
		private void ckSessionSet_CheckStateChanged(System.Object eventSender, System.EventArgs eventArgs)
		{
			cbMeterType_SelectedIndexChanged(cbMeterType, new System.EventArgs());
		}
		
		private void btMeter_Click(System.Object eventSender, System.EventArgs eventArgs)
		{
			if (Conversion.Val(txtUnits.Text) / 1 > 0)
			{
				//nothing
			}
			else
			{
				Interaction.MsgBox("Will meter with 100 units.", MsgBoxStyle.Information, "COM SDK Client");
				txtUnits.Text = "100";
				this.Refresh();
			}
			if (cbMeterType.Text == "Atomic")
			{
				MeterAtomic();
			}
			if (cbMeterType.Text == "Compound")
			{
				MeterCompound();
			}
			if (cbMeterType.Text == "Secure")
			{
				MeterSecure();
			}
			if (cbMeterType.Text == "Synchronous")
			{
				MeterSynchronous();
			}
		}
		
		private void Initialize()
		{
			// Create the meter object
			objMeter = new COMMeterLib.Meter();
			
			// start up the SDK
			objMeter.Startup();
			
			// Set the timeout and number of server retries
			objMeter.HTTPTimeout = 30;
			objMeter.HTTPRetries = 1;
		}
		
		private void TestSession()
		{
			// create a test session
			objSession = objMeter.CreateSession("metratech.com/TestService");
			
			if (cbMeterType.Text == "Synchronous")
			{
				//   request a response session
				objSession.RequestResponse = true;
			}
			
			// set the session properties
			objSession.InitProperty("AccountName", txtAccount.Text);
			objSession.InitProperty("Description", txtDescription.Text);
			objSession.InitProperty("Time", DateTime.Now);
			objSession.InitProperty("Units", System.Convert.ToDouble(txtUnits.Text));
			if (cbMeterType.Text != "Compound")
			{
				
			}
			else
			{
				CallChildren();
			}
			
			// Close the session
			objSession.Close();
			
			// Shutdown the SDK
			objMeter.Shutdown();
		}
		
		private void TestSessionSet()
		{
			
			short nSessions;
			short i;
			
			// create a session set to hold the test sessions
			objSessionSet = objMeter.CreateSessionSet();
			
			nSessions = System.Convert.ToInt16(Conversion.Val(txtSessions.Text));
			
			for (i = 1; i <= nSessions; i++) //Create the test sessions in the set
			{
				objSession = objSessionSet.CreateSession("metratech.com/TestService");
				// set the session properties
				if (cbMeterType.Text == "Synchronous")
				{
					//   request a response session
					objSession.RequestResponse = true;
				}
				objSession.InitProperty("AccountName", txtAccount.Text);
				objSession.InitProperty("Description", txtDescription.Text);
				objSession.InitProperty("Units", System.Convert.ToDouble(txtUnits.Text));
				objSession.InitProperty("Time", DateTime.Now);
			}
			
			// close the session
			objSessionSet.Close();
			
			// Shutdown the SDK
			objMeter.Shutdown();
		}
		
		private void MeterAtomic()
		{
			try
			{
				
				Initialize();
				
				// priority, servername, port, secure, username, password
				objMeter.AddServer(0, txtServer.Text, (COMMeterLib.PortNumber) COMMeterLib.PortNumber.DEFAULT_HTTP_PORT, System.Convert.ToInt32(false), "", "");
				
				if (System.Convert.ToInt32(ckSessionSet.CheckState) == 1)
				{
					TestSessionSet();
				}
				else
				{
					TestSession();
				}
				
			}
			catch (System.Exception excep)
			{
				Interaction.MsgBox(excep.Message,MsgBoxStyle.Exclamation ,"COM SDK Client");
				return;
			}
			Interaction.MsgBox("Metering Complete", MsgBoxStyle.Information, "COM SDK Client");
		}
		
		private void MeterCompound()
		{
			try
			{
				//				short i;
				
				Initialize();
				
				// priority, servername, port, secure, username, password
				objMeter.AddServer(0, txtServer.Text, (COMMeterLib.PortNumber) COMMeterLib.PortNumber.DEFAULT_HTTP_PORT, System.Convert.ToInt32(false), "", "");
				
				// create the parent session
				objParent = objMeter.CreateSession("metratech.com/testparent");
				
				if (System.Convert.ToInt32(ckSessionSet.CheckState) == 1)
				{
					TestSessionSet();
				}
				else
				{
					TestSession();
				}
				
			}
			catch (System.Exception excep)
			{
				Interaction.MsgBox(excep.Message,MsgBoxStyle.Exclamation ,"COM SDK Client");
				return;
			}
			Interaction.MsgBox("Metering Complete", MsgBoxStyle.Information, "COM SDK Client");
		}
		
		private void CallChildren()
		{
			COMMeterLib.Session objChild;
			short i;
			// create some test children
			for (i = 1; i <= 5; i++)
			{
				// create a child session
				objChild = objParent.CreateChildSession("metratech.com/TestService");
				
				// set the session properties
				objChild.InitProperty("AccountName", txtAccount.Text);
				objChild.InitProperty("Description", txtDescription.Text);
				objChild.InitProperty("Units", System.Convert.ToDouble(txtUnits.Text));
				objChild.InitProperty("Time", DateTime.Now);
			}
		}
		
		private void MeterSecure()
		{
			try
			{
				Initialize();
				
				// priority, servername, port, secure, username, password
				objMeter.AddServer(0, txtServer.Text, (COMMeterLib.PortNumber) COMMeterLib.PortNumber.DEFAULT_HTTPS_PORT, System.Convert.ToInt32(true), txtUser.Text, txtPassword.Text);
				
				if (System.Convert.ToInt32(ckSessionSet.CheckState) == 1)
				{
					TestSessionSet();
				}
				else
				{
					TestSession();
				}
				
			}
			catch (System.Exception excep)
			{
				Interaction.MsgBox(excep.Message,MsgBoxStyle.Exclamation ,"COM SDK Client");
				return;
			}
			Interaction.MsgBox("Metering Complete", MsgBoxStyle.Information, "COM SDK Client");
		}
		
		private void MeterSynchronous()
		{
			try
			{
				//   Dim objMeter As Meter
				double amount;
				
				Initialize();
				
				// priority, servername, port, secure, username, password
				objMeter.AddServer(0, txtServer.Text, (COMMeterLib.PortNumber) COMMeterLib.PortNumber.DEFAULT_HTTP_PORT, System.Convert.ToInt32(false), "", "");
				
				if (System.Convert.ToInt32(ckSessionSet.CheckState) == 1)
				{
					TestSessionSet();
				}
				else
				{
					TestSession();
				}
				
				// Get the result session
				objResultSession = objSession.ResultSession;
				
				// Get the property added by the test stage
				//UPGRADE_WARNING: Couldn't resolve default property of object objResultSession.GetProperty(). Click for more: 'ms-help://MS.VSCC.2003/commoner/redir/redirect.htm?keyword="vbup1037"'
				amount = System.Convert.ToDouble(objResultSession.GetProperty("_Amount", COMMeterLib.DataType.MTC_DT_DOUBLE));
				
				// Display the property
				txtAmount.Text = amount.ToString();
				
			}
			catch (System.Exception excep)
			{
				Interaction.MsgBox(excep.Message,MsgBoxStyle.Exclamation ,"COM SDK Client");
				return;
			}
			Interaction.MsgBox("Metering Complete", MsgBoxStyle.Information, "COM SDK Client");
		}
		
		private void txtAccount_Enter(System.Object eventSender, System.EventArgs eventArgs)
		{
			txtAccount.SelectionLength = txtAccount.Text.Length;
		}
		private void txtAmount_Enter(System.Object eventSender, System.EventArgs eventArgs)
		{
			txtAmount.SelectionLength = txtAmount.Text.Length;
		}
		private void txtDescription_Enter(System.Object eventSender, System.EventArgs eventArgs)
		{
			txtDescription.SelectionLength = txtDescription.Text.Length;
		}
		private void txtPassword_Enter(System.Object eventSender, System.EventArgs eventArgs)
		{
			txtPassword.SelectionLength = txtPassword.Text.Length;
		}
		private void txtServer_Enter(System.Object eventSender, System.EventArgs eventArgs)
		{
			txtServer.SelectionLength = txtServer.Text.Length;
		}
		private void txtSessions_TextChanged(System.Object eventSender, System.EventArgs eventArgs)
		{
			cbMeterType_SelectedIndexChanged(cbMeterType, new System.EventArgs());
		}
		private void txtUnits_Enter(System.Object eventSender, System.EventArgs eventArgs)
		{
			txtUnits.SelectionLength = txtUnits.Text.Length;
		}
		private void txtUser_Enter(System.Object eventSender, System.EventArgs eventArgs)
		{
			txtUser.SelectionLength = txtUser.Text.Length;
		}
	}
}
