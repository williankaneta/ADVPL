
#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MAF302WK
//TODO
@description Função para chamar a Consulta Estoque - MAF301WK pelo Menu 
@author willian.kaneta
@since 13/11/2019
@version 1.0
@type function
/*/
user function MAF302WK()
	Local lMenu := .T.
	
	//Executa função consulta estoque Masutti
	U_MAF301WK(lMenu)
	
return