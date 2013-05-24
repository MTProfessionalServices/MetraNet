using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Transactions;
using NHibernate;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  /// <summary>
  ///   The UnitOfWorkScope class encapsulates an ISession.
  ///   Use this when making multiple calls to the StandardRepository API's within a single TransactionScope.
  ///   It is not necessary to use this if only a single call is being made to StandardRepository because
  ///   each call to StandardRepository will create its own transaction if an ambient transaction does not exist.
  /// 
  ///   By setting the value of a thread static member to a UnitOfWorkScope instance, 
  ///   we have a way of sharing the ISession amongst all 
  ///   the StandardRepository API calls on this thread.
  /// 
  ///   Instances of this class are supposed to be used in a using() statement.
  ///   
  ///   The typical usage pattern would be to 
  ///   (1) Create a TransactionScope
  ///   (2) Create a UnitOfWorkScope
  ///       - initializes an ISession and sets the FlushMode to FlushMode.Commit meaning that
  ///       - all db operations will be flushed at Transaction commit
  ///       
  ///   (3) Call multiple StandardRepository API's (that's why we're using a TransactionScope)
  ///       - All the API's will use the same ISession
  /// 
  ///   When this class is Disposed, it will release ISession resources by calling Dispose on ISession
  ///   
  ///   Usage:
  /// 
  ///   using (var transactionScope = new TransactionScope()) 
  ///   using (var unitOfWorkScope = new UnitOfWorkScope())
  ///   {
  ///     // Call multiple StandardRepository API's  
  /// 
  ///     scope.Complete();   
  ///   }
  /// 
  ///   Discussion on IDisposable
  ///   http://www.codeproject.com/KB/cs/idisposable.aspx
  /// </summary>
  public class UnitOfWorkScope : IDisposable
  {
    #region Public Methods
    /// <summary>
    ///   Construct the class with either an entity name or a database name
    /// </summary>
    /// <param name="entityOrDatabaseName"></param>
    public UnitOfWorkScope(string entityOrDatabaseName)
    {
      if (_currentScope != null && !_currentScope._disposed)
      {
        throw new InvalidOperationException("UnitOfWorkScope instances cannot be nested.");
      }

      _session = NHibernateConfig.IsBmeDatabase(entityOrDatabaseName) ? 
                RepositoryAccess.Instance.GetSessionForDb(entityOrDatabaseName) : 
                RepositoryAccess.Instance.GetSession(entityOrDatabaseName);
      _session.FlushMode = FlushMode.Commit;

      // Notifies a host that managed code is about to execute instructions that depend on 
      // the identity of the current physical operating system thread.
      // http://msdn.microsoft.com/en-us/library/system.threading.thread.beginthreadaffinity.aspx
      Thread.BeginThreadAffinity();

      _disposed = false;
      // Set the current scope to this UnitOfWorkScope object
      _currentScope = this;
    }

    public void Dispose()
    {
      Dispose(true);

      // This object will be cleaned up by the Dispose method.
      // Therefore, you should call GC.SupressFinalize to
      // take this object off the finalization queue
      // and prevent finalization code for this object
      // from executing a second time.
      GC.SuppressFinalize(this);
    }
    #endregion

    #region Internal Properties
    internal static ISession Session
    {
      get { return _currentScope != null ? _currentScope._session : null; }
    }

    #endregion

    #region Protected Methods
    // Dispose(bool disposing) executes in two distinct scenarios.
    // If disposing equals true, the method has been called directly
    // or indirectly by a user's code. Managed and unmanaged resources
    // can be disposed.
    //
    // If disposing equals false, the method has been called by the
    // runtime from inside the finalizer and you should not reference
    // other objects. Only unmanaged resources can be disposed.
    protected virtual void Dispose(bool disposing)
    {
      // Check to see if Dispose has already been called.
      if (!_disposed)
      {
        if (disposing)
        {
          if (_session != null)
          {
            _session.Dispose();
          }

          _currentScope = null;
          Thread.EndThreadAffinity(); 
        }

        // Disposing has been done.
        _disposed = true;
      }
    }
    #endregion

    #region Private Fields
    [ThreadStatic]
    private static UnitOfWorkScope _currentScope;
    private ISession _session;
    private bool _disposed; // to detect redundant calls
    #endregion
  }
}
