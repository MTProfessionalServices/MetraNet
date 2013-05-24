using System;
using MetraTech;
using MetraTech.Interop.RCD;
using System.IO;
using System.Collections;
using System.Text;
using System.Xml;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.EnterpriseServices;
using Microsoft.Dynamics.GP.eConnect;


[assembly: Guid("F74FB2EB-B0CC-492a-9B26-6F8F95F790BE")]

namespace MetraTech.AR
{
  [Guid("C89ADCC3-A430-49ca-86D5-676211822491")]
  public interface IeConnectShim
  {
    bool ExecStoredProc(string sXML, string ConnectionString, ref long ErrorState, ref string ErrorString, ref string OutgoingMessage);
    ArrayList ErrorCodes {get; set;}
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.NotSupported)]
  [Guid("8AF23D90-77FC-4dd9-A72C-0B6D4AB791FF")]
  public class eConnectShim : ServicedComponent, IeConnectShim
  {
    public eConnectShim()
    {
    }

    public bool ExecuteProcedure(string sConnectionString, string xml)
    {
        return false;
    }

    /*[AutoComplete]*/
    public bool ExecStoredProc(string sXML, string ConnectionString, ref long ErrorState, ref string ErrorString, ref string OutgoingMessage)
    {
        bool bStatus = false;

        try
        {
            eConnectMethods e = new eConnectMethods();
            try
            { 
                bStatus = e.eConnect_EntryPoint(ConnectionString, EnumTypes.ConnectionStringType.SqlClient, sXML, EnumTypes.SchemaValidationType.None, null);
            }
            catch (eConnectException exc)	// The eConnectException class will catch any business logic releated errors from eConnect.
            {
                SetErrorCodesFromException(exc);
            }
            finally
            {
                e.Dispose();
            }

        }
        catch (System.Exception ex)		// Catch any system error that might occurr.
        {
            SetErrorCodesFromException(ex);
        }

        return bStatus;
    }

    private ArrayList errorCodes;

    public ArrayList ErrorCodes
    {
        get
        {
            if (errorCodes == null)
            { //May need to throw exception or otherwise note when ErrorCodes have been requested but
              //the information has not been populated.
      
                return null;
            }
            else
                return errorCodes;
        }
        set
        {
            errorCodes = value;
        }
    }
    
    /// <summary>
    /// Internal helper routine to take an exception and transform it into what is expected by the eConnect interface
    /// </summary>
    /// <param name="ex"></param>
    private void SetErrorCodesFromException(Exception ex)
    {
        ArrayList outErrorList = new ArrayList();
        Exception currentException = ex;
        while (currentException != null)
        {
            outErrorList.Add(ex.Message);
            currentException = currentException.InnerException;
        }

        ErrorCodes = outErrorList;
    }
  }
}
