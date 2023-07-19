#Include 'Protheus.ch'

User Function MT120FIL()

    Local cRet := ""
    
    if IsInCallStack("U_FXREPDFE")
        cRet := U_FX120FIL()
    endif

Return cRet
