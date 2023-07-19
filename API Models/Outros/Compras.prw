#include "totvs.ch"
#INCLUDE "RESTFUL.CH"
#include "fwmvcdef.ch"

User Function RRESTCOM	
Return

WSRESTFUL RRESTCOM DESCRIPTION "Produtos"
	WSDATA Solcomp		as STRING
	

    WSMETHOD GET solcompras ;
    DESCRIPTION "Solicitação de Compras" ;
    WSSYNTAX "/Solcomp/{Codigo}" ;
	PRODUCES APPLICATION_JSON ;
    PATH "/Solcomp"

    WSMETHOD POST solcompras ;
    DESCRIPTION "inclusão de solicitação de compras" ;
    WSSYNTAX "/Solcomp/" ;
	PRODUCES APPLICATION_JSON ;
    PATH "/Solcomp"

ENDWSRESTFUL



WSMETHOD GET Solcomp WSRECEIVE Codigo WSSERVICE RRESTCOM
	Local oRet	 := JsonObject():new()
	::SetContentType("application/json; charset=iso-8859-1")
	If Empty(::Codigo)
		SetRestFault(400,EncodeUTF8("Necessário enviar Codigo da solicitação"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
		Return .F.
	Endif

	cQuery		:= "SELECT C1_NUM, C1_ITEM, C1_PRODUTO, C1_UM, C1_DESCRI, C1_QUANT,C1_COTACAO,C1_FORNECE,C1_PEDIDO "
	cQuery		+= " FROM "+RetSqlName("SC1")+" SC1"
	cQuery		+= " WHERE C1_FILIAL='"+xFilial("SC1")+"'"
	cQuery		+= " AND C1_NUM='"+::Produto+"'"
	cQuery		+= " AND SC1.D_E_L_E_T_=' '"
	cAliasQry	:= MpSysOpenQuery(cQuery,"TMP1",{{"C1_NUM","C",15,0}})

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

WSMETHOD POST produto WSRECEIVE Produto WSSERVICE RRESTCOM
	Local oBody		:= JsonObject():new()
	Local oRet		:= JsonObject():new()		//{}
	Local nCont

	cBody := ::GetContent()
	oBody:Fromjson(cBody)

	If Empty(oBody["produtos"])
		SetRestFault(400,EncodeUTF8("Necessário enviar código do produto"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
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

WSMETHOD POST tst WSRECEIVE Produto PATHPARAM url,id HEADERPARAM senha WSSERVICE RRESTCOM
	//::aURLParms		- Parametros da URL(PATHPARAM)
	//::GetContent()	- Parametros do body
	//WSRECEIVE xVar	- Query_string VAR=123
	//HEADERPARAM xVar	- Parametros do Header
	
	//If Len(::aURLParms)<=1
	//	SetRestFault(400,EncodeUTF8("Necessário enviar id do produto"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
	//	Return .F.
	//EndIf
	//ConOut(::aURLParms[2])

	self:SetResponse("Query param:"+cValToChar(::Produto)+;
					"|Header senha:"+cValToChar(::senha)+;
					"|Header Authorization:"+cValToChar(::GetHeader("Authorization"))+;
					"|Body:"+cValToChar(::GetContent()))
Return .T.

WSMETHOD POST inc_produto WSRECEIVE Produto WSSERVICE RRESTCOM
	Local oBody		:= JsonObject():new()
	Local oRet		:= JsonObject():new()		//{}
	Local nCont
	Local lRet		:= .T.
	Local oTmp
	Local lIncluir	:= .F.

	cBody := ::GetContent()
	oBody:Fromjson(cBody)

	If Empty(oBody["produtos"])
		SetRestFault(400,EncodeUTF8("Necessário enviar código do produto"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
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
			oTmp["msg"]	+= "Id do formulário de origem:		" + ' [' + AllToChar( aErro[1]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do campo de origem:			" + ' [' + AllToChar( aErro[2]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do formulário de erro:		" + ' [' + AllToChar( aErro[3]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do campo de erro:			" + ' [' + AllToChar( aErro[4]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do erro:						" + ' [' + AllToChar( aErro[5]	) + ']'+CRLF
			oTmp["msg"]	+= "Mensagem do erro:				" + ' [' + AllToChar( aErro[6]	) + ']'+CRLF
			oTmp["msg"]	+= "Mensagem da solução:			" + ' [' + AllToChar( aErro[7]	) + ']'+CRLF
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

WSMETHOD POST aluno WSRECEIVE Produto WSSERVICE RRESTCOM
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
		SetRestFault(400,EncodeUTF8("Necessário enviar alunos"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
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
				//Busca a linha se já está cadastrada
				If !oModel:GetModel("ZA2GRID"):SeekLine({{"ZA2_CURSO",oBody["alunos"][nCont]["itens"][nCont2]["curso"]}})
					nLinhaAdd	:= oModel:GetModel("ZA2GRID"):AddLine()	//Se não tiver cadastrada, adiciona uma nova linha
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
			oTmp["msg"]	+= "Id do formulário de origem:		" + ' [' + AllToChar( aErro[1]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do campo de origem:			" + ' [' + AllToChar( aErro[2]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do formulário de erro:		" + ' [' + AllToChar( aErro[3]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do campo de erro:			" + ' [' + AllToChar( aErro[4]	) + ']'+CRLF
			oTmp["msg"]	+= "Id do erro:						" + ' [' + AllToChar( aErro[5]	) + ']'+CRLF
			oTmp["msg"]	+= "Mensagem do erro:				" + ' [' + AllToChar( aErro[6]	) + ']'+CRLF
			oTmp["msg"]	+= "Mensagem da solução:			" + ' [' + AllToChar( aErro[7]	) + ']'+CRLF
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
