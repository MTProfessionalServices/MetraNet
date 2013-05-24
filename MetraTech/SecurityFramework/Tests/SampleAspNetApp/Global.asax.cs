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
using System.Collections;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.Xml.Linq;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common.Logging;
using MetraTech.SecurityFramework.Core.SecurityMonitor;
using MetraTech.SecurityFramework.Serialization;

namespace SampleAspNetApp
{
    public class Global : System.Web.HttpApplication
    {

        protected void Application_Start(object sender, EventArgs e)
        {
            Debug.WriteLine("Application_Start");

            if (Application["SecurityFrameworkIsOn"] == null)
            {
                try
                {
                    //SecurityPolicyActionHandler mySecPolicyActionHandler = new SecurityPolicyActionHandler();
                    //string sfPropsStoreLocation = Directory.GetCurrentDirectory() + @"\MtSecurityFramework.xml";
                    string sfPropsStoreLocation = Server.MapPath("bin/MtSfConfigurationLoader.xml");

					SecurityKernel.Initialize(new XmlSerializer(), sfPropsStoreLocation); //Initialize with the Security Framework properties
                    //mySecPolicyActionHandler.Register(); //Register the application as a policy action handler
                    SecurityKernel.Start(); //Start the Security Kernel

                    //Application.Lock();
                    //Application["SecurityFrameworkPAH"] = mySecPolicyActionHandler;
                    Application["SecurityFrameworkIsOn"] = true;
                    //Application.UnLock();

                    // Set custom filter
                    SecurityEventFilter filter = new SecurityEventFilter();
                    filter.CustomFilter += new CustomFilterEventHandler(filter_CustomFilter);
					//if (SecurityKernel.IsSecurityMonitorEnabled && SecurityKernel.SecurityMonitor.IsRuntimeApiEnabled)
					//{
					//    SecurityKernel.SecurityMonitor.Api.GetRecorder("CsvFileRecorder").AddFilter(filter);
					//}
                }
                catch (SubsystemAccessException x)
                {
                    Debug.WriteLine(x.Message);
                    throw;
                }
                catch (SubsystemApiAccessException x)
                {
                    Debug.WriteLine(x.Message);
                    throw;
                }
                catch (Exception x)
                {
                    Debug.WriteLine(x.Message);
                    throw;
                }
            }
        }

        /// <summary>
        /// This is method for QAs.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void filter_CustomFilter(object sender, CustomFilterEventArgs e)
        {
            e.Matched = e.SecurityEvent.Path != "TestSecurityEventCreation()";
        }
        
        protected void Session_Start(object sender, EventArgs e)
        {

        }

        protected void Application_BeginRequest(object sender, EventArgs e)
        {

        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {

        }

        protected void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();
            if (!(ex is BadInputDataException))
            {
                LoggingHelper.Log(ex);
            }
        }

        protected void Session_End(object sender, EventArgs e)
        {

        }

        protected void Application_End(object sender, EventArgs e)
        {
            Debug.WriteLine("Application_Start");

            if (Application["SecurityFrameworkIsOn"] != null)
            {
                try
                {
                    //Application.Lock();
                    Application["SecurityFrameworkPAH"] = null;
                    Application["SecurityFrameworkIsOn"] = null;
                    //Application.UnLock();

                    SecurityKernel.Stop();
                    SecurityKernel.Shutdown();
                }
                catch (SubsystemAccessException x)
                {
                    Debug.WriteLine(x.Message);
                }
                catch (SubsystemApiAccessException x)
                {
                    Debug.WriteLine(x.Message);
                }
                catch (Exception x)
                {
                    Debug.WriteLine(x.Message);
                }
            }
        }
    }
}