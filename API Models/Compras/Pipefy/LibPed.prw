#INCLUDE "totvs.ch"
#INCLUDE "RestFul.ch"


User Function LibPed()
    MsgAlert("Rest", "Rest")
return
    

WSRESTFUL LibPed DESCRIPTION "Servico REST para manipulacao de PC"

    WSDATA LiberaPedido as String

    WSMETHOD POST DESCRIPTION "Retorna o produto informado na URL" WSSYNTAX "/LibPed" PATH "/LibPed" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST WSSERVICE LibPed

    Local cError as char
    Local oPedido := JsonObject():New()
    Local Result := ""
    Local lOk := .T.
    Local cPedido := ""
    Private lMsErroAuto := .F.

    Self:SetContentType("application/json")
    cError := oPedido:fromJson( self:getContent() )

    if Empty(cError)

        DbSelectArea("SC1")
        SC1->(DbOrderNickName("CODPIPE"))
        SC1->(DBGOTOP(  ))
            if  SC1->( dbSeek('010101' + oPedido["Pedido"] ) )
                cPedido := SC1->C1_PEDIDO
                SC1->(DbCloseArea())
            else 
                Result := '{ Result : {"'+oPedido["Pedido"]+'":"Não Encontrado"}}''
            endif

        SC7->( dbGoTop() )
            if  SC7->( dbSeek('010101' + cPedido ) )
                while !SC7->(EOF()) .AND. cPedido == SC7->C7_NUM    
                    RecLock('SC7',.F.)
                    if UPPER(oPedido["Aprovacao"]) = "TRUE"
                        Replace C7_CONAPRO With "L"
                        Result := '{ Result : {"'+oPedido["Pedido"]+'":"Success"}}''
                    else
                        SC7->(DbDelete())
                        Result := '{ Result : {"'+oPedido["Pedido"]+'":"Success"}}''
                    endif
                    SC7->(MsUnlock())
                    SC7->( dbSkip() )
                enddo
                SC7->(DbCloseArea())
            else 
                Result := '{ Result : {"'+oPedido["Pedido"]+'":"Não Encontrado"}}''
            end if
        ::SetResponse(EncodeUTF8(Result))
        return lOk
    end if
    SetRestFault(418,EncodeUTF8(cError+"teste"),.T.,418,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
    lOk := .F.
return lOk
