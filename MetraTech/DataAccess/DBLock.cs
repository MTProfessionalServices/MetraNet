using System;
using System.Collections;
using System.Runtime.InteropServices;

using MetraTech.DataAccess;

using System.Diagnostics;

//
// NOTE: to test this, construct a lock, then
// use query analyzer to try to construct one with the same name.
//  sp_getapplock "mylock", "Exclusive", "Session"
//
// TODO: use the DBMS_LOCK package in Oracle to do the same thing
//
namespace MetraTech.DataAccess
{
	[ComVisible(false)]
	public class DBLock : IDisposable
	{
		// wait forever
		public static int InfiniteTimeout = -1;
		// throw an error if we can't get access immediately
		public static int ImmediateTimeout = 0;

    public DBLock(string lockName)
			: this(lockName, InfiniteTimeout)
		{ }

    public DBLock(string lockName, int timeoutMs)
		{
			mLockName = lockName;
			mConnection = ConnectionManager.CreateNonServicedConnection();
            // g. cieplik CR 15945 9/4/2008 for oracle use DBMS_LOCK in dblock stored procedure
            mIsOracle = (mConnection.ConnectionInfo.DatabaseType == DBType.Oracle) ? true : false;
            mLockMode = "ALLOCATE";
            // g. cieplik CR 15945 the timeoutMS is configured to be millseconds for SqlServer, convert to seconds for Oracle, default to 10 secs
            if ((mTimeOutSec = timeoutMs / 1000)  <= 0) mTimeOutSec = 10;

            if (mIsOracle)
            
            {
                try
                {
                    using (IMTCallableStatement stmt = mConnection.CreateCallableStatement("dblock"))
                    {
                        stmt.AddParam("p_lockname", MTParameterType.String, lockName);
                        stmt.AddParam("p_timeout", MTParameterType.Integer, mTimeOutSec);
                        stmt.AddParam("p_lockmode", MTParameterType.String, mLockMode);
                        stmt.AddOutputParam("p_result", MTParameterType.Integer);
                        stmt.ExecuteNonQuery();

                        //Get the return value from the stored procedure
                        int retVal = (int)stmt.GetOutputValue("p_result");

                        switch (retVal)
                        {
                            case 0:
                                // Lock was successfully granted synchronously.
                                break;
                            case 1:
                                // Lock request timed out.
                                throw new DataAccessException("Lock request timed out.");
                            case 2:
                                // Lock request was chosen as a deadlock victim.
                                throw new DataAccessException("Lock request was chosen as a deadlock victim.");
                            case 3:
                                // Parameter validation or other call error.
                                throw new DataAccessException("Lock request had parameter error");
                            case 4:
                                // Lock was already owned.
                                throw new DataAccessException("Lock request already owned.");
                            case 5:
                                // Lock was already owned.
                                throw new DataAccessException("Illegal Lock Handle");
                            default:
                                if (retVal < 0 || retVal > 5)
                                {
                                    Debug.Assert(false, "Unknown value returned from lock request");
                                    throw new DataAccessException("Unknown value returned from lock request");
                                }
                                else
                                    break;
                        }
                    }
                }
                // catch                
                catch (Exception)
                {
                    mConnection.Dispose();
                    mConnection = null;
                    throw;
                }
                
           }                      

            else
                try
                {
                    using (IMTCallableStatement stmt = mConnection.CreateCallableStatement("sp_getapplock"))
                    {
                        stmt.AddReturnValue(MTParameterType.Integer);
                        stmt.AddParam("@Resource", MTParameterType.String, lockName);
                        stmt.AddParam("@LockMode", MTParameterType.String, "Exclusive");
                        stmt.AddParam("@LockOwner", MTParameterType.String, "Session");
                        stmt.AddParam("@LockTimeout", MTParameterType.Integer, timeoutMs);

                        stmt.ExecuteNonQuery();
                        int retVal = (int)stmt.ReturnValue;

                        switch (retVal)
                        {
                            case 0:
                                // Lock was successfully granted synchronously.
                                break;
                            case 1:
                                // Lock was granted successfully after waiting for other incompatible locks to be released.
                                break;
                            case -1:
                                // Lock request timed out.
                                throw new DataAccessException("Lock request timed out.");
                            case -2:
                                // Lock request was cancelled.
                                throw new DataAccessException("Lock request was cancelled.");
                            case -3:
                                // Lock request was chosen as a deadlock victim.
                                throw new DataAccessException("Lock request was chosen as a deadlock victim.");
                            case -999:
                                // Parameter validation or other call error.
                                throw new DataAccessException("Error requesting lock.");
                            default:
                                if (retVal < 0)
                                {
                                    Debug.Assert(false, "Unknown value returned from lock request");
                                    throw new DataAccessException("Unknown value returned from lock request");
                                }
                                else
                                    break;
                        }
                    }
                }
                catch (Exception)
                {
                    mConnection.Dispose();
                    mConnection = null;
                    throw;
                }
		}

		public void Release()
		{
			using (mConnection)
			{
                // g. cieplik CR 15945 9/4/2008 for oracle use DBMS_LOCK in dblock stored procedure
                mLockMode = "RELEASE";

                if (mIsOracle)
                {
                    try
                    {
                        using (IMTCallableStatement stmt = mConnection.CreateCallableStatement("dblock"))
                        {
                            stmt.AddParam("p_lockname", MTParameterType.String, mLockName);
                            stmt.AddParam("p_timeout", MTParameterType.Integer, mTimeOutSec);
                            stmt.AddParam("p_lockmode", MTParameterType.String, mLockMode);
                            stmt.AddOutputParam("p_result", MTParameterType.Integer);
                            stmt.ExecuteNonQuery();
                            //Get the return value from the stored procedure
                            int retVal = (int)stmt.GetOutputValue("p_result");

                            switch (retVal)
                            {
                                case 0:
                                    // Lock was released successfully. 
                                    break;
                                case 3:
                                    // Parameter validation or other call error.
                                    throw new DataAccessException("Lock request had parameter error");
                                case 4:
                                    // Lock was already owned.
                                    throw new DataAccessException("Do not own lock specified by id or lockhandle");
                                case 5:
                                    // Lock was already owned.
                                    throw new DataAccessException("Illegal Lock Handle");
                                default:
                                    if (retVal < 0 || retVal > 5)
                                    {
                                        Debug.Assert(false, "Unknown value returned from lock request");
                                        throw new DataAccessException("Unknown value returned from lock request");
                                    }
                                    else
                                        break;
                            }
                        }
                    }
                    catch (Exception)
                    {
                        mConnection.Dispose();
                        mConnection = null;
                        throw;
                    }
                }
                else
                {
                    using (IMTCallableStatement stmt = mConnection.CreateCallableStatement("sp_releaseapplock"))
                    {
                        stmt.AddReturnValue(MTParameterType.Integer);
                        stmt.AddParam("@Resource", MTParameterType.String, mLockName);
                        stmt.AddParam("@LockOwner", MTParameterType.String, "Session");

                        stmt.ExecuteNonQuery();

                        int retVal = (int)stmt.ReturnValue;
                        if (retVal == -999)
                            throw new DataAccessException("Error releasing lock");
                        if (retVal < 0)
                        {
                            Debug.Assert(false, "Unknown value returned from lock request");
                            throw new DataAccessException("Unknown value returned from lock request");
                        }
                    }
                }
		}
        }
		public void Dispose()
		{
			Release();
		}

		private string mLockName;
		private IMTNonServicedConnection mConnection;
        // g. cieplik CR 15945 9/4/2008 for oracle use DBMS_LOCK in dblock stored procedure
        private bool mIsOracle;
        private string mLockMode;
        private int mTimeOutSec; 

	}
}
