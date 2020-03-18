#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} WREST03WK
//TODO
@description Classe FULL_PEDIDO utilizado no fonte WREST01WK
@author Willian Kaneta
@since 01/11/2019
@version 1.0
@type function
/*/
user function WREST03WK()
	
return

/*/{Protheus.doc} FULL_PEDIDO
//TODO
@description Classe é onde armazenamos uma lista dos objetos da classe PEDIDO
@author Willian Kaneta
@since 01/11/2019
@version 1.0
@type class
/*/
Class FULL_PEDIDO
	
	Data Pedido
	
	Method New() Constructor
	Method Add() 
	
EndClass
/*/{Protheus.doc} New
Método contrutor
@author Willian Kaneta
@since 01/11/2019
@type function
@version 1.0
/*/
Method New() Class FULL_PEDIDO
	::Pedido := {}
Return(Self)

/*/{Protheus.doc} Add	
Adiciona um novo objeto de pedido
@author Willian
@since 01/11/2019
@param oPedido, object, Objeto da Classe Pedido
@type function
/*/
Method Add(oPedido) Class FULL_PEDIDO
	Aadd(::Pedido, oPedido)
Return