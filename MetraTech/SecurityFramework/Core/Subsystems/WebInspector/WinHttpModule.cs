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
using System.Text;
using System.Web;
using System.Diagnostics;

using System.Text.RegularExpressions;
using System.Collections.Specialized;
using MetraTech.SecurityFramework;

/*
The number of HttpApplication instances (and thus, the number of instances for each HTTP Module) is tied to the number of worker threads. It has nothing to do with the number of connections each client opens to the server.
From the one BeingRequest event until the next BeginRequest event you can rely on being on the same request. This reduces locking, for example.
HTTP modules should be built to be independent form each other (other instances of the same module or other modules). If some shared state or configuration is needed, it should be on another class.

 http://msdn.microsoft.com/en-us/library/ms227673(VS.100).aspx 
*/

namespace MetraTech.SecurityFramework.WebInspector
{
    public class WinHttpModule : IHttpModule
    {
        //KCQ: 
        //THE INITIAL IMPLEMENTATION WILL ENFORCE THAT WE SETUP EVENT HANDLERS ONLY ONCE.
        //IN THE FUTURE WE MIGHT TRY TO HAVE PARALLEL WAF MODULES!!!

        private static bool _hasAppStarted = false;
        private readonly static object _syncObject = new object();
        private WebInspector _inspector = null;

        public WinHttpModule()
        {}

        public String ModuleName
        { get { return "MetraTech.SecurityFramework.WebInspector"; } }

        public void Init(HttpApplication app)
        {
            if (null == app)
                return;

            if (!_hasAppStarted)
            {
                lock (_syncObject)
                {
                    if (!_hasAppStarted)
                    {
                        _hasAppStarted = true;
                        InitImpl(app);
                    }
                }
            } 
        }

        private void InitImpl(HttpApplication app)
        {
					//SECENG TODO:
            /*try
            {
                string winPropsLocation = WinConfigInfo.Instance.WinPropsLocation;
                string sfPropsLocation = WinConfigInfo.Instance.SfPropsLocation;

                _inspector = new WebInspector();
                _inspector.Initialize(winPropsLocation, sfPropsLocation);

                app.BeginRequest += OnWebAppBeginRequest;
                app.Error += OnWebAppError;
                app.EndRequest += OnWebAppEndRequest;
            }
            catch (Exception x)
            {
                string msg = x.Message;
            }*/
        }

        private void OnWebAppBeginRequest(Object source, EventArgs e)
        {
            if (null != _inspector)
            {
                HttpApplication app = (HttpApplication)source;
                HttpContext context = app.Context;
                HttpRequest request = context.Request;
                HttpResponse response = context.Response;

                _inspector.ProcessRequest(app, context, request,response);
            }
        }

        void OnWebAppError(object sender, EventArgs e)
        {
            if (null != _inspector)
            {
                HttpApplication app = (HttpApplication)sender;
                Exception exception = app.Server.GetLastError();
                Exception baseException = exception.GetBaseException();
                HttpResponse response = app.Context.Response;

                _inspector.ProcessError(app,response,exception,baseException);
            }
        }

        void OnWebAppEndRequest(object sender, EventArgs e)
        {
            if (null != _inspector)
            {
                HttpApplication app = (HttpApplication)sender;
                HttpRequest request = app.Context.Request;
                HttpResponse response = app.Context.Response;

                _inspector.ProcessResponse(app,request,response);
            }
        }

        public void Dispose() 
        {
            if (null != _inspector)
            {
                _inspector.Shutdown();
            }
        }
    }
}
