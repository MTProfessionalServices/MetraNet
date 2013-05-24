using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel;

namespace MetraTech.UI.Controls
{

  public enum MetaDataType
  {
    DomainModel,
    ServiceDefinition
  }

  public class MetaDataItem
  {
    public MetaDataItem()
    {
    }

    private string mValue;

    [NotifyParentProperty(true)]
    [Description("The MetaData to use for better designer support."), DefaultValue("")]
    [TypeConverter(typeof(MetaDataTypeConverter))]
    [Browsable(true)]
    public string Value
    {
      get { return mValue; }
      set { mValue = value; }
    }

    private string mAlias;
    public string Alias
    {
      get { return mAlias; }
      set { mAlias = value; }
    }

    private string mAssemblyName;
    public string AssemblyName
    {
      get { return mAssemblyName; }
      set { mAssemblyName = value; }
    }

    private string mAliasBaseType;
    public string AliasBaseType
    {
      get { return mAliasBaseType; }
      set { mAliasBaseType = value; }
    }

    private MetaDataType mType;
    public MetaDataType MetaType
    {
      get { return mType; }
      set { mType = value; }
    }
	
  }

}