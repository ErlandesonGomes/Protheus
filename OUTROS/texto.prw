#INCLUDE 'TOTVS.ch'

/*/{Protheus.doc} User Function Reltxt
    (Essa fun��o tem por objetivo chamar a fun��o de cria��o de TXT)
    @type  Function
    @author Erlandeson
    @since 18/07/2022
    @version 1.0
    @return Nil /*/
User Function Reltxt()
IF MSGYESNO("Essa fun��o tem como objetivo gerar aquivo TXT")
    GeraArq()
else
Alert("Cancelada pelo Operador")    
ENDIF
Return NIL


/*/{Protheus.doc} GeraArq
    (Fun��o de cria��o de txt)
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
        MsgAlert("N�o foi possivel criar o arquivo", "Alerta")
    ENDIF
Return 
