#INCLUDE "fwmvcdef.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} RCADZA1
Cadastro de Alunos
@type function
@version 1.0
@author Saulo Gomes Martins
@since 23/09/2022
//*/
User Function RCADZA1
	Local oBrowse	:= BrowseDef()
	oBrowse:Activate()
return

Static Function BrowseDef()
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription("Cadastro de Alunos")
	oBrowse:SetAlias('ZA1')
	oBrowse:DisableDetails()
	oBrowse:SetCanSaveArea(.T.)
	oBrowse:SetMenuDef( 'RCADZA1' )
	//Gráfico
	oBrowse:SetAttach(.T.)
Return oBrowse

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"		ACTION "PesqBrw"				OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Visualizar"		ACTION "VIEWDEF.RCADZA1"		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"			ACTION "VIEWDEF.RCADZA1"		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"			ACTION "VIEWDEF.RCADZA1"		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"			ACTION "VIEWDEF.RCADZA1"		OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Cópia"			ACTION "VIEWDEF.RCADZA1"		OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"			ACTION "VIEWDEF.RCADZA1"		OPERATION 8 ACCESS 0
Return aRotina

Static Function ModelDef()
	Local oModel as object
	Local oStruZA1 as object
	Local oStruZA2 as object
	oStruZA1	:= FWFormStruct( 1, 'ZA1',/*bAvalCampo*/,/*lViewUsado*/)
	oStruZA2	:= FWFormStruct( 1, 'ZA2',/*bAvalCampo*/,/*lViewUsado*/)

	//Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('YCADZA1')
	oModel:AddFields( 'ZA1MASTER', /*cOwner*/, oStruZA1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( {"ZA1_FILIAL", "ZA1_COD"})
	oModel:SetDescription( 'Cadastro de Alunos' )
	//oModel:GetModel( 'ZA1MASTER' ):SetDescription( '' )

	oModel:AddGrid("ZA2GRID", "ZA1MASTER",oStruZA2, ,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)
	oModel:SetRelation("ZA2GRID",{{"ZA2_FILIAL",'xFilial("ZA2")'},{"ZA2_CODZA1","ZA1_COD"}},ZA2->(IndexKey(1)))
	//oModel:GetModel( 'ZA2GRID' ):SetDescription( '' )
	oModel:GetModel( 'ZA2GRID' ):SetUniqueLine({"ZA2_CURSO"})

	//Calc
	oModel:AddCalc( 'RCADZA1CALC1', 'ZA1MASTER', 'ZA2GRID', 'ZA2_NOTA', 'NTOTAL', 'SUM',/*{ | oModel | CONDICIONAL }*/,,'TOTAL' )
	oModel:AddCalc( 'RCADZA1CALC1', 'ZA1MASTER', 'ZA2GRID', 'ZA2_NOTA', 'NMEDIA', 'AVG',/*{ | oModel | CONDICIONAL }*/,,'Média' )
	//oModel:AddCalc( 'RCADZA1CALC1', 'ZA1MASTER', 'ZA2GRID', 'ZA2_VALOR', 'NTOTQTD', 'FORMULA',/*{ | oModel | CONDICIONAL }*/,,'Total Vlr',/*{|oModel,nTotalAtual,xValor,lSomando| FORMULA */ )

	oModel:InstallEvent("RCADZA1", /*cOwner*/, RCADZA1():New())
	oModel:SetSource("RCADZA1")
Return oModel

Static Function ViewDef()
	Local oModel as object
	Local oStruZA1 as object
	Local oStruZA2 as object
	Local oView as object
	Local oCalc1 as object

	oModel		:= FwLoadModel( 'RCADZA1' )
	oStruZA1	:= FWFormStruct( 2, 'ZA1', /*bAvalCampo*/)
	oStruZA2	:= FWFormStruct( 2, 'ZA2', /*bAvalCampo*/)

	oStruZA2:RemoveField("ZA2_CODZA1")

	//Cria o objeto de View
	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField("ZA1MASTER", oStruZA1 )
	oView:AddGrid("ZA2GRID",oStruZA2)
	oCalc1 := FWCalcStruct( oModel:GetModel( 'RCADZA1CALC1') )
	oView:AddField( 'RCADZA1CALC1', oCalc1)

	//oView:AddIncrementField("ZA2GRID","ZA2_ITEM")

	oView:CreateHorizontalBox("CABEC",100,,.T.)
	oView:CreateHorizontalBox("GRID",100)
	oView:CreateHorizontalBox("TOTAIS",60,,.T.)
	oView:CreateFolder( "ABAS", "GRID" )
	oView:AddSheet( "ABAS", "ABA01", "Itens" )
	oView:CreateHorizontalBox( "ID_ABA01", 100,,, "ABAS", "ABA01" )

	oView:SetOwnerView( "ZA1MASTER", "CABEC" )
	oView:SetOwnerView( "ZA2GRID","ID_ABA01")
	oView:SetOwnerView( "RCADZA1CALC1","TOTAIS")

	//oView:SetFieldAction( 'ZA2_QTD', { || oView:Refresh("ZA2GRID") } )
	oView:SetViewProperty("ZA2GRID", "GRIDFILTER", {.T.})

Return oView

/*/{Protheus.doc} RCADZA1
Classe principal para controle do model
@type class
@version 1.0
@author Saulo Gomes Martins
@since 23/09/2022
//*/
Class RCADZA1 FROM FWModelEvent
	Method New() CONSTRUCTOR
End Class

Method New() Class RCADZA1
Return self
