namespace MetraTech.Debug.LogAnalyzer
{
	using System;
	using System.Text;
	using System.Xml;
	using System.Collections;
	using System.IO;
	using System.Text.RegularExpressions;
	using MetraTech.Xml;



	public class LogMessage
	{
		static LogMessage()
		{
			mTimestampRegex = new Regex("^([01][0-9]/[0-3][0-9]/[09][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]) (.*)");
		}
		
		public LogMessage(string originalMessage, LogFile log) : this(originalMessage, originalMessage, log)
		{ }

		public LogMessage(string originalMessage, string finalMessage, LogFile log)
		{
			mLog = log; // keeps track of where we came from
			mMessage = finalMessage;

			// time is taken from the source message since the final message can be arbitrary text
			mTimestamp = DateTime.Parse(mTimestampRegex.Match(originalMessage).Result("$1"));

			// strips the timestamp from the final message so 
			// meaningful frequencies can be tallied
			Match m = mTimestampRegex.Match(finalMessage);
			if (m.Success)
				mTimelessMessage = m.Result("$2");
			else
				mTimelessMessage = finalMessage;
		}

		// returns the current message's timestamp
		public DateTime Timestamp
		{
			get
			{
				return mTimestamp;
			}
		}

		public override string ToString()
		{
			return mMessage;
		}

		public string ToStringWithoutTimestamp()
		{
			return mTimelessMessage;
		}

		public LogFile Log
		{
			get 
			{
				return mLog;
			}
		}


		LogFile mLog;
		string mMessage;
		string mTimelessMessage;
		DateTime mTimestamp;
		static Regex mTimestampRegex;
	}
}
