using System;
using System.IO;
using System.Diagnostics;

namespace MSIDiff
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class App
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static int Main(string[] args)
		{
			try
			{
				ArgumentParser arguments = new ArgumentParser( args );

				if ( CheckArguments( arguments ) == false )
				{
					ShowUsage();
				}
				else
				{
					if ( arguments.CheckFlag( "verbose" ) )
						Trace.Listeners.Add( new TextWriterTraceListener( Console.Out ) );
				
					GenerateDiff( arguments );
				}
			}
			catch ( ArgumentException e )
			{
				Console.WriteLine( e.Message );
				return 1;
			}
			catch ( Exception e )
			{
				Console.WriteLine( "Error: " + e.Message );
				return 1;
			}

			return 0;
		}

		private static bool CheckArguments( ArgumentParser arguments )
		{
			if ( arguments.FileNameCount < 2 || arguments.FileNameCount > 2 || arguments.HasArgument( "help" ) )
				return false;

			if ( arguments.GetFile( 0 ).Extension.ToLower() != ".msi" && arguments.GetFile( 0 ).Extension.ToLower() != ".msm" )
				throw new ArgumentException( string.Format( "{0} is not a windows installer database", arguments.GetFile( 0 ) ) );
			
			if ( arguments.GetFile( 1 ).Extension.ToLower() != ".msi" && arguments.GetFile( 1 ).Extension.ToLower() != ".msm" )
				throw new ArgumentException( string.Format( "{0} is not a windows installer database", arguments.GetFile( 1 ) ) );
			
			if ( arguments.GetFile( 0 ).FullName == arguments.GetFile( 1 ).FullName )
				throw new ArgumentException( "Cannot compare a file to itself" );

			return true;
		}

		private static void ShowUsage()
		{
			Console.WriteLine( "MSIDiff <PATH1> <PATH2> [-html] [-xml] [out=<PATH3>] [-view] [-verbose]" );
			Console.WriteLine( "" );
			Console.WriteLine( "PATH1 and PATH2 are paths to the MSI or MSM databases to compare" );
			Console.WriteLine( "-html or -xml indicate what type of output to generate" );
			Console.WriteLine( "PATH3 is the name of the output file to create" );
			Console.WriteLine( "\tIf not specified, the output will be created in the same folder as PATH1 with a name derived from the input files" );
			Console.WriteLine( "\tIf PATH3 is relative, it will be created relative to PATH1" );
			Console.WriteLine( "-view will open the output file in a web browser" );
			Console.WriteLine( "\tIf both -xml and -html are specified the html will be shown" );
			Console.WriteLine( "-verbose outputs status to the console" );
		}

		private static void GenerateDiff( ArgumentParser arguments )
		{
			FileInfo file1 = arguments.GetFile( 0 );
			FileInfo file2 = arguments.GetFile( 1 );

			Differ differ = new Differ( file1, file2 );
			differ.MakeXml();

			string outPath = string.Format( "{0}_{1}", file1.Name, file2.Name );

			if ( arguments.HasArgument( "out" ) )
				outPath = arguments.GetArgument( "out" );

			if ( Path.GetDirectoryName( outPath ) == "" )
				outPath = Path.Combine( file1.Directory.FullName, outPath );
			
			else if ( Path.IsPathRooted( outPath ) == false )
				outPath = Path.GetFullPath( outPath );

			if ( arguments.CheckFlag( "xml" ) )
				differ.SaveXml( Path.ChangeExtension( outPath, "xml" ) );

			if ( arguments.CheckFlag( "html" ) )
				differ.SaveHtml( Path.ChangeExtension( outPath, "html" ) );

			if ( arguments.CheckFlag( "view" ) )
			{
				if ( arguments.CheckFlag( "html" ) )
					Process.Start( Path.ChangeExtension( outPath, "html" ) );

				else if ( arguments.CheckFlag( "xml" ) )
					Process.Start( Path.ChangeExtension( outPath, "xml" ) );
			}

			Trace.WriteLine( "Done" );
		}
	}
}
