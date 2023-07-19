// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"


User Function MT110GRV ()
Local SC1->C1_OBS := SC1->C1_OBS
local lval := .f.
Static aTeste := {} 
local i := 0
if len(aTeste) == 0
    AADD(aTeste, SC1->C1_OBS)
    card := alltrim(aTeste[Len(aTeste)])
    phase := "316085610"
    CardMut(card,phase) 
else
    for i:= 1 to len(aTeste)
        if aTeste[i] == SC1->C1_OBS
            lval := .f.
            EXIT
        else
            lval := .t.
        Endif
    next i
    if lval == .t.
        AADD(aTeste, SC1->C1_OBS)
        card := alltrim(aTeste[Len(aTeste)])
        phase := "316085610"
        CardMut(card,phase) 
    EndIf
EndIf



Return

// FUNÇÃO PARA CONSUMO DO SERVIÇO REST
 Static Function CardMut(card,phase)
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
    oRest:SetPostParams(GetJson(card,phase))

    // REALIZA O MÉTODO POST E VALIDA O RETORNO
    If (oRest:Post(aHeader))
        ConOut("POST: " + oRest:GetResult())
    Else
        ConOut("POST: " + oRest:GetLastError())
    EndIf
Return (NIL)


// CRIA O JSON QUE SERÁ ENVIADO NO CORPO (BODY) DA REQUISIÇÃO
Static Function GetJson(card,phase)
    Local bObject := {|| JsonObject():New()}
    Local oJson   := Eval(bObject)
    oJson["card"]           := card
    oJson["phase"]          := phase
    
Return (oJson:ToJson())
