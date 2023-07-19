#Include 'Protheus.ch'

User Function MT100TOK()

    Local aArea := GetArea()
    Local lRet := .T.

    if FunName() == 'FXREPDFE' .or. FunName() == 'MATA103'
        lRet := U_FXDFEAUDIT()
    endif
    
    if FunName() == 'FXREPDFE' .and. FindFunction("U_FXORGXML")
        U_FXORGXML()
    endif
    
    RestArea(aArea)

Return lRet
