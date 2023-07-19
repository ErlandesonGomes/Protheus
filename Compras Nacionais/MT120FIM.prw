#INCLUDE "TOTVS.CH"

user function MT120FIM()
COMNACPED()
Return



STATIC Function COMNACPED() 
    Local nOpcao := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
    Local nConfirma := PARAMIXB[3]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO
    Local pedido := ""
    Local oRet
    Local oJson
    Local aArea := GetArea() 
    Local cMens
    if (nOpcao == 3 .and. nConfirma == 1) .OR. (nOpcao == 4 .and. nConfirma == 1) 
        if trim(SC7->C7_TES) == '445'
            pedido := trim(SC7->C7_NUM)
            oRet := INTCOMN(pedido)
            oJson := JsonObject():New()
            oJson:FromJson(oRet)
            cMens := DecodeUTF8(Ojson['message'], "cp1252")
            if Ojson['result'] == 1
                FWAlertSucess(cMens,"OK")
            else
                FWAlertError('<p style="color:#FF0000"> '+cMens+"</p>","Falha")
            endif
            
        ENDIF
    ELSEIF (nOpcao == 5 .and. nConfirma == 1) 
        if trim(SC7->C7_TES) == '445'
                pedido := trim(SC7->C7_NUM)
                oRet := INTDELCOMN(pedido)
                oJson := JsonObject():New()
                oJson:FromJson(oRet)
                cMens := DecodeUTF8(Ojson['message'], "cp1252")
                if Ojson['result'] == 1
                    FWAlertSucess(cMens,"OK")   
                else
                    FWAlertError('<p style="color:#FF0000"> '+cMens+"</p>","Falha")
                endif
                
            ENDIF

    ENDIF

    RestArea(aArea)
Return 

Static Function INTCOMN(pedido)
    Local cURI      := "https://www.fonnet.net.br" // URI DO SERVIÇO REST
    Local cResource := "/CompraNacionalRevenda/api/IntegrationCompraNacional" // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI) // CLIENTE PARA CONSUMO REST
    Local aHeader   := {} // CABEÇALHO DA REQUISIÇÃO

    // PREENCHE CABEÇALHO DA REQUISIÇÃO
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÇÃO
    oRest:SetPath(cResource)
    oRest:SetPostParams(GetJsonCMN(pedido))

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
Static Function GetJsonCMN(pedido)
    Local bObject := {|| JsonObject():New()}
    Local oJson   := Eval(bObject)
    oJson["idPedido"] := pedido
    
Return (oJson:ToJson())


Static Function INTDELCOMN(pedido)
    Local cServer   := "www.fonnet.net.br"                               // URL (IP) DO SERVIDOR
    Local cURI      := "https://" + cServer  // URI DO SERVI�O REST
    Local cId       := pedido                                 // ID DO REGISTRO A SER DELETADO
    Local cResource := "/CompraNacionalRevenda/api/IntegrationCompraNacional/"  // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI)                            // CLIENTE PARA CONSUMO REST
    Local aHeader   := {}                                            // CABE�ALHO DA REQUISI��O
    Local oRet := ""

    // PREENCHE CABE�ALHO DA REQUISI��O
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    // INFORMA O RECURSO
    oRest:SetPath(cResource + cId)

    // REALIZA O M�TODO GET E VALIDA O RETORNO
    If (oRest:Delete(aHeader))
        ConOut("DELETE: " + oRest:GetResult())
        oRet := oRest:GetResult()
    Else
        ConOut("DELETE: " + oRest:GetLastError())
        oRet := oRest:cresult
    EndIf
Return oRet
