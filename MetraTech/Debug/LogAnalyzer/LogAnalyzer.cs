
namespace MetraTech.Debug.LogAnalyzer
{
	using System;
	using System.Text;
	using System.Xml;
	using System.Collections;
	using System.IO;
	using System.Text.RegularExpressions;
	using MetraTech.Xml;


	class LogAnalyzerExecutable
	{
		[MTAThread]
		static int Main(string[] args)
		{
			LogAnalyzerExecutable logAnalyzer = new LogAnalyzerExecutable(args);
			return logAnalyzer.Execute();
		}

		public LogAnalyzerExecutable(string [] args)
		{
			mArgs = args;
		}

		public int Execute()
		{
			// at least one argument, the action, is required
			if (mArgs.Length == 0)
			{
				DisplayUsage();
				return 1;
			}

			try
			{
				mParser = new CommandLineParser(mArgs, 0, mArgs.Length);
				mParser.Parse();
				
				string configFile = mParser.GetStringOption("configfile", null);
				string logDir = mParser.GetStringOption("logdir", Directory.GetCurrentDirectory());

				DateTime start = DateTime.Now;
				LogAnalyzer analyzer = new LogAnalyzer(configFile, logDir);

				if (mParser.GetBooleanOption("temporalonly", false))
				{
					Console.WriteLine("Filters will be ignored - all messages will be included");
					analyzer.ClearFilters();
					analyzer.AnalyzeTemporal();
				}
				else
					analyzer.Analyze();

				DateTime finish = DateTime.Now;

				TimeSpan duration =  finish.Subtract(start);
				Console.WriteLine("Duration: {0}", duration);

			}
			catch (ApplicationException e)
			{
				Console.WriteLine();
				Console.WriteLine(e.Message);
				return 1;
			}
			catch (Exception e)
			{
				Console.WriteLine();
				Console.WriteLine(e);
				return 2;
			}

			return 0;
		}

		private void DisplayUsage()
		{
			Console.WriteLine("loganalyzer v1.0");
			Console.WriteLine();
			Console.WriteLine("usage:");
			Console.WriteLine("  loganalyzer /configfile:config.xml [/logdir:.]");
			Console.WriteLine();
		}
		
		string [] mArgs;
		CommandLineParser mParser;
	}


	public class LogAnalyzer
	{

		class TemporalStats
		{
			public DateTime EarliestMessage = DateTime.MaxValue;
			public DateTime LatestMessage = DateTime.MinValue;
			public TimeSpan LargestGap = new TimeSpan(0);

			public DateTime PreviousMessage = DateTime.MinValue;
		}

		public LogAnalyzer(string configFile, string logDir)
		{
			if (configFile != null)
				LoadConfig(configFile);

			OpenLogFiles(logDir);
		}

		private void LoadConfig(string configFile)
		{
			Console.WriteLine("Loading configuration from {0}:", configFile);
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(configFile);

 			Console.Write("  adding MTLog filters...");
			foreach (XmlNode filterNode in doc.SelectNodes("/LogAnalyzer/LogSettings/MTLog/Filters/Filter"))
				mMTLogFilters.Add(ProcessFilterNode(filterNode));
 			Console.WriteLine("\t{0} added.", mMTLogFilters.Count);

 			Console.Write("  adding MSIXLog filters...");
			foreach (XmlNode filterNode in doc.SelectNodes("/LogAnalyzer/LogSettings/MSIXLog/Filters/Filter"))
				mMSIXLogFilters.Add(ProcessFilterNode(filterNode));
 			Console.WriteLine("\t{0} added.", mMSIXLogFilters.Count);

			mOutputFilename = doc.GetNodeValueAsString("/LogAnalyzer/Output/MainFile");
			mStatsFilename = doc.GetNodeValueAsString("/LogAnalyzer/Output/StatisticsFile");
			mInsertDayBreaks = doc.GetNodeValueAsBool("/LogAnalyzer/Output/InsertDayBreaks", false);
		}

		private LogFilter ProcessFilterNode(XmlNode filterNode)
		{
			LogFilter filter = new LogFilter();

			// adds conditions
			foreach (XmlNode conditionNode in filterNode.SelectNodes("MessageContains"))
				filter.AddCondition(conditionNode.InnerText);
			
			// sets the optional substitute message
			filter.SubstituteMessage = MTXmlDocument.GetNodeValueAsString(filterNode, "SubstituteMessage", null);
			return filter;
		}

		private void OpenLogFiles(string logDir)
		{
			// adds logs found in the log directory and sub-directories
			Console.WriteLine("Finding log files...");
			AddLogs(logDir);

			if (mLogs.Count == 0)
				throw new ApplicationException("No logs found. Did you forget to specify the /logdir switch?");

			Console.WriteLine("Reading initial messages...");
			ArrayList removeList = new ArrayList();
			foreach (LogFile log in mLogs)
				if (log.NextMessage() == null)
					removeList.Add(log);

			// remove any logs with no matches
			foreach (LogFile log in removeList)
				mLogs.Remove(log);
		}

		private void AddLogs(string logDir)
		{
			int baseLogCount = mLogs.Count;
			foreach (string filename in Directory.GetFiles(logDir, "mtlog*.txt"))
				mLogs.Add(new LogFile(filename, logDir, mMTLogFilters));
			
			foreach (string filename in Directory.GetFiles(logDir, "msixlog*.txt"))
				mLogs.Add(new LogFile(filename, logDir, mMSIXLogFilters));

			Console.WriteLine("\t{0} logs found in {1}", mLogs.Count - baseLogCount, logDir);

			foreach (string subdir in Directory.GetDirectories(logDir))
				AddLogs(subdir);
		}

		// clears out any configured filters
		// if there are no filters, all messages will be included
		public void ClearFilters()
		{
			foreach (LogFile log in mLogs)
				log.Filters.Clear();
		}

		public void Analyze()
		{
			Console.WriteLine("Analyzing logs...");
			StreamWriter output = new StreamWriter(new FileStream(mOutputFilename, FileMode.Create));
			StreamWriter stats = new StreamWriter(new FileStream(mStatsFilename, FileMode.Create));
			
			SortLogs();

			//
			// loops until no more log messages are returned
			//
			bool firstTime = false;
			while (true)
			{
				LogMessage message = NextMessage();
				if (message == null)
					break;

				// initializes the next day trigger with the first message's date + 1 day
				if (firstTime)
				{
					mNextDay = message.Timestamp.Date.AddDays(1);
					firstTime = false;
				}

				// has a day boundary been crossed?
				if (message.Timestamp > mNextDay)
					AdvanceDay(message.Timestamp, output, stats);

				output.WriteLine(message);

				UpdateFrequencies(message);
				UpdateTemporalStats(message);
			}

			WriteFrequencies(stats);

			output.Close();
			stats.Close();
			
			DisplayTemporalStats();
		}

		public void AnalyzeTemporal()
		{
			Console.WriteLine("Analyzing logs...");
			SortLogs();

			//
			// loops until no more log messages are returned
			//
			while (true)
			{
				LogMessage message = NextMessage();
				if (message == null)
					break;

				UpdateTemporalStats(message);
			}

			DisplayTemporalStats();
		}



		private void AdvanceDay(DateTime timestamp, StreamWriter output, StreamWriter stats)
		{
			// advances the next day trigger
			mNextDay = timestamp.Date.AddDays(1);
			
			// inserts the day header
			if (mInsertDayBreaks)
			{
				output.WriteLine();
				output.WriteLine("_________________________________________________");
				output.WriteLine("  {0}", timestamp.Date.ToString("ddd MM/dd/yyyy"));
				output.WriteLine();
				
			}

			WriteFrequencies(stats);
			ResetFrequencies();

			// writes out statistical information
			stats.WriteLine();
			stats.WriteLine("_________________________________________________");
			stats.WriteLine("  {0}", timestamp.Date.ToString("ddd MM/dd/yyyy"));
			stats.WriteLine();

		}

		private void WriteFrequencies(StreamWriter stats)
		{
			// sorts the messages based on frequency (descending)
			ArrayList sortedStatistics = new ArrayList();
			foreach (DictionaryEntry entry in mStatistics)
				sortedStatistics.Add(entry);
			sortedStatistics.Sort(new StatisticComparer());

			foreach (DictionaryEntry entry in sortedStatistics)
				stats.WriteLine("{0}\t{1}", entry.Value, entry.Key);
		}

		// increments the frequency count for the given message
		private void UpdateFrequencies(LogMessage message)
		{
			Object obj = mStatistics[message.ToStringWithoutTimestamp()];
			if (obj == null)
				mStatistics[message.ToStringWithoutTimestamp()] = 1;
			else
				mStatistics[message.ToStringWithoutTimestamp()] = (int) obj + 1;
		}

		// resets the statistical counters for all messages
		public void ResetFrequencies()
		{
			mStatistics = new Hashtable();
		}


		private void UpdateTemporalStats(LogMessage message)
		{
			// retrieves the stats object for the given log dir
			TemporalStats stats;
			Object obj = mTemporalStats[message.Log.Directory];
			if (obj == null)
			{
				// create the stats object if one doesn't yet exist
				stats = new TemporalStats();
				mTemporalStats[message.Log.Directory] = stats;
			}
			else
				stats = (TemporalStats) mTemporalStats[message.Log.Directory];
			
			ComputeTemporalStats(stats, message);
			ComputeTemporalStats(mOverallTemporalStats, message);
		}
		
		private void ComputeTemporalStats(TemporalStats stats, LogMessage message)
		{
			if (message.Timestamp < stats.EarliestMessage)
				stats.EarliestMessage = message.Timestamp;

			if (message.Timestamp > stats.LatestMessage)
				stats.LatestMessage = message.Timestamp;

			// this computation can only be done if we've seen at least one message already
			if (stats.PreviousMessage != DateTime.MinValue) 
			{
				TimeSpan currentGap = message.Timestamp - stats.PreviousMessage;
				if (currentGap > stats.LargestGap)
					stats.LargestGap = currentGap;
			}
			
			stats.PreviousMessage = message.Timestamp;
		}


		private void DisplayTemporalStats()
		{
			foreach (DictionaryEntry entry in mTemporalStats)
			{
				Console.WriteLine("Temporal statistics for {0}:", entry.Key);

				TemporalStats stats = (TemporalStats) entry.Value;
				Console.WriteLine("  Earliest message : {0}", stats.EarliestMessage);
				Console.WriteLine("  Latest message   : {0}", stats.LatestMessage);
				Console.WriteLine("  Largest gap      : {0}", stats.LargestGap);

				Console.WriteLine();
			}

			Console.WriteLine("Overall temporal statistics:");
			Console.WriteLine("  Earliest message : {0}", mOverallTemporalStats.EarliestMessage);
			Console.WriteLine("  Latest message   : {0}", mOverallTemporalStats.LatestMessage);
			Console.WriteLine("  Largest gap      : {0}", mOverallTemporalStats.LargestGap);
			Console.WriteLine();
		}

		private void SortLogs()
		{
			mLogs.Sort();

			// calculates the highest timestamp to read from the minimal log before resorting
			if (mLogs.Count > 1)
			{
				LogFile log = (LogFile) mLogs[1];
				mMaxTimestamp = log.Message.Timestamp;
			}
			else
				mMaxTimestamp = DateTime.MaxValue;
		}
			

		private LogMessage NextMessage()
		{
			// no logs are left, all messages have been consumed
			if (mLogs.Count == 0)
				return null;

			LogFile log = (LogFile) mLogs[0];
			LogMessage message = log.Message;
			
			// if the current timestamp is greater than max it is time to sort again
			if (log.Message.Timestamp > mMaxTimestamp)
			{
				SortLogs();
				return NextMessage();
			}

			// if the minimal log's next message is null, removes it from the list
			if (log.NextMessage() == null)
				mLogs.Remove(log);


			return message;
		}

		ArrayList mMTLogFilters = new ArrayList();
		ArrayList mMSIXLogFilters = new ArrayList();

		ArrayList mLogs = new ArrayList();
		DateTime mMaxTimestamp;

		string mOutputFilename;
		string mStatsFilename;

		DateTime mNextDay;
		bool mInsertDayBreaks;

		Hashtable mStatistics = new Hashtable();

		Hashtable mTemporalStats = new Hashtable();
		TemporalStats mOverallTemporalStats = new TemporalStats();
	}


	internal class StatisticComparer : IComparer
	{
		public int Compare(object x, object y)
		{
			DictionaryEntry xx = (DictionaryEntry) x;
			DictionaryEntry yy = (DictionaryEntry) y;
			
			if ((int) xx.Value < (int) yy.Value)
				return 1;

			if ((int) xx.Value > (int) yy.Value)
				return -1;

			return 0;
		}
	}
}
