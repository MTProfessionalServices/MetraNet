using System;
using System.IO;
using System.Xml;
using System.Xml.Xsl;
using System.Text;
using System.Diagnostics;

using Interop.msi;

namespace MSIDiff
{
	/// <summary>
	/// Summary description for Differ.
	/// </summary>
	public class Differ
	{
		private FileInfo m_file1;
		private FileInfo m_file2;

		private string m_diffXml;

		public Differ( FileInfo file1, FileInfo file2 )
		{
			Debug.Assert( file1 != null );
			Debug.Assert( file2 != null );

			m_file1 = file1;
			m_file2 = file2;

			Trace.WriteLine( string.Format( "Comparing files {0} and {1}", file1.FullName, file2.FullName ) );
		}

		public void MakeXml()
		{
			Trace.WriteLine( "Making Xml diff report" );

			Installer installer = new WindowsInstaller.Installer() as Installer;
			Debug.Assert( installer != null );

			Database database1 = installer.OpenDatabase( m_file1.FullName, MsiOpenDatabaseMode.msiOpenDatabaseModeReadOnly );
			Database database2 = installer.OpenDatabase( m_file2.FullName, MsiOpenDatabaseMode.msiOpenDatabaseModeReadOnly );

			MemoryStream stream = new MemoryStream();

			using ( DiffWriter writer = new DiffWriter( database1, m_file1.FullName, stream ) )
				writer.Diff( database2, m_file2.FullName );

			stream.Seek( 0, SeekOrigin.Begin );

			m_diffXml = new StreamReader( stream ).ReadToEnd();
			stream.Close();
		}

		public void SaveXml( string path )
		{
			Trace.WriteLine( "Saving Xml diff report to " + path );

			TextWriter writer = new StreamWriter( new FileStream( path, FileMode.Create, FileAccess.Write, FileShare.None ), Encoding.UTF8 );
			writer.Write( m_diffXml );
			writer.Close();
		}

		public void SaveHtml( string path )
		{
			Trace.WriteLine( "Making Html diff report" );

			XslTransform transform = new XslTransform();

			Stream stream = this.GetType().Assembly.GetManifestResourceStream( this.GetType(), "diff.xslt" );

			XmlReader reader = new XmlTextReader( stream );
			transform.Load( reader, null, AppDomain.CurrentDomain.Evidence );
			reader.Close();

			XmlDocument doc = new XmlDocument();
			doc.LoadXml( m_diffXml );

			Trace.WriteLine( "Saving Html diff report to " + path );
			XmlWriter writer = new XmlTextWriter( path, Encoding.UTF8 );
			transform.Transform( doc, null, writer, null );
			writer.Close();
		}
	}
}
