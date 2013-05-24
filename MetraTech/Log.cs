
using System;
using System.Diagnostics;
using System.Reflection;

namespace MetraTech
{
	public interface ILogger
	{
		//
		// FATAL
		// 
		void LogFatal(string format, params object[] args);
		void LogFatal(string str);

		//
		// ERROR
		//
		void LogError(string format, params object[] args);
		void LogError(string str);

		//
		// WARNING
		//
		void LogWarning(string format, params object[] args);
		void LogWarning(string str);

		//
		// INFO
		//
		void LogInfo(string format, params object[] args);
		void LogInfo(string str);

		//
		// DEBUG
		//
		bool WillLogDebug
		{ get; }
        bool WillLogError
        { get; }
        bool WillLogWarning
        { get; }
        bool WillLogInfo
        { get; }
        bool WillLogFatal
        { get; }
        bool WillLogTrace
        { get; }

		void LogDebug(string format, params object[] args);
		void LogDebug(string str);

        void LogTrace(string format, params object[] args);
        void LogTrace(string str);

    void LogException(string str, Exception e);
	}

	public class Logger : ILogger
	{
		public Logger(string directory, string tag, bool initialize)
		{
			mDirectory = directory;
			mTag = tag;
			if (initialize)
				Init(mDirectory, mTag);
		}

		public Logger(string directory, string tag)
			: this(directory, tag, false)
		{ }

		public Logger(string tag)
			: this("logging", tag, false)
		{	}

		public Logger(string tag, bool initialize)
			: this("logging", tag, initialize)
		{	}

		public Logger(MetraTech.Interop.SysContext.IMTLog logger)
		{
			mLogger = logger;
		}

		public void Init(string directory, string tag)
		{
			Debug.Assert(!IsInitialized);

			mLogger = new MetraTech.Interop.SysContext.MTLog();
			Debug.Assert(tag[0] == '[' && tag[tag.Length - 1] == ']',
									 "Logging tag must be contained in brackets []");
			mLogger.Init(directory, tag);
		}

		public void AutoInit()
		{
			if (!IsInitialized)
				Init(mDirectory, mTag);
		}

		public bool IsInitialized
		{
			get
			{
				return mLogger != null;
			}
		}

		//
		// FATAL
		// 
		public void LogFatal(string format, params object[] args)
		{
			AutoInit();
			LogFatal(string.Format(format, args));
		}

		public void LogFatal(string str)
		{
			AutoInit();
      
      mLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_FATAL, str);
		}

		//
		// ERROR
		//
		public void LogError(string format, params object[] args)
		{
			AutoInit();
			LogError(string.Format(format, args));
		}

		public void LogError(string str)
		{
			AutoInit();

      mLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_ERROR, str);
    }

		//
		// WARNING
		//
		public void LogWarning(string format, params object[] args)
		{
			AutoInit();
			LogWarning(string.Format(format, args));
		}

		public void LogWarning(string str)
		{
			AutoInit();
			mLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_WARNING,
												str);
		}

		//
		// INFO
		//
		public void LogInfo(string format, params object[] args)
		{
			AutoInit();
			LogInfo(string.Format(format, args));
		}

		public void LogInfo(string str)
		{
			AutoInit();
			mLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_INFO,
												str);
		}

		//
		// DEBUG
		//
		public bool WillLogDebug
		{
			get
			{
				AutoInit();
				return mLogger.OKToLog(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_DEBUG);
			}
		}

        public bool WillLogError
        {
          get
          {
            AutoInit();
            return mLogger.OKToLog(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_ERROR);
          }
        }

        public bool WillLogWarning
        {
          get
          {
            AutoInit();
            return mLogger.OKToLog(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_WARNING);
          }
        }

        public bool WillLogInfo
        {
          get
          {
            AutoInit();
            return mLogger.OKToLog(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_INFO);
          }
        }

        public bool WillLogFatal
        {
          get
          {
            AutoInit();
            return mLogger.OKToLog(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_FATAL);
          }
        }

		public void LogDebug(string format, params object[] args)
		{
			AutoInit();
			LogDebug(string.Format(format, args));
		}

		public void LogDebug(string str)
		{
			AutoInit();
			mLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_DEBUG,
												str);
		}
    
    public void LogStackFrame(MetraTech.Interop.SysContext.PlugInLogLevel level)
    {
      StackTrace stackTrace = new StackTrace();
      StackFrame stackFrame;
      MethodBase stackFrameMethod;
      int frameCount = 0;
      string typeName;
      do 
      {
        frameCount++;
        stackFrame = stackTrace.GetFrame(frameCount);
        stackFrameMethod = stackFrame.GetMethod();
        typeName = stackFrameMethod.ReflectedType.FullName;
      } while (typeName.StartsWith("System") ||
               typeName.EndsWith("Exception") ||
               typeName.EndsWith("Logger"));

      StackFrame sf = new StackFrame(frameCount, true);
      mLogger.LogString(level, sf.ToString());
    }

    public void LogException(string msg, Exception e)
    {
      AutoInit();

      mLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_ERROR, msg);

      string errMsg = string.Format("Error message was: {0}\n", e.Message);
      errMsg += string.Format("Exception at: {0}\n", e.StackTrace);

      Exception inner = e.InnerException;
      while (inner != null)
      {
        errMsg += string.Format("Inner error message was: {0}\n", inner.Message);
        errMsg += string.Format("Inner exception at: {0}\n", inner.StackTrace);

        inner = inner.InnerException;
      }

      mLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_ERROR, errMsg);
    }

		private MetraTech.Interop.SysContext.IMTLog mLogger;
		private string mDirectory;
		private string mTag;

        #region ILogger Members


        public bool WillLogTrace
        {
            get
            {
                AutoInit();
                return mLogger.OKToLog(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_TRACE);
            }
        }

        public void LogTrace(string format, params object[] args)
        {
            AutoInit();
            LogTrace(string.Format(format, args));
        }

        public void LogTrace(string str)
        {
            AutoInit();
            mLogger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_TRACE,
                                                str);
        }

        #endregion
    }
}
