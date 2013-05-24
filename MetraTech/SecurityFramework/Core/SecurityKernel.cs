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
using System.IO;
using System.Text;
using MetraTech.Security;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Common.Configuration;
using MetraTech.SecurityFramework.Serialization;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Core.Common.Logging;
using MetraTech.SecurityFramework.Core.Common.Logging.Configuration;
using MetraTech.SecurityFramework.Core.SecurityMonitor;

namespace MetraTech.SecurityFramework
{
	public static class SecurityKernel
	{
		#region Private Fields

		private static bool _isInitialized = false;
		private static AccessController _accessController = null;
		private static Detector _detector = null;
		private static Encoder _encoder = null;
		private static Decoder _decoder = null;
		private static Equalizer _equalizer = null;
		private static Sanitizer _sanitizer = null;
		private static Encryptor _encryptor = null;
		private static ObjectReferenceMapper _objectReferenceMapper = null;
		private static PasswordQualifier _passwordQualifier = null;
		private static Processor _processor = null;
		private static RandomObjectGenerator _randomObjectGenerator = null;
		private static SecurityMonitor _securityMonitor = null;
		private static SystemAccountManager _systemAccountManager = null;
		private static Validator _validator = null;
		private static RequestScreener _requestScreener = null;
		private static WebInspectorSubsystem _webInspectorSubsystem = null;

		private static ConfigurationLoader _loader = null;
		private static IDictionary<string, SubsystemBase> _subsystems = null;
		private static object _syncRoot;

		#endregion

		#region Public Properties

		public static ConfigurationLoader Loader
		{
			get
			{
				if (_loader != null && _loader.IsInitialized)
					return _loader;
				else
					throw new Exception();
				//TODO: create new Exception-class
			}
		}

		public static ISecurityMonitor SecurityMonitor
		{
			get
			{
				if (null == _securityMonitor)
					throw new SubsystemAccessException("ISecurityMonitor");
				else
					return _securityMonitor;
			}
		}

		public static ISubsystem Processor
		{
			get
			{
				if (null == _processor)
					throw new SubsystemAccessException("IProcessor");
				else
					return _processor;
			}
		}

		public static ISubsystem Validator
		{
			get
			{
				if (null == _validator)
					throw new SubsystemAccessException("IValidator");
				else
					return _validator;
			}
		}

		public static ISubsystem Detector
		{
			get
			{
				if (null == _detector)
					throw new SubsystemAccessException("IDetector");
				else
					return _detector;
			}
		}

		public static ISubsystem Encoder
		{
			get
			{
				if (null == _encoder)
					throw new SubsystemAccessException("IEncoder");
				else
					return _encoder;
			}
		}

		public static ISubsystem Decoder
		{
			get
			{
				if (null == _decoder)
					throw new SubsystemAccessException("IDecoder");
				else
					return _decoder;
			}
		}

		public static ISubsystem Equalizer
		{
			get
			{
				if (null == _equalizer)
					throw new SubsystemAccessException("IEqualizer");
				else
					return _equalizer;
			}
		}

		public static ISubsystem Sanitizer
		{
			get
			{
				if (null == _sanitizer)
					throw new SubsystemAccessException("ISanitizer");
				else
					return _sanitizer;
			}
		}

		public static IEncryptor Encryptor
		{
			get
			{
				if (null == _encryptor)
					throw new SubsystemAccessException("IEncryptor");
				else
					return _encryptor;
			}
		}

		public static ISubsystem PasswordQualifier
		{
			get
			{
				if (null == _passwordQualifier)
					throw new SubsystemAccessException("IPasswordQualifier");
				else
					return _passwordQualifier;
			}
		}

		public static ISubsystem AccessController
		{
			get
			{
				if (null == _accessController)
					throw new SubsystemAccessException("IAccessController");
				else
					return _accessController;
			}
		}

		public static ISubsystem ObjectReferenceMapper
		{
			get
			{
				if (null == _objectReferenceMapper)
					throw new SubsystemAccessException("IObjectReferenceMapper");
				else
					return _objectReferenceMapper;
			}
		}

		public static IRandomObjectGenerator RandomObjectGenerator
		{
			get
			{
				if (null == _randomObjectGenerator)
					throw new SubsystemAccessException("IRandomObjectGenerator");
				else
					return _randomObjectGenerator;
			}
		}

		public static ISubsystem SystemAccountManager
		{
			get
			{
				if (null == _systemAccountManager)
					throw new SubsystemAccessException("ISystemAccountManager");
				else
					return _systemAccountManager;
			}
		}

		public static ISubsystem RequestScreener
		{
			get
			{
				if (null == _requestScreener)
					throw new SubsystemAccessException("RequestScreener");
				else
					return _requestScreener;
			}
		}

		public static ISubsystem WebInspectorSubsystem
		{
			get
			{
				if (null == _webInspectorSubsystem)
					throw new SubsystemAccessException("WebInspectorSubsystem");
				else
					return _webInspectorSubsystem;
			}
		}

		/// <summary>
		/// Gets a value indicating that the Access Controller subsystem is enabled.
		/// </summary>
		public static bool IsAccessControllerEnabled
		{
			get
			{
				return IsSubsystemEnabled(_accessController);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Detector subsystem is enabled.
		/// </summary>
		public static bool IsDetectorEnabled
		{
			get
			{
				return IsSubsystemEnabled(_detector);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Encoder subsystem is enabled.
		/// </summary>
		public static bool IsEncoderEnabled
		{
			get
			{
				return IsSubsystemEnabled(_encoder);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Decoder subsystem is enabled.
		/// </summary>
		public static bool IsDecoderEnabled
		{
			get
			{
				return IsSubsystemEnabled(_decoder);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Equalizer subsystem is enabled.
		/// </summary>
		public static bool IsEqualizerEnabled
		{
			get
			{
				return IsSubsystemEnabled(_equalizer);
			}
		}

		/// <summary>
		/// Gets a value inicating that the Sanitizer subsystem is enabled.
		/// </summary>
		public static bool IsSanitizerEnabled
		{
			get
			{
				return IsSubsystemEnabled(_sanitizer);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Encryptor subsystem is enabled.
		/// </summary>
		public static bool IsEncryptorEnabled
		{
			get
			{
				return IsSubsystemEnabled(_encryptor);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Object Reference Mapper subsystem is enabled.
		/// </summary>
		public static bool IsObjectReferenceMapperEnabled
		{
			get
			{
				return _isInitialized && _objectReferenceMapper != null;
			}
		}

		/// <summary>
		/// Gets a value indicating that the Password Qualifier is enabled.
		/// </summary>
		public static bool IsPasswordQualifierEnabled
		{
			get
			{
				return IsSubsystemEnabled(_passwordQualifier);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Processor subsystem is enabled.
		/// </summary>
		public static bool IsProcessorEnabled
		{
			get
			{
				return IsSubsystemEnabled(_processor);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Random Object Generator is enabled.
		/// </summary>
		public static bool IsRandomObjectGeneratorEnabled
		{
			get
			{
				return IsSubsystemEnabled(_randomObjectGenerator);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Security Monitor subsystem is enabled.
		/// </summary>
		public static bool IsSecurityMonitorEnabled
		{
			get
			{
				return IsSubsystemEnabled(_securityMonitor);
			}
		}

		/// <summary>
		/// Gets a value indicating that the System Account Manager is enabled.
		/// </summary>
		public static bool IsSystemAccountManagerEnabled
		{
			get
			{
				return IsSubsystemEnabled(_systemAccountManager);
			}
		}

		/// <summary>
		/// Gets a value indicating that the Validator subsystem is enabled.
		/// </summary>
		public static bool IsValidatorEnabled
		{
			get
			{
				return IsSubsystemEnabled(_validator);
			}
		}

		/// <summary>
		/// Gets a value indicating that the WEB inspector subsystem is enabled.
		/// </summary>
		public static bool IsWebInspectorEnabled
		{
			get
			{
				return IsSubsystemEnabled(_webInspectorSubsystem);
			}
		}

		#endregion

		#region Internal Properties

		internal static SecurityMonitor SecurityMonitorInternal
		{
			get { return _securityMonitor; }
		}

		internal static Processor ProcessorInternal
		{
			get { return _processor; }
		}

		internal static Validator ValidatorInternal
		{
			get { return _validator; }
		}

		internal static Detector DetectorInternal
		{
			get { return _detector; }
		}

		internal static Encoder EncoderInternal
		{
			get { return _encoder; }
		}

		internal static Decoder DecoderInternal
		{
			get { return _decoder; }
		}

		internal static Equalizer EqualizerInternal
		{
			get { return _equalizer; }
		}

		internal static Sanitizer SanitizerInternal
		{
			get { return _sanitizer; }
		}

		internal static Encryptor EncryptorInternal
		{
			get { return _encryptor; }
		}

		internal static PasswordQualifier PasswordQualifierInternal
		{
			get { return _passwordQualifier; }
		}

		internal static AccessController AccessControllerInternal
		{
			get { return _accessController; }
		}

		internal static ObjectReferenceMapper ObjectReferenceMapperInternal
		{
			get { return _objectReferenceMapper; }
		}

		internal static RandomObjectGenerator RandomObjectGeneratorInternal
		{
			get { return _randomObjectGenerator; }
		}

		internal static SystemAccountManager SystemAccountManagerInternal
		{
			get { return _systemAccountManager; }
		}

		#endregion

		#region Public methods

		static SecurityKernel()
		{
			_syncRoot = new object();
		}

		public static void Initialize(string location)
		{
			Initialize(new XmlSerializer(), location);
		}

		public static void Initialize(ISerializer serializer, string pathToSource)
		{
			lock (_syncRoot)
			{
				if (_isInitialized)
					return;

				_loader = ConfigurationLoader.Load(serializer, pathToSource, new ConfigurationParameters().ConfigurationDirectory);

				LoggingHelper.LogInfo("SecurityFramework.SecurityKernel.Initialize", String.Format("Loading from source {0} has been completed", pathToSource));

				ConfigurationLoader.Initialize();

				_subsystems = new Dictionary<string, SubsystemBase>();

				_detector = AddSubsystem<Detector>(ConfigurationLoader.GetSubsystem<Detector>());

				_validator = AddSubsystem<Validator>(ConfigurationLoader.GetSubsystem<Validator>());

				_encoder = AddSubsystem<Encoder>(ConfigurationLoader.GetSubsystem<Encoder>());

				_securityMonitor = ConfigurationLoader.GetSubsystem<SecurityMonitor>();

				_decoder = AddSubsystem<Decoder>(ConfigurationLoader.GetSubsystem<Decoder>());

				_equalizer = AddSubsystem<Equalizer>(ConfigurationLoader.GetSubsystem<Equalizer>());

				_sanitizer = AddSubsystem<Sanitizer>(ConfigurationLoader.GetSubsystem<Sanitizer>());

				_encryptor = AddSubsystem<Encryptor>(ConfigurationLoader.GetSubsystem<Encryptor>());

				_passwordQualifier = AddSubsystem<PasswordQualifier>(ConfigurationLoader.GetSubsystem<PasswordQualifier>());

				_processor = AddSubsystem<Processor>(ConfigurationLoader.GetSubsystem<Processor>());

				_systemAccountManager = AddSubsystem<SystemAccountManager>(ConfigurationLoader.GetSubsystem<SystemAccountManager>());

				_accessController = AddSubsystem<AccessController>(ConfigurationLoader.GetSubsystem<AccessController>());

				_objectReferenceMapper = AddSubsystem<ObjectReferenceMapper>(ConfigurationLoader.GetSubsystem<ObjectReferenceMapper>());

				_requestScreener = AddSubsystem<RequestScreener>(ConfigurationLoader.GetSubsystem<RequestScreener>());

				_webInspectorSubsystem = AddSubsystem<WebInspectorSubsystem>(ConfigurationLoader.GetSubsystem<WebInspectorSubsystem>());

				if (SecurityFrameworkSettings.Current.UsePerformanceCounters)
				{
				     PerformanceMonitor.CreateCounters();
				}

				_isInitialized = true;

				LoggingHelper.LogInfo("SecurityFramework.SecurityKernel.Initialize", String.Format("Initialization completed"));
			}
		}

		public static void SaveConfiguration(Type subsystemType)
		{
			if (!_isInitialized)
			{
				throw new ConfigurationException("SecurityKernel is not initialized, reconfiguration impossible.");
			}

			Loader.SaveConfiguration(subsystemType);
		}

		public static SubsystemBase GetSubsystem(string typeName)
		{
			if (_subsystems != null && _subsystems.ContainsKey(typeName))
			{
				return _subsystems[typeName];
			}
			else
			{
				return null;
			}
		}

		public static T GetSubsystem<T>() where T : new()
		{
			return ConfigurationLoader.GetSubsystem<T>();
		}

		public static ApiOutput Execute<T>(string idEngine, ApiInput input) where T : new()
		{
			ApiOutput output = null;
			T sBase = ConfigurationLoader.GetSubsystem<T>();
			SubsystemBase system;
			if ((system = sBase as SubsystemBase) != null)
			{
				output = system.Api.Execute(idEngine, input);
			}
			return output;
		}

		public static bool IsInitialized()
		{
			return _isInitialized;
		}

		public static void Start()
		{
		}

		public static void Stop()
		{
		}

		public static void Shutdown()
		{
			lock (_syncRoot)
			{
				if (!_isInitialized)
					return;

				ShutdownSubsystem(_detector);

				ShutdownSubsystem(_decoder);

				ShutdownSubsystem(_encoder);

				ShutdownSubsystem(_encryptor);

				ShutdownSubsystem(_equalizer);

				ShutdownSubsystem(_passwordQualifier);

				ShutdownSubsystem(_processor);

				ShutdownSubsystem(_sanitizer);

				ShutdownSubsystem(_validator);

				ShutdownSubsystem(_requestScreener);

				_isInitialized = false;
			}
		}

		#endregion

		#region Private methods

		private static string MakeFullPath(string baseDir, string name)
		{
			StringBuilder result = new StringBuilder(baseDir);
			if (result.Length > 0)
				result.Append('\\');

			result.Append(name);
			return result.ToString();
		}

		private static bool IsSubsystemEnabled(ISubsystemInitialize subsystem)
		{
			return _isInitialized && subsystem != null;
		}

		private static T AddSubsystem<T>(T subsystem) where T : SubsystemBase
		{
			_subsystems.Add(typeof(T).Name, subsystem);
			return subsystem;
		}

		private static void ShutdownSubsystem(ISubsystem subsystem)
		{
			if (subsystem != null)
			{
				((SubsystemBase)subsystem).Shutdown();
			}
		}

		#endregion
	}
}
