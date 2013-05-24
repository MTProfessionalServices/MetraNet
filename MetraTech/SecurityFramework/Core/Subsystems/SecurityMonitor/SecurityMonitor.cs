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
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Common.Configuration.Logger;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    internal sealed class SecurityMonitor : ISecurityMonitor, ISubsystemInitialize
    {
        #region Private fields

        private ISecurityMonitorApi _api;
        private bool _initialized;
        private bool _isRuntimeApiPublic;

        #endregion

        #region Public properties
        /// <summary>
        /// Gets or sets an API for the subsystem.
        /// </summary>
        public ISecurityMonitorApi Api
        {
            get
            {
                if (_api == null || !_isRuntimeApiPublic)
                {
                    throw new SubsystemApiAccessException();
                }

                return _api;
            }
            private set
            {
                _api = value;
            }
        }

        public ISecurityMonitorControlApi ControlApi
        {
            get
            {
                throw new NotImplementedException();
            }
        }

        /// <summary>
        /// Gets a value indicating that the Security Monitor API is enabled.
        /// </summary>
        public bool IsRuntimeApiEnabled
        {
            get
            {
                return _initialized && _isRuntimeApiPublic && _api != null;
            }
        }

        /// <summary>
        /// Gets a value indicating that the Security Monitor control API is enabled.
        /// </summary>
        public bool IsControlApiEnabled
        {
            get
            {
                throw new NotImplementedException();
            }
        }

        /// <summary>
        /// Gets or internally sets a value indication if Input Data should be recorder together with other information.
        /// </summary>
        public bool RecordInputData
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets or internally sets a value indication if security event Reason should be recorder together with other information.
        /// </summary>
        public bool RecordEventReason
        {
            get;
            private set;
        }

        #endregion

        #region Public methods

        /// <summary>
        /// Initializes the subsystem.
        /// </summary>
        /// <param name="props">Subsystem's configuration.</param>
        public void Initialize(MetraTech.SecurityFramework.Core.SubsystemProperties properties)
        {
            if (properties == null)
            {
                throw new ArgumentNullException(Constants.Arguments.Properties);
            }

            SecurityMonitorProperties monitorProperties = properties as SecurityMonitorProperties;

            if (monitorProperties == null)
            {
                throw new SubsystemInputParamException("Passed value's type mismatch. It must be an instance of the SecurityMonitorProperties type.");
            }

            if (_initialized)
            {
                return;
            }

            _isRuntimeApiPublic = monitorProperties.IsRuntimeApiPublic;
            RecordInputData = monitorProperties.RecordInputData;
            RecordEventReason = monitorProperties.RecordEventReason;

            if (monitorProperties.IsRuntimeApiEnabled)
            {
                SecurityMonitorApi apiValue = new SecurityMonitorApi();
                apiValue.Initialize(monitorProperties);

                Api = apiValue;
            }

            _initialized = true;
        }

        /// <summary>
        /// Frees all resources used by the subsystem.
        /// </summary>
        public void Shutdown()
        {
        }

        #endregion

        //private bool mIsInitialized = false;
        //private bool mIsRuntimeApiPublic = false;
        //private bool mIsControlApiPublic = false;
        //private ISecurityMonitorApi mRuntimeApi = null;
        //private ISecurityMonitorControlApi mControlApi = null;

        //public ISecurityMonitorApi Api
        //{
        //    get
        //    {
        //        if (mIsRuntimeApiPublic && (null != mRuntimeApi))
        //            return mRuntimeApi;
        //        else
        //            throw new SubsystemApiAccessException("ISecurityMonitorApi");
        //    } 
        //}

        //public ISecurityMonitorControlApi ControlApi
        //{
        //    get
        //    {
        //        if (mIsControlApiPublic && (null != mControlApi))
        //            return mControlApi;
        //        else
        //            throw new SubsystemApiAccessException("ISecurityMonitorControlApi");
        //    }
        //}

        //internal ISecurityMonitorApi ApiInternal
        //{
        //    get { return mRuntimeApi; }
        //}

        //internal ISecurityMonitorControlApi ControlApiInternal
        //{
        //    get { return mControlApi; }
        //}

        //internal SecurityMonitor()
        //    : base("SecurityMonitor")
        //{
        //}

        //public override void Initialize(string propsStoreLocation)
        //{
        //    if (mIsInitialized)
        //        return;

        //    try
        //    {
        //        SecurityMonitorProperties props = SecurityMonitorProperties.Get(propsStoreLocation);

        //        SecurityMonitorApi api = null;
        //        if (props.mSubsystemProps.mIsControlApiEnabled)
        //        {
        //            if (null == api)
        //                api = new SecurityMonitorApi();

        //            mControlApi = api as ISecurityMonitorControlApi;
        //            mIsControlApiPublic = props.mSubsystemProps.mIsControlApiPublic;
        //        }

        //        if (props.mSubsystemProps.mIsRuntimeApiEnabled)
        //        {
        //            if (null == api)
        //                api = new SecurityMonitorApi();

        //            mRuntimeApi = api as ISecurityMonitorApi;
        //            mIsRuntimeApiPublic = props.mSubsystemProps.mIsRuntimeApiPublic;
        //        }

        //        mIsInitialized = true;
        //    }
        //    catch (Exception x)
        //    {
        //        Console.WriteLine(x.Message);
        //        throw;
        //    }
        //}

        //public override void Shutdown()
        //{
        //    if (null != mControlApi)
        //    {
        //        mIsControlApiPublic = false;
        //        mControlApi = null;
        //    }
        //    mIsRuntimeApiPublic = false;
        //    mRuntimeApi = null;
        //    mIsInitialized = false;
        //}


		public IConfigurationLogger GetConfiguration()
		{
			throw new NotImplementedException();
		}
	}
}
