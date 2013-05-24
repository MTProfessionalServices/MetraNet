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

namespace MetraTech.SecurityFramework
{
	internal class RequestScreener : SubsystemBase
	{
		public RequestScreener() : base() { }

		public override void InitCategories()
		{
			InitCategories(typeof(RequestScreenerEngineCategory));
		}
		/*
		private delegate void EngineLoader(EnginePropsInfo info);

		private Dictionary<string, EngineLoader> _engineFactory = new Dictionary<string, EngineLoader>();

		private bool _isInitialized = false;
		private bool _isRuntimeApiPublic = false;
		private bool _isControlApiPublic = false;
		private IRequestScreenerApi _runtimeApi = null;
		private IRequestScreenerControlApi _controlApi = null;

		public bool IsInitialized
		{
			get { return _isInitialized; }
		}

		public bool IsApiPublic
		{
			get { return _isRuntimeApiPublic && (null != _runtimeApi); }
		}

		public bool IsControlApiPublic
		{
			get { return _isControlApiPublic && (null != _controlApi); }
		}

		public IRequestScreenerApi Api
		{
			get
			{
				if (_isRuntimeApiPublic && (null != _runtimeApi))
					return _runtimeApi;
				else
					throw new SubsystemApiAccessException("IRequestScreenerApi");
			}
		}

		public IRequestScreenerControlApi ControlApi
		{
			get
			{
				if (_isControlApiPublic && (null != _controlApi))
					return _controlApi;
				else
					throw new SubsystemApiAccessException("IRequestScreenerControlApi");
			}
		}

		internal IRequestScreenerApi ApiInternal
		{
			get { return _runtimeApi; }
		}

		internal IRequestScreenerControlApi ControlApiInternal
		{
			get { return _controlApi; }
		}

		internal RequestScreener()
		{
			_engineFactory.Add(RequestScreenerEngineName.InputStandard, LoadInputStandardEngine);
		}

		public void Initialize(string propsStoreLocation)
		{
			if (_isInitialized)
				return;

			try
			{
				SubsystemPropsInfo info = SubsystemProps.Load(propsStoreLocation);

				RequestScreenerApi api = null;

				if (info.Api.EnableControlApi)
				{
					if (null == api)
						api = new RequestScreenerApi();

					_controlApi = api as IRequestScreenerControlApi;
					_isControlApiPublic = info.Api.PublicControlApi;
				}

				if (info.Api.EnableRuntimeApi)
				{
					if (null == api)
						api = new RequestScreenerApi();

					_runtimeApi = api as IRequestScreenerApi;
					_isRuntimeApiPublic = info.Api.PublicRuntimeApi;
				}

				if ((null != _controlApi) && (null != info.Engines) && (info.Engines.Count > 0))
				{
					foreach (EnginePropsInfo engineInfo in info.Engines)
					{
						CreateEngine(engineInfo);
					}
				}

				_isInitialized = true;
			}
			catch (Exception x)
			{
				string msg = x.Message;
				throw;
			}
		}

		public void Shutdown()
		{
			if (null != _controlApi)
			{
				_controlApi.RemoveAllEngines();
				_isControlApiPublic = false;
				_controlApi = null;
			}
			_isRuntimeApiPublic = false;
			_runtimeApi = null;
			_isInitialized = false;
		}

		public void NotifySystemIsStarted()
		{
		}

		private void CreateEngine(EnginePropsInfo info)
		{
			if ((null == info.Name) || (0 == info.Name.Length))
				return;

			EngineLoader engineLoader = null;
			if (_engineFactory.TryGetValue(info.Name, out engineLoader) && (null != engineLoader))
			{
				engineLoader(info);
			}
		}

		private void LoadInputStandardEngine(EnginePropsInfo info)
		{
			if (string.IsNullOrEmpty(info.Id))
				throw new ArgumentNullException();

			DefaultInputRequestScreenerEngine engine = new DefaultInputRequestScreenerEngine(info);
			_controlApi.AddEngine(info.Id, info.Category, engine, info.IsDefault);
		}
		*/
	}
}

