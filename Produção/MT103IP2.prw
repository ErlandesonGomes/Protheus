#Include 'Protheus.ch'



User Function MT103IP2()
Local aParam	:= PARAMIXB
Local nCont		:= aParam[1]
Local nPosAliq	:= aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_ALIQII"}) 
Local nPosII	:= aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_II"}) 	
Local nPosPed 	:= aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_PEDIDO"})
Local nPedido 	:= ""
Local nPosItem 	:= aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_ITEMPC"})
Local nD1VUNIT 	:= aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_VUNIT"})
Local nD1TOTAL 	:= aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_TOTAL"})


if funname() != "FXREPDFE"

	cPedido :=  aCols[nCont,nPosPed]		
	cItem := aCols[nCont,nPosItem]		

	DBSELECTAREA("SC7")
	SC7->(DBSETORDER(1))
	IF SC7->(DBSEEK(xFilial("SC7")+cPedido+cItem))

				aCols[nCont,nPosAliq]	:= SC7->C7_YALIQII
			aCols[nCont,nPosII]		:= SC7->C7_YVALII
			
			MaFisIniLoad(nCont)
			
			MaFisLoad( "IT_ALIQII", SC7->C7_YALIQII,  nCont)
			MaFisLoad( "IT_VALII", SC7->C7_YVALII,  nCont)
			
			MaFisRef("IT_ALIQII","MT100",aCols[nCont,nPosAliq])
			MaFisRef("IT_VALII","MT100",aCols[nCont,nPosII])
			
			MaFisRecal("",nCont)
			
			MaFisEndLoad(nCont)		
	ENDIF
endif

Return
