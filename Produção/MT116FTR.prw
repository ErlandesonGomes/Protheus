#Include 'Protheus.ch'

User Function MT116FTR()

    Local cRet := ""

    if FunName() == 'FXREPDFE'
        cRet := U_FX116FTR()
    endif

Return cRet
