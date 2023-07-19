#INCLUDE 'TOTVS.ch'

/*/{Protheus.doc} User Function Reltxt
    (Essa função tem por objetivo chamar a função de criação de TXT)
    @type  Function
    @author Erlandeson
    @since 18/07/2022
    @version 1.0
    @return Nil /*/
User Function Reltxt()
IF MSGYESNO("Essa função tem como objetivo gerar aquivo TXT")
    GeraArq()
else
Alert("Cancelada pelo Operador")    
ENDIF
Return NIL

Static Function Qquery()
Local cQuery := ""
cQuery := " SELECT B1_FILIAL AS FILIAL, B1_COD AS CODIGO, B1_DESC AS NOME "
cQuery += " FROM SB1990 WHERE D_E_L_E_T_ = ''" 
cQuery := CHANGEQUERY(cQuery)
DBUSEAREA( .T., "TOPCONN", TCGENQRY( , , CQUERY ), 'TMP', .F., .T.) 
Return





/*/{Protheus.doc} GeraArq
    (Função de criação de txt)
    @type  Static Function
    @author Erlandeson
    @since 18/07/2022
    @version 1.0
/*/
Static Function GeraArq()
    Local cDir := "C:\ADVPL_LOCAL\"
    Local cArq := "Teste_Arquivo.txt"
    Local nHandle := FCREATE(cDir+cArq)
    if nHandle < 0
    MsgAlert("Erro ao criar o arquivo", "Erro")
    else
        For nLinha := 1 to 200
            FWRITE(nHandle,"Gravando a Linha " + StrZero(nLinha,3)+ CRLF)
        Next nLinha
        FCLOSE(nHandle)
    ENDIF
    if FILE(cDir+cArq)
        MsgInfo("Arquivo Criado com sucesso")
    else 
        MsgAlert("Não foi possivel criar o arquivo", "Alerta")
    ENDIF
Return 
