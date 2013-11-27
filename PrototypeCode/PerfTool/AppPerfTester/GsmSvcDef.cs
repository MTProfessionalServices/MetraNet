using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.GSM.Metratech_com_GSM;
using MetraTech.DomainModel.Enums.GSM.Metratech_com_GSMReference;
using System;
using System.Reflection;
using System.IO;
using DataGenerators;

namespace BaselineGUI
{


    public class GsmSvcDef : SvcDefGSMBase
    {

        public void doit()
        {
            StreamWriter writer = new StreamWriter(@"c:\temp\ctl00XX.metergsm.voice.txt"); 
            for (int ix = 0; ix < 5000; ix++)
            {
                init();

                CalledNumber = "+450001112233";
                DialedDigits = CalledNumber;

                CallEventStartTimestamp = DateTime.Now;
                TotalCallEventDuration = 7;

                // Get a service account
                FCNetMeter netMeter = Framework.netMeter;
                IMSI = netMeter.pickImsi();
                //IMSI = "USATT2915373100";
                MSISDN = IMSI;
                //Console.WriteLine("IMSI is {0}", IMSI);


                print(writer);
            }
            writer.Close();
        }



    }
}
