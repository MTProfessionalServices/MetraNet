using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using MetraTech.DataAccess;

namespace MetraTech.DataAccess
{
  /// <summary>
  /// A delegate to provide simple cursor processing, wherein the managed reader will be managed internally
  /// </summary>
  /// <param name="reader">The cursor to read</param>
  /// <returns>whether to continue processing</returns>
  public delegate bool CursorProcessor ( IMTDataReader reader );

  /// <summary>
  /// Delegate to bind parameters to a statement
  /// </summary>
  /// <param name="queryId">the query id of the statement being bound (for logging)</param>
  /// <param name="stmt">the statement to bind the parameters to</param>
  public delegate void ParameterBinder ( string queryId, IMTAdapterStatement stmt );

  /// <summary>
  /// How to handle enumeration bindings
  /// </summary>
  public enum EnumBindingType
  {
    /// <summary>
    /// Use the name of the enumeration value, e.g., USD for currency
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1707:IdentifiersShouldNotContainUnderscores" )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "USE" )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "NAME" )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "ENUM" )]
    USE_ENUM_NAME,
    /// <summary>
    /// Use the id_enum_data id of the enumeration value, e.g., 2379 for USD
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1707:IdentifiersShouldNotContainUnderscores" )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "USE" )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "ID" )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "ENUM" )]
    USE_ENUM_ID,
    /// <summary>
    /// Use the internal enumeration value, e.g, 0
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "USE" )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1707:IdentifiersShouldNotContainUnderscores" )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "VAL" )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "ENUM" )]
    USE_ENUM_VAL
  }

  /// <summary>
  /// Database utility methods.
  /// </summary>
  [System.Diagnostics.CodeAnalysis.SuppressMessage ( "Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Utils" )]
  public static class DatabaseUtils
  {
    /// <summary>
    /// Execute a query (using the query tag as the identifier to log perf messages with).
    /// This method can thrown an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages to</param>
    /// <param name="queryPath">Path to the queries file</param>
    /// <param name="queryTag">Tag of the query to use</param>
    /// <param name="binder">Parameters to pass to this query</param>
    /// <param name="processor">Cursor processor</param>
    /// <returns>How many rows were processed, or null if no processor was passed in.</returns>
    public static int? ExecuteQuery (Logger logger, string queryPath, string queryTag, ParameterBinder binder, CursorProcessor processor )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      using ( IMTConnection conn = ConnectionManager.CreateConnection () )
      {
        return ExecuteQuery ( logger, queryPath, queryTag, conn, binder, processor );
      }
    }

    /// <summary>
    /// Execute a query with a unique query id.
    /// This method can throw an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages to</param>
    /// <param name="queryId">A unique id to log perf messages with</param>
    /// <param name="queryPath">Path to the queries file</param>
    /// <param name="queryTag">Tag of the query to use</param>
    /// <param name="binder">Parameters to pass to this query</param>
    /// <param name="processor">Cursor processor</param>
    /// <returns>How many rows were processed, or null if no processor was passed in.</returns>
    public static int? ExecuteQuery ( Logger logger, string queryId, string queryPath, string queryTag, ParameterBinder binder, CursorProcessor processor )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      using ( IMTConnection conn = ConnectionManager.CreateConnection () )
      {
        return ExecuteQuery ( logger, queryId, queryPath, queryTag, conn, binder, processor );
      }
    }

    /// <summary>
    /// Execute a query (using the query tag as the identifier to log perf messages with) using supplied connection.
    /// This method can thrown an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages to</param>
    /// <param name="queryPath">Path to the queries file</param>
    /// <param name="queryTag">Tag of the query to use</param>
    /// <param name="conn">The connection to use</param>
    /// <param name="binder">Parameters to pass to this query</param>
    /// <param name="processor">Cursor processor</param>
    /// <returns>How many rows were processed, or null if no processor was passed in.</returns>
    public static int? ExecuteQuery ( Logger logger, string queryPath, string queryTag, IMTConnection conn, ParameterBinder binder, CursorProcessor processor )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      if ( conn == null )
      {
        throw new ArgumentNullException ( "conn" );
      }
      string queryId = queryTag;
      using ( IMTAdapterStatement stmt = conn.CreateAdapterStatement ( queryPath, queryTag ) )
      {
        return ExecuteQuery ( logger, queryId, stmt, binder, processor );
      }
    }

    /// <summary>
    /// Execute a query with a unique query id using supplied connection.
    /// This method can thrown an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages to</param>
    /// <param name="queryId">A unique id to log perf messages with</param>
    /// <param name="queryPath">Path to the queries file</param>
    /// <param name="queryTag">Tag of the query to use</param>
    /// <param name="conn">The connection to use</param>
    /// <param name="binder">Parameters to pass to this query</param>
    /// <param name="processor">Cursor processor</param>
    /// <returns>How many rows were processed, or null if no processor was passed in.</returns>
    public static int? ExecuteQuery ( Logger logger, string queryId, string queryPath, string queryTag, IMTConnection conn, ParameterBinder binder, CursorProcessor processor )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      if ( conn == null )
      {
        throw new ArgumentNullException ( "conn" );
      }
      using ( IMTAdapterStatement stmt = conn.CreateAdapterStatement ( queryPath, queryTag ) )
      {
        return ExecuteQuery ( logger, queryId, stmt, binder, processor );
      }
    }
    /// <summary>
    /// Execute a statement with a unique query id using supplied connection.
    /// This method can throw an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages to</param>
    /// <param name="queryId">A unique id to log perf messages with</param>
    /// <param name="stmt">The statement to execute</param>
    /// <param name="binder">Parameters to pass to this query</param>
    /// <param name="processor">Cursor processor</param>
    /// <returns>How many rows were processed, or null if no processor was passed in.</returns>
    public static int? ExecuteQuery ( Logger logger, string queryId, IMTAdapterStatement stmt, ParameterBinder binder, CursorProcessor processor )
    {
      if ( string.IsNullOrEmpty ( queryId ) )
      {
        throw new ArgumentNullException ( "queryId", "QueryID is required" );
      }
      if ( stmt == null )
      {
        throw new ArgumentNullException ( "stmt" );
      }
      if ( binder != null )
      {
        binder.Invoke ( queryId, stmt );
      }
      if ( logger != null && logger.WillLogDebug )
      {
        logger.LogDebug ( "Executing SQL: {0} for {1}", stmt.Query, queryId );
      }
     
      {
        int count = 0;
        try
        {
          using ( IMTDataReader reader = stmt.ExecuteReader () )
          {
            if ( processor == null )
            {
              return null;
            }
            while ( reader.Read () && processor.Invoke ( reader ) )
            {
              count++;
            }

            if ( logger != null && logger.WillLogDebug)
            {
              logger.LogDebug ( "Processed {0} rows for {1}", count, queryId);
            }
            return count;
          }
        }
        catch ( Exception )
        {

          if ( logger != null && logger.WillLogDebug)
          {
            logger.LogDebug ( "Query failed after processing {0} rows for {1}", count, queryId);
          }
          throw;
        }
      }
    }

    /// <summary>
    /// Execute query.  This method can thrown an exception.
    /// </summary>
    /// <param name="logger">the logger</param>
    /// <param name="queryPath">the query path</param>
    /// <param name="queryTag">the query tag</param>
    /// <param name="binder">the input binder</param>
    /// <returns>the cursor</returns>
    public static IMTDataReader ExecuteQuery ( Logger logger, string queryPath, string queryTag, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      using ( IMTConnection conn = ConnectionManager.CreateConnection () )
      {
        return ExecuteQuery ( logger, queryPath, queryTag, conn, binder );
      }
    }

    /// <summary>
    /// Execute query.  This method can thrown an exception.
    /// </summary>
    /// <param name="logger">the logger</param>
    /// <param name="queryId">the query identifier</param>
    /// <param name="queryPath">the query path</param>
    /// <param name="queryTag">the query tag</param>
    /// <param name="binder">the input binder</param>
    /// <returns>the cursor</returns>
    public static IMTDataReader ExecuteQuery ( Logger logger, string queryId, string queryPath, string queryTag, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      using ( IMTConnection conn = ConnectionManager.CreateConnection () )
      {
        return ExecuteQuery ( logger, queryId, queryPath, queryTag, conn, binder );
      }
    }

    /// <summary>
    /// Execute query.  This method can thrown an exception.
    /// </summary>
    /// <param name="logger">the logger</param>
    /// <param name="queryPath">the query path</param>
    /// <param name="queryTag">the query tag</param>
    /// <param name="conn">the connection</param>
    /// <param name="binder">the input binder</param>
    /// <returns>the cursor</returns>
    public static IMTDataReader ExecuteQuery ( Logger logger, string queryPath, string queryTag, IMTConnection conn, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      if ( conn == null )
      {
        throw new ArgumentNullException ( "conn" );
      }
      string queryId = queryTag;
      using ( IMTAdapterStatement stmt = conn.CreateAdapterStatement ( queryPath, queryTag ) )
      {
        return ExecuteQuery ( logger, queryId, stmt, binder );
      }
    }

    /// <summary>
    /// Execute query.  This method can throw an exception.
    /// </summary>
    /// <param name="logger">the logger</param>
    /// <param name="queryId">the query identifier</param>
    /// <param name="queryPath">the query path</param>
    /// <param name="queryTag">the query tag</param>
    /// <param name="conn">the connection</param>
    /// <param name="binder">the input binder</param>
    /// <returns>the cursor</returns>
    public static IMTDataReader ExecuteQuery ( Logger logger, string queryId, string queryPath, string queryTag, IMTConnection conn, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      if ( conn == null )
      {
        throw new ArgumentNullException ( "conn" );
      }
      using ( IMTAdapterStatement stmt = conn.CreateAdapterStatement ( queryPath, queryTag ) )
      {
        return ExecuteQuery ( logger, queryId, stmt, binder );
      }
    }

    /// <summary>
    /// Execute query.  This method can throw an exception.
    /// </summary>
    /// <param name="logger">the logger</param>
    /// <param name="queryId">the query identifier</param>
    /// <param name="stmt">the statement</param>
    /// <param name="binder">the input binder</param>
    /// <returns>the cursor</returns>
    public static IMTDataReader ExecuteQuery ( Logger logger, string queryId, IMTAdapterStatement stmt, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryId ) )
      {
        throw new ArgumentNullException ( "queryId", "QueryID is required" );
      }
      if ( stmt == null )
      {
        throw new ArgumentNullException ( "stmt" );
      }
      if ( binder != null )
      {
        binder.Invoke ( queryId, stmt );
      }
      if ( logger != null && logger.WillLogDebug )
      {
        logger.LogDebug ( "Executing SQL: {0} for {1}", stmt.Query, queryId );
      }
     
      {
        try
        {
          IMTDataReader reader = stmt.ExecuteReader ();

          if ( logger != null && logger.WillLogDebug)
          {
              logger.LogDebug("Executed query {0} ", queryId);
          }
          return reader;
        }
        catch ( Exception )
        {

          if ( logger != null && logger.WillLogDebug)
          {
              logger.LogDebug("Query failed for {0} ", queryId);
          }
          throw;
        }
      }
    }

    /// <summary>
    /// Execute an update/insert/storedproc statement (using queryTag as the uniqueId).
    /// This method can throw an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages with</param>
    /// <param name="queryPath">path to the queries file</param>
    /// <param name="queryTag">tag of the query to execute</param>
    /// <param name="binder">parameters to pass to the query</param>
    /// <returns>the number of rows</returns>
    public static int ExecuteNonQuery ( Logger logger, string queryPath, string queryTag, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      using ( IMTConnection conn = ConnectionManager.CreateConnection () )
      {
        return ExecuteNonQuery ( logger, queryPath, queryTag, conn, binder );
      }
    }

    /// <summary>
    /// Execute an update/insert/storedproc statement with a unique id
    /// This method can throw an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages with</param>
    /// <param name="queryId">The id to use for logging perf messages with</param>
    /// <param name="queryPath">path to the queries file</param>
    /// <param name="queryTag">tag of the query to execute</param>
    /// <param name="binder">parameters to pass to the query</param>
    /// <returns>the number of rows</returns>
    public static int ExecuteNonQuery ( Logger logger, string queryId, string queryPath, string queryTag, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      using ( IMTConnection conn = ConnectionManager.CreateConnection () )
      {
        return ExecuteNonQuery ( logger, queryId, queryPath, queryTag, conn, binder );
      }
    }

    /// <summary>
    /// Execute an update/insert/storedproc statement using the supplied connection
    /// This method can throw an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages with</param>
    /// <param name="queryPath">path to the queries file</param>
    /// <param name="queryTag">tag of the query to execute</param>
    /// <param name="conn">The connection to use</param>
    /// <param name="binder">parameters to pass to the query</param>
    /// <returns>the number of rows</returns>
    public static int ExecuteNonQuery ( Logger logger, string queryPath, string queryTag, IMTConnection conn, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      if ( conn == null )
      {
        throw new ArgumentNullException ( "conn" );
      }
      string queryId = queryTag;
      using ( IMTAdapterStatement stmt = conn.CreateAdapterStatement ( queryPath, queryTag ) )
      {
        return ExecuteNonQuery ( logger, queryId, stmt, binder );
      }
    }

    /// <summary>
    /// Execute an update/insert/storedproc statement using the supplied connection
    /// This method can throw an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages with</param>
    /// <param name="queryId">The id to use for logging perf messages with</param>
    /// <param name="queryPath">path to the queries file</param>
    /// <param name="queryTag">tag of the query to execute</param>
    /// <param name="conn">The connection to use</param>
    /// <param name="binder">parameters to pass to the query</param>
    /// <returns>the number of rows</returns>
    public static int ExecuteNonQuery ( Logger logger, string queryId, string queryPath, string queryTag, IMTConnection conn, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryPath ) )
      {
        throw new ArgumentNullException ( "queryPath", "QueryPath must be set" );
      }
      if ( string.IsNullOrEmpty ( queryTag ) )
      {
        throw new ArgumentNullException ( "queryTag", "QueryTag must be set" );
      }
      if ( conn == null )
      {
        throw new ArgumentNullException ( "conn" );
      }
      using ( IMTAdapterStatement stmt = conn.CreateAdapterStatement ( queryPath, queryTag ) )
      {
        return ExecuteNonQuery ( logger, queryId, stmt, binder );
      }
    }

    /// <summary>
    /// Execute an update/insert/storedproc statement using the statement object
    /// This method can throw an exception.
    /// </summary>
    /// <param name="logger">The logger to log messages with</param>
    /// <param name="queryId">The id to log the perf messages with</param>
    /// <param name="stmt">The statement to execute</param>
    /// <param name="binder">parameters to pass to the query</param>
    /// <returns>the number of rows</returns>
    public static int ExecuteNonQuery ( Logger logger, string queryId, IMTAdapterStatement stmt, ParameterBinder binder )
    {
      if ( string.IsNullOrEmpty ( queryId ) )
      {
        throw new ArgumentNullException ("queryId", "QueryID is required" );
      }
      if ( stmt == null )
      {
        throw new ArgumentNullException ( "stmt" );
      }
      if ( binder != null )
      {
        binder.Invoke ( queryId, stmt );
      }
      if ( logger != null && logger.WillLogDebug)
      {
          logger.LogDebug("Executing SQL: {0} for {1}", stmt.Query, queryId);
      }
      
      {
        try
        {
          int result = stmt.ExecuteNonQuery ();

          if ( logger != null && logger.WillLogDebug )
          {
            logger.LogDebug ( "Query returned {0} for {1}", result, queryId );
          }
          return result;
        }
        catch ( Exception )
        {

          if ( logger != null && logger.WillLogDebug )
          {
            logger.LogDebug ( "Query failed for {0}", queryId);
          }
          throw;
        }
      }
    }

  }
}
