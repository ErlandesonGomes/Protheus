#Include 'TOTVS.ch'


User Function M185FGR()
    local oBody := ProcessamentoReq()     
    Conout(cvaltochar(oBody))
    SyncReqPipe(oBody)
Return  


User Function MA185ENC()
    local oBody := ProcessamentoReq()     
    Conout(cvaltochar(oBody))
    SyncReqPipe(oBody)
Return .T. 


STATIC Function ProcessamentoReq()
    Local cRequisicao := SCP->CP_NUM
    Local cPipeID := SCP->CP_YPIPID
    Local oBody := JsonObject():new()
    Local oProd 
    LOCAL I := 0
    if SCP->CP_YPIPID != "" 
    
    end if

    
    oBody["Requisicao"] := trim(cPipeID)
    oBody["Tipo"] := ""
    oBody["Status"] := "Fechado"
    oBody["Produtos"] := {}
    DbSelectArea("SCP")
    SCP->(DbOrderNickName("PIPREQ"))
    SCP->(DBGOTOP(  ))
    if DbSeek(xFilial("SCP")+cvaltochar(cPipeID)+cvaltochar(cRequisicao))
       while !SCP->(EOF()) .AND. SCP->CP_NUM == cRequisicao
            oProd                := JsonObject():New()
            oProd["CODIGO"]      := trim(SCP->CP_PRODUTO)
		    oProd["DESC"]        := trim(SCP->CP_DESCRI)
		    oProd["Quant.Sol"]   := SCP->CP_QUANT
		    oProd["Quant.Atend"] := SCP->CP_QUJE
            if Trim(SCP->CP_STATUS) = "E" 
                if SCP->CP_QUANT = SCP->CP_QUJE
                    oProd["Status"]      := "Integral"
                else
                    if SCP->CP_QUJE = 0
                        oProd["Status"]      := "Cancelado"
                    else
                        oProd["Status"]      := "Parcial"
                    endif
                endif
            else     
                oBody["Status"] := "Aberto"
                if SCP->CP_QUJE = 0
                    oProd["Status"]      := "Nao Atendido"
                else
                    oProd["Status"]      := "Parcial"
                endif
            endif
		   
            AADD(oBody["Produtos"],oProd)
            SCP->( dbSkip() )
            
        enddo
    EndIF
    FOR i := 1 to Len(oBody["Produtos"])
            if oBody["Produtos"][i]["Status"] = "Integral" 
                if oBody["Tipo"] = "" .or. oBody["Tipo"] = "Integral"
                    oBody["Tipo"] = "Integral"
                else 
                    oBody["Tipo"] = "Parcial"
                end if
            Else
                if oBody["Produtos"][i]["Status"] = "Cancelado" 
                     if oBody["Tipo"] = "" .or. oBody["Tipo"] = "Cancelado"
                        oBody["Tipo"] = "Cancelado"
                    else 
                        oBody["Tipo"] = "Parcial"
                    end if
                else
                    if oBody["Produtos"][i]["Status"] = "Nao Atendido"
                        if oBody["Tipo"] = "Parcial" .or. oBody["Tipo"] = "Cancelado" .or. oBody["Tipo"] = "Integral"
                            oBody["Tipo"] = "Parcial"
                        else 
                            oBody["Tipo"] = "Nao Atendido"
                        end if
                    else
                        if oBody["Produtos"][i]["Status"] = "Parcial"
                            oBody["Tipo"] = "Parcial"
                        end if


                    endif

                endif
            EndIf
    Next
return oBody

Static Function SyncReqPipe(oJsonPost)
    Local cURI      :=  "https://api.fonnet.net.br:4433/PipefyCompras" // "https://api.fonnet.net.br:4433"
    Local cResource := "/pipefy/Sincroniza-Requisicao" // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI) // CLIENTE PARA CONSUMO REST
    Local aHeader   := {} // CABEÃ‡ALHO DA REQUISIÃ‡ÃƒO
    Local cResponse

    // PREENCHE CABEÃ‡ALHO DA REQUISIÃ‡ÃƒO
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÃ‡ÃƒO
    oRest:SetPath(cResource)
    oRest:SetPostParams(oJsonPost:ToJson())

    // REALIZA O MÃ‰TODO POST E VALIDA O RETORNO
    If (oRest:Post(aHeader))
        ConOut("POST: " + cvaltochar(oJsonPost))
        ConOut("POST: " + oRest:GetResult())
    Else
        ConOut("POST: " + cvaltochar(oJsonPost))
        ConOut("POST: " + oRest:GetLastError())
    end if


    IF oRest:ORESPONSEH:CSTATUSCODE == "200" .OR. oRest:ORESPONSEH:CSTATUSCODE == "400"
        Conout(ORest:cResult)
    ELSE 
        alert("Erro na Sincroniza��o Contate o ADM","Contate o ADM")
        Conout(oRest:ORESPONSEH:CSTATUSCODE)
        Conout(ORest:cResult)
        RETURN cResponse
    ENDIF 
    

    

Return ORest:cResult

/////////////////////////////////////////// NFEDevolucao ////////////////////////////////////////////////////////////
