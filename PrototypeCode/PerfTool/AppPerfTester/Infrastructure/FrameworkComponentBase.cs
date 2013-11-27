using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class FrameworkComponentBase
    {
        public string name { set; get; }
        public string fullName { set; get; }

        // Model to present to UI
        public MsgLogger msgLogger { set; get; }

        public BringupState bringupState { set; get; }

        public int priority {set; get;}

        public List<FrameworkComponentUpdateCallback> OnUpdateEvent { set; get; }

        public FrameworkComponentBase()
        {
            name = null;
            fullName = "Fix Me";
            priority = 20;
            bringupState = new BringupState("idle");
            OnUpdateEvent = new List<FrameworkComponentUpdateCallback>();
        }


    }
}
