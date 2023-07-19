Static function tstsmtp( cSMTPServer, cPort, cUser, cAccount, cPass, lAuth, nTimeout )
  Local oServer := Nil
  Local oMessage  := Nil
  Local nret := 0
  oServer := TMailManager():New()
  oServer:Init( "", cSMTPServer, cAccount, cPass, 0, val( cPort ) )
  If( nTimeout <= 0 )
    conout( "[TIMEOUT] DISABLE" )
  Else
    conout( "[TIMEOUT] ENABLE()" )
    nRet := oServer:SetSmtpTimeOut( 120 )
    If nRet != 0
      conout( "[TIMEOUT] Fail to set" )
      conout( "[TIMEOUT][ERROR] " + str( nRet, 6 ), oServer:GetErrorString( nRet ) )
      Return .F.
    EndIf
  Endif
  Conout( "[SMTPCONNECT] connecting ..." )
  nRet := oServer:SmtpConnect()
  If nRet != 0
    conout( "[SMTPCONNECT] Falha ao conectar" )
    conout( "[SMTPCONNECT][ERROR] " + str( nRet, 6 ), oServer:GetErrorString( nRet ) )
    Return .F.
  Else
    conout( "[SMTPCONNECT] Sucesso ao conectar" )
  EndIf
  If lAuth
    conout( "[AUTH] ENABLE" )
    conout( "[AUTH] TRY with ACCOUNT() and PASS()" )
    // try with account and pass
    nRet := oServer:SMTPAuth( cAccount, cPass )
    If nRet != 0
      conout( "[AUTH] FAIL TRY with ACCOUNT() and PASS()")
      conout( "[AUTH][ERROR] " + str(nRet,6) , oServer:GetErrorString( nRet ) )
      conout( "[AUTH] TRY with USER() and PASS()" )
      // try with user and pass
      nRet := oServer:SMTPAuth( cUser, cPass )
      If nRet != 0
        conout( "[AUTH] FAIL TRY with USER() and PASS()" )
        conout( "[AUTH][ERROR] " + str( nRet, 6 ), oServer:GetErrorString( nRet ) )
        Return .F.
      Else
        conout( "[AUTH] SUCEEDED TRY with USER() and PASS()" )
      Endif
    Else
      conout( "[AUTH] SUCEEDED TRY with ACCOUNT and PASS" )
    Endif
  Else
    conout( "[AUTH] DISABLE" )
  Endif
  conout( "[MESSAGE] Criando mail message" )
  oMessage := TMailMessage():New()
  oMessage:Clear()
  oMessage:cFrom          := cAccount
  oMessage:cTo            := "erlandeson.gomes@fonnet.com.br"
  oMessage:cCc            := ""
  oMessage:cBcc           := ""
  oMessage:cSubject       := "Teste de Email " + dtoc( date() ) + " " + time()
  oMessage:cBody          := "Teste"
  conout( "[SEND] Sending ..." )
  nRet := oMessage:Send( oServer )
  If nRet != 0
    conout( "[SEND] Fail to send message" )
    conout( "[SEND][ERROR] " + str( nRet, 6 ), oServer:GetErrorString( nRet ) )
  Else
    conout( "[SEND] Success to send message" )
  EndIf
  conout( "[DISCONNECT] smtp disconnecting ... " )
  nRet := oServer:SmtpDisconnect()
  If nRet != 0
    conout( "[DISCONNECT] Fail smtp disconnecting ... " )
    conout( "[DISCONNECT][ERROR] " + str( nRet, 6 ), oServer:GetErrorString( nRet ) )
  Else
    conout( "[DISCONNECT] Success smtp disconnecting ... " )
  EndIf
return
