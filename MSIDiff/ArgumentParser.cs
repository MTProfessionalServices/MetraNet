using System;
using System.IO;
using System.Collections;

namespace MSIDiff
{
	/// <summary>
	/// Summary description for ArgumentParser.
	/// </summary>
	public class ArgumentParser
	{
		private Hashtable m_options;
		private ArrayList m_flags;
		private ArrayList m_fileNames;

		public ArgumentParser( string[] args )
		{
			m_options = new Hashtable();
			m_flags = new ArrayList();
			m_fileNames = new ArrayList();

			for ( int i = 0; i < args.Length; i++ )
				ParseArgument( args[i].ToLower() );
		}		

		public bool HasArgument( string name )
		{
			return m_options.Contains( name );
		}

		public string GetArgument( string name )
		{
			return (string)m_options[name];
		}

		public bool CheckFlag( string name )
		{
			return m_flags.Contains( name );
		}

		public FileInfo GetFile( int index )
		{
			return (FileInfo)m_fileNames[index];
		}

		public int FileNameCount
		{
			get
			{
				return m_fileNames.Count;
			}
		}

		private void ParseArgument( string arg )
		{
			int eqPos = arg.IndexOf( '=', 0 );

			if ( eqPos != -1 )
				m_options.Add( arg.Substring( 0, eqPos ), arg.Substring( eqPos + 1 ) );

			else if ( arg.Substring( 0, 1 ) == "-" )
				m_flags.Add( arg.Substring( 1 ) );

			else
				ParseFileName( arg );
		}

		private void ParseFileName( string path )
		{
			FileInfo file = new FileInfo( path );
			if ( !file.Exists )
				throw new ArgumentException( string.Format( "The file {0} could not be found", path ) );

			m_fileNames.Add( file );
		}
	}
}
