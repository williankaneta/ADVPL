#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} WREST02WK
//TODO
@description Classe Pedido utilizado no fonte WREST01WK
@author Willian Kaneta
@since 01/11/2019
@version 1.0
@type function
/*/
user function WREST02WK()
	
return

/*/{Protheus.doc} PEDIDO
//TODO
@description Classe Pedido
@author Willian Kaneta
@since 01/11/2019
@version 1.0
@type class
/*/
Class PEDIDO	
	
	DATA item		As String
	DATA produto	As String
	DATA descricao	As String
	DATA unidmed	As String
	DATA segunid	As String
	DATA preco		As float
	DATA quant		As float
	
	Method New() Constructor
	Method SetItem(cItem)
	Method SetProd(cProduto)
	Method SetDesc(cDescricao)
	Method SetUMed(cUnidmed)
	Method SetSegU(cSegunid)
	Method SetPrec(nPreco)
	Method SetQuan(nQuant)	

EndClass

/*/{Protheus.doc} New
Método Construtor
@author Willian Kaneta
@since 18/04/2017
@version 1.0
@type function
/*/
Method New() Class PEDIDO

	::item		:= ""		
	::produto	:= ""
	::descricao	:= ""
	::unidmed	:= ""
	::segunid	:= ""
	::quant		:= 0
	::preco		:= 0	

Return(Self)
	
// --> Métodos Setters			
Method SetItem(cItem) Class PEDIDO
Return(::item := cItem)
	
Method SetProd(cProduto) Class PEDIDO
Return(::produto := cProduto)

Method SetDesc(cDescricao) Class PEDIDO
Return(::descricao := cDescricao)

Method SetUMed(cUnidmed) Class PEDIDO
Return(::unidmed := cUnidmed)				

Method SetSegU(cSegunid) Class PEDIDO
Return(::segunid := cSegunid)	

Method SetPrec(nPreco) Class PEDIDO
Return(::preco := nPreco)		

Method SetQuan(nQuant) Class PEDIDO
Return(::quant := nQuant)			