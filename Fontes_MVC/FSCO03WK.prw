#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.ch"

/*/{Protheus.doc} User Function FSCO03WK
    Função utilizado para retornar o filtro na rotina Solicitação Insumo
    @type  Function
    @author Willian Kaneta
    @since 14/03/2020
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function FSCO03WK()
    Local   cRet        := ""
    Local   cFilterBrw  := ""

    Private cPerg 	    := "FSCO01WK"

    AJUSTASX1(cPerg)

	If !Pergunte(cPerg,.T.)
		Return Nil
	EndIf	
    
    cFilterBrw := RETFILTER()

    If !Empty(cFilterBrw)
		cRet := "ZZ1_CODSC $ " + '"' +cFilterBrw + '"'
	EndIf
Return cRet

/*/{Protheus.doc} Static Function AJUSTASX1
	Função grupo de perguntas SX1
	@type  Function
	@author Willian Kaneta
	@since 11/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function AJUSTASX1(cPerg)
	Local aRegs := {}
	Local nX := 0

	/*-----------------------MV_PAR01--------------------------*/
	aAdd(aRegs,{cPerg,'01','Nº SC ?'		,'Nº SC ?'			,'Nº SC ?'			,'mv_ch1' ,'C',06,0,0,'G','','MV_PAR01',''             ,'',''    ,''	,	  ''        ,  ''   ,'' })	

	/*-----------------------MV_PAR01--------------------------*/
	aAdd(aRegs,{cPerg,'02','Produto ?'		,'Produto ?'			,'Produto ?'	,'mv_ch2' ,'C',15,0,0,'G','','MV_PAR02',''             ,'',''    ,''	,	  ''        ,  ''   ,'' })	


	DbSelectArea('SX1')
	DbSetOrder(1)

	For nX := 1 to Len(aRegs)
		If	!MsSeek(PadR(cPerg, Len(X1_GRUPO)) + aRegs[nX][02])
			If	RecLock('SX1',.T.)
				Replace X1_GRUPO	With aRegs[nX][01]
				Replace X1_ORDEM   	With aRegs[nX][02]
				Replace X1_PERGUNTE	With aRegs[nX][03]
				Replace X1_PERSPA	With aRegs[nX][04]
				Replace X1_PERENG	With aRegs[nX][05]
				Replace X1_VARIAVL	With aRegs[nX][06]
				Replace X1_TIPO		With aRegs[nX][07]
				Replace X1_TAMANHO	With aRegs[nX][08]
				Replace X1_DECIMAL	With aRegs[nX][09]
				Replace X1_PRESEL	With aRegs[nX][10]
				Replace X1_GSC		With aRegs[nX][11]
				Replace X1_VALID	With aRegs[nX][12]
				Replace X1_VAR01	With aRegs[nX][13]
				Replace X1_DEF01	With aRegs[nX][14]
				Replace X1_DEF02	With aRegs[nX][15]
				Replace X1_DEF03	With aRegs[nX][16]
				Replace X1_DEF04	With aRegs[nX][17]
				Replace X1_DEF05	With aRegs[nX][18]
				Replace X1_F3   	With aRegs[nX][19]
				MsUnlock('SX1')
			EndIf
		Endif
	next

Return

/*/{Protheus.doc} 
	Função para retornar as SCs para filtrar na tabela ZZ1
	@type  Static Function RETFILTER
	@author Willian Kaneta
	@since 11/03/2020
	@version 1.0
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RETFILTER()
	Local cRet 		:= ""
	Local cCodSCAnt	:= ""
	Local cWhere	:= ""
	Local cQryAux  	:= ""
	Local lFirst	:= .T.
	Local lFilter 	:= .F. 

	If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
			cWhere := " AND ZZ2.ZZ2_AUTORI = '" + MV_PAR01 + "'"
			cWhere += " AND ZZ2.ZZ2_CODPRO 	= '" + MV_PAR02 + "'"
	ElseIf !Empty(MV_PAR01) .AND. Empty(MV_PAR02)
			cWhere := " AND ZZ2.ZZ2_AUTORI = '" + MV_PAR01 + "'"
	ElseIf Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
			cWhere := " AND ZZ2.ZZ2_CODPRO 	= '" + MV_PAR02 + "'"
	EndIf

	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cQryAux :=	"SELECT ZZ2.ZZ2_CODSC "
		cQryAux += 	"FROM "+ RetSqlName("ZZ2") + " ZZ2 "
		cQryAux +=	"WHERE ZZ2.D_E_L_E_T_ <> '*' "
		cQryAux +=	cWhere
		
		TCQuery cQryAux New Alias "ZZ2TMP"
		lFilter := .T. 		
	EndIf

	If lFilter
		While ZZ2TMP->(!EOF())
			If lFirst
				cRet 	:= ZZ2TMP->ZZ2_CODSC
				lFirst 	:= .F.
			Else
				If cCodSCAnt != ZZ2TMP->ZZ2_CODSC
					cRet 	+=  "|" + ZZ2TMP->ZZ2_CODSC
				EndIf
			EndIf
			cCodSCAnt := ZZ2TMP->ZZ2_CODSC
			ZZ2TMP->(DbSkip())
		EndDo
		ZZ2TMP->(DBCLOSEAREA())
	EndIf
Return cRet