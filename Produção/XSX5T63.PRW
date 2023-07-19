/*//#########################################################################################
Project  : Melhorias nos processos - Fonnet
Module   : Financeiro
Source   : XSX5T63
Objective: Cadastro tabela genérica SX5 - 63 Feriados
*///#########################################################################################

//Bibliotecas
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"

//Variáveis Estáticas
STATIC cTitulo := "Feriados"

/*/{Protheus.doc} XSX5T63
    Gerenciador de Processamento
    @type    function
    @author  Dilson Castro
    @since   15-06-2022
    @table   
/*/

USER FUNCTION XSX5T63()
    //Variáveis Locais
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
    Local cTabela := "63" // Tabela na SX5
    Local cChave  := "001" // Feriados
    Local cTitulo := "Feriados"
    Private cTabX := cTabela
    //Setando tabela
    DbSelectArea('SX5')
    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
    SX5->(DbGoTop())
    //Procurar na tabela SX5
        If SX5->(DbSeek(FWxFilial("SX5") + cTabela + cChave))
            ///-Alterado por Dilson Castro em 29/08/2022
            //Direct Access not allowed in data dictionary
            //cTitulo := SX5->X5_DESCRI
            cTitulo := &("SX5->X5_DESCRI")
			///-
        Else
            MsgAlert("Tabela "+cTabela+" Chave "+cChave+" não encontrada!", "Atenção")
            Return
        EndIf
    //Instânciando FWMBrowse - Somente com dicionário de dados
    SetFunName("XSX5T63")
    oBrowse := FWMBrowse():New()
    //Setando a tabela de cadastro de Feriados
    oBrowse:SetAlias("SX5")
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
    //Filtrando
    oBrowse:SetFilterDefault("SX5->X5_TABELA = '"+cTabela+"'")
    //Ativa a Browse
    oBrowse:Activate()
    SetFunName(cFunBkp)
    RestArea(aArea)
RETURN
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Dilson Castro                                                |
 | Data:  15/06/2022                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
STATIC FUNCTION MENUDEF()
    Local aRot := {}     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.XSX5T63' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.XSX5T63' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.XSX5T63' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.XSX5T63' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
RETURN aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Dilson Castro                                                |
 | Data:  15/06/2022                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
STATIC FUNCTION ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
    //Criação da estrutura de dados utilizada na interface
    Local oStSX5 := FWFormStruct(1,"SX5")
    //Editando características do dicionário
    oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                       //Modo de Edição
    oStSX5:SetProperty('X5_TABELA',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTabX'))                   //Ini Padrão
    oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    'Iif(INCLUI, .T., .F.)'))     //Modo de Edição
    oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'U_XSX5CHV()'))               //Validação de Campo
    oStSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório
    oStSX5:SetProperty('X5_DESCRI',   MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("XSX5T63M",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)      
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMSX5",/*cOwner*/,oStSX5)
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE'})
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
    //Setando a descrição do formulário
    oModel:GetModel("FORMSX5"):SetDescription("Formulário do Cadastro "+cTitulo)
RETURN oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Dilson Castro                                                |
 | Data:  15/06/2022                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
STATIC FUNCTION ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Feriados
    Local oModel := FWLoadModel("XSX5T63")
    //Criação da estrutura de dados utilizada na interface do cadastro de Feriados
    Local oStSX5 := FWFormStruct(2, "SX5")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SX5_NOME|SX5_DTAFAL|'} 
    //Criando oView como nulo
    Local oView := Nil
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
    //Atribuindo formulários para interface
    oView:AddField("VIEW_SX5", oStSX5, "FORMSX5")
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_SX5', 'Dados - '+cTitulo )  
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.}) 
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SX5","TELA")
    //Retira o campo de tabela da visualização
    oStSX5:RemoveField("X5_TABELA")
RETURN oView
 
/*/{Protheus.doc} XSX5CHV
Função que valida a digitação do campo Chave, para verificar se já existe
@type function
@author Dilson Castro
@since 15/06/2022
@version 1.0
/*/
 
USER FUNCTION XSX5CHV()
    Local aArea    := GetArea()
    Local lRet     := .T.
    Local cX5Chave := M->X5_CHAVE     
    DbSelectArea('SX5')
    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
    SX5->(DbGoTop())
    //Se conseguir posicionar, já existe
    If SX5->(DbSeek(FWxFilial('SX5') + cTabX + cX5Chave))
        MsgAlert("Já existe chave com esse código (<b>"+cX5Chave+"</b>)!", "Atenção")
        lRet := .F.
    EndIf
    RestArea(aArea)
RETURN lRet
