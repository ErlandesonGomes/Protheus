#Include 'Protheus.ch'

User Function MT140FIL()

    Local cFiltro := ""
	
	if IsInCallStack("U_FXREPDFE")
        cFiltro := U_FX140FIL()
    endif

Return cFiltro
