package com.metratech.sdk.utils;

import com.metratech.sdk.base.MTMeter;
import java.io.*;

public class MTLogger extends PrintStream
{
  public MTLogger (int logLevel, OutputStream oStream)
  {
    super (oStream);
    mLogLevel = logLevel;
  }
  
  public void println (int logLevel, String msg)
  {
    if (logLevel >= mLogLevel)
      println (msg);
  }
  
  private int mLogLevel;
}
