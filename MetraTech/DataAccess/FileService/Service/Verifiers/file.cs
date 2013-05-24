namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  using System;
  using System.IO;
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Interfaces
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  enum NmIdx
  {
    SERVICEDEF = 0,
    CONTROLNUMBER = 1,
    DATE = 2,
    TYPE = 3,
    EXTENSION = 4
  }
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region File acVerifier
  /// <summary>
  /// cFileVerifier defines what it means to verify a file. 
  /// For now it just checks the existance
  /// </summary>
  class cFileVerifier : acVerifier
  {
    public cFileVerifier(string value)
      : base(value)
    {
      Name = "cFileVerifier";
    }

    public override bool Verify()
    {
      Log.Debug(CODE.__FUNCTION__);
      if (File.Exists(VALUE))
        return true;
      return false;
    }
  } 
  #endregion
  //////////////////////////////////////////////////////////////////////////////////////
  #region cFileName acVerifier
  /// <summary>
  /// cFileNameVerifier defines what it means to verify a filename. 
  /// This will check that the format is correct if name encoding format is enabled
  ///
  /// cFileName should be:
  ///   SERVICEDEF.CONTROLNUMBER. DATE.TYPE
  ///   SERVICEDEF is the value of the service definition to which this file is related. 
  ///     This information will be used to lookup mapping information used to invoke the appropriate 
  ///     service on the record file. This field must map to a valid service definition in the mapping BME. 
  ///   CONTROLNUMBER is a unique value assigned to the file, much like a message ID in the pipeline, 
  ///     to uniquely identify the file data (session set). This can be any string of 
  ///     letters or numbers, but may not contains a ‘.’ character.
  ///   DATE is a date string in YYYYMMDDHHMM format.
  ///   TYPE is one of the following:
  ///     •	flat	this represents a single flat record file.
  ///     •	zip	a compressed group of flat candidates
  /// </summary>
  class cFileNameVerifier : acVerifier
  {
    cTargetWorkInfo Work = null;
    /// <summary>
    /// 
    /// </summary>
    /// <param name="value"></param>
    public cFileNameVerifier(cTargetWorkInfo work)
      : base(work.OldRecordName.FullName)
    {
      Work = work;
      Name = "cFileNameVerifier";
    }
    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public override bool Verify()
    {
#if false
      // Check DB against file
      if (!(TstFileUnique()))
      {
        Log.Error(String.Format("Record file {0} has already been processed. Must not process again.",
                                Work.OldRecordName.NameParts[(int)NmIdx.EXTENSION]));
        return false;
      }

      // Confirm the DESC file existance
      if (!Work.MANAGER.SERVICECFG.USEFILENAMEENCODING)
      {
        return TstForDescFile();
      }
      else // Otherwise confirm how the file name encoding is...
        if (TstExtension())
          if (TstType())
            if (TstDate())
              if (TstServiceDef())
                return true;
#endif
      return false;
    }
    private bool TstDate()
    {
      bool valid = false;
      try
      {
        DateTime dt = Convert.ToDateTime(Work.RECORDFILE.NameParts[(int)NmIdx.DATE]);
        valid = true;
      }
      catch (System.FormatException e)
      {
        Log.Error(String.Format("acValidate value format, Date segment is not valid date format. " +
                                "User provided ({0}). Exception error : {1}",
                                Work.RECORDFILE.NameParts[(int)NmIdx.DATE], e.Message));
      }
      return valid;
    }

    private bool TstExtension()
    {
      // Check various parts
      foreach (string ext in CONST.SupportedExtensions)
      {
        if (Work.RECORDFILE.NameParts[(int)NmIdx.EXTENSION] == ext)
        {
          return true;
        }
      }
      Log.Error("Unknown file extension \"" + Work.RECORDFILE.NameParts[(int)NmIdx.EXTENSION] + "\"");
      return false;
    }

    private bool TstForDescFile()
    {
      cFileVerifier fv = new cFileVerifier(Work.DESCFILE.FullName);
      bool val = fv.Verify();
      if (!val)
        Log.Error("Descriptor file \"" + Work.DESCFILE.FullName + "\" does not exist");
      return val;
    }
  } 
  #endregion
  ////////////////////////////////////////////////////////////////////////////////////// 
}
