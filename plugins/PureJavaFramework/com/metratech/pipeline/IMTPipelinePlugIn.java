package com.metratech.pipeline;

/**
 * COM Interface 'IMTPipelinePlugIn'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTPipelinePlugIn Interface</B>'
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
public interface IMTPipelinePlugIn {
  /**
   * configure. Configure processor
   *
   * @param     systemContext A reference to another Object (IUnknown) (in)
   * @param     propSet An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void configure  (
              Object systemContext,
              IMTConfigPropSet propSet) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * shutdown. Shutdown processor
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void shutdown  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getProcessorInfo. Return information about this processor
   *
   * @return    return value.  The info
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getProcessorInfo  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * processSessions. Process a set of sessions
   *
   * @param     sessions An reference to a IMTSessionSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void processSessions  (
              IMTSessionSet sessions) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID94001850_3170_11d2_a1c2_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTPipelinePlugInProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "94001850-3170-11d2-a1c2-006008c0e24a";
  String DISPID_1_NAME = "configure";
  String DISPID_2_NAME = "shutdown";
  String DISPID_3_GET_NAME = "getProcessorInfo";
  String DISPID_4_NAME = "processSessions";
}
