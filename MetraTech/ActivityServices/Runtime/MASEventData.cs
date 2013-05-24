using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Permissions;

namespace MetraTech.ActivityServices.Runtime
{
  [Serializable]
  internal abstract class CMASEventData : CMASRequestData
  {
    #region Private Members
    private Guid m_InstanceId;

    private bool m_bAllowMultipleInstances = false;
    private Guid m_ProcessorInstanceId = Guid.Empty;

    private string m_DataTypeName;
    private int m_AccountId;

    private string m_EventName;
    #endregion

    #region Properties
    public Guid InstanceId
    {
      get { return m_InstanceId; }
      set { m_InstanceId = value; }
    }

    public bool AllowMultipleInstances
    {
      get { return m_bAllowMultipleInstances; }
      set { m_bAllowMultipleInstances = value; }
    }

    public Guid ProcessorInstanceId
    {
      get { return m_ProcessorInstanceId; }
      set { m_ProcessorInstanceId = value; }
    }

    public string DataTypeName
    {
      get { return m_DataTypeName; }
      set { m_DataTypeName = value; }
    }

    public string EventName
    {
      get { return m_EventName; }
      set { m_EventName = value; }
    }

    public int AccountId
    {
      get { return m_AccountId; }
      set { m_AccountId = value; }
    }

    public string EntityKey { get; set; }
    #endregion

    #region Methods
    public abstract string GetQueryPredicate(bool isOracle);
    public abstract string GetTableName();
    public abstract string GetIDColumnName();

    protected string EncodeGuid(Guid value, bool isOracle)
    {
        string retval = (isOracle ? "'" : "0x");

        Byte[] bytes = value.ToByteArray();

        for (int i = 0; i < bytes.Length; i++)
        {
            retval += string.Format("{0:X2}", bytes[i]);
        }

        if (isOracle)
        {
            retval += "'";
        }

        return retval;
    }
    #endregion
  }
}
