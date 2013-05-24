package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IMTSessionServer'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTSessionServer Interface</B>'
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
public class IMTSessionServerProxy extends com.linar.jintegra.Dispatch implements IMTSessionServer, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IMTSessionServer.class;

  public IMTSessionServerProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTSessionServer.IID, host, authInfo);
  }

  /** For internal use only */
  public IMTSessionServerProxy() {}

  public IMTSessionServerProxy(Object obj) throws java.io.IOException {
    super(obj, IMTSessionServer.IID);
  }

  protected IMTSessionServerProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IMTSessionServerProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTSessionServer.IID, host, null);
  }

  protected IMTSessionServerProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
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
   * getSession. method GetSession
   *
   * @param     sessionID The sessionID (in)
   * @return    return value.  An reference to a IMTSession
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSession getSession  (
              int sessionID) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSession zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(sessionID), zz_retVal };
        vtblInvoke("getSession", 7, zz_parameters);
        return (IMTSession)zz_retVal[0];
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
   * createSession. method CreateSession
   *
   * @param     uID An unsigned byte (in)
   * @param     serviceID The serviceID (in)
   * @return    return value.  An reference to a IMTSession
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSession createSession  (
              byte[] uID,
              int serviceID) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSession zz_retVal[] = { null };
        Object zz_parameters[] = { uID, new Integer(serviceID), zz_retVal };
        vtblInvoke("createSession", 8, zz_parameters);
        return (IMTSession)zz_retVal[0];
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
   * createChildSession. method CreateChildSession
   *
   * @param     uID An unsigned byte (in)
   * @param     serviceID The serviceID (in)
   * @param     parentUId An unsigned byte (in)
   * @return    return value.  An reference to a IMTSession
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSession createChildSession  (
              byte[] uID,
              int serviceID,
              byte[] parentUId) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSession zz_retVal[] = { null };
        Object zz_parameters[] = { uID, new Integer(serviceID), parentUId, zz_retVal };
        vtblInvoke("createChildSession", 9, zz_parameters);
        return (IMTSession)zz_retVal[0];
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
   * createTestSession. method CreateTestSession
   *
   * @param     serviceID The serviceID (in)
   * @return    return value.  An reference to a IMTSession
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSession createTestSession  (
              int serviceID) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSession zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(serviceID), zz_retVal };
        vtblInvoke("createTestSession", 10, zz_parameters);
        return (IMTSession)zz_retVal[0];
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
   * createSessionSet. method CreateSessionSet
   *
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet createSessionSet  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSessionSet zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("createSessionSet", 11, zz_parameters);
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
   * getSessionSet. method GetSessionSet
   *
   * @param     setId The setId (in)
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet getSessionSet  (
              int setId) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSessionSet zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(setId), zz_retVal };
        vtblInvoke("getSessionSet", 12, zz_parameters);
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
   * init. method Init
   *
   * @param     filename The filename (in)
   * @param     sharename The sharename (in)
   * @param     totalSize The totalSize (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void init  (
              String filename,
              String sharename,
              int totalSize) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { filename, sharename, new Integer(totalSize), zz_retVal };
        vtblInvoke("init", 13, zz_parameters);
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
   * sessionsInProcessBy. method SessionsInProcessBy
   *
   * @param     aStageID The aStageID (in)
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet sessionsInProcessBy  (
              int aStageID) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSessionSet zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(aStageID), zz_retVal };
        vtblInvoke("sessionsInProcessBy", 14, zz_parameters);
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
   * failedSessions. method FailedSessions
   *
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet failedSessions  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSessionSet zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("failedSessions", 15, zz_parameters);
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
   * getSessionWithUID. method GetSessionWithUID
   *
   * @param     uID An unsigned byte (in)
   * @return    return value.  An reference to a IMTSession
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSession getSessionWithUID  (
              byte[] uID) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSession zz_retVal[] = { null };
        Object zz_parameters[] = { uID, zz_retVal };
        vtblInvoke("getSessionWithUID", 16, zz_parameters);
        return (IMTSession)zz_retVal[0];
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
   * createChildTestSession. method CreateChildTestSession
   *
   * @param     serviceID The serviceID (in)
   * @param     parentID The parentID (in)
   * @return    return value.  An reference to a IMTSession
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSession createChildTestSession  (
              int serviceID,
              int parentID) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTSession zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(serviceID), new Integer(parentID), zz_retVal };
        vtblInvoke("createChildTestSession", 17, zz_parameters);
        return (IMTSession)zz_retVal[0];
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
   * getCurrentCapacity. property CurrentCapacity
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public double getCurrentCapacity  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        double zz_retVal[] = { 0.0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getCurrentCapacity", 18, zz_parameters);
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
   * deleteSessionsInProcessBy. method DeleteSessionsInProcessBy
   *
   * @param     aStageID The aStageID (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void deleteSessionsInProcessBy  (
              int aStageID) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(aStageID), zz_retVal };
        vtblInvoke("deleteSessionsInProcessBy", 19, zz_parameters);
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
    com.linar.jintegra.InterfaceDesc.add("c8757975-20e5-11d2-a1c1-006008c0e24a", IMTSessionServerProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("getSession",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("sessionID", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("session", 29, 20, 4, IMTSession.IID, IMTSessionProxy.class) }),
        new com.linar.jintegra.MemberDesc("createSession",
            new Class[] { byte[].class, Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("uID", 17, 3, 8, null, null), 
              new com.linar.jintegra.Param("serviceID", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("session", 29, 20, 4, IMTSession.IID, IMTSessionProxy.class) }),
        new com.linar.jintegra.MemberDesc("createChildSession",
            new Class[] { byte[].class, Integer.TYPE, byte[].class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("uID", 17, 3, 8, null, null), 
              new com.linar.jintegra.Param("serviceID", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("parentUId", 17, 3, 8, null, null), 
              new com.linar.jintegra.Param("session", 29, 20, 4, IMTSession.IID, IMTSessionProxy.class) }),
        new com.linar.jintegra.MemberDesc("createTestSession",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("serviceID", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("session", 29, 20, 4, IMTSession.IID, IMTSessionProxy.class) }),
        new com.linar.jintegra.MemberDesc("createSessionSet",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTSessionSet.IID, IMTSessionSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("getSessionSet",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("setId", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTSessionSet.IID, IMTSessionSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("init",
            new Class[] { String.class, String.class, Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("filename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("sharename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("totalSize", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("sessionsInProcessBy",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aStageID", 22, 2, 8, null, null), 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTSessionSet.IID, IMTSessionSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("failedSessions",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTSessionSet.IID, IMTSessionSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("getSessionWithUID",
            new Class[] { byte[].class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("uID", 17, 3, 8, null, null), 
              new com.linar.jintegra.Param("session", 29, 20, 4, IMTSession.IID, IMTSessionProxy.class) }),
        new com.linar.jintegra.MemberDesc("createChildTestSession",
            new Class[] { Integer.TYPE, Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("serviceID", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("parentID", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("session", 29, 20, 4, IMTSession.IID, IMTSessionProxy.class) }),
        new com.linar.jintegra.MemberDesc("getCurrentCapacity",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 5, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("deleteSessionsInProcessBy",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aStageID", 22, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
});  }
}
