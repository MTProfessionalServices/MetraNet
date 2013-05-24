/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SQLite;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Common;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor.SQLite
{
	/// <summary>
	/// Provides an access to SQLite event recording database.
	/// </summary>
	internal static class SQLiteDataAccess
	{
		private delegate void CommandInitializer(SQLiteCommand command);

		#region Constants

		private const string SelectEventTypesCommand = "SELECT ID, Name FROM SecurityEventType ORDER BY Name;";
		private const string SelectSubsystemCategoriesCommand =
			"SELECT c.ID, c.Name, s.Name SubsystemName FROM SubsystemCategory c JOIN Subsystem s ON c.SubsystemID = s.ID ORDER BY c.Name, s.Name;";

		private const string InsertSecurityEventCommand =
			@"INSERT INTO SecurityEvent
            (
                 SecurityEventTypeID
                ,SubsystemCategoryID
				,ProblemID
                ,InputData
                ,Reason
                ,TimeStamp
                ,Path
                ,HostName
                ,Message
                ,ClientAddress
                ,UserIdentity
                ,SessionID
                ,ClientInfo
                --,StackTrace
                ,InputDataSize
            )
            SELECT
                 @SecurityEventTypeID
                ,@SubsystemCategoryID
				,@ProblemId
                ,@InputData
                ,@Reason
                ,@TimeStamp
                ,@Path
                ,@HostName
                ,@Message
                ,@ClientAddress
                ,@UserIdentity
                ,@SessionID
                ,@ClientInfo
                --,@StackTrace
                ,@InputDataSize;
			SELECT last_insert_rowid();";

		private const string InsertSecurityPolicyActionCommand =
			@"INSERT INTO SecurityPolicyAction
			(
				 SecurityEventID
				,SecurityPolicyActionTypeID
				,BlockingPeriod
				,SessionParameterName
				,SessionParameterValue
				,Message
				,AdminEmailAddress
				,DestinationPath
			)
			VALUES
			(
				 @SecurityEventId
				,@SecurityPolicyActionTypeId
				,@BlockingPeriod
				,@SessionParameterName
				,@SessionParameterValue
				,@Message
				,@AdminEmailAddress
				,@DestinationPath
			)";

		private const string SelectEventsNumberInSessionCommand =
			@"SELECT COUNT(*)
                FROM SecurityEvent e
               WHERE e.SessionId = @SessionID
                AND e.SubsystemCategoryID IN
                    (SELECT sc.ID
                       FROM SubsystemCategory sc JOIN Subsystem s ON s.ID = sc.SubsystemID
                      WHERE s.Name = @SubsystemName
                        AND sc.Name = @CategoryName)";

		private const string SelectEventsNumberInTimespanCommand =
			@"SELECT COUNT(*)
                FROM SecurityEvent e
               WHERE e.TimeStamp >= @TimeStamp
                AND e.SubsystemCategoryID IN
                    (SELECT sc.ID
                       FROM SubsystemCategory sc JOIN Subsystem s ON s.ID = sc.SubsystemID
                      WHERE s.Name = @SubsystemName
                        AND sc.Name = @CategoryName)";

		private const string SelectIPAddressesNumberInSessionCommand =
			@"SELECT COUNT(DISTINCT ClientAddress)
                FROM SecurityEvent e
               WHERE e.SessionId = @SessionID AND e.ClientAddress <> @CurrentAddress";

		private const string SelectLastActionTimeStamp =
			@"SELECT MAX(TimeStamp)
                FROM SecurityEvent e JOIN SecurityPolicyAction a ON e.ID = a.SecurityEventID
               WHERE a.SecurityPolicyActionTypeID = @SecurityPolicyActionTypeID";

		#endregion

		#region Private fields

		private static object _syncRoot = new object();
		private static List<SecurityEventTypeEntity> _eventTypes;
		private static List<SubsystemCategoryEntity> _subsystemCategories;

		#endregion

		#region Public methods

		/// <summary>
		/// Writes an event data to the database.
		/// </summary>
		/// <param name="connectionString">Connection string to the SQLite database.</param>
		/// <param name="eventData">The security event data to be written.</param>
		/// <param name="actionsData">The recomended actions data to be written.</param>
		/// <param name="useAsynchronousRecording">Indicatits to turn the SQLite synchronous progma option off.</param>
		public static void AddEvent(
			string connectionString,
			IDictionary<string, object> eventData,
			List<Dictionary<string, object>> actionsData,
			bool useAsynchronousRecording)
		{
			if (eventData == null)
			{
				throw new ArgumentNullException(Constants.Arguments.EventData);
			}

			if (actionsData == null)
			{
				throw new ArgumentNullException(Constants.Arguments.ActionsData);
			}

			using (SQLiteConnection connection = new SQLiteConnection(connectionString))
			{
				connection.Open();

				if (useAsynchronousRecording)
				{
					using (SQLiteCommand command = new SQLiteCommand("PRAGMA synchronous = OFF;", connection))
					{
						command.CommandType = CommandType.Text;
						command.ExecuteNonQuery();
					}
				}

				using (SQLiteTransaction transaction = connection.BeginTransaction())
				{
					try
					{
						long eventId = InsertSecurityEvent(eventData, transaction);

						foreach (Dictionary<string, object> action in actionsData)
						{
							InsertSecurityPolicyAction(eventId, action, transaction);
						}

						transaction.Commit();
					}
					catch (Exception)
					{
						transaction.Rollback();
					}
				}
			}
		}

		/// <summary>
		/// Determines a number of the events of the specified kind happened within the session with the specified ID.
		/// </summary>
		/// <param name="connectionString">Connection string to the SQLite database.</param>
		/// <param name="sessionId">An ID of the user's session to find events within.</param>
		/// <param name="subsystemName">An event's source subsystem name.</param>
		/// <param name="categoryName">An event's source category name.</param>
		/// <returns>A number of the events with the specified parameters.</returns>
		public static int GetEventsNumberInSession(
			string connectionString,
			string sessionId,
			string subsystemName,
			string categoryName)
		{
			object result = ExecuteScalar(
				connectionString,
				SelectEventsNumberInSessionCommand,
				delegate(SQLiteCommand command)
				{
					SetParameter(command, Constants.DbParameters.SessionId, sessionId);
					SetParameter(command, Constants.DbParameters.SubsystemName, subsystemName);
					SetParameter(command, Constants.DbParameters.CategoryName, categoryName);
				});

			return Convert.ToInt32(result);
		}

		/// <summary>
		/// Determines a number of the event of the specified kind happened since the specified time.
		/// </summary>
		/// <param name="connectionString">Connection string to the SQLite database.</param>
		/// <param name="fromTime">
		/// A date and time to count event heppened since.
		/// Value must be passed in ISO-8601 format.
		/// </param>
		/// <param name="subsystemName">An event's source subsystem name.</param>
		/// <param name="categoryName">An event's source category name.</param>
		/// <returns>A number of the events with the specified parameters.</returns>
		public static int GetEventsNumberInTimespan(
			string connectionString,
			string fromTime,
			string subsystemName,
			string categoryName)
		{
			object result = ExecuteScalar(
				connectionString,
				SelectEventsNumberInTimespanCommand,
				delegate(SQLiteCommand command)
				{
					SetParameter(command, Constants.DbParameters.TimeStamp, fromTime);
					SetParameter(command, Constants.DbParameters.SubsystemName, subsystemName);
					SetParameter(command, Constants.DbParameters.CategoryName, categoryName);
				});

			return Convert.ToInt32(result);
		}

		/// <summary>
		/// Determines a number of distinct IP client addresses within the session except the current one.
		/// </summary>
		/// <param name="connectionString">Connection string to the SQLite database.</param>
		/// <param name="sessionId">An ID of the user's session to find IP addresses within.</param>
		/// <param name="currentAddress">A current client address.</param>
		/// <returns>A number of IP addresses used in the specified session.</returns>
		public static int GetSessionIPAddressesNumber(string connectionString, string sessionId, string currentAddress)
		{
			object result = ExecuteScalar(
				connectionString,
				SelectIPAddressesNumberInSessionCommand,
				delegate(SQLiteCommand command)
				{
					SetParameter(command, Constants.DbParameters.SessionId, sessionId);
					SetParameter(command, Constants.DbParameters.CurrentAddress, currentAddress);
				});

			return Convert.ToInt32(result);
		}

		/// <summary>
		/// Retrieves date/time of the event the action of the specific type was recommended for.
		/// </summary>
		/// <param name="connectionString">Connection string to the SQLite database.</param>
		/// <param name="actionTypeId">An action type to look for.</param>
		/// <returns>
		/// Last date/time of the event the action was recommended for.
		/// Returms DateTime.MinValue if such action was never recommended.
		/// </returns>
		public static DateTime GetLastActionTimeStamp(string connectionString, int actionTypeId)
		{
			object result = ExecuteScalar(
				connectionString,
				SelectLastActionTimeStamp,
				delegate(SQLiteCommand command)
				{
					SetParameter(command, Constants.DbParameters.SecurityPolicyActionTypeId, actionTypeId.ToString());
				});

			return result != null ?
				DateTime.ParseExact(result.ToString(), Constants.Formatting.ISO8601DateFormat, System.Globalization.CultureInfo.InvariantCulture) : DateTime.MinValue;
		}

		#endregion

		#region Private methods

		private static void SetParameter(SQLiteCommand command, string paramName, string dictionaryKey, IDictionary<string, object> data)
		{
			command.Parameters.AddWithValue(
				paramName,
				data.ContainsKey(dictionaryKey) ? data[dictionaryKey] ?? DBNull.Value : DBNull.Value);
		}

		private static void SetParameter(SQLiteCommand command, string paramName, string value)
		{
			command.Parameters.AddWithValue(
				paramName,
				!string.IsNullOrEmpty(value) ? (object)value : DBNull.Value);
		}

		private static long InsertSecurityEvent(IDictionary<string, object> eventData, SQLiteTransaction transaction)
		{
			using (SQLiteCommand command =
				new SQLiteCommand(InsertSecurityEventCommand, transaction.Connection, transaction))
			{
				command.CommandType = CommandType.Text;

				// Setting SecurityEventTypeID
				SecurityEventTypeEntity eventType =
					eventData.ContainsKey(Constants.Properties.EventType) ?
					GetSecurityEventTypes(transaction.Connection.ConnectionString).
					FirstOrDefault(p => AreEqual(p.Name, eventData[Constants.Properties.EventType])) : null;

				command.Parameters.AddWithValue(Constants.DbParameters.SecurityEventTypeId, eventType != null ? (object)eventType.Id : DBNull.Value);
					
				// Setting SubsystemCategoryID
				SubsystemCategoryEntity category =
					eventData.ContainsKey(Constants.Properties.CategoryName) && eventData.ContainsKey(Constants.Properties.SubsystemName) ?
					GetSubsystemCategories(transaction.Connection.ConnectionString).
					FirstOrDefault(p =>
						AreEqual(p.Name, eventData[Constants.Properties.CategoryName]) &&
						AreEqual(p.SubsystemName, eventData[Constants.Properties.SubsystemName])) : null;

				command.Parameters.AddWithValue(Constants.DbParameters.SubsystemCategoryId, category != null ? (object)category.Id : DBNull.Value);

				SetParameter(command, Constants.DbParameters.ProblemId, Constants.Properties.ProblemId, eventData);
				SetParameter(command, Constants.DbParameters.InputData, Constants.Properties.InputData, eventData);
				SetParameter(command, Constants.DbParameters.Reason, Constants.Properties.Reason, eventData);
				SetParameter(command, Constants.DbParameters.TimeStamp, Constants.Properties.TimeStamp, eventData);
				SetParameter(command, Constants.DbParameters.Path, Constants.Properties.Path, eventData);
				SetParameter(command, Constants.DbParameters.HostName, Constants.Properties.HostName, eventData);
				SetParameter(command, Constants.DbParameters.Message, Constants.Properties.Message, eventData);
				SetParameter(command, Constants.DbParameters.ClientAddress, Constants.Properties.ClientAddress, eventData);
				SetParameter(command, Constants.DbParameters.UserIdentity, Constants.Properties.UserIdentity, eventData);
				SetParameter(command, Constants.DbParameters.SessionId, Constants.Properties.SessionId, eventData);
				SetParameter(command, Constants.DbParameters.ClientInfo, Constants.Properties.ClientInfo, eventData);
				//SetParameter(command, Constants.DbParameters.StackTrace, Constants.Properties.StackTrace, eventData);
				SetParameter(command, Constants.DbParameters.InputDataSize, Constants.Properties.InputDataSize, eventData);

				return (long)command.ExecuteScalar();
			}
		}

		private static bool AreEqual(string name, object value)
		{
			string toCompare = value != null ? value.ToString() : null;

			return String.Compare(name, toCompare, StringComparison.InvariantCultureIgnoreCase) == 0;
		}

		private static void InsertSecurityPolicyAction(
			long eventId,
			Dictionary<string, object> action,
			SQLiteTransaction transaction)
		{
			using (SQLiteCommand command =
				new SQLiteCommand(InsertSecurityPolicyActionCommand, transaction.Connection, transaction))
			{
				command.CommandType = CommandType.Text;

				command.Parameters.AddWithValue(Constants.DbParameters.SecurityEventId, eventId);
				SetParameter(command, Constants.DbParameters.SecurityPolicyActionTypeId, Constants.Properties.SecurityPolicyActionTypeId, action);
				SetParameter(command, Constants.DbParameters.BlockingPeriod, Constants.Properties.BlockingPeriod, action);
				SetParameter(command, Constants.DbParameters.SessionParameterName, Constants.Properties.SessionParameterName, action);
				SetParameter(command, Constants.DbParameters.SessionParameterValue, Constants.Properties.SessionParameterValue, action);
				SetParameter(command, Constants.DbParameters.Message, Constants.Properties.Message, action);
				SetParameter(command, Constants.DbParameters.AdminEmailAddress, Constants.Properties.AdminEmailAddress);
				SetParameter(command, Constants.DbParameters.DestinationPath, Constants.Properties.DestinationPath, action);

				command.ExecuteNonQuery();
			}
		}

		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
		private static object ExecuteScalar(string connectionString, string commandText, CommandInitializer initializer)
		{
			using (SQLiteConnection connection = new SQLiteConnection(connectionString))
			{
				connection.Open();

				using (SQLiteTransaction transaction = connection.BeginTransaction())
				{
					try
					{
						using (SQLiteCommand command = new SQLiteCommand(commandText, connection, transaction))
						{
							command.CommandType = CommandType.Text;

							if (initializer != null)
							{
								initializer(command);
							}

							object result = command.ExecuteScalar();
							transaction.Commit();

							return result != DBNull.Value ? result : null;
						}
					}
					catch (Exception)
					{
						transaction.Rollback();
						throw;
					}
				}
			}
		}

		#endregion

		#region Private methods

		private static List<SecurityEventTypeEntity> GetSecurityEventTypes(string connectionString)
		{
			lock (_syncRoot)
			{
				if (_eventTypes == null)
				{
					_eventTypes = new List<SecurityEventTypeEntity>();

					using (SQLiteConnection connection = new SQLiteConnection(connectionString))
					{
						connection.Open();

						ReadEventTypes(connection);
					}
				}
			}

			return _eventTypes;
		}

		private static void ReadEventTypes(SQLiteConnection connection)
		{
			using (SQLiteCommand command = new SQLiteCommand(SelectEventTypesCommand, connection))
			{
				command.CommandType = CommandType.Text;

				using (SQLiteDataReader reader = command.ExecuteReader())
				{
					while (reader.Read())
					{
						SecurityEventTypeEntity value = new SecurityEventTypeEntity();

						value.Id = (long)reader[Constants.DbColumns.Id];
						value.Name = (string)reader[Constants.DbColumns.Name];

						_eventTypes.Add(value);
					}
				}
			}
		}

		private static List<SubsystemCategoryEntity> GetSubsystemCategories(string connectionString)
		{
			lock (_syncRoot)
			{
				if (_subsystemCategories == null)
				{
					_subsystemCategories = new List<SubsystemCategoryEntity>();

					using (SQLiteConnection connection = new SQLiteConnection(connectionString))
					{
						connection.Open();

						ReadSubsystemCategories(connection);
					}
				}
			}

			return _subsystemCategories;
		}

		private static void ReadSubsystemCategories(SQLiteConnection connection)
		{
			using (SQLiteCommand command = new SQLiteCommand(SelectSubsystemCategoriesCommand, connection))
			{
				command.CommandType = CommandType.Text;

				using (SQLiteDataReader reader = command.ExecuteReader())
				{
					while (reader.Read())
					{
						SubsystemCategoryEntity value = new SubsystemCategoryEntity();

						value.Id = (long)reader[Constants.DbColumns.Id];
						value.Name = (string)reader[Constants.DbColumns.Name];
						value.SubsystemName = (string)reader[Constants.DbColumns.SubsystemName];

						_subsystemCategories.Add(value);
					}
				}
			}
		}

		#endregion
	}
}