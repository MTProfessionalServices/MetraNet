using System;
using System.IO;
using System.Xml;
using System.Text;
using System.Diagnostics;
using System.Collections;

using WindowsInstaller;
using Interop.msi;

namespace MSIDiff
{
	/// <summary>
	/// Summary description for Writer.
	/// </summary>
	public class DiffWriter : IDisposable
	{
		private XmlTextWriter m_writer;
		private Database m_database;

		public DiffWriter( Database referenceDatabase, string dbPath, Stream stream )
		{
			Debug.Assert( referenceDatabase != null );
			Debug.Assert( stream != null );

			m_database = referenceDatabase;
			m_writer = new XmlTextWriter( stream, Encoding.UTF8 );
			m_writer.Formatting = Formatting.Indented;

			m_writer.WriteStartDocument();
			m_writer.WriteStartElement( "msiDiff" );

			WriteDatabaseSummary( dbPath, m_database.get_SummaryInformation( 0 ) );
		}

		public void Dispose()
		{
			m_writer.WriteEndElement();
			m_writer.WriteEndDocument();
			m_writer.Flush();
		}

		public void Diff( Database database, string filePath )
		{
			SummaryInfo summary1 = m_database.get_SummaryInformation( 0 );
			SummaryInfo summary2 = database.get_SummaryInformation( 0 );

			WriteDatabaseSummary( filePath, summary2 );
			WriteSummaryDiff( summary1, summary2 );

			string tmp = Path.GetTempFileName();
			File.Delete( tmp );

			Trace.WriteLine( "Generating diff transform" );
			if ( database.GenerateTransform( m_database, tmp ) )
			{
				m_database.ApplyTransform( tmp, MsiTransformError.msiTransformErrorViewTransform );
				WriteTransformDiff();
			}
		}

		public void WriteDatabaseSummary( string filePath, SummaryInfo summary )
		{
			m_writer.WriteStartElement( "database" );
			m_writer.WriteAttributeString( "file", filePath );

			Trace.WriteLine( "Summary stream for " + filePath );
			Trace.Indent();

			foreach ( PropertyId id in Enum.GetValues( typeof( PropertyId ) ) )
				WriterSummaryProperty( summary, id );

			Trace.Unindent();
			m_writer.WriteEndElement();
		}

		public void WriteSummaryDiff( SummaryInfo summary1, SummaryInfo summary2 )
		{
			m_writer.WriteStartElement( "summaryStream" );
			Trace.WriteLine( "Summary stream differences:" );
			Trace.Indent();
			foreach ( PropertyId id in Enum.GetValues( typeof( PropertyId ) ) )
			{
				object property1 = summary1.get_Property( (int)id );
				object property2 = summary2.get_Property( (int)id );

				if ( property1 != null && property2 != null )
				{
					string value1 = property1.ToString();
					string value2 = property2.ToString();

					if ( value1 != value2 )
					{
						m_writer.WriteStartElement( "value" );
						m_writer.WriteAttributeString( "name", id.ToString() );
						m_writer.WriteElementString( "old", value1 );
						m_writer.WriteElementString( "new", value2 );
						m_writer.WriteEndElement();

						Trace.WriteLine( string.Format( "{0} old={1} new={2}", id.ToString(), value1, value2 ) );
					}
				}
			}
			Trace.Unindent();

			m_writer.WriteEndElement();
		}

		private void WriteChange( string rowName, Record change, bool isChangedRow )
		{
			string column = change.get_StringData( 1 );
			string oldValue = change.get_StringData( 2 );
			string newValue = change.get_StringData( 3 );

			m_writer.WriteStartElement( "column" );
			m_writer.WriteAttributeString( "name", column );

			Trace.Indent();

			if ( isChangedRow )
			{
				m_writer.WriteElementString( "old", oldValue );
				m_writer.WriteElementString( "new", newValue );
				Trace.WriteLine( string.Format( "{0} old={1} new={2}", column, oldValue, newValue ) );
			}
			else
			{
				m_writer.WriteElementString( "value", newValue );
				Trace.WriteLine( string.Format( "{0}={1}", column, newValue ) );
			}

			Trace.Unindent();
			m_writer.WriteEndElement();
		}
		
		private int CountRecords( string sql )
		{
			using ( ViewHolder holder = new ViewHolder( m_database.OpenView( sql ) ) )
				return holder.GetRecordCount();
		}

		private void WriteRow( string tableName, Record row )
		{
			string rowName = row.get_StringData( 1 );

			m_writer.WriteStartElement( "row" );
			m_writer.WriteAttributeString( "name", rowName );

			string selector = "`Table` = '" + tableName + "' AND `Row` = '" + rowName + "'";

			bool isNewRow = CountRecords( "SELECT * FROM `_TransformView` WHERE `Column` = 'INSERT' AND " + selector ) == 1;
			bool isDroppedRow = CountRecords( "SELECT * FROM `_TransformView` WHERE `Column` = 'DELETE' AND " + selector ) == 1;
			
			Debug.Assert( ( !isNewRow && !isDroppedRow ) || isNewRow ^ isDroppedRow );

			if ( isNewRow )
			{
				Trace.WriteLine( "New row" );
				m_writer.WriteAttributeString( "type", "INSERT" );
			}
			else if ( isDroppedRow )
			{
				Trace.WriteLine( "Deleted row\n\tPK=" + rowName );
				m_writer.WriteAttributeString( "type", "DELETE" );
			}
			else 
			{
				Trace.WriteLine( "Changed row" );
				m_writer.WriteAttributeString( "type", "CHANGED" );
			}

			string sql = "SELECT `Column`, `Current`, `Data` FROM `_TransformView` WHERE "
				+ selector + " AND `Column` <> 'INSERT' AND `Column` <> 'DELETE'";

			using ( ViewHolder changes = new ViewHolder( m_database.OpenView( sql ) ) )
			{
				foreach( Record change in changes )	
					WriteChange( rowName, change, !( isNewRow | isDroppedRow ) );
			}

			Trace.WriteLine( "" );
			m_writer.WriteEndElement();
		}

		private void WriteTable( Record table )
		{
			string tableName = table.get_StringData( 1 );

			m_writer.WriteStartElement( "table" );
			m_writer.WriteAttributeString( "name", tableName );

			Trace.WriteLine( string.Format( "{0} table differences:", tableName ) );
			Trace.Indent();

			string sql = "SELECT DISTINCT `Row` FROM `_TransformView` WHERE `Table` = '" + tableName  + "' AND `Row` <> NULL";
			using ( ViewHolder rows = new ViewHolder( m_database.OpenView( sql ) ) )
			{
				foreach( Record row in rows )	
					WriteRow( tableName, row );

				sql = "SELECT DISTINCT `Column`, `Data`, `Current` FROM `_TransformView` WHERE `Table` = '" + tableName  + "' AND `Row` = NULL";
				if ( CountRecords( sql ) > 0 )
				{
					m_writer.WriteStartElement( "schemaChange" );

					using ( ViewHolder schemaChanges = new ViewHolder( m_database.OpenView( sql ) ) )
					{
						foreach( Record schemaChange in schemaChanges )	
							WriteSchemaChange( schemaChange );
					}

					m_writer.WriteEndElement();
				}
			}

			Trace.Unindent();
			m_writer.WriteEndElement();
		}

		private void WriteSchemaChange( Record schemaChange )
		{
			if ( schemaChange.get_IsNull( 2 ) == false )
			{
				Trace.WriteLine( "Schema Change:" );
				Trace.WriteLine( string.Format( "{0} old={1} new={2}", schemaChange.get_StringData( 1 ), schemaChange.get_StringData( 2 ), DecodeColDef( schemaChange.get_IntegerData( 3 ) ) ) );

				m_writer.WriteStartElement( "value" );
				m_writer.WriteAttributeString( "name", schemaChange.get_StringData( 1 ) );
				m_writer.WriteElementString( "old", schemaChange.get_StringData( 2 ) );
				m_writer.WriteElementString( "new", DecodeColDef( schemaChange.get_IntegerData( 3 ) ) );
				m_writer.WriteEndElement();
			}
		}

		public void WriteTransformDiff()
		{
			string sql = "SELECT DISTINCT `Table` FROM `_TransformView`";
			using ( ViewHolder tables = new ViewHolder( m_database.OpenView( sql ) ) )
			{
				foreach( Record table in tables )	
					WriteTable( table );
			}
		}

		private string DecodeColDef( int colDef )
		{
			string ret = string.Empty;

			switch ( colDef & ( (int)ColumnType.icdShort | (int)ColumnType.icdObject ) )
			{
				case (int)ColumnType.icdLong:
					ret = "LONG";
					break;

				case (int)ColumnType.icdShort:
					ret = "SHORT";
					break;

				case (int)ColumnType.icdObject:
					ret = "OBJECT";
					break;

				case (int)ColumnType.icdString:
					ret = "CHAR(" + (colDef & 255) + ")";
					break;
			}
			
			if ( ( colDef & (int)ColumnType.icdNullable ) == 0 ) 
				ret += " NOT NULL";

			if ( ( colDef & (int)ColumnType.icdPrimaryKey ) != 0 )
				ret += " PRIMARY KEY";
			
			return ret;
		}

		private void WriterSummaryProperty( SummaryInfo summary, PropertyId id )
		{
			object property = summary.get_Property( (int)id );
			if ( property != null )
			{
				m_writer.WriteElementString( id.ToString(), property.ToString() );
				Trace.WriteLine( string.Format( "{0} = {1}", id.ToString(), property.ToString() ) );
			}
		}
	}
}
