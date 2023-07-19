#INCLUDE "totvs.ch"
#Include "tbiconn.ch"

USER Function ExecAutoMT410() //U_ExecAutoMT410
Local aCabec := {}
Local aDados := {}
Local aLinha := {}
Local aArea := {}
Local C6_PRODUTO := {"9100195","9100197","9100361","9100196","9100198","9100362","9102065","9100417","9100709" }
Local C6_QTDVEN := {4,4,4,4,4,4,1,4,6}
Local C6_QTDLIB := {4,4,4,4,4,4,1,4,6}
Local C6_PRUNIT := {224.81093,303.64465,503.68109,224.81093,303.64465,503.68109,245.01139,1263.87244,924.06378}
Local C6_PRCVEN := {224.81093,303.64465,503.68109,224.81093,303.64465,503.68109,245.01139,1263.87244,924.06378}
Local C6_VALOR := {899.24,1214.58,2014.72,899.24,1214.58,2014.72,245.01,5055.49,5544.38}
Local C6_TES := {"700","700","700","700","700","700","700","700","700"}
Local nCount
Local aMessageError
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

   aArea := GetArea()
   AAdd(aCabec, {"C5_FILIAL", "010101", NIL})
   aadd(aCabec,{"C5_TIPO" ,"N",Nil})
   aadd(aCabec,{"C5_EMISSAO" ,Date(),NIL})
   AAdd(aCabec, {"C5_CLIENTE", "22812", NIL})
   AAdd(aCabec, {"C5_LOJACLI", "01", NIL})
   AAdd(aCabec, {"C5_LOJAENT", "01", NIL})
   aadd(aCabec,{"C5_NATCLI","000001",Nil})
   AAdd(aCabec, {"C5_VEND1", "014", NIL})
   AAdd(aCabec, {"C5_CONDPAG", "014", NIL})
   AAdd(aCabec, {"C5_MENNOTA", "PROPOSTA: FN-20220707-56821 SITE:  ORDEM: ", NIL})
   AAdd(aCabec, {"C5_FRETE", 1, NIL})
   AAdd(aCabec, {"C5_YNUM", 45194, NIL})
   AAdd(aCabec, {"C5_YPEDCLI", "FN-20220707-56821", NIL})
   AAdd(aCabec, {"C5_EMAIL", "michele.morais@fonnet.com.br, compras@goxinternet.com.br, financeiro@goxinternet.com.br", NIL})
   AAdd(aCabec, {"C5_TRANSP", "000033", NIL})
   AAdd(aCabec, {"C5_MENPAD", "001", NIL})
   AAdd(aCabec, {"C5_TPFRETE", "C", NIL})
   AAdd(aCabec, {"C5_PESOL", 2.45, NIL})
   AAdd(aCabec, {"C5_PBRUTO", 2.45, NIL})
   AAdd(aCabec, {"C5_VOLUME1", 1, NIL})
   AAdd(aCabec, {"C5_ESPECI1", "CAIXA", NIL})


   FOR  nCount := 1 to 2
   aLinha := {}
   aadd(aLinha,{"C6_ITEM",StrZero(nCount,2),Nil})
   AAdd(aLinha, {"C6_PRODUTO",C6_PRODUTO[nCount], NIL})
   AAdd(aLinha, {"C6_QTDVEN",C6_QTDVEN[nCount], NIL})
   AAdd(aLinha, {"C6_PRCVEN",C6_PRCVEN[nCount], NIL})
   AAdd(aLinha, {"C6_PRUNIT",C6_PRUNIT[nCount], NIL})
   AAdd(aLinha, {"C6_VALOR",C6_VALOR[nCount], NIL})
   AAdd(aLinha, {"C6_QTDLIB",C6_QTDLIB[nCount], NIL})
   AAdd(aLinha, {"C6_TES",C6_TES[nCount], NIL})
   AAdd(aLinha, {"C6_NUMPCOM","Autorizado pelo Whatsapp", NIL})
   AAdd(aLinha, {"C6_ITPC","0001", NIL})

   AAdd(aDados, aLinha)
    NEXT
   
   MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aDados, 3)
// VALIDA플O DE ERRO
   If (lMsErroAuto)
    
        aMessageError := Mostraerro()

       // RollbackSX8() // REMOVER PARA GERA플O DE NUMERA플O AUTOM햀ICA PELA ROTINA
       ConOut(Repl("-", 80))
       ConOut(PadC("MATA410 automatic routine ended with error", 80))
       ConOut(PadC("Ended at: " + Time(), 80))
       ConOut(Repl("-", 80))
       ConOut(aMessageError)

   Else
       // ConfirmSX8() // REMOVER PARA GERA플O DE NUMERA플O AUTOM햀ICA PELA ROTINA
       ConOut(Repl("-", 80))
       ConOut(PadC("MATA410 automatic routine successfully ended", 80))
       ConOut(PadC("Ended at: " + Time(), 80))
       ConOut(Repl("-", 80))
   EndIf
   
   RestArea(aArea) // RESTAURA플O DA 핾EA ANTERIOR

Return (NIL)
