namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // This class contains constants used in the code, to make modification easier
  // Eventually these should be pulled out of the app.config file.
  ////////////////////////////////////////////////////////////////////////////////////// 
  class CONST
  {
    public static readonly string RecordFileName = "USAGERECORDFILE";
    public static readonly int FileNamePartCount = 5;
    public static readonly string[] SupportedTypes = { "zip", "flat" };
    public static readonly string[] SupportedExtensions = { "start", "metering", "failed", "complete" };
  }
}
