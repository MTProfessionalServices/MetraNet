namespace MetraTech.Debug.LogAnalyzer
{
	using System;
	using System.Text;
	using System.Xml;
	using System.Collections;
	using System.IO;
	using System.Text.RegularExpressions;
	using MetraTech.Xml;



	public class LogFile : IComparable
	{

		static LogFile()
		{
			mDateHeaderRegex = new Regex("^([01][0-9]/[0-3][0-9]/[09][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]) ", RegexOptions.Compiled);
			mTimelessMessageRegex = new Regex("^[01][0-9]/[0-3][0-9]/[09][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9] (.*)", RegexOptions.Compiled);
		}


		public LogFile(string filename, string logDir, ArrayList filters)
		{
			FileStream fileStream = File.OpenRead(filename);
			mFile = new StreamReader(fileStream);
			mFilters = filters;
			mLogDir = logDir;
		}

		// returns the directory the log was read from
		public string Directory
		{
			get
			{
				return mLogDir;
			}
		}

		// returns the current message
		public LogMessage Message
		{
			get
			{
				return mMessage;
			}
		}

		// returns the current message's timestamp
		public DateTime Timestamp
		{
			get
			{
				if (mMessage == null)
					return DateTime.MinValue;

				return mMessage.Timestamp;
			}
		}

		public LogMessage NextMessage()
		{
			while(true)
			{
				string message = ReadMessage();
				if (message == null)
				{
					mMessage = null;
					return null;
				}

				// if filters are specified only filter in what they match (inclusive)
				if (mFilters.Count > 0)
				{
					string finalMessage;
					if (Match(message, out finalMessage))
					{
						mMessage = new LogMessage(message, finalMessage, this);
						return mMessage;
					}
				}
				else
				{
					// if there are no filters just include everything
					mMessage = new LogMessage(message, this);
					return mMessage;
				}
			}
		}

		// A collection of filters
		public ArrayList Filters
    {
			set 
			{
				mFilters = value;
			}
			get 
			{
				return mFilters;
			}
		}

		public int CompareTo(object obj)
		{
			LogFile other = (LogFile) obj;
			if (Timestamp < other.Timestamp)
				return -1;

			if (Timestamp > other.Timestamp)
				return 1;

			return 0;
		}

		// returns the next message.
		// a message may contain multiple lines.
		// if there are no more messages, returns null.
		private string ReadMessage()
		{
			string message = null;
			while (true)
			{
				string line = ReadLine();
				if (line == null)
					return message;
				
				if (message == null)
					message = line;
				else
					message += "\n" + line;
				
				string peekahead = PeekLine();
				if ((peekahead == null) || mDateHeaderRegex.IsMatch(peekahead))
					return message; 
			}
		}


		private string ReadLine()
		{
			string line;
			if (mPeekMessage != null)
			{
				line = mPeekMessage;
				mPeekMessage = null;
				return line;
			}

			return mFile.ReadLine();
		}
		
		private string PeekLine()
		{
			System.Diagnostics.Debug.Assert(mPeekMessage == null);

			mPeekMessage = mFile.ReadLine();
			return mPeekMessage;
		}

		// evaluates filters on an input message until at least one filter matches.
		// a message is exlcuded if none of the filters match.
    private bool Match(string message, out string outputMessage)
		{
			outputMessage = null;

			foreach (LogFilter filter in mFilters)
				// returns immediately if a condition IS met
				if (filter.Match(message, out outputMessage))
					return true; 
			
			// excludes the message
			return false; 
		}

		StreamReader mFile;
		string mLogDir;
		ArrayList mFilters = new ArrayList();

		LogMessage mMessage;
		string mPeekMessage;
		static Regex mDateHeaderRegex;
		static Regex mTimelessMessageRegex;
	}
}
