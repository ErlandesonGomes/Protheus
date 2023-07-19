#Include 'Protheus.ch'

User Function MT103FIM()

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

