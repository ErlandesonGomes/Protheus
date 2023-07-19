#INCLUDE 'TOTVS.CH'

User Function MT120BRW() // Adicionar Bot�o
    Local _aBotao := {}
    Local aArea := GetArea()
    aAdd( aRotina, { "Sincronizar Syscontrol", "U_SYNCSYS", 4, 0, 4 } )
    RestArea(aArea)
Return(_aBotao)

User Function SYNCSYS()
    Local aArea := GetArea() 
    Local pedido := ""
    Local oRet
    Local oJson
    Local cMens
    
    

    if trim(SC7->C7_TES) == '445'
        pedido := trim(SC7->C7_NUM)
        oRet := INTCMNS(pedido)
        oJson := JsonObject():New()
        oJson:FromJson(oRet)
        cMens := DecodeUTF8(Ojson['message'], "cp1252")
        if Ojson['result'] == 1
            FWAlertSucess(cMens,"OK")   
        else
            FWAlertError('<p style="color:#FF0000"> '+cMens+"</p>","Falha")
        endif
        
    ENDIF
    RestArea(aArea)
Return

Static Function INTCMNS(pedido)
    Local cURI      := "https://www.fonnet.net.br" // URI DO SERVIÇO REST
    Local cResource := "/CompraNacionalRevenda/api/IntegrationCompraNacional" // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI) // CLIENTE PARA CONSUMO REST
    Local oRet := []
    Local aHeader   := {} // CABEÇALHO DA REQUISIÇÃO

    // PREENCHE CABEÇALHO DA REQUISIÇÃO
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÇÃO
    oRest:SetPath(cResource)
    oRest:SetPostParams(GetJsonSSB(pedido))

    // REALIZA O MÉTODO POST E VALIDA O RETORNO
    If (oRest:Post(aHeader))
        ConOut("POST: " + oRest:GetResult())
        oRet := oRest:GetResult()
    Else
        ConOut("POST: " + oRest:GetLastError())
        oRet := oRest:cresult
    EndIf
    
Return oRet


// CRIA O JSON QUE SERÝ ENVIADO NO CORPO (BODY) DA REQUISIÇÃO
Static Function GetJsonSSB(pedido)
    Local bObject := {|| JsonObject():New()}
    Local oJson   := Eval(bObject)
    oJson["idPedido"] := pedido
    
Return (oJson:ToJson())

