
#include "totvs.ch"


User Function MT100TOK()
    Local aArea                     as array
    Local lRet                      as logical
    Local nX                        as numeric
    Local Count_CompraNacional      as numeric
    Local Count_RMA                 as numeric
    Local Count_DevolucaoVenda      as numeric
    Local Count_RetornoDemonstracao as numeric
    Local aRMAs                := {}
    Local aRMAs2               := {}
    Local NNF
    Local cMsg                 := ""
    local aCompraNacional      := StrTokArr( GetMV("MV_YCOMNAC"), ";" )
    local aRMA                 := StrTokArr( GetMV("MV_YRMA"), ";" )
    local aDevolucaoVenda      := StrTokArr( GetMV("MV_YDEVVEN"), ";" )
    local aRetornoDemonstracao := StrTokArr( GetMV("MV_YRETDEM"), ";" )
    local oJsonGet             := JsonObject():New()
    local oJsonPost            := JsonObject():New()
    

    
    //Inicializa as variáveis



    IF CFORMUL = "N"
        NNF := VAL(trim(CNFISCAL))
    ELSE 
        DbSelectArea("SX5")
        DbSetOrder(1)
        SX5->( dbSeek( xFilial('SX5')+'01'+'1' ) )
        NNF := VAL(trim(SX5->X5_DESCRI))
    END IF

    aArea                     := SC7->(getArea())
    lRet                      := .T.
    Count_CompraNacional      := 0
    Count_RMA                 := 0
    Count_DevolucaoVenda      := 0
    Count_RetornoDemonstracao := 0



    // Contagem da quantidade de Itens usando cada TES Analisada(445,440,417,443,400,402,424,430,431)
    For nX    := 1 To Len(aCols)
    
       
        // Verifica se alinha de item contém a TES 445 Compra Nacional
        IF AScan( aCompraNacional , {|x| x == aCols[nX][13] })
            Count_CompraNacional += 1
        ENDIF



        // Verifica se alinha de item contém a TES 440,417,443 RMA
        IF AScan( aRMA , {|x| x == aCols[nX][13] })
            Count_RMA += 1
            if  aCols[nX][1] == 0
                lRet := .F.
                cMsg += DecodeUTF8("A linha "+ cvaltochar(nX) +" possui o campo RMA vazio") + CRLF
            else
                aadd(aRMAs,aCols[nX][1])
            endif 
        ENDIF


        // Verifica se alinha de item contém a TES 400,402,424 Devolução de Vendas
        IF AScan( aDevolucaoVenda , {|x| x == aCols[nX][13] })
            Count_DevolucaoVenda += 1
        ENDIF


        // Verifica se alinha de item contém a TES 430,431 Retorno de Demostrações
        IF AScan( aRetornoDemonstracao , {|x| x == aCols[nX][13] })
            Count_RetornoDemonstracao += 1
        ENDIF



    Next nX


    // Compra Nacional
    If Count_CompraNacional > 0  
        IF Count_CompraNacional < LEN(aCols)
            lRet      := .F.
            cMsg += DecodeUTF8("A TES de compra nacional foi utilizada indevidamente.") + CRLF        
        EndIf
    EndIf
    // Compra Nacional


    // RMA
    If Count_RMA > 0 
    
        // Verifica se a TES está sendo usada de forma incorreta(mais de um tipo de TES na mesma nota)
    
        IF Count_RMA < LEN(aCols)
            lRet      := .F.
             cMsg += DecodeUTF8("A TES de RMA foi utilizada indevidamente.") + CRLF
        ELSE
            
            //RETIRANDO REGISTROS DUPLICADOS DO ARRAY
            for nX:=1 to len(aRMAs)
                if ascan(aRMAs2,aRMAs[nX]) = 0 ; aadd(aRMAs2,aRMAs[nX]) ; endif     
            next      

        ENDIF
    EndIf
    // RMA


    // Devolução de Venda
    If Count_DevolucaoVenda > 0 
        IF Count_DevolucaoVenda < LEN(aCols)
            lRet      := .F.
            cMsg += DecodeUTF8("A TES de Devolução de Venda foi utilizada indevidamente.") + CRLF
        ELSE
        ENDIF
    EndIf
    // Devolução de Venda


    //Retorno de Demonstração
    If Count_RetornoDemonstracao > 0 
        IF Count_RetornoDemonstracao < LEN(aCols)
            lRet      := .F.
            cMsg += DecodeUTF8("A TES de Retorno de Demonstração foi utilizada indevidamente.") + CRLF
        ELSE
        ENDIF
    EndIf
    //Retorno de Demonstração


     // Liberando Tabela
     restArea(aArea)


  

    
    // MOSTRA ERRO OU SEGUE O FLUXO DE SINCRONIZAÇÃO
    if cMsg != ""
        MsgStop(DecodeUTF8(cMsg))
    else
    
        ////////////////////////////////// S Y N C H R O N I Z A T I O N ///////////////////////////////////

        //////////////////////////////////////////////RMA///////////////////////////////////////////////////
        If Count_RMA > 0
            oJsonPost := CriarJsonRMA(aCols,aRMAs2,NNF)
            oJsonGet:FromJson(SyncRMA(oJsonPost))
            if oJsonGet["success"] != .T.
                lRet := .F.
                for nX:=1 to len(oJsonGet["errors"])
                    if nX > 1 
                        cMsg += CRLF
                    end if
                    cMsg += DecodeUTF8(oJsonGet["errors"][nX]) 
                next
                FWAlertError(cMsg,"Erro")
            else
                for nX:=1 to len(oJsonGet["data"])
                    FWAlertSuccess("RMA Sincronizado!", "Successo")
                    ShellExecute("Open", oJsonGet["data"][nX]["urlSysControl"], "", "", 1)
                next
            endif
        endif
        //////////////////////////////////////////////RMA///////////////////////////////////////////////////


        /////////////////////////////////////////// NFEDevolucao ////////////////////////////////////////////////////////////

        If Count_DevolucaoVenda > 0 .or. Count_RetornoDemonstracao > 0
            
            oJsonPost := CriarJsonNFEDevolucao(aCols,NNF)
            oJsonGet:FromJson(SyncNFEDevolucao(oJsonPost))
            if oJsonGet["success"] != .T.
                lRet := .F.
                for nX:=1 to len(oJsonGet["errors"])
                    if nX > 1 
                        cMsg += CRLF
                    end if
                    cMsg += DecodeUTF8(oJsonGet["errors"][nX]) 
                next
                FWAlertError(cMsg,"Erro")
            else
                    FWAlertSuccess("Devolu��o Sincronizada!", "Successo")
                    ShellExecute("Open", oJsonGet["data"]["urlSysControl"], "", "", 1)
            endif
        endif

        /////////////////////////////////////////// NFEDevolucao ////////////////////////////////////////////////////////////


    endif

Return lRet





/////////////////////////////////////////// RMA ////////////////////////////////////////////////////////////

Static Function CriarJsonRMA(aCols,aRMAs2,NNF)//U_testedejson
    
    local oRMA 
    local oItem 
    local aRoot := {}
    local oJson := JsonObject():new()
    local nX
    Local nY
    For nX := 1 To Len(aRMAs2)
        oRMA := JsonObject():new()
        oRMA['dataNf'] := Year2Str(DDEMISSAO)+"-"+Month2Str(DDEMISSAO)+"-"+Day2Str(DDEMISSAO)
        oRMA['codNfProtheus'] := NNF
        oRMA['ValorTotalNF'] := mafisret(,"NF_TOTAL")
        oRMA['IdCliente'] := VAL(CA100FOR)
        oRMA['rmaID'] := aCols[nX][1]
        oRMA['cfop'] := trim(aCols[nX][18])
        oRMA['produtos'] := {}
        For nY := 1 To Len(aCols)
            if aCols[nY][1] == aRMAs2[nX] .AND. aCols[nY][239] != .T.
                oitem := JsonObject():new() 
                oitem['codigoProtheus'] := trim(aCols[nY][2])
                oitem['quantidade'] := aCols[nY][6]
                oitem['valorUnitario'] := aCols[nY][7]
                aadd(oRMA['produtos'],oitem)
            endif
        next nY
        aadd(aRoot,oRMA)
    next nX

    oJson:Set(aRoot)

Return oJson

Static Function SyncRMA(oJsonPost)
    Local cURI      :=  GetMV("MV_YENDRMA") // URI DO SERVIÃ‡O REST
    Local cResource := "/CreateNfsRMAs" // RECURSO A SER CONSUMIDO
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
        RETURN ORest:cResult
    ELSE 
        alert(oRest:ORESPONSEH:CSTATUSCODE,"Contate o ADM")
        cResponse := '"success":false,"errors":["'+'Status Code = '+oRest:ORESPONSEH:CSTATUSCODE+'Error = '+ ORest:cResult +'"]}'
        RETURN cResponse
    ENDIF 
    

    

Return ORest:cResult

/////////////////////////////////////////// RMA ////////////////////////////////////////////////////////////


/////////////////////////////////////////// NFEDevolucao ////////////////////////////////////////////////////////////

Static Function CriarJsonNFEDevolucao(aCols,NNF)//U_testedejson
    
    local oDev 
    local oItem 
    Local nY
        oDev := JsonObject():new()
        oDev["CodNfSaida"] := VAL(trim(Acols[1][37])) 
        oDev['codNfProtheus'] := NNF
        oDev['ValorTotalNF'] := mafisret(,"NF_TOTAL")
        oDev['dataNf'] := Year2Str(DDEMISSAO)+"-"+Month2Str(DDEMISSAO)+"-"+Day2Str(DDEMISSAO)
        oDev['cfop'] := trim(aCols[1][18])
        oDev['produtos'] := {}
        For nY := 1 To Len(aCols)
            if aCols[nY][239] != .T.
                oitem := JsonObject():new() 
                oitem['codigoProtheus'] := trim(aCols[nY][2])
                oitem['quantidade'] := aCols[nY][6]
                oitem['valorUnitario'] := aCols[nY][7]
                aadd(oDev['produtos'],oitem)
            endif
        next nY
        
Return oDev


// Static Function CriarJsonNFEDevolucao(CodNfSaida,CodNfProtheus)//U_testedejson
//      local oJson := JsonObject():new()
//      oJson["CodNfSaida"] := VAL(trim(Acols[1][37]))
//      oJson["CodNfProtheus"] := VAL(trim(CodNfProtheus))
// Return oJson

Static Function SyncNFEDevolucao(oJsonPost)
    Local cURI      :=  GetMV("MV_YENDRMA") // URI DO SERVIÃ‡O REST
    Local cResource := "/CreateNFeDevolucao" // RECURSO A SER CONSUMIDO
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
        RETURN ORest:cResult
    ELSE 
        alert(oRest:ORESPONSEH:CSTATUSCODE,"Contate o ADM")
        cResponse := '"success":false,"errors":["'+'Status Code = '+oRest:ORESPONSEH:CSTATUSCODE+'Error = '+ ORest:cResult +'"]}'
        RETURN cResponse
    ENDIF 
    

    

Return ORest:cResult

/////////////////////////////////////////// NFEDevolucao ////////////////////////////////////////////////////////////

