#Include 'Protheus.ch'

User Function M103FILB()

    Local cFiltro := ""

    if IsInCallStack("U_FXREPDFE")
        cFiltro := U_FX103FTR()
    endif

Return cFiltro
