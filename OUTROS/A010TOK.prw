//Bibliotecas
#Include "TOTVS.ch"
#INCLUDE "TOPCONN.ch"
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  A010TOK                                                                                      |
 | Desc:  Ponto de entrada após inclusão ou alteração de produto                                                    |
 | Link:  http://tdn.totvs.com/pages/releaseview.action?pageId=6087681                                  |
 *------------------------------------------------------------------------------------------------------*/

User Function A010TOK()
    If Inclui
        Testeip()
    ENDIF
    LOGPRODINC()
    MsgInfo("<Span>Registro Inserido o Codigo é </Span><Span style=color:red;>"+M->B1_COD+"</Span><Span>!</Span>", "Sucesso!")
Return .T.

// FUNÇÃO PARA INCLUSÃO DE LOG DE REGISTROS
STATIC FUNCTION LOGPRODINC()
    Local cMensagem := "" 
    Local aArea := SB1->(GetArea())
    Local aCabec := {}
    Local cBanc := ""
    Local cMemoria := ""
    Local cQuery := ""
    Local cCod := SB1->B1_COD
    Local i

    AADD(aCabec, "B1_COD")
    AADD(aCabec, "B1_Desc")
    AADD(aCabec, "B1_UM")
    If Inclui
        cMemoria := "M->"+aCabec[1]
        cBanc := "SB1->"+aCabec[1]
        IF &cMemoria != &cBanc
            Begin Transaction
                dbSelectArea("YPL")
                dbSetOrder(1)
                dbGoTop()
                Reclock("YPL",.T.)
                    YPL_FILIAL  := xFilial("YPL")
                    YPL_CDP := &cMemoria
                    YPL_COD     := GetSXENum('YPL', 'YPL_COD')
                    YPL_USER     := UsrRetName(RetCodUsr())
                    YPL_OPERACAO := "INCLUIR"
                    YPL_ANTIGO   := ""
                    YPL_NOVO     := "Registro Incluido"
                    YPL_DATA     := dDataBase
                    YPL_HORA     := Time()
                YPL->(MsUnlock())
            End Transaction
        ENDIF




    Else
        For i:=1 to Len(aCabec)
            cMemoria := "M->"+aCabec[i]
            cBanc := "SB1->"+aCabec[i]
            IF &cMemoria != &cBanc
                Begin Transaction
                    dbSelectArea("YPL")
                    dbSetOrder(1)
                    dbGoTop()
                    Reclock("YPL",.T.)
                        YPL_FILIAL  := xFilial("YPL")
                        YPL_CDP := cCod
                        YPL_COD     := GetSXENum('YPL', 'YPL_COD')
                        YPL_USER     := UsrRetName(RetCodUsr())
                        YPL_OPERACAO := "ALTERAR"
                        YPL_ANTIGO   := &cBanc
                        YPL_NOVO     := &cMemoria
                        YPL_DATA     := dDataBase
                        YPL_HORA     := Time()
                    YPL->(MsUnlock())
                End Transaction
            ENDIF
        Next j
    ENDIF
    RestArea(aArea)
RETURN

// FUNÇÃO PARA PREPARAR CAMPOS DO JSON
Static Function Testeip()
    local cID_DATABASE := "302594305"
    local cID_FASE_DE_DESTINO := "316252342"
    Local aDados := {}
    AADD(aDados, cID_DATABASE)
    AADD(aDados, trim(M->B1_COD))
    AADD(aDados, trim(M->B1_Desc))
    AADD(aDados, trim(M->B1_TIPO))
    AADD(aDados, trim(M->B1_UM))
    AADD(aDados, trim(M->B1_locpad))
    AADD(aDados, trim(M->B1_Grupo))
    AADD(aDados, trim(M->B1_posipi))
    AADD(aDados, trim(M->B1_YPIPE))
    AADD(aDados, cID_FASE_DE_DESTINO)
    INCDPR(aDados)

Return

// FUNÇÃO PARA CONSUMO DO SERVIÇO REST
Static Function INCDPR(corpo)
    Local cURI      := "http://127.0.0.1:1000" // URI DO SERVIÇO REST
    Local cResource := "/cdproduto"                  // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI)      // CLIENTE PARA CONSUMO REST
    Local aHeader   := {}                      // CABEÇALHO DA REQUISIÇÃO

    // PREENCHE CABEÇALHO DA REQUISIÇÃO
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÇÃO
    oRest:SetPath(cResource)
    oRest:SetPostParams(GetJsonIPCP(corpo))

    // REALIZA O MÉTODO POST E VALIDA O RETORNO
    If (oRest:Post(aHeader))
        ConOut("POST: " + oRest:GetResult())
    Else
        ConOut("POST: " + oRest:GetLastError())
    EndIf
Return (NIL)


// CRIA O JSON QUE SERÁ ENVIADO NO CORPO (BODY) DA REQUISIÇÃO
Static Function GetJsonIPCP(corpo)
    Local bObject := {|| JsonObject():New()}
    Local oJson   := Eval(bObject)
    oJson["ID_DATABASE"]             := corpo[1]
    oJson["Valor_Codigo"]            := corpo[2]
    oJson["Valor_Descricao"]         := corpo[3]
    oJson["Valor_Tipo"]              := corpo[4]
    oJson["Valor_Unidade_de_medida"] := corpo[5]
    oJson["Valor_Amazem"]            := corpo[6]
    oJson["Valor_Grupo"]             := corpo[7]
    oJson["Valor_NCM"]               := corpo[8]
    oJson["ID_CARD"]                 := corpo[9]
    oJson["ID_FASE_DE_DESTINO"]      := corpo[10]
    
Return (oJson:ToJson())
