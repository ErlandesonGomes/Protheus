#Include "Protheus.Ch"
#Include "Ap5Mail.Ch"

#Define P_CODCEDENTE		01
#Define P_CEDENTE			02
#Define P_CNPJCED        	03
#Define P_CLIENTE 			04
#Define P_LOJA 				05
#Define P_NOME 				06
#Define P_CNPJ 				07
#Define P_PESSOA 			08               	
#Define P_ENDERECO			09
#Define P_NUMERO 			10
#Define P_COMPLEMENTO		11
#Define P_BAIRRO	    	12
#Define P_CEP				13
#Define P_MUNICIPIO			14
#Define P_ESTADO			15
#Define P_BANCO				16
#Define P_AGENCIA			17
#Define P_CONTA				18
#Define P_NUMDOC			19
#Define P_ESPECIEDOC		20
#Define P_CARTEIRA			21
#Define P_ESPECIE			22
#Define P_EMISSAO			23
#Define P_VENCIMENTO		24
#Define P_DATPROC        	25
#Define P_NOSSONUMERO		26
#Define P_VALOR				27
#Define P_CODBARRAS			28
#Define P_LINHADIG			29
#Define P_DIGITOCB			30
#Define P_INSTRUCAO1		31
#Define P_INSTRUCAO2		32
#Define P_INSTRUCAO3		33 
#Define P_INSTRUCAO4		34
#Define P_INSTRUCAO5		35
#Define P_INSTRUCAO6		36
#Define P_INSTRUCAO7		37
#Define P_INSTRUCAO8		38
#Define P_ACEITE			39
#Define P_MSGLOCPAG1		40
#Define P_MSGLOCPAG2		41
#Define P_NOMEBCO			42
#Define P_NUMEROBCO			43
#Define P_LOGOBCO			44
#Define P_OPCPRINT			45
#Define P_MSGJUROS			46
#Define P_USUBANCO			47
#Define P_AVALISTA			48 
#Define P_ENDCOB			49  

#Define P_NTAMBOL			49 


/*/{Protheus.doc} OmFRCnab
Efetua pesquisa do Titulo a Receber na Baixa do Cnab.
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function OmFRCnab(_cNumTit,_cNossoNum,_cEspecie,_ValRec,_dDtBaixa,_cBuffer,_cBanco,_cAgencia,_cContaCor,_cConvenio,_cOrigem)

	Local lAchouSE1		:= .F.
	Local _nRegSE1		:= 0
	Local nTamPre		:= TamSX3("E1_PREFIXO")[1]
	Local nTamNum		:= TamSX3("E1_NUM")[1] 
	Local nTamPar		:= TamSX3("E1_PARCELA")[1]
	Local nTamTit		:= nTamPre+nTamNum+nTamPar
	Local lNewIndice 	:= FaVerInd()  //Verifica a existencia dos indices de IDCNAB sem filial
	Local _cBkpNossNum 	:= _cNossoNum
	
	Default	_cConvenio	:= ""
	Default	_cOrigem	:= ""

	If	Len(_cNumTit) > 10
		_cNumTit := StrZero(Val(_cNumTit),10)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Como o controle por ID_CNAB ainda nao esta implantado, as buscas serao   ³
	//³ por Chave do Titulo e Nosso Numero.									     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If 	lNewIndice .And. !Empty(xFilial("SE1"))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca por IdCnab (Sem Filial).											 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SE1->(DBSetOrder(19)) // E1_IDCNAB, R_E_C_N_O_, D_E_L_E_T_
		If	!Empty(_cNumTit) .And. SE1->(DBSeek(Substr(_cNumTit,1,10)))
			cFilAnt		:= SE1->E1_FILIAL
			mv_par11	:= 2  //Desligo contabilizacao on-line
			lAchouSE1 	:= .T.
			nPos   		:= 1
		EndIf

	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca por IdCnab.														 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SE1->(DBSetOrder(16)) // E1_FILIAL, E1_IDCNAB, R_E_C_N_O_, D_E_L_E_T_
		If	!Empty(_cNumTit) .And. SE1->(DBSeek(xFilial("SE1")+Substr(_cNumTit,1,10)))
			lAchouSE1 	:= .T.
			nPos   		:= 1
		EndIf

	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao achou pela chave do Titulo, procura pelo Nosso Numero.		     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	!lAchouSE1


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Insere Zero a esqueda do Nosso Numero.								     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	Len(AllTrim(_cNossoNum)) < 12
			_cNossoNum := StrZero(Val(_cNossoNum),12)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a busca pelo Nosso Numero Padrao ( E1_NUMBCO ).				     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nRegSE1 := fProcNumBco(_cBanco,_cAgencia,_cContaCor,_cNossoNum,_ValRec)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a busca pelo Nosso Numero ( E1_NUMBCO ) sem considerar zero a    ³
		//³ esquerda.																 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	_nRegSE1 <= 0
			_nRegSE1 := fProcNumBco(_cBanco,_cAgencia,_cContaCor,_cBkpNossNum,_ValRec)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a busca pelo backup do Nosso Numero ( E1_NUMBCO ).			     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	_nRegSE1 <= 0
			_nRegSE1 := fProcNumBco(_cBanco,_cAgencia,_cContaCor,StrZero(Val(_cBkpNossNum),11),_ValRec,.T.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a busca pelo backup do Nosso Numero ( E1_NUMBCO ) sem considerar ³
		//³ banco, agencia e conta para quando houve a exclusao do bordero.			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	_nRegSE1 <= 0
			_nRegSE1 := fProcNumBco(_cBanco,_cAgencia,_cContaCor,StrZero(Val(_cBkpNossNum),11),_ValRec,.T.,.F.)
		EndIf

		If	_nRegSE1 > 0

			DBSelectArea("SE1")
			SE1->(MsGoTo(_nRegSE1))
			lAchouSE1 	:= .T.
			nPos   		:= 1

			If	_cOrigem	== "FINA200"
				cFilAnt		:= SE1->E1_FILIAL
				mv_par11	:= 2  //Desligo contabilizacao on-line				
			EndIf
		EndIf
	EndIf
Return(lAchouSE1)


/*/{Protheus.doc} fProcNumBco
Efetua Busca pelo Nosso Numero.
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
Static Function fProcNumBco(_cNumBanco,_cAgencia,_cContaC,_cNumBco,nValRecCnb,lBuscaBkp,lBuscaBAC)

	Local _nRegSE1 	:= 0
	Local lDuplica	:= .F.
	Local cQuery	:= ""
	Local cValorRec := AllTrim(Str(nValRecCnb))

	Default	lBuscaBkp	:= .F.
	Default	lBuscaBAC	:= .T.

	cQuery	:= " SELECT	SE1.R_E_C_N_O_ AS REGSE1 "
	cQuery	+= " FROM	"+RetSqlName("SE1")+"	SE1 "
	cQuery	+= " WHERE	SE1.D_E_L_E_T_	= '' "
	If	lBuscaBAC
		cQuery	+= " AND	SE1.E1_PORTADO	= '"+_cNumBanco+"' "
		cQuery	+= " AND	SE1.E1_AGEDEP	= '"+_cAgencia+"' "
		cQuery	+= " AND	SE1.E1_CONTA	= '"+_cContaC+"' "
	EndIf
	cQuery	+= " AND SE1.E1_NUMBCO = '"+_cNumBco+"' "
	cQuery	+= " AND SE1.E1_SALDO > 0 "
	cQuery	+= " AND SE1.E1_BAIXA = '' "

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBSE1",.F.,.T.)

	DBSelectArea("TRBSE1")
	TRBSE1->(DBGoTop()) 

	While 	!TRBSE1->(Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se houve duplicidade.										     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	lDuplica
			_nRegSE1 	:= 0
			Exit
		EndIf

		_nRegSE1 	:= TRBSE1->REGSE1

		lDuplica	:= .T.

		TRBSE1->(DBSkip())
	EndDo

	TRBSE1->(DBCloseArea())

	If	lDuplica .And. _nRegSE1 == 0
		_nRegSE1 := fDup1705(_cNumBanco,_cAgencia,_cContaC,_cNumBco,nValRecCnb,.F.,.T.)
	EndIf

Return(_nRegSE1)


/*/{Protheus.doc} fDup1705
Tratamento especial para duplicidade do dia 17/05/2010.
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
Static Function fDup1705(_cNumBanco,_cAgencia,_cContaC,_cNumBco,nValRecCnb,lBuscaBkp,lBuscaBAC)

	Local _nRegSE1 	:= 0
	Local lDuplica	:= .F.
	Local cQuery	:= ""
	Local cValorRec := AllTrim(Str(nValRecCnb))

	Default	lBuscaBkp	:= .F.
	Default	lBuscaBAC	:= .T.

	cQuery	:= " SELECT	SE1.R_E_C_N_O_ AS REGSE1 "
	cQuery	+= " FROM	"+RetSqlName("SE1")+"	SE1 "
	cQuery	+= " WHERE	SE1.D_E_L_E_T_	= '' "
	If	lBuscaBAC
		cQuery	+= " AND	SE1.E1_PORTADO	= '"+_cNumBanco+"' "
		cQuery	+= " AND	SE1.E1_AGEDEP	= '"+_cAgencia+"' "
		cQuery	+= " AND	SE1.E1_CONTA	= '"+_cContaC+"' "
	EndIf
	cQuery	+= " AND	SE1.E1_NUMBCO = '"+_cNumBco+"' "
	
	cQuery	+= " AND		(	SE1.E1_EMISSAO	<> '20100517' OR "
	cQuery	+= " 			(SE1.E1_EMISSAO	= '20100517' AND SE1.E1_VALOR BETWEEN ("+cValorRec+"-1) AND ("+cValorRec+"+1)) "
	cQuery	+= " 		) "

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBSE1",.F.,.T.)

	DBSelectArea("TRBSE1")
	TRBSE1->(DBGoTop()) 

	While 	!TRBSE1->(Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se houve duplicidade.										     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	lDuplica
			_nRegSE1 	:= 0
			Exit
		EndIf

		_nRegSE1 	:= TRBSE1->REGSE1

		lDuplica	:= .T.

		TRBSE1->(DBSkip())
	EndDo

	TRBSE1->(DBCloseArea())

Return(_nRegSE1)


/*/{Protheus.doc} OmCalJur
Efetua Calculo de Juros.	
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function OmCalJur(dVencOri,dVencNovo,nValTot,lChecaSemJ,nRegSE1)

	Local aAreaSE1		:= SE1->(GetArea())
	Local aRetJurMul	:= {0,0,0}
	Local nValMulta		:= 0
	Local nTaxaMulta	:= 0
	Local nValJuro		:= 0     
	Local nTaxaJuro		:= 0.033 
	Local nValAcres		:= 0     
	Local nDiasAtraso	:= dVencNovo - dVencOri
	Local nDiaSemJur	:= 0

	Default	lChecaSemJ	:= .F.
	Default	nRegSE1		:= 0

	If	nDiasAtraso < 0
		nDiasAtraso := 0
	EndIf

	nDiasAtraso := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aRetJurMul:															     ³
	//³ 																	     ³
	//³ [01] - Valor da Multa												     ³
	//³ [02] - Valor do Juros												     ³
	//³ [03] - Valor de Multa+Juros											     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da Multa.													     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do	Case
		Case	nDiasAtraso <= 0
		nTaxaMulta := 0
		nTaxaJuro  := 0
		OtherWise
		nTaxaMulta := 2
	EndCase             

	nValMulta := Round( (( nValTot * nTaxaMulta) / 100 ) , 2 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do Juro diario.											     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValJuro := ( nValTot * nDiasAtraso  * nTaxaJuro * 0.01 )


	nValAcres := ( nValMulta + nValJuro )

	aRetJurMul[01] := nValMulta
	aRetJurMul[02] := nValJuro
	aRetJurMul[03] := nValAcres

	RestArea(aAreaSE1)

Return(aRetJurMul)


/*/{Protheus.doc} OmVIdCnab
Verifica se ha duplicidade de IDCNAB.
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function OmVIdCnab(nTpValid,nOpcA,cArqRem,lShowMsg,_cNumBanco,_cAgencia,_cContaC)

	Local cQuery  	:= ""
	Local lRet		:= .F.
	Local aIdCnab	:= {}              

	Default	nOpcA		:= 1
	Default	cArqRem		:= ""
	Default	lShowMsg	:= .F.
	Default	_cNumBanco	:= ""
	Default	_cAgencia	:= ""
	Default	_cContaC 	:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³nOpcA:                                    ³
	//³                                          ³
	//³1 - Somente verifica a duplicidade.       ³
	//³2 - Verifica e envia e-mail.				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If	nTpValid == 1
		cQuery	:= " SELECT	SE1.E1_IDCNAB AS CHAVE , COUNT(*) AS QUANTIDADE "
		cQuery	+= " FROM	"+RetSqlName("SE1")+"	SE1 "
		cQuery	+= " WHERE	SE1.E1_IDCNAB	<> '' "
		cQuery	+= " AND	SE1.D_E_L_E_T_	= ''  "
		cQuery	+= " GROUP	BY SE1.E1_IDCNAB "
		cQuery	+= " HAVING	COUNT(*) > 1 "
	Else	
		cQuery	:= " SELECT	SE1.E1_NUMBCO AS CHAVE , COUNT(*) AS QUANTIDADE "
		cQuery	+= " FROM	"+RetSqlName("SE1")+"	SE1 "
		cQuery	+= " WHERE	SE1.E1_EMISSAO	>= '20100601' "
		cQuery	+= " AND	SE1.E1_PORTADO	= '"+_cNumBanco+"' "
		cQuery	+= " AND	SE1.E1_AGEDEP	= '"+_cAgencia+"' "
		cQuery	+= " AND	SE1.E1_CONTA	= '"+_cContaC+"' "
		cQuery	+= " AND	SE1.E1_NUMBCO	<> '' "
		cQuery	+= " AND	SE1.D_E_L_E_T_	= ''  
		cQuery	+= " GROUP	BY SE1.E1_NUMBCO
		cQuery	+= " HAVING	COUNT(*) > 1 
	EndIf

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBIDC",.F.,.T.)

	DBSelectArea("TRBIDC")
	TRBIDC->(DBGoTop()) 

	If	!TRBIDC->(Eof())

		lRet := .T.
		If	lShowMsg

			MsgAlert("Foi detectado duplicidade de "+IIf(nTpValid==1,"IDCNAB","NOSSO NUMERO")+" na base de dados."+ CRLF +;
			"Não envie para o Banco o arquivo gerado ["+cArqRem+"]"	+ CRLF +;
			"Entre em contato com a area de Tecnologia." 			+ CRLF +;
			" ","Integridade Cnab" )

		EndIf

	EndIf

	If	lRet .And. ( nOpcA == 2 .Or. nOpcA == 3 )

		While 	!TRBIDC->(Eof())
			aAdd( aIdCnab , { TRBIDC->CHAVE , TRBIDC->QUANTIDADE } )
			TRBIDC->(DBSkip())
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia e-mail.														     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	nOpcA == 2
			//LjMsgRun("Enviando e-mail de notificação, aguarde...","Integridade Cnab",{ || fMailCnab(aIdCnab,cArqRem,nTpValid) , CLR_HRED })
		EndIf
		

	EndIf

	TRBIDC->(DBCloseArea())

Return(lRet)


/*/{Protheus.doc} OmVlrCnb
Retorna o valor do Titulo a ser enviado no arquivo Cnab.
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function OmVlrCnb()

Return( SE1->( E1_SALDO + E1_MULTA + E1_JUROS + E1_ACRESC - E1_DECRESC - E1_DESCONT ) )


/*/{Protheus.doc} OmDigBar
Monta a Linha Digitavel e o Codigo de Barras para o Boleto
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function OmDigBar(cBanco,cAgencia,cConta,cCarteira,dVencto,nValBoleto,_cNossoNum)

	Local cCodBar 	:= "" 
	Local cCodBrAx	:= ""
	Local dBaseVento:= CtoD("07/10/1997")

	Local cMoedaBar  := ""
	Local cDacBar	 := ""
	Local cVenctoBar := ""
	Local cValorBar	 := ""
	Local cAgeCede	 := ""
	Local cContaCed	 := ""
	Local cCartCed	 := ""
	Local cCpoLivre	 := ""
	Local cSistBar	 := ""
	Local cCliBar	 := ""
	Local cNossNuBar := ""
	Local cTpCobBar	 := ""
	Local cBarSemDig := ""
	Local cLinDigita := ""
	Local cLinDigAux := ""
	Local cDigLinDig := ""
	Local cAno := ""
	Local cNroOperacao := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CAMPO DE ATÉ CONTEÚDO OBS                                               	 ³
	//³Banco 	001 003 422 Fixo                                                 ³
	//³Moeda 	004 004 9 ou 0 9 para real 0 para outras moedas                  ³
	//³Dac 		005 005 Dígito de autoconferência do código de barras (módulo 11)³
	//³Fator 	006 009 Fator do vencimento Formato do vencimento                ³
	//³Valor 	010 019 Valor do título Reais ou Quantidade de moeda             ³
	//³Sistema 	020 044 Campo Livre                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Codigo da Moeda. 9 = Real.										         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMoedaBar := "9"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fator de vencimento.											         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cVenctoBar:= StrZero( ( dVencto - dBaseVento ) , 4 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valor do compromisso.											         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cValorBar	:= StrZero( nValBoleto * 100 , 10 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campo Livre.													         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Do	Case
		Case	cBanco == "001" .OR. cBanco == "04 "

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³20 a 23 4 Agência Cedente (Sem o digito verificador, completar com zeros a esquerda quando necessário)  ³
			//³24 a 25 2 Carteira																					   ³
			//³26 a 36 10 Número do Nosso Número(Sem o digito verificador)											   ³
			//³37 a 43 7 Conta do Cedente (Sem o digito verificador, completar com zeros a esquerda quando necessário) ³
			//³44 a 44 1 Zero																						   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			cAgeCede	:= StrZero( Val(cAgencia) 		, 4  )
			cCartCed	:= AllTrim(GetNewPar("CP_001CART","17"))
			cConven	   	:= AllTrim(GetNewPar("CP_001CONV","2918625"))
			cNossNuBar	:= StrZero( Val( _cNossoNum ) 	, 10 )
			cContaCed	:= StrZero( Val(cConta),7)
			cTpCobBar	:= "0"
			cCpoLivre	:= "000000"+cConven+cNossNuBar+cCartCed


		Case	cBanco == "341" .OR. cBanco == "03 "

	
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³20 a 23 4 Agência Cedente (Sem o digito verificador, completar com zeros a esquerda quando necessário)  ³
            //³24 a 25 3 Carteira                                                                                                                           ³
            //³26 a 36 8 Número do Nosso Número(Sem o digito verificador)                                             ³
            //³37 a 43 7 Conta do Cedente (Sem o digito verificador, completar com zeros a esquerda quando necessário) ³
            //³44 a 44 1 Zero                                                                                                                               ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            
            
            cCartCed    := StrZero( Val(cCarteira), 3  )                                
            cNossNuBar  := StrZero( Val( _cNossoNum )     , 8 )
//            cDacNuBar   := alltrim(str(U_Modulo10(Alltrim(cAgeCede) + alltrim(cContaCed) + cCartCed + alltrim(_cNossoNum))))
//            cDacNuBar	:= U_OmDig341(cAgeCede + cContaCed + cCartCed + StrZero(Val(_cNossoNum),8))    
            
            cAgeCede    := StrZero( Val(cAgencia) , 4  )
            cContaCed   := StrZero( Val(cConta) , 5  )
            
            cDacNuBar	:= alltrim(str(U_OmMod10(cAgeCede + cContaCed + cCartCed + cNossNuBar)))
            
            cDacConta   := alltrim(str(U_Modulo10(Alltrim(cAgeCede) + alltrim(cContaCed))))
            cTpCobBar   := "000"          
            cCpoLivre   := cCartCed + cNossNuBar + cDacNuBar + cAgeCede + cContaCed + cDacConta + cTpCobBar

		
				
	EndCase
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculo do DAC.													         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF cBanco == "341" .OR. cBanco == "03 "
		cBarSemDig 	:= cBanco + cMoedaBar + cVenctoBar + cValorBar + cCartCed + cNossNuBar + cDacNuBar + Alltrim(cAgeCede) + cConta + cDacConta + "000"
		
		cDacBar		:= ALLTRIM(STR(mod11CB(cBarSemDig)))
		//Modulo11( cBarSemDig , 2 , 9 )
		
		IF cDacBar == "0" .OR. cDacBar == "10" .OR. cDacBar == "11" 
			cDacBar := "1"
			
			If	cDacBar == "0" .Or. cDacBar == "10"
				cDacBar := "1"
			EndIf
		ENDIF
	ELSE
		cBarSemDig 	:= cBanco + cMoedaBar + cVenctoBar + cValorBar + cCpoLivre
		cDacBar		:= Modulo11( cBarSemDig , 2 , 9 )
	
		If	cDacBar == "0" .Or. cDacBar == "10"
			cDacBar := "1"
		EndIf
	ENDIF 
	
//	IF cBanco == "341" .OR. cBanco == "03 "
//		cDacBar := Modulo11( cBarSemDig , 2 , 9 )
//		IF cDacBar == "0" .OR. cDacBar == "10" .OR. cDacBar == "11" 
//			cDacBar := "1"
//			
//			If	cDacBar == "0" .Or. cDacBar == "10"
//				cDacBar := "1"
//			EndIf
//		ENDIF 
//	ENDIF 

	
//	If cBanco == "341" .OR. cBanco == "03 "
//		cBarSemDig 	:= cBanco + cDacBar + cMoedaBar + cVenctoBar + cValorBar + cCpoLivre
////		cDacBar		:= Modulo10( cBarSemDig , 2 , 9 )
//	ELSE
//		cDacBar		:= Modulo11( cBarSemDig , 2 , 9 )
//	EndIF	
	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Codigo de Barras.												         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodBar  := cBanco + cMoedaBar + cDacBar + cVenctoBar + cValorBar + cCpoLivre
	cCodBrAx  := cBanco + cMoedaBar + cVenctoBar + cValorBar + cCpoLivre

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Linha Digitavel.									         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1º CAMPO - Composto pelo código do banco (sem o dígito verificador = 422), código da moeda, as cinco ³
	//³primeiras posições do campo livre, ou seja, da posição 20 à 24 do código de barras, e mais um dígito ³
	//³verificador deste campo. Após os 5 primeiros dígitos deste campo separar o conteúdo por um ponto (.).³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLinDigAux 	:= cBanco + cMoedaBar + SubStr(cCpoLivre,1,5)
	cDigLinDig	:= U_OmMod10(cLinDigAux)
	cLinDigAux 	:= cLinDigAux + StrZero(cDigLinDig,1)

	cLinDigita 	+= SubStr(cLinDigAux,1,5) + "." + SubStr(cLinDigAux,6,Len(cLinDigAux) - 5) + Space(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³2º CAMPO - Composto pelas posições 6 à 15 do campo livre, ou seja, da posição 25 à 34 do código de³
	//³barras e mais um dígito verificador deste campo. Após os 5 primeiros dígitos deste campo separar o³
	//³conteúdo por um ponto (.).                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// DAC, os dados “AGÊNCIA / CONTA(sem DAC) / CARTEIRA / NOSSO NÚMERO”
	cLinDigAux 	:= SubStr(cCpoLivre,6,10)
//	cLinDigAux 	:= SubStr(cAgeCede + cContaCed + cCartCed + cNossNuBar,6,10)
	cDigLinDig	:= U_OmMod10(cLinDigAux)
	cLinDigAux	+= StrZero(cDigLinDig,1)

	cLinDigita 	+= SubStr(cLinDigAux,1,5) + "." + SubStr(cLinDigAux,6,Len(cLinDigAux) - 5) + Space(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³3º CAMPO - Composto pelas posições 16 à 25 do campo livre, ou seja, da posição 35 à 44 do código de³
	//³barras, e mais um dígito verificador deste campo. Após os 5 primeiros dígitos deste campo separar o³
	//³conteúdo por um ponto (.).                                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLinDigAux 	:= SubStr(cCpoLivre,16,10)
	cDigLinDig	:= U_OmMod10(cLinDigAux)
	cLinDigAux	+= StrZero(cDigLinDig,1)

	cLinDigita 	+= SubStr(cLinDigAux,1,5) + "." + SubStr(cLinDigAux,6,Len(cLinDigAux) - 5) + Space(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³4º CAMPO - Composto pelo dígito de autoconferência do código de barras.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDacBar := ALLTRIM(STR(mod11CB(cCodBrAx)))
	cLinDigAux 	:= cDacBar

	cLinDigita 	+= cLinDigAux + Space(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³5º CAMPO - Composto pelo vencimento (fator a ser calculado conforme data de vencimento posição do      ³
	//³código de barras 06 à 09 e valor nominal do documento pela posições 10 à 19 do código de barras, (sem a³
	//³supressão de zeros a esquerda e sem edição de ponto e vírgula).                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLinDigAux 	:= SubStr(cCodBar,06,04) + SubStr(cCodBar,10,10)

	cLinDigita 	+= cLinDigAux

Return( { cCodBar , cLinDigita } )


/*/{Protheus.doc} OmDig237
Calcula o Digito do Codigo de Barras do Boleto Bradesco. 
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function OmDig237(cCarteira,cNossoNum)

	Local cDig237 	:= ""
	Local aTabPeso	:= {2,7,6,5,4,3,2,7,6,5,4,3,2}
	Local nI		:= 0
	Local cNumero	:= cCarteira+cNossoNum
	Local nSomaAux	:= 0
	Local nRestoAux	:= 0
	Local nDigAux	:= 0

	For	nI	:= 1 To Len(cNumero)
		nSomaAux += ( Val( SubStr(cNumero,nI,1) ) * aTabPeso[nI] )
	Next nI

	nRestoAux 	:= ( nSomaAux % 11 )
	nDigAux		:= ( 11 - nRestoAux )

	If		nDigAux == 10
		cDig237 := "P"
	ElseIf	nDigAux == 11
		cDig237 := "0"
	Else
		cDig237 := StrZero(nDigAux,1)
	EndIf

Return(cDig237)


/*/{Protheus.doc} OmMod07
Calculo do Digito Verrificador Modulo 07.
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function OmMod07(nNumeroAux)

	Local cAux1		:= ""
	Local nAux1 	:= 0
	Local nPosPonto	:= 0
	Local nDigito   := 0

	cAux1 		:= AllTrim( Str(( nNumeroAux / 7 )) )
	nPosPonto	:= At( "." , cAux1 )
	If	nPosPonto	> 0
		cAux1	:= SubStr( cAux1 , 1 , nPosPonto - 1 )
	EndIf

	nAux1	:= Val(cAux1) * 7

	nDigito := ( nNumeroAux - nAux1 )

Return(AllTrim(Str(nDigito)))


/*/{Protheus.doc} OmMod10
Monta o Codigo de Barras para Boleto Safra.
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function OmMod10(cData)

	LOCAL L,D,P := 0
	LOCAL B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End

Return(D)


/*/{Protheus.doc} OmInfBol
Funcao generica que retorna dados a serem impressos no Boleto. 
@author Jonatas Oliveira | www.compila.com.br
@since 25/08/2017
@version 1.0
/*/
User Function OmInfBol(cFilialTit,cPrefixo,cNumTit,cParcela,cTipoTit,lCobJuros,lProrroga,dDtVencto,lMostraMsg,cLogErro,lSegVia,cCanalSol,lTitProv,cOrigAl)

	Local aAreaSE1		:= SE1->(GetArea())             
	Local aDadosTit 	:= {}
	Local cValAbati		:= ""
	Local nValOrigi		:= 0
	Local nValAbati		:= 0
	Local nValJuros		:= 0
	Local nValAcresc	:= 0
	Local nValDecres	:= 0
	Local nValBoleto	:= 0
	Local dVenctoBol	:= Nil
	Local aDadosBar		:= {}
	Local cCodAgen		:= ""
	Local cDigAgen		:= ""
	Local cCodConta		:= ""
	Local cDigConta		:= ""
	Local nPosAux		:= 0
	Local aTitulo		:= 0
	Local dVencReaOri	:= Nil
	Local cBkpFilAnt	:= cFilAnt
	Local aItemSoli		:= Array(6)
	Local cNSSafra		:= ""
	Local cNSSafraBrad	:= ""
	Local aMsgBOL 		:= {}
	Local cCodEmpCob	:= ""
	Local _cCodEmp, _cCodFil
	Local aRetCorr		:= {} 	


	Default	lCobJuros	:= .T.
	Default	lProrroga	:= .F.
	Default	dDtVencto	:= Nil
	Default	lMostraMsg	:= .T.
	Default	cLogErro	:= ""
	Default	lSegVia		:= .F.
	Default	lTitProv    := .F.
	Default cOrigAl		:= "000003"

	Private lMsHelpAuto := .T. //.F. // para nao mostrar os erro na tela
	Private lMsErroAuto := .F. //.F. // inicializa como falso, se voltar verdadeiro e' que deu erro



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na Filial da Nota ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil		:= SM0->M0_CODFIL

	IF _cCodEmp+_cCodFil <> _cCodEmp+cFilialTit
		CFILANT := cFilialTit
		SM0->(DBGOTOP())
		opensm0(_cCodEmp+CFILANT)
	ENDIF


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aItemSoli:														         ³
	//³ [01] - Chave do Titulo.												     ³
	//³ [02] - Vencimento Antigo.											     ³
	//³ [03] - Vencimento Novo.												     ³
	//³ [04] - Valor Antigo.												     ³
	//³ [05] - Valor Novo.													     ³
	//³ [06] - Valor de Juros.												     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A fun‡„o SomaAbat reabre o SE1 com outro nome pela ChkFile, pois 		 ³
	//³ o filtro do SE1, desconsidera os abatimentos					 		 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//SomaAbat("","","","R")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Titulo a Receber.									         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSelectArea("SE1")                                              
	SE1->(DBSetOrder(1)) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	// Paulo da Mata (COMPILA) - 22/08/2012 - Incluída na pesquisa o TIPO do titulo
	//If	!SE1->(DBSeek(cFilialTit+cPrefixo+cNumTit+cParcela))
	If	!SE1->(DBSeek(cFilialTit + cPrefixo + cNumTit + cParcela + cTipoTit))
		cLogErro := "O título ["+cFilialTit + cPrefixo + cNumTit + cParcela+"] nao foi encontrado."
		If	lMostraMsg
			MsgInfo(cLogErro,"Boleto")
		EndIf
		RestArea(aAreaSE1)
		Return()
	EndIf

	// Paulo da Mata (COMPILA) - 22/08/2012 - Incluída na pesquisa o TIPO do titulo
	//While	!SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == cFilialTit+cPrefixo+cNumTit+cParcela
	While	!SE1->(Eof()) .And. SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO) == cFilialTit + cPrefixo + cNumTit + cParcela + cTipoTit
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no Cliente.											         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DBSelectArea("SA1")
		SA1->(DBSetOrder(1))
		If	!SA1->(DBSeek(xFilial("SA1")+SE1->(E1_CLIENTE + E1_LOJA)))
			cLogErro := "O cliente+loja ["+SE1->(E1_CLIENTE + E1_LOJA)+"] não foi encontrado."
			If	lMostraMsg
				MsgInfo(cLogErro,"Boleto")
			EndIf             
			RestArea(aAreaSE1)
			Return()
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha abatimento.										         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	SE1->E1_TIPO $ MVABATIM
			cValAbati	:= Str(SE1->E1_SALDO,17,2)
			SE1->(DBSkip())
			Loop
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o titulo eh provisorio.								         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
			SE1->(DBSkip())
			Loop
		EndIf

		If Empty(SE1->E1_NUMBCO)
			u_OmNumBco( .F. )	
		endif	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha Nosso Numero criado.								         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	Empty(SE1->E1_NUMBCO)
			cLogErro :="Em processo de Faturamento - Boleto disponível em até 4 dias úteis."
			//cLogErro := "O título não possui Nosso Número."
			If	lMostraMsg
				MsgInfo(cLogErro,"Boleto")
			EndIf             
			RestArea(aAreaSE1)
			Return()
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha IDCNAB criado.								         	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	Empty(SE1->E1_IDCNAB)
			U_OmIdCnab()
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no Banco.											         	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DBSelectArea("SA6")
		SA6->(DBSetOrder(1))
		If	!SA6->(DBSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))
			cLogErro := "Não foi encontrado o Banco+Agencia+Conta ["+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)+"]."
			If	lMostraMsg
				MsgInfo(cLogErro,"Boleto")
			EndIf             
			RestArea(aAreaSE1)
			Return()
		EndIf


		lAchouSEE := .F.
		DBSelectArea("SEE")
		SEE->(DBSetOrder(1))
		If	SEE->(DBSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))
			lAchouSEE := .T.
		Else
			lAchouSEE := .F.
		EndIf

		if !lAchouSEE
			cLogErro := "Não foi encontrado o Banco+Agencia+Conta ["+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)+"]."
			If	lMostraMsg
				MsgInfo(cLogErro,"Boleto")
			EndIf             
			RestArea(aAreaSE1)
			Return()
		EndIf             

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Banco possui configuracao de Boleto.				         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

		If	!( SE1->E1_PORTADO $ "341/001/03 /04 " )//"237/422/399/001/246" ) 
			cLogErro := "O banco ["+SE1->E1_PORTADO+"] não possui layout de boleto."
			If	lMostraMsg
				MsgInfo(cLogErro,"Boleto")
			EndIf 
			RestArea(aAreaSE1)
			Return(.F.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o valor do Documento.									         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//nValOrigi	:= xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,1,,2)
		nValOrigi	:= xMoeda((SE1->E1_SALDO+0-SE1->E1_SDDECRE),SE1->E1_MOEDA,1,,2)
		nValJuros	:= SE1->E1_SDACRES

		If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
			nValAbati	:=	SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL,,)
		EndIf

		dVencReaOri	:= SE1->E1_VENCREA

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ aItemSoli:														         ³
		//³ [01] - Chave do Titulo.												     ³
		//³ [02] - Vencimento Antigo.											     ³
		//³ [04] - Valor Antigo.												     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aItemSoli[01] := SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		aItemSoli[02] := dVencReaOri
		aItemSoli[04] := nValOrigi

		If	lProrroga

			dVenctoBol := DataValida(dDtVencto)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a data que foi prorrogado e maior que o vencimento real.	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	SE1->E1_VENCREA > dVenctoBol
				cLogErro := "O vencimento real [" + right( dtos(SE1->E1_VENCREA),2) +"/"+ substr( dtos(SE1->E1_VENCREA),5,2) +"/"+ left( dtos(SE1->E1_VENCREA),4)  /*DtoCY(SE1->E1_VENCREA,4)*/ + "] está maior que a data que está sendo prorrogado [" + right( dtos(dVenctoBol),2) +"/"+ substr( dtos(dVenctoBol),5,2) +"/"+ left( dtos(dVenctoBol),4)  + "]."
				If	lMostraMsg
					MsgInfo(cLogErro,"Boleto")
				EndIf         
				RestArea(aAreaSE1)
				Return()
			EndIf

			If	lCobJuros
				aRetCorr := U_CCalJuros(SE1->(RECNO()),,dDataBase )
				nValJuros := aRetCorr[2] + aRetCorr[3]
				//nValJuros := U_OmCalJur(SE1->E1_VENCTO,dVenctoBol,SE1->E1_VALOR,.T.,SE1->(Recno()))[03]
			EndIf

			nValAcresc := Round( ( nValJuros ) , TamSx3("E1_ACRESC")[02] )

			If	nValAcresc > 0 .And. SE1->E1_DECRESC > 0
				cLogErro := "Esse título possui decréscimo e não pode ser prorrogado. Para prorrogá-lo, é necessário retirar o decréscimo ou não cobrar juros."
				If	lMostraMsg
					MsgInfo(cLogErro,"Boleto")
				EndIf             
				RestArea(aAreaSE1)
				Return(.F.)
			EndIf          

			If	lMostraMsg .And. nValAcresc > 0 .And. !TmkOk("O valor de acréscimo em juros e multa será ["+Transform(nValAcresc,PesqPict("SE1","E1_ACRESC"))+"]. Deseja continuar?","Boleto")
				RestArea(aAreaSE1)
				Return(.F.)
			EndIf


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera dados no Titulo para gerar Instrucao Bancaria.					 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	!Empty(SE1->E1_FILIAL) .And. cFilAnt != SE1->E1_FILIAL
				cFilAnt := SE1->E1_FILIAL
			EndIf

			aTitulo := {	{"E1_FILIAL"	, SE1->E1_FILIAL 		, Nil },;
							{"E1_PREFIXO"	, SE1->E1_PREFIXO		, Nil },;
							{"E1_NUM"		, SE1->E1_NUM			, Nil },;
							{"E1_PARCELA"	, SE1->E1_PARCELA		, Nil },;
							{"E1_TIPO"		, SE1->E1_TIPO			, Nil },;			
							{"E1_CLIENTE"	, SE1->E1_CLIENTE		, Nil },;			
							{"E1_LOJA"		, SE1->E1_LOJA			, Nil },;			
							{"E1_VENCREA"	, dVenctoBol  			, Nil },;
							{"E1_ACRESC"	, nValAcresc  			, Nil }}


			lMsErroAuto	:= .F.
			MsExecAuto({|x,y| Fina040(x,y)},aTitulo,4) //Altera
			If	lMsErroAuto
				MostraErro()
				RestArea(aAreaSE1)
				Return(.F.)
			EndIf

			cFilAnt := cBkpFilAnt 

		Else

			dVenctoBol := SE1->E1_VENCREA

		EndIf

		nValBoleto := ( nValOrigi + nValJuros - nValAbati )

		nValBoleto := Round(NoRound(nValBoleto,3),2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ aItemSoli:														         ³
		//³ [03] - Vencimento Novo.												     ³
		//³ [05] - Valor Novo.													     ³
		//³ [06] - Valor de Juros.												     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aItemSoli[03] := SE1->E1_VENCREA
		aItemSoli[05] := nValBoleto
		aItemSoli[06] := nValJuros

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta a matriz com dados do Boleto.							         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDadosTit := Array(P_NTAMBOL)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados genericos para todos os bancos.							         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
		aDadosTit[P_CLIENTE] 	:= SA1->A1_COD
		aDadosTit[P_LOJA] 		:= SA1->A1_LOJA
		aDadosTit[P_NOME] 		:= Left(AllTrim(SA1->A1_NOME),40) &&| Alterado por Fabio Sales  em 20130626
		aDadosTit[P_CNPJ] 		:= Transform( SA1->A1_CGC , PicPesFJ(SA1->A1_PESSOA) )
		aDadosTit[P_PESSOA] 	:= SA1->A1_PESSOA
		
		If	Empty(SA1->A1_ENDCOB)
			aDadosTit[P_ENDERECO]		:= AllTrim(SA1->A1_END)
			aDadosTit[P_NUMERO] 		:= ""
			aDadosTit[P_COMPLEMENTO]	:= AllTrim(SA1->A1_COMPLEM)
			aDadosTit[P_BAIRRO]	 	   	:= AllTrim(SA1->A1_BAIRRO)
			aDadosTit[P_CEP]			:= Transform(SA1->A1_CEP,"@R 99999-999")
			aDadosTit[P_MUNICIPIO]		:= AllTrim(SA1->A1_MUN)
			aDadosTit[P_ESTADO]			:= AllTrim(SA1->A1_EST)
		Else
			aDadosTit[P_ENDERECO]		:= AllTrim(SA1->A1_ENDCOB)
			aDadosTit[P_NUMERO] 		:= ""
			aDadosTit[P_COMPLEMENTO]	:= ""//AllTrim(SA1->A1_COMCOB)
			aDadosTit[P_BAIRRO]	    	:= AllTrim(SA1->A1_BAIRROC)
			aDadosTit[P_CEP]			:= Transform( SA1->A1_CEPC , "@R 99999-999" )
			aDadosTit[P_MUNICIPIO]		:= AllTrim(SA1->A1_MUNC)
			aDadosTit[P_ESTADO]			:= AllTrim(SA1->A1_ESTC)
		EndIf
		
		aDadosTit[P_BANCO]		:= SE1->E1_PORTADO
		aDadosTit[P_NUMDOC]		:= SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)                     //SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		aDadosTit[P_ACEITE]		:= "N"
		aDadosTit[P_ESPECIE]	:= "R$"
		aDadosTit[P_EMISSAO]	:= right( dtos(SE1->E1_EMISSAO),2) +"/"+ substr( dtos(SE1->E1_EMISSAO),5,2) +"/"+ left( dtos(SE1->E1_EMISSAO),4)      //    DtoCY(SE1->E1_EMISSAO,4) 
		aDadosTit[P_VENCIMENTO]	:= right( dtos( dVenctoBol),2) +"/"+ substr( dtos( dVenctoBol),5,2) +"/"+ left( dtos(dVenctoBol),4)    //DtoCY(dVenctoBol,4)
		aDadosTit[P_DATPROC]	:= right( dtos( dDataBase),2) +"/"+ substr( dtos( dDataBase),5,2) +"/"+ left( dtos(dDataBase),4)    //DtoCY(dDataBase,4)
		aDadosTit[P_VALOR]		:= Transform(nValBoleto,PesqPict("SE1","E1_VALOR"))
		aDadosTit[P_CODCEDENTE]	:= "XXXXXXXX"                


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca Mensagem a ser impressa no Boleto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aMsgBOL	:= OmMsgBol("", SA1->A1_COD, SA1->A1_LOJA, SE1->E1_PEDIDO, SE1->E1_PARCELA, SE1->(RECNO()))

		aDadosTit[P_INSTRUCAO1]	:= aMsgBOL[1]
		aDadosTit[P_INSTRUCAO2]	:= aMsgBOL[2]
		aDadosTit[P_INSTRUCAO3]	:= aMsgBOL[3]
		aDadosTit[P_INSTRUCAO4]	:= aMsgBOL[4]
		aDadosTit[P_INSTRUCAO5]	:= aMsgBOL[5]		


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mensagem de Juros.												         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     

		If dVenctoBol > dVencReaOri .And. nValJuros <= 0
			aDadosTit[P_MSGJUROS]	:= "Isento de Juros e Multa até o vencimento. Vencimento original: "+ right( dtos(SE1->E1_VENCTO),2) +"/"+ substr( dtos(SE1->E1_VENCTO),5,2) +"/"+ left( dtos(SE1->E1_VENCTO),4) +"."  //   DtoCY(SE1->E1_VENCTO,4)+"." 
		ElseIf	lProrroga .And. dVenctoBol > dVencReaOri .And. nValJuros > 0
			aDadosTit[P_MSGJUROS]	:= "O valor original é de R$ "+Alltrim(Transform(nValOrigi,PesqPict("SE1","E1_VALOR")))+" e o valor do acréscimo em juros/multa é de R$ "+Alltrim(Transform( nValBoleto - nValOrigi ,PesqPict("SE1","E1_VALOR")))+"."
		Else
			aDadosTit[P_MSGJUROS]	:= ""
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Definicao da Agencia e Conta.									         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodAgen		:= Substr(SA6->A6_AGENCIA,1,4)
		
		cDigAgen		:= SA6->A6_DVAGE  //sivaldo 31082017

		nPosAux			:= At("-",SA6->A6_NUMCON)
		
		If	nPosAux > 0
			cCodConta		:= AllTrim( SubStr(SA6->A6_NUMCON,1,nPosAux-1) )			
			nqtdCrt			:= Len(Alltrim(SA6->A6_NUMCON)) - nPosAux		
			cDigConta		:= AllTrim(SubStr(SA6->A6_NUMCON,nPosAux+1,nqtdCrt))
		Else
			cCodConta		:= AllTrim(SA6->A6_NUMCON)
			cDigConta		:=  AllTrim(SA6->A6_DVCTA) 
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados especificos por banco.									         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do	Case

			Case	aDadosTit[P_BANCO] == "341" .or. aDadosTit[P_BANCO] == "03 "
			
				IF aDadosTit[P_BANCO] == "03 "
					aDadosTit[P_BANCO] := "341"
				ENDIF 
				
				aDadosTit[P_NOMEBCO]		:= "Itau"
				aDadosTit[P_NUMEROBCO]		:= "341-7"
				aDadosTit[P_LOGOBCO]		:= "Logo_Itau.bmp"
				aDadosTit[P_OPCPRINT]		:= "LOGO"
				aDadosTit[P_CARTEIRA]		:= AllTrim(GetNewPar("CP_341CART","109"))
				aDadosTit[P_AGENCIA]        := cCodAgen
                aDadosTit[P_CONTA]          := "/" + cCodConta +"-"+ cDigConta
                
                _cDigNS						 := U_OmDig341(cCodAgen+cCodConta+aDadosTit[P_CARTEIRA]+StrZero(Val(SE1->E1_NUMBCO),8))            
                aDadosTit[P_NOSSONUMERO]     := aDadosTit[P_CARTEIRA]+"/"+StrZero(Val(SE1->E1_NUMBCO),8)+"-"+_cDigNS
	             
	            aDadosBar                    := U_OmDigBar(aDadosTit[P_BANCO],cCodAgen,cCodConta,aDadosTit[P_CARTEIRA],CtoD(aDadosTit[P_VENCIMENTO]),nValBoleto,StrZero(Val(SE1->E1_NUMBCO),08),cDigConta)
	            aDadosTit[P_CODBARRAS]       := aDadosBar[01]
	            aDadosTit[P_LINHADIG]        := aDadosBar[02]
	            aDadosTit[P_DIGITOCB]        := ""                                                
	            aDadosTit[P_ESPECIEDOC]      := SE1->E1_TIPO
	            aDadosTit[P_MSGLOCPAG1]      := "Até o vencimento pagar preferencialmente no Itau" 
	            aDadosTit[P_MSGLOCPAG2]      := "Após o vencimento, pagar somente no Itaú" 
	            aDadosTit[P_CEDENTE]         := AllTrim(SM0->M0_NOMECOM)
	            aDadosTit[P_CNPJCED]         := Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")
	            aDadosTit[P_USUBANCO]        := ""
	            aDadosTit[P_AVALISTA]        := ""                              
	            aDadosTit[P_ENDCOB]          := Left(AllTrim(SM0->M0_ENDCOB)+", "+AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+"-"+AllTrim(SM0->M0_ESTCOB),74) && Incluído por Fabio Sales em 

			Case	aDadosTit[P_BANCO] == "001" .OR. aDadosTit[P_BANCO] =="04 "
			
				IF aDadosTit[P_BANCO] =="04 "
					aDadosTit[P_BANCO] := "001"
				ENDIF 
				
				aDadosTit[P_NOMEBCO]		:= "BANCO DO BRASIL"
				aDadosTit[P_NUMEROBCO]		:= "001-9"
				aDadosTit[P_LOGOBCO]		:= "logobb.bmp"
				aDadosTit[P_OPCPRINT]		:= "LOGO"
				aDadosTit[P_CARTEIRA]		:= AllTrim(GetNewPar("CP_001CART","17")) 																				
				aDadosTit[P_AGENCIA]		:= Alltrim(cCodAgen)+"-"+Alltrim(cDigAgen)
				aDadosTit[P_CONTA]			:= "/"+Alltrim(cCodConta)+"-"+Alltrim(cDigConta)
				aDadosTit[P_NOSSONUMERO] 	:= AllTrim(GetNewPar("CP_001CONV","2918625"))+StrZero(Val(right(ALLTRIM(SE1->E1_NUMBCO),10)),10) // sivaldo 31082017
				aDadosBar					:= U_OmDigBar(aDadosTit[P_BANCO],cCodAgen,cCodConta+cDigConta,"00",CtoD(aDadosTit[P_VENCIMENTO]),nValBoleto,StrZero(Val(right(ALLTRIM(SE1->E1_NUMBCO),10)),10))
				aDadosTit[P_CODBARRAS]		:= aDadosBar[01]
				aDadosTit[P_LINHADIG]		:= aDadosBar[02]
				aDadosTit[P_DIGITOCB]		:= ""                                                
				aDadosTit[P_ESPECIEDOC]		:= "DM" 
				aDadosTit[P_ESPECIE]		:= "R$" 
				aDadosTit[P_MSGLOCPAG1]		:= "Pagar em qualquer agência bancária até o vencimento" 
				aDadosTit[P_MSGLOCPAG2]		:= "ou canais eletrônicos do Banco do Brasil" 
				aDadosTit[P_CEDENTE]		:= AllTrim(SM0->M0_NOMECOM)
				aDadosTit[P_CNPJCED]		:= Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")
				aDadosTit[P_USUBANCO]		:= ""
				aDadosTit[P_AVALISTA]		:= "" 					
				aDadosTit[P_ENDCOB]			:= Left(AllTrim(SM0->M0_ENDCOB)+", "+AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+"-"+AllTrim(SM0->M0_ESTCOB),74) && Incluído por Fabio Sales em 20130626

		EndCase

		aDadosTit[P_INSTRUCAO5]	:= IIF(EMPTY(aDadosTit[P_INSTRUCAO5]),"",aDadosTit[P_INSTRUCAO5])
		aDadosTit[P_INSTRUCAO6]	:= IIF(EMPTY(aDadosTit[P_INSTRUCAO6]),"",aDadosTit[P_INSTRUCAO6])
		aDadosTit[P_INSTRUCAO7]	:= IIF(EMPTY(aDadosTit[P_INSTRUCAO7]),"",aDadosTit[P_INSTRUCAO7])
		aDadosTit[P_INSTRUCAO8]	:= IIF(EMPTY(aDadosTit[P_INSTRUCAO8]),"",aDadosTit[P_INSTRUCAO8])


		SE1->(DBSkip())
	EndDo


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Filial ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	IF _cCodEmp + _cCodFil <> _cCodEmp + cFilialTit
		CFILANT := _cCodFil
		SM0->(DBGOTOP())
		opensm0(_cCodEmp + CFILANT)			 			
	ENDIF 
	

	RestArea(aAreaSE1)

Return(aDadosTit)


/*/{Protheus.doc} OmPontBol
Imprime linha pontilhada no objeto oPrint. 
@version 1.0
/*/
User Function OmPontBol(oPrint,nLinha)

	Local nCol := 0

	For	nCol := 100 To 2300 Step 50
		oPrint:Line( nLinha , nCol , nLinha , nCol+30 )
	Next nX

Return()


/*/{Protheus.doc} OmCabBol
Imprime Cabecalho do Boleto no objeto oPrint. 
@version 1.0
/*/
User Function OmCabBol(oPrint,aLinhaBol,nLinha)

	Local oFont8  := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont14 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont21 := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:Line ( nLinha+0150 , 550 , nLinha+0070 , 550 )
	oPrint:Line ( nLinha+0150 , 770 , nLinha+0070 , 770 )

	If		aLinhaBol[P_OPCPRINT] == "LOGO"
		oPrint:SayBitmap  ( nLinha+015 , 0110 , aLinhaBol[P_LOGOBCO] , 420 , 140 )
	ElseIf	aLinhaBol[P_OPCPRINT] == "NOME"
		oPrint:Say  ( nLinha+084 , 100 , aLinhaBol[P_NOMEBCO] 				, oFont14 )
	EndIf

	oPrint:Say  ( nLinha+0075 , 0567 , aLinhaBol[P_NUMEROBCO]					, oFont21 )

	oPrint:Say  ( nLinha+0084 , 1900 , "Comprovante de Entrega"					, oFont10)
	oPrint:Line ( nLinha+0150 , 0100 , nLinha+0150 , 2300 )

	&& | Alterado por Fabio Sales em 20130625.

	oPrint:Say  ( nLinha+0150 , 100 , "Beneficiário"									, oFont8) && Alterado Por Fabio Sales em 20130709
	oPrint:Say  ( nLinha+0200 , 100 , aLinhaBol[P_CEDENTE]						, oFont10 )

	If Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO ABC B")
		oPrint:Say  ( nLinha+0150 , 1060 , "Agência/Código Beneficiário"					, oFont8) && | Alterado por Fabio Sales em 20130709 
		oPrint:Say  ( nLinha+0200 , 1060 , aLinhaBol[P_AGENCIA]+"/"+aLinhaBol[P_CONTA]	, oFont10)
	Else   
		oPrint:Say  ( nLinha+0150 , 1060 , "Agência/Código Beneficiário"					, oFont8) && | Alterado por Fabio Sales em 20130709 
		oPrint:Say  ( nLinha+0200 , 1060 , aLinhaBol[P_AGENCIA]+aLinhaBol[P_CONTA]	, oFont10)
	EndIF


	oPrint:Say  ( nLinha+0150 , 1510 , "Nro.Documento"							, oFont8)
	oPrint:Say  ( nLinha+0200 , 1510 , aLinhaBol[P_NUMDOC]						, oFont10)


	oPrint:Say  ( nLinha+0250 , 100 , "Pagador"									, oFont8)

	oPrint:Say  ( nLinha+0300 , 100 , aLinhaBol[P_NOME]							, oFont10)

	oPrint:Say  ( nLinha+0250 , 1060 , "Vencimento"								, oFont8)
//	oPrint:Say  ( nLinha+0300 , 1060 , aLinhaBol[P_VENCIMENTO]					, oFont10)
	oPrint:SayAlign( nLinha+0300	,1060, aLinhaBol[P_VENCIMENTO]					,oFont10,/*nWidth*/,/*nHeigth*/,/*nClrText*/,0/*nAlignHorz*/,0/*nAlignVert*/ )
	
	oPrint:Say  ( nLinha+0250 , 1510 , "Valor do Documento"						, oFont8)
	oPrint:Say  ( nLinha+0300 , 1550 , aLinhaBol[P_VALOR]						, oFont10)

	oPrint:Say  ( nLinha+0400 , 0100 , "Recebi(emos) o boleto/título"			, oFont10)
	oPrint:Say  ( nLinha+0450 , 0100 , "com as características acima."			, oFont10)
	oPrint:Say  ( nLinha+0350 , 1060 , "Data"									, oFont8)
	oPrint:Say  ( nLinha+0350 , 1410 , "Assinatura"								, oFont8)
	oPrint:Say  ( nLinha+0450 , 1060 , "Data"									, oFont8)
	oPrint:Say  ( nLinha+0450 , 1410 , "Entregador"								, oFont8)

	oPrint:Line ( nLinha+0250 , 100 , nLinha+0250,1900 )
	oPrint:Line ( nLinha+0350 , 100 , nLinha+0350,1900 )
	oPrint:Line ( nLinha+0450 ,1050 , nLinha+0450,1900 )
	oPrint:Line ( nLinha+0550 , 100 , nLinha+0550,2300 )

	oPrint:Line ( nLinha+0550 , 1050 , nLinha+0150,1050 )
	oPrint:Line ( nLinha+0550 , 1400 , nLinha+0350,1400 )
	oPrint:Line ( nLinha+0350 , 1500 , nLinha+0150,1500 )
	oPrint:Line ( nLinha+0550 , 1900 , nLinha+0150,1900 )

	oPrint:Say  ( nLinha+0165 , 1910 , "(  )Mudou-se"                          , oFont8)
	oPrint:Say  ( nLinha+0205 , 1910 , "(  )Ausente"                           , oFont8)
	oPrint:Say  ( nLinha+0245 , 1910 , "(  )Não existe nº indicado"            , oFont8)
	oPrint:Say  ( nLinha+0285 , 1910 , "(  )Recusado"                          , oFont8)
	oPrint:Say  ( nLinha+0325 , 1910 , "(  )Não procurado"                     , oFont8)
	oPrint:Say  ( nLinha+0365 , 1910 , "(  )Endereço insuficiente"             , oFont8)
	oPrint:Say  ( nLinha+0405 , 1910 , "(  )Desconhecido"                      , oFont8)
	oPrint:Say  ( nLinha+0445 , 1910 , "(  )Falecido"                          , oFont8)
	oPrint:Say  ( nLinha+0485 , 1910 , "(  )Outros(anotar no verso)"           , oFont8)

Return()



/*/{Protheus.doc} OmBodyBol
Imprime o corpo do Boleto.
@version 1.0
/*/
User Function OmBodyBol(oPrint,aLinhaBol,nLinIni,lSegVia,lReciboSac)

	Local oFont7    := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont8    := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont10   := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont11n  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont13n  := TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont14   := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont15n  := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont16   := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont21   := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)  
	Local oFontGrf	:= TFont():New("Courier",,09,,.F.,,,,.T.,.F.)

	Default lSegVia 	:= .F.
	Default lReciboSac 	:= .F.

	nLinIni -= 0384

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logo do Banco.										                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	aLinhaBol[P_OPCPRINT] == "LOGO"
		oPrint:SayBitmap  ( nLinIni + 330 , 0110 , aLinhaBol[P_LOGOBCO] , 420 , 140 )
	EndIf

	oPrint:Line ( nLinIni + 0472 , 0100 , nLinIni + 472 , 2300 )
	oPrint:Line ( nLinIni + 0472 , 0550 , nLinIni + 392 , 0550 )
	oPrint:Line ( nLinIni + 0472 , 0770 , nLinIni + 392 , 0770 )

	If	aLinhaBol[P_OPCPRINT] == "NOME"
		oPrint:Say  ( nLinIni + 0390 , 0100 , aLinhaBol[P_NOMEBCO]  , oFont14 )
	EndIf
	oPrint:Say  ( nLinIni + 0384 , 0567 , aLinhaBol[P_NUMEROBCO]	, oFont21 )
	If	lReciboSac
		  	
		oPrint:Say  ( nLinIni + 0406 , 1910 , "Recibo do Sacado" 	, oFont10 )
		
	Else
		oPrint:Say  ( nLinIni + 0406 , 0790 , aLinhaBol[P_LINHADIG] , oFont14 )
	EndIf

	oPrint:Line ( nLinIni + 0572 , 0100 , nLinIni + 0572 , 2300 )
	oPrint:Line ( nLinIni + 0672 , 0100 , nLinIni + 0672 , 2300 )
	oPrint:Line ( nLinIni + 0742 , 0100 , nLinIni + 0742 , 2300 )
	oPrint:Line ( nLinIni + 0812 , 0100 , nLinIni + 0812 , 2300 )

	oPrint:Line ( nLinIni + 0672 , 0500 , nLinIni + 0812 , 0500 )
	oPrint:Line ( nLinIni + 0742 , 0750 , nLinIni + 0812 , 0750 )
	oPrint:Line ( nLinIni + 0672 , 1000 , nLinIni + 0812 , 1000 )
	oPrint:Line ( nLinIni + 0672 , 1350 , nLinIni + 0742 , 1350 )
	oPrint:Line ( nLinIni + 0672 , 1550 , nLinIni + 0812 , 1550 )   

	oPrint:Say  ( nLinIni + 0472 , 0100 , "Local de Pagamento"                      				, oFont8  ) 
	oPrint:Say  ( nLinIni + 0476 , 0400 , aLinhaBol[P_MSGLOCPAG1]									, oFont10 ) 
	oPrint:Say  ( nLinIni + 0516 , 0400 , aLinhaBol[P_MSGLOCPAG2]									, oFont10 ) 

	oPrint:Say  ( nLinIni + 0472 , 1910 , "Vencimento"                                	   			, oFont8  ) 
//	oPrint:Say  ( nLinIni + 0512 , 2010 , aLinhaBol[P_VENCIMENTO]                       			, oFont10 )
	oPrint:SayAlign( nLinIni+0512	,2010, aLinhaBol[P_VENCIMENTO]									,oFont10,/*nWidth*/,/*nHeigth*/,/*nClrText*/,0/*nAlignHorz*/,0/*nAlignVert*/ )

	oPrint:Say  ( nLinIni + 0612 , 0300 , aLinhaBol[P_ENDCOB]	, oFont10 )
	                                                                                                                                                                                                                       
	oPrint:Say  ( nLinIni + 0572 , 1910 , "Agência/Código Beneficiário"                         	, oFont8  ) 
	oPrint:Say  ( nLinIni + 0612 , 2010 , aLinhaBol[P_AGENCIA]+aLinhaBol[P_CONTA] 					, oFont10 )
	
	oPrint:Say  ( nLinIni + 0672 , 0100 , "Data de Emissão"                                			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 0200 , right( dtos(dDataBase),2) +"/"+ substr( dtos(dDataBase),5,2) +"/"+ left( dtos(dDataBase),4)                              		, oFont10 )

	oPrint:Say  ( nLinIni + 0672 , 0505 , "Nro.Documento"                                  			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 0605 , aLinhaBol[P_NUMDOC]				            			, oFont10 )

	oPrint:Say  ( nLinIni + 0672 , 1005 , "Espécie Doc."                                   			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 1105 , aLinhaBol[P_ESPECIEDOC]                        			, oFont10 )

	oPrint:Say  ( nLinIni + 0672 , 1355 , "Aceite"                                         			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 1455 , aLinhaBol[P_ACEITE]		                    			, oFont10 )

	oPrint:Say  ( nLinIni + 0672 , 1555 , "Data do Processamento"                          			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 1655 , aLinhaBol[P_DATPROC]	                        			, oFont10 )

	If  Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO ABC B")
		oPrint:Say  ( nLinIni + 0672 , 1910 , "Nosso Número"                                   			, oFont8  ) 
		oPrint:Say  ( nLinIni + 0702 , 1920 , aLinhaBol[P_NOSSONUMERO]			            			, oFont10 )        
	Else
		
		
		oPrint:Say  ( nLinIni + 0672 , 1910 , "Nosso Número"                                   			, oFont8  ) 
		oPrint:Say  ( nLinIni + 0702 , 1930/*2010*/ , aLinhaBol[P_NOSSONUMERO]			            	, oFont10 )
		
		
	EndIf

	oPrint:Say  ( nLinIni + 0742 , 0100 , "Uso do Banco"                                   			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0772 , 0200 , aLinhaBol[P_USUBANCO]			            				, oFont10 )

	oPrint:Say  ( nLinIni + 0742 , 0505 , "Carteira"                                       			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0772 , 0605 , aLinhaBol[P_CARTEIRA]  		               				, oFont10 )

	oPrint:Say  ( nLinIni + 0742 , 0755 , "Espécie"                                        			, oFont8  )
	oPrint:Say  ( nLinIni + 0772 , 0855 , aLinhaBol[P_ESPECIE]	                        			, oFont10 ) 

	oPrint:Say  ( nLinIni + 0742 , 1005 , "Quantidade"                                   			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0742 , 1555 , "Valor"                                         			, oFont8  ) 

	oPrint:Say  ( nLinIni + 0742 , 1910 , "(=)Valor do Documento"                         			, oFont8 ) 
	oPrint:Say  ( nLinIni + 0772 , 2000 , aLinhaBol[P_VALOR]   										, oFont10 )

	If Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO SAFRA/BANCO ABC B")
		oPrint:Say  ( nLinIni + 0812 , 0100 , "Todas as informações  deste boleto são de exclusiva responsabilidade do Sacador avalista" , oFont7  ) 
	ElseIf  Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO ABC B")
		oPrint:Say  ( nLinIni + 0812 , 0100 , "Instruções" , oFont7  )  
	ElseIf !Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO SAFRA/BANCO ABC B")
		oPrint:Say  ( nLinIni + 0812 , 0100 , "Instruções/Texto de responsabilidade do Beneficiário" 		, oFont7  )  
	EndIf

	oPrint:Say  ( nLinIni + 0862 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO1])   						, oFont10 )
	oPrint:Say  ( nLinIni + 0912 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO2])   						, oFont10 )
	oPrint:Say  ( nLinIni + 0962 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO3])   						, oFont10 ) 
	oPrint:Say  ( nLinIni + 1012 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO4])   						, oFont10 ) 
	oPrint:Say  ( nLinIni + 1062 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO5])   						, oFont10 ) 
	oPrint:Say  ( nLinIni + 1112 , 0120 , Alltrim(aLinhaBol[P_MSGJUROS])   							, oFont10 ) 

	oPrint:Say  ( nLinIni + 0812 , 1910 , "(-)Desconto/Abatimento"  								, oFont8 ) 
	oPrint:Say  ( nLinIni + 0882 , 1910 , "(-)Outras Deduções"      								, oFont8 ) 
	oPrint:Say  ( nLinIni + 0952 , 1910 , "(+)Mora/Multa"           								, oFont8 ) 
	oPrint:Say  ( nLinIni + 1022 , 1910 , "(+)Outros Acréscimos"    								, oFont8 ) 
	oPrint:Say  ( nLinIni + 1092 , 1910 , "(-)Valor Cobrado"        								, oFont8 ) 

	oPrint:Say  ( nLinIni + 1162 , 0100 , "Pagador"                             						, oFont8  )  
	oPrint:Say  ( nLinIni + 1172 , 0500 , aLinhaBol[P_NOME]+" ("+aLinhaBol[P_CLIENTE]+"-"+aLinhaBol[P_LOJA]+")" 		, oFont10 )
	oPrint:Say  ( nLinIni + 1172 , 1880 , IIf(aLinhaBol[P_PESSOA] == "F" , "CPF: " , "CNPJ: " )+aLinhaBol[P_CNPJ] 	, oFont10 )

	oPrint:Say  ( nLinIni + 1222 , 0500 , aLinhaBol[P_ENDERECO]+"   "+aLinhaBol[P_NUMERO]+"   "+aLinhaBol[P_COMPLEMENTO]+" - "+aLinhaBol[P_BAIRRO] 												, oFont10 )
	oPrint:Say  ( nLinIni + 1272 , 0500 , aLinhaBol[P_CEP]+" "+aLinhaBol[P_MUNICIPIO]+" - "+aLinhaBol[P_ESTADO]   																				, oFont10 )	

	If Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO SAFRA/BANCO ABC B")
		oPrint:Say  ( nLinIni + 1335 , 0100 , "Sacador/Avalista "         								, oFont7  ) 
		oPrint:Say  ( nLinIni + 1335 , 0500 , aLinhaBol[P_AVALISTA]										, oFont10 )
	Else
		oPrint:Say  ( nLinIni + 1335 , 0100 , "Pagador/Avalista"         								, oFont7  ) 
		oPrint:Say  ( nLinIni + 1335 , 0500 , aLinhaBol[P_AVALISTA]										, oFont10 )
	EndIF

	oPrint:Say  ( nLinIni + 1335 , 1400 , "Autenticação Mecânica"   								, oFont7  )
	oPrint:Say  ( nLinIni + 1335 , 1850 , "Ficha de Compensação"      								, oFont8  )
	If	lSegVia
		oPrint:Say  ( nLinIni + 1335 , 2192 , "2a.Via"                     							, oFont11n )
	EndIf

	oPrint:Line ( nLinIni + 0472 , 1900 , nLinIni + 1162 , 1900 )
	oPrint:Line ( nLinIni + 0882 , 1900 , nLinIni + 0882 , 2300 )
	oPrint:Line ( nLinIni + 0952 , 1900 , nLinIni + 0952 , 2300 )
	oPrint:Line ( nLinIni + 1022 , 1900 , nLinIni + 1022 , 2300 )
	oPrint:Line ( nLinIni + 1092 , 1900 , nLinIni + 1092 , 2300 )
	oPrint:Line ( nLinIni + 1162 , 0100 , nLinIni + 1162 , 2300 )
	oPrint:Line ( nLinIni + 1316 , 0100 , nLinIni + 1316 , 2300 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Codigo do Cliente - Utilizado pela Grafica.								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Say  ( nLinIni + 1700 , 0100 , aLinhaBol[P_CLIENTE]+aLinhaBol[P_LOJA] , oFontGrf )

Return()

/*/{Protheus.doc} OmBarBol
Imprime o codigo de barra do Boleto
@version 1.0
/*/
User Function OmBarBol(oPrint,aLinhaBol,nLinha)

	MSBAR("INT25",nLinha,1.5,aLinhaBol[P_CODBARRAS],oPrint,.F.,Nil,Nil,0.025,1.5,Nil,Nil,"A",.F.)

Return()


/*/{Protheus.doc} OmDigDI
Calcula o Digito Verificado do  Deposito Identificado.
@version 1.0
/*/
User Function OmDigDI(cNumero)

	Local cDigDI 	:= ""
	Local aTabPeso	:= {2,7,6,5,4,3,2}
	Local nI		:= 0
	Local nSomaAux	:= 0
	Local nRestoAux	:= 0
	Local nDigAux	:= 0

	For	nI	:= 1 To Len(cNumero)
		nSomaAux += ( Val( SubStr(cNumero,nI,1) ) * aTabPeso[nI] )
	Next nI

	nRestoAux 	:= ( nSomaAux % 11 )

	If		nRestoAux == 0 .Or. nRestoAux == 1
		cDigDI := "0"
	ElseIf	nRestoAux == 10
		cDigDI := "1"
	Else
		nDigAux	:= ( 11 - nRestoAux )
		cDigDI 	:= StrZero(nDigAux,1)
	EndIf

Return(cDigDI)


/*/{Protheus.doc} OmIdCnab
Gera IdCnab para Boletos antigos que nao tinham.
@version 1.0
/*/
User Function OmIdCnab()

	Local cIdCnab 		:= ""
	Local aOrdSE1 		:= {}
	Local cBkpFilAnt	:= cFilAnt

	If 	Empty(SE1->E1_IDCNAB)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera dados no Titulo para gerar Instrucao Bancaria.					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	!Empty(SE1->E1_FILIAL) .And. cFilAnt != SE1->E1_FILIAL
			cFilAnt := SE1->E1_FILIAL
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera identificador do registro CNAB no titulo enviado.		        	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cIdCnab := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt,16)
		DBSelectArea("SE1")
		aOrdSE1 := SE1->(GetArea())
		SE1->(DBSetOrder(16))
		While 	SE1->(MsSeek(xFilial("SE1")+cIdCnab))
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cIdCnab := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt,16)
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para tratamento da variavel cIdCnab     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If 	ExistBlock ("F150ICNB")
			cIdCnab := ExecBlock("F150ICNB",.F.,.F.,{cIdCnab})
		EndIf 					

		SE1->(RestArea(aOrdSE1))
		SE1->(Reclock("SE1"))
		SE1->E1_IDCNAB := cIdCnab
		SE1->(MsUnlock())

		ConfirmSx8()

		cFilAnt := cBkpFilAnt

	EndIf

Return()


/*/{Protheus.doc} OmErrLog
Trata a mensagem do Error Log.
@version 1.0
/*/
User Function OmErrLog()

	Local nX	:= 0
	Local cErro := ""
	Local aErro := GetAutoGRLog()

	For nX := 1 To Len(aErro)

		If 	nX <= 4 .Or. ( "<--" $ aErro[nX] )
			cErro += aErro[nX] + Chr(13)+Chr(10)
		EndIf

	Next nX

Return(cErro)


/*/{Protheus.doc} OmErrLog
Retorna mensagem a ser impressa no Boleto 
@author Augusto Ribeiro | www.compila.com.br
@since 25/08/2017
@version 1.0
@param cCodCan = Codgo do Canal ,_cCodCli, _cLoja, _cPedido, _cParc
@return Sempre retorna array de 5 elementos, 1 para cada linha 
/*/
Static Function OmMsgBol(cCodCan,_cCodCli, _cLoja,_cPedido,_cParc, _nRecSE1)
	Local aRet		:= {"","","","",""}
	Local cTpMsg	:= ALLTRIM(GetNewPar("CP_BOLTPMG","P"))		//| Tipo da Mensagem a ser impressa no Boleto
	Local cAnoAtual	:= ""
	Local cAnoAnt	:= ""
	Local cCodPad	:= "PAD"
	Local cCodAdp	:= "ADP"
	Local cPed		:= .F.
	Local cTes		:= ""
	Local cAF		:= ""
	Local cCenar	:= ""


	/*------------------------------------------------------ Augusto Ribeiro | 08/12/2016 - 2:39:41 PM
	PROJETO HERMES
	REPOSICIONA SE1 se necessário
	------------------------------------------------------------------------------------------*/
	IF _nRecSE1 <> SE1->(RECNO())
		SE1->(DBGOTO(_nRecSE1))
	ENDIF

	cPed 	:= ""//iif(ALLTRIM(Posicione("SC5",1, xFilial("SC5")+_cPedido, "C5_OTCP"))<>'',.T.,.F.)		     	                                                                                              
	cAF		:= ""//Posicione("SC5",1, xFilial("SC5")+_cPedido, "C5_OTCP")
	cTes 	:= ALLTRIM(Posicione("SC6",1, xFilial("SC6")+_cPedido, "C6_TES"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipos de Mensagem         ³
	//³ P = Padrao               ³
	//³ A = Clientes Adimplentes ³
	//³ C = Por Canal            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao do Tipo de Mensagem desejada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF Valtype(cTpMsg) == "C"
		IF LEN(cTpMsg) <> 1 .OR. !(cTpMsg $ "PAC")
			cTpMsg	:= "P"	
		ENDIF
	else 
		cTpMsg	:= "P"
	ENDIF
		
	//aRet[1]	:= "Após o Vencimento Cobrar juros Mora de R$ "+ALLTRIM(STR(SE1->E1_VALJUR))+" por dia de atraso."
	
	aRet[1]	:= "APÓS O VENCIMENTO COBRAR ENCARGOS AO DIA DE R$ " + ALLTRIM(STR(SE1->E1_VALJUR))
//	aRet[2]	:= "APÓS O VENCIMENTO SERÁ COBRADO MULTA DE 2% AO MÊS"
	aRet[2]	:= "APÓS O VENCIMENTO SERÁ COBRADO MULTA DE R$ " + ALLTRIM( Transform( ( ( SE1->E1_SALDO/100) *2),PesqPict("SE1","E1_VALOR"))) + " AO MÊS"
	aRet[3]	:= "PROTESTAR APÓS 05 DIAS DE VENCIDO"
	 

Return(aRet)

/*                       
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmTitAde  ºAutor  ³Paulo Sampaio		 º Data ³ 01/09/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o titulo e originado de Taxa de Adesao do 	  º±±
±±º          ³Varejo.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Zatix.	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} OmDiSeJu
Verifica se o titulo e originado de Taxa de Adesao do V
@version 1.0
/*/
User Function OmDiSeJu(cFilTit,cPrefTit,cNumTit,cCliente,cLojaCli,dDtEmissao,dDtVencto)

	Local cQuery	:= ""
	Local nDiaMinDes:= GetNewPar("OM_DIMIDES",3)
	Local cProdAdes	:= AllTrim(GetNewPar("OM_PRODADE","1025,S000.G1025.00,S000.1024.00"))
	Local nDiasSemJ	:= 0

	cQuery 	:= " SELECT TOP 01 SD2.D2_FILIAL "
	cQuery 	+= " FROM	"+RetSqlName("SD2")+" SD2 "
	cQuery 	+= " WHERE	SD2.D2_FILIAL	= '"+cFilTit+"' "
	cQuery 	+= " AND	SD2.D2_SERIE	= '"+cPrefTit+"' "
	cQuery 	+= " AND	SD2.D2_DOC		= '"+cNumTit+"' "
	cQuery 	+= " AND	SD2.D2_CLIENTE	= '"+cCliente+"' "
	cQuery 	+= " AND	SD2.D2_LOJA		= '"+cLojaCli+"' "
	cQuery 	+= " AND	SD2.D2_COD 		IN	"+FormatIn(cProdAdes,",")
	cQuery 	+= " AND	SD2.D_E_L_E_T_	= '' "

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBSD2",.F.,.T.)

	DBSelectArea("TRBSD2")
	TRBSD2->(DBGoTop()) 

	If	!TRBSD2->(Eof()) .And. ( dDtVencto - dDtEmissao ) <= nDiaMinDes
		nDiasSemJ := GetNewPar("OM_DISEJUR",15)
	EndIf

	TRBSD2->(DBCloseArea())

Return(nDiasSemJ)




/*/{Protheus.doc} FWOmCabBol
Imprime Cabecalho do Boleto no objeto oPrint.
Adaptado para o COmponente FWPRINTER
@version 1.0
/*/
User Function FWOmCabBol(oPrint,aLinhaBol,nLinha)

	Local oFont8 
	Local oFont10
	Local oFont14
	Local oFont21

	oFont8  := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont10 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14 := TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21 := TFont():New("Arial",9,26,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:Line ( nLinha+0120 , 550 , nLinha+0050 , 550 )
	oPrint:Line ( nLinha+0120 , 780 , nLinha+0050 , 780 )

	If		aLinhaBol[P_OPCPRINT] == "LOGO"
		oPrint:SayBitmap  ( nLinha , 0110 , aLinhaBol[P_LOGOBCO] , 400 , 100 )
	ElseIf	aLinhaBol[P_OPCPRINT] == "NOME"
		oPrint:Say  ( nLinha+084 , 100 , aLinhaBol[P_NOMEBCO] 				, oFont14 )
	EndIf

	oPrint:Say  ( nLinha+0100 , 0577 , aLinhaBol[P_NUMEROBCO]					, oFont21 )

	oPrint:Say  ( nLinha+0084 , 1900 , "Comprovante de Entrega"					, oFont10)
	oPrint:Line ( nLinha+0120 , 0100 , nLinha+0120 , 2300 )

	oPrint:Say  ( nLinha+0150 , 100 , "Beneficiário"							, oFont8) 
	oPrint:Say  ( nLinha+0200 , 100 , aLinhaBol[P_CEDENTE]						, oFont10 )

	If  Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO ABC B")
		oPrint:Say  ( nLinha+0150 , 1060 , "Agência/Código Beneficiário"					, oFont8) 
		oPrint:Say  ( nLinha+0200 , 1060 , aLinhaBol[P_AGENCIA]+"/"+aLinhaBol[P_CONTA]	, oFont10)
	Else
		oPrint:Say  ( nLinha+0150 , 1060 , "Agência/Código Beneficiário"					, oFont8) 
		oPrint:Say  ( nLinha+0200 , 1060 , aLinhaBol[P_AGENCIA]+aLinhaBol[P_CONTA]	, oFont10)
	EndIf

	oPrint:Say  ( nLinha+0150 , 1510 , "Nro.Documento"							, oFont8)
	oPrint:Say  ( nLinha+0200 , 1510 , aLinhaBol[P_NUMDOC]						, oFont10)

	oPrint:Say  ( nLinha+0250 , 100 , "Pagador"									, oFont8) 
	oPrint:Say  ( nLinha+0300 , 100 , aLinhaBol[P_NOME]							, oFont10)

	oPrint:Say  ( nLinha+0250 , 1060 , "Vencimento"								, oFont8)
//	oPrint:Say  ( nLinha+0300 , 1060 , aLinhaBol[P_VENCIMENTO]					, oFont10)
	oPrint:SayAlign( nLinha+0300	,1060, aLinhaBol[P_VENCIMENTO]				, oFont10 ,/*nWidth*/,/*nHeigth*/,/*nClrText*/,0/*nAlignHorz*/,0/*nAlignVert*/ )
	
	oPrint:Say  ( nLinha+0250 , 1510 , "Valor do Documento"						, oFont8)
	oPrint:Say  ( nLinha+0300 , 1550 , aLinhaBol[P_VALOR]						, oFont10)

	oPrint:Say  ( nLinha+0400 , 0100 , "Recebi(emos) o boleto/título"			, oFont10)
	oPrint:Say  ( nLinha+0450 , 0100 , "com as características acima."			, oFont10)
	oPrint:Say  ( nLinha+0350 , 1060 , "Data"									, oFont8)
	oPrint:Say  ( nLinha+0350 , 1410 , "Assinatura"								, oFont8)
	oPrint:Say  ( nLinha+0450 , 1060 , "Data"									, oFont8)
	oPrint:Say  ( nLinha+0450 , 1410 , "Entregador"								, oFont8)

	oPrint:Line ( nLinha+0220 , 100 , nLinha+0220,1900 )
	oPrint:Line ( nLinha+0320 , 100 , nLinha+0320,1900 )
	oPrint:Line ( nLinha+0420 ,1050 , nLinha+0420,1900 )
	oPrint:Line ( nLinha+0520 , 100 , nLinha+0520,2300 )

	oPrint:Line ( nLinha+0520 , 1050 , nLinha+0120,1050 )
	oPrint:Line ( nLinha+0520 , 1400 , nLinha+0320,1400 )
	oPrint:Line ( nLinha+0320 , 1500 , nLinha+0120,1500 )
	oPrint:Line ( nLinha+0520 , 1900 , nLinha+0120,1900 )

	oPrint:Say  ( nLinha+0165 , 1910 , "(  )Mudou-se"                          , oFont8)
	oPrint:Say  ( nLinha+0205 , 1910 , "(  )Ausente"                           , oFont8)
	oPrint:Say  ( nLinha+0245 , 1910 , "(  )Não existe nº indicado"            , oFont8)
	oPrint:Say  ( nLinha+0285 , 1910 , "(  )Recusado"                          , oFont8)
	oPrint:Say  ( nLinha+0325 , 1910 , "(  )Não procurado"                     , oFont8)
	oPrint:Say  ( nLinha+0365 , 1910 , "(  )Endereço insuficiente"             , oFont8)
	oPrint:Say  ( nLinha+0405 , 1910 , "(  )Desconhecido"                      , oFont8)
	oPrint:Say  ( nLinha+0445 , 1910 , "(  )Falecido"                          , oFont8)
	oPrint:Say  ( nLinha+0485 , 1910 , "(  )Outros(anotar no verso)"           , oFont8)

Return()

/*/{Protheus.doc} FWOmCabBol
Imprime o corpo do Boleto. 
Adapatado para FWPRINTER
@version 1.0
/*/
User Function FWOmBodyBol(oPrint,aLinhaBol,nLinIni,lSegVia,lReciboSac,lPrintClient)

	Local oFont7    := TFont():New("Arial",9,12 ,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont8    := TFont():New("Arial",9,12 ,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont10   := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont11n  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont13n  := TFont():New("Arial",9,17,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont14   := TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont15n  := TFont():New("Arial",9,19,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont16   := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont21   := TFont():New("Arial",9,26,.T.,.T.,5,.T.,5,.T.,.F.)  
	Local oFontGrf	:= TFont():New("Courier",,13,,.F.,,,,.T.,.F.)

	Default lSegVia 	 := .F.
	Default lReciboSac 	 := .F.
	Default lPrintClient := .F.

	nLinIni -= 0384

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logo do Banco.										                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	aLinhaBol[P_OPCPRINT] == "LOGO"
		oPrint:SayBitmap  ( nLinIni + 330 , 0110 , aLinhaBol[P_LOGOBCO] , 400 , 100 )
	EndIf

	oPrint:Line ( nLinIni + 0442 , 0100 , nLinIni + 442 , 2300 )
	oPrint:Line ( nLinIni + 0442 , 0550 , nLinIni + 372 , 0550 )
	oPrint:Line ( nLinIni + 0442 , 0770 , nLinIni + 372 , 0770 )

	If	aLinhaBol[P_OPCPRINT] == "NOME"
		oPrint:Say  ( nLinIni + 0390 , 0100 , aLinhaBol[P_NOMEBCO]  , oFont14 )
	EndIf
	oPrint:Say  ( nLinIni + 0424 , 0567 , aLinhaBol[P_NUMEROBCO]	, oFont21 )
	If	lReciboSac
		oPrint:Say  ( nLinIni + 0406 , 1910 , "Recibo do Pagador" 	, oFont10 ) && Alterado Por Fabio Sales em 20130709
	Else
		oPrint:Say  ( nLinIni + 0406 , 0790 , aLinhaBol[P_LINHADIG] , oFont14 )
	EndIf

	oPrint:Line ( nLinIni + 0542 , 0100 , nLinIni + 0542 , 2300 )
	oPrint:Line ( nLinIni + 0642 , 0100 , nLinIni + 0642 , 2300 )
	oPrint:Line ( nLinIni + 0712 , 0100 , nLinIni + 0712 , 2300 )
	oPrint:Line ( nLinIni + 0782 , 0100 , nLinIni + 0782 , 2300 )

	oPrint:Line ( nLinIni + 0642 , 0500 , nLinIni + 0782 , 0500 )
	oPrint:Line ( nLinIni + 0712 , 0750 , nLinIni + 0782 , 0750 )
	oPrint:Line ( nLinIni + 0642 , 1000 , nLinIni + 0782 , 1000 )
	oPrint:Line ( nLinIni + 0642 , 1350 , nLinIni + 0712 , 1350 )
	oPrint:Line ( nLinIni + 0642 , 1550 , nLinIni + 0782 , 1550 )   

	oPrint:Say  ( nLinIni + 0472 , 0100 , "Local de Pagamento"                      				, oFont8  ) 
	oPrint:Say  ( nLinIni + 0476 , 0400 , aLinhaBol[P_MSGLOCPAG1]									, oFont10 ) 
	oPrint:Say  ( nLinIni + 0516 , 0400 , aLinhaBol[P_MSGLOCPAG2]									, oFont10 ) 

	oPrint:Say  ( nLinIni + 0472 , 1910 , "Vencimento"                                	   			, oFont8  ) 
//	oPrint:Say  ( nLinIni + 0512 , 2010 , aLinhaBol[P_VENCIMENTO]                       			, oFont10 )
	oPrint:SayAlign( nLinIni+490	,2115, aLinhaBol[P_VENCIMENTO]				, oFont10 ,2100,1300,,0,0)
	
	//oPrint:Say  ( nLinIni + 0572 , 0100 , "Beneficiário"                                        			, oFont8  )  
	//oPrint:Say  ( nLinIni + 0612 , 0100 , aLinhaBol[P_CEDENTE]+" - CNPJ: "+aLinhaBol[P_CNPJCED]	, oFont10 )


	If Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO SAFRA")
		oPrint:Say  ( nLinIni + 0572 , 0100 , "Beneficiário: "                                        			, oFont8  )  
		oPrint:Say  ( nLinIni + 0572 , 0300 , aLinhaBol[P_CEDENTE]	, oFont10 )               
	ElseIf Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO ABC B")
		oPrint:Say  ( nLinIni + 0572 , 0100 , "Cedente  "                                        			, oFont8  )  
		oPrint:Say  ( nLinIni + 0572 , 0300 , aLinhaBol[P_CEDENTE]	, oFont10 )
	ElseIf !Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO SAFRA/BANCO ABC B")
		oPrint:Say  ( nLinIni + 0572 , 0100 , "Beneficiário: "                                        			, oFont8  ) 
		oPrint:Say  ( nLinIni + 0572 , 0300 , aLinhaBol[P_CEDENTE]+" - CNPJ: "+aLinhaBol[P_CNPJCED]	, oFont10 )
	EndIf 


	If Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO ABC B")
		oPrint:Say  ( nLinIni + 0572 , 1910 , "Agência/Código Beneficiário"                         			, oFont8  ) 
		oPrint:Say  ( nLinIni + 0612 , 2010 , aLinhaBol[P_AGENCIA]+"/"+aLinhaBol[P_CONTA] 				, oFont10 )
	Else                                                                                                                                                                                                                            
		oPrint:Say  ( nLinIni + 0572 , 1910 , "Agência/Código Beneficiário"                         			, oFont8  ) 
//		oPrint:Say  ( nLinIni + 0612 , 2010 , aLinhaBol[P_AGENCIA]+aLinhaBol[P_CONTA] 				, oFont10 )
		oPrint:SayAlign( nLinIni +0600	,2075, aLinhaBol[P_AGENCIA]+aLinhaBol[P_CONTA]				, oFont10 ,2100,1300,,0,0)
	EndIf

	//&&| Adcionado por Fabio Sales em 20130625
	oPrint:Say  ( nLinIni + 0612 , 0300 , aLinhaBol[P_ENDCOB]	, oFont10 )


	oPrint:Say  ( nLinIni + 0672 , 0100 , "Data de Emissão"                                			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 0200 , right( dtos(dDataBase),2) +"/"+ substr( dtos(dDataBase),5,2) +"/"+ left( dtos(dDataBase),4)                                 		, oFont10 )

	oPrint:Say  ( nLinIni + 0672 , 0505 , "Nro.Documento"                                  			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 0605 , aLinhaBol[P_NUMDOC]				            			, oFont10 )

	oPrint:Say  ( nLinIni + 0672 , 1005 , "Espécie Doc."                                   			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 1105 , aLinhaBol[P_ESPECIEDOC]                        			, oFont10 )

	oPrint:Say  ( nLinIni + 0672 , 1355 , "Aceite"                                         			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 1455 , aLinhaBol[P_ACEITE]		                    			, oFont10 )

	oPrint:Say  ( nLinIni + 0672 , 1555 , "Data do Processamento"                          			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0702 , 1655 , aLinhaBol[P_DATPROC]	                        			, oFont10 )

	If  Substring(aLinhaBol[P_CEDENTE],1,11)$("BANCO ABC B")

		oPrint:Say  ( nLinIni + 0672 , 1910 , "Nosso Número"                                   			, oFont8  ) 
		oPrint:Say  ( nLinIni + 0702 , 1920 , aLinhaBol[P_NOSSONUMERO]			            			, oFont10 )
	Else
		
		
		oPrint:Say  ( nLinIni + 0672 , 1910 , "Nosso Número"                                   			, oFont8  ) 
//		oPrint:Say  ( nLinIni + 0702 , 1930/*2010*/ , aLinhaBol[P_NOSSONUMERO]			            	, oFont10 )
		oPrint:SayAlign( nLinIni + 670, 2040, aLinhaBol[P_NOSSONUMERO]			, oFont10 ,2100,1300,,0,0)
	
	EndIf	

	oPrint:Say  ( nLinIni + 0742 , 0100 , "Uso do Banco"                                   			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0772 , 0200 , aLinhaBol[P_USUBANCO]			            				, oFont10 )

	oPrint:Say  ( nLinIni + 0742 , 0505 , "Carteira"                                       			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0772 , 0605 , aLinhaBol[P_CARTEIRA]  		               				, oFont10 )

	oPrint:Say  ( nLinIni + 0742 , 0755 , "Espécie"                                        			, oFont8  )
	oPrint:Say  ( nLinIni + 0772 , 0855 , aLinhaBol[P_ESPECIE]	                        			, oFont10 ) 

	oPrint:Say  ( nLinIni + 0742 , 1005 , "Quantidade"                                   			, oFont8  ) 
	oPrint:Say  ( nLinIni + 0742 , 1555 , "Valor"                                         			, oFont8  ) 

	oPrint:Say  ( nLinIni + 0742 , 1910 , "(=)Valor do Documento"                         			, oFont8 ) 
//	oPrint:Say  ( nLinIni + 0772 , 2000 , aLinhaBol[P_VALOR]   										, oFont10 )
	oPrint:SayAlign( nLinIni + 740 , 2040, aLinhaBol[P_VALOR] 			, oFont10 ,2100,1300,,0,0)
	
	oPrint:Say  ( nLinIni + 0812 , 0100 , "Instruções/Texto de responsabilidade do Beneficiário" 		, oFont7  ) 

	oPrint:Say  ( nLinIni + 0862 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO1])   						, oFont10 )
	oPrint:Say  ( nLinIni + 0912 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO2])   						, oFont10 )
	oPrint:Say  ( nLinIni + 0962 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO3])   						, oFont10 ) 
	oPrint:Say  ( nLinIni + 1012 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO4])   						, oFont10 ) 
	oPrint:Say  ( nLinIni + 1062 , 0120 , Alltrim(aLinhaBol[P_INSTRUCAO5])   						, oFont10 ) 
	oPrint:Say  ( nLinIni + 1112 , 0120 , Alltrim(aLinhaBol[P_MSGJUROS])   						, oFont10 ) 

	oPrint:Say  ( nLinIni + 0812 , 1910 , "(-)Desconto/Abatimento"  								, oFont8 ) 
	oPrint:Say  ( nLinIni + 0882 , 1910 , "(-)Outras Deduções"      								, oFont8 ) 
	oPrint:Say  ( nLinIni + 0952 , 1910 , "(+)Mora/Multa"           								, oFont8 ) 
	oPrint:Say  ( nLinIni + 1022 , 1910 , "(+)Outros Acréscimos"    								, oFont8 ) 
	oPrint:Say  ( nLinIni + 1092 , 1910 , "(-)Valor Cobrado"        								, oFont8 ) 

	oPrint:Say  ( nLinIni + 1162 , 0100 , "Pagador"                             						, oFont8  )  
	oPrint:Say  ( nLinIni + 1172 , 0500 , aLinhaBol[P_NOME]+" ("+aLinhaBol[P_CLIENTE]+"-"+aLinhaBol[P_LOJA]+")" 		, oFont10 )
	oPrint:Say  ( nLinIni + 1172 , 1880 , IIf(aLinhaBol[P_PESSOA] == "F" , "CPF: " , "CNPJ: " )+aLinhaBol[P_CNPJ] 	, oFont10 )

	oPrint:Say  ( nLinIni + 1215 , 0500 , aLinhaBol[P_ENDERECO]+"   "+aLinhaBol[P_NUMERO]+"   "+aLinhaBol[P_COMPLEMENTO]+" - "+aLinhaBol[P_BAIRRO] 												, oFont10 )
	oPrint:Say  ( nLinIni + 1265 , 0500 , aLinhaBol[P_CEP]+" "+aLinhaBol[P_MUNICIPIO]+" - "+aLinhaBol[P_ESTADO]   																				, oFont10 )

	&& | Alterado por Fabio Sales em 20130625.
	oPrint:Say  ( nLinIni + 1335 , 0100 , "Pagador/Avalista"         								, oFont7  ) 
	oPrint:Say  ( nLinIni + 1335 , 0500 , aLinhaBol[P_AVALISTA]										, oFont10 )

	oPrint:Say  ( nLinIni + 1335 , 1400 , "Autenticação Mecânica"   								, oFont7  )
	oPrint:Say  ( nLinIni + 1335 , 1850 , "Ficha de Compensação"      								, oFont8  )
	
	If	lSegVia
		oPrint:Say  ( nLinIni + 1335 , 2192 , "2a.Via"                     							, oFont11n )
	EndIf

	oPrint:Line ( nLinIni + 0442 , 1900 , nLinIni + 1132 , 1900 )
	oPrint:Line ( nLinIni + 0852 , 1900 , nLinIni + 0852 , 2300 )
	oPrint:Line ( nLinIni + 0922 , 1900 , nLinIni + 0922 , 2300 )
	oPrint:Line ( nLinIni + 0992 , 1900 , nLinIni + 0992 , 2300 )
	oPrint:Line ( nLinIni + 1062 , 1900 , nLinIni + 1062 , 2300 )
	oPrint:Line ( nLinIni + 1132 , 0100 , nLinIni + 1132 , 2300 )
	oPrint:Line ( nLinIni + 1286 , 0100 , nLinIni + 1286 , 2300 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Codigo do Cliente - Utilizado pela Grafica.								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lPrintClient
		oPrint:Say  ( nLinIni + 1530 , 0100 , aLinhaBol[P_CLIENTE]+aLinhaBol[P_LOJA] , oFontGrf )
	endif

Return()


/*/{Protheus.doc} FWOmBarBol
Imprime o codigo de barra do Boleto.
@version 1.0
/*/
User Function FWOmBarBol(oPrint,aLinhaBol,nLinha)
	Local nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix

	cFont		:= "Arial"
	nWidth		:= 0.025
	nHeigth		:= 1.1
	nPFWidth	:= 1
	nPFHeigth	:= 1

	oPrint:FWMSBAR("INT25",nLinha,2.3,aLinhaBol[P_CODBARRAS],oPrint,.F.,Nil,Nil,nWidth,nHeigth,Nil,cFont,NIL,.F., nPFWidth, nPFHeigth)

Return()


/*/{Protheus.doc} OmNumBco
Gera NumBCO para gerar boleto sem Bordero e sem Arquivo CNAB
@version 1.0
/*/
User Function OmNumBco(lMostraMsg)

	Local cNumBCO 		:= ""
	Local aSavATU       := GetArea()
	Local aSavSE1       := SE1->(GetArea())
	Local aSavSEE       := SEE->(GetArea())
	Local _cBanco,_cAgencia,_cConta 
	Local _cCodA6	:= ""
	Local nTam := TamSx3("EE_FAXATU")[1]
	
	//Local aBanco1	:= StrTokArr(GETNEWPAR( "CP_BANC1", "04 |001|3336|7|3866|0|" ),"|")
	//GETNEWPAR( "CP_BANC1", "04|001|33367|7|38660|" )//|Cod SA6|Banco|Agencia|DV Agencia|Conta|Dv Conta
	//Local aBanco2	:= StrTokArr(GETNEWPAR( "CP_BANC2", "03 |341|1338| |72242|1|" ),"|")
	//GETNEWPAR( "CP_BANC2", "03|237|01104||860603|" )//|Cod SA6|Banco|Agencia|DV Agencia|Conta|Dv Conta
		
	DEFAULT lMostraMsg := .T.

	If Empty(SE1->E1_NUMBCO) .and. Empty(SE1->E1_BAIXA) .and. SE1->E1_SALDO > 0 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona na SX5 para buscar conta padrão quando não preenchido no titulo Boleto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

		/*DBSELECTAREA("SA6")
		SA6->(DBSETORDER(1))//|A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON|
	
		IF !EMPTY(SA1->A1_BCO1) .AND. SA6->(DBSEEK(XFILIAL("SA6") + SA1->A1_BCO1))
		
			IF ALLTRIM(SA1->A1_BCO1) == ALLTRIM(aBanco1[1])
				_cCodA6 	:= aBanco1[1]
				_cBanco 	:= aBanco1[2]
				_cAgencia 	:= ALLTRIM(aBanco1[3]) + aBanco1[4]
				_cConta 	:= ALLTRIM(aBanco1[5])
			ELSEIF ALLTRIM(SA1->A1_BCO1) == ALLTRIM(aBanco2[1])
				_cCodA6 	:= aBanco2[1]
				_cBanco 	:= ALLTRIM(aBanco2[2])
				_cAgencia 	:= ALLTRIM(aBanco2[3]) + aBanco2[4]
				_cConta 	:= ALLTRIM(aBanco2[5])
			ENDIF 			
			
		Else	
		*/		
			_cBanco    := SE1->E1_PORTADO
			_cAgencia  := SE1->E1_AGEDEP
			_cConta    := SE1->E1_CONTA	
	//	EndIf
		
	//	IF EMPTY(_cCodA6) .AND. !EMPTY(_cBanco)
			_cCodA6 := _cBanco
	//	ENDIF 
		
		SA6->(DBSEEK(XFILIAL("SA6") + _cCodA6))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona na Configuracao Bancaria.							         	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAchouSEE := .F.
		DBSelectArea("SEE")
		SEE->(DBSetOrder(1))
		
//		alert("_cCodA6 : " + _cCodA6)
//		alert("_cBanco : " + _cBanco)
		
		If	SEE->(DBSeek(xFilial("SEE") + _cCodA6 + _cAgencia + _cConta))
			//Ao encontrar o parametro banco, verifico a subconta que atende o Tipo de pagamento ou seja, tipo pag diferente de E
			lAchouSEE := .T.
		Else
			lAchouSEE := .F.
		EndIf

		if !lAchouSEE
			cLogErro := "Não foi encontrado o Codigo+Agencia+Conta [" + _cCodA6 + _cAgencia + _cConta + "],GERAR BORDERÔ!!!!!."
			If	lMostraMsg
				MsgInfo(cLogErro,"Boleto")
			EndIf             
			
			RestArea(aSavSE1)
			Return()
		EndIf             	

		//Apos posicionar no parametro banco inicio o tratamento para geração do numbco
		//Pego o Numero
		//Ja atualizo o numero no parametro banco para que outro usuario possa usar o codigo sem ficar esperando minhas validações
		
		DBSelectArea("SEE")
		RecLock("SEE",.F.)
			cNumBCO := StrZero(Val(SEE->EE_FAXATU),nTam)
			SEE->EE_FAXATU := Soma1(cNumBCO, nTam)
		SEE->( MsUnlock() )

		//Verifico se existe esse numero banco no SE1
		//DBSelectArea("SE1")
		//DbOrderNickName("NUMBCOBOL")
		//Modificado devido erro de criação de indice na base, por seguranca passarei a procurar por query se o nosso numero ja está duplicado
		While .T.
			//Procurando se ja existe o numbco na base pelo, banco, agencia e conta
			_cQuery := "SELECT E1_PORTADO,E1_AGEDEP,E1_CONTA,E1_NUMBCO "+CRLF
			_cQuery += "FROM "+RetSQLName("SE1")+" WITH (NOLOCK)  "+CRLF
			_cQuery += "WHERE D_E_L_E_T_='' AND  "+CRLF              
			_cQuery += "	E1_PORTADO='"+_cBanco+"' AND  "+CRLF
			_cQuery += "	E1_AGEDEP='"+_cAgencia+"' AND  "+CRLF
			_cQuery += "	E1_CONTA='"+_cConta+"' AND  "+CRLF
			_cQuery += "	E1_NUMBCO='"+cNumBCO+"' "+CRLF
			_cQuery += "	AND E1_BAIXA = '' "+CRLF
			_cQuery += "	AND E1_SALDO > 0 "+CRLF

			if Select("TQRY") > 0
				DBSelectArea("TQRY")
				DBCloseArea()
			endif

			DBUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery),"TQRY",.F.,.T.)

			DBSelectArea("TQRY")
			if !TQRY->(Eof()) .AND. !TQRY->(Bof())
				//Pego o Numero
				//Ja atualizo o numero no parametro banco para que outro usuario possa usar o codigo sem ficar esperando minhas validações
				DBSelectArea("SEE")
				
				RecLock("SEE",.F.)
					cNumBCO := StrZero(Val(SEE->EE_FAXATU),nTam)
					SEE->EE_FAXATU := Soma1(cNumBCO, nTam)
				SEE->( MsUnlock() )
				
			else
				exit
			endif
		Enddo

		if Select("TQRY") > 0
			DBSelectArea("TQRY")
			DBCloseArea()
		endif

		DBSelectArea("SE1")
		RestArea(aSavSE1)
		
		//sivaldo .. grava o nosso munemro casa não extista
		If _cBanco == "341"
		    
			//|Apos posicionar no parametro banco inicio o tratamento para geração do numbco. Pego o Numero e Já atualizo
			//|o numero no parametro banco para que outro usuario possa usar o codigo sem ficar esperando minhas validações
			DBSelectArea("SEE")
			RecLock("SEE",.F.)
			If _cBanco=="341"
				nTam:= 8		
			EndIf
		
			cNumBCO := StrZero(Val(SEE->EE_FAXATU),nTam)
			SEE->EE_FAXATU := Soma1(cNumBCO, nTam)
			SEE->( MsUnlock() )
			
			While .T.
				//Procurando se ja existe o numbco na base pelo, banco, agencia e conta
				_cQuery := "SELECT E1_PORTADO,E1_AGEDEP,E1_CONTA,E1_NUMBCO "+CRLF
				_cQuery += "FROM "+RetSQLName("SE1")+" WITH (NOLOCK)  "+CRLF
				_cQuery += "WHERE D_E_L_E_T_='' AND  "+CRLF              
				_cQuery += "E1_PORTADO='"+_cBanco+"' AND  "+CRLF
				_cQuery += "E1_AGEDEP='"+_cAgencia+"' AND  "+CRLF
				_cQuery += "E1_CONTA='"+_cConta+"' AND  "+CRLF
				_cQuery += "E1_NUMBCO='"+cNumBCO+"' "+CRLF
				_cQuery += "AND E1_BAIXA='' "+CRLF
				_cQuery += "AND E1_SALDO > 0 "+CRLF
		      
				if Select("TQRY") > 0
					DBSelectArea("TQRY")
					DBCloseArea()
				endif
				
				DBUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery),"TQRY",.F.,.T.)
		
				DBSelectArea("TQRY")
				
				IF !TQRY->(Eof()) .AND. !TQRY->(Bof())
					//| Pego o Numero já atualizo o numero no parametro banco para que outro usuario possa usar o codigo sem ficar esperando minhas validações
					DBSelectArea("SEE")
					RecLock("SEE",.F.)
					cNumBCO := StrZero(Val(SEE->EE_FAXATU),nTam)
					SEE->EE_FAXATU := Soma1(cNumBCO, nTam)
					SEE->( MsUnlock() )
				else
					exit
				endif
			Enddo

		if Select("TQRY") > 0
			DBSelectArea("TQRY")
			DBCloseArea()
		endif
		  
		  
		  //  cNumBCO := aDadosTit[P_CARTEIRA]+"/"+StrZero(Val(SE1->E1_NUMBCO),8)+"-" + Alltrim(str(U_modulo10(Alltrim(cCodAgen) + alltrim(cCodConta) + aDadosTit[P_CARTEIRA]+ alltrim(SE1->E1_NUMBCO))))
	        
		   //cNumBCO := left(_cAgencia,4) + StrZero(Val(right(Alltrim(cNumBCO),8)),8) + U_Modulo10(AllTrim(GetNewPar("CP_341CART","109")), left(_cAgencia,4) + StrZero(Val(right(Alltrim(cNumBCO),8)),8))
		
		ElseIf _cBanco == "001"
		   cNumBCO := AllTrim(GetNewPar("CP_001CONV","2918625"))+StrZero(Val(right(ALLTRIM(cNumBCO),10)),10)
		
		EndIf 
		
		
		
		SE1->(Reclock("SE1"))      		
			SE1->E1_NUMBCO  := cNumBCO
			SE1->E1_PORTADO := SEE->EE_CODIGO 
			SE1->E1_AGEDEP  := SEE->EE_AGENCIA
			SE1->E1_CONTA   := SEE->EE_CONTA			
		SE1->(MsUnlock())
		
	EndIf

	RestArea(aSavSE1)
	RestArea(aSavSEE)
	RestArea(aSavATU)

Return()


/*/{Protheus.doc} OmDig001
Calcula o Digito do Codigo de Barras do Boleto Safra. 
@version 1.0
/*/
User Function OmDig001(cNumero)

	Local cDig001 	:= Modulo11( cNumero , 2 , 9 )       
	Local nMultIni	:= 2
	Local nMultFim	:= 9
	Local nModulo	:= 0
	Local i, cChar, nMult

	nMultIni := Iif( nMultIni==Nil,2,nMultIni )
	nMultFim := Iif( nMultFim==Nil,9,nMultFim )
	nMult := nMultIni
	cNumero := AllTrim(cNumero)

	For i := Len(cNumero) to 1 Step -1
		cChar := Substr(cNumero,i,1)
		If isAlpha( cChar )
			Help(" ", 1, "ONLYNUM")
			Return .f.
		End
		nModulo += Val(cChar)*nMult
		nMult:= IIf(nMult==nMultfim,2,nMult+1)
	Next
	nRest := nModulo % 11

	//nRest := IIf(nRest==0 .or. nRest==1,0,11-nRest)

	IF nRest == 0
		cDig001	:= "1"

	ELSEIF nRest == 1
		cDig001	:= "0"
	ELSE 
		cDig001	:= ALLTRIM(STR(11-nRest))
	ENDIF

Return(cDig001)


/*/{Protheus.doc} CCalJuros
Calcula Juros e Multas 
@author Jonatas Oliveira | www.compila.com.br
@since 17/03/2016
@version 1.0
@param nRecnoE1, N, RECNO SE1
@param cChvSe1, C, Chave SE1 indice 1
@param dDataCal, D, Data 
@return aRetVlr, Array , Array[1] = Valor Corrigido, Array[2] = Valor Multa, Array[3] = Valor Juros
/*/
User Function CCalJuros(nRecnoE1,cChvSe1,dDataCal )

	Local aRetVlr	:= {0,0,0}
	Local _nTxDia	:= U_ATEC200G("18", "TAXADIA")//0.033/100
	Local _nTxMes	:= U_ATEC200G("18", "TAXAMES")//2/100
	Local _nPerd	:= 0  	
	Local _nPerdM	:= 0  
	Local _nMulta 	:= 0   
	Local _nJuros 	:= 0   
	Local _nAcres 	:= 0
	Local lPosSE1	:= .F.
	Local _nSaldo	:= 0 

	Default	nRecnoE1	:= 0
	Default cChvSe1		:= ""
	Default dDataCal 	:= dDataBase  

	DBSELECTAREA("SE1")
	SE1->(DBSETORDER(1))

	IF nRecnoE1 > 0 
		SE1->(DBGOTO(nRecnoE1))
		lPosSE1	:= .T.

	ELSEIF !EMPTY(cChvSe1)
		IF 	SE1->(DBSEEK(cChvSe1)) 
			lPosSE1	:= .T.
		ENDIF
	ELSE
		aRetVlr := {0,0,0}	
	ENDIF


	IF lPosSE1
		_nAcres	:= 0
		_nMulta	:= 0	
		_nJuros	:= 0

		_nSaldo := SE1->E1_SALDO - SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", SE1->E1_MOEDA, dDataBase, SE1->E1_CLIENTE, SE1->E1_LOJA)
		IF SE1->E1_VENCREA < DDATABASE
			_nPerd  := DateDiffDay( DATAVALIDA(SE1->E1_VENCORI , .T.) ,dDataCal)
			_nPerdM := DateDiffMonth( DATAVALIDA(SE1->E1_VENCORI , .T.) ,dDataCal)			
			_nPerdM ++  

			_nMulta := (_nSaldo   * ((1+_nTxMes)^1)) - _nSaldo  
			_nJuros := (_nSaldo	* ((1+_nTxDia)^_nPerd) ) - _nSaldo   
			_nAcres := _nJuros+_nMulta
		ENDIF

		aRetVlr := {_nSaldo + _nAcres , _nMulta, _nJuros}			
	ENDIF


Return(aRetVlr)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Modulo10   ºAutor  ³Fabio Sales        º Data ³ 23/11/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o Codigo de Barras para Boleto Itau.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Zatix.                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Modulo10(cData)
//LOCAL L, D, P, nInt := 0
//L := Len(cdata)
//D := 0
//P := 2
//N := 0
//
//While L > 0
//	N := (Val(SubStr(cData, L, 1)) * P)
//	If N > 9
//		D := D + (Val(SubsTr(Str(N,2),1,1)) + Val(SubsTr(Str(N,2),2,1)))
//	Else
//		D := D + N
//	Endif
//	If P = 2
//		P := 1
//	Elseif P = 1
//		P := 2
//	EndIf
//	L := L - 1
//End
//
//D := Mod(D,10)
//D := 10 - D
//
//If D == 10
//	D:=0
//Endif
//
//Return(D)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return(D)
//Local L,D,P := 0
//Local B     := .F.
//
//L := Len(cData)  //TAMANHO DE BYTES DO CARACTER
//B := .T.   
//D := 0     //DIGITO VERIFICADOR
//While L > 0 
//   P := Val(SubStr(cData, L, 1))
//   If (B) 
//      P := P * 2
//      If P > 9 
//         P := P - 9
//      End
//   End
//   D := D + P
//   L := L - 1
//   B := !B
//End
//D := 10 - (Mod(D,10))
//If D = 10
//   D := 0
//End
//   
//Return(D)   



User Function OmDig341(cNumero)
                                            
Local cDig341 	:= Modulo10( cNumero , 2 , 9 )       
Local nMultIni	:= 2
Local nMultFim	:= 9
Local nModulo	:= 0      
Local nAux 		:= 0        
Local nAux1  	:= 0
Local nX 		:= 0
Local i, cChar, nMult

nMultIni := Iif( nMultIni==Nil,2,nMultIni )
nMultFim := Iif( nMultFim==Nil,9,nMultFim )
nMult := 1
cNumero := AllTrim(cNumero)

For i := 1 to Len(cNumero) 
	cChar := Substr(cNumero,i,1)
	If isAlpha( cChar )
		Help(" ", 1, "ONLYNUM")
		Return .f.
	End            
	nAux :=  Val(cChar)*nMult
	nTam := len(alltrim(str(nAux)))
	If nTam > 1    
		For Nx := 1 to nTam 
			nAux1 += Val(Substr(alltrim(str(nAux)),Nx,1))
		Next Nx 
		nAux := nAux1
	EndIf
	nModulo += nAux      
	nAux1 := 0                      
	nAux0 := 0
	nMult:= IIf(nMult==1,2,1)
Next 

nRest := nModulo % 10

IF nRest == 0
	cDig341	:= "0"
Else
	cDig341	:= ALLTRIM(STR(10-nRest))
ENDIF

Return(cDig341)

Static Function Mod11CB(cData) // Modulo 11 com base 9
LOCAL CBL, CBD, CBP := 0
CBL := Len(cdata)
CBD := 0
CBP := 1

While CBL > 0
	CBP := CBP + 1
	CBD := CBD + (Val(SubStr(cData, CBL, 1)) * CBP)
	If CBP = 9
		CBP := 1
	End
	CBL := CBL - 1
End
_nCBResto := mod(CBD,11)  //Resto da Divisao
CBD := 11 - _nCBResto
If (CBD == 0 .Or. CBD == 1 .Or. CBD == 10 .Or. CBD == 11)
	CBD := 1
End

Return(CBD)