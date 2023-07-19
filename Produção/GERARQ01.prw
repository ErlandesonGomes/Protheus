#Include "Protheus.ch"
#include "TOTVS.CH"
#include "fileio.ch"
#include "rwmake.ch"
#include "TBICONN.CH"
#include "TBICODE.CH"

//	###########################################################################################
//	Projeto: FonNet
//	Modulo : Compras/Faturamento
//	Fonte  : GERARQ01.prw
//	-----------+-------------------+-----------------------------------------------------------
//	Data       | Autor             | Descricao
//	-----------+-------------------+-----------------------------------------------------------
//	31/05/2017 | Wilton Lima       | Arquivo de Notas.         
//	           |                   | Menu de escolha Entradas/Saidas.    
//	-----------+-------------------+-----------------------------------------------------------
//	###########################################################################################

#Define SALTO CHR(13) + CHR(10)

user function GERARQ01()
	Local aPergs    := {}
	Local aColuna   := {}
	Local aRet      := {}
	Local aTipo	    := {}
	Local lConfirm  := .F.
	
	Private nCnt  := 0
	Private cPerg := PadR( 'GERARQ001', 10 )
	
	CriaSX1(cPerg)
	
	lConfirm := Pergunte( cPerg, .T. )	
	
	If lConfirm
		If MV_PAR01 == 1
			Processa( {|| GeraTXT("E") }, "Aguarde...", "processamento iniciado...", .F. )		
		ElseIf MV_PAR01 == 2
			Processa( {|| GeraTXT("S") }, "Aguarde...", "processamento iniciado...", .F. )		
		EndIf
		
		MsgInfo( "Gerado... " + cValtoChar(nCnt) + " Registros.", "Finalizado com sucesso" )
		
	EndIf
	
	nCnt := 0
Return

Static Function GeraTXT(cTipo)
	//Armazena a area atual
	Local aArea    := GetArea()

	Local nHandle  := 0
	Local cNomeArq := "NF" + dtos(dDataBase) + StrTran(time(),":", "") + ".TXT"
	Local cTexto   := ""
	Local cSetSql  := ""
	Local cSep     := ";"
	
	if (cTipo == "E") //Entradas
		//Monta cabeçalho 
		cTexto := "D1_PEDIDO"  + cSep + "F1_DOC"     + cSep + "F1_SERIE"    + cSep + "F1_FORNECE" + cSep + "F1_LOJA"    + cSep + "F1_COND"    + cSep
		cTexto += "F1_EMISSAO" + cSep + "D1_ITEM"    + cSep + "D1_COD"      + cSep + "D1_TES"     + cSep + "D1_CF"      + cSep + "D1_TIPO"    + cSep
		cTexto += "D1_QUANT"   + cSep + "D1_VUNIT"   + cSep + "D1_TOTAL"    + cSep + "D1_IPI"     + cSep + "D1_BASEIPI" + cSep + "D1_VALIPI"  + cSep 
		cTexto += "D1_VALDESC" + cSep + "D1_PICM"    + cSep + "D1_BASEICM"  + cSep + "D1_VALICM"  + cSep + "D1_ICMSRET" + cSep + "D1_BRICMS"  + cSep
		cTexto += "D1_ALIQII"  + cSep + "D1_II"      + cSep + "D1_BASIMP5"  + cSep + "D1_BASIMP6" + cSep + "D1_ALQIMP5" + cSep + "D1_ALQIMP6" + cSep
		cTexto += "D1_VALIMP5" + cSep + "D1_VALIMP6" + cSep + "D1_DESPESA"  + cSep + "D1_BASEIRR" + cSep + "D1_ALIQIRR" + cSep + "D1_VALIRR"  + cSep
		cTexto += "D1_BASEISS" + cSep + "D1_ALIQISS" + cSep + "D1_VALISS"   + cSep + "D1_BASEINS" + cSep + "D1_ALIQINS" + cSep + "D1_VALINS"  + cSep 
		cTexto += "D1_ALIQSOL" + cSep + "D1_BASECSL" + cSep + "D1_VALCSL"   + cSep + "D1_ALQCSL"  + cSep + "D1_BASECOF" + cSep + "D1_VALCOF"  + cSep
		cTexto += "D1_ALQCOF"  + cSep + "D1_BASEPIS" + cSep + "D1_VALPIS"   + cSep + "D1_ALQPIS"  + SALTO

		//Select das notas de Saidas
		cSetSql := selectSD1()
		
		//salva o select para debug
		//MemoWrite("C:\temp\SELECT002.TXT", cSetSql)
				
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSetSql), "QRY", .F., .T.)	
		DbSelectArea('QRY')
		dbGoTop()
		
		ProcRegua(Reccount())
				
		While !QRY->(Eof())						
			IncProc()
			
			//monta os dados
			cTexto += QRY->D1_PEDIDO              + cSep + QRY->F1_DOC                 + cSep + QRY->F1_SERIE               + cSep + QRY->F1_FORNECE             + cSep + QRY->F1_LOJA                + cSep + QRY->F1_COND                + cSep
			cTexto += QRY->F1_EMISSAO             + cSep + QRY->D1_ITEM                + cSep + QRY->D1_COD                 + cSep + QRY->D1_TES                 + cSep + QRY->D1_CF                  + cSep + QRY->D1_TIPO                + cSep
			cTexto += cValToChar(QRY->D1_QUANT)   + cSep + cValToChar(QRY->D1_VUNIT)   + cSep + cValToChar(QRY->D1_TOTAL)   + cSep + cValToChar(QRY->D1_IPI)     + cSep + cValToChar(QRY->D1_BASEIPI) + cSep + cValToChar(QRY->D1_VALIPI)  + cSep 
			cTexto += cValToChar(QRY->D1_VALDESC) + cSep + cValToChar(QRY->D1_PICM)    + cSep + cValToChar(QRY->D1_BASEICM) + cSep + cValToChar(QRY->D1_VALICM)  + cSep + cValToChar(QRY->D1_ICMSRET) + cSep + cValToChar(QRY->D1_BRICMS)  + cSep
			cTexto += cValToChar(QRY->D1_ALIQII)  + cSep + cValToChar(QRY->D1_II)      + cSep + cValToChar(QRY->D1_BASIMP5) + cSep + cValToChar(QRY->D1_BASIMP6) + cSep + cValToChar(QRY->D1_ALQIMP5) + cSep + cValToChar(QRY->D1_ALQIMP6) + cSep
			cTexto += cValToChar(QRY->D1_VALIMP5) + cSep + cValToChar(QRY->D1_VALIMP6) + cSep + cValToChar(QRY->D1_DESPESA) + cSep + cValToChar(QRY->D1_BASEIRR) + cSep + cValToChar(QRY->D1_ALIQIRR) + cSep + cValToChar(QRY->D1_VALIRR)  + cSep
			cTexto += cValToChar(QRY->D1_BASEISS) + cSep + cValToChar(QRY->D1_ALIQISS) + cSep + cValToChar(QRY->D1_VALISS)  + cSep + cValToChar(QRY->D1_BASEINS) + cSep + cValToChar(QRY->D1_ALIQINS) + cSep + cValToChar(QRY->D1_VALINS)  + cSep 
			cTexto += cValToChar(QRY->D1_ALIQSOL) + cSep + cValToChar(QRY->D1_BASECSL) + cSep + cValToChar(QRY->D1_VALCSL)  + cSep + cValToChar(QRY->D1_ALQCSL)  + cSep + cValToChar(QRY->D1_BASECOF) + cSep + cValToChar(QRY->D1_VALCOF)  + cSep
			cTexto += cValToChar(QRY->D1_ALQCOF)  + cSep + cValToChar(QRY->D1_BASEPIS) + cSep + cValToChar(QRY->D1_VALPIS)  + cSep + cValToChar(QRY->D1_ALQPIS)  + SALTO
			
			nCnt++
			
			QRY->(dbSkip())
		EndDo
					
		QRY->(dbCloseArea())
		
	elseIf (cTipo == "S") //Saidas
	
		//Monta cabeçalho 
		cTexto := "C5_YNUM"    + cSep + "C5_CLIENTE" + cSep + "C5_LOJACLI" + cSep + "F2_DOC"     + cSep + "F2_SERIE"   + cSep + "F2_COND"    + cSep
		cTexto += "F2_EMISSAO" + cSep + "D2_COD"     + cSep + "D2_ITEM"    + cSep + "D2_TES"     + cSep + "D2_CF"      + cSep + "D2_TIPO"    + cSep
		cTexto += "D2_QUANT"   + cSep + "D2_PRCVEN"  + cSep + "D2_TOTAL"   + cSep + "D2_DESCON"  + cSep + "D2_LOCAL"   + cSep + "D2_PRUNIT"  + cSep
		cTexto += "D2_IPI"     + cSep + "D2_BASEIPI" + cSep + "D2_VALIPI"  + cSep + "D2_PICM"    + cSep + "D2_BASEICM" + cSep + "D2_VALICM"  + cSep
		cTexto += "D2_BASIMP5" + cSep + "D2_BASIMP6" + cSep + "D2_ALQIMP5" + cSep + "D2_ALQIMP6" + cSep + "D2_VALIMP5" + cSep + "D2_VALIMP6" + cSep   
		cTexto += "D2_BASEIRR" + cSep + "D2_ALQIRRF" + cSep + "D2_VALIRRF" + cSep + "D2_BASEISS" + cSep + "D2_ALIQISS" + cSep + "D2_VALISS"  + SALTO		

		//Select das notas de Saidas
		cSetSql := selectSD2()
		
		//salva o select para debug
		//MemoWrite("C:\temp\SELECT001.TXT", cSetSql)
				
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSetSql), "QRY", .F., .T.)	
		DbSelectArea('QRY')
		dbGoTop()
		
		ProcRegua(Reccount())
				
		While !QRY->(Eof())						
			IncProc()
			
			//monta os dados
			cTexto += cValToChar(QRY->C5_YNUM)    + cSep + QRY->C5_CLIENTE             + cSep + QRY->C5_LOJACLI             + cSep + QRY->F2_DOC                 + cSep + QRY->F2_SERIE               + cSep + QRY->F2_COND                + cSep
			cTexto += QRY->F2_EMISSAO             + cSep + QRY->D2_COD                 + cSep + QRY->D2_ITEM                + cSep + QRY->D2_TES                 + cSep + QRY->D2_CF                  + cSep + QRY->D2_TIPO                + cSep
			cTexto += cValToChar(QRY->D2_QUANT)   + cSep + cValToChar(QRY->D2_PRCVEN)  + cSep + cValToChar(QRY->D2_TOTAL)   + cSep + cValToChar(QRY->D2_DESCON)  + cSep + QRY->D2_LOCAL               + cSep + cValToChar(QRY->D2_PRUNIT)  + cSep
			cTexto += cValToChar(QRY->D2_IPI)     + cSep + cValToChar(QRY->D2_BASEIPI) + cSep + cValToChar(QRY->D2_VALIPI)  + cSep + cValToChar(QRY->D2_PICM)    + cSep + cValToChar(QRY->D2_BASEICM) + cSep + cValToChar(QRY->D2_VALICM)  + cSep
			cTexto += cValToChar(QRY->D2_BASIMP5) + cSep + cValToChar(QRY->D2_BASIMP6) + cSep + cValToChar(QRY->D2_ALQIMP5) + cSep + cValToChar(QRY->D2_ALQIMP6) + cSep + cValToChar(QRY->D2_VALIMP5) + cSep + cValToChar(QRY->D2_VALIMP6) + cSep   
			cTexto += cValToChar(QRY->D2_BASEIRR) + cSep + cValToChar(QRY->D2_ALQIRRF) + cSep + cValToChar(QRY->D2_VALIRRF) + cSep + cValToChar(QRY->D2_BASEISS) + cSep + cValToChar(QRY->D2_ALIQISS) + cSep + cValToChar(QRY->D2_VALISS)  + SALTO	
			
			nCnt++
			QRY->(dbSkip())
		EndDo
					
		QRY->(dbCloseArea())
			
	EndIf
	
	//Salva na pasta temp local	
	nHandle := FCREATE('C:\temp\' + cNomeArq, FC_NORMAL)
	
	//Salva na pasta data do protheus
	//nHandle := FCREATE('\data\' + cNomeArq, FC_NORMAL)
	
	//Salva no arquivo os nomes e os campos
	//FWrite(nHandle, cTexto + SALTO)
	FWrite(nHandle, cTexto)
	
	//Fecha o arquivo
	fclose(nHandle)
	
	RestArea( aArea )
Return

Static function setFiltro(cTab)
	Local cSetSql := ""
	
	cSetSql += " AND " + cTab + "FILIAL >= '" + mv_par02 + "'"
	cSetSql += " AND " + cTab + "FILIAL <= '" + mv_par03 + "'"
	cSetSql += " AND " + cTab + "EMISSAO >= '" + DtoS(mv_par04) + "'"
	cSetSql += " AND " + cTab + "EMISSAO <= '" + DtoS(mv_par05) + "'"
	
return cSetSql

//Select para SD1 entradas
static function selectSD1()
	Local cSetSql := ""
	
	cSetSql += "SELECT SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_COND, SF1.F1_EMISSAO, " 
	cSetSql += "SD1.D1_FILIAL, SD1.D1_ITEM, SD1.D1_COD, SD1.D1_TES, SD1.D1_CF, SD1.D1_TIPO, SD1.D1_GRUPO, SD1.D1_PEDIDO, "
	cSetSql += "SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_TOTAL, SD1.D1_IPI, SD1.D1_BASEIPI, SD1.D1_VALIPI, " 
	cSetSql += "SD1.D1_VALDESC, SD1.D1_PICM, SD1.D1_BASEICM, SD1.D1_VALICM, SD1.D1_ICMSRET, SD1.D1_BRICMS, SD1.D1_ALIQII, SD1.D1_II, " 
	cSetSql += "SD1.D1_BASIMP5, SD1.D1_BASIMP6, SD1.D1_ALQIMP5, SD1.D1_ALQIMP6, SD1.D1_VALIMP5, SD1.D1_VALIMP6, SD1.D1_DESPESA, "
	cSetSql += "SD1.D1_BASEIRR, SD1.D1_ALIQIRR, SD1.D1_VALIRR, SD1.D1_BASEISS, SD1.D1_ALIQISS, SD1.D1_VALISS, SD1.D1_BASEINS, "
	cSetSql += "SD1.D1_ALIQINS, SD1.D1_VALINS, SD1.D1_ALIQSOL, SD1.D1_BASECSL, SD1.D1_VALCSL, SD1.D1_ALQCSL, SD1.D1_BASECOF, "
	cSetSql += "SD1.D1_VALCOF, SD1.D1_ALQCOF, SD1.D1_BASEPIS, SD1.D1_VALPIS, SD1.D1_ALQPIS " 
	cSetSql += "FROM " + RetSqlName("SD1") + " SD1 "				 
	cSetSql += "INNER JOIN " + RetSqlName("SF1") + " SF1 ON (SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE) "
	cSetSql += "WHERE "
	cSetSql += "SF1.D_E_L_E_T_ <> '*' AND "
	cSetSql += "SD1.D_E_L_E_T_ <> '*' "	
	
	cSetSql += setFiltro("SD1.D1_")
					
	cSetSql += "GROUP BY SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_COND, SF1.F1_EMISSAO, " 
	cSetSql += "SD1.D1_FILIAL, SD1.D1_ITEM, SD1.D1_COD, SD1.D1_TES, SD1.D1_CF, SD1.D1_TIPO, SD1.D1_GRUPO, SD1.D1_PEDIDO, "
	cSetSql += "SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_TOTAL, SD1.D1_IPI, SD1.D1_BASEIPI, SD1.D1_VALIPI, " 
	cSetSql += "SD1.D1_VALDESC, SD1.D1_PICM, SD1.D1_BASEICM, SD1.D1_VALICM, SD1.D1_ICMSRET, SD1.D1_BRICMS, SD1.D1_ALIQII, SD1.D1_II, " 
	cSetSql += "SD1.D1_BASIMP5, SD1.D1_BASIMP6, SD1.D1_ALQIMP5, SD1.D1_ALQIMP6, SD1.D1_VALIMP5, SD1.D1_VALIMP6, SD1.D1_DESPESA, "
	cSetSql += "SD1.D1_BASEIRR, SD1.D1_ALIQIRR, SD1.D1_VALIRR, SD1.D1_BASEISS, SD1.D1_ALIQISS, SD1.D1_VALISS, SD1.D1_BASEINS, "
	cSetSql += "SD1.D1_ALIQINS, SD1.D1_VALINS, SD1.D1_ALIQSOL, SD1.D1_BASECSL, SD1.D1_VALCSL, SD1.D1_ALQCSL, SD1.D1_BASECOF, "
	cSetSql += "SD1.D1_VALCOF, SD1.D1_ALQCOF, SD1.D1_BASEPIS, SD1.D1_VALPIS, SD1.D1_ALQPIS "
		
	// Converte o texto num Sql
	cSetSql := ChangeQuery(cSetSql) 
return cSetSql

//Select para SD2 saidas
static function selectSD2()
	Local cSetSql := ""
	
	cSetSql += "SELECT SC5.C5_FILIAL, SC5.C5_NUM, SC5.C5_YNUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SF2.F2_FILIAL, "
	cSetSql += "SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_COND, SF2.F2_EMISSAO, SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, " 
	cSetSql += "SD2.D2_COD, SD2.D2_ITEM, SD2.D2_TES, SD2.D2_CF, SD2.D2_TIPO, SD2.D2_QUANT, SD2.D2_PRCVEN, "
	cSetSql += "SD2.D2_TOTAL,SD2.D2_DESCON, SD2.D2_LOCAL, SD2.D2_PRUNIT, SD2.D2_IPI, SD2.D2_BASEIPI, SD2.D2_VALIPI, " 
	cSetSql += "SD2.D2_PICM, SD2.D2_BASEICM, SD2.D2_VALICM, SD2.D2_BASIMP5, SD2.D2_BASIMP6, SD2.D2_ALQIMP5, "
	cSetSql += "SD2.D2_ALQIMP6, SD2.D2_VALIMP5, SD2.D2_VALIMP6, SD2.D2_BASEIRR, SD2.D2_ALQIRRF, SD2.D2_VALIRRF, " 
	cSetSql += "SD2.D2_BASEISS, SD2.D2_ALIQISS, SD2.D2_VALISS "
	cSetSql += "FROM " + RetSqlName("SD2") + " SD2 "
	cSetSql += "INNER JOIN " + RetSqlName("SF2") + " SF2 ON (SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE) "
	cSetSql += "INNER JOIN " + RetSqlName("SC5") + " SC5 ON (SC5.C5_FILIAL = SD2.D2_FILIAL AND SC5.C5_NUM = SD2.D2_PEDIDO) "
	cSetSql += "WHERE "
	cSetSql += "SD2.D_E_L_E_T_ <> '*' AND "
	cSetSql += "SF2.D_E_L_E_T_ <> '*' AND "
	cSetSql += "SC5.D_E_L_E_T_ <> '*'"
	
	cSetSql += setFiltro("SD2.D2_")
	
	cSetSql += "GROUP BY SC5.C5_FILIAL, SC5.C5_NUM, SC5.C5_YNUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SF2.F2_FILIAL, " 
	cSetSql += "SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_COND, SF2.F2_EMISSAO, SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, "
	cSetSql += "SD2.D2_COD, SD2.D2_ITEM, SD2.D2_TES, SD2.D2_CF, SD2.D2_TIPO, SD2.D2_QUANT, SD2.D2_PRCVEN, "
	cSetSql += "SD2.D2_TOTAL,SD2.D2_DESCON, SD2.D2_LOCAL, SD2.D2_PRUNIT, SD2.D2_IPI, SD2.D2_BASEIPI, SD2.D2_VALIPI, " 
	cSetSql += "SD2.D2_PICM, SD2.D2_BASEICM, SD2.D2_VALICM, SD2.D2_BASIMP5, SD2.D2_BASIMP6, SD2.D2_ALQIMP5, "
	cSetSql += "SD2.D2_ALQIMP6, SD2.D2_VALIMP5, SD2.D2_VALIMP6, SD2.D2_BASEIRR, SD2.D2_ALQIRRF, SD2.D2_VALIRRF, " 
	cSetSql += "SD2.D2_BASEISS, SD2.D2_ALIQISS, SD2.D2_VALISS "
	
	// Converte o texto num Sql
	cSetSql := ChangeQuery(cSetSql) 
return cSetSql

Static Function CriaSX1(cPerg)
	PutSx1(cPerg, "01", "Entradas/Saidas", "Entradas/Saidas", "Entradas/Saidas", "mv_ch01","N",01,0,0,"C","","","","","mv_par01","Entradas","Entradas","Entradas","Saidas","Saidas","Saidas","","","","","","","","","","")
	
	PutSx1(cPerg, "02", "Filial De",       "Filial De",       "Filial De",       "mv_ch02","C",TamSX3("D2_FILIAL")[1]	,0,0,"G","","SM0"	,"","","mv_par02"," ","","","","","","","","","","","","","","","")
	PutSx1(cPerg, "03", "Filial Ate",      "Filial Ate",      "Filial Ate",      "mv_ch03","C",TamSX3("D2_FILIAL")[1]	,0,0,"G","","SM0"	,"","","mv_par03"," ","","",REPLICATE('Z',TamSX3("D2_FILIAL")[1]),"","","","","","","","","","","","")
	
	PutSx1(cPerg, "04", "Emissao De",      "Emissao De",      "Emissao De",      "mv_ch04","D",08,0,2,"G","","","","","mv_par04"," ","","","","","","","","","","","","","","","")
	PutSx1(cPerg, "05", "Emissao Ate",     "Emissao Ate",     "Emissao Ate",     "mv_ch05","D",08,0,2,"G","","","","","mv_par05"," ","","","","","","","","","","","","","","","")
Return
