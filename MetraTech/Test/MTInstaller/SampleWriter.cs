
using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;


[assembly: Guid("16587146-d97e-4f85-90b6-92320de0e565")]


namespace  MetraTech.Test.MTInstaller
{
  /// <summary>
  /// Summary description for ReasonCodeWriter.
  /// </summary>
  /// 
  
  [Guid("56c3b4c4-83c6-4a13-a955-b32337eb6c22")]
  public interface ISampleWriter
  {
    int Create();
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("3a5746ae-57a2-4818-9aa6-a5291bcad024")]
  public class SampleWriter : ServicedComponent, ISampleWriter
  {
    // looks like this is necessary for COM+?
    public SampleWriter() { }

    [AutoComplete]
    public int Create()
    {
      return -1;
    }
  }
 
}

