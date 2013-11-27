using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public static class ProgressableFactory
    {
        static Dictionary<string, Progressable> progs = new Dictionary<string, Progressable>();

        private static Progressable _active;
        public static Progressable active { get { return _active; } set { _active = value; RaiseModelChange(); } }

        public static event EventHandler<EventArgs> OnModelChangeEvent = null;
        private static void RaiseModelChange()
        {
            if (OnModelChangeEvent != null)
            {
                EventArgs d = new EventArgs();
                OnModelChangeEvent(null, d);
            }
        }

        public static Progressable find(string name)
        {
            Progressable prog;
            if (progs.ContainsKey(name))
                return progs[name];
            prog = new Progressable();
            prog.name = name;
            prog.OnModelChangeEvent += handleChange;
            progs.Add(name, prog);
            return prog;
        }

       private static void handleChange(object sender, EventArgs e)
       {
           if (sender is Progressable)
           {
               Progressable who = (Progressable)sender;
               if (who == active)
                   RaiseModelChange();
           }
       }

    }
}
