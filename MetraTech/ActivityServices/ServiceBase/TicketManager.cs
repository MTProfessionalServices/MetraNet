using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using System.Transactions;
using System.Security.Cryptography;
using MetraTech.Security.Crypto;
using System.Runtime.CompilerServices;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.QueryAdapter;

#region Assembly Attribute
[assembly: InternalsVisibleTo("MetraTech.Core.Services, PublicKey=" +
            "00240000048000009400000006020000002400005253413100040000010001009993f9ecb650f0" +
            "bf59efed30ebc31bd85224c1b5905a43f1eb8907b85adea02a4a94e3fd66bb594b04066fa4f836" +
            "e2c09f88bf3ca9ef98ee58cc2a8ece11c804f48306f053932fe4d711c3250b94c769d141bb76a4" +
            "66732466908441d4c27d9d5279758e548b0c038de1f664130e1232c2df09a53c35d1746de7966b" +
            "df27e798")]

[assembly: InternalsVisibleTo("MetraTech.ActivityServices.Runtime, PublicKey=" +
            "00240000048000009400000006020000002400005253413100040000010001009993f9ecb650f0" +
            "bf59efed30ebc31bd85224c1b5905a43f1eb8907b85adea02a4a94e3fd66bb594b04066fa4f836" +
            "e2c09f88bf3ca9ef98ee58cc2a8ece11c804f48306f053932fe4d711c3250b94c769d141bb76a4" +
            "66732466908441d4c27d9d5279758e548b0c038de1f664130e1232c2df09a53c35d1746de7966b" +
            "df27e798")]

#endregion

namespace MetraTech.ActivityServices.Services.Common
{
    public class TicketManager
    {
        #region Private Members
        
        private static Logger mLogger = new Logger("[TicketManager]");
        const string AUTH_QUERY_FOLDER = "Queries\\AuthServices";
        private static RNGCryptoServiceProvider mCryptoProvider;
  
        #endregion

        #region Constructors

        static TicketManager()
        {
            mCryptoProvider = new RNGCryptoServiceProvider();
        }

        private TicketManager() { throw new NotImplementedException(); }
        #endregion

        #region Public Methods

        public static string CreateTicket(int id_acc, string nameSpace, string userName, int ticketLifeSpanMins)
        {
            mLogger.LogDebug("Create Ticket");

            try
            {

                Byte[] salt = new Byte[16];
                mCryptoProvider.GetNonZeroBytes(salt);
                string encSalt = Convert.ToBase64String(salt);
                IdGenerator idGenerator = new IdGenerator("id_ticket");
                int idTicket = idGenerator.NextMashedId;

                string ticket = string.Format("{0};{1}", encSalt, idTicket.ToString());

                CryptoManager cm = new CryptoManager();

                string encTicket = cm.Encrypt(CryptKeyClass.Ticketing, ticket);

                using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AUTH_QUERY_FOLDER))
                    {
                        MTQueryAdapter queryAdapter = new MTQueryAdapter();
                        queryAdapter.Init(AUTH_QUERY_FOLDER);
                        queryAdapter.SetQueryTag("__INSERT_AUTH_TICKET__");


                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.GetQuery()))
                        {
                            stmt.AddParam(MTParameterType.Integer, idTicket);
                            stmt.AddParam(MTParameterType.NText, encSalt);
                            stmt.AddParam(MTParameterType.Integer, id_acc);
                            stmt.AddParam(MTParameterType.NText, nameSpace);
                            stmt.AddParam(MTParameterType.NText, userName);
                            stmt.AddParam(MTParameterType.Integer, ticketLifeSpanMins);
                            stmt.AddParam(MTParameterType.DateTime, MetraTime.Now);
                            stmt.AddParam(MTParameterType.DateTime, (ticketLifeSpanMins <= 0) ? MetraTime.Max : MetraTime.Now.AddMinutes(ticketLifeSpanMins));

                            mLogger.LogInfo("executing insert auth ticket query");
                            stmt.ExecuteNonQuery();

                        }
                    }
                    scope.Complete();
                }

                return encTicket;
            }
            catch (MASBasicException masE)
            {
                mLogger.LogException("Cannot create ticket", masE);
                throw;
            }
            catch (Exception e)
            {
                mLogger.LogException("Cannot create ticket", e);

                throw new MASBasicException("Cannot create ticket");
            }
        }

        public static void ValidateTicket(IMTSessionContext requestor, string ticket, out string nameSpace, out string userName, out IMTSessionContext sessionContext)
        {
            sessionContext = null;
            try
            {
                CryptoManager cm = new CryptoManager();
                string decTicket = cm.Decrypt(CryptKeyClass.Ticketing, ticket);
                string[] ticketInfo = decTicket.Split(';');

                using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AUTH_QUERY_FOLDER))
                    {
                        MTQueryAdapter queryAdapter = new MTQueryAdapter();
                        queryAdapter.Init(AUTH_QUERY_FOLDER);
                        queryAdapter.SetQueryTag("__LOAD_AUTH_TICKET__");
                        queryAdapter.AddParam("%%UPDLOCK%%", (conn.ConnectionInfo.IsSqlServer) ? "with (updlock)" : "", true);

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.GetQuery()))
                        {
                            stmt.AddParam(MTParameterType.Integer, ticketInfo[1] /* id_Ticket */);
                            stmt.AddParam(MTParameterType.NText, ticketInfo[0] /* salt */);

                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {

                                if (reader.Read())
                                {
                                    DateTime expiration = reader.GetDateTime("dt_expiration");
                                    nameSpace = reader.GetString("nm_space");
                                    userName = reader.GetString("nm_login");
                                    int lifespanMinutes = reader.GetInt32("n_lifespanminutes");

                                    if (expiration > MetraTime.Now)
                                    {
                                        IMTLoginContext loginContext = new MTLoginContextClass();
                                        sessionContext = loginContext.LoginAsAccountByName((MTSessionContext)requestor, nameSpace, userName);

                                        //TODO: update ticket withs new expiration.
                                        DateTime newExpiration = (lifespanMinutes <= 0) ? MetraTime.Max : MetraTime.Now.AddMinutes(lifespanMinutes);
                                        UpdateTicket(newExpiration, Convert.ToInt32(ticketInfo[1]) /* id_ticket*/);
                                    }
                                    else
                                    {
                                        //Invalidate ticket due to expiration.
                                        InvalidateTicket(ticket);
                                        //Throw new Invalid Ticket Exception so caller get notified and take necessary actions.
                                        throw new MASBasicException("Invalid Ticket");

                                    }
                                }
                                else
                                {
                                    throw new MASBasicException("Invalid ticket");
                                }

                            }
                        }
                    }
                    scope.Complete();
                }
            }
            catch (MASBasicException masE)
            {
                mLogger.LogException("Error while ticket validation ", masE);
                throw;
            }
            catch (Exception e)
            {
                mLogger.LogException("Error while ticket validation", e);

                throw new MASBasicException("Error while ticket validation");
            }
        }

        public static void UpdateTicket(DateTime expiration, int idTicket)
        {
            try
            {

                using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AUTH_QUERY_FOLDER))
                    {
                        MTQueryAdapter queryAdapter = new MTQueryAdapter();
                        queryAdapter.Init(AUTH_QUERY_FOLDER);
                        queryAdapter.SetQueryTag("__UPDATE_AUTH_TICKET__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.GetQuery()))
                        {
                            stmt.AddParam(MTParameterType.DateTime, expiration);
                            stmt.AddParam(MTParameterType.Integer, idTicket);
                            stmt.ExecuteNonQuery();
                        }
                    }
                    scope.Complete();
                }

            }
            catch (MASBasicException masE)
            {
                mLogger.LogException("Error while updating ticket with new expiration ", masE);
                throw;
            }
            catch (Exception e)
            {
                mLogger.LogException("Error while updating ticket with new expiration", e);

                throw new MASBasicException("Error while ticket with new expiration");
            }
        }

        public static void InvalidateTicket(string ticket)
        {
            try
            {
                CryptoManager cm = new CryptoManager();
                string decTicket = cm.Decrypt(CryptKeyClass.Ticketing, ticket);
                int idTicket = Convert.ToInt32(decTicket.Split(';')[1]);
                using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection(AUTH_QUERY_FOLDER))
                    {
                        MTQueryAdapter queryAdapter = new MTQueryAdapter();
                        queryAdapter.Init(AUTH_QUERY_FOLDER);
                        queryAdapter.SetQueryTag("__DELETE_AUTH_TICKET__");

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(queryAdapter.GetQuery()))
                        {
                            stmt.AddParam(MTParameterType.Integer, idTicket);
                            stmt.AddParam(MTParameterType.DateTime, MetraTime.Now.AddHours(1));
                            stmt.ExecuteNonQuery();
                        }
                    }
                    scope.Complete();
                }

            }
            catch (MASBasicException masE)
            {
                mLogger.LogException("Error while invalidating Ticket ", masE);
                throw;
            }
            catch (Exception e)
            {
                mLogger.LogException("Error while invalidating Ticket ", e);

                throw new MASBasicException("Error while invalidating Ticket ");
            }
        }
        #endregion
    }
}
