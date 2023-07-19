#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

USER FUNCTION RSTFATAUT
RETURN

WSRESTFUL RSTFATAUT DESCRIPTION "FATURAMENTO AUTOMATICO"
    WSDATA TESTE AS STRING

    WSMETHOD POST INC_PEDIDOV;
    DESCRIPTION "INCLUSÃƒO DO PEDIDO DE VENDA(OV)";
    WSSYNTAX "/INC_PEDIDOV/";
    PRODUCES APPLICATION_JSON ;
    PATH "/INC_PEDIDOV"
ENDWSRESTFUL

WSMETHOD POST INC_PEDIDOV WSRECEIVE PEDIDO WSSERVICE RSTFATAUT

Local oBody := JsonObject():new()
Local oRet := JsonObject():new()
Local lRet := .T.
Local cMensagem := ""
Local nPCount
Local nICount
Local nOpec := 3
Local aCabec := {}
Local aDados := {}
Local aLinha := {}
Local aArea := {}
Local i
local aLogAuto
Private lMSHelpAuto     := .T.
Private lAutoErrNoFile  := .T.
Private lMsErroAuto     := .F.

cBody:= ::GetContent()
oBody:Fromjson(cBody)
oRet["Result"] := JsonObject():new()
aArea := GetArea()

For nPCount := 1 to Len(oBody["Pedidos"])
    //Validação de estrutura de campos
    cMensagem := ""
    aCabec := {}
    
    IF Empty(oBody["Pedidos"][nPCount]["C5_FILIAL"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_FILIAL" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_FILIAL"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_FILIAL deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_FILIAL"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_FILIAL", oBody["Pedidos"][nPCount]["C5_FILIAL"], NIL})
        ENDIF
    ENDIF

    aadd(aCabec,{"C5_TIPO" ,"N",Nil})
    aadd(aCabec,{"C5_EMISSAO" ,Date(),NIL})

    IF Empty(oBody["Pedidos"][nPCount]["C5_CLIENTE"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_CLIENTE" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_CLIENTE"]) != "C"
            cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_CLIENTE deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_CLIENTE"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_CLIENTE", oBody["Pedidos"][nPCount]["C5_CLIENTE"], NIL})
        ENDIF
    ENDIF


    IF Empty(oBody["Pedidos"][nPCount]["C5_LOJACLI"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_LOJACLI" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_LOJACLI"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_LOJACLI deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_LOJACLI"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_LOJACLI", oBody["Pedidos"][nPCount]["C5_LOJACLI"], NIL})
            AAdd(aCabec, {"C5_LOJAENT", oBody["Pedidos"][nPCount]["C5_LOJACLI"], NIL})
        ENDIF
    ENDIF
    
    aadd(aCabec,{"C5_NATCLI","000001",Nil})


    IF Empty(oBody["Pedidos"][nPCount]["C5_VEND1"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_VEND1" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_VEND1"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_VEND1 deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_VEND1"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_VEND1", oBody["Pedidos"][nPCount]["C5_VEND1"], NIL})
        ENDIF
    ENDIF
    
    IF Empty(oBody["Pedidos"][nPCount]["C5_CONDPAG"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_CONDPAG" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_CONDPAG"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_CONDPAG deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_CONDPAG"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_CONDPAG", oBody["Pedidos"][nPCount]["C5_CONDPAG"], NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_MENNOTA"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_MENNOTA" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_MENNOTA"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_MENNOTA deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_MENNOTA"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_MENNOTA", oBody["Pedidos"][nPCount]["C5_MENNOTA"], NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_FRETE"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_FRETE" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_FRETE"]) != "N"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_FRETE deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_FRETE"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_FRETE", oBody["Pedidos"][nPCount]["C5_FRETE"], NIL})
        ENDIF
    ENDIF


    IF Empty(oBody["Pedidos"][nPCount]["C5_YNUM"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_YNUM" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_YNUM"]) != "N"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_YNUM deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_YNUM"])) + " " + CRLF)
        ELSE
           AAdd(aCabec, {"C5_YNUM", oBody["Pedidos"][nPCount]["C5_YNUM"], NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_YPEDCLI"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_YPEDCLI" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_YPEDCLI"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_YPEDCLI deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_YPEDCLI"])) + " " + CRLF)
        ELSE
                AAdd(aCabec, {"C5_YPEDCLI", oBody["Pedidos"][nPCount]["C5_YPEDCLI"], NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_EMAIL"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_EMAIL" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_EMAIL"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_EMAIL deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_EMAIL"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_EMAIL", oBody["Pedidos"][nPCount]["C5_EMAIL"], NIL})
        ENDIF
    ENDIF

    IF Empty(oBody["Pedidos"][nPCount]["C5_TRANSP"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_TRANSP" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_TRANSP"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_TRANSP deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_TRANSP"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_TRANSP", oBody["Pedidos"][nPCount]["C5_TRANSP"], NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_MENPAD"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_MENPAD" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_MENPAD"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_MENPAD deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_MENPAD"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_MENPAD", oBody["Pedidos"][nPCount]["C5_MENPAD"], NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_TPFRETE"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_TPFRETE" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_TPFRETE"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_TPFRETE deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_TPFRETE"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_TPFRETE", oBody["Pedidos"][nPCount]["C5_TPFRETE"], NIL})
        ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_PESOL"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_PESOL" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_PESOL"]) != "N"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_PESOL deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_PESOL"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_PESOL", oBody["Pedidos"][nPCount]["C5_PESOL"], NIL})
        ENDIF
    ENDIF
    
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_PBRUTO"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_PBRUTO" + " " + CRLF)
    ELSE
            IF ValType(oBody["Pedidos"][nPCount]["C5_PBRUTO"]) != "N"
                        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_PBRUTO deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_PBRUTO"])) + " " + CRLF)
            ELSE
                AAdd(aCabec, {"C5_PBRUTO", oBody["Pedidos"][nPCount]["C5_PBRUTO"], NIL})
            ENDIF
    ENDIF
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_VOLUME1"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_VOLUME1" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_VOLUME1"]) != "N"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_VOLUME1 deve ser numérico, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_VOLUME1"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_VOLUME1", oBody["Pedidos"][nPCount]["C5_VOLUME1"], NIL})
        ENDIF
    ENDIF
    
    

    IF Empty(oBody["Pedidos"][nPCount]["C5_ESPECI1"])
        cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C5_ESPECI1" + " " + CRLF)
    ELSE
        IF ValType(oBody["Pedidos"][nPCount]["C5_ESPECI1"]) != "C"
                    cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C5_ESPECI1 deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["C5_ESPECI1"])) + " " + CRLF)
        ELSE
            AAdd(aCabec, {"C5_ESPECI1", oBody["Pedidos"][nPCount]["C5_ESPECI1"], NIL})
        ENDIF
    ENDIF

    For nICount := 1 to Len(oBody["Pedidos"][nPCount]["ITENS"])
        aLinha := {}
        
        aadd(aLinha,{"C6_ITEM",StrZero(nICount,2),Nil})


        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRODUTO"])
            cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C6_PRODUTO" + " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRODUTO"]) != "C"
                cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C6_PRODUTO deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRODUTO"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_PRODUTO",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRODUTO"], NIL})
            ENDIF
        ENDIF

        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDVEN"])
            cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C6_QTDVEN"+ " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDVEN"]) != "N"
                cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C6_QTDVEN deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDVEN"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_QTDVEN",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDVEN"], NIL})
            ENDIF
        ENDIF

        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"])
            cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C6_PRCVEN" + " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"]) != "N"
                cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C6_PRCVEN deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_PRCVEN",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"], NIL})
                AAdd(aLinha, {"C6_PRUNIT",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_PRCVEN"], NIL})
            ENDIF
        ENDIF


        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_VALOR"])
            cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C6_VALOR"+ " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_VALOR"]) != "N"
                cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C6_VALOR deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_VALOR"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_VALOR",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_VALOR"], NIL})
            ENDIF
        ENDIF


        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDLIB"])
            cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C6_QTDLIB" + " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDLIB"]) != "N"    
                cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C6_QTDLIB deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDLIB"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_QTDLIB",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_QTDLIB"], NIL})
            ENDIF
        ENDIF



        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_TES"])
            cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C6_TES"+ " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_TES"]) != "C"
                cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C6_TES deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_TES"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_TES",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_TES"], NIL})
            ENDIF
        ENDIF


        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_NUMPCOM"])
            cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C6_TES"+ " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_NUMPCOM"]) != "C"
                cMensagem += EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C6_NUMPCOM deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_NUMPCOM"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_NUMPCOM",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_NUMPCOM"], NIL})
            ENDIF
        ENDIF

        IF Empty(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_ITPC"])
            cMensagem := EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= Necessário enviar C6_ITPC" + " " + CRLF)
        ELSE
            IF ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_ITPC"]) != "C"
                cMensagem := EncodeUTF8(" Pedido: "+cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])+"= C6_ITPC deve ser caractere, tipo recebido = "+ cvaltochar(ValType(oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_ITPC"])) + " " + CRLF)
            ELSE
                AAdd(aLinha, {"C6_ITPC",oBody["Pedidos"][nPCount]["ITENS"][nICount]["C6_ITPC"], NIL})
            ENDIF
        ENDIF


        AAdd(aDados, aLinha)
    Next
    IF cMensagem != '' 
        oRet["Result"][cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])] := cMensagem 
    ELSE 
        
        ConOut(Repl("-", 80))
        ConOut(Repl("-", 80))
        ConOut(Repl("-", 80))
        ConOut(Repl("-", 80))
        ConOut(Repl("-", 80))
        ConOut(Repl("-", 80))
        ConOut(Repl("-", 80))
        ConOut("Executando MSExecAuto")
        MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aDados, nOpec)
        ConOut("Fim MSExecAuto")
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
            oRet["Result"][cvaltochar(oBody["Pedidos"][nPCount]["C5_YNUM"])] := "Success" 
        EndIf
    ENDIF
Next 
self:SetResponse(oRet:toJson())
RestArea(aArea)
RETURN .T.
