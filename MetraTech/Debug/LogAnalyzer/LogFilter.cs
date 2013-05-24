namespace MetraTech.Debug.LogAnalyzer
{
	using System;
	using System.Text;
	using System.Xml;
	using System.Collections;
	using System.IO;
	using System.Text.RegularExpressions;
	using MetraTech.Xml;

	class LogFilter
	{
		public LogFilter()
		{
			// TODO: support MetraTime
			mFullHeaderRegex = new Regex(@"^([01][0-9]/[0-3][0-9]/[09][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9] \[.*?\]\[.*?\])",
																	 RegexOptions.Compiled);

			mMSIXServiceDefRegex = new Regex(@"<beginsession>\s*?<dn>(.+?)</dn>", RegexOptions.Compiled);

			mUIDRegex = new Regex(@"[\w\d+/]{22}==", RegexOptions.Compiled);
		}

		// adds a condition to the filter
		public void AddCondition(string condition)
		{
			mConditions.Add(new Regex(condition));
		}

		// A substitute output message for a successfully matched input message
		public string SubstituteMessage
    {
			set 
			{
				mSubstituteMessage = value;
			}
			get 
			{
				return mSubstituteMessage;
			}
		}

		// evaluates all conditions on an input message
    // if all conditions match, then the message is included (not filtered)
    public bool Match(string message, out string outputMessage)
		{
			outputMessage = null;

			foreach (Regex condition in mConditions)
			{
				// return immediately if a condition is not met
				// multiple conditions in one filter are ANDed together
				if (!condition.IsMatch(message))
					return false;
			}

			// returns either the original message or substitute message as output
			if (mSubstituteMessage == null)
				outputMessage = message;
			else
				outputMessage = RewriteMessage(message, mSubstituteMessage);


			// TODO: make this optional
			outputMessage = OmitUIDs(outputMessage);

			return true;
		}

		private string RewriteMessage(string message, string substituteMessage)
		{
			string rewrite = null;

			if (substituteMessage.IndexOf("$HEADER") >= 0)
			{
				string header = mFullHeaderRegex.Match(message).Result("$1");
				rewrite = substituteMessage.Replace("$HEADER", header);
			}

			if (substituteMessage.IndexOf("$SERVICEDEF") >= 0)
			{
				if (rewrite == null)
					rewrite = substituteMessage;

				Match m = mMSIXServiceDefRegex.Match(message);
				if (!m.Success) // didn't match
				{
					Console.WriteLine("LogAnalyzer Error: $SERVICEDEF did not match input message!");
					Console.WriteLine("Offending input: {0}", message);
					return substituteMessage;
				}
			
				string serviceDef = m.Result("$1");
				rewrite = rewrite.Replace("$SERVICEDEF", serviceDef);
			}

			if (rewrite == null)
				return substituteMessage;

			return rewrite;
		}

		private string OmitUIDs(string message)
		{
			return mUIDRegex.Replace(message, "[UID OMITTED]");
		}

		ArrayList mConditions = new ArrayList();
		string mSubstituteMessage;

		Regex mFullHeaderRegex;
		Regex mMSIXServiceDefRegex;
		Regex mUIDRegex;
	}
}

