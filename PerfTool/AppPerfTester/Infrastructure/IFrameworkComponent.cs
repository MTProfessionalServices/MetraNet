using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{

    public delegate void FrameworkComponentUpdateCallback(IFrameworkComponent comp);

    public interface IFrameworkComponent
    {
        string name { get; }
        string fullName { get; }
        MsgLogger msgLogger { set; get; }
        int priority { set; get; }

        BringupState bringupState { set; get; }

        List<FrameworkComponentUpdateCallback> OnUpdateEvent { set; get; }

        void Bringup();
        void Teardown();
    }
}
