using System;
using System.Runtime.InteropServices;
using System.Collections;

using MetraTech;
using QueryAdapter = MetraTech.Interop.QueryAdapter;
using MTSQL = MetraTech.MTSQL;

[assembly: GuidAttribute("08611ee6-b62a-4bfc-a15c-c2a866794ea8")]

namespace MetraTech.DataAccess
{

	/// <summary>
	/// QueryHinter is used to add custom runtime logic that decides when
	/// and where to emit hints to a query based on pre-established input parameters.
	/// </summary>
	[ComVisible(true)]
	[Guid("56336e5a-dfaa-47b5-9f8c-7ff53af5a884")]
	public interface IQueryHinter
	{

		/// <summary>
		/// Initializes the hinter. (internal use only)
		/// </summary>
		void Initialize(string hinterSource, string queryTag);
		
		/// <summary>
		/// Compiles the hinter given the associated query adapter. (internal use only)
		/// </summary>
		void Compile(QueryAdapter.IMTQueryAdapter queryAdapter);

		/// <summary>
		/// Sets the value of one of the hinter's input parameters.
		/// </summary>
		void AddParam(string name, object value);

		/// <summary>
		/// Executes the hinter given the input parameters and
		/// applies the hint to the associated query.
		/// </summary>
		void Apply();

		/// <summary>
		/// Returns the query adapter associated with this hinter.
		/// </summary>
		QueryAdapter.IMTQueryAdapter QueryAdapter
		{
			get;
		}
	}

	[ComVisible(true)]
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("d180b6be-e01e-473b-90d9-4bc53cb08d21")]
	public class QueryHinter : IQueryHinter
	{
		public void Initialize(string hinterSource, string queryTag)
		{
			mLogger.LogDebug("Initializing hinter for for query '{0}'", queryTag);
			mQueryTag = queryTag;
			mHinterSource = hinterSource;
		}

		public void Compile(QueryAdapter.IMTQueryAdapter queryAdapter)
		{
			mQueryAdapter = queryAdapter;

			if (mInitialized)
				return;

			mLogger.LogDebug("Compiling hinter for query '{0}'...", mQueryTag);
			
			// compiles the hinter
			mExe = new MTSQL.ExecutionEngine();
			try
			{
				mExe.Compile(mHinterSource);
			}
			// TODO: MTSQL should throw a more specific exception
			catch (ApplicationException e)
			{
				throw new QueryHinterCompilationException(mQueryTag, e);
			}

			// validates hinter parameters:
			//    - at least one input parameter must be given
			//    - at least one output parameter must be given
			//    - output parameters must be of type string (varchar)
			//    - normalized output paramter names are found in the query string
			int inCount = 0;
			int outCount = 0;
			string rawQueryString = mQueryAdapter.GetRawSQLQuery(false);
      foreach (DictionaryEntry paramEntry in mExe.ProgramParameters)
			{
				MTSQL.Parameter parameter = (MTSQL.Parameter) paramEntry.Value;
				
				if (parameter.Direction == MTSQL.ParameterDirection.Out)
				{
					outCount++;

					// validates output parameter is of string type
					if (parameter.DataType != MTSQL.ParameterDataType.WideString)
						throw new QueryHinterOutputParameterTypeMismatchException(mQueryTag, parameter);

					// checks for the existence of the normalized parameter name in the query string
					string normalizedName = NormalizeParameterName(parameter);
					if (rawQueryString.IndexOf(normalizedName) == -1)
						throw new QueryHinterOutputParameterNotFoundInQueryException(mQueryTag, parameter, normalizedName);
				}
				else
					inCount++;
			}

			if (inCount < 1)
				throw new QueryHinterMissingInputParameterException(mQueryTag);

			if (outCount < 1)
				throw new QueryHinterMissingOutputParameterException(mQueryTag);

			mInitialized = true;
		}

		public void AddParam(string name, object value)
		{
			// validates the hinter isn't being reused for a different query
			if (mQueryAdapter.GetQueryTag() != mQueryTag)
				throw new QueryHinterBadAssociationException(mQueryTag, mQueryAdapter.GetQueryTag());

			// is the parameter undeclared?
			MTSQL.Parameter parameter = (MTSQL.Parameter) mExe.ProgramParameters[name];
			if (parameter == null)
				throw new QueryHinterUnknownParameterException(mQueryTag, name);

			// is the parameter a non-input parameter? 
			if (parameter.Direction != MTSQL.ParameterDirection.In)
				throw new QueryHinterCannotSetOutputParameterException(mQueryTag, name);

			// TODO: where does param type come into play?

			parameter.Value = value;
		}

		public void Apply()
		{
			// validates the hinter isn't being reused for a different query
			if (mQueryAdapter.GetQueryTag() != mQueryTag)
				throw new QueryHinterBadAssociationException(mQueryTag, mQueryAdapter.GetQueryTag());

			// TODO: check that all input parameters are set. how does this interact with nulls?

			//
			// executes the hinter!
			//
			try
			{
				mExe.Execute();
			}
			// TODO: MTSQL should throw a more specific exception
			catch (ApplicationException e)
			{
				throw new QueryHinterExecutionException(mQueryTag, e);
			}

			//
			// fills in the query parameters with the output values of the hinter
			//
      foreach (DictionaryEntry paramEntry in mExe.ProgramParameters)
			{
				MTSQL.Parameter parameter = (MTSQL.Parameter) paramEntry.Value;
				if (parameter.Direction == MTSQL.ParameterDirection.Out)
				{
					string value = (string) parameter.Value;

					// null output parameters result in hints being omitted from the query
					// it is not necessary to set them in MTSQL as ""
					if (parameter.Value == null)
						value = "";

					mQueryAdapter.AddParam(NormalizeParameterName(parameter), value, true);
				}
			}
			
		}

		public QueryAdapter.IMTQueryAdapter QueryAdapter
		{
			get
			{
				return mQueryAdapter;
			}
		}

		/// <summary>
		/// Constructs a cannonical parameter name used in the query
		/// based on the hinter's output parameter.
		/// </summary>
		private string NormalizeParameterName(MTSQL.Parameter parameter)
		{
			return String.Format("%%%{0}_HINT%%%", parameter.Name.ToUpper());
		}

		Logger mLogger = new Logger("[QueryHinter]");
    bool mInitialized = false;
		string mQueryTag;
		string mHinterSource;
		QueryAdapter.IMTQueryAdapter mQueryAdapter;
		MTSQL.IExecutionEngine mExe;
	}




	[ComVisible(false)]
	public class QueryHinterCompilationException : DataAccessException
	{ 
		public QueryHinterCompilationException(string queryTag, ApplicationException mtsqlException)
			: base(String.Format("Hinter compilation failed for query '{0}': {1}!", queryTag, mtsqlException.Message))
		{ }
	}

	[ComVisible(false)]
	public class QueryHinterExecutionException : DataAccessException
	{ 
		public QueryHinterExecutionException(string queryTag, ApplicationException mtsqlException)
			: base(String.Format("Hinter execution failed for query '{0}': {1}!", queryTag, mtsqlException.Message))
		{ }
	}

	[ComVisible(false)]
	public class QueryHinterMissingInputParameterException : DataAccessException
	{ 
		public QueryHinterMissingInputParameterException(string queryTag)
			: base(String.Format("Hinter of query '{0}' must declare at least one input parameter!", queryTag))
		{ }
	}

	[ComVisible(false)]
	public class QueryHinterMissingOutputParameterException : DataAccessException
	{ 
		public QueryHinterMissingOutputParameterException(string queryTag)
			: base(String.Format("Hinter of query '{0}' must declare at least one output parameter!", queryTag))
		{ }
	}

	[ComVisible(false)]
	public class QueryHinterOutputParameterTypeMismatchException : DataAccessException
	{ 
		public QueryHinterOutputParameterTypeMismatchException(string queryTag, MTSQL.Parameter parameter)
			: base(String.Format("Hinter of query '{0}' has an output parameter '{1}' that is not declared as type VARCHAR!",
													 queryTag, parameter.Name))
		{ }
	}

	[ComVisible(false)]
	public class QueryHinterOutputParameterNotFoundInQueryException : DataAccessException
	{ 
		public QueryHinterOutputParameterNotFoundInQueryException(string queryTag,
																															MTSQL.Parameter parameter,
																															string normalizedName)
			: base(String.Format("Hinter of query '{0}' has an output parameter '{1}' that does not " +
													 "have a corresponding query parameter named '{2}' in the query string!",
													 queryTag, parameter.Name, normalizedName))
		{ }
	}

	[ComVisible(false)]
	public class QueryHinterBadAssociationException : DataAccessException
	{ 
		public QueryHinterBadAssociationException(string queryTag, string otherQueryTag)
			: base(String.Format("This hinter can only be used for query '{0}' - not for query '{1}'!",
													 queryTag, otherQueryTag))
		{ }
	}

	[ComVisible(false)]
	public class QueryHinterUnknownParameterException : DataAccessException
	{ 
		public QueryHinterUnknownParameterException(string queryTag, string name)
			: base(String.Format("Parameter '{0}' is unknown to hinter of query '{1}'", name, queryTag))
		{ }
	}

	[ComVisible(false)]
	public class QueryHinterCannotSetOutputParameterException : DataAccessException
	{ 
		public QueryHinterCannotSetOutputParameterException(string queryTag, string name)
			: base(String.Format("Cannot set parameter '{0}' because it is an output parameter for hinter of query '{1}'", name, queryTag))
		{ }
	}
}
