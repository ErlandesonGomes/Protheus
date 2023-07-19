#Include 'Protheus.ch'


User Function MT103FIM()
    COMNACNOT()
	AtuCD5()
Return

Static Function AtuCD5()

	Local cQuery := ""
	//Local cPedido := 

	cQuery := " SELECT CD5.R_E_C_N_O_ RECNO  "
	cQuery += "   FROM " + RETSQLNAME("CD5") + " CD5 "
	cQuery += "  INNER JOIN " + RETSQLNAME("SC7") + " SC7 "
	cQuery += "     ON SC7.C7_FILIAL = CD5.CD5_FILIAL "
	cQuery += "    AND SC7.C7_YNUM = CD5.CD5_DOC "
	cQuery += "  WHERE CD5.D_E_L_E_T_ = ' ' "
	cQuery += "    AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += "    AND SC7.C7_NUM = '" + SD1->D1_PEDIDO + "' "
	cQuery += "    AND SC7.C7_FILIAL = '" + XFILIAL("SC7") + "' "
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"XSC7", .F., .T.)
	
	While XSC7->(!EOF())
	
		DBSELECTAREA("CD5")
		DBGOTO(XSC7->RECNO)
		
		RECLOCK("CD5",.F.)
		
			CD5->CD5_DOC := SF1->F1_DOC
		
		MSUNLOCK()		
		
		XSC7->(DBSKIP())
	
	EndDo
	
	XSC7->(DBCLOSEAREA())	 

Return


STATIC Function COMNACNOT() 
    Local nOpcao := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
    Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO
    Local pedido := ""
    Local oRet
    Local oJson
    Local aArea := GetArea() 
    Local cMens
    if nOpcao == 3 .and. nConfirma == 1 
        if trim(SD1->D1_TES) == '445'
            pedido := trim(SD1->D1_PEDIDO)
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
    ENDIF
    RestArea(aArea)
Return 

Static Function INTCOMN(pedido)
    Local cURI      := "https://www.fonnet.net.br" // URI DO SERVIÇO REST
    Local cResource := "/CompraNacionalRevenda/api/IntegrationCompraNacional" // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI) // CLIENTE PARA CONSUMO REST
    Local aHeader   := {} // CABEÇALHO DA REQUISIÇÃO
    Local oRet := ""

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
