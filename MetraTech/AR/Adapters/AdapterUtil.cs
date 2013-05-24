using System;
using System.Xml;
using System.Diagnostics;
using System.Collections;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.AR;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;
using System.Runtime.InteropServices;

[assembly: ComVisible(false)]
[assembly: GuidAttribute("953392CD-D42C-41de-A7A9-23FEC5D6D87B")]

namespace MetraTech.AR.Adapters
{
  public class AdapterUtil
  {
    /// <summary>
    /// delete batch in AR if exists
    /// </summary>
    /// <returns>true if batch was deleted, false otherwise</returns>
    public static bool DeleteBatch(string batchID, string sExtNamespace, object ARConfigState, out bool bBatchExists)
    {
      bool batchCanBeDeleted;
      
      if (BatchExists(batchID, sExtNamespace, ARConfigState, out batchCanBeDeleted))
      {
        bBatchExists = true;
        if (batchCanBeDeleted)
        {
          //create AR document to delete batch on AR system
          MTXmlDocument doc = new MTXmlDocument();
          doc.LoadXml(@"
              <ARDocuments ExtNamespace='" + sExtNamespace + @"'>
                <ARDocument>
                  <DeleteBatch>
                    <BatchID/>
                  </DeleteBatch>
                </ARDocument>      
              </ARDocuments>");

          doc.SetNodeValue("//BatchID", batchID);

          IMTARWriter ARWriter = new MTARWriterClass();
          ARWriter.DeleteBatches( doc.InnerXml, ARConfigState );

          return true;
        }
        else
        {
          return false;
        }

      }
      bBatchExists = false;
      return false;
    }

    public static bool DeleteAdapterBatch(string batchID, object ARConfigState, IRecurringEventRunContext context, out string returnMessage)
    {
      bool batchCanBeDeleted;

      ArrayList arrAccountNameSpaces = ARConfiguration.GetInstance().AccountNameSpaces;
      bool[] arrDeleteBatchInThisNamespace = new bool[arrAccountNameSpaces.Count];

      returnMessage = "";

      string sAccountNameSpace;
      bool BatchCanBeDeletedFromAllSystems = true;
      for (int i=0; i<arrAccountNameSpaces.Count; i++)
      {
        sAccountNameSpace = arrAccountNameSpaces[i].ToString();
        if (BatchExists(batchID, sAccountNameSpace, ARConfigState, out batchCanBeDeleted))
        {
          if (batchCanBeDeleted)
          {
            context.RecordInfo(String.Format("AR Batch {0} exists in AR system {1} and can be deleted.",batchID,sAccountNameSpace));
            arrDeleteBatchInThisNamespace[i] = true;
          }
          else
          {
            returnMessage += String.Format("AR Batch {0} exists in AR system {1} but it cannot be deleted.",batchID,sAccountNameSpace);
            context.RecordWarning(returnMessage);
            BatchCanBeDeletedFromAllSystems = false;            
          }
        }
        else
        {
          context.RecordInfo(String.Format("AR Batch {0} does not exist in AR system {1} and does not need to be deleted.",batchID,sAccountNameSpace));
          arrDeleteBatchInThisNamespace[i] = false;
        }
      }

      if (BatchCanBeDeletedFromAllSystems)
      {
        for (int i=0; i<arrAccountNameSpaces.Count; i++)
        {
          sAccountNameSpace = arrAccountNameSpaces[i].ToString();
          if (arrDeleteBatchInThisNamespace[i])
          {
            context.RecordInfo(String.Format("Deleting AR Batch {0} from AR system {1}", batchID, sAccountNameSpace));

            //create AR document to delete batch on AR system
            MTXmlDocument xmlDoc = new MTXmlDocument();
            xmlDoc.LoadXml(@"<ARDocuments ExtNamespace='" + sAccountNameSpace + @"'>
                <ARDocument>
                  <DeleteBatch>
                    <BatchID/>
                  </DeleteBatch>
                </ARDocument>      
              </ARDocuments>");

            xmlDoc.SetNodeValue("//BatchID", batchID);

            IMTARWriter ARWriter = new MTARWriterClass();
            ARWriter.DeleteBatches( xmlDoc.InnerXml, ARConfigState );
            
            returnMessage += String.Format("Deleted AR Batch {0} from AR system {1}.", batchID, sAccountNameSpace);
          }
        }

        return true;
      }
      else
      {
        returnMessage += " Most likely the batch cannot be deleted from the AR System because it has already been posted.";
        return false;
      }

      /*
      if (BatchExists(batchID, ARConfigState, out batchCanBeDeleted))
      {
        bBatchExists = true;
        if (batchCanBeDeleted)
        {
          //create AR document to delete batch on AR system
          MTXmlDocument doc = new MTXmlDocument();
          doc.LoadXml(@"
              <ARDocuments>
                <ARDocument>
                  <DeleteBatch>
                    <BatchID/>
                  </DeleteBatch>
                </ARDocument>      
              </ARDocuments>");

          doc.SetNodeValue("//BatchID", batchID);

          IMTARWriter ARWriter = new MTARWriterClass();
          ARWriter.DeleteBatches( doc.InnerXml, ARConfigState );

          return true;
        }
        else
        {
          return false;
        }

      }
      bBatchExists = false;
      return false;
      */

    }
    
    /// <summary>
    /// checks if batch can be exists in AR
    /// </summary>
    public static bool BatchExists(string batchID, string sExtNamespace, object ARConfigState, out bool CanBeDeleted)
    {
      //create CanDeleteBatch document
      MTXmlDocument xmlDoc = new MTXmlDocument();
      xmlDoc.LoadXml(@"<ARDocuments ExtNamespace='" + sExtNamespace + @"'>
            <ARDocument>
              <CanDeleteBatch>
                <BatchID/>
              </CanDeleteBatch>
            </ARDocument>
          </ARDocuments>");

      xmlDoc.SetNodeValue("//BatchID", batchID);
      
      //call AR interface
      IMTARReader ARReader = new MTARReaderClass();
      string xmlResponse = ARReader.CanDeleteBatches(xmlDoc.InnerXml, ARConfigState);

      //check exists element in response doc
      xmlDoc.LoadXml(xmlResponse);
      CanBeDeleted=xmlDoc.GetNodeValueAsBool("//CanDelete");
      return xmlDoc.GetNodeValueAsBool("//Exists");
    }


    static public string ToString(ExportType expType, bool plural)
    {
      string str;

      switch(expType)
      {
        case ExportType.PAYMENTS: str = "payment"; break;
        case ExportType.AR_ADJUSTMENTS: str = "AR adjustment"; break;
        case ExportType.PB_ADJUSTMENTS: str = "post-bill adjustment"; break;
        case ExportType.DELETED_PB_ADJUSTMENTS: str = "deleted post-bill adjustment"; break;
        default: str = "item"; break;
      }
      if (plural)
        str += "s";
      return str;
    }

  }
}
