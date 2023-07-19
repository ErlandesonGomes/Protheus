/*//#########################################################################################
Project  : Melhorias nos processos - FonNet
Module   : Financeiro
Source   : WFON005
Objective: Relatório de Aviso de Cobrança (transferência)
*///#########################################################################################

#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Totvs.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "RwMake.ch"

/*/{Protheus.doc} WFON005
    Gerenciador de Processamento
    @author  Dilson Castro
    @table   SA1, SE1
    @since   26-08-2021
    @type    function
/*/

User Function WFON005()
	Prepare Environment Empresa "01" Filial "01"
		QOUT("##### INICIANDO PROCESSAMENTO RELATORIO AVISO DE COBRANÇA #####")
    	U_WFON005C()
		QOUT("##### FINALIZANDO PROCESSAMENTO RELATORIO AVISO DE COBRANÇA #####")
	Reset Environment
Return

User Function WFON005C()
	Local   cCabec  := ""
	Local   aItens  := {}
	Local   nTotal  := 0
	Local   cBody   := ""
	Local   cBodyt  := ""
	Local   cItens  := ""
	Local   cCor    := "white"
	Local   i       := 0
	Local   nReg    := 0
	Local   cEmailV := ""
	Private aHeader := {}

	cQuery := "SELECT "
	cQuery += " A1_COD, A1_LOJA, A1_NOME, A1_EMAIL, A1_YDIACOB, A1_VEND, A3_EMAIL "
	cQuery += "FROM "+RETSQLNAME("SA1")+" SA1 "
	cQuery += " INNER JOIN "+RETSQLNAME("SA3")+" SA3 ON "
	cQuery += "  A1_FILIAL=A3_FILIAL AND A1_VEND=A3_COD "
	cQuery += "WHERE "
	cQuery += " SA1.D_E_L_E_T_ != '*' AND SA3.D_E_L_E_T_ != '*' AND A1_YDIACOB != '' AND "
	cQuery += " A1_EMAIL!='' AND A1_EST!='EX' "

	TCQUERY cQuery NEW ALIAS T01
	DBSELECTAREA("T01")

	cDiaCob  := StrTokArr(Alltrim(T01->A1_YDIACOB),"-")
	cCobQry  := ""
	For nReg :=1 to Len(cDiaCob)
		cCobQry += "'"+DtoS(date()-val(cDiaCob[nReg]))+"'"
		If ( nReg+1 ) <= Len(cDiaCob)
			cCobQry += "," 
		Endif
	Next nReg

	///-Incluído por Dilson Castro em 29/08/2022
	//Uso NÃO PERMITIDO de API em LOOP
	cDe      := GETMV("MV_RELACNT")
	cCC      := GETMV("MV_YCOBEMA")
	cBCC     := GETMV("MV_YCBCC")
	///-
	WHILE !T01->(EOF())
		/* 26/08/2021 - Brena solicitou a retirada da coluna Prefixo*/
		//cCabec := " Prefixo, Título, Parcela, Emissão, Vencimento, Venc.Real, Valor"
		cCabec := " Título, Parcela, Emissão, Vencimento, Venc.Real, Valor"
		aHeader:= StrTokArr(cCabec,",")
		/*30/08/2021 - Brena solicitou a inclusão do e-mail do vendedor*/
		/*04/11/2021 - Fernando solicitou comentar para testar problema de envio*/
		cEmailV := IIF(!Empty(T01->A3_EMAIL),Alltrim(T01->A3_EMAIL),"")
		//cEmailV := ""

		cQuery := "SELECT "
		/* 26/08/2021 - Brena solicitou a retirada da coluna Prefixo*/
		//cQuery += " E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_VALOR "
		cQuery += " E1_CLIENTE, E1_LOJA, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_VALOR "
		cQuery += "FROM "+RETSQLNAME("SE1")+" SE1 "
		cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON "
		cQuery += "  SA1.D_E_L_E_T_ = '' AND A1_COD = E1_CLIENTE AND "
		cQuery += "  A1_LOJA = E1_LOJA AND A1_EMAIL <> '' AND A1_EST <> 'EX' "
		cQuery += "WHERE "
		cQuery += " SE1.D_E_L_E_T_ != '*' AND SA1.D_E_L_E_T_ != '*' AND RTRIM(E1_TIPO) = 'NF' AND "
		/* 26/08/2021 - Brena solicitou emails separados por boleto e transferência, será utilizado o campo E1_NATUREZA, 101001 (boleto) e 101002 transferência*/		
		//cQuery += " E1_VENCREA IN ("+cCobQry+") AND E1_SALDO > 0 AND "
		cQuery += " E1_VENCREA IN ("+cCobQry+") AND E1_SALDO > 0 AND E1_NATUREZ='101002' AND "
		cQuery += " E1_FILIAL = '"+cFilAnt+"' AND E1_CLIENTE='"+T01->A1_COD+"' AND E1_LOJA='"+T01->A1_LOJA+"'"
		
		TCQUERY cQuery NEW ALIAS T02
		DBSELECTAREA("T02")

		WHILE  !T02->(EOF()) .And. (T01->A1_COD == T02->E1_CLIENTE .AND. T01->A1_LOJA == T02->E1_LOJA)
			nTotal += T02->E1_VALOR
			/* 26/08/2021 - Brena solicitou a retirada da coluna Prefixo*/
			//AADD(aItens,{T02->E1_PREFIXO,;
			AADD(aItens,{T02->E1_NUM,;
						 T02->E1_PARCELA,;
						 STOD(T02->E1_EMISSAO),;
						 STOD(T02->E1_VENCTO),;
						 STOD(T02->E1_VENCREA),;
						 T02->E1_VALOR })
			T02->(dbSkip())
		ENDDO

		If Len(aItens) > 0
			/* 26/08/2021 - Brena solicitou a retirada da coluna Prefixo*/
			//AADD(aItens,{"",; // elemento 1/7
			AADD(aItens,{"",;
						"",;
						"",;
						"",;
						"",;
						nTotal })

			For i:=1 to Len(aItens)
				cItens += "<tr>"
				//cItens += " <td align='center' width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + ALLTRIM(aItens[i][1]) + "</td>"
				cItens += " <td align='center' width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + ALLTRIM(aItens[i][1]) + "</td>"
				cItens += " <td align='center' width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + ALLTRIM(aItens[i][2]) + "</td>"
				If !Empty(aItens[i][1]) // Título (soma)
					cItens += " <td align='center' width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + ALLTRIM(DtoC(aItens[i][3])) + "</td>"
					cItens += " <td align='center' width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + ALLTRIM(DtoC(aItens[i][4])) + "</td>"
					cItens += " <td align='center' width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + ALLTRIM(Dtoc(aItens[i][5])) + "</td>"
					cItens += " <td align='right'  width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + TransForm(aItens[i][6],"@E 99,999,999.99")
				Else
					cItens += " <td align='center' width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + ALLTRIM(aItens[i][3]) + "</td>"
					cItens += " <td align='center' width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + ALLTRIM(aItens[i][4]) + "</td>"
					cItens += " <td align='center' width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'>" + ALLTRIM(aItens[i][5]) + "</td>"
					cItens += " <td align='right'  width='12%' bgcolor='"+ALLTRIM(cCor)+"'><font size='2' face='Arial'><b>" + TransForm(aItens[i][6],"@E 99,999,999.99")+"</b>"
				EndIf
				cItens += "</tr>"
				If ALLTRIM(cCor) == "white"
					cCor:="#E0EEEE"
				Else
					cCor:= "white"
				EndIf
			Next i

			cBodyt := "<table border='0' align='center' cellpadding='1' cellspacing='1' bgColor=#ffffff bordercolor='#000000' width='100%'> "
			cBodyt += " <tr>"
			/* 26/08/2021 - Brena solicitou a retirada da coluna Prefixo*/
			//cBodyt += "   <td align='center' width='7%' bgcolor='#336699'> "
			//cBodyt += "   <font size='2' color='white' face='Arial'><b>PREFIXO</b></font></td>"
			cBodyt += "   <td align='center' width='7%' bgcolor='#336699'> "
			cBodyt += "   <font size='2' color='white' face='Arial'><b>TÍTULO</b></font></td>"
			cBodyt += "   <td align='center' width='7%' bgcolor='#336699'>"
			cBodyt += "   <font size='2' color='white' face='Arial'><b>PARCELA</b></font></td>"
			cBodyt += "   <td align='center' width='7%' bgcolor='#336699'>"
			cBodyt += "   <font size='2' color='white' face='Arial'><b>EMISSÃO</b></font></td>"
			cBodyt += "   <td align='center' width='7%' bgcolor='#336699'>"
			cBodyt += "   <font size='2' color='white' face='Arial'><b>VENCIMENTO</b></font></td>"
			cBodyt += "   <td align='center' width='7%' bgcolor='#336699'>"
			cBodyt += "   <font size='2' color='white' face='Arial'><b>VENCTO REAL</b></font></td>"
			cBodyt += "   <td align='center' width='7%' bgcolor='#336699'>"
			cBodyt += "   <font size='2' color='white' face='Arial'><b>VALOR</b></font></td>"
			cBodyt += "</tr>"
			cBodyt += cItens
			cBodyt += "</table>"
			MontaXML(aHeader, aItens)
			///-Alterado por Dilson Castro em 29/08/2022
			//Uso NÃO PERMITIDO de API em LOOP
			//cDe      := GETMV("MV_RELACNT")
			///-
			/*04/11/2021 - Fernando solicitou comentar para testar problema de envio*/
			cPara    := T01->A1_EMAIL
			///-Alterado por Dilson Castro em 29/08/2022
			//Uso NÃO PERMITIDO de API em LOOP
			//cCC      := GETMV("MV_YCOBEMA")//+IIF(!Empty(cEmailV),";"+cEmailV,"")//dilsoncastro@mconsult.com.br"
			///-			
			//cPara    := "fernando.marchetti@fonnet.com.br"
			//cCC      := ""
			///-Alterado por Dilson Castro em 29/08/2022
			//Uso NÃO PERMITIDO de API em LOOP
			//cBCC     := GETMV("MV_YCBCC")
			///-
			cAssunto := "Aviso de Cobrança - FONNET NETWORKS"
			cBody := "<p align=left><font face=Calibri size=4 color=#000000>"
			cBody += "<br>Prezado(a) cliente, "+ALLTRIM(T01->A1_NOME)
			cBody += "<br>"
			cBody += "<br>Até o momento, não identificamos em nossos sistemas o pagamento da(s) notas fiscais abaixo:"
			cBody += "<br>"
			cBody += cBodyt
			cBody += "<br>Entendemos que imprevistos acontecem e podemos perder alguns prazos, por isso estamos entrando em contato para negociação dos vencimentos."
			cBody += "<br>"
			cBody += "<br>Podemos reagendar para hoje?"
			cBody += "<br>"
			cBody += "<br>"
            cBody += "Segue abaixo nossos dados bancários:"
            cBody += "<br>"
            cBody += "<b>B.Brasil</b> Ag: 1369-2 CC: 26387-7 Pix: financeiro@fonnet.com.br"
            cBody += "<br>"
            cBody += "<b>Bradesco</b> Ag: 564 CC: 33855-9 
            cBody += "<br>"
            cBody += "<b>Itaú</b> Ag: 1338 CC: 73242-1 Pix: 11.035.558/0001-29"
            cBody += "<br>"
            cBody += "<b>Santander</b> Ag: 4279 CC: 13006199-5 "
			cBody += "<br>"
			cBody += "<br>Caso você enfrente qualquer dificuldade para efetuar seu pagamento, estamos a disposição para apoiá-lo."
			cBody += "<br>"
			cBody += "<br>Atenciosamente,"
			cBody += "<br>"
			cBody += "<br>Financeiro FonNet"
			cBody += "<br>E-mail: financeiro@fonnet.com.br"
			cBody += "<br>Fixo: +55 85 3494.2077 - Ramal 203"
			cBody += "<br>Celular: (85) 9 9108-3878"
			cBody += "</font><br><br>"

			cBody += "</font><br><br>"
			cAtach    := "\DATA\Cobranca.xls"
            /* 26/08/2021 - Brena solicitou a retirada do arquivo*/
            //TEnvMail(cPara,cAssunto,cBody,cAtach,cCC)
            TEnvMail(cPara,cAssunto,cBody,cCC,cBCC)
			cCabec  := ""
			aItens  := {}
			nTotal  := 0
			aHeader := {}
			cItens  := ""
		EndIf
		T02->(dbclosearea())
		T01->(dbSkip())
	ENDDO
	T01->(dbclosearea())
RETURN

Static Function MontaXML(colunas, dados)
	Local oExcel := FWMSEXCELEX():New()
	Local x
	oExcel:AddworkSheet("Relato")
	oExcel:AddTable ("Relato","Dados")
	//colunas
	For x := 1 to len(colunas)
		/* 26/08/2021 - Brena solicitou a retirada da coluna Prefixo*/
		//If colunas[x] $ " Prefixo_ Título_ Parcela"
		If colunas[x] $ " Título_ Parcela"
			nAlign  := 1
			nFormat := 1
		ElseIf colunas[x] $ " Emissão_Vencimento_ Venc.Real"
			nAlign  := 2
			nFormat := 4
		ElseIf colunas[x] $ " Valor"
			nAlign  := 3
			nFormat := 3
		EndIf
		oExcel:AddColumn("Relato","Dados",Alltrim(colunas[x]),nAlign,nFormat)
	Next x
	//linhas
	For x := 1 to len(dados)
		IncProc()
		/* 26/08/2021 - Brena solicitou a retirada da coluna Prefixo*/
		//If !Empty(dados[x][2]) // Titulo (soma)
		If !Empty(dados[x][1]) // Titulo (soma)
			oExcel:AddRow("Relato","Dados",dados[x])
		Else
			oExcel:SetCelBold(.T.)
			oExcel:SetCelFont('Arial')
			oExcel:SetCelItalic(.T.)
			oExcel:SetCelUnderLine(.T.)
			oExcel:SetCelSizeFont(16)
			oExcel:SetCelFrColor("#FFFFFF")
			oExcel:SetCelBgColor("#0000FF")
			oExcel:AddRow("Relato","Dados",dados[x])
		EndIf
	Next x
	oExcel:Activate()
	oExcel:GetXMLFile("\DATA\Cobranca.xls")
Return

/* 26/08/2021 - Brena solicitou a retirada do arquivo*/
//Static Function TEnvMail(cPara,cAssunto,cMensagem,cArquivo,cCC)
Static Function TEnvMail(cPara,cAssunto,cMensagem,cCC,cBCC)
	Local cMsg      := ""
	Local xRet
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)
	Local nPorta    := 587
			
	Private cFROM		:= NIL
	Private cMailConta	:= NIL
	Private cMailServer	:= NIL
	Private cMailSenha	:= NIL
	
   	oMessage:= TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom   := GETMV("MV_YCOBLEM")
	oMessage:cTo 	 := ENCODEUTF8(LOWER(ALLTRIM(cPara)))
	oMessage:cSubject:= cAssunto
	oMessage:cBody 	 := cMensagem
	oMessage:cCC     := cCC
	oMessage:cBCC    := cBCC

    /* 26/08/2021 - Brena solicitou a retirada do arquivo*/
    /*
	If !EMPTY(cArquivo)
		xRet := oMessage:AttachFile( cArquivo )
		If xRet < 0
			cMsg := "O arquivo " + cArquivo + " não foi anexado!"
			alert( cMsg )
			Return
		EndIf
	EndIf
    */

	oServer := tMailManager():New()
	oServer:SetUseTLS(.T.)
	oServer:SetUseSSL(.F.)
	
	xRet := oServer:Init( "", "smtp.gmail.com", GETMV("MV_RELAUSR"), GETMV("MV_RELAPSW"), 0, nPorta )
	If xRet != 0
		alert("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ))
		Return
	EndIf
   
	xRet := oServer:SetSMTPTimeout( 120 ) //Indica o tempo de espera em segundos.
	If xRet != 0
		alert("Não foi possível definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	EndIf
   
	xRet := oServer:SMTPConnect()
	If xRet != 0
		alert("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		Return
	EndIf
   
	If lMailAuth
		xRet := oServer:SmtpAuth( GETMV("MV_RELAUSR"), GETMV("MV_RELAPSW") )
		If xRet != 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			alert( cMsg )
			oServer:SMTPDisconnect()
			Return
		EndIf
   	Endif
	xRet := oMessage:Send( oServer )
	If xRet != 0
		alert("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
	EndIf
   
	xRet := oServer:SMTPDisconnect()
	If xRet != 0
		alert("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	EndIf 
Return
