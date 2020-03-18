
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

//Constantes
#Define STR_PULA        Chr(13)+ Chr(10)

/*/{Protheus.doc} MAF301WK
//TODO
@description Consulta Específica Estoque SB1/SB2/SBZ/SBM
@type  User Function
@author Willian Kaneta
@since 29/10/2019
@version 1.0
/*/
User Function MAF301WK(lMenu)
    Local aArea     := GetArea()
    Local nTamBtn   := 50
    Local lInicio   := .T.

    //Privates
    Private cAliasPvt := "SB2"
    Private aCampos := {"B2_FILIAL","B1_TIPO","B1_COD","B1_DESC","B1_UM","BZ_XLOCAC","B2_QATU","B2_QEMPSA","XX_SALDATU","B2_CM1","B1_GRUPO","BM_DESC","B1_XCODFAB","B1_FABRIC","B2_LOCAL"}
    Private nTamanRet := 0
    Private cCampoRet := "B1_COD"
    //MsNewGetDados
    Private oMsNew
    Private aHeadAux := {}
    Private aColsAux := {}

    //Tamanho da janela
    Private nJanLarg := 1500
    Private nJanAltu := 0850
    //Gets e Dialog
    Private oDlgEspe    := Nil
    Private oBitPro		:= Nil
    Private aColsEsp	:= {"XX_SALDATU"}
    Private cCodPro     := ""
    Private cGrupPro    := ""
    Private cCodFabr    := ""
    Private cArmPad     := ""
    Private cDescProd   := ""
    Private cLocacao    := ""
    Private cDescFabr   := ""
    Private cFilSB2     := ""

    //Retorno
    Private lRetorn := .F.
    Public  __cRetorn := ""
    
    cCodPro     := Space(010)
    cGrupPro    := Space(004)
    cCodFabr    := Space(020)
    cArmPad     := Space(002)
    cDescProd   := Space(040)
    cLocacao    := Space(030)
    cDescFabr   := Space(020)
    cFilSB2     := xFilial("SB2")
     
    //Criando a estrutura para a MsNewGetDados
    fCriaMsNew()
    __cRetorn := Space(nTamanRet)
    
    //Criando a janela
    DEFINE MSDIALOG oDlgEspe TITLE "Consulta de Dados" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
    
    //Pesquisar
    @ 003, 003 GROUP oGrpPesqui TO 160, (nJanLarg/2)-3 PROMPT "Pesquisar: "    OF oDlgEspe COLOR 0, 16777215 PIXEL
    
    //Linha 1
    @ 013, 006 SAY "Código Produto"     OF oDlgEspe PIXEL SIZE 060 ,9
    @ 010, 055 MSGET oGetCodPro VAR cCodPro     SIZE 050, 010 	OF oDlgEspe COLORS 0, 16777215	PIXEL

    @ 013, 125 SAY "Grupo Produto"      OF oDlgEspe PIXEL SIZE 060 ,9
    @ 010, 174 MSGET oGetGruPro VAR cGrupPro    SIZE 050, 010 	OF oDlgEspe COLORS 0, 16777215	PIXEL
    
    @ 013, 244 SAY "Código Fabricante"  OF oDlgEspe PIXEL SIZE 060 ,9
    @ 010, 293 MSGET oGetCodFab VAR cCodFabr    SIZE 050, 010 	OF oDlgEspe COLORS 0, 16777215	PIXEL
  
    @ 013, 363 SAY "Armazém Padrão"     OF oDlgEspe PIXEL SIZE 060 ,9
    @ 010, 412 MSGET oGetArmPad VAR cArmPad SIZE 050, 010 		OF oDlgEspe COLORS 0, 16777215	PIXEL
    
    //Linha 2
    @ 033, 006 SAY "Descrição Produto"  OF oDlgEspe PIXEL SIZE 060 ,9
    @ 030, 055 MSGET oGetDesPro VAR cDescProd   SIZE 080, 010 	OF oDlgEspe COLORS 0, 16777215	PIXEL    

    @ 033, 155 SAY "Locação"            OF oDlgEspe PIXEL SIZE 060 ,9
    @ 030, 184 MSGET oGetLocao  VAR cLocacao    SIZE 050, 010 	OF oDlgEspe COLORS 0, 16777215	PIXEL 
    
    @ 033, 254 SAY "Descr. Fabricante"  OF oDlgEspe PIXEL SIZE 060 ,9
    @ 030, 303 MSGET oGetDesFab VAR cDescFabr   SIZE 050, 010 	OF oDlgEspe COLORS 0, 16777215	PIXEL    
    
    @ 033, 410 SAY "Filial"             OF oDlgEspe PIXEL SIZE 060 ,9
    @ 030, 425 MSGET oGetFilial VAR cFilSB2     SIZE 050, 010 	OF oDlgEspe COLORS 0, 16777215	PIXEL WHEN IIF(lMenu,.T.,.F.)

    @ 013,480 REPOSITORY oBitPro OF oDlgEspe NOBORDER SIZE 161,130 PIXEL
    
    @ 050, 010 BUTTON oBtnConf PROMPT "Pesquisar" SIZE nTamBtn, 013 OF oDlgEspe ACTION( fVldPesq() )     PIXEL
    
    //Dados
    @ 165, 003 GROUP oGrpDados TO (nJanAltu/2)-30, (nJanLarg/2)-3 PROMPT "Dados: "    OF oDlgEspe COLOR 0, 16777215 PIXEL
    oMsNew := MsNewGetDados():New(  175,;                                       //nTop
                                    006,;                                       //nLeft
                                    (nJanAltu/2)-35,;                           //nBottom
                                    (nJanLarg/2)-6,;                            //nRight
                                    GD_INSERT+GD_DELETE+GD_UPDATE,;            	//nStyle
                                    "AllwaysTrue",;                           	//cLinhaOk
                                    ,;                                          //cTudoOk
                                    "",;                                        //cIniCpos
                                    ,;                                          //aAlter
                                    ,;                                          //nFreeze
                                    999,;                                       //nMax
                                    ,;                                          //cFieldOK
                                    ,;                                          //cSuperDel
                                    ,;                                          //cDelOk
                                    oDlgEspe,;                                  //oWnd
                                    aHeadAux,;                                  //aHeader
                                    aColsAux)                                   //aCols                                    
    oMsNew:lActive := .F.
    If !lMenu
    	oMsNew:oBrowse:blDblClick := {|| fConfirm()}
    EndIf
    oMsNew:oBrowse:bChange := {|| RETIMAGEM()}
    
    If lInicio
        //Populando os dados da MsNewGetDados
        fPopula()
        lInicio := .F.
    EndIf
    
    //Ações
    If lMenu
	    @ (nJanAltu/2)-25, 003 GROUP oGrpAcoes TO (nJanAltu/2)-3, (nJanLarg/2)-3 PROMPT "Ações: "    OF oDlgEspe COLOR 0, 16777215 PIXEL
	    @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnLimp PROMPT "Limpar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fLimpar())     PIXEL
	    @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnCanc PROMPT "Fechar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fCancela())     PIXEL    
    Else
	    @ (nJanAltu/2)-25, 003 GROUP oGrpAcoes TO (nJanAltu/2)-3, (nJanLarg/2)-3 PROMPT "Ações: "    OF oDlgEspe COLOR 0, 16777215 PIXEL
	    @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Confirmar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fConfirm())     PIXEL
	    @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Limpar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fLimpar())     PIXEL
	    @ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*3)+12) BUTTON oBtnCanc PROMPT "Cancelar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fCancela())     PIXEL
    EndIf
    oMsNew:oBrowse:SetFocus()
    //Ativando a janela
    ACTIVATE MSDIALOG oDlgEspe CENTERED
    
    RestArea(aArea)
Return lRetorn

/*/{Protheus.doc} fCriaMsNew
//TODO
@description Função para criar a estrutura da MsNewGetDados
@author Willian Kaneta
@since 31/10/2019
@version 1.0
@type function
/*/
Static Function fCriaMsNew()
    Local aAreaX3 	:= SX3->(GetArea())
    Local nAtual	:= 0
    //Zerando o cabeçalho e a estrutura
    aHeadAux := {}
    aColsAux := {}
    
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2)) // Campo
    SX3->(DbGoTop())
    
    //Percorrendo os campos
    For nAtual := 1 To Len(aCampos)
        cCampoAtu := aCampos[nAtual]
        
    	If nAtual == 9
    	    //Cabeçalho ...    Titulo        Campo            Mask                        Tamanho    Dec        Valid    Usado    Tip        F3    CBOX
    	    aAdd(aHeadAux,{    "Saldo Disponível","XX_SALDATU",    "@E 999,999,999.999999",    16,            2,        ".F.",    ".F.",    "N",    "",    ""})            
        EndIf
                
        //Se coneguir posicionar no campo
        If SX3->(DbSeek(cCampoAtu))

            //Cabeçalho ...    Titulo            Campo        Mask                                    Tamanho                    Dec                            Valid    Usado    Tip                F3    CBOX
            aAdd(aHeadAux,{    X3Titulo(),    cCampoAtu,    Alltrim(SX3->X3_PICTURE),    TamSX3(cCampoAtu)[01],    TamSX3(cCampoAtu)[02],    ".F.",    ".F.",    SX3->X3_TIPO,    "",    ""})
                
            //Se o campo atual for retornar, aumenta o tamanho do retorno
            If cCampoAtu $ cCampoRet
                nTamanRet += TamSX3(cCampoAtu)[01]
            EndIf
        EndIf
    Next
    
    RestArea(aAreaX3)
Return

/*/{Protheus.doc} fPopula
//TODO
@description Função que popula a tabela auxiliar da MsNewGetDados 
@author Willian Kaneta
@since 31/10/2019
@version 1.0
@type function
/*/
Static Function fPopula()
    Local aColsAux 	:={}
    Local aAux 		:= Nil
    Local nCampAux 	:= 1
    Local nAtual 	:= 0
    Local cQuery	:= ""
    

    //Faz a consulta
    If Empty(cCodPro) .AND. Empty(cDescProd) .AND. Empty(cArmPad) .AND. Empty(cCodFabr) .AND. Empty(cDescFabr) .AND. Empty(cLocacao)
    	cQuery := "	 SELECT TOP 50"	
    Else	
    	cQuery := "	 SELECT "
    EndIf
    cQuery += "  B2.B2_FILIAL "
    cQuery += " ,B1.B1_TIPO "
    cQuery += " ,B1.B1_COD "
    cQuery += " ,B1.B1_DESC "
    cQuery += " ,B1.B1_UM "
    cQuery += " ,BZ.BZ_XLOCAC "
    cQuery += " ,B2.B2_QATU "
    cQuery += " ,B2.B2_QEMPSA "
    cQuery += " ,B2.B2_CM1 " 
    cQuery += " ,(B2.B2_QATU - B2.B2_QEMPSA) AS XX_SALDATU "  
    cQuery += " ,B1.B1_GRUPO "
    cQuery += " ,BM.BM_DESC "    
    cQuery += " ,B1.B1_XCODFAB "
    cQuery += " ,B1.B1_FABRIC "
    cQuery += " ,B2.B2_LOCAL "
    cQuery += " FROM " + RetSQLName("SB1") + " B1 "
    cQuery += "	LEFT JOIN " + RetSQLName("SB2") + " B2 ON B2.B2_COD = B1.B1_COD "
    If !Empty(cFilSB2)
        cQuery += "	AND B2.B2_FILIAL = " + Alltrim(cFilSB2)
    EndIf
    cQuery += "	AND B2.D_E_L_E_T_ <> '*' "    
    cQuery += "	LEFT JOIN " + RetSQLName("SBZ") + " BZ ON BZ.BZ_COD = B2.B2_COD AND BZ.BZ_FILIAL = B2.B2_FILIAL "
    cQuery += "	AND BZ.D_E_L_E_T_ <>	'*' "
    cQuery += "	LEFT JOIN "+ RetSQLName("SBM") +" BM ON BM.BM_GRUPO = B1.B1_GRUPO "
    cQuery += "	AND BM.D_E_L_E_T_ <>	'*' " 
    cQuery += "	WHERE  	B1.B1_MSBLQL = '2' " 
    cQuery += "	AND B1.D_E_L_E_T_ <> '*' "
	If !Empty(cCodPro)
	    cQuery += "AND B2.B2_COD LIKE '%" + Alltrim(cCodPro) + "%'"
	EndIf
    If !Empty(cDescProd)
        cQuery += "AND B1.B1_DESC LIKE '%" + UPPER(Alltrim(cDescProd)) + "%'"
    EndIf	
    If !Empty(cArmPad)
        cQuery += "AND B2.B2_LOCAL LIKE '%" + Alltrim(cArmPad) + "%'"
    EndIf    
    If !Empty(cGrupPro)
        cQuery += "AND BM.BM_GRUPO LIKE '%" + Alltrim(cGrupPro) + "%'"
    EndIf
    If !Empty(cCodFabr)
        cQuery += "AND B1.B1_XCODFAB LIKE '%" + Alltrim(cCodFabr) + "%'"
    EndIf
    If !Empty(cDescFabr)
        cQuery += "AND B1.B1_FABRIC LIKE '%" + Alltrim(cDescFabr) + "%'"
    EndIf     
    If !Empty(cLocacao)
        cQuery += "AND BZ.BZ_XLOCAC LIKE '%" + Alltrim(cLocacao) + "%'"
    EndIf
 
    TCQuery cQuery New Alias "QRY_SB1"
    
    //Percorrendo a estrutura, procurando campos de data
    For nAtual := 1 To Len(aHeadAux)
        //Se for data
        If aHeadAux[nAtual][8] == "D"
            TCSetField('QRY_SB1', aHeadAux[nAtual][2], 'D')
        EndIf
    Next
    
    //Enquanto tiver dados
    While ! QRY_SB1->(EoF())
        nCampAux := 1
        aAux := {}
        //Percorrendo os campos e adicionando no acols (junto com o recno e com o delet
        For nAtual := 1 To Len(aCampos)
            cCampoAtu := aCampos[nAtual]
            
            If cCampoAtu == "B2_FILIAL" .AND. !Empty(QRY_SB1->B2_FILIAL)
            	aAdd(aAux, QRY_SB1->B2_FILIAL)
            ElseIf cCampoAtu == "B2_FILIAL" .AND. Empty(QRY_SB1->B2_FILIAL) .AND. !Empty(cFilSB2) 
            	aAdd(aAux, cFilSB2)
            ElseIf cCampoAtu == "B2_FILIAL" .AND. Empty(QRY_SB1->B2_FILIAL) .AND. Empty(cFilSB2)
            	aAdd(aAux, "999999")            
            Else
            	aAdd(aAux, &("QRY_SB1->"+cCampoAtu))
            EndIf
                        
        Next

        aAdd(aAux, .F.)
        
        aAdd(aColsAux, aClone(aAux))
        QRY_SB1->(DbSkip())
    EndDo
    QRY_SB1->(DbCloseArea())
    
    //Se não tiver dados, adiciona linha em branco
    If Len(aColsAux) == 0
        aAux := {}
        //Percorrendo os campos e adicionando no acols (junto com o recno e com o delet
        For nAtual := 1 To Len(aCampos)
            aAdd(aAux, '')
        Next
        aAdd(aAux, 0)
        aAdd(aAux, .F.)
    
        aAdd(aColsAux, aClone(aAux))
    EndIf
    
    //Posiciona no topo e atualiza grid
    oMsNew:SetArray(aColsAux)
    oMsNew:oBrowse:Refresh()
Return

/*/{Protheus.doc} fConfirm
//TODO
@description Função de confirmação da rotina 
@author Willian Kaneta
@since 31/10/2019
@version 1.0
@type function
/*/
Static Function fConfirm()
    Local aAreaX3 	:= SX3->(GetArea())
    Local cAux 		:= ""
    Local aColsNov 	:= oMsNew:aCols
    Local nLinAtu  	:= oMsNew:nAt
    Local nAtual	:= 0	
    
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2)) // Campo
    SX3->(DbGoTop())

    //Percorrendo os campos
    For nAtual := 1 To Len(aHeadAux)
        cCampoAtu := aHeadAux[nAtual][2]
    
        //Se coneguir posicionar no campo
        If SX3->(DbSeek(cCampoAtu))
            //Se o campo atual for retornar, soma com o auxiliar
            If cCampoAtu $ cCampoRet
                cAux += aColsNov[nLinAtu][nAtual]
            EndIf
        EndIf
    Next

    //Setando o retorno conforme auxiliar e finalizando a tela
    lRetorn := .T.
    __cRetorn := cAux
      
     
    //Se o tamanho for menor, adiciona
    If Len(__cRetorn) < nTamanRet
        __cRetorn += Space(nTamanRet - Len(__cRetorn))
    
    //Senão se for maior, diminui
    ElseIf Len(__cRetorn) > nTamanRet
        __cRetorn := SubStr(__cRetorn, 1, nTamanRet)
    EndIf
    
    oDlgEspe:End()
    RestArea(aAreaX3)
Return

/*/{Protheus.doc} fCriaMsNew
//TODO
@description Função que limpa os dados da rotina 
@author Willian Kaneta
@since 31/10/2019
@version 1.0
@type function
/*/
Static Function fLimpar()
    //Zerando gets
    cCodPro     := Space(010)
    cGrupPro    := Space(004)
    cCodFabr    := Space(020)
    cArmPad     := Space(002)
    cDescProd   := Space(040)
    cLocacao    := Space(030)
    cDescFabr   := Space(020)
    cFilSB2     := xFilial("SB2")

    oGetCodPro:Refresh()
    oGetGruPro:Refresh()
    oGetCodFab:Refresh()
    oGetArmPad:Refresh()
    oGetDesPro:Refresh()
    oGetLocao:Refresh()
    oGetDesFab:Refresh()
    oGetFilial:Refresh()

    //Atualiza grid
    fPopula()
    
    //Setando o foco na pesquisa
    oGetCodPro:SetFocus()
    oGetGruPro:SetFocus()
    oGetCodFab:SetFocus()
    oGetArmPad:SetFocus()
    oGetDesPro:SetFocus()
    oGetLocao:SetFocus()
    oGetDesFab:SetFocus()
    oGetFilial:SetFocus()
Return

/*/{Protheus.doc} fCancela
//TODO
@description Função de cancelamento da rotina 
@author Willian Kaneta
@since 31/10/2019
@version 1.0
@type function
/*/
Static Function fCancela()
    //Setando o retorno em branco e finalizando a tela
    lRetorn := .F.
    __cRetorn := Space(nTamanRet)
    oDlgEspe:End()
Return

/*/{Protheus.doc} fCancela
//TODO
@description Função que valida o campo digitado
@author Willian Kaneta
@since 31/10/2019
@version 1.0
@type function
/*/
Static Function fVldPesq()
    Local lRet	:= .T.
            
    //Se tiver apóstrofo ou porcentagem, a pesquisa não pode prosseguir
    If  ("'" $ cCodPro  .Or. "%" $ cCodPro)     .AND.;
        ("'" $ cGrupPro .Or. "%" $ cGrupPro)    .AND.;
        ("'" $ cCodFabr .Or. "%" $ cCodFabr)    .AND.;
        ("'" $ cArmPad  .Or. "%" $ cArmPad)     .AND.;
        ("'" $ cDescProd.Or. "%" $ cDescProd)   .AND.;
        ("'" $ cLocacao .Or. "%" $ cLocacao)    .AND.;
        ("'" $ cDescFabr .Or. "%" $ cDescFabr)  .AND.;
        ("'" $ cFilSB2  .Or. "%" $ cFilSB2)
        lRet := .F.
        MsgAlert("<b>Pesquisa inválida!</b><br>A pesquisa não pode ter <b>'</b> ou <b>%</b>.", "Atenção")
    EndIf

    //Se houver retorno, atualiza grid
    If lRet
        fPopula()
        RETIMAGEM()
    EndIf
Return

/*/{Protheus.doc} RETIMAGEM
//TODO
@description Função para retornar a imagem salva no cadastro de Produtos - Repositório de Imagens
@author willian.kaneta
@since 18/11/2019
@version 1.0
@return return_description
@type function
/*/
Static Function RETIMAGEM()
	Local lRet 		:= .T.
    Local aColsNov 	:= oMsNew:aCols
    Local nLinAtu  	:= oMsNew:nAt
    Local cB1BITMAP	:= ""
    Local cAux 		:= ""
    Local nAtual 	:= 0    
    
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2)) // Campo
    SX3->(DbGoTop())

    //Percorrendo os campos
    For nAtual := 1 To Len(aHeadAux)
        cCampoAtu := aHeadAux[nAtual][2]
    
        //Se coneguir posicionar no campo
        If SX3->(DbSeek(cCampoAtu))
            //Se o campo atual for retornar, soma com o auxiliar
            If cCampoAtu $ cCampoRet
                cAux += aColsNov[nLinAtu][nAtual]
            EndIf
        EndIf
    Next	
	
	__cRetorn := cAux
	
    cB1BITMAP := POSICIONE("SB1",1,xFilial("SB1")+__cRetorn,"B1_BITMAP")
    
    Showbitmap(oBitPro,cB1BITMAP)
    oBitPro:lStretch:=.T.
    oBitPro:Refresh() 	
Return lRet