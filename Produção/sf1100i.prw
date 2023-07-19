#include "rwmake.ch"
#include "protheus.ch"
#include "Topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SF1100I    �Autor  �Edna Ferreira   � Data � 28/09/2016    ���
�������������������������������������������������������������������������͹��
���Desc.     � O PE ir� verificar se existe t�tulo provis�rio para o      ���
��� Fornecedor e caso exista o usu�rio ter� a op��o de excluir o t�tulo   ���
��� provis�rio se for necess�rio.                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Compras ou Estoque, documento de entrada                  �'��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function SF1100I()

Local aArea    := GetArea()
Local aAreaSE2 := SE2->(GetArea())

Private cMarca
Private linverte := .f.
Private aRotina := {}
Private aCampos := {}

If !ALLTRIM(SE2->E2_TIPO)$"AB-_ADF_ADI_CF-_CH_COF_CS-_CSL_CSS_DDI_FER_FOL_FT_FU-_IN-_INS_IR-_IRRF_IS-_ISS_PI-_PIS_NCF_PRE_NCP_NDC_NDF_PA_PR_RPA_TX"
	
	cQTSE2 := "SELECT * FROM "+RETSQLNAME("SE2")+" WHERE D_E_L_E_T_='' "
	cQTSE2 += " And E2_FILIAL = '"+SE2->E2_FILIAL+"' "
	cQTSE2 += " And E2_FORNECE = '"+SE2->E2_FORNECE+"' "
	cQTSE2 += " And E2_LOJA = '"+SE2->E2_LOJA+"' " 
	cQTSE2 += " And E2_SALDO > 0 "
	cQTSE2 += " And SUBSTRING(E2_TIPO,1,2)='PR' "
	
	If Select("cQTSE2")> 0
		cQTSE2->(DBCLOSEAREA())
	Endif
	
	TCQUERY cQTSE2 NEW ALIAS "cQTSE2"
	
	If !Empty(cQTSE2->E2_TIPO)
		
		If MSGYESNO( "Fornecedor tem T�tulo Provis�rio. Deseja Verificar?", "T�tulo Provis�rio" )
			
			aRotina:= {{"Exclui Provisorio" ,'u_ExcPrE2()', 0 , 4 }}
			
			aCampos := { {"E2_YOK","OK",""} ,;
			{"E2_FILIAL","FILIAL",""} ,;
			{"E2_PREFIXO","PREFIXO",""} ,;
			{"E2_NUM","TITULO",""} ,;
			{"E2_PARCELA","PARCELA",""} ,;
			{"E2_TIPO","TIPO",""} ,;
			{"E2_NATUREZ","NATUREZA",""} ,;
			{"E2_FORNECE","FORNEC",""} ,;
			{"E2_LOJA","LOJA",""},;
			{"E2_NOMFOR","NOME",""},;
			{"E2_EMISSAO","DTEMISS",""},;
			{"E2_VENCTO","DTVENCTO",""},;
			{"E2_VENCREA","DTVENCREA",""},;
			{"E2_VALOR","VALOR",""} }
			
			cMarca := GetMark()
			
			DbSelectArea("SE2")
			SE2->(DbSetorder(1))
			SE2->(DbGotop())
			SE2->(DbSeek(xFilial("SE2") + cQTSE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA )))
			Set Filter To SE2->E2_FILIAL == xFilial("SE2") .And. SE2->E2_FORNECE == cQTSE2->E2_FORNECE .And. SE2->E2_LOJA == cQTSE2->E2_LOJA .And. SE2->E2_SALDO > 0 .And. SE2->E2_TIPO == "PR "
						
			MarkBrow("SE2","E2_YOK",,aCampos,linverte,cMarca,,,,,Mark())
			
		EndIf
		
	Endif
	
	cQTSE2->(DBCLOSEAREA())
	
EndIf

RestArea(aAreaSE2)
RestArea(aArea)

Return

//FUN��O GRAVA MARCA NO CAMPO
Static Function Mark()

If SE2->E2_YOK == cMarca
	RecLock( 'SE2', .F. )
	Replace E2_YOK With Space(2)
	MsUnLock()
Else
	RecLock( 'SE2', .F. )
	Replace E2_YOK With cMarca
	MsUnLock()
EndIf

Return

//FUN��O EXCLUIR O PROVIS�RIO
User Function ExcPrE2()

cQSE2 := "SELECT * FROM "+RETSQLNAME("SE2")+" WHERE D_E_L_E_T_='' "
cQSE2 += " And E2_FILIAL = '"+SE2->E2_FILIAL+"' "
cQSE2 += " And E2_YOK <> '' "
cQSE2 += " And E2_FORNECE = '"+SE2->E2_FORNECE+"' "
cQSE2 += " And E2_LOJA = '"+SE2->E2_LOJA+"' " 
cQSE2 += " And E2_SALDO > 0 "
cQSE2 += " And SUBSTRING(E2_TIPO,1,2) ='PR' "

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQSE2), "TRBSE2", .F., .T. )

DbSelectArea("SE2")
SE2->(DbGotop())
SE2->(DbSetorder(1))

While !TRBSE2->(eof())
	
	If SE2->(DbSeek(xFilial("SE2") + TRBSE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA )))
		
		RecLock("SE2",.F.,.T.)
		dbDelete()
		MsUnlock()
		
	EndIf
	
	TRBSE2->(dbskip())
	
Enddo

TRBSE2->(DBCLOSEAREA())

Return
