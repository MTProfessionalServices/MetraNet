using System;
using System.Collections;
using System.Xml;
using System.Diagnostics;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.AR;
using MetraTech.Interop.MTARInterfaceExec;
using MetraTech.Interop.MTYAAC;

namespace MetraTech.AR.Adapters
{

  /// <summary>
  /// consolidates state changes that occurred in MetraNet and AR.
  /// helper class for AccountStateAdapter
  /// INPUT:  occurred state changes
  /// OUTPUT: state changes to appply
	/// </summary>
  public class StateChangeConsolidator
  {
    //DATA
    private Hashtable mStateChangesForMetraNet = new Hashtable();
    private Hashtable mStateChangesForAR = new Hashtable();
    private Logger mLogger;
    private IMTAccountCatalog mAccountCatalog;
    private string mAccountNameSpace;
    private DateTime mCurrentTime;
    private IRecurringEventRunContext mRecurringEventRunContext;

    public StateChangeConsolidator(
      string accountNameSpace,
      IMTAccountCatalog accountCatalog,
      Logger logger,
      DateTime currentTime,
      IRecurringEventRunContext context)
    {
      mAccountNameSpace = accountNameSpace;
      mAccountCatalog = accountCatalog;
      mLogger = logger;
      mCurrentTime = currentTime;
      mRecurringEventRunContext = context;
    }

    public void AddStateChangeForAR(string extAccountID, string state, DateTime timeChanged)
    {
      StateChange stateChange = new StateChange(extAccountID, state, timeChanged);

      string extAccountIDUpper = extAccountID.ToUpper();

      if (mStateChangesForAR.ContainsKey(extAccountIDUpper))
      {
        //if there already is an entry use the one with the later time
        StateChange previousStateChange = (StateChange)mStateChangesForAR[extAccountIDUpper];
        if( previousStateChange.mTimeChanged >= stateChange.mTimeChanged)
        {
          mLogger.LogDebug("Ignored less recent change for AR. {0}", stateChange);
        }
        else
        {
          // replace the existing change
          mStateChangesForAR[extAccountIDUpper] = stateChange;
          mLogger.LogDebug("Modified change for AR. {0}", stateChange);
        }
      }
      else 
      {
        //add new change
        mStateChangesForAR[extAccountIDUpper] = stateChange;
        mLogger.LogDebug("Added change for AR. {0}", stateChange);
      }
    }

    enum ChangeType {NO_CHANGE, CHANGE_FOR_MN, CHANGE_FOR_AR};

    /// <summary>
    /// Add a AR state change and consolidate it with any other MetraNet or AR changes
    /// CONSOLIDATION PRINCIPLE: most recent change is the one to apply (if same time MetraNet wins)
    /// ALGORITHM:
    ///   See if there is a change already marked for this account.
    ///   There are three cases:
    ///   (1) no change marked yet
    ///   (2) change to MN marked (there was another AR change already added)
    ///   (3) change to AR marked (there was a MN change during the same interval)
    ///
    ///   case (1)
    ///     add change to MN, if AR state different from current MN state
    ///
    ///   case (2)
    ///     if this AR change more recent than the other AR change
    ///       compare AR state to current MN state
    ///       if states are different
    ///         replace AR change to MN with this AR change
    ///       else (state is same)
    ///         remove previous AR change to MN
    ///
    ///   case (3)
    ///     if this AR change more recent than the MN change
    ///       remove MN change to AR
    ///       add change to MN, if AR state different from current MN state
    /// </summary>
    public void AddAndConsolidateStateChangeForMetraNet(string extAccountID, string state, DateTime timeChanged, string changedBy )
    { 
      StateChange stateChange = new StateChange(extAccountID, state, timeChanged, changedBy);

      string extAccountIDUpper = extAccountID.ToUpper();

      //step 1: See if there is a change already marked for this account.
      ChangeType existingChange = ChangeType.NO_CHANGE;

      if (mStateChangesForAR.ContainsKey(extAccountIDUpper))
      { existingChange = ChangeType.CHANGE_FOR_AR;
    
        //account should only be in one map
        Debug.Assert( !mStateChangesForMetraNet.ContainsKey(extAccountIDUpper));
      }
      else if (mStateChangesForMetraNet.ContainsKey(extAccountIDUpper))
      { existingChange = ChangeType.CHANGE_FOR_MN;
      }

      //step 2: act based on existingChange;
      switch(existingChange)
      {
        case ChangeType.NO_CHANGE:
          //add change to MN, if AR state different from current MN state
          ConsolidateWithCurrentMetraNet(stateChange);
          break;
    
        case ChangeType.CHANGE_FOR_MN:
          //if this AR change is more recent than the previous AR change
          StateChange previousStateChange = (StateChange)mStateChangesForMetraNet[extAccountIDUpper];
          if (stateChange.mTimeChanged >= previousStateChange.mTimeChanged)
          {
            mLogger.LogDebug( "Removed previous change for MetraNet (new change is more recent). {0}", previousStateChange);
            mStateChangesForMetraNet.Remove(extAccountIDUpper);
            
            // use this AR state, add it if state is different from MN state
            ConsolidateWithCurrentMetraNet(stateChange);
          }
          else
          {
            mLogger.LogDebug( "Ignored less recent change for MetraNet. {0}", stateChange);
          }
          break;
    
        case ChangeType.CHANGE_FOR_AR:
         // if this AR change more recent than the MN change
          StateChange MNStateChange = (StateChange)mStateChangesForAR[extAccountIDUpper];
          if (stateChange.mTimeChanged > MNStateChange.mTimeChanged)
          {
            // remove MN change to AR
            mLogger.LogDebug( "Removed change for AR (change for MetraNet more recent) {0}", MNStateChange);
            mStateChangesForAR.Remove(extAccountIDUpper);

            // add change to MN, if AR state different from current MN state
            ConsolidateWithCurrentMetraNet(stateChange);
          }
          break;
      }
    }

    enum ConsolidationCase {MN_ALREADY_IN_AR_STATE, MN_CAN_TRANSITION_TO_AR_STATE, MN_CANNOT_TRANSITION_TO_AR_STATE};

    /// <summary>
    /// compares passed in AR state change to current MN state
    /// if same: do nothing
    /// if MN can transition to AR state: change state
    /// if MN cannot transition to AR state: leave MN in state, force AR to MN state (and log warning)
    /// </summary>
    public void ConsolidateWithCurrentMetraNet(StateChange stateChange)
    {
      MetraTech.Interop.MTYAAC.IMTYAAC account;
      account = mAccountCatalog.GetAccountByName(stateChange.mExtAccountID, mAccountNameSpace, mCurrentTime);

      //step: look up state
      string MNState = account.GetAccountStateMgr().GetStateObject().Name;
      string ARState = stateChange.mState;

      // step: determine consolidation case
      // MN_ALREADY_IN_AR_STATE: nothing to do
      // MN_CAN_TRANSITION_TO_AR_STATE: change state
      // MN_CANNOT_TRANSITION_TO_AR_STATE: leave MN in state, force AR to MN state
      ConsolidationCase consCase;

      if (ARState == "SU")
      {
        switch(MNState)
        {
          case "AC":
            consCase = ConsolidationCase.MN_CAN_TRANSITION_TO_AR_STATE;
            break;
          case "SU":
            consCase = ConsolidationCase.MN_ALREADY_IN_AR_STATE;
            break;
          default: //PA, PF, CL, AR
            consCase = ConsolidationCase.MN_CANNOT_TRANSITION_TO_AR_STATE;
            break;
        }
      }
      else if (ARState == "US")
      {
        switch(MNState)
        {
          case "SU":
            consCase = ConsolidationCase.MN_CAN_TRANSITION_TO_AR_STATE;
            break;
          default: //AC, PA, PF, CL, AR
            consCase = ConsolidationCase.MN_ALREADY_IN_AR_STATE;
            break;
        }
      }      
      else
        throw new ARException("unsupported AR State: {0}", ARState);
 
      // step: act on consolidation case
      switch(consCase)
      {
        case ConsolidationCase.MN_ALREADY_IN_AR_STATE: //nothing to do
          mLogger.LogDebug( "MetraNet already in AR state. Ignoring AR state change: {0}", stateChange);
          break;

        case ConsolidationCase.MN_CAN_TRANSITION_TO_AR_STATE: //change state
          string extAccountIDUpper = stateChange.mExtAccountID.ToUpper();
          
          //caller should have made sure that account does not exist in mStateChangesForMetraNet
          Debug.Assert(!mStateChangesForMetraNet.ContainsKey(extAccountIDUpper)); 

          mStateChangesForMetraNet[extAccountIDUpper] = stateChange;
          mLogger.LogDebug( "Added change for MetraNet. {0}", stateChange);
          break;

        case ConsolidationCase.MN_CANNOT_TRANSITION_TO_AR_STATE: //leave MN in state, force AR to MN state
          //log warning
          string msg;
          msg = String.Format("State of account '{0}' cannot be changed to AR state {1} since MetraNet state is {2}. Changing AR state to {2}.",
            stateChange.mExtAccountID, ARState, MNState);
          mRecurringEventRunContext.RecordWarning(msg);
          mLogger.LogDebug(msg);

          AddStateChangeForAR(stateChange.mExtAccountID, MNState, mCurrentTime);
          break;

        default:
          throw new ARException("Invalid ConsolidationCase");
      }
    }

    public IDictionaryEnumerator GetStateChangesForMetraNet()
    {
      return mStateChangesForMetraNet.GetEnumerator();
    }

    public IDictionaryEnumerator GetStateChangesForAR()
    {
      return mStateChangesForAR.GetEnumerator();
    }
  }

  /// <summary>
  /// identifies one state change to perform
  /// helper for the StateChangeConsolidator
  /// </summary>
  public class StateChange
  {
    // DATA
    public string mExtAccountID;
    public string mState;
    public DateTime mTimeChanged;
    public string mChangedBy;

    // METHODS
    public StateChange(string extAccountID, string state, DateTime timeChanged)
      : this(extAccountID, state, timeChanged, "")
    {
    }
    
    public StateChange(string extAccountID, string state, DateTime timeChanged, string changedBy)
    {
      mExtAccountID = extAccountID;
      mState = state;
      mTimeChanged = timeChanged;
      mChangedBy = changedBy;
    }

    override public string ToString()
    {
      return String.Format("acc: {0}, state: {1}, changed: {2}, by: {3}",
        mExtAccountID, mState, mTimeChanged, mChangedBy);
    } 
  }

}
