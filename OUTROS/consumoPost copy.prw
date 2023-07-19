// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"

// FUNÇÃO PARA CONSUMO DO SERVIÇO REST
User Function T164POST()
    Local cURI      := "http://127.0.0.1:1000" // URI DO SERVIÇO REST
    Local cResource := "/add"                  // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI)      // CLIENTE PARA CONSUMO REST
    Local aHeader   := {}                      // CABEÇALHO DA REQUISIÇÃO

    // PREENCHE CABEÇALHO DA REQUISIÇÃO
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÇÃO
    oRest:SetPath(cResource)
    oRest:SetPostParams(GetJson())

    // REALIZA O MÉTODO POST E VALIDA O RETORNO
    If (oRest:Post(aHeader))
        ConOut("POST: " + oRest:GetResult())
    Else
        ConOut("POST: " + oRest:GetLastError())
    EndIf
Return (NIL)


// CRIA O JSON QUE SERÁ ENVIADO NO CORPO (BODY) DA REQUISIÇÃO
Static Function GetJson()
    Local bObject := {|| JsonObject():New()}
    Local oJson   := Eval(bObject)
    oJson["card"]           := "554828155"
    oJson["phase"]          := "316085610"
    
Return (oJson:ToJson())
