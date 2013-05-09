using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NetMeterObj
{
    /// <summary>
    /// We use the id_acc_ext 16-byte field (table t_account) as place to keep extra PerfTool account flags
    /// </summary>
    public class PerfAccountFlags
    {
        public bool isModifiable;

        public PerfAccountFlags()
        {
            setToDefaults();
        }

        public void setToDefaults()
        {
            isModifiable = false;
        }


        public void unpack(Byte[] bytes)
        {
            isModifiable = (bytes[0] & 0x1) != 0;
        }

        public Byte[] pack()
        {
            Byte[] bytes = new Byte[16];

            int b = 0;
            if (isModifiable)
                b = b | 0x1;

            bytes[0] = (byte)b;
            return bytes;
        }

 
    }
}
