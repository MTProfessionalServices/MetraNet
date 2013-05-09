using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class MsgLogger
    {
        public enum LogLevel { Error, Warning, Info, Debug}

        public Dictionary<LogLevel, int> countPerLevel = new Dictionary<LogLevel, int>();

        /// <summary>
        /// The number of times that an error was logged
        /// </summary>
        public int NumErrors { get { return countPerLevel[LogLevel.Error]; } }

        /// <summary>
        /// The number of times that a warning was logged
        /// </summary>
        public int NumWarnings { get { return countPerLevel[LogLevel.Warning]; } }

        public class LogEntry
        {
            LogLevel level;
            string msg;

            public LogEntry(LogLevel level, string msg)
            {
                this.level = level;
                this.msg = msg;
            }
        }

        public readonly List<LogEntry> Log = new List<LogEntry>();

        public int Count { get { return Log.Count; } }

        public delegate void LogEvent(string msg);
        public LogEvent OnLogEvent;

        public MsgLogger()
        {
            foreach (LogLevel level in Enum.GetValues(typeof(LogLevel)))
            {
                countPerLevel.Add(level, 0);
            }
        }


        public void AddMessage(LogLevel level, string msg)
        {
            string text = "";

            if (level != LogLevel.Info)
            {
                text = string.Format("{0}: ", level.ToString());
            }

            text += msg;

            Log.Add(new LogEntry(level, msg));
            countPerLevel[level]++;

            if (OnLogEvent != null)
                OnLogEvent(text + "\r\n");
        }

        public void Info(string msg)
        {
            AddMessage(LogLevel.Info, msg);
        }

        public void Error(string msg)
        {
            AddMessage(LogLevel.Error, msg);
        }
        public void Warning(string msg)
        {
            AddMessage(LogLevel.Warning, msg);
        }



        public void InfoFormat(string msg, params object[] args)
        {
            AddMessage(LogLevel.Info, string.Format(msg, args));
        }

        public void ErrorFormat(string msg, params object[] args)
        {
            AddMessage(LogLevel.Error, string.Format(msg, args));
        }
        public void WarningFormat(string msg, params object[] args)
        {
            AddMessage(LogLevel.Warning, string.Format(msg, args));
        }

    }
}
