using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using log4net;

namespace BaselineGUI
{
    public class Statistic
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(Statistic));

        public string Name;

        public double myMin;
        public double myMax;
        public double total;
        public double average;
        public double numSamples;
        public double confidence;
        public long errCnt;

        public int[] bins;
        public int maxBins = 20000;

        public event EventHandler<EventData> OnModelChangeEvent;

        public Statistic(string name = "")
        {
            Name = name;
            myMin = 0.0;
            myMax = 0.0;
            average = 0.0;
            total = 0.0;
            numSamples = 0.0;
            errCnt = 0L;

            bins = new int[maxBins];
        }

        public void reset()
        {
            lock (this)
            {
                myMin = 0.0;
                myMax = 0.0;
                average = 0.0;
                total = 0.0;
                numSamples = 0.0;
                confidence = (double) maxBins;
                errCnt = 0L;

                bins = new int[maxBins];
            }

            RaiseModelChange();
        }

        public void addSample(double v)
        {
            addSample(v, "");
        }

        public void addSample(double v, string message)
        {
            lock (this)
            {
                int binNum = (int)v;
                if (binNum >= maxBins)
                    binNum = maxBins-1;

                bins[binNum]++;

                log.DebugFormat("Adding sample {0} to {1}: {2}", v, Name, message);
                if (numSamples == 0.0)
                {
                    myMin = v;
                    myMax = v;
                }
                else
                {
                    myMin = Math.Min(myMin, v);
                    myMax = Math.Max(myMax, v);
                }

                total += v;
                numSamples += 1.0;
                average = total / numSamples;

                double cnt = 0.0;

                int startBin = (int)myMax;
                if (startBin >= maxBins)
                    startBin = maxBins - 1;

                int stopBin = (int)myMin;
                if (stopBin >= maxBins)
                    stopBin = maxBins - 1;

                for (confidence = startBin; confidence >= stopBin; confidence -= 1.0)
                {
                    cnt += bins[(int)confidence];
                    if ((cnt / numSamples) > 0.10)
                        break;
                }
            }

            RaiseModelChange();
        }

        public void addErr()
        {
            lock (this)
            {
                errCnt++;
            }
            RaiseModelChange();
        }

        private void RaiseModelChange()
        {
            if (this is Statistic)
            {
                EventHandler<EventData> handler = OnModelChangeEvent;
                EventData d = new EventData();
                d.sender = this;
                handler(this, d);
            }
        }


        public class EventData : EventArgs
        {
            public Statistic sender;
        }


    }
}
