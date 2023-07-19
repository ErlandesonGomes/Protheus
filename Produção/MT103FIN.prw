#Include 'Protheus.ch'

User Function MT103FIN()

    // F4_AGRPEDG - Agrega pedagio
    // 1 = Agrega na base do ICMS
    // 2 = Agrega somente no total da NF
    // 3 = Nao considera
    // 4 = Agrega no PIS/COFINS
    // 5 = Agrega no PIS/COFINS e ICMS

    Local lRet := .T.
    Local aLocCols := PARAMIXB[2]   
    Local lLocRet  := PARAMIXB[3] 
    Local nSomaParc := 0
    Local nSomaTot := 0
    Local nX := 0

    if IsInCallStack("U_FXREPDFE") .and. IsInCallStack("MATA116")

        cAgrPedg := FBuscaCPO("SF4", 1 , xFilial("SF4") + aParametros[12], "F4_AGRPEDG")
        nPosTot := aScan(aHeader,{|x| alltrim(x[2]) == "D1_TOTAL"})
        
        if aNfeDanfe[15] > 0 .and. cAgrPedg $ "1-2-4-5"

            for nX := 1 to len(aLocCols)
                nSomaParc += aLocCols[nX,3]
            next
            for nX := 1 to len(aCols)
                nSomaTot += aCols[nX,nPosTot]
            next
            if nSomaParc <= nSomaTot
                Processa({|| AtuPedg()}, "Atualizando pedágio...")
                Processa({|| AtuPedg()}, "Atualizando duplicatas...")
                sleep(1000)
                msginfo("As duplicatas foram atualizadas por favor verifique os valores.")
                Eval(bRefresh)
                Eval(bGdRefresh)
                lRet := .F.
            endif
        endif
    endif

Return lRet

Static Function AtuPedg()

    MaFisAlt("NF_VALPEDG",aNfeDanfe[15])
    MaFisToCols(aHeader,aCols,,"MT100")
    Eval(bRefresh)
    Eval(bGdRefresh)
    sleep(2000)

Return
