using System;

namespace MetraTech.ActivityServices.PersistenceService
{
    internal class PendingWorkItem
    {
      #region Members
      private int blocked;
      private string info;
      private Guid instanceId;
      private DateTime nextTimer;
      private byte[] serializedActivity;
      private Guid stateId;
      private int status;
      private ItemType type;
      private bool unlocked;
      #endregion

      #region Constructor
      public PendingWorkItem(ItemType type)
        {
            this.type = type;
          }
      #endregion

      #region Properties

          public int Blocked
          {
            get { return blocked; }
            set { blocked = value; }
          }

          public string Info
          {
            get { return info; }
            set { info = value; }
          }

          public Guid InstanceId
          {
            get { return instanceId; }
            set { instanceId = value; }
          }

          public DateTime NextTimer
          {
            get { return nextTimer; }
            set { nextTimer = value; }
          }

          public byte[] SerializedActivity
          {
            get { return serializedActivity; }
            set { serializedActivity = value; }
          }

          public Guid StateId
          {
            get { return stateId; }
            set { stateId = value; }
          }

          public int Status
          {
            get { return status; }
            set { status = value; }
          }

          public ItemType Type
          {
            get { return type; }
            set { type = value; }
          }

          public bool Unlocked
          {
            get { return unlocked; }
            set { unlocked = value; }
          }
          #endregion
         
      public enum ItemType
        {
            Instance,
            CompletedScope,
            ActivationComplete
        }
    }
}