/*//#########################################################################################
Project  : Melhorias nos processos - FonNet
Module   : Financeiro
Source   : F240FIL
Objective: Filtrar título conforme escolha dos parametros
*///#########################################################################################

/*/{Protheus.doc} F240FIL
    Gerenciador de Processamento
    @author  Dilson Castro
    @table   SA2, SE2
    @since   15-06-2022
    @type    function
/*/

User Function F240FIL()
    Local cRet := ""
    If CMODPGTO == '01' // CREDITO EM CONTA
        If !Empty(Alltrim(SE2->E2_FORBCO))
            cRet += " (cAliasSE2)->E2_PORTADO = '   ' .And. CODBAR Subs((cAliasSE2)->E2_CODBAR,1,3) = '   ' .And. (cAliasSE2)->E2_FORBCO = '"+CPORT240+"'"
        Else
            cRet += " (cAliasSE2)->E2_PORTADO = '   ' .And. Subs((cAliasSE2)->E2_CODBAR,1,3) = '   ' .And. POSICIONE('SA2', 1, xFilial('SA2') + (cAliasSE2)->E2_FORNECE + (cAliasSE2)->E2_LOJA, 'A2_BANCO') = '"+CPORT240+"'"
        EndIf
    ElseIf CMODPGTO $ '03_41_43' // DOC, TED MESMA TITULAR, TED OUTRO TITULAR
        If !Empty(Alltrim(SE2->E2_FORBCO))
            cRet += " (cAliasSE2)->E2_PORTADO = '   ' .And. Subs((cAliasSE2)->E2_CODBAR,1,3) = '   ' .And. (cAliasSE2)->E2_FORBCO != '"+CPORT240+"'"
        Else
            cRet += " (cAliasSE2)->E2_PORTADO = '   ' .And. Subs((cAliasSE2)->E2_CODBAR,1,3) = '   ' .And. POSICIONE('SA2', 1, xFilial('SA2') + (cAliasSE2)->E2_FORNECE + (cAliasSE2)->E2_LOJA, 'A2_BANCO') != '"+CPORT240+"'"
        EndIf
    ElseIf CMODPGTO == '30' // TITULOS BOLETO BANCO FONNET
            cRet += " Subs((cAliasSE2)->E2_CODBAR,1,3) != '   ' .And. Subs((cAliasSE2)->E2_CODBAR,1,3) = '"+CPORT240+"'"
    ElseIf CMODPGTO == '31' // TITULOS BOLETO BANCO OUTROS
            cRet += " !(Subs((cAliasSE2)->E2_CODBAR,1,3)) $ '   _"+CPORT240+"'"
    EndIf
Return cRet
