package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IMTConfigPropSet'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfigPropSet Interface</B>'
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
public class IMTConfigPropSetProxy extends com.linar.jintegra.Dispatch implements IMTConfigPropSet, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IMTConfigPropSet.class;

  public IMTConfigPropSetProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTConfigPropSet.IID, host, authInfo);
  }

  /** For internal use only */
  public IMTConfigPropSetProxy() {}

  public IMTConfigPropSetProxy(Object obj) throws java.io.IOException {
    super(obj, IMTConfigPropSet.IID);
  }

  protected IMTConfigPropSetProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IMTConfigPropSetProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTConfigPropSet.IID, host, null);
  }

  protected IMTConfigPropSetProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
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
   * next. method Next
   *
   * @return    return value.  An reference to a IMTConfigProp
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigProp next  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigProp zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("next", 7, zz_parameters);
        return (IMTConfigProp)zz_retVal[0];
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
   * previous. method Previous
   *
   * @return    return value.  An reference to a IMTConfigProp
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigProp previous  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigProp zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("previous", 8, zz_parameters);
        return (IMTConfigProp)zz_retVal[0];
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
   * reset. method Reset
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void reset  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("reset", 9, zz_parameters);
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
   * nextWithName. method NextWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  An reference to a IMTConfigProp
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigProp nextWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigProp zz_retVal[] = { null };
        Object zz_parameters[] = { aName, zz_retVal };
        vtblInvoke("nextWithName", 10, zz_parameters);
        return (IMTConfigProp)zz_retVal[0];
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
   * nextLongWithName. method NextLongWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int nextLongWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { aName, zz_retVal };
        vtblInvoke("nextLongWithName", 11, zz_parameters);
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
   * nextStringWithName. method NextStringWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String nextStringWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { aName, zz_retVal };
        vtblInvoke("nextStringWithName", 12, zz_parameters);
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
   * nextBoolWithName. method NextBoolWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean nextBoolWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        boolean zz_retVal[] = { false };
        Object zz_parameters[] = { aName, zz_retVal };
        vtblInvoke("nextBoolWithName", 13, zz_parameters);
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
   * nextVariantWithName. method NextVariantWithName
   *
   * @param     aName The aName (in)
   * @param     apType A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0256_0001 constant (A  COM typedef)  (out: use single element array)
   * @return    return value.  A Variant
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object nextVariantWithName  (
              String aName,
              int[] apType) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { aName, apType, zz_retVal };
        vtblInvoke("nextVariantWithName", 14, zz_parameters);
        return (Object)zz_retVal[0];
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
   * nextDoubleWithName. method NextDoubleWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public double nextDoubleWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        double zz_retVal[] = { 0.0 };
        Object zz_parameters[] = { aName, zz_retVal };
        vtblInvoke("nextDoubleWithName", 15, zz_parameters);
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
   * nextSetWithName. method NextSetWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet nextSetWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { aName, zz_retVal };
        vtblInvoke("nextSetWithName", 16, zz_parameters);
        return (IMTConfigPropSet)zz_retVal[0];
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
   * insertSet. method InsertSet
   *
   * @param     aName The aName (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet insertSet  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { aName, zz_retVal };
        vtblInvoke("insertSet", 17, zz_parameters);
        return (IMTConfigPropSet)zz_retVal[0];
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
   * insertProp. method InsertProp
   *
   * @param     aName The aName (in)
   * @param     aType A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0256_0001 constant (A  COM typedef)  (in)
   * @param     aVal A Variant (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void insertProp  (
              String aName,
              int aType,
              Object aVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { aName, new Integer(aType), aVal, zz_retVal };
        vtblInvoke("insertProp", 18, zz_parameters);
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
   * addSubSet. method AddSubSet
   *
   * @param     apNewSet An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addSubSet  (
              IMTConfigPropSet apNewSet) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { apNewSet, zz_retVal };
        vtblInvoke("addSubSet", 19, zz_parameters);
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
   * write. method Write
   *
   * @param     aFilename The aFilename (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void write  (
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { aFilename, zz_retVal };
        vtblInvoke("write", 20, zz_parameters);
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
   * writeWithChecksum. method WriteWithChecksum
   *
   * @param     aFilename The aFilename (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeWithChecksum  (
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { aFilename, zz_retVal };
        vtblInvoke("writeWithChecksum", 21, zz_parameters);
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
   * writeToHost. method WriteToHost
   *
   * @param     aHostName The aHostName (in)
   * @param     aRelativePath The aRelativePath (in)
   * @param     aUsername The aUsername (in)
   * @param     aPassword The aPassword (in)
   * @param     aSecure The aSecure (in)
   * @param     aChecksum The aChecksum (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeToHost  (
              String aHostName,
              String aRelativePath,
              String aUsername,
              String aPassword,
              boolean aSecure,
              boolean aChecksum) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { aHostName, aRelativePath, aUsername, aPassword, new Boolean(aSecure), new Boolean(aChecksum), zz_retVal };
        vtblInvoke("writeToHost", 22, zz_parameters);
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
   * nextMatches. method NextMatches
   *
   * @param     aPropName The aPropName (in)
   * @param     aType A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0256_0001 constant (A  COM typedef)  (in)
   * @return    return value.  The apMatch
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean nextMatches  (
              String aPropName,
              int aType) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        boolean zz_retVal[] = { false };
        Object zz_parameters[] = { aPropName, new Integer(aType), zz_retVal };
        vtblInvoke("nextMatches", 23, zz_parameters);
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
   * writeToBuffer. method WriteToBuffer
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String writeToBuffer  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("writeToBuffer", 24, zz_parameters);
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
   * nextDateWithName. method NextDateWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The pDate
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public java.util.Date nextDateWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        java.util.Date zz_retVal[] = { null };
        Object zz_parameters[] = { aName, zz_retVal };
        vtblInvoke("nextDateWithName", 25, zz_parameters);
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
   * insertConfigProp. method InsertConfigProp
   *
   * @param     pProp An reference to a IMTConfigProp (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void insertConfigProp  (
              IMTConfigProp pProp) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { pProp, zz_retVal };
        vtblInvoke("insertConfigProp", 26, zz_parameters);
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
   * getName. property Name
   *
   * @return    return value.  The bName
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getName  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getName", 27, zz_parameters);
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
   * getAttribSet. property AttribSet
   *
   * @return    return value.  An reference to a IMTConfigAttribSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigAttribSet getAttribSet  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigAttribSet zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getAttribSet", 28, zz_parameters);
        return (IMTConfigAttribSet)zz_retVal[0];
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
   * setAttribSet. property AttribSet
   *
   * @param     ppSet An reference to a IMTConfigAttribSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setAttribSet  (
              IMTConfigAttribSet ppSet) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { ppSet, zz_retVal };
        vtblInvoke("setAttribSet", 29, zz_parameters);
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
   * getDTD. property DTD
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getDTD  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getDTD", 30, zz_parameters);
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
   * setDTD. property DTD
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDTD  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { pVal, zz_retVal };
        vtblInvoke("setDTD", 31, zz_parameters);
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
   * getChecksum. property Checksum
   *
   * @return    return value.  The pChecksum
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getChecksum  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getChecksum", 32, zz_parameters);
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
   * checksumRefresh. method ChecksumRefresh
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void checksumRefresh  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("checksumRefresh", 33, zz_parameters);
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
    com.linar.jintegra.InterfaceDesc.add("9adcd818-35fd-11d2-a1c4-006008c0e24a", IMTConfigPropSetProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("next",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aProp", 29, 20, 4, IMTConfigProp.IID, IMTConfigPropProxy.class) }),
        new com.linar.jintegra.MemberDesc("previous",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apProp", 29, 20, 4, IMTConfigProp.IID, IMTConfigPropProxy.class) }),
        new com.linar.jintegra.MemberDesc("reset",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("nextWithName",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apProp", 29, 20, 4, IMTConfigProp.IID, IMTConfigPropProxy.class) }),
        new com.linar.jintegra.MemberDesc("nextLongWithName",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("nextStringWithName",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apVal", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("nextBoolWithName",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apVal", 11, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("nextVariantWithName",
            new Class[] { String.class, int[].class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apType", 16387, 4, 0, null, null), 
              new com.linar.jintegra.Param("apVal", 12, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("nextDoubleWithName",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apVal", 5, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("nextSetWithName",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("insertSet",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apNewSet", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("insertProp",
            new Class[] { String.class, int.class, Object.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aType", 3, 2, 0, null, null), 
              new com.linar.jintegra.Param("aVal", 12, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("addSubSet",
            new Class[] { IMTConfigPropSet.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apNewSet", 29, 2, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("write",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aFilename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("writeWithChecksum",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aFilename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("writeToHost",
            new Class[] { String.class, String.class, String.class, String.class, Boolean.TYPE, Boolean.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aHostName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aRelativePath", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aUsername", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aPassword", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aSecure", 11, 2, 8, null, null), 
              new com.linar.jintegra.Param("aChecksum", 11, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("nextMatches",
            new Class[] { String.class, int.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aPropName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aType", 3, 2, 0, null, null), 
              new com.linar.jintegra.Param("apMatch", 11, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("writeToBuffer",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("nextDateWithName",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("pDate", 7, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("insertConfigProp",
            new Class[] { IMTConfigProp.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pProp", 29, 2, 4, IMTConfigProp.IID, IMTConfigPropProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getName",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("bName", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getAttribSet",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("ppSet", 29, 20, 4, IMTConfigAttribSet.IID, IMTConfigAttribSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("setAttribSet",
            new Class[] { IMTConfigAttribSet.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("ppSet", 29, 2, 4, IMTConfigAttribSet.IID, IMTConfigAttribSetProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getDTD",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setDTD",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getChecksum",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pChecksum", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("checksumRefresh",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
});  }
}
