#include "totvs.ch"
#INCLUDE "RESTFUL.CH"

User Function ESTQSC	
Return

WSRESTFUL ESTQSC DESCRIPTION "Saldo de itens no  Protheus"
	WSDATA Codigo		as STRING
    WSMETHOD GET Saldo ;
    DESCRIPTION "Saldo de itens no Protheus" ;
    WSSYNTAX "/Saldo/{codigo}" ;
	PRODUCES APPLICATION_JSON ;
    PATH "/Saldo"

ENDWSRESTFUL

WSMETHOD GET Saldo WSRECEIVE Codigo WSSERVICE ESTQSC
	Local oRet	 := JsonObject():new()
	::SetContentType("application/json; charset=iso-8859-1")
	If Empty(::Codigo)
		SetRestFault(400,EncodeUTF8("Necessário enviar Codigo do Produto"),.T.)
		Return .F.
	Endif
	
	If SB2->(DbSeek(xFilial("SB2")+::Codigo))
		oRet["ok"]			:= .T. 
		oRet["Codigo"]		:= SB2->B2_COD
		oRet["QUANTIDADE"]	:= SB2->B2_QATU
	Else
		oRet["ok"]		:= .F. 
	EndIf

	oRet["Codigo"]	:= ::Codigo
	self:SetResponse(oRet:toJson())
	FreeObj(oRet)
Return .T.
