#INCLUDE "totvs.ch"
#INCLUDE "RestFul.ch"


User Function MT160WF()

    Local cPedido := SC7->C7_NUM
    Local TotalSC7 := 0
    Local TotalSC1 := 0
    Local aQtdSC7 := {}
    Local aTotalSC7 := {}
    Local aItemSC1 := {}
    Local TRI := {}
    Local aItemSC7 := {}
    Local cSC := SC7->C7_NUMSC
    Local cTEMP := ""
    Local IDCARD
    Local i
    LOCAL cREQUISICAO := ""
    Local oReq := JsonObject():New()
    Local fase := ""
    // Bloqueia Pedido Após Cotação e Pega Valores do Pedido de Compras
    SC7->( dbGoTop() )
    if  SC7->( dbSeek(FWXFilial("SC7") + cPedido ) )
        while !SC7->(EOF()) .AND. cPedido == SC7->C7_NUM            
            RecLock('SC7',.F.)
            Replace C7_CONAPRO With "B"
            TotalSC7 = TotalSC7 +  SC7->C7_TOTAL
            AAdd(aQtdSC7,SC7->C7_QUANT)
            AAdd(aTotalSC7,SC7->C7_TOTAL)
            aadd(aItemSC7,SC7->C7_ITEMSC)
            SC7->(MsUnlock())
            SC7->( dbSkip() )
        enddo
    end if

    // Pega Valores dos campos de Solicitação de Compras
    SC1->(DbSetOrder(1))
    SC1->(dbGoTop()) 
    if  SC1->( dbSeek(FWXFilial("SC1") + cSC +  aItemSC7[len(aItemSC7)]) )
        while !SC1->(EOF()) .AND. cSC == SC1->C1_NUM
            TotalSC1 := TotalSC1 +  (SC1->C1_VUNIT * SC1->C1_QUANT)
            IDCARD := trim(SC1->C1_YPIPID)
            AAdd(TRI,trim(SC1->C1_YTRI))
            aadd(aItemSC1,trim(SC1->C1_ITEM))
            SC1->( dbSkip() )
        enddo
    end if


    For i := 1 to Len(aItemSC7) 
        IF cTEMP <> ""
             cTEMP := cTEMP + ','
        END IF
        cTEMP := cTEMP + '{'
        cTEMP := cTEMP + '"Item" : "' + trim(aItemSC7[i]) + '",' 
        cTEMP := cTEMP + '"TRI" : "' + trim(TRI[i]) + '",' 
        cTEMP := cTEMP + '"Quantidade": "' + cvaltochar(aQtdSC7[i]) +    '",'
        cTEMP := cTEMP + '"Preco Unitario": "' + cvaltochar(aTotalSC7[i]/aQtdSC7[i]) + '",'
        cTEMP := cTEMP + '"Preco Total": "' + cvaltochar(aTotalSC7[i])+ '"'
        cTEMP := cTEMP + '}'
    Next i






    if TotalSC7 > 500
            fase := GETMV("MV_PIPEFY3")
            if  TotalSC7 > (TotalSC1 * 1.1)
                MsgAlert("Pedido "+cPedido+" Foi Movido para etapa de Aprovação da Diretoria", "Acima de 10%, Acima de 500 R$")        
            else
                MsgAlert("Pedido "+cPedido+" Foi Movido para etapa de Aprovação da Diretoria", "Abaixo  de 10%, Acima de 500 R$")        
            endif
            //FWAlertInfo("Valores Alterados: " + CRLF + cTEMP,"Valores Enviados")
    else       
        if TotalSC7 > (TotalSC1 * 1.1)
            MsgAlert("Pedido "+cPedido+" Foi Movido para etapa de Aprovação do Head da Celula", "Acima de 10%, Abaixo de 500 R$")
            fase := GETMV("MV_PIPEFY1")
        else
            MsgAlert("Pedido " + cPedido + " Movido Para Aprovação do Head De Compras","Abaixo de 10% de aumento")
            //FWAlertInfo("Valores Alterados: " + CRLF + cTEMP,"Valores Enviados")
            fase := GETMV("MV_PIPEFY2")
        end if
    end if

/*
    if TotalSC7 > (TotalSC1 * 1.1)
        if TotalSC7 > 500
            MsgAlert("Pedido "+cPedido+" Foi Movido para etapa de Aprovação da Diretoria", "Acima de 10%, Acima de 500 R$")        
            fase := GETMV("MV_PIPEFY3")
            //FWAlertInfo("Valores Alterados: " + CRLF + cTEMP,"Valores Enviados")
        else
            MsgAlert("Pedido "+cPedido+" Foi Movido para etapa de Aprovação do Head da Celula", "Acima de 10%, Abaixo de 500 R$")
            
           // FWAlertInfo("Valores Alterados: " + CRLF + cTEMP,"Valores Enviados")
             fase := GETMV("MV_PIPEFY1")
        end if
    else
        MsgAlert("Pedido " + cPedido + " Movido Para Aprovação do Head De Compras","Abaixo de 10% de aumento")
        //FWAlertInfo("Valores Alterados: " + CRLF + cTEMP,"Valores Enviados")
         fase := GETMV("MV_PIPEFY2")
    end if

*/
    cREQUISICAO := cREQUISICAO + '{'
    cREQUISICAO := cREQUISICAO + '"CARD":"'+IDCARD+'",'
    cREQUISICAO := cREQUISICAO + '"DPI":"'+fase+'",'
    cREQUISICAO := cREQUISICAO + '"TOTAL":"'+cvaltochar(TotalSC7)+'",'
    cREQUISICAO := cREQUISICAO + '"PRODUTO":['+cTEMP+']'
    cREQUISICAO := cREQUISICAO + '}'
    oReq:FromJson(cREQUISICAO)


    if PostAPI(cREQUISICAO) <> "Success"
        FWAlertSuccess("Sincronizado no Pipefy","OK")
        ConOut(oReq)
    end if



    SC7->( dbGoTop() )
    if  SC7->( dbSeek('010101' + cPedido ) )
    ENDIF

return

Static Function PostAPI(Body)
    Local cURI      := "https://api.fonnet.net.br:4433/PipefyCompras" // URI DO SERVIÃ‡O REST
    Local cResource := "/pipefy/comprasCotacao"                  // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI)      // CLIENTE PARA CONSUMO REST
    Local aHeader   := {}                      // CABEÃ‡ALHO DA REQUISIÃ‡ÃƒO
    Local cRetorno

    // PREENCHE CABEÃ‡ALHO DA REQUISIÃ‡ÃƒO
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÃ‡ÃƒO
    oRest:SetPath(cResource)
    oRest:SetPostParams(Body)

    // REALIZA O MÃ‰TODO POST E VALIDA O RETORNO
    If (oRest:Post(aHeader))
        cRetorno := "POST: " + oRest:GetResult()
    Else
        cRetorno := "POST: " + oRest:GetLastError()
    EndIf
Return cRetorno
