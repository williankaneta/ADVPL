#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT120GOK
//TODO Descrição auto-gerada.
@author Willian Kaneta
@since 06/11/2019
@version 1.0
@type function
/*/	
user function MT120GOK()
	Local aAreaAtu	:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local aAreaSCR	:= SCR->(GetArea())
	Local cPedido   :=  PARAMIXB[1] // Numero do Pedido
	Local lInclui   :=  PARAMIXB[2] // Inclusão
	Local lAltera   :=  PARAMIXB[3] // Alteração
	Local lExclusao :=  PARAMIXB[4] // Exclusão
	
	//Excuta WebSevice Fluig na inclusão Pedido de Compras
	If lInclui
		U_WSSOAP01(cPedido)
	EndIf
	
	RestArea(aAreaSCR)
	RestArea(aAreaSC7)
	RestArea(aAreaAtu)
return