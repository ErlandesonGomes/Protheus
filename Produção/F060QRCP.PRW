#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"


/*/{Protheus.doc} F060QRCP
//TODO Filtro de Naturezas na gera็ใo do border๔ 
@author sivaldo.santos.ext
@since 01/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
USER FUNCTION F060QRCP()

Local aStru 	:= {}
Local cQuery	:= ""
Local cNaturez  := ""
Local nj		:= 0
Local cQryOri	:= PARAMIXB[1]  // query padrใo do sistema
aStru := dbStruct()
cQuery := "SELECT "

For nj:= 1 to Len(aStru)
	
cQuery += aStru[nj,1]+", "

Next

cQuery += "SE1.R_E_C_N_O_ RECNO "
cQuery += "  FROM "+	RetSqlName("SE1") + " SE1 "
cQuery += "  INNER JOIN "+	RetSqlName('SA1') + " SA1 ON E1_CLIENTE = SA1.A1_COD "
cQuery += " WHERE E1_FILIAL Between '" + cFilDe + "' AND '"+ cFilAte + "'"
cQuery += "   AND E1_NUMBOR = '      '"
cQuery += "   AND E1_EMISSAO Between '" + DTOS(dEmisDe) + "' AND '" + DTOS(dEmisAte) + "'"
cQuery += "   AND E1_CLIENTE between '" + cCliDe        + "' AND '" + cCliAte        + "'"
cQuery += "   AND E1_VENCREA between '" + DTOS(dVencIni)+ "' AND '" + DTOS(dVencFim) + "'"
cQuery += "   AND E1_MOEDA = "+ str(nmoeda)
cQuery += "   AND E1_PREFIXO Between '" + cPrefDe + "' AND '" + cPrefAte + "'"
cQuery += "   AND E1_NUM between '"     + cNumDe  + "' AND '" + cNumAte  + "'"
cQuery += "   AND ( E1_SALDO > 0  OR E1_OCORREN = '02' ) "
//Seleciona Tipos
If mv_par12 == 1	
cQuery += "   AND E1_TIPO IN " + FormatIn(cTipos,"/")
Endif

If !Empty(MVPROVIS) .Or. !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .Or. !Empty(MVENVBCOR)	
cQuery += "   AND E1_TIPO NOT IN " + FormatIn(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR,"/")
Endif


cNaturez :=   u_CPNAT()

IF !Empty(cNaturez)
//If !Empty(GetMv("CP_FILNATU")) 
//cNaturez := GetMv("CP_FILNATU")

cQuery += "   AND E1_NATUREZ IN "+FormatIn(cNaturez,"/")+" "

EndIf

cQuery += "   AND E1_SITUACA IN ('0','F','G') "
cQuery += "   AND SE1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY "+ SqlOrder(SE1->(IndexKey()))

Return cQuery


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFAT124   บAutor  ณ Augusto Ribeiro	  บ Data ณ  18/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera pedido de venda a patir do Or็amento (OS) - Aglutinadoบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Zatix                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function CPNAT()

Local cQuery		:= ""
Local aHeader		:= {}
Local aDadosList	:= {}
Local cNatu  := ""

Local _cTitulo		:= "Seleciona Natureza"
Local _aSay			:= {}
Local _aBotoes		:= {}
Local nY
Private aCpoHeader	:= {}
Private cCadastro 	:= ""

//| Parametros do Usuario

	// AJUSTE FEITO MATEUS HENGLE - 12/09/18
	cQuery := ""
	cQuery	+= " SELECT ED_CODIGO, ED_DESCRIC FROM "+RetSqlName("SED") + " WHERE D_E_L_E_T_ = '' AND ED_MSBLQL = '2' "
	
				
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRY') 
	
		

		//| Monta aHeader
		
		aadd(aHeader," ")
		aadd(aCpoHeader," ")
		For nY := 1 To QRY->(FCOUNT())
			aadd(aHeader,RetTitle(FieldName(nY)))
			aadd(aCpoHeader,FieldName(nY))
		Next nY
		
		//| Monta aDados
		
		WHILE QRY->(!EOF())
			aLinha	:= {}
			AADD(aLinha, .F.)
			For nY := 1 To QRY->(FCOUNT())
				aadd(aLinha, QRY->&(FieldName(nY)) )
			Next nY
			
			AADD(aDadosList, aLinha)
			
			QRY->(DBSKIP())
		ENDDO
		
		//| Monta ListMark para o Usuแrio
		
		cNatu := LtMark(aHeader, aDadosList)
		
	


Return(cNatu)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ListMark บAutor  ณ Augusto Ribeiro	 บ Data ณ  18/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Monta ListMark com as OS em aberto conforme parametro do  บฑฑ
ฑฑบ          ณ usuario                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LtMark(aHeader, aDados)
Local cVar     := Nil
Local oDlg     := Nil
Local cTitulo  := "Selecione as Naturezas que deseja Filtrar"
Local lMark    := .F.
Local oOk      := LoadBitmap( GetResources(), "LBOK" ) //CHECKED    //LBOK  //LBTIK
Local oNo      := LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local oChk     := Nil
Local aDados
Local nY, nI
Local cNatu := ""
Local cBCodLin	:= ""
Local aVetor	:= {}

Private lChk     := .F.
Private oLbx := Nil

//| Carrega dados do Listmark

FOR nY := 1 to len(aDados)
	//   	aaDD(aVetor,{lMark, aDados[_nY,1]})
	aLinVet	:= {}
	For nI := 1 To LEN(aHeader)
		aadd(aLinVet,aDados[nY, nI])
	Next nI
	
	aadd(aVetor,aLinVet)
Next nY

//| Monta a tela para usuario visualizar consulta

If Len( aVetor ) == 0
	Aviso( cTitulo, "Nao existe bancos a consultar", {"Ok"} )
	Return
Endif

//| Dimensionamento da Janela

aSize := MsAdvSize()

aObjects := {}
aAdd( aObjects, { 100, 100, .T., .T. } )


aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
aPosEnc	:= {000,000,aPosObj[1,3]-aPosObj[1,1]-12,aPosObj[1,4]-aPosObj[1,2]-1}

aPosObj[1,3] -= 20

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],00 to aSize[6],aSize[5] OF oMainWnd PIXEL
//   " ", "Campos" ;
@ 000,000 LISTBOX oLbx VAR cVar FIELDS HEADER ;
" ", "Campos" ;
SIZE aPosObj[1,4],aPosObj[1,3] OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())

oLbx:aheaders := aHeader
oLbx:SetArray( aVetor )

//| Cria string com Bloco de Codigo

cBCodLin	:= "Iif(aVetor[oLbx:nAt,1],oOk,oNo)"
For nI := 2 To LEN(aHeader)
	cBCodLin	+= ", aVetor[oLbx:nAt,"+alltrim(str(nI))+"]"
Next nI

cBCodLin	:= "oLbx:bLine := {|| {"+cBCodLin+"}}"
&(cBCodLin)

//cNatu := "'101001'"
//| Para marcar e desmarcar todos os itens existentes

@ (aPosObj[1,3]+5),05 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ON CLICK(aEval(aVetor,{|x| x[1]:= lChk} ),oLbx:Refresh())

DEFINE SBUTTON FROM (aPosObj[1,3]+5), (aPosObj[1,4]-40) TYPE 1 ACTION {|| Processa( { || cNatu := AglutNat(aCpoHeader,aVetor) }, ,"Filtrando Natureza..." ), oDlg:End()} ENABLE OF oDlg 	//| OK
DEFINE SBUTTON FROM (aPosObj[1,3]+5), (aPosObj[1,4]-80) TYPE 2 ACTION oDlg:End() ENABLE OF oDlg 		//| Cancela

ACTIVATE MSDIALOG oDlg CENTER

Return(cNatu)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AglutOS   บAutor  ณ Augusto Ribeiro	 บ Data ณ  19/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Aglutina OS para gerar pedido de Venda                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function AglutNat(aListHead, aLista)

Local nI
Local cNatureza := ""
Local nPosNatu	:= Ascan(aListHead, "ED_CODIGO")

FOR nI := 1 TO Len(aLista)
	
	//| Verifico se o registro foi selecionado.
	
	IF !aLista[nI,1]
		
		Loop
		
	ELSE
		
				
		IF EMPTY(cNatureza)
			
			cNatureza := aLista[nI,nPosNatu]
			
		ELSE
			
			cNatureza += "/" + aLista[nI,nPosNatu]
			
		ENDIF
		
	ENDIF
	
	
NEXT  nI

Return(cNatureza)


