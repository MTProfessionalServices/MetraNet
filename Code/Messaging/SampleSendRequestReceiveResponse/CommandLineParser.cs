using System;
using System.Collections;

namespace MetraTech
{
	public interface ICommandLineParser
	{
		void AddOptionPrefix(string prefix);
		void Parse();
		bool OptionExists(string name);

		bool GetBooleanOption(string name);
		bool GetBooleanOption(string name, bool defaultValue);

		int GetIntegerOption(string name);
		int GetIntegerOption(string name, int defaultValue);

		double GetDoubleOption(string name);
		double GetDoubleOption(string name, double defaultValue);

		decimal GetDecimalOption(string name);
		decimal GetDecimalOption(string name, decimal defaultValue);

		string GetStringOption(string name);
		string GetStringOption(string name, string defaultValue);

		DateTime GetDateTimeOption(string name);
		DateTime GetDateTimeOption(string name, DateTime defaultValue);

		object GetOption(string name, TypeCode dataType, bool throwOnError);

 		void CheckForUnusedOptions();
		bool CheckForUnusedOptions(bool throwOnUnused);
	}

	// exceptions thrown from the parser of this type
	public class CommandLineParserException : ApplicationException 
	{ 
		public CommandLineParserException(String message)
			: base(message)
		{ }
	}

	/// <summary>
	/// A general command line option parser which handles .NET style options
	/// </summary>
	public class CommandLineParser : ICommandLineParser
	{
		public CommandLineParser(string [] args)
		{
			mArgs = args;
			mStartOffset = 0;
			mStopOffset = args.Length;
		}

		// restricts which arguments are considered options
		public CommandLineParser(string [] args, int startOffset, int stopOffset)
		{
			mArgs = args;
			mStartOffset = startOffset;
			mStopOffset = stopOffset;
		}

		// allows options with the given prefix to
		// be recognized by the parser
		// NOTE: longer prefixes should be added first
		// NOTE: this should be called before Parse() if used
		public void AddOptionPrefix(string prefix)
		{
			mPrefixes.Add(prefix);
		}

		// parses the argument array into options
		// and stores them for quick retrieval later
		public void Parse()
		{
			if (mPrefixes.Count == 0)
			{
				// adds the default prefixes
				mPrefixes.Add("--");
				mPrefixes.Add("-");
				mPrefixes.Add("/");
			}
				
			for (int i = mStartOffset; i < mStopOffset; i++)
			{
				string arg = mArgs[i];
				string optPrefix, optName, optData;
				SplitArgument(arg, out optPrefix, out optName, out optData);

				mOptions[optName.ToLower()] = optData;
			}
		}

 		// determines if a particular option exists given its name
		public bool OptionExists(string name)
		{
			return mOptions.Contains(name.ToLower());
		}

		// gets the named option as a boolean
		public bool GetBooleanOption(string name)
		{
			return (bool) GetOption(name, TypeCode.Boolean, true); 
		}

		// gets the named option as a boolean
		// if it doesn't exist, returns the default value
		public bool GetBooleanOption(string name, bool defaultValue)
		{
			if (OptionExists(name))
				return GetBooleanOption(name);
			return defaultValue;
		}

		// gets the named option as an integer
		public int GetIntegerOption(string name)
		{
			return (int) GetOption(name, TypeCode.Int32, true); 
		}

		// gets the named option as a boolean
		// if it doesn't exist, returns the default value
		public int GetIntegerOption(string name, int defaultValue)
		{
			if (OptionExists(name))
				return GetIntegerOption(name);
			return defaultValue;
		}

		// gets the named option as a double
		public double GetDoubleOption(string name)
		{
			return (double) GetOption(name, TypeCode.Double, true); 
		}

		// gets the named option as a boolean
		// if it doesn't exist, returns the default value
		public double GetDoubleOption(string name, double defaultValue)
		{
			if (OptionExists(name))
				return GetDoubleOption(name);
			return defaultValue;
		}

		// gets the named option as a decimal
		public decimal GetDecimalOption(string name)
		{
			return (decimal) GetOption(name, TypeCode.Decimal, true); 
		}

		// gets the named option as a boolean
		// if it doesn't exist, returns the default value
		public decimal GetDecimalOption(string name, decimal defaultValue)
		{
			if (OptionExists(name))
				return GetDecimalOption(name);
			return defaultValue;
		}

		// gets the named option as a string
		public string GetStringOption(string name)
		{
			return (string) GetOption(name, TypeCode.String, true); 
		}

		// gets the named option as a boolean
		// if it doesn't exist, returns the default value
		public string GetStringOption(string name, string defaultValue)
		{
			if (OptionExists(name))
				return GetStringOption(name);
			return defaultValue;
		}

		// gets the named option as a datetime
		public DateTime GetDateTimeOption(string name)
		{
			return (DateTime) GetOption(name, TypeCode.DateTime, true); 
		}

		// gets the named option as a boolean
		// if it doesn't exist, returns the default value
		public DateTime GetDateTimeOption(string name, DateTime defaultValue)
		{
			if (OptionExists(name))
				return GetDateTimeOption(name);
			return defaultValue;
		}

		// gets the named option as an object
		public object GetOption(string name, TypeCode dataType, bool throwOnError)
		{
			// looks up the option name
			string optData = (string) mOptions[name.ToLower()];
			if (optData == null)
				if (throwOnError)
					throw new 
						CommandLineParserException(String.Format("Required option '{0}' not supplied", name));
				else
					return null;

			// attempts to parse the option's data
			object value = null;
			switch(dataType)
			{
			case TypeCode.Boolean:
				if (optData == "" || optData == "+")
					value = true;
				else if (optData == "-")
					value = false;
				else
					if (throwOnError)
						throw new 
							CommandLineParserException(String.Format("Invalid boolean data passed to" +
																								 " option '{0}'. Use '+' or '-'.", name));
				break;

			case TypeCode.Int32:
				try 
				{
					value = Int32.Parse(optData);
				}
				catch
				{
					if (throwOnError)
						throw new 
							CommandLineParserException(String.Format("Invalid integer data passed to option '{0}'", name));
				}
				break;

			case TypeCode.Double:
				try 
				{
					value = Double.Parse(optData);
				}
				catch
				{
					if (throwOnError)
						throw new 
							CommandLineParserException(String.Format("Invalid floating point data passed to option '{0}'", name));
				}
				break;

			case TypeCode.Decimal:
				try 
				{
					value = Decimal.Parse(optData);
				}
				catch
				{
					if (throwOnError)
						throw new 
							CommandLineParserException(String.Format("Invalid decimal data passed to option '{0}'", name));
				}
				break;

			case TypeCode.String:
				if (optData == "")
					if (throwOnError)
						throw new 
							CommandLineParserException(String.Format("Invalid string data passed to option '{0}'", name));

				value = optData;
				break;

			case TypeCode.DateTime:
				try 
				{
					value = DateTime.Parse(optData); 
				}
				catch
				{
					if (throwOnError)
						throw new
							CommandLineParserException(String.Format("Invalid datetime data passed to option '{0}'", name));
				}
				break;

			default:
				// always throw 
				throw new
						CommandLineParserException(String.Format("Unknown datatype for option '{0}'", name));
			}

			// marks the option as used
			if (value != null)
				mUsedOptions[name.ToLower()] = true;

			return value;
		}

		// checks for any unused options and throws an exception if any are found 
 		public void CheckForUnusedOptions()
		{
			CheckForUnusedOptions(true);
		}

		// checks for any unused options an returns a boolean (or throws)
 		public bool CheckForUnusedOptions(bool throwOnUnused)
		{
			foreach (DictionaryEntry entry in mOptions)
			{
				string name = (string) entry.Key;
				if (!mUsedOptions.Contains(name))
					if (throwOnUnused)
						throw new
							CommandLineParserException(String.Format("Unrecognized option '{0}' or option " +
																											 "is not permitted in this context.", name));
				  else
						return true;
			}
			return false;
		}

		// splits the argument into three useful parts:
		// option prefix, option name, option data
		private void SplitArgument(string arg, out string optPrefix,
															 out string optName, out string optData)
		{

			// finds the length of the first recognized prefix
			int prefixLen = -1;
			foreach (string prefix in mPrefixes)
			{
				if (prefix.Length > arg.Length)
					continue;

				if (prefix == arg.Substring(0, prefix.Length))
				{
					prefixLen = prefix.Length;
					break;
				}
			}
			if (prefixLen == -1)
				throw new 
					CommandLineParserException(String.Format("Unrecognized option prefix in argument '{0}'", arg));

			optPrefix = arg.Substring(0, prefixLen);


			// finds the data delimiter (if any)
			int colonPos = arg.IndexOfAny(mAssignmentOperators);
			if (colonPos != -1)
			{
				optName = arg.Substring(prefixLen, colonPos - prefixLen);
				optData = arg.Substring(colonPos + 1); 
			}
			else
			{
				string lastChar = new string(arg[arg.Length - 1], 1);
				int modPos = lastChar.IndexOfAny(mBoolModifiers);

				// if no bool modifier was found then
				// assumes that the option is being turned on
				if (modPos == -1)
				{
					if (arg.Length == prefixLen)
						throw new 
							CommandLineParserException(String.Format("No option name given in argument '{0}'", arg));

					optData = "";
					optName = arg.Substring(prefixLen);
				}
				else 
				{
					if (arg.Length - prefixLen <= 1)
						throw new 
							CommandLineParserException(String.Format("No option name given in argument '{0}'", arg));

					optData = arg.Substring(arg.Length - 1); 
					optName = arg.Substring(prefixLen, arg.Length - prefixLen - 1);
				}
			}
		}

		string [] mArgs;
		int mStartOffset;
		int mStopOffset;

		ArrayList mPrefixes = new ArrayList();
		Hashtable mOptions = new Hashtable();
		Hashtable mUsedOptions = new Hashtable();

		readonly char [] mBoolModifiers = {'+', '-'};
		readonly char [] mAssignmentOperators = {':', '='};
	}
	
}
