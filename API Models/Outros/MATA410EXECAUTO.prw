#INCLUDE "totvs.ch"
#Include "tbiconn.ch"

USER Function ExecAutoMT410() //U_ExecAutoMT410
Local aCabec := {}
Local aDados := {}
Local aLinha := {}
Local aArea := {}
Local C6_PRODUTO := {"CD00100001","CD00300010"}
Local C6_QTDVEN := {1,1}
Local C6_QTDLIB := {1,1}
Local C6_PRUNIT := {1116.13,1116.13}
Local C6_PRCVEN := {1116.13,1116.13}
Local C6_VALOR := {1116.13,1116.13}
Local C6_TES := {"501","501"}
Local nCount
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

   aArea := GetArea()
   
   
   AAdd(aCabec, {"C5_TIPO", "N", NIL})
   AAdd(aCabec, {"C5_CLIENTE", "000002", NIL})
   AAdd(aCabec, {"C5_LOJACLI", "01", NIL})
   AAdd(aCabec, {"C5_LOJAENT", "01", NIL})
   AAdd(aCabec, {"C5_CONDPAG", "001", NIL})
   AAdd(aCabec, {"C5_TRANSP", "000001", NIL})
   AAdd(aCabec, {"C5_TPFRETE", "C", NIL})
   AAdd(aCabec, {"C5_TIPOCLI", "F", NIL})
   AAdd(aCabec, {"C5_NATUREZ","0000000001",NIL})

   FOR  nCount := 1 to 2
   aLinha := {}
   AAdd(aLinha, {"C6_PRODUTO",C6_PRODUTO[nCount], NIL})
   AAdd(aLinha, {"C6_QTDVEN",C6_QTDVEN[nCount], NIL})
   AAdd(aLinha, {"C6_QTDLIB",C6_QTDLIB[nCount], NIL})
   AAdd(aLinha, {"C6_PRUNIT",C6_PRUNIT[nCount], NIL})
   AAdd(aLinha, {"C6_PRCVEN",C6_PRCVEN[nCount], NIL})
   AAdd(aLinha, {"C6_VALOR",C6_VALOR[nCount], NIL})
   AAdd(aLinha, {"C6_TES",C6_TES[nCount], NIL})

   AAdd(aDados, aLinha)
    NEXT
   
   MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aDados, 3)
// VALIDA플O DE ERRO
   If (lMsErroAuto)
       MostraErro()
       // RollbackSX8() // REMOVER PARA GERA플O DE NUMERA플O AUTOM햀ICA PELA ROTINA
       ConOut(Repl("-", 80))
       ConOut(PadC("MATA410 automatic routine ended with error", 80))
       ConOut(PadC("Ended at: " + Time(), 80))
       ConOut(Repl("-", 80))

   Else
       // ConfirmSX8() // REMOVER PARA GERA플O DE NUMERA플O AUTOM햀ICA PELA ROTINA
       ConOut(Repl("-", 80))
       ConOut(PadC("MATA410 automatic routine successfully ended", 80))
       ConOut(PadC("Ended at: " + Time(), 80))
       ConOut(Repl("-", 80))
   EndIf
   
   RestArea(aArea) // RESTAURA플O DA 핾EA ANTERIOR

Return (NIL)
