using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class BringupState
    {
        public enum State { idle, inProgress, success, failure };

        private State _state;
        public State state { get { return _state; } set { _state = value; updateCallbacks(); } }

        private string _message;
        public string message { get { return _message; } set { _message = value; updateCallbacks(); } }

        public BringupState(string message)
        {
            this.message = message;
            state = State.idle;
        }

        public delegate void UpdateEvent();
        public UpdateEvent OnUpdateEvent;

        private void updateCallbacks()
        {
            if( OnUpdateEvent != null)
            {
                OnUpdateEvent();
            }
        }

    }
}
