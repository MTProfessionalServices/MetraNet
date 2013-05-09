using System;
using System.Data;
using MetraTech.DomainModel.BaseTypes;

namespace BaselineGUI
{
    public class AccountLoadDesc
    {
        private Account _acct;
        public Account acct
        {
            set
            {
                _acct = value;
                if (value != null)
                {
                    setStatusCell("UserName", value.UserName);
                    setStatusCell("Type", value.GetType().ToString());
                }
            }
            get { return _acct; }
        }

        public int sequence;

        private int _predecessor;   // -1 if no predecessor
        public int predecessor
        { set { _predecessor = value; setStatusCell("Predecessor", value); } get { return _predecessor; } }

        private int _state;
        public int state { set { _state = value; setStatusCell("State", value); } get { return _state; } }

        public int corpAccountBin = 0;

        public string message
        {
            set
            {
                setStatusCell("Message", value);
            }
        }

        public DateTime timeOfQueue { set { setStatusCell("Queued", value); } }
        public DateTime timeOfCompletion { set { setStatusCell("Completion", value); } }

        public DataRow status;

        public void setStatusCell<T>(string name, T value)
        {
            if (status != null)
            {
                lock (status.Table)
                {
                    status[name] = value;
                }
            }
        }
    }

}
