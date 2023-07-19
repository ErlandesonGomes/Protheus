#INCLUDE "totvs.ch"
#INCLUDE "RestFul.ch"

User Function REQMAT()
    MsgAlert("Rest", "Rest")
return

WSRESTFUL REQMAT DESCRIPTION "Servico REST para manipulacao de Requisição de Material"
    WSDATA SoldeComp as String
    WSMETHOD POST DESCRIPTION "Cria o Requisição com body informado" WSSYNTAX "/REQMAT" PATH "/REQMAT" PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD POST WSSERVICE REQMAT

    Local cError as char
    Local oRequisiçao := JsonObject():New()
    Local Result := ""
    Private lMsErroAuto := .F.
    Private lOk := .F.

    Self:SetContentType("application/json")
    cError := oRequisiçao:fromJson( self:getContent() )
    ConOut(cError)
    ConOut(cvaltochar(oRequisiçao))
    
    if Empty(cError)

        result := '{"OK":"OK"}'
        ConOut(result)
        ::SetResponse(EncodeUTF8(Result))
        lOk := .T.
        return lOk

    end if
    
    SetRestFault(418,EncodeUTF8(cError+"n\ <<<<<<<<<< ERROR >>>>>>>>>"),.T.,418,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
    ConOut(cError)
    lOk := .F.
return lOk
