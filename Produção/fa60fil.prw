#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/04/01

User Function fa60fil()        // incluido pelo assistente de conversao do AP5 IDE em 26/04/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("X,MFIL,MTIPO,_CFILT,")

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  FA60FIL � Autor � Edna Ferreira       � Data � 24/11/14   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de entrada que altera o filtro da rotina de Borderos ���
���          � de Transferencias                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
Alteracoes: 
Edna Ferreira - 15/04/04 - Considerar tipo FT
*/
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
x:=''
mFil  := SPACE(3)
mPortado := SPACE(3)

_cFilt := ""

@ 0,0 TO 150,300 DIALOG oDlg1 TITLE "Portador"
@ 17,35 Say "Digite o Portador do Titulo  : "


@ 17,97 Get mPortado F3 "SA6"


@ 10,125 BMPBUTTON TYPE 1 ACTION AtuTipo()
@ 25,125 BMPBUTTON TYPE 2 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 CENTER


RETURN(_cFilt)

Static Function Atutipo()

If !empty(mPortado )
   _cFilt := "E1_PORTADO == '"+mPortado+"' "
Endif
Close(oDlg1)
Return(Nil)