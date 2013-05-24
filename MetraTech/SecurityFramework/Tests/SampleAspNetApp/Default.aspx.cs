/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Core.Common.Logging;
using MetraTech.SecurityFramework.Core.Detector;
using MetraTech.SecurityFramework.Core.SecurityMonitor;
using MetraTech.SecurityFramework.Core.SecurityMonitor.Policy;

namespace SampleAspNetApp
{
    public partial class _Default : System.Web.UI.Page, ISecurityPolicyActionHandler
    {
        /// <summary>
        /// This is method for QAs.
        /// </summary>
        public void Handle(PolicyAction policyAction, ISecurityEvent securityEvent)
        {
            NotifyUserPolicyAction action = policyAction as NotifyUserPolicyAction;
            if (action != null)
            {
                custPolicy.ErrorMessage = action.Message;
                custPolicy.IsValid = false;
            }

            //RedirectOperationPolicyAction redirectAction = policyAction as RedirectOperationPolicyAction;
            //if (redirectAction != null)
            //{
            //    Response.Redirect(redirectAction.DestinationPath);
            //}
            lblPolicyActions.Text += string.Format(
                "{1}Action type: {0}",
                policyAction.ActionType,
                string.IsNullOrEmpty(lblPolicyActions.Text) ? string.Empty : ",<br/>");
        }

        protected void Page_Init(object sender, EventArgs e)
        {
            if (SecurityKernel.IsSecurityMonitorEnabled && SecurityKernel.SecurityMonitor.IsRuntimeApiEnabled)
            {
                SecurityKernel.SecurityMonitor.Api.AddPolicyActionHandler(
                    "MyApp",
                    SecurityPolicyActionType.BlockAddress |
                    SecurityPolicyActionType.BlockOperation |
                    SecurityPolicyActionType.BlockUser |
                    SecurityPolicyActionType.ChangeSessionParameter |
                    SecurityPolicyActionType.Log |
                    SecurityPolicyActionType.RedirectOperation |
                    SecurityPolicyActionType.RedirectUser |
                    SecurityPolicyActionType.LogoutUser |
                    SecurityPolicyActionType.SendAdminNotification |
                    SecurityPolicyActionType.SendSecurityWarningToUser,
                    this);
            }
        }

        protected void Page_Unload(object sender, EventArgs e)
        {
            if (SecurityKernel.IsSecurityMonitorEnabled && SecurityKernel.SecurityMonitor.IsRuntimeApiEnabled)
            {
                SecurityKernel.SecurityMonitor.Api.RemovePolicyActionHandler("MyApp");
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Debug.WriteLine("Page_Load");
        }

        protected void OnProcessData(object sender, EventArgs e)
        {
            Debug.WriteLine("OnProcessData");
            if (Page.IsValid)
            {
                try
                {
                    string qsNameParam = Request.QueryString["name"];
                    string rawUrl = Request.RawUrl;
                    string inputText = TextBoxInputData.Text;

                    if (!string.IsNullOrEmpty(rawUrl))
                    {
                        rawUrl.DetectSql();
                        rawUrl.DetectXss();
                    }

                    if (!string.IsNullOrEmpty(qsNameParam))
                    {
                        qsNameParam.DetectBad();
                    }

                    LabelOutputField.Text = inputText.EncodeForHtml();
                    LabelRequestUrl.Text = rawUrl.EncodeForHtml();
                }
                catch (DetectorInputDataException x)
                {
                    Debug.WriteLine("Security Framework Exception: Engine ID - " + x.Message);
                    x.Report();
                }
                catch (Exception x)
                {
                    Debug.WriteLine(x.Message);
                }
            }
            else
            {
                Debug.WriteLine("Page is not valid");
            }
        }

        protected void InputTextCustomValidator_ServerValidate(object source, ServerValidateEventArgs args)
        {
            Debug.WriteLine("InputTextCustomValidator_ServerValidate");

            args.IsValid = false;
            string str = args.Value;
            if (string.IsNullOrEmpty(str))
                return;

            Debug.WriteLine("InputText value: " + str);

            try
            {
                args.IsValid = true;
                str.DetectBad();
            }
            catch (DetectorInputDataException x)
            {
                args.IsValid = false;
                Debug.WriteLine("Security Framework Exception: Engine ID - " + x.Message);
                x.Report();
            }
            catch (Exception x)
            {
                Debug.WriteLine(x.Message);
                if (!LoggingHelper.Log(x))
                {
                    throw;
                }
            }
        }

        protected void btnThrow_Click(object sender, EventArgs e)
        {
            throw new SecurityFrameworkException("Error loggin test");
        }

        /// <summary>
        /// This is method for QAs.
        /// </summary>
        protected void btnGenerateEvent_Click(object sender, EventArgs e)
        {
            TestSecurityEventCreation();
        }

        /// <summary>
        /// This is method for QAs.
        /// </summary>
        private void TestSecurityEventCreation()
        {
            ISecurityEvent securityEvent =
                new MetraTech.SecurityFramework.Core.SecurityMonitor.SecurityEvent()
                {
                    EventType = SecurityEventType.SessionEventType,
                    SubsystemName = SecurityKernel.Detector.SubsystemName,
                    CategoryName = Convert.ToString(DetectorEngineCategory.Xss),
                    ClientAddress = System.Net.IPAddress.Loopback,
                    ClientInfo = System.Diagnostics.Process.GetCurrentProcess().ProcessName,
                    HostName = System.Diagnostics.Process.GetCurrentProcess().MachineName,
                    Message = "Test message",
                    Path = "TestSecurityEventCreation()",
                    SessionId = Session.SessionID,
                    TimeStamp = DateTime.Now,
                    UserIdentity = Thread.CurrentPrincipal.Identity.Name,
                    StackTrace = new System.Diagnostics.StackTrace().ToString()
                };

            SecurityKernel.SecurityMonitor.Api.ReportEvent(securityEvent);
        }
    }
}
