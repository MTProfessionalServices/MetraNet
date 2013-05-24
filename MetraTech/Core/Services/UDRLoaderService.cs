using System.ServiceModel;
using System.IO;
using System.Configuration;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.RCD;
using System.Xml.Serialization;
using System.Runtime.Serialization;
using System.Xml;
using System.Text;
using System;
using System.Collections.Generic;
using System.Reflection;
using MetraTech.DataAccess;
using System.Collections;
using System.Data;
using MetraTech.DomainModel.BaseTypes;


namespace MetraTech.Core.Services
{
  /// <summary>
  /// UDR Fault exception
  /// </summary>
  public class UDRFaultException : MASBaseException
  {
    #region members
    private string m_ErrorMessage;
    private string m_FaultCode;
    private string m_Action;
    private List<string> m_ErrorMessages = new List<string> ();
    #endregion

    #region constructors

    /// <summary>
    /// Create a new exception.
    /// </summary>
    /// <param name="errorMessage">Error message to display</param>
    /// <param name="faultCode">fault code</param>
    /// <param name="action">fault action</param>
    public UDRFaultException ( String errorMessage, string faultCode, string action )
    {
      this.m_ErrorMessage = errorMessage;
      this.m_FaultCode = faultCode;
      this.m_Action = action;
    }

    /// <summary>
    /// Create a new exception with details.
    /// </summary>
    /// <param name="errorMessage">error message</param>
    /// <param name="faultCode">fault code</param>
    /// <param name="action">action</param>
    /// <param name="messageDetails">detail set of error messages</param>
    public UDRFaultException ( String errorMessage, string faultCode, string action, List<string> messageDetails )
    {
      this.m_ErrorMessage = errorMessage;
      this.m_FaultCode = faultCode;
      this.m_Action = action;
      this.m_ErrorMessages.AddRange ( messageDetails );
    }
    #endregion

    #region public methods
    /// <summary>
    /// Creates the fault from this exception.
    /// </summary>
    /// <returns>the populated fault</returns>
    public override FaultException CreateFaultDetail ()
    {
      MASBasicFaultDetail detail = new MASBasicFaultDetail ();
      if ( m_ErrorMessages.Count > 0 )
      {
        detail.ErrorMessages.AddRange ( m_ErrorMessages );
      }
      else
      {
        detail.ErrorMessages.Add ( m_ErrorMessage );
      }
      FaultException<MASBasicFaultDetail> fe = new FaultException<MASBasicFaultDetail> ( detail, m_ErrorMessage );

      return fe;
    }
    #endregion

    #region public properties
    /// <summary>
    /// The error message.
    /// </summary>
    public override string Message
    {
      get
      {
        return this.m_ErrorMessage;
      }
    }

    /// <summary>
    ///  The fault code under metratech.com Namespace
    /// </summary>
    public string FaultCode
    {
      get
      {
        return this.m_FaultCode;
      }
    }

    /// <summary>
    /// The fault action.
    /// </summary>
    public string Action
    {
      get
      {
        return this.m_Action;
      }
    }

    /// <summary>
    /// The detail error messages.
    /// </summary>
    public List<string> ErrorMessages
    {
      get
      {
        return this.m_ErrorMessages;
      }
    }
    #endregion
  }

  /// <summary>
  /// UDR web service interface.
  /// </summary>
  [ServiceContract]
  public interface IUDRLoaderService
  {
    /// <summary>
    /// Loads a UDR into the SVC tables to be processed by the pipeline asynchronously.
    /// </summary>
    /// <param name="udrObject">the UDR object to be loaded</param>
    [OperationContract]
    [FaultContract ( typeof ( MASBasicFaultDetail ) )]
    void LoadUDR ( MetraTech.DomainModel.BaseTypes.RootServiceDef udrObject );
  }

  /// <summary>
  /// UDR web service
  /// </summary>
  public class UDRLoaderService : CMASServiceBase, IUDRLoaderService
  {
      private static Logger logger = new Logger("[UDRLoaderService]");

    /// <summary>
    /// Constructor.
    /// </summary>
    static UDRLoaderService ()
    {
    }

    /// <summary>
    /// Loads the passed in UDR record
    /// </summary>
    /// <param name="udrObject">The UDR record to load</param>
    public void LoadUDR ( MetraTech.DomainModel.BaseTypes.RootServiceDef udrObject )
    {
      try
      {
        LoadFromObject ( udrObject );
      }
      catch ( UDRFaultException ex )
      {
        throw ex;
      }
      catch ( Exception ex )
      {
        logger.LogError ( "Caught exception in LoadUDR " + ex.Message + " " + ex.InnerException + " " + ex.StackTrace );
        throw new UDRFaultException ( ex.Message, "UNKNOWN", "LoadUDR" );
      }
    }

    private void LoadFromObject ( MetraTech.DomainModel.BaseTypes.RootServiceDef parent )
    {
      if ( parent == null )
      {
        return;
      }
      string key;
      PipelineMeteringHelperCache cache = PipelineMeteringUtil.GetPipelineCache ( parent.GetType (), out key );
      PipelineMeteringHelper helper = cache.GetMeteringHelper ();
      try
      {
        PipelineMeteringUtil.Meter ( helper, key, null, parent );
        DataSet dataSet = helper.Meter ("su", "system_user", "su123");
        using ( var writer = new StringWriter () )
        {
          dataSet.WriteXml ( writer );
          logger.LogDebug ( writer.ToString () );
        }
        // helper.WaitForMessagesToComplete ( dataSet, 1000 );
      }
      finally
      {
        cache.Release( helper );
      }
    }
  }
}
