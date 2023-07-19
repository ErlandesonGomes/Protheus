#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"


USER FUNCTION RSTFATAUT
RETURN

WSRESTFUL RSTFATAUT DESCRIPTION "FATURAMENTO AUTOMATICO"
    WSDATA INC_PEDIDOV AS STRING;

    WSMETHOD GET INC_PEDIDOV ;
    DESCRIPTION "Monitor Sefaz" ;
    WSSYNTAX "/INC_PEDIDOV/{Nota}" ;
	PRODUCES APPLICATION_JSON ;
    PATH "/INC_PEDIDOV";

    WSMETHOD POST INC_PEDIDOV;
    DESCRIPTION "INCLUSÃƒO DO PEDIDO DE VENDA(OV)";
    WSSYNTAX "/INC_PEDIDOV/";
    PRODUCES APPLICATION_JSON ;
    PATH "/INC_PEDIDOV"
ENDWSRESTFUL

WSMETHOD POST INC_PEDIDOV WSRECEIVE PEDIDO WSSERVICE RSTFATAUT

Local oBody            := JsonObject():New()
Local oRet             := JsonObject():New()
Local aSC5Area         := SC5->(GetArea())
Local cMensagem        := ""
Local nOpec            := 3
Local aCabec           := {}
Local aDados           := {}
Local aLinha           := {}
Local aArea            := {}
Local nPCount
Local nICount
Local NF_Gerada
Local i
local clog
local aLogAuto
Private lMSHelpAuto    := .T.
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.


cBody:= ::GetContent()
oBody:Fromjson(cBody)
oRet["Result"] := JsonObject():new()
aArea := GetArea()

For nPCount := 1 to Len(oBody["Pedidos"])
    //Validação de estrutura de campos
    cMensagem := ""
    aCabec := {}
    lMsErroAuto     := .F.
    clog := ""
    aDados := {}
    
    IF Empty(oBody["Pedidos"][nPCount]["C5_FILIAL"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_FILIAL" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_FILIAL"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_FILIAL deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_FILIAL"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_FILIAL", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_FILIAL"]), NIL})
        ENDIF
    ENDIF

    aadd(aCabec,{"C5_TIPO" ,"N",Nil})
    aadd(aCabec,{"C5_EMISSAO" ,Date(),NIL})

    IF Empty(oBody["Pedidos"][nPCount]["C5_CLIENTE"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_CLIENTE" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_CLIENTE"]) != "C"
            cMensagem += EncodeUTF8(  "C5_CLIENTE deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_CLIENTE"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_CLIENTE", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_CLIENTE"]), NIL})
        ENDIF
    ENDIF


    IF Empty(oBody["Pedidos"][nPCount]["C5_LOJACLI"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_LOJACLI" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_LOJACLI"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_LOJACLI deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_LOJACLI"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_LOJACLI", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_LOJACLI"]), NIL})
            AAdd(aCabec, {"C5_LOJAENT", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_LOJACLI"]), NIL})
        ENDIF
    ENDIF
    


    
    IF Empty(oBody["Pedidos"][nPCount]["A1_NATUREZ"])
        cMensagem += ""
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["A1_NATUREZ"]) != "C"
            cMensagem += EncodeUTF8(  "A1_NATUREZ deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["A1_NATUREZ"])) + " " + CRLF)
        ELSE
           
            cMensagem += NatuCli(PADR((oBody["Pedidos"][nPCount]["C5_CLIENTE"]),6," ")+cvaltochar(oBody["Pedidos"][nPCount]["C5_LOJACLI"]),cvaltochar(oBody["Pedidos"][nPCount]["A1_NATUREZ"])) //Mudar Natureza do Cliente
            
        ENDIF
    ENDIF


    IF Empty(oBody["Pedidos"][nPCount]["C5_VEND1"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_VEND1" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_VEND1"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_VEND1 deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_VEND1"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_VEND1", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_VEND1"]), NIL})
        ENDIF
    ENDIF
    
    IF Empty(oBody["Pedidos"][nPCount]["C5_CONDPAG"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_CONDPAG" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_CONDPAG"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_CONDPAG deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_CONDPAG"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_CONDPAG", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_CONDPAG"]), NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_MENNOTA"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_MENNOTA" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_MENNOTA"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_MENNOTA deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_MENNOTA"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_MENNOTA", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_MENNOTA"]), NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_FRETE"])
        AAdd(aCabec, {"C5_FRETE", 0, NIL})
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_FRETE"]) != "N"
                    cMensagem += EncodeUTF8(  "C5_FRETE deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_FRETE"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_FRETE", oBody["Pedidos"][nPCount]["C5_FRETE"], NIL})
        ENDIF
    ENDIF


    IF Empty(oBody["Pedidos"][nPCount]["C5_YNUM"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_YNUM" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_YNUM"]) != "N"
                    cMensagem += EncodeUTF8(  "C5_YNUM deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_YNUM"])) + " " + CRLF)
        ELSE
           AAdd(aCabec, {"C5_YNUM", oBody["Pedidos"][nPCount]["C5_YNUM"], NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_YPEDCLI"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_YPEDCLI" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_YPEDCLI"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_YPEDCLI deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_YPEDCLI"])) + " " + CRLF)
        ELSE
                AAdd(aCabec, {"C5_YPEDCLI", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_YPEDCLI"]), NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_EMAIL"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_EMAIL" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_EMAIL"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_EMAIL deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_EMAIL"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_EMAIL", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_EMAIL"]), NIL})
        ENDIF
    ENDIF

    IF Empty(oBody["Pedidos"][nPCount]["C5_TRANSP"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_TRANSP" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_TRANSP"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_TRANSP deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_TRANSP"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_TRANSP", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_TRANSP"]), NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_MENPAD"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_MENPAD" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_MENPAD"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_MENPAD deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_MENPAD"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_MENPAD", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_MENPAD"]), NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_TPFRETE"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_TPFRETE" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_TPFRETE"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_TPFRETE deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_TPFRETE"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_TPFRETE", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_TPFRETE"]), NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_PESOL"])
        AAdd(aCabec, {"C5_PESOL", 0, NIL})
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_PESOL"]) != "N"
                    cMensagem += EncodeUTF8(  "C5_PESOL deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_PESOL"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_PESOL", oBody["Pedidos"][nPCount]["C5_PESOL"], NIL})
        ENDIF
    ENDIF
    
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_PBRUTO"])
        AAdd(aCabec, {"C5_PBRUTO", 0, NIL})
    ELSE
            IF ValType(oBody["Pedidos"][nPCount]["C5_PBRUTO"]) != "N"
                        cMensagem += EncodeUTF8(  "C5_PBRUTO deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_PBRUTO"])) + " " + CRLF)
            ELSE
                AAdd(aCabec, {"C5_PBRUTO", oBody["Pedidos"][nPCount]["C5_PBRUTO"], NIL})
            ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_VOLUME1"])
         AAdd(aCabec, {"C5_VOLUME1", 0, NIL})
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_VOLUME1"]) != "N"
                    cMensagem += EncodeUTF8(  "C5_VOLUME1 deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_VOLUME1"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_VOLUME1", oBody["Pedidos"][nPCount]["C5_VOLUME1"], NIL})
        ENDIF
    ENDIF
    
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_ESPECI1"])
        cMensagem += EncodeUTF8(  "Necessário enviar C5_ESPECI1" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_ESPECI1"]) != "C"
                    cMensagem += EncodeUTF8(  "C5_ESPECI1 deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_ESPECI1"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_ESPECI1", EncodeUTF8( oBody["Pedidos"][nPCount]["C5_ESPECI1"]), NIL})
        ENDIF
    ENDIF



    DbSelectArea("SC5")
    SC5->(DbOrderNickName("ORDFAT"))
    SC5->(DBGOTOP(  ))
    if DbSeek(xFilial("SC5")+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"]))
    cMensagem += LimpPed(oBody,nPCount,aCabec)
    EndIF




    For nICount := 1 to Len(oBody["Pedidos"][nPCount]["ITENS"])
        aLinha := {}
        
        aadd(aLinha,{"C6_ITEM",StrZero(nICount,2),Nil})


        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRODUTO"])
            cMensagem += EncodeUTF8(  "Necessário enviar C6_PRODUTO" + " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRODUTO"]) != "C"
                cMensagem += EncodeUTF8(  "C6_PRODUTO deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRODUTO"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_PRODUTO",EncodeUTF8( oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRODUTO"]), NIL})
            ENDIF
        ENDIF

        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDVEN"])
            cMensagem += EncodeUTF8(  "Necessário enviar C6_QTDVEN"+ " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDVEN"]) != "N"
                cMensagem += EncodeUTF8(  "C6_QTDVEN deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDVEN"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_QTDVEN",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDVEN"], NIL})
            ENDIF
        ENDIF

        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"])
            cMensagem += EncodeUTF8(  "Necessário enviar C6_PRCVEN" + " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"]) != "N"
                cMensagem += EncodeUTF8(  "C6_PRCVEN deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_PRCVEN",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"], NIL})
                AAdd(aLinha, {"C6_PRUNIT",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"], NIL})
            ENDIF
        ENDIF


        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_VALOR"])
            cMensagem += EncodeUTF8(  "Necessário enviar C6_VALOR"+ " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_VALOR"]) != "N"
                cMensagem += EncodeUTF8(  "C6_VALOR deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_VALOR"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_VALOR",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_VALOR"], NIL})
            ENDIF
        ENDIF


        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDLIB"])
            cMensagem += EncodeUTF8(  "Necessário enviar C6_QTDLIB" + " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDLIB"]) != "N"    
                cMensagem += EncodeUTF8(  "C6_QTDLIB deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDLIB"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_QTDLIB",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDLIB"], NIL})
            ENDIF
        ENDIF



        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_TES"])
            cMensagem += EncodeUTF8(  "Necessário enviar C6_TES"+ " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_TES"]) != "C"
                cMensagem += EncodeUTF8(  "C6_TES deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_TES"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_TES",EncodeUTF8( oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_TES"]), NIL})
            ENDIF
        ENDIF


        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_NUMPCOM"])
            cMensagem += EncodeUTF8(  "Necessário enviar C6_TES"+ " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_NUMPCOM"]) != "C"
                cMensagem += EncodeUTF8(  "C6_NUMPCOM deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_NUMPCOM"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_NUMPCOM",EncodeUTF8( oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_NUMPCOM"]), NIL})
            ENDIF
        ENDIF

        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_ITPC"])
            cMensagem := EncodeUTF8(  "Necessário enviar C6_ITPC" + " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_ITPC"]) != "C"
                cMensagem := EncodeUTF8(  "C6_ITPC deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_ITPC"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_ITPC",EncodeUTF8( oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_ITPC"]), NIL})
            ENDIF
        ENDIF


        AAdd(aDados, aLinha)
    Next
    IF cMensagem != '' 
        oRet["Result"][cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])] := cMensagem 
    ELSE 



        lMsErroAuto := .F.
        MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aDados, nOpec)
        
        If (lMsErroAuto)
            aLogAuto := GetAutoGRLog()
            For i := 1 To Len(aLogAuto)
                cMensagem += aLogAuto[i] + CRLF + (" ")
            Next



            //cMensagem += Mostraerro()
            ConOut(Repl("-", 80))
            ConOut(PadC("MATA410 automatic routine ended with error", 80))
            ConOut(PadC("Ended at: " + Time(), 80))
            ConOut(Repl("-", 80))
            oRet["Result"][cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])] := EncodeUTF8(cMensagem)
        Else
            ConOut(Repl("-", 80))
            ConOut(PadC("MATA410 automatic routine successfully ended", 80))
            ConOut(PadC("Ended at: " + Time(), 80))
            ConOut(Repl("-", 80))
            //------------------------------------------------------------------
            //Faturar Automaticamente
            //DbSelectArea("SC5")
            //SC5->(DbOrderNickName("ORDFAT"))
            //SC5->(DBGOTOP(  ))
            //if DbSeek(xFilial("SC5")+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"]))
            //NF_Gerada := Fatura(SC5->C5_NUM)
            //EndIF
            //------------------------------------------------------------------
            oRet["Result"][cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])] := "Success " // +NF_Gerada 
        EndIf

    ENDIF
Next 
self:SetResponse(oRet:toJson())
RestArea(aArea)
RestArea(aSC5Area)
RETURN .T.









/*
procMonitorDoc (
     cIdEnt          Entidade do TSS para processamento
     cUrl          endereço do Web Wervice no TSS
     aParam          Parametro para a busca dos documetnos, de acordo com o tipo nTpMonitor
     nTpMonitor     tipo do monitor (1=por intervalo de notas, 2=por lote de IDs,3=por tempo)
     cModelo          modelo do documento (se não for passado, será assumido ‘55‘)
     lCte          indica se o modelo é Cte
     cAviso          variavel que receberá uma possível mensagem de erro (deve ser passada por referência)
     lUsaColab     indica se usa TOTVS colaboração
)

se nTpMonitor=1 -> aParam := { SerieNF, NotaINI, NotaFIM, DataDe, DataAte }
se nTpMonitor=2 -> aParam := { {IDLote}, {IDLote}, {IDLote}, {IDLote} }
se nTpMonitor=3 -> aParam := { Tempo }

a função retorna um array, com a seguinte estrutura:
{ cId,
cSerie,
cNota,
cProtocolo,
cRetCodNfe,
cMsgRetNfe,
nAmbiente,
nModalidade,
cRecomendacao,
cTempoDeEspera,
nTempomedioSef,
aLote,
lUpd,
.F.
}          
onde:
nAmbiente -> 1=Produção, 2=Homologação
nModalidade ->     se lUsaColab: 1=Normal, n=Contingencia
          se lUsaColab=.F.: 1,4 ou 6=Normal, n=Contingência

*/


WSMETHOD GET INC_PEDIDOV WSRECEIVE Nota WSSERVICE RSTFATAUT

Local Serie := "1"
Local Notasefaz := ""
local cURL          := alltrim(PadR(GetNewPar("MV_SPEDURL","http://"),250))
local aParam          := {}
local nTpMonitor     := 1 // por intervalo de notas
local cModelo          := "55" // NFe
local lCte          := .F.
local cAviso          := ""
local lUsaColab          := .F.
local aRetorno
local cIdEnt, cError
Local oRet	 := JsonObject():new()
Local i
Local oWS    
Local lOk      := .T.
Local oRetorno
::SetContentType("application/json; charset=iso-8859-1")
Notasefaz := oRest:getQueryRequest()["Nota"]
aParam := { Serie, Notasefaz, Notasefaz }

    If Empty(Notasefaz)
		SetRestFault(400,EncodeUTF8("Necessário enviar Nota Fiscal"),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
		Return .F.
	Endif


     If CTIsReady(,,,lUsaColab)
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³Obtem o codigo da entidade                                              ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          cIdEnt := getCfgEntidade(@cError)
          
          if !empty(cError)
               Alert(cError)
               return
          endif
     Endif

    oWs:= WsNFeSBra():New()
    oWs:cUSERTOKEN   := "TOTVS"
    oWs:cID_ENT      := cIdEnt
    oWs:_URL        := AllTrim(cURL)+"/NFeSBRA.apw"
    oWS:cIdInicial := Notasefaz
    oWS:cIdFinal      := Notasefaz
    lOk := oWS:MONITORFAIXA()
    oRetorno := oWS:oWsMonitorFaixaResult
     aRetorno := procMonitorDoc(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, @cAviso, lUsaColab)

     if empty(cAviso) // tudo certo
          // faz a varredura no aRetorno
            
            //For i := 1 To Len(aRetorno)
            //    cMensagem += aRetorno[i] + CRLF + (" ")
            //Next
                oRet["Result"] := aRetorno
                
                self:SetResponse(oRetorno:toJson())
                FreeObj(oRet)
                

     else // ocorreu alguma falha
          SetRestFault(418,EncodeUTF8(cAviso),.T.,/*nStatus*/,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
     endif



return .T.








































































Static Function LimpPed(oBody,nPCount,aCabec)
Local cMensagem := ""
Local i
local lFaturado        := .F.
local lLiberado        := .F.
local lPodeExcluir     := .T.
local cPedido
local clog := ""
local aLogAuto
Private lMSHelpAuto    := .T.
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.


    DbSelectArea("SC5")
    SC5->(DbOrderNickName("ORDFAT"))
    SC5->(DBGOTOP(  ))
    if DbSeek(xFilial("SC5")+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"]))
      
        if DbSeek(xFilial("SC5")+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"]))
            cPedido := SC5->C5_NUM
            SC6->( dbGoTop() )
            SC6->( dbSeek( oBody["Pedidos"][nPCount]["C5_FILIAL"] + cPedido ) )

          // avalia os itens, de modo a eliminar resíduos caso haja faturamento
            while !SC6->(EOF()) .AND. SC6->C6_FILIAL == oBody["Pedidos"][nPCount]["C5_FILIAL"] .AND. SC6->C6_NUM == SC5->C5_NUM
               // tenta estornar as liberações do item
               MaAvalSC6("SC6",4,"SC5",Nil,Nil,Nil,Nil,Nil,Nil)
               
               lFaturado := (SC6->C6_QTDENT > 0)
               lLiberado := (SC6->C6_QTDEMP > 0)

ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
                    ConOut(PadC(lFaturado, 80))
                    ConOut(PadC(lLiberado, 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))


                // se há liberação ou faturamento, o pedido não pode ser excluido!
                if lLiberado .OR. lFaturado
                    lPodeExcluir := .F.
                endif

                // se não pode excluir e não estiver liberado, tento eliminar o resíduo do item
                if !lPodeExcluir .AND. !lLiberado
                    if lFaturado
                       cMensagem += EncodeUTF8("Esse pedido já foi faturado")
                       exit
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
                    ConOut(PadC(lFaturado, 80))
                    ConOut(PadC(lLiberado, 80))
                    ConOut(PadC(cMensagem, 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))


                    else
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
                    ConOut(PadC(lFaturado, 80))
                    ConOut(PadC(lLiberado, 80))
                    ConOut(PadC("Tentou limpar", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
ConOut(Repl("-", 80))
                        MaResDoFat()
                    endif
                endif

               SC6->( dbSkip() )
            enddo

          // depois de processar cada item do pedido, verifico
          // a possibilidade de excluir o pedido
          // obs.: o procedimento de eliminação de resídios, dentro do loop
          // já se encarrega de encerrar o pedido por resíduo
            if lPodeExcluir
               lMsErroAuto := .F.
               MATA410(aCabec, {} , 5)
               if lMsErroAuto
            
                    aLogAuto := GetAutoGRLog()
            
                    For i := 1 To Len(aLogAuto)
                        clog += aLogAuto[i] + CRLF + (" ")
                    
                    Next
                    //cMensagem += Mostraerro()
                    ConOut(Repl("-", 80))
                    ConOut(PadC("MATA410 automatic routine ended with error", 80))
                    ConOut(PadC("Falhou ao Deletar", 80))
                    ConOut(PadC(clog, 80))
                    ConOut(PadC("Ended at: " + Time(), 80))
                    ConOut(Repl("-", 80))
                    

                    
               
               
               
                else


                    ConOut(Repl("-", 80))
                    ConOut(PadC("MATA410 automatic routine successfully ended", 80))
                    ConOut(PadC("Deletou com sucesso", 80))
                    ConOut(PadC(cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"Deletado", 80))
                    ConOut(PadC("Ended at: " + Time(), 80))
                    ConOut(Repl("-", 80))
                
                endif
            else

               if !EMPTY(SC5->C5_NOTA) .OR. (SC5->C5_LIBEROK = ‘E‘)

                    ConOut(Repl("-", 80))
                    ConOut(PadC("Resíduos do pedido "+cPedido+" foram eliminados. O pedido foi encerrado!", 80))
                    ConOut(PadC("Ended at: " + Time(), 80))
                    ConOut(Repl("-", 80))

                endif
            endif

        endif
        if cMensagem == ""
            AAdd(aCabec, {"C5_NUM", cPedido, NIL})
            lMsErroAuto := .F.
            MATA410(aCabec, {} , 5)
            if lMsErroAuto

                LogAuto := GetAutoGRLog()
                cMensagem += clog
                For i := 1 To Len(aLogAuto)
                    cMensagem += aLogAuto[i] + CRLF + (" ")
                Next
                //cMensagem += Mostraerro()
                ConOut(Repl("-", 80))
                ConOut(PadC("MATA410 automatic routine ended with error", 80))
                ConOut(PadC("não deu certo", 80))
                ConOut(PadC("Ended at: " + Time(), 80))
                ConOut(Repl("-", 80))
                oRet["Result"][cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])] := EncodeUTF8(cMensagem)

            endif

        endif
    endif
    lMSHelpAuto    := .T.
    lAutoErrNoFile := .T.
    lMsErroAuto    := .F.
    SC6->(DbCloseArea())
    SC5->(DbCloseArea())
    
Return cMensagem










Static Function NatuCli(codiloj,natureza)//U_TesteCli
    Local cMensagem := ""
    Local aDados
    Local aLogAutoCli 
    Local i
    Private lMSHelpAuto    := .T.
    Private lAutoErrNoFile := .T.
    Private lMsErroAuto    := .F.
    
    DbSelectArea("SA1")
    dbSetOrder(1)
    SA1->(DBGOTOP(  ))
    DbSeek("0101  "+codiloj) //Alteração deve ter o registro SA1 posicionado
        aDados := {{"A1_COD", SA1->A1_COD,NIL},;
               {"A1_LOJA", SA1->A1_LOJA,NIL},;
               {"A1_NATUREZ", natureza,NIL}}
    MsExecAuto( { |x,y| Mata030(x,y)},aDados, 4) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
        If (lMsErroAuto)
            aLogAutoCli := GetAutoGRLog()
            For i := 1 To Len(aLogAutoCli)
                cMensagem += aLogAutoCli[i] + CRLF + (" ")
            Next
            //cMensagem += Mostraerro()
            ConOut(Repl("-", 80))
            ConOut(PadC("Mata030 automatic routine ended with error", 80))
            ConOut(PadC("Ended at: " + Time(), 80))
            ConOut(Repl("-", 80))
        Else
            ConOut(Repl("-", 80))
            ConOut(PadC("Mata030 automatic routine successfully ended", 80))
            ConOut(PadC("Ended at: " + Time(), 80))
            ConOut(Repl("-", 80))
        EndIf
    lMSHelpAuto    := .T.
    lAutoErrNoFile := .T.
    lMsErroAuto    := .F.
    SA1->(DbCloseArea())
Return  cMensagem


Static Function Fatura(Pedido)

    Local aPvlDocS := {}
    Local nPrcVen := 0
    Local cSerie  := "1"
    Local cEmbExp := ""
    Local cDoc    := ""
    
        SC5->(DbSetOrder(1))
    SC5->(MsSeek(xFilial("SC5")+Pedido))

    SC6->(dbSetOrder(1))
    SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))

    //É necessário carregar o grupo de perguntas MT460A, se não será executado com os valores default.
    Pergunte("MT460A",.F.)

    // Obter os dados de cada item do pedido de vendas liberado para gerar o Documento de Saída
    While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And. SC6->C6_NUM == SC5->C5_NUM

        SC9->(DbSetOrder(1))
        SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM

        SE4->(DbSetOrder(1))
        SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

        SB1->(DbSetOrder(1))
        SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

        SB2->(DbSetOrder(1))
        SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL

        SF4->(DbSetOrder(1))
        SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

        nPrcVen := SC9->C9_PRCVEN
        If ( SC5->C5_MOEDA <> 1 )
            nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
        EndIf

		If AllTrim(SC9->C9_BLEST) == "" .And. AllTrim(SC9->C9_BLCRED) == ""
        	AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
                        	SC9->C9_ITEM,;
                        	SC9->C9_SEQUEN,;
                        	SC9->C9_QTDLIB,;
                        	nPrcVen,;
                        	SC9->C9_PRODUTO,;
                        	.F.,;
                        	SC9->(RecNo()),;
                        	SC5->(RecNo()),;
                        	SC6->(RecNo()),;
                        	SE4->(RecNo()),;
                        	SB1->(RecNo()),;
                        	SB2->(RecNo()),;
                        	SF4->(RecNo())})
		EndIf

        SC6->(DbSkip())
    EndDo

	SetFunName("MATA461")
    cDoc := MaPvlNfs(  /*aPvlNfs*/         aPvlDocS,;  // 01 - Array com os itens a serem gerados
                       /*cSerieNFS*/       cSerie,;    // 02 - Serie da Nota Fiscal
                       /*lMostraCtb*/      .F.,;       // 03 - Mostra Lançamento Contábil
                       /*lAglutCtb*/       .F.,;       // 04 - Aglutina Lançamento Contábil
                       /*lCtbOnLine*/      .F.,;       // 05 - Contabiliza On-Line
                       /*lCtbCusto*/       .T.,;       // 06 - Contabiliza Custo On-Line
                       /*lReajuste*/       .F.,;       // 07 - Reajuste de preço na Nota Fiscal
                       /*nCalAcrs*/        0,;         // 08 - Tipo de Acréscimo Financeiro
                       /*nArredPrcLis*/    0,;         // 09 - Tipo de Arredondamento
                       /*lAtuSA7*/         .T.,;       // 10 - Atualiza Amarração Cliente x Produto
                       /*lECF*/            .F.,;       // 11 - Cupom Fiscal
                       /*cEmbExp*/         cEmbExp,;   // 12 - Número do Embarque de Exportação
                       /*bAtuFin*/         {||},;      // 13 - Bloco de Código para complemento de atualização dos títulos financeiros
                       /*bAtuPGerNF*/      {||},;      // 14 - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
                       /*bAtuPvl*/         {||},;      // 15 - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
                       /*bFatSE1*/         {|| .T. },; // 16 - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
                       /*dDataMoe*/        dDatabase,; // 17 - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
                       /*lJunta*/          .F.)        // 18 - Aglutina Pedido Iguais
    
    If !Empty(cDoc)
        Conout("Documento de Saída: " + cSerie + "-" + cDoc + ", gerado com sucesso!!!")
    EndIf

Return cDoc
