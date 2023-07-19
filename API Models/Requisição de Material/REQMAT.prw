#INCLUDE "totvs.ch"
#INCLUDE "RestFul.ch"

User Function REQMAT()
    MsgAlert("Rest", "Rest")
return

WSRESTFUL REQMAT DESCRIPTION "Servico REST para manipulacao de Requisição de Material"
    WSDATA SoldeComp as String
    WSMETHOD POST DESCRIPTION "Cria o Requisição com body informado" WSSYNTAX "/REQMAT" PATH "/REQMAT" PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD POST WSSERVICE REQMAT

Local lOk := .T.
Local aCab := {}
Local aItens := {}
LOCAL nICount := 0
LOCAL nRCount := 0
LOCAL oPreReq := JsonObject():New()
LOCAL oReqItem := JsonObject():New()
LOCAL i := 0
local nSaldoAtual
local descprod := ""
Local aResult := {}
Local oResult := JsonObject():new()
Local oRequisicao := JsonObject():New()
Private lMsErroAuto := .F.
Private lMsErroHelp := .T.
Private lAutoErrNoFile :=  .t.


Self:SetContentType("application/json")
cError := oRequisicao:fromJson( self:getContent() )
ConOut(cError)
ConOut("----------------------------------\n")
ConOut(cvaltochar(oRequisicao))
ConOut("----------------------------------\n")

IF Empty(cError)
    FOR nRCount := 1 to Len(oRequisicao["Requisicao"])
        aItens := {}
        aCab := {}


        cError := ""

        //Aadd( aCab, { "CP_NUM" ,oRequisicao["Requisicao"][nRCount]["CP_NUM"] , Nil })
        Aadd( aCab, { "CP_EMISSAO" ,CTOD(oRequisicao["Requisicao"][nRCount]["CP_EMISSAO"] ) , Nil })
        Aadd( aCab, { "CP_SOLICIT" ,oRequisicao["Requisicao"][nRCount]["CP_SOLICIT"] , Nil })
        
        oReqItem := JsonObject():New()

        oReqItem["Requisicao"] := oRequisicao["Requisicao"][nRCount]["CP_YPIPID"]
        oReqItem["Integral"] := oRequisicao["Requisicao"][nRCount]["CP_YINTEGR"]
        oReqItem["STATUS"] := ""
        oReqItem["Error"] := ""
        oReqItem["Itens"] := {}
        
        FOR nICount := 1 to Len(oRequisicao["Requisicao"][nRCount]["ITENS"])

            /////////////////////////////////
            //     Validação de Itens     //
            ////////////////////////////////

            // Valida se existe req, devera ser criado o indice
            DbSelectArea("SCP")
            SCP->(DbOrderNickName("REQPIPE"))
            SCP->(DBGOTOP(  ))
            if DbSeek(xFilial("SCP")+PADR(cvaltochar(oRequisicao["Requisicao"][nRCount]["CP_YPIPID"]),TAMSX3("CP_YPIPID")[1])+PADR(cvaltochar(oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_YTRI"]),TAMSX3("CP_YTRI")[1]))
                cError := cError + EncodeUTF8(  "Produto ja adicionado chave = "+ xFilial("SCP")+cvaltochar(oRequisicao["Requisicao"][nRCount]["CP_YPIPID"])+cvaltochar(oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_YTRI"]) + CRLF)
            EndIF
            DBCLOSEAREA("SCP")
            

            DbSelectArea("CTT")
            dbSetOrder(1)
            CTT->(DBGOTOP(  ))
            if !DbSeek("010101"+ oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_CC"])
                cError := cError + EncodeUTF8(  "O Centro de Custo nao existe, CC = "+ oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_CC"] + " " + CRLF)
            end if
            DBCLOSEAREA("CTT")

        
            DbSelectArea("SB1")
            dbSetOrder(1)
            SB1->(DBGOTOP(  ))
            if !DbSeek("010101"+ oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_PRODUTO"])
                cError := cError + EncodeUTF8(  "Produto não encontrado, Produto = "+ oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_PRODUTO"] + " " + CRLF)
            else 
                descprod := TRIM(SB1->B1_DESC)
            end if
            DBCLOSEAREA("SB1")
        



            if oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_QUANT"] <= 0
                cError := cError + EncodeUTF8(  "Quantidade invalida, Quantidade = "+ cvaltochar(oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_QUANT"]) + " " + CRLF)
            end if

            /////////////////////////////////
            //     Validação de Itens     //
            ////////////////////////////////

            aadd(aItens,   {{"CP_ITEM" , oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_ITEM"]            , Nil },;
                            {"CP_YPIPID" ,oRequisicao["Requisicao"][nRCount]["CP_YPIPID"]       , Nil },;
                            {"CP_YINTEGR" ,oRequisicao["Requisicao"][nRCount]["CP_YINTEGR"]       , Nil },;
                            {"CP_PRODUTO" ,oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_PRODUTO"]       , Nil },;
                            {"CP_QUANT" ,oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_QUANT"]           , Nil },;
                            {"CP_DATPRF" ,CTOD(oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_DATPRF"])   , Nil },;
                            {"CP_OBS" ,oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_OBS"]               , Nil },;
                            {"CP_YTRI" ,oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_YTRI"]               , Nil },;
                            {"CP_CC" ,oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_CC"]                 , Nil }})


            nSaldoAtual := VerificaSaldo(oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_PRODUTO"])
            
            
            AADD(oReqItem["Itens"],JsonObject():New())
            oReqItem["Itens"][nICount]["COD"] := oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_PRODUTO"]
            oReqItem["Itens"][nICount]["QtdSuficiente"] := oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_QUANT"] <  nSaldoAtual
            oReqItem["Itens"][nICount]["CP_YTRI"] := oRequisicao["Requisicao"][nRCount]["ITENS"][nICount]["CP_YTRI"]
            oReqItem["Itens"][nICount]["DESC"] := descprod
            ConOut(cvaltochar(oReqItem))


        Next

        if Empty(cError)
            MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aCab, aItens , 3 )

            if (lMsErroAuto)
                            
                aLogAuto := GetAutoGRLog()

                For i := 1 To Len(aLogAuto)
                    cError += aLogAuto[i] + CRLF + (" ")
                Next

                ConOut(cError)
                //Result += "'" + oRequisicao["Requisicao"][nRCount]["CP_NUM"] + '" : "' + cError + "}'
                oReqItem["STATUS"] := "Error"
                cError := cError + " " 
                oReqItem["Error"] := cError
            else
                //Result += '"' + oRequisicao["Requisicao"][nRCount]["CP_NUM"] + '" : "Success"'
                oReqItem["STATUS"] := "Success"
                ConOut(oReqItem)
            end if
        else
            //Result += "'" + oRequisicao["Requisicao"][nRCount]["CP_NUM"] + '" : "' + cError + "}'
            oReqItem["STATUS"] := "Error"
            cError := cError + " "
            oReqItem["Error"] := cError
        end if
        AADD(aResult,oReqItem)
    NEXT
    oPreReq := GerarPreReq()
    if oPreReq["status"] == .f.
        connout(oPreReq["Error"] )
    end if
    //Result += ' }}'
    ConOut(cError)

    oResult:Set(aResult)
 
    ::SetResponse(EncodeUTF8(cvaltochar(oResult)))
    return lOk

EndIf
SetRestFault(418,EncodeUTF8(cError),.T.,418,/*cDetailMsg*/,/*cHelpUrl*/,/*aDetails*/)
ConOut(cError)
lOk := .F.
return lOk
// https://tdn.totvs.com/pages/releaseview.action?pageId=6087459





Static Function GerarPreReq() //u_testenota
local lMarkB, lDtNec
local BFiltro   := {|| .T.}
local lConsSPed, lGeraSC1, lAmzSA
local cSldAmzIni, cSldAmzFim
local lLtEco, lConsEmp
local nAglutSC
local lAuto, lEstSeg
local aRecSCP
local lRateio
local aLogAuto := {}
local i
local oRetorno := JsonObject():New()
Private lMsErroAuto := .F.
Private lMsErroHelp := .T.

     // preenche os parâmetros MV_PARnn com as respostas das perguntas da rotina MATA106
     Pergunte("MTA106",.F.)

     lMarkB     := .F.
     lDtNec     := (MV_PAR01 == 1)
     BFiltro    := BFiltro
     lConsSPed := (MV_PAR02 == 1)
     lGeraSC1   := (MV_PAR03 == 1)
     lAmzSA     := (MV_PAR04 == 1)
     cSldAmzIni := MV_PAR05
     cSldAmzFim := MV_PAR06
     lLtEco     := (MV_PAR07 == 1)
     lConsEmp   := (MV_PAR08 == 1)
     nAglutSC   := MV_PAR09
     lAuto      := .T.
     lEstSeg    := (MV_PAR10 == 1)
     aRecSCP    := {}
     lRateio    := .F.

     MaSAPreReq(lMarkB,lDtNec,BFiltro,lConsSPed,lGeraSC1,lAmzSA,cSldAmzIni,cSldAmzFim,lLtEco,lConsEmp,nAglutSC,lAuto,lEstSeg,@aRecSCP,lRateio)
     if (lMsErroAuto)
                            
        aLogAuto := GetAutoGRLog()
        For i := 1 To Len(aLogAuto)
            cError += aLogAuto[i] + CRLF + (" ")
        Next
        oRetorno["status"] := .f.
        oRetorno["Error"] := cError
        ConOut(cError)
     else 
        oRetorno["status"] := .t.
        ConOut("Pre-Requisicoes Geradas com Sucesso")
        
     endif


Return oRetorno


STATIC Function VerificaSaldo(Produto) 
    local cCodigoProd := PADR(Produto,TAMSX3("B1_COD")[1])         
    local nSaldoAtual
    local nSaldoResidual
    // Valida se existe req, devera ser criado o indice
    DbSelectArea("SB2")
    SB2->(DBSETORDER( 1 ))
    SB2->(DBGOTOP(  ))
    if DbSeek(xFilial("SB2")+cCodigoProd)
        nSaldoAtual := SB2->B2_QATU
    EndIF
    DBCLOSEAREA("SB2")

    BeginSql Alias "SCP_TMP"
                    SELECT sum(CP_QUANT) - sum(CP_QUJE) as qtd,CP_PRODUTO 
                    FROM SCP010 as SCP
                    WHERE CP_PRODUTO = %exp:cCodigoProd% and D_E_L_E_T_ = '' and CP_STATUS = ''
                    GROUP BY CP_PRODUTO
                    EndSql
    nSaldoResidual := SCP_TMP->qtd
    ("SCP_TMP")->(dbCloseArea())


    nSaldoAtual := nSaldoAtual - nSaldoResidual


Return nSaldoAtual




