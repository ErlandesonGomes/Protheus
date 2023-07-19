#include "totvs.ch"
#INCLUDE "RESTFUL.CH"
#include "fwmvcdef.ch"

User Function RRESTPRD	
Return

WSRESTFUL RRESTPRD DESCRIPTION "Produtos"
	WSDATA tabPreco		as STRING
	WSDATA Produto		as STRING
	WSDATA senha		as STRING

    WSMETHOD GET Preco ;
    DESCRIPTION "Pre�o do produto" ;
    WSSYNTAX "/Preco/{tab, codigo}" ;
	PRODUCES APPLICATION_JSON ;
    PATH "/Preco"

    WSMETHOD POST inc_produto ;
    DESCRIPTION "inclus�o de produto" ;
    WSSYNTAX "/inc_produto/" ;
	PRODUCES APPLICATION_JSON ;
    PATH "/inc_produto"

    WSMETHOD POST produto ;
    DESCRIPTION "produto" ;
    WSSYNTAX "/produto/" ;
	PRODUCES APPLICATION_JSON ;
    PATH "/produto"

    WSMETHOD POST tst ;
    DESCRIPTION "tst produto" ;
    WSSYNTAX "/tst/" ;
	PRODUCES APPLICATION_JSON ;
    PATH "/tst"

    WSMETHOD POST aluno ;
    DESCRIPTION "aluno" ;
    WSSYNTAX "/aluno/" ;
	PRODUCES APPLICATION_JSON ;
    PATH "/aluno"

ENDWSRESTFUL

WSMETHOD GET Preco WSRECEIVE tabPreco,Produto WSSERVICE RRESTPRD
	Local oRet	 := JsonObject():new()
	::SetContentType("application/json; charset=iso-8859-1")
	If Empty(::tabPreco) .OR. Empty(::Produto)
		SetRestFault(400,EncodeUTF8("Necess�rio enviar tabela e c�digo do produto"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
		Return .F.
	Endif
	//SB1->(DbSetOrder(1))	//FILIAL+CODIGO
	//If SB1->(DbSeek(xFilial("SB1")+::Produto))
	//	oRet["ok"]		:= .T. 
	//	oRet["descricao"]	:= SB1->B1_DESC
	//Else
	//	oRet["ok"]		:= .F. 
	//EndIf
	cQuery		:= "SELECT B1_COD,B1_DESC,B1_UREV "
	cQuery		+= " FROM "+RetSqlName("SB1")+" SB1"
	cQuery		+= " WHERE B1_FILIAL='"+xFilial("SB1")+"'"
	cQuery		+= " AND B1_COD='"+::Produto+"'"
	cQuery		+= " AND SB1.D_E_L_E_T_=' '"
	cAliasQry	:= MpSysOpenQuery(cQuery,"TMP1",{{"B1_UREV","D",8,0}})
	oRet["produtos"]	:= {}
	While (cAliasQry)->(!EOF())
		AADD(oRet["produtos"],JsonObject():New())
		nTam	:= Len(oRet["produtos"])
		oRet["produtos"][nTam]["produto"]		:= (cAliasQry)->B1_COD
		oRet["produtos"][nTam]["descricao"]		:= (cAliasQry)->B1_DESC
		oRet["produtos"][nTam]["ultrev"]		:= (cAliasQry)->B1_UREV
		(cAliasQry)->(DbSkip())
	EndDo
	//(cAliasQry)->(DBCloseArea())
	
	//oRet["valor"]	:= MaTabPrVen(::tabPreco,::Produto,1,"","")
	self:SetResponse(oRet:toJson())
	FreeObj(oRet)
Return .T.

WSMETHOD POST produto WSRECEIVE Produto WSSERVICE RRESTPRD
	Local oBody		:= JsonObject():new()
	Local oRet		:= JsonObject():new()		//{}
	Local nCont

	cBody := ::GetContent()
	oBody:Fromjson(cBody)

	If Empty(oBody["produtos"])
		SetRestFault(400,EncodeUTF8("Necess�rio enviar c�digo do produto"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
		Return .F.
	EndIf
	oRet["OK"]		:= {}						//{"OK":[]}
	For nCont:=1 to Len(oBody["produtos"])
		ConOut("Produto:"	+oBody["produtos"][nCont]["cod"])
		ConOut("Descricao:"	+oBody["produtos"][nCont]["desc"])

		oTmp	:= JsonObject():new()
		oTmp["desc"]		:= oBody["produtos"][nCont]["desc"]
		oTmp["retorno"]		:= .T.
		AADD(oRet["OK"],oTmp )				//{"OK":[{"desc":"","retorno":true},...]}
	Next
	self:SetResponse(oRet:toJson())
	FreeObj(oRet)
	FreeObj(oBody)
Return .T.

WSMETHOD POST tst WSRECEIVE Produto PATHPARAM url,id HEADERPARAM senha WSSERVICE RRESTPRD
	//::aURLParms		- Parametros da URL(PATHPARAM)
	//::GetContent()	- Parametros do body
	//WSRECEIVE xVar	- Query_string VAR=123
	//HEADERPARAM xVar	- Parametros do Header
	
	//If Len(::aURLParms)<=1
	//	SetRestFault(400,EncodeUTF8("Necess�rio enviar id do produto"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
	//	Return .F.
	//EndIf
	//ConOut(::aURLParms[2])

	self:SetResponse("Query param:"+cValToChar(::Produto)+;
					"|Header senha:"+cValToChar(::senha)+;
					"|Header Authorization:"+cValToChar(::GetHeader("Authorization"))+;
					"|Body:"+cValToChar(::GetContent()))
Return .T.

WSMETHOD POST inc_produto WSRECEIVE Produto WSSERVICE RRESTPRD
	Local oBody		:= JsonObject():new()
	Local oRet		:= JsonObject():new()		//{}
	Local nCont
	Local lRet		:= .T.
	Local oTmp
	Local lIncluir	:= .F.

	cBody := ::GetContent()
	oBody:Fromjson(cBody)

	If Empty(oBody["produtos"])
		SetRestFault(400,EncodeUTF8("Necess�rio enviar c�digo do produto"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
		Return .F.
	EndIf
	SB1->(DbSetOrder(1))
	oRet["retornos"]		:= {}						//{"OK":[]}
	oModel	:= FwLoadModel("MATA010")
	For nCont:=1 to Len(oBody["produtos"])
		oTmp		:= JsonObject():new()
		oTmp["produto"]	:= oBody["produtos"][nCont]["cod"]
		If SB1->(DbSeek(xFilial("SB1")+ PADR(oBody["produtos"][nCont]["cod"],GetSx3Cache("B1_COD","X3_TAMANHO")) ))
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
		Else
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			lIncluir	:= .T.
		EndIf
		lRet	:= oModel:Activate()
		If lIncluir
			lRet	:= lRet .AND. oModel:GetModel("SB1MASTER"):SetValue("B1_COD"	,oBody["produtos"][nCont]["cod"])
		EndIf
		lRet	:= lRet .AND. oModel:GetModel("SB1MASTER"):SetValue("B1_DESC"	,oBody["produtos"][nCont]["desc"])
		lRet	:= lRet .AND. oModel:GetModel("SB1MASTER"):SetValue("B1_TIPO"	,oBody["produtos"][nCont]["tipo"])
		lRet	:= lRet .AND. oModel:GetModel("SB1MASTER"):SetValue("B1_UM"		,oBody["produtos"][nCont]["um"])
		lRet	:= lRet .AND. oModel:GetModel("SB1MASTER"):SetValue("B1_LOCPAD"	,oBody["produtos"][nCont]["locpad"])
		lRet	:= lRet .AND. oModel:VldData()
		lRet	:= lRet .AND. oModel:CommitData()
		oTmp["msg"]		:= ""
		If !lRet
			aErro	:= oModel:GetErrorMessage()
			oTmp["lok"]	:= .F.
			oTmp["msg"]	+= "Erro ao registrar produto"+CRLF
			oTmp["msg"]	+= "Id do formul�rio de origem:		" + ' [' + AllToChar( aErro[1]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do campo de origem:			" + ' [' + AllToChar( aErro[2]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do formul�rio de erro:		" + ' [' + AllToChar( aErro[3]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do campo de erro:			" + ' [' + AllToChar( aErro[4]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do erro:						" + ' [' + AllToChar( aErro[5]	) + ']'+CRLF
			oTmp["msg"]	+= "Mensagem do erro:				" + ' [' + AllToChar( aErro[6]	) + ']'+CRLF
			oTmp["msg"]	+= "Mensagem da solu��o:			" + ' [' + AllToChar( aErro[7]	) + ']'+CRLF
			oTmp["msg"]	+= "Valor anterior:					" + ' [' + AllToChar( aErro[8]	) + ']'+CRLF
			oTmp["msg"]	+= "Valor atribuido:				" + ' [' + AllToChar( aErro[9]	) + ']'+CRLF
			oTmp["msg"]	+= "=============================================================="+CRLF
		Else
			oTmp["cod"]	:= SB1->B1_COD
			oTmp["lok"]	:= .T.
		Endif
		oTmp["msg"]		:= EncodeUTF8(oTmp["msg"])
		oModel:DeActivate()
		AADD(oRet["retornos"],oTmp)
	Next
	self:SetResponse(oRet:toJson())
	FreeObj(oRet)
	FreeObj(oBody)
Return .T.

WSMETHOD POST aluno WSRECEIVE Produto WSSERVICE RRESTPRD
	Local oBody		:= JsonObject():new()
	Local oRet		:= JsonObject():new()		//{}
	Local nCont,nCont2
	Local lRet		:= .T.
	Local oTmp
	Local lIncluir	:= .F.
	Local nLinhaAtu
	Local nLinhaAdd

	cBody := ::GetContent()
	oBody:Fromjson(cBody)

	If Empty(oBody["alunos"])
		SetRestFault(400,EncodeUTF8("Necess�rio enviar alunos"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
		Return .F.
	EndIf
	ZA1->(DbSetOrder(2))		//Pelo Nome
	oRet["retornos"]		:= {}						//{"OK":[]}
	oModel	:= FwLoadModel("RCADZA1")
	For nCont:=1 to Len(oBody["alunos"])
		oTmp		:= JsonObject():new()
		If ZA1->(DbSeek(xFilial("ZA1")+ PADR(oBody["alunos"][nCont]["nome"],GetSx3Cache("ZA1_NOME","X3_TAMANHO")) ))
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
		Else
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			lIncluir	:= .T.
		EndIf
		lRet	:= oModel:Activate()
		lRet	:= lRet .AND. oModel:GetModel("ZA1MASTER"):SetValue("ZA1_NOME"	,oBody["alunos"][nCont]["nome"])
		For nCont2:=1 to Len(oBody["alunos"][nCont]["itens"])
			nLinhaAtu	:= oModel:GetModel("ZA2GRID"):GetLine()
			If lIncluir .AND. nCont2>1	//No incluir, adiciona linha a partir da segunda vez
					nLinhaAdd	:= oModel:GetModel("ZA2GRID"):AddLine()
					If nLinhaAdd==nLinhaAtu
						lRet	:= .F.
					EndIf
			ElseIf !lIncluir	//Alterar
				//Busca a linha se j� est� cadastrada
				If !oModel:GetModel("ZA2GRID"):SeekLine({{"ZA2_CURSO",oBody["alunos"][nCont]["itens"][nCont2]["curso"]}})
					nLinhaAdd	:= oModel:GetModel("ZA2GRID"):AddLine()	//Se n�o tiver cadastrada, adiciona uma nova linha
					If nLinhaAdd==nLinhaAtu
						lRet	:= .F.
					EndIf
				EndIf
			EndIf
			lRet	:= lRet .AND. oModel:GetModel("ZA2GRID"):SetValue("ZA2_CURSO"	,oBody["alunos"][nCont]["itens"][nCont2]["curso"])
			lRet	:= lRet .AND. oModel:GetModel("ZA2GRID"):SetValue("ZA2_NOTA"	,oBody["alunos"][nCont]["itens"][nCont2]["nota"])
		Next
		lRet	:= lRet .AND. oModel:VldData()
		lRet	:= lRet .AND. oModel:CommitData()
		oTmp["msg"]		:= ""
		If !lRet
			aErro	:= oModel:GetErrorMessage()
			oTmp["lok"]	:= .F.
			oTmp["msg"]	+= "Erro ao registrar aluno"+CRLF
			oTmp["msg"]	+= "Id do formul�rio de origem:		" + ' [' + AllToChar( aErro[1]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do campo de origem:			" + ' [' + AllToChar( aErro[2]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do formul�rio de erro:		" + ' [' + AllToChar( aErro[3]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do campo de erro:			" + ' [' + AllToChar( aErro[4]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do erro:						" + ' [' + AllToChar( aErro[5]	) + ']'+CRLF
			oTmp["msg"]	+= "Mensagem do erro:				" + ' [' + AllToChar( aErro[6]	) + ']'+CRLF
			oTmp["msg"]	+= "Mensagem da solu��o:			" + ' [' + AllToChar( aErro[7]	) + ']'+CRLF
			oTmp["msg"]	+= "Valor anterior:					" + ' [' + AllToChar( aErro[8]	) + ']'+CRLF
			oTmp["msg"]	+= "Valor atribuido:				" + ' [' + AllToChar( aErro[9]	) + ']'+CRLF
			oTmp["msg"]	+= "=============================================================="+CRLF
		Else
			oTmp["cod"]	:= ZA1->ZA1_COD
			oTmp["lok"]	:= .T.
			oTmp["total"]	:= oModel:GetModel("RCADZA1CALC1"):GetValue("NTOTAL")
			oTmp["media"]	:= oModel:GetModel("RCADZA1CALC1"):GetValue("NMEDIA")
		Endif
		oTmp["msg"]		:= EncodeUTF8(oTmp["msg"])
		oModel:DeActivate()
		AADD(oRet["retornos"],oTmp)
	Next
	self:SetResponse(oRet:toJson())
	FreeObj(oRet)
	FreeObj(oBody)
Return .T.
