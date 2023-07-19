#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'



User Function telcondpag()//U_telcondpag

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de cVariable dos componentes                                 ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Local cCondPag   := Space(3)
Local cLabel1    := Space(1)
Local cLabel2    := Space(1)
Local cNF        := Space(9)
Local cSerie     := Space(3)


/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Local dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oDlg1","Label1","Label2","oGet1","oGet2","oGet3","OK","Cancelar")

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
//oDlg1      := MSDialog():New( 344,275,522,531,"Alteração de Pagamento de Devolução",,,.F.,,,,,,.T.,,,.T. )
DEFINE  MSDIALOG oDlg1 FROM  344,275 TO 522,531 TITLE "Alteração de Pagamento de Devolução" PIXEL STYLE DS_MODALFRAME //dialog sem o X para fechar
oDlg1:lEscClose := .F. //desabilita fechar a janela ao pressinar esc.
oDlg1:lCentered := .T. //abre a janela centralizado.
oDlg1:nstyle := 128

Label1     := TSay():New( 008,013,{||"Digite o Numero da  Nota Fiscal e Serie"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
Label2     := TSay():New( 036,008,{||"Digite o codigo de Pagamento"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
oGet1      := TGet():New( 020,008,{|u| If(PCount()>0,cNF:=u,cNF)},oDlg1,080,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNF",,)
oGet2      := TGet():New( 020,092,{|u| If(PCount()>0,cSerie:=u,cSerie)},oDlg1,020,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSerie",,)
oGet3      := TGet():New( 048,008,{|u| If(PCount()>0,cCondPag:=u,cCondPag)},oDlg1,104,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cCondPag",,)
OK         := TButton():New( 064,008,"OK",oDlg1,{||AlteraCond(cNF,cSerie,cCondPag)},037,012,,,,.T.,,"",,,,.F. )
Cancelar   := TButton():New( 064,077,"Cancelar",oDlg1,{|| oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return .T.

Static Function AlteraCond(cNF,cSerie,cCondPag)
    Local aArea  := SF1->(GetArea())
        DbSelectArea("SF1")
        SF1->(DbOrderNickName("DOCDEV"))
        SF1->(DBGOTOP(  ))                            
            if  SF1->( dbSeek('010101' + cNF + cSerie + "D" ) )    
                RecLock('SF1',.F.)
                Replace F1_COND With cCondPag
                SF1->(MsUnlock())
                SF1->(DbCloseArea())
                FWAlertSuccess("Alterado!","Sucesso")
            else
                FWAlertError("Nota Não Encontrada")
                oDlg1:End()
            endif
    RestArea( aArea )
Return .t.
