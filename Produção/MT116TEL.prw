#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TbiConn.ch'
#Include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Topconn.ch'
#Include 'Fwbrowse.ch'
#INCLUDE "XMLXFUN.CH"
#INCLUDE 'FWMVCDEF.CH'

User Function MT116TEL


	Local aCombo1	    := {"Incluir NF de Conhec. Frete","Excluir NF de Conhec. Frete"} //"Incluir NF de Conhec. Frete"###"Excluir NF de Conhec. Frete"
	Local aCombo2	    := {"NF Normal","NF Devol./Benef."} //"NF Normal"###"NF Devol./Benef."
	Local aCombo3	    := {"Não","Sim"} //"N?"###"Sim"
	Local aCombo4	    := {"Sim","Não"} //"Sim"###"N?"
	Local aCombo5	    := {"Nâo","Sim"} //"N?"###"Sim"
	Local aCliFor	    := {{"Fornecedor","FOR"},{"Cliente","SA1"}} //"Fornecedor"###"Cliente"
	Local nCombo1	    := 1
	Local nCombo2	    := If(l116Auto,aAutoCab[6,2],1)
	Local nCombo3	    := If(l116Auto,aAutoCab[10,2],1)
	Local nCombo4	    := 1
	Local nCombo5	    := 1
	Local n116Valor	    := 0
	Local n116BsIcmret	:= 0
	Local n116VlrIcmRet	:= 0
	Local nOpcAuto      := If(l116Auto, If(aAutoCab[3,2]==1 ,2,1),1) //1= Exclusao - 2= Inclusao
	Local nX            := 0
	Local d116DataDe    := dDataBase - 60
	Local d116DataAte   := dDataBase
	LocaL lMT116VTP:= .F.

	Local c116Combo1    := aCombo1[nCombo1]
	Local c116Combo2    := aCombo2[1]
	Local c116Combo3    := aCombo3[1]
	Local c116Combo4	:= aCombo4[2]
	Local c116Combo5    := aCombo5[1]
	Local c116FornOri   := If(l116Auto,aAutoCab[4,2],CriaVar("F1_FORNECE",.F.))
	Local c116LojaOri   := If(l116Auto,aAutoCab[5,2],CriaVar("F1_LOJA",.F.))
	Local c116NumNF	    := If(l116Auto,aAutoCab[11,2],CriaVar("F1_DOC",.F.))
	Local c116SerNF	    := If(l116Auto,aAutoCab[12,2],CriaVar(iif(SerieNfId("SF1",3,"F1_SERIE")=='F1_SDOC','F1_SDOC','F1_SERIE'),.F.))
	Local c116Fornece   := If(l116Auto,aAutoCab[13,2],CriaVar("F1_FORNECE",.F.))
	Local c116Loja	    := If(l116Auto,aAutoCab[14,2],CriaVar("F1_LOJA",.F.))
	Local c116Tes	    := If(l116Auto,aAutoCab[15,2],CriaVar("D1_TES",.F.))
	Local lRet		    := .F.
	Local n116tIPOnf    := 1
	Local nPedagio := 0

	Local oDlg
	Local oCombo1
	Local oCombo2
	Local oCombo3
	Local oCombo4
	Local oCombo5
	Local oCliFor
	Local oFornOri
	Local lUtZeros	:= GetMV("FXT_UTZERO")
	Local lZerSerie	:= GetMV("FXT_ZERSER")
	Local nInc := 0
	Local aNfesRef := {}
	Local cNfesRef := ""
	Local n116tIPOnf := 1

	Private c116UFOri	:= CriaVar("A2_EST",.F.)
	Private aValidGet	:= {}
	Private c116Especie   := If(l116Auto,aAutoCab[18,2],CriaVar("F1_ESPECIE",.F.))
	Private lPedag := SuperGetMV("FXT_DESPDG", .F., .F.)

	if funname() == 'FXREPDFE'
		If lUtZeros
			c116NumNF := PadL(Alltrim(oCT:_InfCte:_ide:_nct:TEXT),Len(SF1->F1_DOC),"0")
		Else
			c116NumNF := PadR(Alltrim(oCT:_InfCte:_ide:_nct:TEXT),Len(SF1->F1_DOC))
		EndIf

		If lZerSerie
			c116SerNF := PadL(Alltrim(oCT:_InfCte:_ide:_serie:TEXT),Len(SF1->F1_SERIE),"0")
		Else
			c116SerNF := PadR(Alltrim(oCT:_InfCte:_ide:_serie:TEXT),Len(SF1->F1_SERIE))
		EndIf

        if Type("oCT:_InfCte:_infCTeNorm:_infDoc:_infNFe") == "A"
            for nX := 1 to len(oct:_infcte:_infctenorm:_infdoc:_infnfe)
                aadd(aNfesRef, oct:_infcte:_infctenorm:_infdoc:_infnfe[nX]:_chave:TEXT)
				cNfesRef := oct:_infcte:_infctenorm:_infdoc:_infnfe[nX]:_chave:TEXT
            next nX
        ElseIf Type("oCT:_InfCte:_infCTeNorm:_infDoc:_infNFe:_chave") <> "U" 
            aadd(aNfesRef,oCT:_InfCte:_infCTeNorm:_infDoc:_infNFe:_chave:TEXT)
			cNfesRef := oCT:_InfCte:_infCTeNorm:_infDoc:_infNFe:_chave:TEXT
        endif

		If Select("TRB") <> 0
			TRB->(dbCloseArea())
		Endif

		cQry := ""
		cQry := " SELECT A2_COD,A2_LOJA "
		cQry += " FROM "+RetSqlName("SA2")+" SA2 "
		cQry += " WHERE SA2.D_E_L_E_T_ = ' ' "
		cQry += " AND SA2.A2_CGC = '"+oCT:_InfCte:_emit:_cnpj:TEXT+"' "
		cQry += " AND SA2.A2_MSBLQL <> '1'

		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB",.T.,.T.)

		//melhoria de performance na geração do filtro das notas de compra
		If Select("TC1") > 0
	        TC1->(dbCloseArea())
		Endif
        if len(cNfesRef) > 0 
            cQry := "select F1_FORNECE,F1_LOJA,F1_TIPO from " + RetSqlName("SF1")+ " SF1"
            cQry += " WHERE F1_CHVNFE ='"+cNfesRef+"'"            
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TC1",.T.,.T.)																		            
			c116FornOri := TC1->F1_FORNECE
			c116LojaOri := TC1->F1_LOJA
			n116tIPOnf  := iif(TC1->F1_TIPO=='N',1,2)
        endif
		//fim melhoria performance

		c116Fornece := TRB->A2_COD //FBUSCACPO("SA2", 3 , xfilial("SA2") + oCT:_InfCte:_emit:_cnpj:TEXT , "A2_COD")
		c116Loja := TRB->A2_LOJA //FBUSCACPO("SA2", 3 , xfilial("SA2") + oCT:_InfCte:_emit:_cnpj:TEXT , "A2_LOJA")
		if !empty(c116Fornece) .and. !empty(c116Loja)
			c116UfOri := FBUSCACPO("SA2", 1 , xfilial("SA2") + c116Fornece + c116Loja, "A2_EST")
		endif

		if Type("oct:_infcte:_vprest:_comp") <> "U"
			if Type("oct:_infcte:_vprest:_comp") == "A"
				for nX := 1 to len(oct:_infcte:_vprest:_comp)
					if upper(alltrim(oct:_infcte:_vprest:_comp[nX]:_XNOME:TEXT)) == 'PEDAGIO'
						nPedagio := val(oct:_infcte:_vprest:_comp[nX]:_VCOMP:TEXT)
					endIf
				next nX
			ElseIf Type("oCT:_InfCte:_infCTeNorm:_infDoc:_infNFe") <> "U"
				if upper(alltrim(oct:_infcte:_vprest:_comp:_XNOME:TEXT)) == 'PEDAGIO'
					nPedagio := val(oct:_infcte:_vprest:_comp:_VCOMP:TEXT)
				ENDIF
			endif
		endif

		c116Especie := "CTE"

		if Type("oCT:_InfCte:_vPrest:_vTPrest") <> "U"
			if lPedag
				n116Valor := Val(Alltrim(oCT:_InfCte:_vPrest:_vTPrest:TEXT)) - nPedagio
			else
				n116Valor := Val(Alltrim(oCT:_InfCte:_vPrest:_vTPrest:TEXT))
			endif
		endif

    elseif funname() == "MATA116FX"

		c116Combo1 := "Excluir NF de Conhec. Frete"
		nCombo1 := 2
		c116FornOri := ZX1->ZX1_CLIFOR
		c116LojaOri:= ZX1->ZX1_LOJA		
	Endif

	c116Combo2 := aCombo2[n116tIPOnf]
	nCombo2 := n116tIPOnf

	DEFINE MSDIALOG oDlg FROM 87 ,52  TO 500/*450*/,609 TITLE cCadastro Of oMainWnd PIXEL //"Parametros "

	@ 22 ,3   TO 68 ,274 LABEL "Parametros do Filtro" OF oDlg PIXEL //"Parametros do Filtro"
	@ 6 ,48  MSCOMBOBOX oCombo1 VAR c116Combo1 ITEMS aCombo1 SIZE 83 ,50 OF oDlg PIXEL When (funname()!='FXREPDFE') VALID (nCombo1:=aScan(aCombo1,c116Combo1))
	@ 7  ,6   SAY "Quanto a Nota" Of oDlg PIXEL SIZE 43,09 //"Quanto a Nota"
	@ 7  ,140 SAY "Filtrar Notas com conhecimento de frete" Of oDlg PIXEL SIZE 100 ,9 //"Filtrar notas com conhecimento de frete"
	@ 7  ,245 MSCOMBOBOX oCombo5 VAR c116Combo5 ITEMS aCombo5 SIZE 30 ,50 OF oDlg PIXEL When (nCombo1==1) VALID (nCombo5:=aScan(aCombo5,c116Combo5))
	@ 34 ,12  SAY "Data Inicial" Of oDlg PIXEL SIZE 60 ,9 //"Data Inicial"
	@ 34 ,125 SAY "Data Final" Of oDlg PIXEL SIZE 59 ,9 //"Data Final"
	@ 33 ,48  MSGET d116DataDe  Valid !Empty(d116DataDe) OF oDlg PIXEL SIZE 60 ,9
	@ 33 ,165 MSGET d116DataAte Valid !Empty(d116DataAte) OF oDlg PIXEL SIZE 60 ,9

	@ 52  ,12 SAY "Considerar" Of oDlg PIXEL SIZE 54 ,9 //"Considerar"
	@ 51  ,48 MSCOMBOBOX oCombo2 VAR c116Combo2 ITEMS aCombo2 SIZE 60 ,50 OF oDlg PIXEL When (nCombo1==1) VALID ((nCombo2:=aScan(aCombo2,c116Combo2)),oCliFor:Refresh(),oFornOri:cF3:=aCliFor[nCombo2][2],c116FornOri:=SPACE(Len(c116FornOri)),c116LojaOri:=SPACE(Len(c116LojaOri)))

	@ 52 ,125 SAY oCliFor VAR aCliFor[nCombo2][1] Of oDlg PIXEL SIZE 28 ,9
	@ 51 ,165 MSGET oFornOri VAR c116FornOri Picture PesqPict("SA2","A2_COD") F3 aCliFor[nCombo2][2];
		OF oDlg PIXEL SIZE 80 ,9 VALID Empty(c116FornOri).Or.A116StpVld(nCombo2,c116FornOri,@c116LojaOri,,1)

	@ 51 ,245  MSGET c116LojaOri Picture PesqPict("SA2","A2_LOJA") F3 CpoRetF3("A2_LOJA");
		OF oDlg PIXEL SIZE 19 ,9 VALID A116StpVld(nCombo2,c116FornOri,c116LojaOri,,1)

	//Dados para Nf Conhecimento de Frete
	@ 74 ,3   TO 180/*160*/,274 LABEL "Dados da NF de Frete" OF oDlg PIXEL //"Dados da NF de Frete"
	@ 86 ,10  SAY "Form. Proprio" Of oDlg PIXEL SIZE 32 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //"Form. Proprio"
	@ 85 ,47  MSCOMBOBOX oCombo3 VAR c116Combo3 ITEMS aCombo3 SIZE 35 ,50 OF oDlg PIXEL When (nCombo1==1.And.funname()!='FXREPDFE') VALID ((nCombo3:=aScan(aCombo3,c116Combo3)),c116NumNF:=SPACE(Len(c116NumNF)),c116SerNF:=SPACE(Len(c116SerNF)))

	@ 86 ,125 SAY "Num. Conhec." Of oDlg PIXEL SIZE 39 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //"Num. Conhec."
	@ 85 ,165 MSGET c116NumNF Picture PesqPict("SF1","F1_DOC") OF oDlg PIXEL SIZE 50 ,9 When (nCombo1==1.And.nCombo3==1.And.funname()!='FXREPDFE') VALID A116NCF(@c116NumNF).And.A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF)

	@ 86 ,225 SAY "Serie" Of oDlg PIXEL SIZE 15 ,9  //"Serie"
	@ 85 ,242 MSGET c116SerNF Picture PesqPict("SF1","F1_SERIE") OF oDlg PIXEL SIZE 19 ,9  When (nCombo1==1.And.nCombo3==1.And.funname()!='FXREPDFE') VALID A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF)

	@ 105,10  SAY "Fornecedor" Of oDlg PIXEL SIZE 47 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //"Fornecedor"
	@ 104,47  MSGET c116Fornece  Picture PesqPict("SF1","F1_FORNECE") F3 aCliFor[1][2] ;
		OF oDlg PIXEL SIZE 80 ,9 When (nCombo1==1.And.funname()!='FXREPDFE') VALID A116StpVld(1,c116Fornece,@c116Loja,@c116UfOri,2).And.A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF)

	@ 104,128  MSGET c116Loja Picture PesqPict("SF1","F1_LOJA") F3 CpoRetF3("F1_LOJA");
		OF oDlg PIXEL SIZE 19 ,9 When (nCombo1==1.And.funname()!='FXREPDFE') VALID A116StpVld(1,c116Fornece,c116Loja,@c116UfOri,2).And.A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF).And.A116ChkTra(c116Fornece,c116Loja,c116FornOri,c116LojaOri)

	@ 105,152 SAY "Cod. TES" Of oDlg PIXEL SIZE 32 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //"Cod. TES"
	@ 104,175 MSGET c116TES Picture PesqPict("SD1","D1_TES") F3 CpoRetF3("D1_TES");
		OF oDlg PIXEL SIZE 25 ,9 When (nCombo1==1) VALID  (Empty(c116Tes) .Or. ExistCpo("SF4",c116Tes)) .And. A116ChkTES(c116TES)

	@ 105,205 SAY "Valor" Of oDlg PIXEL SIZE 33 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //" Valor"
	@ 104,220 MSGET n116Valor Picture PesqPict("SD1","D1_TOTAL") ;
		OF oDlg PIXEL SIZE 51 ,9 When (nCombo1==1.And.funname()!='FXREPDFE')

	@ 125,10  SAY "UF Origem" Of oDlg PIXEL SIZE 36 ,9 //"UF Origem"
	@ 124,47  MSGET c116UfOri Picture PesqPict("SA2","A2_EST") F3 CpoRetF3("A2_EST");
		OF oDlg PIXEL SIZE 25 ,9 	When (nCombo1==1.And.funname()!='FXREPDFE') VALID A116StpVld(1,c116Fornece,@c116Loja,@c116UfOri,2) .And. ExistCPO("SX5","12"+c116UFOri) .Or. Vazio(c116UFOri)

	@ 125,120 SAY "Aglutina Produtos ?" Of oDlg PIXEL SIZE 48 ,9 //"Aglutina Produtos ?"
	@ 125,180 MSCOMBOBOX oCombo4 VAR c116Combo4 ITEMS aCombo4 SIZE 30 ,50 OF oDlg PIXEL When (nCombo1==1) VALID (nCombo4:=aScan(aCombo4,c116Combo4))

	@ 146,10  SAY "Bs Icms Ret." Of oDlg PIXEL SIZE 49 ,9 //"Bs Icms Ret."
	@ 144,47  MSGET oGetBs VAR n116BsIcmRet  Picture PesqPict("SD1","D1_BRICMS") F3 CpoRetF3("D1_BRICMS");
		OF oDlg PIXEL SIZE 70 ,9 When (nCombo1==1) VALID Positivo(n116BsIcmRet)

	@ 144,140 SAY "Vlr. Icms Ret." Of oDlg PIXEL SIZE 41 ,9 //"Vlr. Icms Ret."
	@ 143,180 MSGET n116VlrIcmRet Picture PesqPict("SD1","D1_ICMSRET") F3 CpoRetF3("D1_ICMSRET");
		OF oDlg PIXEL SIZE 70 ,9 When (nCombo1==1) VALID Positivo(n116VlrIcmRet)

	@ 166,10  SAY "Especie:" Of oDlg PIXEL SIZE 49 ,9 //"Bs Icms Ret."
	@ 164,47  MSGET oGetBs VAR c116Especie  Picture PesqPict("SF1","F1_ESPECIE") F3 CpoRetF3("F1_ESPECIE");
		OF oDlg PIXEL SIZE 25 ,9 When (nCombo1==1) VALID CheckSX3("F1_ESPECIE",c116Especie)	

	@188,240 BUTTON "Confirmar" SIZE 35 ,10  FONT oDlg:oFont ACTION If(A116StpOk(c116NumNF,c116Fornece,c116Loja,c116Tes,c116FornOri,c116LojaOri,nCombo1,n116Valor,nCombo3),(lRet:=.T.,oDlg:End()),Nil)  OF oDlg PIXEL //"Confirma >>"
	@188,200 BUTTON "Cancelar" SIZE 35 ,10  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL //"<< Cancelar"

	if funname() == 'FXREPDFE'
		@188,160 Button "Abrir XML" Size 35, 10 PIXEL OF oDlg Action(VisXML(ZX1->ZX1_FILE))
		@190,5 SAY str(len(aNfesRef)) + " chave(s) referenciada(s) no XML" Of oDlg PIXEL SIZE 120 ,20 //NFs referenciadas no XML
	endif

	ACTIVATE MSDIALOG oDlg CENTERED

	//inclui ou exclui
	if nCombo1 == 1
		nInc := 2
	else
		nInc := 1
	endif 

	//aglutina produtos	
		if nCombo4 == 1
		lAglu := .T.
	else
		lAglu := .F.
	endif 

	//filtra notas com conhecimento de frete
	if nCombo5 == 1
		lfilnt := .T.
	else
		lfilnt := .F.
	endif 

	aAdd(aParametros,nInc)              // 1o.parâmetro: Define a Rotina  : 2 = Inclusao
	aAdd(aParametros,nCombo2)              // 2o.parâmetro: Considerar Notas : 1 = Compra
	aAdd(aParametros,d116DataDe) // 3o.parâmetro: Data inicial para filtro das NFs Originais
	aAdd(aParametros,d116DataAte)       // 4o.parâmetro: Data final   para filtro das NFs Originais
	aAdd(aParametros,c116FornOri)   // 5o.parâmetro: Cod. forn. p/ filtro das NFs Originais: em branco p/ trazer TODOS
	aAdd(aParametros,c116LojaOri)   // 6o.parâmetro: Loja forn. p/ filtro das NFs Originais: em branco p/ trazer TODOS......
	aAdd(aParametros,nCombo3)
	aAdd(aParametros,c116NumNF)
	aAdd(aParametros,c116SerNF)
	aAdd(aParametros,c116Fornece)
	aAdd(aParametros,c116Loja)
	aAdd(aParametros,c116TES)
	aAdd(aParametros,n116Valor)
	aAdd(aParametros,c116UfOri)
	aAdd(aParametros,lAglu) //15
	aAdd(aParametros,n116BsIcmRet) //16
	aAdd(aParametros,n116VlrIcmRet) //17
	aAdd(aParametros,lfilnt) //18
	aAdd(aParametros,c116Especie)


Return lRet

Static Function A116ChkTra(c116Fornece,c116Loja,c116FornOri,c116LojaOri)

	Local lRet 		:= .T.
	Local lCkTrans	:= GetNewPar("MV_CKTRANS",.F.)

	If lCkTrans
		If c116Fornece == c116FornOri .And. c116Loja == c116LojaOri
			lRet := .F.
			HELP("",1,"A116CKTR")
		Endif
	Endif

Return (lRet)

Static Function A116ChkTES(cCodTES)

	Local lRet := .T.
	If SubStr(cCodTES,1,1) >= "5" .And. cCodTES <> "500"
		lRet := .F.
		HELP("   ",1,"INV_TE")
	Endif

Return (lRet)

Static Function A116StpOk(cNumNF,cFornece,cLoja,cTes,cFornOri,cLojaOri,nCombo1,nValor,nCombo3)

	Local lRet := .T.

	If nCombo1 == 1
		If (Empty(cNumNF).And.nCombo3==1) .Or. Empty(cFornece) .Or. Empty(cLoja) .Or. Empty(cTes) .Or. Empty(nValor)
			lRet := .F.
			Help(" ",1,"A116CPOOBRIGAT",,"Existem campos de preenchimento obrigatorio que nao foram informados. Verifique os campos da tela de que contem os dados da nota fiscal.",1,0) //"Atencao!"###"Existem campos de preenchimento obrigatorio que nao foram informados. Verifique os campos da tela de que contem os dados da nota fiscal."###"Voltar"
		EndIf
	EndIf

	If lRet .And. (!Empty(cFornOri).And.Empty(cLojaOri))
		lRet := .F.
		Help(" ",1,"A116FORNLOJ",,"Codigo da loja do fornecedor invalida. Verifique o preenchimento correto da loja do Fornecedor nos parametros para filtragem da nota fiscal.",1,0) //"Atencao!"###"Codigo da loja do fornecedor invalida. Verifique o preenchimento correto da loja do Fornecedor nos parametros para filtragem da nota fiscal."###"Voltar"
	EndIf

Return lRet

/***********************************************************************************
|----------------------------------------------------------------------------------|
|* Função     | VisXML                                                            *|
|----------------------------------------------------------------------------------|
|* Autor      | 4Fx Soluções em Tecnologia                                        *|
|----------------------------------------------------------------------------------|
|* Descricao  | Botão para visualizar XML na rotina de subst. de Cód. Produto     *|
|*            |                                                                   *|
|----------------------------------------------------------------------------------|
***********************************************************************************/

Static Function VisXML(cArq)

	Local cOper		:= "open" // "print", "explore
	Local cFileName	:= ""
	Local cParam	:= ""
	Local cDir		:= StrTran(AllTrim(UPPER(GetMV("FXT_FOLDER"))), UPPER(SuperGetMv("FXT_PATHPD",.F.,"\XmlNfe\",)) ,"",1,1)
	Local cDrive	:= cArq
	Local lRemotLin	:= GetRemoteType() == 2 //Checa se o Remote e Linux

	//If !lRemotLin
	//	cFileName := cDir + AllTrim(cDrive)
	//Else
	//	cFileName := cDir + StrTran(Lower(AllTrim(cDrive))," ","_")
	//EndIf

	_DrvAux 	:= ""
	_DirAux 	:= ""
	_NameAux 	:= ""
	_ExtAux 	:= ""

	SplitPath(cArq,@_DrvAux,@_DirAux,@_NameAux,@_ExtAux)

	lOk := CpyS2T( cArq, "C:\TEMP", .F. )
	cFileName := "C:\TEMP\" + _NameAux + _ExtAux

	If !Empty(cFileName)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para ambiente Linux ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IsSrvUnix() .And. GetRemoteType() == 1
			cDir := StrTran(cDir,"/","\")
		Endif

		If !lRemotLin
			If File(cFileName)
				ShellExecute(cOper,cFileName,cParam,cDir,1)
			Else
				MsgAlert("Arquivos não encontrados no driver e na pasta!")
				Return
			EndIf
		Else
			If File(cFileName)
				WinExec("linexec "+cFileName)
			Else
				MsgAlert("Arquivos não encontrados no driver e na pasta!")
				Return
			EndIf
		EndIf
	Endif

Return (.T.)
