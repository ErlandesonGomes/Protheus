#Include "Protheus.Ch"
#Include "Ap5Mail.Ch"


/*/{Protheus.doc} FA60BDE
//GERAÇÃO E1_NUMBCO  na geração do borderô!
@author sivaldo.santos.ext
@since 01/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User function FA60BDE()


Local cNumBCO 		:= ""
Local aSavATU       := GetArea()
Local aSavSE1       := SE1->(GetArea())
Local aSavSEE       := SEE->(GetArea())
Local _cBanco       := SE1->E1_PORTADO
Local _cAgencia     := SE1->E1_AGEDEP
Local _cConta       := SE1->E1_CONTA
Local _cCodA6	    := cPort060
Local nTam          := TamSx3("EE_FAXATU")[1]
Local lMostraMsg    := .T.

	
	Local aBanco1	:= StrTokArr(GETNEWPAR( "CP_BANC1", "04 |001|1369|2|26387|7|" ),"|")
	//GETNEWPAR( "CP_BANC1", "04|001|33367|7|38660|" )//|Cod SA6|Banco|Agencia|DV Agencia|Conta|Dv Conta
	Local aBanco2	:= StrTokArr(GETNEWPAR( "CP_BANC2", "03 |341|1338| |73242|1" ),"|")
	//GETNEWPAR( "CP_BANC2", "03|237|01104||860603|" )//|Cod SA6|Banco|Agencia|DV Agencia|Conta|Dv Conta
		
	DEFAULT lMostraMsg := .T.


If  Empty(SE1->E1_NUMBCO) .AND. TRB->E1_OK == cMarca
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na SX5 para buscar conta padrão quando não preenchido no titulo Boleto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
    
	DBSELECTAREA("SA6")
	SA6->(DBSETORDER(1))//|A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON|

	IF !EMPTY(cPort060) .AND. SA6->(DBSEEK(XFILIAL("SA6") + cPort060))
	
		IF ALLTRIM(cPort060) == ALLTRIM(aBanco1[1])
			_cCodA6 	:= aBanco1[1]
			_cBanco 	:= aBanco1[2]
			_cAgencia 	:= ALLTRIM(aBanco1[3]) + aBanco1[4]
			_cConta 	:= ALLTRIM(aBanco1[5])
		ELSEIF ALLTRIM(cPort060) == ALLTRIM(aBanco2[1])
			_cCodA6 	:= aBanco2[1]
			_cBanco 	:= ALLTRIM(aBanco2[2])
			_cAgencia 	:= ALLTRIM(aBanco2[3]) + aBanco2[4]
			_cConta 	:= ALLTRIM(aBanco2[5])
		ENDIF 			
		
	Else			
		_cBanco    := SE1->E1_PORTADO
		_cAgencia  := SE1->E1_AGEDEP
		_cConta    := SE1->E1_CONTA	
	EndIf
	
	SA6->(DBSEEK(XFILIAL("SA6") + _cBanco))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na Configuracao Bancaria.							         	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAchouSEE := .F.
	DBSelectArea("SEE")
	SEE->(DBSetOrder(1))
	If	SEE->(DBSeek(xFilial("SEE") + _cBanco + _cAgencia + _cConta))
		//Ao encontrar o parametro banco, verifico a subconta que atende o Tipo de pagamento ou seja, tipo pag diferente de E
		lAchouSEE := .T.
	Else
		lAchouSEE := .F.
	EndIf

	if !lAchouSEE
		cLogErro := "Não foi encontrado o Codigo+Agencia+Conta [" + _cBanco + _cAgencia + _cConta + "]."
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
	
	  
	  // cNumBCO := left(_cAgencia,4) + StrZero(Val(right(Alltrim(cNumBCO),7)),7) + U_OmDig237(AllTrim(GetNewPar("CP_237CART","02")), left(_cAgencia,4) + StrZero(Val(right(Alltrim(cNumBCO),7)),7)) 
	
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


Return