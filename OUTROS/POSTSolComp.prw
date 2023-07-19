#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function EREST_01()
Return


WSRESTFUL Sol_Compras DESCRIPTION "Serviço REST para criação de solicitação de compras"

//WSDATA CODPRODUTO As String

WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE Sol_Compras

	Local cJSON := Self:GetContent() // Pega a string do JSON

	Local oParseJSON := Nil

	Local aDadosCli := {} //–> Array para ExecAuto do MATA030

	Local cFileLog := “”

	Local cJsonRet := “”

	Local cArqLog := “”

	Local cErro := “”

	Local cCodSA1 := “”

	Local lRet := .T.

	Private lMsErroAuto := .F.

	Private lMsHelpAuto := .F.

	// –> Cria o diretório para salvar os arquivos de log

	If !ExistDir(“\log_cli”)

	MakeDir(“\log_cli”)

	EndIf

	// –> Deserializa a string JSON

	FWJsonDeserialize(cJson, @oParseJSON)

	SA1->( DbSetOrder(3) )

	If !(SA1->( DbSeek( xFilial(“SA1”) + oParseJSON:CLIENTE:CGC ) ))

	cCodSA1 := GetNewCod()

	Aadd(aDadosCli, {“A1_FILIAL” , xFilial(“SA1”) , Nil} )

	Aadd(aDadosCli, {“A1_COD” , cCodSA1 , Nil} )

	Aadd(aDadosCli, {“A1_LOJA” , “01” , Nil} )

	Aadd(aDadosCli, {“A1_CGC” , oParseJSON:CLIENTE:CGC , Nil} )

	Aadd(aDadosCli, {“A1_NOME” , oParseJSON:CLIENTE:NOME , Nil} )

	Aadd(aDadosCli, {“A1_NREDUZ” , oParseJSON:CLIENTE:NOME , Nil} )

	Aadd(aDadosCli, {“A1_END” , oParseJSON:CLIENTE:ENDERECO ,Nil}

	Aadd(aDadosCli, {“A1_PESSOA” , Iif(Len(oParseJSON:CLIENTE:CGC)== 11, “F”, “J”) , Nil} )

	Aadd(aDadosCli, {“A1_CEP” , oParseJSON:CLIENTE:CEP , Nil} )

	Aadd(aDadosCli, {“A1_TIPO” , “F” , Nil} )

	Aadd(aDadosCli, {“A1_EST” , oParseJSON:CLIENTE:ESTADO , Nil} )

	Aadd(aDadosCli, {“A1_MUN” , oParseJSON:CLIENTE:MUNICIPIO,Nil} )

	Aadd(aDadosCli, {“A1_TEL” , oParseJSON:CLIENTE:TELEFONE, Nil} )

	MsExecAuto({|x,y| MATA030(x,y)}, aDadosCli, 3)

	If lMsErroAuto

	cArqLog := oParseJSON:CLIENTE:CGC + ” – ” +SubStr(Time(),1,5 ) + “.log”

	RollBackSX8()

	cErro := MostraErro(“\log_cli”, cArqLog)

	cErro := TrataErro(cErro) // –> Trata o erro para devolver para o client.

	SetRestFault(400, cErro)

	lRet := .F.

	Else

	ConfirmSX8()

	cJSONRet := ‘{“cod_cli”:”‘ + SA1->A1_COD + ‘”‘;

	+ ‘,”loja”:”‘ + SA1->A1_LOJA + ‘”‘;

	+ ‘,”msg”:”‘ + “Sucesso” + ‘”‘;

	+’}’

	::SetResponse( cJSONRet )

	EndIf

	Else

	SetRestFault(400, “Cliente já cadastrado: ” + SA1->A1_COD + ” – ” + SA1->A1_LOJA)

	lRet := .F.

	EndIf

	Return(lRet)
END WSRESTFUL
