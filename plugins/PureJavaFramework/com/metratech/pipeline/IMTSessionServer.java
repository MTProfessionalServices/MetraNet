package com.metratech.pipeline;

/**
 * COM Interface 'IMTSessionServer'. Generated 7/24/00 5:03:12 PM
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
public interface IMTSessionServer {
  /**
   * getSession. method GetSession
   *
   * @param     sessionID The sessionID (in)
   * @return    return value.  An reference to a IMTSession
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSession getSession  (
              int sessionID) throws java.io.IOException, com.linar.jintegra.AutomationException;

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
              int serviceID) throws java.io.IOException, com.linar.jintegra.AutomationException;

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
              byte[] parentUId) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * createTestSession. method CreateTestSession
   *
   * @param     serviceID The serviceID (in)
   * @return    return value.  An reference to a IMTSession
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSession createTestSession  (
              int serviceID) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * createSessionSet. method CreateSessionSet
   *
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet createSessionSet  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getSessionSet. method GetSessionSet
   *
   * @param     setId The setId (in)
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet getSessionSet  (
              int setId) throws java.io.IOException, com.linar.jintegra.AutomationException;

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
              int totalSize) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * sessionsInProcessBy. method SessionsInProcessBy
   *
   * @param     aStageID The aStageID (in)
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet sessionsInProcessBy  (
              int aStageID) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * failedSessions. method FailedSessions
   *
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet failedSessions  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getSessionWithUID. method GetSessionWithUID
   *
   * @param     uID An unsigned byte (in)
   * @return    return value.  An reference to a IMTSession
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSession getSessionWithUID  (
              byte[] uID) throws java.io.IOException, com.linar.jintegra.AutomationException;

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
              int parentID) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getCurrentCapacity. property CurrentCapacity
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public double getCurrentCapacity  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * deleteSessionsInProcessBy. method DeleteSessionsInProcessBy
   *
   * @param     aStageID The aStageID (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void deleteSessionsInProcessBy  (
              int aStageID) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IIDc8757975_20e5_11d2_a1c1_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTSessionServerProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "c8757975-20e5-11d2-a1c1-006008c0e24a";
  String DISPID_1_NAME = "getSession";
  String DISPID_2_NAME = "createSession";
  String DISPID_3_NAME = "createChildSession";
  String DISPID_4_NAME = "createTestSession";
  String DISPID_5_NAME = "createSessionSet";
  String DISPID_6_NAME = "getSessionSet";
  String DISPID_7_NAME = "init";
  String DISPID_8_NAME = "sessionsInProcessBy";
  String DISPID_9_NAME = "failedSessions";
  String DISPID_10_NAME = "getSessionWithUID";
  String DISPID_11_NAME = "createChildTestSession";
  String DISPID_12_GET_NAME = "getCurrentCapacity";
  String DISPID_13_NAME = "deleteSessionsInProcessBy";
}
