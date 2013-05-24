using System;
using System.Collections;
using System.IO;

namespace MetraTech.Debug
{

 	/// <summary>
	/// CleanPath is a simple tool that checks path-based environment
	/// variables for invalid directory entries.
 	/// </summary>
	public class CleanPath
	{
		public static void Main(string [] argv)
		{
			// checks PATH, INCLUDE, and LIB by default
			if (argv.Length == 0)
			{
				CheckVariable("PATH");
				CheckVariable("INCLUDE");
				CheckVariable("LIB");
			}
			else
			{
				if ((argv.Length == 1) && (argv[0] == "/?"))
				{
					PrintUsage();
					return;
				}
				
				// checks user supplied variables
				foreach (string var in argv)
				{
					CheckVariable(var);
				}
			}
		}

		private static void CheckVariable(string name)
		{
			Console.Write("Checking {0} variable...", name.ToUpper());

			PathBasedVariable path = new PathBasedVariable(name);

			// is the variable set?
			if (!path.IsSet)
			{
				Console.Write("!!");
 				Console.WriteLine();
 				Console.WriteLine();
				Console.WriteLine("  Variable is not currently set!");
				Console.WriteLine();
				return;
			}

			// are there invalid directories?
			if (path.HasInvalidDirectories)
			{
				Console.WriteLine("!!");
				Console.WriteLine();
				Console.WriteLine("  Invalid directory entries found:");
				foreach (string dir in path.InvalidDirectories)
				{
					Console.WriteLine("    {0}", dir);
				}

				Console.WriteLine();
				Console.WriteLine("  Clean version:");
				Console.WriteLine();
				foreach (string dir in path.ValidDirectories)
				{
					Console.Write("{0};", dir);
				}
				Console.WriteLine();
				Console.WriteLine();
			}
			// are there any duplicates?
			else if (path.HasDuplicateDirectories)
			{
				Console.WriteLine("!!");
				Console.WriteLine();
				Console.WriteLine("  Duplicate directory entries found:");
				foreach (string dir in path.DuplicateDirectories)
				{
					Console.WriteLine("    {0}", dir);
				}

				Console.WriteLine();
				Console.WriteLine("  Clean version:");
				Console.WriteLine();
				foreach (string dir in path.ValidDirectories)
				{
					Console.Write("{0};", dir);
				}
				Console.WriteLine();
				Console.WriteLine();
			}
			else
			{
				Console.WriteLine("OK");
			}
		}

		private static void PrintUsage()
		{
			Console.WriteLine("Usage: cleanpath [/?] [var1] [var2] [...]");
			Console.WriteLine("       cleanpath with no arguments checks PATH, INCLUDE, and LIB variables");
			Console.WriteLine();
			Console.WriteLine("Examples: ");
			Console.WriteLine("   cleanpath");
			Console.WriteLine("   cleanpath CLASSPATH DEVPATH");
			Console.WriteLine();
		}
	}


	/// <summary>
	/// A class that encapsulates a path-based variable
	/// </summary>
	public class PathBasedVariable
	{
		public PathBasedVariable(string name)
		{
			mRawValue = Environment.GetEnvironmentVariable(name);
			if (!IsSet)
				return;

			Parse();
		}
	
		public bool IsSet
		{
			get 
			{
				return !(mRawValue == null);
			}
		}

		public string [] Directories
		{
			get
			{
				return mDirectories;
			}
		}

		public ArrayList ValidDirectories
		{
			get
			{
				return ArrayList.ReadOnly(mValidDirectories);
			}
		}

		public ArrayList InvalidDirectories
		{
			get
			{
				return ArrayList.ReadOnly(mInvalidDirectories);
			}
		}

		public ArrayList DuplicateDirectories
		{
			get
			{
				return ArrayList.ReadOnly(mDuplicateDirectories);
			}
		}

		public bool HasInvalidDirectories
		{
			get
			{
				return mInvalidDirectories.Count > 0;
			}
		}

		public bool HasDuplicateDirectories
		{
			get
			{
				return mDuplicateDirectories.Count > 0;
			}
		}

		private void Parse()
		{
			Hashtable dirHash = new Hashtable();

			mDirectories = mRawValue.Split(';');
			foreach (string dir in mDirectories)
			{
				if (dir != String.Empty)
				{
					// detects duplicates
					if (!dirHash.Contains(dir))
					{
						dirHash.Add(dir, null);

						// detects dead directories
						if (Directory.Exists(dir))
							mValidDirectories.Add(dir);
						else
							mInvalidDirectories.Add(dir);
					}
					else
						mDuplicateDirectories.Add(dir);
				}
			}
		}

		private string mRawValue;
		private string [] mDirectories;
		private ArrayList mValidDirectories = new ArrayList();
		private ArrayList mInvalidDirectories = new ArrayList();
		private ArrayList mDuplicateDirectories = new ArrayList();
	}
}
