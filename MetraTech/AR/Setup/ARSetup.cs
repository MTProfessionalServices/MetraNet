using System;
using System.Xml;
using System.IO;
using MetraTech.Xml;


namespace ARSetup
{
  /// <summary>
	/// Utility to configure A/R integration
  /// </summary>
  class ARSetup
  {
    //consts
    const int AR_ACCOUNT_ID_LENGTH = 15;        //length of account ID in AR
    const int USERNAME_LENGTH_WITHOUT_AR = 40;  //length of username prop in accountCreation (without AR)

    
    //data
    string mGPServerName = "127.0.0.1";
    string mGPDatabaseName = "MTGP";
    string mGPUserName = "sa";
    string mGPPassword = "";
    bool mEnableAR = true;

    string mStageFile;
    string mStageFileWithAR;
    string mStageFileWithoutAR;
    MetraTech.Interop.RCD.IMTRcd mRCD;

    ARSetup()
    {
      mRCD = new MetraTech.Interop.RCD.MTRcdClass();
      
      string stagePath = mRCD.ExtensionDir + @"\Account\config\pipeline\AccountCreation\";
      mStageFile = stagePath + "stage.xml";
      mStageFileWithAR = stagePath + "stageWithAR.xml";
      mStageFileWithoutAR = stagePath + "stageWithoutAR.xml";
    }
    
    
    /// <returns>0 on success, 1 if arguments are invalid, can throw exception</returns>
    static int Main(string[] args)
    {
      int returnCode = 0;
      
      ARSetup setup = new ARSetup();

      if (setup.ParseArgs(args))
      {
        setup.PrintCurrentSetup();

        if(setup.mEnableAR)
          Console.WriteLine("enabling A/R integration\n");
        else
          Console.WriteLine("disabling A/R integration\n");

        setup.SetupARConfigFile();
        setup.SetupAccountCreationStage();
        setup.SetupAccountCreationService();
        setup.SetupServerAccess();

        if(setup.mEnableAR)
          Console.WriteLine("enabling A/R integration succeeded\n");
        else
          Console.WriteLine("disabling A/R integration succeeded\n");
      }
      else
      {
        returnCode = 1; //invalid args
      }

      return returnCode;
    }

    void PrintUsage()
    {
      Console.WriteLine("\nusage: ARSetup [options]\n");
      Console.WriteLine("options:");
      Console.WriteLine("  -E(nable)              : enable AR integration");
      Console.WriteLine("  -D(isable)             : disable AR integration");
      Console.WriteLine("  -GPServerName <server> : server that hosts GreatPlains DB, default: " + mGPServerName);
      Console.WriteLine("  -GPDatabaseName <db>   : GreatPlains databasename, default: " + mGPDatabaseName);
      Console.WriteLine("  -GPUserName <user>     : DB username, default: " + mGPUserName);
      Console.WriteLine("  -GPPassword <password> : DB password, default: " + mGPPassword);
      Console.WriteLine("\nexamples:");
      Console.WriteLine("  ARSetup                : check current configuration");
      Console.WriteLine("  ARSetup –e             : enable A/R support on local machine");
      Console.WriteLine("  ARSetup –d             : disable A/R support");
    }
    
    /// <summary>
    /// parses command-line args.
    /// On error prints correct usage.
    /// Returns true if program should continue.
    /// </summary>
    bool ParseArgs(string[] args)
    {
      int i = 0;
      bool argsValid = false;

      if (args.GetUpperBound(0) < 0)
      {
        //no args, just write current setup
        PrintCurrentSetup();
        Console.WriteLine("for further options type ARSetup -?");
        return false;
      }

      while( i <= args.GetUpperBound(0))
      {
        switch(args[i].ToLower())
        {
          case "-e":
            goto case "-enable";
          case "-enable":
            mEnableAR = true;
            argsValid = true;
            break;
          case "-d":
            goto case "-disable";
          case "-disable":
            mEnableAR = false;
            argsValid = true;
            break;
          case "-gpservername":
            if (i < args.GetUpperBound(0))
            {
              i++;
              mGPServerName = args[i];
            }
            else
            {
              argsValid = false;
            }
            break;
          case "-gpdatabasename":
            if (i < args.GetUpperBound(0))
            {
              i++;
              mGPDatabaseName = args[i];
            }
            else
            {
              argsValid = false;
            }
            break;
          case "-gpusername":
            if (i < args.GetUpperBound(0))
            {
              i++;
              mGPUserName = args[i];
            }
            else
            {
              argsValid = false;
            }
            break;
          case "-gppassword":
            if (i < args.GetUpperBound(0))
            {
              i++;
              mGPPassword = args[i];
            }
            else
            {
              argsValid = false;
            }
            break;
          default:
            argsValid = false;
            i = args.GetUpperBound(0); //break while loop
            break;
        }
        i++;
      }

      if (!argsValid)
        PrintUsage();

      return argsValid;
    }

    void PrintCurrentSetup()
    {
      if (File.Exists(mStageFileWithoutAR) && !File.Exists(mStageFileWithAR))
        Console.WriteLine("A/R integration is currently enabled");
      else if (File.Exists(mStageFileWithAR) && !File.Exists(mStageFileWithoutAR))
        Console.WriteLine("A/R integration is currently disabled");
      else
        Console.WriteLine("unable to determine current setup");
    }

    void SetupARConfigFile()
    {
      Console.WriteLine("setting up ARConfig.xml");
      
      try
      {
        string filePath = mRCD.ExtensionDir + "\\AR\\config\\AR\\ARConfig.xml";
        MTXmlDocument doc = new MTXmlDocument();
        doc.Load(filePath);
        bool changed = false;
        
        bool enabled = doc.GetNodeValueAsBool("//AREnabled");
        if(mEnableAR)
        {
          if (enabled)
            Console.WriteLine("  A/R already enabled.");
          else
          {
            doc.SetNodeValue("//AREnabled", true);
            changed = true;
            Console.WriteLine("  enabled A/R.");
          }
        }
        else
        {
          if (enabled)
          {
            doc.SetNodeValue("//AREnabled", false);
            changed = true;
            Console.WriteLine("  disabled A/R.");
          }
          else
            Console.WriteLine("  A/R already disabled.");
        }

        if (changed)
          doc.Save(filePath);
      }
      catch (System.IO.FileNotFoundException)
      {
        if (mEnableAR)
          throw new ApplicationException("Cannot enable AR. Missing ARConfig.xml\n");
        else
          Console.WriteLine("  A/R already disabled (ARConfig.xml not found).\n");
      }

      Console.WriteLine("setting up ARConfig.xml succeeded\n");
    }

    void SetupAccountCreationStage()
    {
      Console.WriteLine("setting up AccountCreation stage");

      SwapFiles(mStageFile, mStageFileWithAR, mStageFileWithoutAR);

      Console.WriteLine("setting up AccountCreation stage succeeded\n");
    }

    /// <summary>
    /// swaps files to enable/disable AR
    /// </summary>
    void SwapFiles( string file, string fileWithAR, string fileWithoutAR)
    {
      if(mEnableAR)
      {
        if(File.Exists(fileWithoutAR) && !File.Exists(fileWithAR))
        {
          Console.WriteLine("  A/R already enabled");
        }
        else
        {
          if(!File.Exists(fileWithAR))
            throw new ApplicationException("Cannot enable A/R. Missing " + fileWithAR);

          if(File.Exists(fileWithoutAR))
            File.Delete(fileWithoutAR);

          File.Move(file, fileWithoutAR);
          File.Move(fileWithAR, file);
          Console.WriteLine("  enabled A/R");
        }
      }
      else // not mEnableAR
      {
        if(File.Exists(fileWithAR) && !File.Exists(fileWithoutAR))
        {
          Console.WriteLine("  A/R already disabled");
        }
        else
        {
          if(!File.Exists(fileWithoutAR))
            throw new ApplicationException("Cannot disable A/R. Missing " + fileWithoutAR);

          if(File.Exists(fileWithAR))
            File.Delete(fileWithAR);

          File.Move(file, fileWithAR);
          File.Move(fileWithoutAR, file);
          Console.WriteLine("  disabled A/R");
        }
      }
    }

    void SetupAccountCreationService()
    {
        try
        {
            Console.WriteLine("setting up AccountCreation service definition");

            //find accountcreation.msixdef
            string filePath = mRCD.ExtensionDir + @"\Account\config\service\metratech.com\accountcreation.msixdef";
            MTXmlDocument doc = new MTXmlDocument();
            doc.Load(filePath);

            //restrict username length to 15 for GreatPlains (keep it at 40 otherwise)

            //find <length> child of <ptype> where <dn> child is "username"
            XmlNode lengthNode = doc.SelectSingleNode("//length[../dn = \"UserName\"]");
            if (lengthNode == null)
            {  //Check for lowercase version
                lengthNode = doc.SelectSingleNode("//length[../dn = \"username\"]");
            }

            if (lengthNode != null)
            {
                int length = MTXmlDocument.GetNodeValueAsInt(lengthNode);

                if (mEnableAR)
                {
                    if (length <= AR_ACCOUNT_ID_LENGTH)
                    {
                        Console.WriteLine("  username already limited to {0} characters", AR_ACCOUNT_ID_LENGTH);
                    }
                    else
                    {
                        Console.WriteLine("  limiting username to {0} characters (was {1})", AR_ACCOUNT_ID_LENGTH, length);
                        MTXmlDocument.SetNodeValue(lengthNode, AR_ACCOUNT_ID_LENGTH);
                        doc.Save(filePath);
                    }
                }
                else
                {
                    if (length > AR_ACCOUNT_ID_LENGTH)
                    {
                        Console.WriteLine("  username already {0} characters", length);
                    }
                    else
                    {
                        Console.WriteLine("  setting username back to {0} characters (was {1})", USERNAME_LENGTH_WITHOUT_AR, length);
                        MTXmlDocument.SetNodeValue(lengthNode, USERNAME_LENGTH_WITHOUT_AR);
                        doc.Save(filePath);
                    }
                }

                Console.WriteLine("setting up AccountCreation service definition succeeded\n");
            }
            else
            {
                Console.WriteLine("Error setting up AccountCreation service definition: Unable to locate UserName node\n");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error setting up AccountCreation service definition: Unable to locate UserName node: " + ex.Message + "\n");
        }
    }


    void SetupServerAccess()
    {
      Console.WriteLine("setting up servers.xml");
      if (mEnableAR)
      {
        //find servers.xml
        string filePath = mRCD.ExtensionDir + "\\AR\\config\\ServerAccess\\servers.xml";
        XmlDocument doc = new XmlDocument();
        doc.Load(filePath);
        
        //find <server> node with <servertype> "GreatPlainsServer"
        XmlNode serverNode = doc.SelectSingleNode("//server[servertype = \"GreatPlainsServer\"]");
        if (serverNode == null)
        {
          Console.WriteLine("  adding new server entry");

          serverNode = doc.CreateNode(XmlNodeType.Element,"server","");
          serverNode.InnerXml =
            "<servertype>GreatPlainsServer</servertype>" +
            "<servername></servername>" +
            "<databasename></databasename>" +
            "<username></username>" + 
            "<password></password>";
          doc.DocumentElement.AppendChild(serverNode);
        }
        else
        {
          Console.WriteLine("  modifying existing server entry");
        }
        Console.WriteLine("  GPServerName = " + mGPServerName);
        Console.WriteLine("  GPDatabaseName = " + mGPDatabaseName);
        Console.WriteLine("  GPUserName = " + mGPUserName);
        Console.WriteLine("  GPPassword = " + mGPPassword);

        serverNode.SelectSingleNode("servername").InnerText = mGPServerName;
        serverNode.SelectSingleNode("databasename").InnerText = mGPDatabaseName;
        serverNode.SelectSingleNode("username").InnerText = mGPUserName;
        serverNode.SelectSingleNode("password").InnerText = mGPPassword;
        //Remove the encrypted attribute from the password tag if it exists (occurs when AR was enabled with encryption and then "re-enabled")
        XmlAttributeCollection attrColl = serverNode.SelectSingleNode("password").Attributes;
        XmlAttribute attr = attrColl["encrypted"];
        if (attr != null)
        {
            attrColl.Remove(attr);
        }

        
        doc.Save(filePath);
      }
      else // not mEnableAR
      {
        Console.WriteLine("  no change required to disable A/R");
      }
      Console.WriteLine("setting up servers.xml succeeded\n");
    }
  }
}
