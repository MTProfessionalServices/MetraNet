using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class Progressable
    {
        public string name;

        private bool _isRunning = false;
        public bool isRunning { get { return _isRunning; } set { _isRunning = value; RaiseModelChange(); } }

        private int _Value = 0;
        public int Value { get { return _Value; } set { _Value = value; RaiseModelChange(); } }

        private int _Minimum = 0;
        public int Minimum { get { return _Minimum; } set { _Minimum = value; RaiseModelChange(); } }

        private int _Maximum = 0;
        public int Maximum { get { return _Maximum; } set { _Maximum = value; RaiseModelChange(); } }

        public event EventHandler<EventArgs> OnModelChangeEvent = null;

        private void RaiseModelChange()
        {
            if (OnModelChangeEvent != null)
            {
                EventArgs d = new EventArgs();
                OnModelChangeEvent(this, d);
            }
        }

    }
}
