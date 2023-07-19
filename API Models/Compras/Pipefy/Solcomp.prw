#INCLUDE "totvs.ch"
#INCLUDE "RestFul.ch"

User Function Solcomp()
    MsgAlert("Rest", "Rest")
return

WSRESTFUL Solcomp DESCRIPTION "Servico REST para manipulacao de SC"
    WSDATA SoldeComp as String
    WSMETHOD POST DESCRIPTION "Retorna o produto informado na URL" WSSYNTAX "/Solcomp" PATH "/Solcomp" PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD POST WSSERVICE Solcomp
    Local cError as char
    Local aCabec := {}
    Local aItens := {}
    Local oResult := JsonObject():New()
    Local oSolicitacao := JsonObject():New()
    Local nSCount
    Local nICount
    lOCAL I
    Local lOk := .T.
    Private lMsErroAuto := .F.
    oResult["Result"] := JsonObject():New()
    Self:SetContentType("application/json")
    ConOut(self:getContent())
    cError := oSolicitacao:fromJson( self:getContent() )
    if Empty(cError)
        For nSCount := 1 to Len(oSolicitacao["Solicitacao"])
            aItens := {}
            aCabec := {}
            

            cError := ""

            /////////////////////////////////
            //   ValidaÁ„o de CabeÁario   //
            ////////////////////////////////

            DbSelectArea("SY3")
            dbSetOrder(1)
            SY3->(DBGOTOP(  ))
            if !DbSeek("0101  "+ oSolicitacao["Solicitacao"][nSCount]["C1_UNIDREQ"])
                cError := cError + EncodeUTF8(  "A Unidade de Requisicao nao existe, unidade de requisicao = "+ cvaltochar(oSolicitacao["Solicitacao"][nSCount]["C1_UNIDREQ"]) + " " + CRLF)
            end if
            DBCLOSEAREA("SY3")

            DbSelectArea("SY1")
            dbSetOrder(1)
            SY1->(DBGOTOP(  ))
            if !DbSeek("0101  "+ oSolicitacao["Solicitacao"][nSCount]["C1_CODCOMP"])
                cError := cError + EncodeUTF8(  "O Comprador nao existe, Comprador = "+ cvaltochar(oSolicitacao["Solicitacao"][nSCount]["C1_CODCOMP"]) + " " + CRLF)
            end if
            DBCLOSEAREA("SY1")
        
            /////////////////////////////////
            //   ValidaÁ„o de CabeÁario   //
            ////////////////////////////////


            
            aCabec :=   {{"C1_FILIAL"                     , oSolicitacao["Solicitacao"][nSCount]["C1_FILIAL"] , NIL},;
                        {"C1_SOLICIT"                     , oSolicitacao["Solicitacao"][nSCount]["C1_SOLICIT"], NIL},;
                        {"C1_EMISSAO"                     , CTOD(oSolicitacao["Solicitacao"][nSCount]["C1_EMISSAO"]), NIL},;
                        {"C1_UNIDREQ"                     , oSolicitacao["Solicitacao"][nSCount]["C1_UNIDREQ"], NIL},;
                        {"C1_CODCOMP"                     , oSolicitacao["Solicitacao"][nSCount]["C1_CODCOMP"], NIL}}
            
            FOR nICount := 1 to Len(oSolicitacao["Solicitacao"][nSCount]["Itens"])

                /////////////////////////////////
                //     ValidaÁ„o de Itens     //
                ////////////////////////////////
                
                

                DbSelectArea("SC1")
                SC1->(DbOrderNickName("SOCCOM"))
                SC1->(DBGOTOP(  ))
                if DbSeek(xFilial("SC1")+PADR(cvaltochar(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_YPIPID"]),10," ")+PADR(cvaltochar(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_ITEM"]),4," ")+PADR(cvaltochar(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_PRODUTO"]),15," "))
                    cError := cError + EncodeUTF8(  "Produto ja adicionado chave = "+ xFilial("SC1")+cvaltochar(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_YPIPID"])+cvaltochar(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_ITEM"])+cvaltochar(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_PRODUTO"]) + CRLF)
                EndIF
                DBCLOSEAREA("SC1")

                DbSelectArea("CTT")
                dbSetOrder(1)
                CTT->(DBGOTOP(  ))
                if !DbSeek("010101"+ oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_CC"])
                    cError := cError + EncodeUTF8(  "O Centro de Custo nao existe, CC = "+ oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_CC"] + " " + CRLF)
                end if
                DBCLOSEAREA("CTT")

            
                DbSelectArea("SB1")
                dbSetOrder(1)
                SB1->(DBGOTOP(  ))
                if !DbSeek("010101"+ oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_PRODUTO"])
                    cError := cError + EncodeUTF8(  "Produto n√£o encontrado, Produto = "+ oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_PRODUTO"] + " " + CRLF)
                end if
                DBCLOSEAREA("SB1")
            



                if oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_QUANT"] <= 0
                    cError := cError + EncodeUTF8(  "Quantidade invalida, Quantidade = "+ cvaltochar(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_QUANT"]) + " " + CRLF)
                end if

                /////////////////////////////////
                //     ValidaÁ„o de Itens     //
                ////////////////////////////////

                aadd(aItens,    {{"C1_ITEM"                        , oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_ITEM"],    NIL},;
                                {"C1_PRODUTO"                     , oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_PRODUTO"], NIL},;
                                {"C1_QUANT"                       , oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_QUANT"],   NIL},;
                                {"C1_VUNIT"                       , oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_VUNIT"],   NIL},;
                                {"C1_YPIPID"                      , oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_YPIPID"],   NIL},;
                                {"C1_CC"                          , oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_CC"],      NIL},;
                                {"C1_YDTSPIP"                     , CTOD(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_YDTSPIP"]), NIL},;
                                {"C1_DTAP1PI"                     , CTOD(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_DTAP1PI"]), NIL},;
                                {"C1_YPRIO"                       , oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_YPRIO"], NIL},;
                                {"C1_YTRI"                       , oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_YTRI"], NIL},;
                                {"C1_OBS"                         , EncodeUTF8(oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount]["C1_OBS"]), NIL}})
            Next

            





            if Empty(cError)
             //MSExecAuto({|x,y,z| Mata110(x,y,z)},aCabec,aItens,3)
                MSExecAuto({|x,y| mata110(x,y)},aCabec,aItens)


                if (lMsErroAuto)
                    
                    aLogAuto := GetAutoGRLog()

                    For i := 1 To Len(aLogAuto)
                        cError += aLogAuto[i] + CRLF + (" ")
                    Next

                    ConOut(cError)
                    //Result += "'" + cvaltochar(nSCount) + '" : "' + cError + "}'
                    oResult["Result"][oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount-1]["C1_YPIPID"]] := cError 

                else
                
                    //Result += '"' + cvaltochar(nSCount) + '" : "Success"'
                    oResult["Result"][oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount-1]["C1_YPIPID"]] := "Success"
                end if

            else 
                    oResult["Result"][oSolicitacao["Solicitacao"][nSCount]["Itens"][nICount-1]["C1_YPIPID"]] := cError 
            end if

        Next
        
        ConOut(cError)
        ConOut(oResult)
        ::SetResponse(EncodeUTF8(cvaltochar(oResult)))
        return lOk
    end if
    SetRestFault(418,EncodeUTF8(cError),.T.,418,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
    ConOut(cError)
    lOk := .F.
return lOk
