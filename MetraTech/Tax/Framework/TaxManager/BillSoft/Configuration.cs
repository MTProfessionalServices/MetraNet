//=============================================================================
// Copyright 1997-2012 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//-----------------------------------------------------------------------------
// AUTHOR: Joseph Barnett
// MODULE: BillSoftConfiguration.cs
// DESCRIPTION: Implements the BillSoft Configuration Parsing Logic
//
// TODO: 
//  Cleanup unused parameters
//=============================================================================

#region

using System;
using System.IO;
using MetraTech.Tax.Framework;
using MetraTech.Xml;
using BillSoft.EZTaxNET;

#endregion

namespace MetraTech.Tax.Framework.MtBillSoft
{
  public class BillSoftConfiguration
  {
    #region Private Data

    private readonly string mCfgFile = "";
    private readonly Logger mLogger = new Logger("[TaxManager.BillSoft.ConfigHelper]");
    private int mNumPerBulkInsertBatch = 1000;

    #endregion // Private Data

    #region CTor and DTors

    public BillSoftConfiguration(string cfgFile)
    {
      EnableTaxLogging = false;
      try
      {
        if (!File.Exists(cfgFile))
        {
          mLogger.LogError("BillSoft Metratech taxmanager configuration file does not exist.");
          throw new TaxException(String.Format(
            "BillSoft Metratech taxmanager configuration file [{0}] does not exist.", cfgFile));
        }
        mCfgFile = cfgFile;

        ReadConfigFile();
      }
      catch (Exception ex)
      {
        mLogger.LogException(@"Please check your Taxmanager\Vendor\Billsoft configuration file", ex);
        throw ex;
      }
    }

    #endregion // CTor and DTors

    #region Property Accessors
    public string LogPrefix { get; private set; }
    public FilePaths EZTaxFilePaths { get; private set; }

#if false
    public string CfgFile
    {
      get { return mCfgFile; }
    }
#endif

    public int NumPerBulkInsertBatch
    {
      get { return mNumPerBulkInsertBatch; }
    }

    public bool EnableTaxLogging { get; private set; }

    #endregion // Property Accessors

    #region Configuration File Reading Methods

    private void ReadConfigFile()
    {
      try
      {
        mLogger.LogDebug("Begin ReadConfigFile method ...");

        var doc = new MTXmlDocument();
        doc.Load(mCfgFile);

        var installPath = doc.GetNodeValueAsString("/xmlconfig/BillSoft/EZTaxInstallPath").Trim();
        if (String.IsNullOrEmpty(installPath))
          throw new ArgumentNullException("BillSoft Installation Path not set in configuration file.");

        if(installPath[installPath.Length - 1] != '\\')
          installPath += @"\"; // Little bit of path fixup

        TestProperty("BillSoft/EZTaxInstallPath", installPath, true);

        // Create a FilePaths object
        var paths = new FilePaths
        {
          Data = installPath + @"Data\EZTax.dat",
          IDX = installPath + @"Data\EZTax.idx",
          DLL = installPath + @"Data\EZTax.dll",
          NpaNxx = installPath + @"Data\EZTax.npa",
          Status = installPath + @"Data\EZTax.sta",
          Temp = installPath + @"Data\tmp77777.dat",
          Location = installPath + @"Data\EZDesc.dat",
          Zip = installPath + @"Data\EZZip.dat",
          CustomerKey = installPath + @"Data\cust_key",
          PCode = installPath + @"Data\EZTax.pcd",
          JCode = installPath + @"Data\EZTax.jtp",
          Override = ""
        };
        EZTaxFilePaths = paths;

        TestProperty("BillSoft/EZTaxLogPath",
                     (EZTaxFilePaths.Log = doc.GetNodeValueAsString("/xmlconfig/BillSoft/EZTaxLogPath").Trim()), true);
        
        LogPrefix = doc.GetNodeValueAsString("/xmlconfig/BillSoft/EZTaxLogFilePrefix").Trim();
        TestProperty("BillSoft/EZTaxLogFilePrefix", LogPrefix, true);

        try
        {
          mNumPerBulkInsertBatch = doc.GetNodeValueAsInt("/xmlconfig/NumPerBulkInsertBatch");
        }
        catch
        {
          mNumPerBulkInsertBatch = 1000;
        }

        mLogger.LogDebug("Exiting ReadConfigFile method with success return code...");
        return;
      }
      catch (Exception e)
      {
        mLogger.LogError(string.Format("Error occurred ({0}: {1})", e.Source, e.Message));
        return;
      }
    }

    #endregion // Configuration File Reading Methods

    #region Helper Methods

    private static void TestProperty(string name, string value, bool mustHaveValue)
    {
      if (String.IsNullOrEmpty(value.Trim()) && mustHaveValue)
        throw new Exception(String.Format("{0} is either null or empty. Please configure it in the config file.", name));
    }

    #endregion // Helper Methods
  }
}
