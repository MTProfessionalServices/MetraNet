package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IMTSession'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTSession Interface</B>'
 *
 * Generator Options:
 * PromptForTypeLibraries = True
 * AttemptNonDual = True
 * ClashPrefix = zz_
 * LowerCaseMemberNames = True
 * IDispatchOnly = False
 * RetryOnReject = True
 * GenerateDeprecatedConstructors = True
 * ArraysAsObjects = False
 * DontGenerateDisp = False
 * DontRenameSameMethods = False
 * IgnoreConflictingInterfaces = True
 */
public class IMTSessionProxy extends com.linar.jintegra.Dispatch implements IMTSession, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IMTSession.class;

  public IMTSessionProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTSession.IID, host, authInfo);
  }

  /** For internal use only */
  public IMTSessionProxy() {}

  public IMTSessionProxy(Object obj) throws java.io.IOException {
    super(obj, IMTSession.IID);
  }

  protected IMTSessionProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IMTSessionProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTSession.IID, host, null);
  }

  protected IMTSessionProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
    super(CLSID, iid, host, authInfo);
  }

  public void addListener(String iidStr, Object theListener, Object theSource) throws java.io.IOException {
    super.addListener(iidStr, theListener, theSource);
  }

  public void removeListener(String iidStr, Object theListener) throws java.io.IOException {
    super.removeListener(iidStr, theListener);
  }

  /**
   * getPropertyByName. Get the value of a property dynamically at run-time, based on its name
   *
   * @return    return value.  The value of the property.
   * @param     name. The name of the property to get.
   * @exception java.lang.NoSuchFieldException If the property does not exit.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getPropertyByName(String name) throws NoSuchFieldException, java.io.IOException, com.linar.jintegra.AutomationException {
    com.linar.jintegra.Variant parameters[] = {};
    return super.invoke(name, super.getDispatchIdOfName(name), 2, parameters).getVARIANT();
  }

  /**
   * getPropertyByName. Get the value of a property dynamically at run-time, based on its name and a parameter value
   *
   * @return    return value.  The value of the property.
   * @param     name. The name of the property to get.
   * @param     rhs. Parameter used when getting the property.
   * @exception java.lang.NoSuchFieldException If the property does not exit.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getPropertyByName(String name, Object rhs) throws NoSuchFieldException, java.io.IOException, com.linar.jintegra.AutomationException {
    com.linar.jintegra.Variant parameters[] = {rhs == null ? new Variant("rhs", 10, 0x80020004L) : new Variant("rhs", 12, rhs)};
    return super.invoke(name, super.getDispatchIdOfName(name), 2, parameters).getVARIANT();
  }

  /**
   * invokeMethodByName. Invoke a method dynamically at run-time
   *
   * @return    return value.  The value returned by the method (null if none).
   * @param     name. The name of the method to be invoked
   * @param     parameters.  One element for each parameter.  Use primitive type wrappers
   *            to pass primitive types (eg Integer to pass an int).
   * @exception java.lang.NoSuchMethodException If the method does not exit.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object invokeMethodByName(String name, Object[] parameters) throws NoSuchMethodException, java.io.IOException, com.linar.jintegra.AutomationException {
    com.linar.jintegra.Variant variantParameters[] = new com.linar.jintegra.Variant[parameters.length];
    for(int i = 0; i < parameters.length; i++) {
      variantParameters[i] = parameters[i] == null ? new Variant("p" + i, 10, 0x80020004L) :
	                                                   new Variant("p" + i, 12, parameters[i]);
    }
    try {
      return super.invoke(name, super.getDispatchIdOfName(name), 1, variantParameters).getVARIANT();
    } catch(NoSuchFieldException nsfe) {
      throw new NoSuchMethodException("There is no method called " + name);
    }
  }

  /**
   * setLongProperty. method SetLongProperty
   *
   * @param     propid The propid (in)
   * @param     propval The propval (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setLongProperty  (
              int propid,
              int propval) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(propid), new Integer(propval), zz_retVal };
        vtblInvoke("setLongProperty", 7, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getLongProperty. method GetLongProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The propval
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getLongProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { new Integer(propid), zz_retVal };
        vtblInvoke("getLongProperty", 8, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setBSTRProperty. method SetBSTRProperty
   *
   * @param     aPropId The aPropId (in)
   * @param     aValue The aValue (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setBSTRProperty  (
              int aPropId,
              String aValue) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(aPropId), aValue, zz_retVal };
        vtblInvoke("setBSTRProperty", 9, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getBSTRProperty. method GetBSTRProperty
   *
   * @param     aPropId The aPropId (in)
   * @return    return value.  The apValue
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getBSTRProperty  (
              int aPropId) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(aPropId), zz_retVal };
        vtblInvoke("getBSTRProperty", 10, zz_parameters);
        return (String)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setStringProperty. method SetStringProperty
   *
   * @param     aPropId The aPropId (in)
   * @param     aValue The aValue (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setStringProperty  (
              int aPropId,
              String aValue) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(aPropId), aValue, zz_retVal };
        vtblInvoke("setStringProperty", 11, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getStringProperty. method GetStringProperty
   *
   * @param     aPropId The aPropId (in)
   * @return    return value.  The apValue
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getStringProperty  (
              int aPropId) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(aPropId), zz_retVal };
        vtblInvoke("getStringProperty", 12, zz_parameters);
        return (String)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setBoolProperty. method SetBoolProperty
   *
   * @param     aPropId The aPropId (in)
   * @param     aVal The aVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setBoolProperty  (
              int aPropId,
              boolean aVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(aPropId), new Boolean(aVal), zz_retVal };
        vtblInvoke("setBoolProperty", 13, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getBoolProperty. method GetBoolProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The apValue
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean getBoolProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        boolean zz_retVal[] = { false };
        Object zz_parameters[] = { new Integer(propid), zz_retVal };
        vtblInvoke("getBoolProperty", 14, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setDoubleProperty. method SetDoubleProperty
   *
   * @param     aPropId The aPropId (in)
   * @param     aValue The aValue (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDoubleProperty  (
              int aPropId,
              double aValue) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(aPropId), new Double(aValue), zz_retVal };
        vtblInvoke("setDoubleProperty", 15, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getDoubleProperty. method GetDoubleProperty
   *
   * @param     aPropId The aPropId (in)
   * @return    return value.  The apValue
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public double getDoubleProperty  (
              int aPropId) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        double zz_retVal[] = { 0.0 };
        Object zz_parameters[] = { new Integer(aPropId), zz_retVal };
        vtblInvoke("getDoubleProperty", 16, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setOLEDateProperty. method SetOLEDateProperty
   *
   * @param     propid The propid (in)
   * @param     propval The propval (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setOLEDateProperty  (
              int propid,
              java.util.Date propval) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(propid), propval, zz_retVal };
        vtblInvoke("setOLEDateProperty", 17, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getOLEDateProperty. method GetOLEDateProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The propval
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public java.util.Date getOLEDateProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        java.util.Date zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(propid), zz_retVal };
        vtblInvoke("getOLEDateProperty", 18, zz_parameters);
        return (java.util.Date)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setTimeProperty. method SetTimeProperty
   *
   * @param     propid The propid (in)
   * @param     propval The propval (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setTimeProperty  (
              int propid,
              int propval) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(propid), new Integer(propval), zz_retVal };
        vtblInvoke("setTimeProperty", 19, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getTimeProperty. method GetTimeProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The propval
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getTimeProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { new Integer(propid), zz_retVal };
        vtblInvoke("getTimeProperty", 20, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setDateTimeProperty. method SetDateTimeProperty
   *
   * @param     propid The propid (in)
   * @param     propval The propval (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDateTimeProperty  (
              int propid,
              int propval) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(propid), new Integer(propval), zz_retVal };
        vtblInvoke("setDateTimeProperty", 21, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getDateTimeProperty. method GetDateTimeProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The propval
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getDateTimeProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { new Integer(propid), zz_retVal };
        vtblInvoke("getDateTimeProperty", 22, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * get_NewEnum. property _NewEnum
   *
   * @return    return value.  An enumeration.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public java.util.Enumeration get_NewEnum  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        java.util.Enumeration zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("get_NewEnum", 23, zz_parameters);
        return (java.util.Enumeration)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getSessionID. property SessionID
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getSessionID  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getSessionID", 24, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * addSessionChildren. method AddSessionChildren
   *
   * @param     apSet An reference to a IMTSessionSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addSessionChildren  (
              IMTSessionSet apSet) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { apSet, zz_retVal };
        vtblInvoke("addSessionChildren", 25, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * sessionChildren. method SessionChildren
   *
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet sessionChildren  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSessionSet zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("sessionChildren", 26, zz_parameters);
        return (IMTSessionSet)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getServiceID. property ServiceID
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getServiceID  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getServiceID", 27, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getParentID. property ParentID
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getParentID  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getParentID", 28, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getDatabaseID. property DatabaseID
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getDatabaseID  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getDatabaseID", 29, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setDatabaseID. property DatabaseID
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDatabaseID  (
              int pVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(pVal), zz_retVal };
        vtblInvoke("setDatabaseID", 30, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * increaseSharedRefCount. method IncreaseSharedRefCount
   *
   * @return    return value.  The apNewCount
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int increaseSharedRefCount  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("increaseSharedRefCount", 31, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * decreaseSharedRefCount. method DecreaseSharedRefCount
   *
   * @return    return value.  The apNewCount
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int decreaseSharedRefCount  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("decreaseSharedRefCount", 32, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * deleteForcefully. method DeleteForcefully
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void deleteForcefully  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("deleteForcefully", 33, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * markComplete. method MarkComplete
   *
   * @return    return value.  The apParentReady
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean markComplete  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        boolean zz_retVal[] = { false };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("markComplete", 34, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * markCompoundAsFailed. method MarkCompoundAsFailed
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void markCompoundAsFailed  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("markCompoundAsFailed", 35, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getOutstandingChildren. property OutstandingChildren
   *
   * @return    return value.  The children
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getOutstandingChildren  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getOutstandingChildren", 36, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * rollback. method Rollback
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void rollback  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("rollback", 37, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setStartStage. property StartStage
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setStartStage  (
              int pVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(pVal), zz_retVal };
        vtblInvoke("setStartStage", 38, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getStartStage. property StartStage
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getStartStage  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getStartStage", 39, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setInTransitTo. method InTransitTo
   *
   * @param     rhs1 The rhs1 (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setInTransitTo  (
              int rhs1) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(rhs1), zz_retVal };
        vtblInvoke("setInTransitTo", 40, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setInProcessBy. method InProcessBy
   *
   * @param     rhs1 The rhs1 (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setInProcessBy  (
              int rhs1) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(rhs1), zz_retVal };
        vtblInvoke("setInProcessBy", 41, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getUID. property UID
   *
   * @param     uID An unsigned byte (out: use single element array)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void getUID  (
              byte[][] uID) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { uID, zz_retVal };
        vtblInvoke("getUID", 42, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getUIDAsString. property UIDAsString
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getUIDAsString  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getUIDAsString", 43, zz_parameters);
        return (String)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * addSessionDescendants. method AddSessionDescendants
   *
   * @param     apSet An reference to a IMTSessionSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addSessionDescendants  (
              IMTSessionSet apSet) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { apSet, zz_retVal };
        vtblInvoke("addSessionDescendants", 44, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * IsParent. property IsParent
   *
   * @return    return value.  The isParent
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean IsParent  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        boolean zz_retVal[] = { false };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("IsParent", 45, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * isCompoundMarkedAsFailed. property CompoundMarkedAsFailed
   *
   * @return    return value.  The failed
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean isCompoundMarkedAsFailed  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        boolean zz_retVal[] = { false };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("isCompoundMarkedAsFailed", 46, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * addEvents. method AddEvents
   *
   * @param     events The events (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addEvents  (
              int events) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(events), zz_retVal };
        vtblInvoke("addEvents", 47, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getEvents. method Events
   *
   * @return    return value.  The events
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getEvents  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getEvents", 48, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * beginTransaction. method BeginTransaction
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void beginTransaction  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("beginTransaction", 49, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * joinDistributedTransaction. method Join Distributed Transaction
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void joinDistributedTransaction  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("joinDistributedTransaction", 50, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * commitTransaction. method Commit Transaction
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void commitTransaction  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("commitTransaction", 51, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * rollbackTransaction. method Rollback Transaction
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void rollbackTransaction  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("rollbackTransaction", 52, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /** Dummy reference from interface to proxy to make sure proxy gets compiled */
  static final int xxDummy = 0;

  static {
    com.linar.jintegra.InterfaceDesc.add("c8757973-20e5-11d2-a1c1-006008c0e24a", IMTSessionProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("setLongProperty",
            new Class[] { Integer.TYPE, Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("propid", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("propval", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getLongProperty",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("propid", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("propval", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setBSTRProperty",
            new Class[] { Integer.TYPE, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aPropId", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("aValue", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getBSTRProperty",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aPropId", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("apValue", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setStringProperty",
            new Class[] { Integer.TYPE, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aPropId", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("aValue", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getStringProperty",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aPropId", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("apValue", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setBoolProperty",
            new Class[] { Integer.TYPE, Boolean.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aPropId", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("aVal", 11, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getBoolProperty",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("propid", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("apValue", 11, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setDoubleProperty",
            new Class[] { Integer.TYPE, Double.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aPropId", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("aValue", 5, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getDoubleProperty",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aPropId", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("apValue", 5, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setOLEDateProperty",
            new Class[] { Integer.TYPE, java.util.Date.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("propid", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("propval", 7, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getOLEDateProperty",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("propid", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("propval", 7, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setTimeProperty",
            new Class[] { Integer.TYPE, Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("propid", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("propval", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getTimeProperty",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("propid", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("propval", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setDateTimeProperty",
            new Class[] { Integer.TYPE, Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("propid", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("propval", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getDateTimeProperty",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("propid", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("propval", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("get_NewEnum",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 13, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getSessionID",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("addSessionChildren",
            new Class[] { IMTSessionSet.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apSet", 29, 2, 4, IMTSessionSet.IID, IMTSessionSetProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("sessionChildren",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTSessionSet.IID, IMTSessionSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("getServiceID",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getParentID",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getDatabaseID",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setDatabaseID",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("increaseSharedRefCount",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apNewCount", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("decreaseSharedRefCount",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apNewCount", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("deleteForcefully",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("markComplete",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apParentReady", 11, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("markCompoundAsFailed",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getOutstandingChildren",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("children", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("rollback",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setStartStage",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getStartStage",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setInTransitTo",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("rhs1", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setInProcessBy",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("rhs1", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getUID",
            new Class[] { byte[][].class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("uID", 17, 5, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getUIDAsString",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("addSessionDescendants",
            new Class[] { IMTSessionSet.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apSet", 29, 2, 4, IMTSessionSet.IID, IMTSessionSetProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("IsParent",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("isParent", 11, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("isCompoundMarkedAsFailed",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("failed", 11, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("addEvents",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("events", 22, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getEvents",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("events", 22, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("beginTransaction",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("joinDistributedTransaction",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("commitTransaction",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("rollbackTransaction",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
});  }
}
