/*//#########################################################################################
Project  : Melhorias nos processos - FonNet
Module   : Financeiro
Source   : WFON003
Objective: Compensação automática entre NF c/ RA
*///#########################################################################################

#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} WFON003
    Gerenciador de Processamento
    @author  Dilson Castro
    @table   SE1, SE5
    @since   09-08-2021
    @type    function
/*/

User Function WFON003()
	Local cQuery := ""
	Local aRecnoNCC := {}
	Local aRecnoSE1 := {}
//	Local aArea  := GetArea()
	Local nTaxaCM := 0
	Local aTxMoeda := {}
//	Local nValor := 0
	Local nSaldo := 0
	Local lAutoJob	 	:=  !(SELECT("SM0") > 0 )   

	Private nRecnoNDF
	Private nRecnoE1

	If lAutoJob
		RpcSetType(3)
		RpcSetEnv('01','01')
	EndIf

	//Select na SE1 do titulo a ser baixado, busca pelo RECNO.
	cQuery := " SELECT "
	cQuery += "  E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VALOR, "
	cQuery += "  E1_SALDO, E1_PREFIXO, E1_TIPO, SE1.R_E_C_N_O_ AS RECNO "
	cQuery += " FROM "+RetSqlName("SE1")+" SE1  "
	cQuery += " WHERE "
	cQuery += "  SE1.D_E_L_E_T_ <> '*' AND "
	cQuery += "  E1_TIPO = 'RA' AND "
	cQuery += "  E1_SALDO > 0 "
	cQuery += " ORDER BY "
	cQuery += "  E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_EMISSAO "

	//dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "XSE1", .F., .T.)
	TcQuery cQuery New Alias XSE1

	While XSE1->(!EOF())

		aRecnoSE1 := {}
		AADD(aRecnoSE1,XSE1->RECNO)

		cQuery := ""
		cQuery += " SELECT R_E_C_N_O_ RECNO,  E1_SALDO "
		cQuery += "   FROM " + RETSQLNAME("SE1") + " SE1 "
		cQuery += "  WHERE SE1.D_E_L_E_T_ <> '*' "
		cQuery += "    AND SE1.E1_CLIENTE = '" + XSE1->E1_CLIENTE + "' "
		cQuery += "    AND SE1.E1_LOJA = '" + XSE1->E1_LOJA + "' "
		cQuery += "    AND SE1.E1_FILIAL = '" + XSE1->E1_FILIAL + "' "
		cQuery += "    AND SE1.E1_SALDO > 0 "
		cQuery += "    AND SE1.E1_TIPO = 'NF' "
		cQuery += "    AND SE1.E1_PARCELA IN ('  ','001') " //compensar somente a parcela 001 e em branco
		cQuery += "  ORDER BY R_E_C_N_O_ "

		//dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "XSE1B", .F., .T.)
		TcQuery cQuery New Alias XSE1B

		While XSE1B->(!EOF())

			aRecnoNCC := {}
			AADD(aRecnoNCC,XSE1B->RECNO)	

			DBSELECTAREA("SE1")
			DBGOTO(aRecnoSE1[1])

			If SE1->E1_SALDO > 0
				
				nSaldo := SE1->E1_SALDO
				
				//Busca a pergunta AFI340 para deixa-la em memoria as variaveis abaixo.
				PERGUNTE("AFI340",.F.)
				lContabiliza  := .F.//MV_PAR11 == 1
				lAglutina   := .F.//MV_PAR08 == 1
				lDigita   := .F.//MV_PAR09 == 1

				DBSELECTAREA("SE1")
				DBGOTO(XSE1B->RECNO)

				If SE1->E1_SALDO < nSaldo
					nSaldo := SE1->E1_SALDO
				Endif

				DBSELECTAREA("SE1")
				DBGOTO(aRecnoSE1[1])

				nTaxaCM := RecMoeda(dDataBase,SE1->E1_MOEDA)
				aAdd(aTxMoeda, {1, 1} )
				aAdd(aTxMoeda, {2, nTaxaCM} )

				//Chama função padrão para ser realizada a contabilização.
				//	!MaIntBxCR(3,aRecnoNCC,,aRecnoSE1,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,nSaldo,dDataBase,,,,,aTxMoeda,.T. )
				If  !MaIntBxCR(3,aRecnoNCC,,aRecnoSE1,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,, nSaldo,dDataBase,,,,,aTxMoeda,.T. ) //!MaIntBxCR(3,aRecnoNCC,,aRecnoSE1,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,SE1->E1_SALDO )   //!MaIntBxCR(3,aRecnoSE1,,aRecnoNCC,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,SE1->E1_SALDO )
					//Help("XAFCMPAD",1,"HELP","XAFCMPAD","Não foi possível a compensação"+CRLF+" do titulo do adiantamento",1,0)
					lRet := .F.
				ELSE
				
				ENDIF

			Else

				Exit

			EndIf			

			XSE1B->(DBSKIP())

		EndDo
		XSE1B->(DBCLOSEAREA())
		XSE1->(DBSKIP())
	EndDo
	XSE1->(DBCLOSEAREA())

	If lAutoJob
		RpcClearEnv()
	EndIf

Return
