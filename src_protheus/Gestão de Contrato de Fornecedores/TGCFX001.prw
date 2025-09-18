#include 'totvs.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TRYEXCEPTION.CH"

/*/{Protheus.doc} TGCFX001
Apresentação de consulta para apresentação dos contratos a serem importados, com opção para leitura de planilha
@author Wagner Mobile Costa
@since 21/04/2025
@version 1.00

@type function
/*/

Static aForm    := {}
Static aJoin    := {}
Static aFolder  := {}
Static __ROTINA := "TGCFX001"
Static aStatic  := {}
Static cMarca   := ""
Static aPB9		:= {}

User Function TGCFX001

Private aQuery  := {}

	LoadForm()

	MontaForm("Importação de Contrato de Fornecedores", aForm, aFolder, aJoin)

Return

Static Function LoadForm
	
	If Len(aForm) > 0
		Return
	EndIf

	// 1. Cabeçalho
	Aadd(aForm, DataForm("PX2", "PX2_OK"))

	// 2. PB9
	Aadd(aForm, DataForm("PB9",, .T.))
	Aadd(aFolder, "Combinações")
	Aadd(aJoin, "PB9_FILIAL=PX2_FILIAL;PB9_CONTRA=PX2_CONTRA")

	// 3. PX7
	Aadd(aForm, DataForm("PX7"))
	Aadd(aFolder, "Fornecedores")
	Aadd(aJoin, "PX7_FILIAL=PX2_FILIAL;PX7_CONTRA=PX2_CONTRA")

	// 4. PX3
	Aadd(aForm, DataForm("PX3"))
	Aadd(aFolder, "Itens")
	Aadd(aJoin, "PX3_FILIAL=PX2_FILIAL;PX3_CONTRA=PX2_CONTRA")

	// 5. PX4
	Aadd(aForm, DataForm("PX4"))
	Aadd(aFolder, "Empresas")
	Aadd(aJoin, "PX4_FILIAL=PX2_FILIAL;PX4_CONTRA=PX2_CONTRA")

	// 6. PX6
	Aadd(aForm, DataForm("PX6"))
	Aadd(aFolder, "Usuários")
	Aadd(aJoin, "PX6_FILIAL=PX2_FILIAL;PX6_CONTRA=PX2_CONTRA")

Return

Static Function DataForm(cAlias, cFieldMark, lOptional)

Local aSX3    := {}
Local aIndTrb := {}
Local cUsado  := Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)
Local cOrdem  := "00"
Local cX3_INIBRW  := ""
Local cX3_RELACAO := ""
Local cX3_CONTEXT := ""
Local aFields	  := FWSX3Util():GetAllFields( cAlias,.T. )
Local nFields	  := 1

DEFAULT cFieldMark := ""
DEFAULT lOptional  := .F.

#DEFINE P_X3_CONTEXT		15

For nFields := 1 To Len(aFields)
	cCampo := Alltrim(aFields[nFields])
	
	cX3_INIBRW  := AllTrim(StrTran(GetSx3Cache(cCampo,"X3_INIBRW"), cAlias + "->", cAlias + "IMP->"))
	cX3_RELACAO := AllTrim(StrTran(GetSx3Cache(cCampo,"X3_RELACAO"), cAlias + "->", cAlias + "IMP->"))
	cX3_CONTEXT := Alltrim(GetSx3Cache(cCampo,"X3_CONTEXT"))
	cOrdem := GetSx3Cache(cCampo,"X3_ORDEM")
	Aadd(aSX3, { 	cCampo,;
					GetSx3Cache(cCampo,"X3_TIPO"),;
					GetSx3Cache(cCampo,"X3_TAMANHO"),;
					GetSx3Cache(cCampo,"X3_DECIMAL"),;
					cOrdem,;
					Alltrim(GetSx3Cache(cCampo,"X3_TITULO")),;
					Alltrim(GetSx3Cache(cCampo,"X3_PICTURE")),;
					GetSx3Cache(cCampo,"X3_CBOX"),;
					GetSx3Cache(cCampo,"X3_NIVEL"),;
					GetSx3Cache(cCampo,"X3_BROWSE"),;
					cUsado,;
					GetSx3Cache(cCampo,"X3_F3"),;
					cX3_INIBRW,;
					cX3_RELACAO,;
					cX3_CONTEXT } )
Next
// Cabecalho Contrato
If cAlias == "PX2"
	Aadd(aSX3, { 	"PX2_XCTR",;
					"M",;
					10,;
					0,;
					cOrdem,;
					"Efetivação Contrato",;
					"",;
					"",;
					1,;
					"S",;
					cUsado,;
					"",;
					"",;
					"",;
					"V" } )
	cOrdem := Soma1(cOrdem)

	Aadd(aSX3, { 	"PX2_XWAR",;
					"M",;
					10,;
					0,;
					cOrdem,;
					"Log de Avisos",;
					"",;
					"",;
					1,;
					"S",;
					cUsado,;
					"",;
					"",;
					"",;
					"V" } )
	cOrdem := Soma1(cOrdem)

	Aadd(aSX3, { 	"PX2_XNWAR",;
					"N",;
					2,;
					0,;
					cOrdem,;
					"Número de Avisos",;
					"",;
					"",;
					1,;
					"S",;
					cUsado,;
					"",;
					"",;
					"",;
					"V" } )
	cOrdem := Soma1(cOrdem)

	Aadd(aSX3, { 	"PX2_XLOG",;
					"M",;
					10,;
					0,;
					cOrdem,;
					"Log de Erros",;
					"",;
					"",;
					1,;
					"S",;
					cUsado,;
					"",;
					"",;
					"",;
					"V" } )
	cOrdem := Soma1(cOrdem)

	Aadd(aSX3, { 	"PX2_NLOG",;
					"N",;
					2,;
					0,;
					cOrdem,;
					"Número de Erros",;
					"",;
					"",;
					1,;
					"S",;
					cUsado,;
					"",;
					"",;
					"",;
					"V" } )
	cOrdem := Soma1(cOrdem)

	Aadd(aSX3, { 	"PX2_XPLIMP",;
					"M",;
					10,;
					0,;
					cOrdem,;
					"Linha Planilha",;
					"",;
					"",;
					1,;
					"S",;
					cUsado,;
					"",;
					"",;
					"",;
					"V" } )
	cOrdem := Soma1(cOrdem)

	Aadd(aSX3, { 	"PX2_CORLEG",;
					"C",;
					1,;
					0,;
					cOrdem,;
					"Legenda",;
					"",;
					"",;
					1,;
					"N",;
					cUsado,;
					"",;
					"",;
					"",;
					"V" } )
	cOrdem := Soma1(cOrdem)

	Aadd(aSX3, { 	"PX2_OK",;
					"C",;
					2,;
					0,;
					cOrdem,;
					"Marcação",;
					"",;
					"",;
					1,;
					"N",;
					"",;
					"",;
					"",;
					"",;
					"V" } )

	cOrdem := Soma1(cOrdem)
EndIf

SIX->(DbSetOrder(1))
SIX->(DbSeek(cAlias))
While SIX->(FieldGet(FieldPos("INDICE"))) == cAlias .And. ! SIX->(Eof())
	Aadd(aIndTrb,{ 	SIX->(FieldGet(FieldPos("ORDEM"))), Alltrim(SIX->(FieldGet(FieldPos("CHAVE")))),;
					Capital(SIX->(FieldGet(FieldPos("DESCRICAO")))),;
					CriaTrab(Nil,.F.) + SIX->(FieldGet(FieldPos("ORDEM"))), "N"})
	SIX->(DbSkip())
EndDo

#DEFINE P_FIELD_MARK	6
#DEFINE P_REG_LOAD		7
#DEFINE P_OPTIONAL		8

Return { cAlias, aSX3, aIndTrb, Nil, Nil, cFieldMark, {}, lOptional }

/*/{Protheus.doc} MontaForm
Montagem do formulário para grid da importação
@author Wagner Mobile Costa
@since 21/04/2025
@version 1.00

@type function
/*/

Static Function MontaForm(cCadastro, aForm, aFolder, aJoin)

Local oFWLayer  := FWLayer():New() 
Local oPnlCapa, oDlg
Local nPos      := 1
Local aSize     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula as dimensoes dos objetos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()

__PQ1_ID  := ""

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

oFWLayer:Init(oDlg,.F.)

oFWLayer:AddLine( 'UP', If(Len(aFolder) > 0, 45, 100), .F.)
oFWLayer:AddCollumn( 'ALLUP', 100, .T., 'UP')
oPnlCapa := oFWLayer:GetColPanel ('ALLUP', 'UP')

If ! CreateBrowse(oPnlCapa, aForm[1][2], aForm[1][3], aForm[1][1], "", "", aForm[1][P_FIELD_MARK])
	Return .F.
EndIF

oCQuery := aQuery[1][2]
oBrowse := aQuery[1][4]

oBrowse:SetProfileID(__ROTINA + aForm[1][1])
oBrowse:ForceQuitButton()

If Len(aFolder) > 0
	// Define painel Detail
	oFWLayer:AddLine( 'DOWN', 55, .F.)
	oPnlDetail := oFWLayer:GetLinePanel ('DOWN')

	oFolder := TFolder():New( 0, 0, aFolder, aFolder, oPnlDetail,,,, .T.,,oPnlDetail:NCLIENTWIDTH/2,(oPnlDetail:NCLIENTHEIGHT/2))

	For nPos := 2 To Len(aForm)
		If ! CreateBrowse(oFolder:aDialogs[nPos - 1], aForm[nPos][2], aForm[nPos][3],;
						  aForm[nPos][1], aJoin[nPos - 1], "", aForm[nPos][P_FIELD_MARK])
			Return .F.
		EndIf

		aQuery[nPos][4]:SetProfileID(__ROTINA + AllTrim(Str(nPos)))
	Next
EndIf

For nPos := 1 To Len(aQuery)
	aQuery[nPos][4]:Activate()
	If aQuery[nPos][4]:cClassName = "FWBROWSE" .And. aQuery[nPos][4]:oPanelBrowse <> Nil
		aQuery[nPos][4]:oPanelBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	If nPos > 1 .And. ! Empty(aQuery[nPos][5])
		oRelation := FWBrwRelation():New()
		oRelation:AddRelation( oBrowse, aQuery[nPos][4], aQuery[nPos][5] )
		oRelation:Activate()
	EndIf
Next

aQuery[1][4]:oBrowse:SetFocus()

Activate MsDialog oDlg

Return

/*/{Protheus.doc} MontaForm
Montagem de menu padrão para manutenção da consulta
@author Wagner Mobile Costa
@since 21/04/2025
@version 1.00

@type function
/*/

Static Function CreateBrowse(oOwner, aSX3, aIndTrb, cAlias, cJoin, cFilter, cFieldMark)

Local oQuery
Local nPos 		:= 1, oBrowse
Local aColsIni 	:= {}
Local aSeek		:= {}
Local aIndex	:= {}
Local aRotina 	:= {}
Local lMark   	:= .F.

oQuery := TCQuery():New("", cAlias + "IMP", aSX3, aIndTrb, "SELECT 1 FROM DUAL")
oCQuery := oQuery
cAlias := oQuery:Alias()
If ! oQuery:Activate()
	Return .F.
EndIf

If ! Empty(cFieldMark)
	oBrowse := FWMarkBrowse():New()
	oBrowse:SetFieldMark( cFieldMark )
	oBrowse:SetAllMark( {|| MarkAll(oBrowse)} )
	cMarca := GetMark()
	lMark  := .T.
Else
	oBrowse := FWMBrowse():New()
EndIf

oBrowse:SetOwner(oOwner)
oBrowse:SetAlias(oQuery:Alias())

If Len(oQuery:aSX3) > 0
	If cAlias == "PX2IMP"
		oBrowse:AddLegend( "PX2IMP->PX2_CORLEG=='0'", "GREEN"  , "Importado Planilha OK" )
		oBrowse:AddLegend( "PX2IMP->PX2_CORLEG=='1'", "RED"    , "Importado Inconsistente" )
		oBrowse:AddLegend( "PX2IMP->PX2_CORLEG=='2'", "WHITE"  , "Contrato Efetivado" )
		oBrowse:AddLegend( "PX2IMP->PX2_CORLEG=='3'", "BLACK"  , "Erro Efetivação Contrato" )
		oBrowse:AddLegend( "PX2IMP->PX2_CORLEG=='4'", "PINK"   , "Contrato já importado" )
	EndIf

	For nPos := 1 To Len(oQuery:aSX3)
		If oQuery:aSX3[nPos][10] == "N"
			Loop
		EndIf
		//Filial do Sistema
		AAdd(aColsIni,FWBrwColumn():New())
		nLinha := Len(aColsIni)
		If ! Empty(oQuery:aSX3[nPos][13])
			aColsIni[nLinha]:SetData(&(	"{|| " + AllTrim(oQuery:aSX3[nPos][13]) + " }"))
		Else
			aColsIni[nLinha]:SetData(&(	"{|| " + oQuery:Alias() + "->" + AllTrim(oQuery:aSX3[nPos][1]) + " }"))
		EndIf
		aColsIni[nLinha]:SetTitle(oQuery:aSX3[nPos][6])
		aColsIni[nLinha]:SetSize(oQuery:aSX3[nPos][3])
		aColsIni[nLinha]:SetDecimal(oQuery:aSX3[nPos][4])
		If ! Empty(oQuery:aSX3[nPos][8])
			aColsIni[nLinha]:SetOptions(Separa(oQuery:aSX3[nPos][8], ";"))
		EndIf
		If oQuery:aSX3[nPos][7] == "@BMP"
			aColsIni[nLinha]:SetImage(.T.)
		Else
			aColsIni[nLinha]:SetPicture(oQuery:aSX3[nPos][7])
		EndIf
	Next
	
	For nPos := 1 To Len(oQuery:aIndTrb)
		Aadd( aSeek, { AllTrim(oQuery:aIndTrb[nPos][3]), RetFldIdx(AllTrim(oQuery:aIndTrb[nPos][2])), 1 } )
		Aadd( aIndex, AllTrim(oQuery:aIndTrb[nPos][2]) )
	Next
	
	oBrowse:SetColumns(aColsIni)
	If ! lMark
		oBrowse:SetQueryIndex(aIndex)
	EndIf
  	oBrowse:SetSeek(,aSeek)
EndIf
oBrowse:SetProfileID(__ROTINA + cAlias)
oBrowse:SetMenuDef(__ROTINA + cAlias)

ADD OPTION aRotina TITLE 'Pesquisa'   	ACTION 'PesqBrw'          		OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.' + __ROTINA 	OPERATION 2 ACCESS 0
If cAlias == "PX2IMP"
	ADD OPTION aRotina TITLE 'Importar' ACTION 'U_TGCFX1LF()'      		OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar' 	ACTION 'VIEWDEF.' + __ROTINA 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Efetivar' ACTION 'U_TGCFX1CF()'      		OPERATION 3 ACCESS 0
EndIf

Aadd(aRotina, { "Atualizar", "aQuery[" + AllTrim(Str(Len(aQuery) + 1)) + "][2]:TelaParms(.T., aQuery, " + AllTrim(Str(Len(aQuery) + 1)) + ")", 0, 3 } )

For nPos := 1 To Len(aRotina)
	oBrowse:AddButton(aRotina[nPos][1],aRotina[nPos][2],, aRotina[nPos][4], aRotina[nPos][3],, aRotina[nPos][4] )
Next

Aadd(aQuery, { "", oQuery, AClone(aRotina), oBrowse, U_RetJoin(cJoin) })

oBrowse:DisableDetails()

Return .T.

/*/{Protheus.doc} setAllMark
  Função para controle de marcação de todos os  registros  
    @type Function
    @author Wagner Mobile Costa
    @since 14/05/2025
    @version 1.0
/*/
Static Function MarkAll(oBrowse)

MsgRun( "Aguarde... Marcando Registros", "Marcar Todos", {|| EMarkAll(oBrowse) } )

Return

Static Function EMarkAll(oBrowse)

Local nCurrRec := oBrowse:At()
Local aArea    := GetArea()
Local cAlias   := oBrowse:Alias()

oBrowse:GoTop(.T.)
DbSelectArea(cAlias)
DbGoTop()

While ! (cAlias)->(Eof())
	oBrowse:MarkRec()

	DbSkip()
EndDo

oBrowse:GoTo( nCurrRec, .T. )
RestArea(aArea)

Return

/*/{Protheus.doc} RetFldIdx
Retorna a lista de campos que compoem um indice
@author Wagner Mobile Costa
@since 21/04/2025
@version 1.00

@type function
/*/

Static Function RetFldIdx(cIndice)

Local aIdx := {}, aArea := SX3->(GetArea())
Local aX3Stru := {}
Local cCpo := ""

cIndice := AllTrim(cIndice)
If Right(cIndice, 1) <> "+"
	cIndice += "+"
EndIf

SX3->(DbSetOrder(2))

While At("+", cIndice) > 0
	SX3->(DbSeek( Left(AllTrim(Left(cIndice, At("+", cIndice) - 1)) + Space(Len(FieldGet(FieldPos("X3_CAMPO")))), Len(FieldGet(FieldPos("X3_CAMPO"))))  ))
	cCpo:= Left(AllTrim(Left(cIndice, At("+", cIndice) - 1)) + Space(Len(    SX3->(FieldGet(FieldPos("X3_CAMPO")))    )), Len(  SX3->(FieldGet(FieldPos("X3_CAMPO")))   ))

	aX3Stru:= FWSX3Util():GetFieldStruct(cCpo)
	If Len(aX3Stru) > 0 
		Aadd(aIdx, {"", aX3Stru[2], aX3Stru[3], aX3Stru[4], FWX3Titulo(aX3Stru[1]),,})
	Endif 
	cIndice := Subs(cIndice, At("+", cIndice) + 1, Len(cIndice))
EndDo

SX3->(RestArea(aArea))

Return aIdx

/*/{Protheus.doc} MenuDef
Definição do modelo de dados  
@type function
@author Mobile
@since 25/04/2025
/*/

Static Function ModelDef()
	Local oModel 	:= Nil
	Local nPos      := 1
	Local nFields   := 1
	Local cMaster   := ""
	Local cInit     := ""

	LoadForm()

	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New("TGCFM001", /* <bPre > */, /* <bPost > */, { |oModel| Commit(oModel) }, /* <bCancel> */)

	For nPos := 1 To Len(aForm)
		If aForm[nPos][4] == Nil
			aForm[nPos][4] := FWFormStruct(1, aForm[nPos][1], /* bSX3 */, /* lViewUsado */,.T.)
			//               TITULO CAMPO, ToolTip ,  ID         , TIPO, TAM                       , DEC                   , validação, When, lista, obrigat, inicialização do campo    , campos chave, altera, virtual		

			If nPos == 1 
				aForm[nPos][4]:AddField("Efetivação Contrato" , "Efetivação Contrato","PX2_XCTR", "M" , 10 , 0, NIL      , NIL , NIL  , .F.    ,  , .T.	      , .F.   , .F.)
				aForm[nPos][4]:AddField("Avisos" , "Avisos","PX2_XNWAR", "N" , 2 , 0, NIL      , NIL , NIL  , .F.    ,  , .T.	      , .F.   , .F.)
				aForm[nPos][4]:AddField("Log de Avisos" , "Log de Avisos","PX2_XWAR", "M" , 10 , 0, NIL      , NIL , NIL  , .F.    ,  , .T.	      , .F.   , .F.)
				aForm[nPos][4]:AddField("Erros" , "Erros","PX2_NLOG", "N" , 2 , 0, NIL      , NIL , NIL  , .F.    ,  , .T.	      , .F.   , .F.)
				aForm[nPos][4]:AddField("Log de Erros" , "Log de Erros","PX2_XLOG", "M" , 10 , 0, NIL      , NIL , NIL  , .F.    ,  , .T.	      , .F.   , .F.)
				aForm[nPos][4]:AddField("Linha Planilha" , "Linha Planilha","PX2_XPLIMP", "M" , 10 , 0, NIL      , NIL , NIL  , .F.    ,  , .T.	      , .F.   , .F.)
			EndIf
			
			For nFields := 1 To Len(aForm[nPos][4]:aFields)
				cInit := RetInit(nPos, aForm[nPos][4]:aFields[nFields][3])
				IF aForm[nPos][4]:aFields[nFields][11] <> Nil .And. cInit <> Nil
					aForm[nPos][4]:aFields[nFields][11] := FWBuildFeature(3, cInit)
				EndIf
			Next
		EndIf
		If nPos == 1 
			cMaster := aForm[nPos][1] + "MASTER"
			oModel:AddFields(cMaster,/*cOwner*/,aForm[nPos][4], /*bPreValidacao*/, /*bPosValidacao*/, {|| LoadReg(1) }/*bCarga*/ )
			oModel:SetDescription("Contrato de Fornecedor")
		Else
			If nPos == 2
				oModel:AddGrid(aForm[nPos][1] + "DETAIL",cMaster,aForm[nPos][4], /* bLinePre*/, /* bLinePost */	, /* bPre*/, /* bLinePost */ ,{|| LoadReg(2) }/*bCarga*/ )
			ElseIf nPos == 3
				oModel:AddGrid(aForm[nPos][1] + "DETAIL",cMaster,aForm[nPos][4], /* bLinePre*/, /* bLinePost */	, /* bPre*/, /* bLinePost */ ,{|| LoadReg(3) }/*bCarga*/ )
			ElseIf nPos == 4
				oModel:AddGrid(aForm[nPos][1] + "DETAIL",cMaster,aForm[nPos][4], /* bLinePre*/, /* bLinePost */	, /* bPre*/, /* bLinePost */ ,{|| LoadReg(4) }/*bCarga*/ )
			ElseIf nPos == 5
				oModel:AddGrid(aForm[nPos][1] + "DETAIL",cMaster,aForm[nPos][4], /* bLinePre*/, /* bLinePost */	, /* bPre*/, /* bLinePost */ ,{|| LoadReg(5) }/*bCarga*/ )
			ElseIf nPos == 6
				oModel:AddGrid(aForm[nPos][1] + "DETAIL",cMaster,aForm[nPos][4], /* bLinePre*/, /* bLinePost */	, /* bPre*/, /* bLinePost */ ,{|| LoadReg(6) }/*bCarga*/ )
			ElseIf nPos == 7
				oModel:AddGrid(aForm[nPos][1] + "DETAIL",cMaster,aForm[nPos][4], /* bLinePre*/, /* bLinePost */	, /* bPre*/, /* bLinePost */ ,{|| LoadReg(7) }/*bCarga*/ )
			EndIF
			
			oModel:SetRelation(aForm[nPos][1] + "DETAIL", U_RetJoin(aJoin[nPos - 1]), (aForm[nPos][1])->(IndexKey(1)))
			oModel:GetModel(aForm[nPos][1] + "DETAIL"):SetDescription(aFolder[nPos - 1])
			oModel:GetModel(aForm[nPos][1] + "DETAIL"):SetOptional(aForm[nPos][P_OPTIONAL])
		EndIf
	Next

	oModel:SetPrimarykey({}) 


Return oModel

/*/{Protheus.doc} MenuDef
Definição do modelo de dados  
@type function
@author Mobile
@since 14/05/2025
/*/

Static Function Commit(oModel)

Local nForm   := 1
Local nRegs   := 1
Local nFields := 1
Local oModTab := Nil
Local cAlias  := ""
Local cCampo  := ""
Local cPX2_FILIAL := ""
Local cPX2_CONTRA := ""

	For nForm := 1 To Len(aForm)
		// Cabeçalho
		cAlias := aQuery[nForm][2]:Alias()
		If nForm == 1
			oModTab	:= oModel:GetModel(aForm[nForm][1] + "MASTER")
			RecLock(cAlias, .F.)
			For nRegs := 1 To Len(aForm[nForm][2])
				// Desconsidera campos virtuais
				If aForm[nForm][2][nRegs][P_X3_CONTEXT] == "V"
					Loop
				EndIf

				cCampo := aForm[nForm][2][nRegs][1]
				If cCampo = "PX2_FILIAL"
					cPX2_FILIAL := oModTab:GetValue(cCampo)
				ElseIf cCampo = "PX2_CONTRA"
					cPX2_CONTRA := oModTab:GetValue(cCampo)
				EndIf

				&(cAlias + "->" + cCampo) := oModTab:GetValue(cCampo)
			Next
			(cAlias)->(MsUnLock())
		Else
			oModTab	:= oModel:GetModel(aForm[nForm][1] + "DETAIL")
			For nRegs := 1 To oModTab:Length()
				oModTab:GoLine(nRegs) 
				If nRegs <= Len(aForm[nForm][P_REG_LOAD])
					(cAlias)->(DbGoto(aForm[nForm][P_REG_LOAD][nRegs][1]))
					RecLock(cAlias, .F.)
				Else
					RecLock(cAlias, .T.)
					&(cAlias + "->" + aForm[nForm][1] + "_FILIAL") := cPX2_FILIAL
					&(cAlias + "->" + aForm[nForm][1] + "_CONTRA") := cPX2_CONTRA
				EndIf
				If oModTab:IsDeleted()
					(cAlias)->(DbDelete())
				Else
					For nFields := 1 To Len(aForm[nForm][2])
						cCampo := aForm[nForm][2][nFields][1]
						// Desconsidera campos virtuais
						If  aForm[nForm][2][nFields][P_X3_CONTEXT] == "V" .Or.;
							cCampo == aForm[nForm][1] + "_FILIAL" .Or. cCampo == aForm[nForm][1] + "_CONTRA"
							Loop
						EndIf


						&(cAlias + "->" + cCampo) := oModTab:GetValue(cCampo)
					Next
				EndIf
				(cAlias)->(MsUnLock())
			Next
		EndIF
	Next

Return .T.

Static Function RetInit(nPos, cField)

Local cInit  := Nil
Local nField := Ascan(aForm[nPos][2], { |x| x[1] == cField })

If nField > 0
	cInit := aForm[nPos][2][nField][14]
EndIF

Return

Static Function LoadReg(nForm)

Local aLoad := {}
Local aReg  := {}
Local nReg  := 1
Local cPX2_CONTRA := ""
Local xValue := Nil

// Cabeçalho
If nForm == 1
	For nReg := 1 To Len(aForm[nForm][4]:aFields)
		If ! Empty(aForm[nForm][2][nReg][13])
			xValue := &(aForm[nForm][2][nReg][13])
		Else
			xValue := &(aQuery[nForm][2]:Alias() + "->" + aForm[nForm][4]:aFields[nReg][3])
		EndIf
		Aadd(aReg, xValue)
	Next
	aLoad := { AClone(aReg), &(aQuery[nForm][2]:Alias() + "->(Recno())") } 
Else
	cPX2_CONTRA := &(aQuery[1][2]:Alias() + "->PX2_CONTRA")
	cDetCONTRA := aQuery[nForm][2]:Alias() + "->" + Left(aQuery[nForm][2]:Alias(), 3) + "_CONTRA"

	&(aQuery[nForm][2]:Alias() + "->(DbSetOrder(1))")
	&(aQuery[nForm][2]:Alias() + "->(DbSeek(xFilial() + '" + cPX2_CONTRA + "'))")

	While &(cDetCONTRA) == cPX2_CONTRA .And. ! &(aQuery[nForm][2]:Alias() + "->(Eof())")
		aReg := {}
		For nReg := 1 To Len(aForm[nForm][4]:aFields)
			If ! Empty(aForm[nForm][2][nReg][13])
				xValue := &(aForm[nForm][2][nReg][13])
			Else
				xValue := &(aQuery[nForm][2]:Alias() + "->" + aForm[nForm][4]:aFields[nReg][3])
			EndIf
			Aadd(aReg, xValue)
		Next
		Aadd(aLoad, { &(aQuery[nForm][2]:Alias() + "->(Recno())"), AClone(aReg) })
		&(aQuery[nForm][2]:Alias() + "->(DbSkip())")
	EndDo
EndIf

aForm[nForm][P_REG_LOAD] := AClone(aLoad)

Return aLoad

/*/{Protheus.doc} MenuDef
Definição da View e persistência  
@type function
@author Mobile
@since 25/04/2025
/*/
Static Function ViewDef()
	Local oView	  := Nil
	Local oModel  := FWLoadModel(__ROTINA)
	Local cMaster := ""
	Local cInit   := ""
	Local nPos    := 1
	Local nFields := 1

	LoadForm()

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho e o grid dos filhos
	For nPos := 1 To Len(aForm)
		If aForm[nPos][5] == Nil
			aForm[nPos][5] := FWFormStruct(2, aForm[nPos][1], /* bSX3 */, /* lViewUsado */,.T.)
			If nPos == 1 
				       //               Nome campo  , ordem, Titulo  , Descricação, Helps , Tipo, Picture, Picture var , F3      , altera, pasta , agru, combo, max combo, IniBrow, virtual , Picture, ???)   

				aForm[nPos][5]:AddField("PX2_XCTR", "ZA" , "Efetivação Contrato" , "Efetivação Contrato", NIL   , "N" , "99"   , NIL         , ""      , .F.   , NIL   , NIL , NIL  , NIL      , NIL    , .F., NIL    , NIL )	
				aForm[nPos][5]:AddField("PX2_XNWAR", "ZB" , "Avisos" , "Avisos", NIL   , "N" , "99"   , NIL         , ""      , .F.   , NIL   , NIL , NIL  , NIL      , NIL    , .F., NIL    , NIL )	
				aForm[nPos][5]:AddField("PX2_XWAR", "ZC" , "Log de Avisos" , "Log de Avisos", NIL   , "M" , "@!"   , NIL         , ""      , .F.   , NIL   , NIL , NIL  , NIL      , NIL    , .F., NIL    , NIL )	
				aForm[nPos][5]:AddField("PX2_NLOG", "ZD" , "Erros" , "Erros", NIL   , "N" , "99"   , NIL         , ""      , .F.   , NIL   , NIL , NIL  , NIL      , NIL    , .F., NIL    , NIL )	
				aForm[nPos][5]:AddField("PX2_XLOG", "ZE" , "Log de Erros" , "Log de Erros", NIL   , "M" , "@!"   , NIL         , ""      , .F.   , NIL   , NIL , NIL  , NIL      , NIL    , .F., NIL    , NIL )	
				aForm[nPos][5]:AddField("PX2_XPLIMP", "ZF" , "Linha Planilha" , "Linha Planilha", NIL   , "M" , "@!"   , NIL         , ""      , .F.   , NIL   , NIL , NIL  , NIL      , NIL    , .F., NIL    , NIL )	
			Else
				aForm[nPos][5]:RemoveField(aForm[nPos][1] + "_CONTRA")
			EndIf
			For nFields := 1 To Len(aForm[nPos][4]:aFields)
				cInit := RetInit(nPos, aForm[nPos][4]:aFields[nFields][3])
				IF aForm[nPos][4]:aFields[nFields][11] <> Nil .And. cInit <> Nil
					aForm[nPos][4]:aFields[nFields][11] := FWBuildFeature(3, cInit)
				EndIf
			Next
		EndIf
		If nPos == 1
			cMaster := aForm[nPos][1]
			oView:AddField('VIEW_' + aForm[nPos][1], aForm[nPos][5], aForm[nPos][1] + 'MASTER')
		Else
			oView:AddGrid('VIEW_' + aForm[nPos][1], aForm[nPos][5], aForm[nPos][1] + 'DETAIL')
		EndIf
		If aForm[nPos][1] == "PX3"
	    	oView:AddIncrementField("PX3DETAIL", "PX3_ITEM")
		EndIf
	Next

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('SUPERIOR', 50)
	oView:SetOwnerView('VIEW_' + cMaster, 'SUPERIOR')
	oView:CreateHorizontalBox('INFERIOR', 50)

	oView:CreateFolder('PASTA_FILHOS', 'INFERIOR')
	For nPos := 1 To Len(aFolder)
		oView:AddSheet('PASTA_FILHOS', 'ABA_FILHO' + StrZero(nPos, 2), aFolder[nPos])
		oView:CreateHorizontalBox('ITENS_FILHO' + StrZero(nPos, 2), 100,,, 'PASTA_FILHOS', 'ABA_FILHO' + StrZero(nPos, 2) )
		oView:SetOwnerView('VIEW_' + aForm[nPos + 1][1], 'ITENS_FILHO' + StrZero(nPos, 2))
		oView:EnableTitleView('VIEW_' + aForm[nPos + 1][1], aFolder[nPos])
	Next

Return oView

/*/{Protheus.doc} TGCFX1LF
Rotina para importação de contratos a partir de um XLSx
@author Wagner Mobile Costa
@since 21/04/2025
@vesion 1.09

@type function
/*/

User Function TGCFX1LF

Local aSay    := {}
Local aButton := {}
Local nOpc    := 0
Local cTitulo := ""
Local cDesc1  := "Esta rotina permite a importação dos contratos de fornecedores a partir do arquivo XLSX"
Local cDesc2  := "É obrigatório escolher a pasta para leitura no botão [Parametros]."
Local cArqDes := CriaTrab(nil, .f.) + ".txt"
Local aArea	  := GetArea()

Private _cArquivo := ""

aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )

aAdd( aButton, { 5, .T., {|| _cArquivo := SelArq()    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )

FormBatch( cTitulo, aSay, aButton )

If nOpc <> 1
	Return
Endif

If Empty(_cArquivo)
	Aviso("Atenção", "O arquivo a ser importado não foi escolhido !", {"Fechar"}, 3)
	Return
EndIf

IF !":\" $ _cArquivo
	Aviso("Atenção", "O arquivo selecionado deve estar em um drive existente na máquina local." + CRLF + CRLF + ;
		"Não será possível a importação de arquivos a partir do servidor!", {"Fechar"}, 3)
ELSEIF !File(_cArquivo)
	Aviso("Atenção", "O arquivo selecionado não pôde ser localizado!", {"Fechar"})
ELSEIF !__CopyFile(Alltrim(_cArquivo), cArqDes)
	Aviso("Atenção", "Falha ao copiar o arquivo para o servidor!", {"Fechar"})
ELSE

    FwMsgRun(,{|oSay| LoadFile(oSay,_cArquivo) }, "Carregando [" + _cArquivo + "]","Aguarde"	)
	FErase(cArqDes)
ENDIF

RestArea(aArea)

Return

Static Function SelArq()

Private _cExtens := "Arquivo XLSX (*.XLSX) |*.XLSX|"

Return AllTrim(cGetFile(_cExtens,"Selecione o Arquivo",,,.F.,GETF_NETWORKDRIVE+GETF_LOCALFLOPPY+GETF_LOCALHARD))

Static Function LoadFile(oSay,cArquivo)

Local cTime 	:= Time()
Local oExcel   	:= YExcel():new(,cArquivo)	
Local nHandle  	:= 0

oExcel:SetPlanAt(1)	//Informa qual a planilha atual
oSay:SetText("Planilha " + oExcel:GetPlanAt("2"))
ProcessMessage()

GCFX01_I(oExcel, oSay)

oExcel:Close()
fClose(nHandle)
MsgInfo("Importação realizada com sucesso: Inicio: " + cTime + " - Fim: " + Time())

Return

/*/{Protheus.doc} CFGX01_S
Função para armazenamento de variaveis static
@author Wagner Mobile Costa
@since 10/05/2025
@version 1.00

@type function
/*/

User Function CFGX01_S(cStatic, uValue)

Local nPos := Ascan(aStatic, {|x| x[1] == cStatic })

If nPos == 0
	Aadd(aStatic, { cStatic, uValue })
	nPos := Len(aStatic)
EndIf
aStatic[nPos][2] := uValue

Return

/*/{Protheus.doc} CFGX01_S
Função para recuperação de variaveis static
@author Wagner Mobile Costa
@since 10/05/2025
@version 1.00

@type function
/*/

User Function CFGX01_G(cStatic)

Local nPos   := Ascan(aStatic, {|x| x[1] == cStatic })
Local uValue := Nil

If nPos > 0
	uValue := aStatic[nPos][2]
EndIf
 
Return uValue

/*/{Protheus.doc} TGCFX1CF
Rotina para confirmação dos contratos importados no temporário
@author Wagner Mobile Costa
@since 14/05/2025
@vesion 1.00

@type function
/*/

User Function TGCFX1CF

    FwMsgRun(,{|oSay| TGCFX1CF(oSay) }, "Efetivando contratos","Aguarde"	)

Return

Static Function TGCFX1CF(oSay)

	Local aArea   	:= GetArea()
	Local cAliasPX2 := aQuery[1][2]:Alias()
	Local aAreaPX2 	:= (cAliasPX2)->(GetArea())
	Local aRotAuto  := {}
	Local aData     := {}
	Local cCampo	:= ""
	Local xValue 	:= Nil
	Local nReg		:= 1
	Local nForm		:= 1
	Local cError	:= ""
	Local oError	:= Nil
	Local cTime 	:= Time()

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	(cAliasPX2)->(DbGoTop())
	While (cAliasPX2)->(!Eof())
		If oBrowse:IsMark() .And. (cAliasPX2)->PX2_CORLEG $ "0,1"
			oSay:SetText("Efetivando contrato " + AllTrim((cAliasPX2)->PX2_CTRFOR) + "...")
			ProcessMessage()

			aRotAuto := {}
			aData    := {}
			
			// PX2
			nForm := 1
			For nReg := 1 To Len(aForm[nForm][2])
				cCampo := aForm[nForm][2][nReg][1]
				If 	aForm[nForm][2][nReg][P_X3_CONTEXT] <> "V" .And.;
					! (cCampo == aForm[nForm][1] + "_FILIAL" .Or. cCampo == aForm[nForm][1] + "_CONTRA")
					xValue := &(aQuery[nForm][2]:Alias() + "->" + aForm[nForm][2][nReg][1])
					If ! Empty(xValue)
						Aadd(aData, { cCampo, xValue, Nil })
					EndIf
				EndIf
			Next
			Aadd(aRotAuto, AClone(aData))

			// 2. PB9
			Aadd(aRotAuto, AClone(LoadDet(2)))

			// 3. PX7
			Aadd(aRotAuto, AClone(LoadDet(3)))

			// 4. PX3
			Aadd(aRotAuto, AClone(LoadDet(4)))

			// 5. PX4
			Aadd(aRotAuto, AClone(LoadDet(5)))

			// 6. PX6
			Aadd(aRotAuto, AClone(LoadDet(6)))

			cError := ""
			lMsErroAuto := .F.
			TRYEXCEPTION
				contrato.fornecedores.U_TGCFA001(aRotAuto,3)
				EndTran()
				ConfirmSX8()
			CATCHEXCEPTION USING oError
				lMsErroAuto := .T.
				cError := "Erro ExecAuto"
				If ValType("oError:Description") == "C"
					cError += ": " + oError:Description
				EndIf
			ENDEXCEPTION
			If lMsErroAuto
				RollBackSX8()
			EndIf

			RecLock(cAliasPX2, .F.)
			If !lMsErroAuto
				(cAliasPX2)->PX2_CORLEG := "2"	// Contrato Efetivado
			Else
				(cAliasPX2)->PX2_CORLEG := "3"	// Erro Efetivacao
				IF Empty(cError)
					cError := MostraErro("/system/ctrfor/", "CTRFOR_"+dTos(Date()) + strtran(IncTime(time() ,3,0,0 ),":")+".log")
				EndIf
				(cAliasPX2)->PX2_XCTR := cError
			EndIf
			(cAliasPX2)->(MsUnLock())
		EndIf
		(cAliasPX2)->(DbSkip())
	EndDo

	(cAliasPX2)->(RestArea(aAreaPX2))
	RestArea(aArea)

	// Faz refresh da tela
	// aQuery[1][2]:TelaParms(.T., aQuery, 1)

	MsgInfo("Efetivação dos contratos executada. Inicio: " + cTime + " - Fim: " + Time())

Return

Static Function LoadDet(nForm)

Local cPX2_CONTRA := &(aQuery[1][2]:Alias() + "->PX2_CONTRA")
Local cDetCONTRA  := aQuery[nForm][2]:Alias() + "->" + Left(aQuery[nForm][2]:Alias(), 3) + "_CONTRA"
Local aData 	:= {}
Local nReg  	:= 1
Local cCampo	:= ""
Local xValue 	:= Nil

	&(aQuery[nForm][2]:Alias() + "->(DbSetOrder(1))")
	&(aQuery[nForm][2]:Alias() + "->(DbSeek(xFilial() + '" + cPX2_CONTRA + "'))")

	While &(cDetCONTRA) == cPX2_CONTRA .And. ! &(aQuery[nForm][2]:Alias() + "->(Eof())")
		aReg := {}

		For nReg := 1 To Len(aForm[nForm][2])
			cCampo := aForm[nForm][2][nReg][1]
			If 	aForm[nForm][2][nReg][P_X3_CONTEXT] <> "V" .And.;
				! (cCampo == aForm[nForm][1] + "_FILIAL" .Or. cCampo == aForm[nForm][1] + "_CONTRA")
				xValue := &(aQuery[nForm][2]:Alias() + "->" + aForm[nForm][2][nReg][1])
				IF ! Empty(xValue)
					Aadd(aReg, { cCampo, xValue, Nil })
				EndIf
			EndIf
		Next
		Aadd(aData, AClone(aReg))
		&(aQuery[nForm][2]:Alias() + "->(DbSkip())")
	EndDo

Return aData

/*/{Protheus.doc} GCFX01_I
Função para tratamento da linha da planilha
@author Wagner Mobile Costa
@since 22/05/2025
@version 1.00

@type function
/*/

Static Function GCFX01_I(oExcel, oSay)

Local aColunas    := {}
Local aData       := {}
Local cLinha      := ""
Local cAliasPX2   := aQuery[1][2]:cAlias
Local cPX2_CONTRA := ""
Local cPX2_CORLEG := ""
Local cPX2_CTRFOR := ""
Local dPX2_DATAIN := Ctod("")
Local dPX2_DATAFI := Ctod("")
Local cPX2_COND   := ""
Local lNew        := .F.
Local xValor	  := Nil
Local nColMax  	  := 0
Local nContC	  := 0	 
Local nContL	  := 0	
Local aTamLin	  := oExcel:LinTam()	
Local aTamCol	  := oExcel:ColTam(nContL)
Local lDimensa    := cEmpAnt == "60"
Local aPX4        := {}
Local lInsere     := .T.
lOCAL nAux        := 0

	For nContL:=aTamLin[1] to aTamLin[2]
		oSay:SetText("Analisando Linha " + cValToChar(nContL) + " de " + cValToChar(aTamLin[2]) + "...")
		ProcessMessage()
		aTamCol	:= oExcel:ColTam(nContL)
		If aTamCol[1]>0
			aData       := {}
			lDimensa    := .F.
			lInsere     := .T.
			cPX2_CONTRA := "L" + StrZero(nContL, LEN(PX2->PX2_CONTRA) - 1)
			cPX2_CORLEG := "0"
			cLinha := "Linha-" + AllTrim(Str(nContL))
			For nContC:=aTamCol[1] to aTamCol[2]
				xValor:= oExcel:GetValue(nContL,nContC)
				If nContL == 1 
					If ! Empty(xValor) .And. nColMAX < nContC
						nColMAX := nContC
					Else
						Loop
					EndIf
				ElseIf nContC > nColMAX
					Loop
				EndIf

				If xValor == Nil
					xValor := ""
				ElseIf nContL == 1 
				ElseIf Left(oExcel:Ref(nContL,nContC), 2) $ "AF,AG,AH,AI"
					xValor := oExcel:GetDate(nContL,nContC)

					IF aColunas[nContC] == "AF1"
						dPX2_DATAIN := xValor
					ElseIF aColunas[nContC] == "AG1"
						dPX2_DATAFI := xValor
					EndIf
				ElseIf ValType(xValor) = "C" .Or. ValType(xValor) = "M"
					xValor := StrTran(xValor, ";", "##")
					xValor := StrTran(xValor, Chr(10), "##")

					IF aColunas[nContC] == "O1"
						cPX2_CTRFOR := xValor
					ELSEIF aColunas[nContC] == "D1"
						lDimensa := "DIMENSA" $ xValor
					EndIf
				EndIf

				If nContL == 1 
					Aadd(aColunas, oExcel:Ref(nContL,nContC))
				Else
					IF aColunas[nContC] == "AP1"
						cPX2_COND := Left(xValor + Space(Len(ZX5->ZX5_DESCRI)), Len(ZX5->ZX5_DESCRI))
						ZX5->(DbSetOrder(3))
						
						If ZX5->(DbSeek(xFilial() + "CTFOR5" + cPX2_COND))
							cPX2_COND := ZX5->ZX5_CHAVE
						Else
							cPX2_COND := "8"
						EndIf
						ZX5->(DbSetOrder(1))
					EndIf

					If ! Empty(cLinha)
						cLinha += ";"
					EndIf
					cLinha += aColunas[nContC] + "-" + cValToChar(xValor)
					Aadd(aData, xValor)
				EndIf			
			Next
			
			If ! lDimensa
				aPX4 := TrataPX4(aColunas, aData, lNew, .F.)
				For nAux := 1 To Len(aPX4)
					If aPX4[nAux][1] == "60"
						lDimensa := .T.
					Else
						lDimensa := .F.
						Exit
					EndIf
				Next
			EndIf
			
			If lDimensa .And. cEmpAnt <> "60"
				lInsere := .F.
			ElseIf ! lDimensa .And. cEmpAnt = "60"
				lInsere := .F.
			EndIf
			
			If Len(aData) > 0 .And. lInsere
				oSay:SetText("Gravando contrato " + cPX2_CONTRA + "...")
				ProcessMessage()

				// Verifica existencia do contrato na base e depois no temporário
				If ! CheckCtr(.F., cPX2_CTRFOR, Dtos(dPX2_DATAIN), Dtos(dPX2_DATAFI), cPX2_COND, @cPX2_CONTRA, cPX2_CORLEG, @cLinha)
					CheckCtr(.T., cPX2_CTRFOR, Dtos(dPX2_DATAIN), Dtos(dPX2_DATAFI), cPX2_COND, @cPX2_CONTRA, cPX2_CORLEG, @cLinha)
				EndIf

				TrataPX2(aColunas, aData, lNew)

				oSay:SetText("Gravando combinações - contrato " + cPX2_CONTRA + "...")
				ProcessMessage()
				TrataPB9(aColunas, aData, lNew)

				oSay:SetText("Gravando fornecedores - contrato " + cPX2_CONTRA + "...")
				ProcessMessage()
				TrataPX7(aColunas, aData, lNew)

				oSay:SetText("Gravando usuários - contrato " + cPX2_CONTRA + "...")
				ProcessMessage()
				TrataPX6(aColunas, aData, lNew)

				oSay:SetText("Gravando itens - contrato " + cPX2_CONTRA + "...")
				ProcessMessage()
				TrataPX3(aColunas, aData, lNew)

				oSay:SetText("Gravando empresas - contrato " + cPX2_CONTRA + "...")
				ProcessMessage()
				TrataPX4(aColunas, aData, lNew, .T.)

				If ! Empty(&(cAliasPX2 + "->PX2_XLOG"))
					&(cAliasPX2 + "->PX2_CORLEG") := "1"
				EndIf

				(cAliasPX2)->(MsUnLock())
			EndIf
		EndIf
	Next

Return

/*/{Protheus.doc} CheckCtr
Função para verificação do contrato no temporário / PX2
@author Wagner Mobile Costa
@since 05/06/2025
@version 1.00

@type function
/*/

Static Function CheckCtr(lTemp, cPX2_CTRFOR, cPX2_DATAIN, cPX2_DATAFI, cPX2_COND, cPX2_CONTRA, cPX2_CORLEG, cLinha)

Local cQuery := "SELECT PX2_CONTRA, PX2_REVISA, R_E_C_N_O_ AS RECNO FROM ? WHERE PX2_FILIAL = ? AND PX2_CTRFOR = ? AND PX2_DATAIN = ? AND PX2_DATAFI = ? AND PX2_COND = ? AND D_E_L_E_T_ = ?""
Local oExec  := Nil
Local cAlias := ""
Local lUpd   := .F.
Local cAliasPX2 := aQuery[1][2]:cAlias

	oExec := FwExecStatement():New(cQuery)
	If ! lTemp
		oExec:SetUnsafe(1,RetSqlName("PX2"))
	Else
		oExec:SetUnsafe(1,aQuery[1][2]:cArqTrb)
	EndIF
	oExec:SetString(2,xFilial("PX2"))
	oExec:SetString(3,cPX2_CTRFOR)
	oExec:SetString(4,cPX2_DATAIN)
	oExec:SetString(5,cPX2_DATAFI)
	oExec:SetString(6,cPX2_COND)
	oExec:SetString(7," ")
	
	cAlias := oExec:OpenAlias()

	lNew := (cAlias)->RECNO == 0
	// Verificação da gravação na PX2
	If ! lTemp
		IF ! lNew
			cPX2_CONTRA := (cAlias)->PX2_CONTRA
			RecLock(cAliasPX2, .T.)

			&(cAliasPX2 + "->PX2_XPLIMP") := cLinha
			&(cAliasPX2 + "->PX2_CONTRA") := cPX2_CONTRA
			&(cAliasPX2 + "->PX2_REVISA") := (cAlias)->PX2_REVISA
			&(cAliasPX2 + "->PX2_CORLEG") := "4"	// Contrato já importado
			lUpd := .T.
		EndIf

	// Entra somente na verificação do temporário
	ElseIf (cAlias)->RECNO > 0
		(cAliasPX2)->(DbGoto((cAlias)->RECNO))
		RecLock(cAliasPX2, .F.)

		&(cAliasPX2 + "->PX2_XPLIMP") := &(cAliasPX2 + "->PX2_XPLIMP") + Chr(13) + Chr(10) + cLinha
		lUpd := .T.
	Else	
		RecLock(cAliasPX2, .T.)

		&(cAliasPX2 + "->PX2_XPLIMP") := cLinha
		&(cAliasPX2 + "->PX2_CONTRA") := cPX2_CONTRA
		&(cAliasPX2 + "->PX2_REVISA") := "001"
		&(cAliasPX2 + "->PX2_CORLEG") := cPX2_CORLEG
		lUpd := .T.
	EndIf
	// Nem precisa verificar no temporário
	(cAlias)->(DbCloseArea())
	FreeObj(oExec)

Return lUpd

/*/{Protheus.doc} TrataPX2
Função para tratamento da gravação da tabela PX2
@author Wagner Mobile Costa
@since 22/05/2025
@version 1.00

@type function
/*/

Static Function TrataPX2(aColunas, aData, lNew)

Local cTabZX5     := ""
Local cLabel      := ""
Local cAliasPX2   := aQuery[1][2]:Alias()
Local cPX2_XLOG   := AllTrim(&(cAliasPX2 + "->PX2_XLOG"))
Local cColuna     := ""
Local cField      := ""
Local nCol        := 1
Local nPX2_VENNEG := 0

For nCol := 1 To Len(aColunas)
	cField  := ""
	IF nCol > Len(aData)
		Loop
	EndIf
	xValor  := aData[nCol]
	cColuna := aColunas[nCol]
	cColuna := Left(cColuna, Len(cColuna) - 1)

	If cColuna == "A"
		cField := "PX2_RENSUP"
		If UPPER(xValor) == "SUPRIMENTOS"
			xValor := "1"
		Else
			xValor := "0"
		EndIf
	ElseIf cColuna == "J"
		cField := "PX2_OBJETO"
		xValor := StrTran(xValor, "##", " ")
	ElseIf cColuna == "K"
		cField := "PX2_OBS"
		xValor := StrTran(xValor, "##", " ")
	ElseIf cColuna == "L"
		cField := "PX2_COMPAR"
		If xValor == UPPER('NÃO APLICÁVEL')
			xValor := "2"
		ElseIf xValor == UPPER('SIM')
			xValor := "1"
		Else
			xValor := "0"
		EndIf
	ElseIf cColuna == "M"
		cField := "PX2_NIVRIS"
		If xValor == UPPER('ALTO')
			xValor := "1"
		ElseIf xValor == UPPER('BAIXO')
			xValor := "3"
		ElseIf xValor == UPPER('MODERADO')
			xValor := "2"
		ElseIf xValor == UPPER('PENDENTE DE RETORNO')
			xValor := "5"
		ElseIf xValor == UPPER('RECUSOU A RESPONDER')
			xValor := "4"
		Else
			xValor := "0"
		EndIF
	ElseIf cColuna == "N"
		cField := "PX2_LGPD"
		If xValor == UPPER('NÃO APLICÁVEL')
			xValor := "2"
		ElseIf xValor == UPPER('SIM')
			xValor := "1"
		Else
			xValor := "0"
		EndIf
	ElseIf cColuna == "O"
		cField := "PX2_CTRFOR"
	ElseIf cColuna == "P"
		cField := "PX2_SUBLOC"
		xValor := If(! Empty(xValor), "1", "0" )
	ElseIf cColuna == "Q"
		cField := "PX2_IFRS16"
		If xValor == UPPER('SIM')
			xValor := "1"
		Else
			xValor := "0"
		EndIf
	ElseIf cColuna == "R"
		cField := "PX2_ADINEG"
	ElseIf cColuna == "U"
		cField := "PX2_DOCTRB"
		If xValor == UPPER('SIM - NÃO CORE')
			xValor := "4"
		ElseIf xValor == UPPER('SIM - CORE')
			xValor := "3"
		ElseIf xValor == UPPER('NÃO - < 22 H/MÊS')
			xValor := "2"
		ElseIf xValor == UPPER('NÃO')
			xValor := "1"
		Else
			xValor := "0"
		EndIf
	ElseIf 	cColuna == "V" .Or. cColuna == "AA" .Or. cColuna == "AJ" .Or. cColuna == "AN" .Or. cColuna == "AO" .Or. cColuna == "AP"
		If cColuna == "V"
			cField := "PX2_SEGMEN"
			cTabZX5 := "CTFOR1"
			cLabel := "Segmento"
			
			If xValor == "RECEPÇÃO E CONTROLE DE ACESSO"
				xValor := "RECEPCAO E CONTROLE DE ACESSO"
			ElseIf xValor == "ASSISTÊNCIA ODONTOLÓGICA"
				xValor := "ASSISTENCIA ODONTOLOGICA"
			ElseIf xValor == "MANUTENÇÃO DE MOVEIS"
				xValor := "MANUTENCAO DE MOVEIS"
			ElseIf xValor == "TELEFONIA MÓVEL"
				xValor := "TELEFONIA MOVEL"
			EndIf
		ElseIf cColuna == "AA"
			cField := "PX2_AREGES"
			cTabZX5 := "CTFOR4"
			cLabel := "Area Responsável"
		ElseIf cColuna == "AJ"
			cField := "PX2_STAREN"
			cTabZX5 := "CTFOR6"
			cLabel := "Status Renovação"

			If xValor == "RENOVAR" .Or. xValor == "NEGOCIAÇÃO PENDENTES POR COMPRAS"
				xValor := "RENOVAR - PENDENTE NEGOC. COMPRAS"
			ElseIf xValor == "ELABORAÇÃO POR CONTRATOS"
				xValor := "RENOVAR - ELABORAÇÃO ACF"
			ElseIf xValor == "PENDENTE LGPD - NÃO RENOVAR"
				xValor := "PENDÊNCIA LGPD - IMPED. RENOV."
			ElseIf xValor == "N/A - POLÍTICA SUBCONTRATAÇÃO"
				xValor := "N/A - SUBCONTRATAÇÃO"
			ElseIf xValor == "NEGOCIAÇÃO PELA ÁREA"
				xValor := "RENOVAR - NEGOC. ÁREA SOLIC."
			EndIf
		ElseIf cColuna == "AN"
			cField := "PX2_INDREJ"
			cTabZX5 := "CTFOR2"
			cLabel := "Indice Reajuste"

			If xValor == "NEGOCIAÇÃO ENTRE ÀS PARTES"
				xValor := "NEGOCIAÇÃO ENTRE AS PARTES"
			EndIf
		ElseIf cColuna == "AO"
			cField := "PX2_MESREJ"
			cTabZX5 := "CTFOR3"
			cLabel := "Mes Reajuste"
		ElseIf cColuna == "AP"
			cField := "PX2_COND"
			cTabZX5 := "CTFOR5"
			cLabel := "Condição Pagto"

			If xValor == "COND.NEGOCIADA"
				xValor := "COND. NEGOCIADA"
			ElseIf xValor == "VCTO P/ 06, 15 E 25 DO MÊS"
				xValor := "VCTO P/ 06 OU 15 OU 25 DO MÊS"
			ElseIf xValor == "VCTO P/ 06, 15 E 25 MÊS SUBSEQUENTE" .Or. xValor == "VCTO P/ 06, 15 OU 25 MÊS SUBSEQUENTE"
				xValor := "VCTO P/ 06 OU 15 OU 25 MÊS SUBSEQUENTE"
			EndIf
			
		EndIF
		If xValor == "-"
			xValor := ""
		EndIf

		If ! Empty(xValor)
			xValor := Left(xValor + Space(Len(ZX5->ZX5_DESCRI)), Len(ZX5->ZX5_DESCRI))
			ZX5->(DbSetOrder(3))
			If ZX5->(DbSeek(xFilial() + cTabZX5 + xValor))
				xValor := ZX5->ZX5_CHAVE
			ElseIf cColuna == "AP"
				nPX2_VENNEG := AllTrim(StrTran(xValor, "DIA", ""))
				nPX2_VENNEG := Val(Subs(nPX2_VENNEG, 1, At(" ", nPX2_VENNEG) - 1))

				If nPX2_VENNEG > 0
					&(cAliasPX2 + "->PX2_VENNEG") := nPX2_VENNEG
				EndIf

				xValor := "8"
			Else
				If ! Empty(cPX2_XLOG)
					cPX2_XLOG += Chr(13) + Chr(10)
				EndIf
				cPX2_XLOG += cLabel + " [" + AllTrim(xValor) + "] não localizado "

				IF cColuna == "V"
					xValor := "00"
				ElseIF cColuna == "AA"
					xValor := "001"
				ElseIF cColuna == "AJ"
					xValor := "0"
				ElseIF cColuna == "AN"
					xValor := "00"
				ElseIF cColuna == "AO"
					xValor := "01"
				EndIf
				cPX2_XLOG += " assumindo default [" + xValor + "]"
				&(cAliasPX2 + "->PX2_NLOG") := &(cAliasPX2 + "->PX2_NLOG") + 1
			EndIf
		EndIf
	ElseIf cColuna == "AE"
		cField := "PX2_LNKCFG"
	ElseIf cColuna == "AF"
		cField := "PX2_DATAIN"
		If ValType(xValor) <> "D"
			xValor := Ctod("")
		EndIf
	ElseIf cColuna == "AG"
		cField := "PX2_DATAFI"
		If ValType(xValor) <> "D"
			xValor := Ctod("")
		EndIf
	ElseIf cColuna == "AH"
		cField := "PX2_DATASS"
		If ValType(xValor) <> "D"
			xValor := Ctod("")
		EndIf
	ElseIf cColuna == "AI"
		cField := "PX2_AVIREN"
		If ValType(xValor) <> "D"
			xValor := Ctod("")
		EndIf
	ElseIf cColuna == "AK"
		cField := "PX2_STATUS"
		If xValor == UPPER('VENCIDO - PROCESSO EM ANDAMENTO')
			xValor := "4"
		ElseIf xValor == UPPER('EM ENCERRAMENTO')
			xValor := "1"
		Else
			xValor := "0"
		EndIf
	ElseIf cColuna == "AL"
		cField := "PX2_PRZRES"
		If ValType(xValor) <> "N"
			xValor := Val(xValor)
		EndIf
	ElseIf cColuna == "AM"
		cField := "PX2_TIPREN"
		If xValor == UPPER('AUTOMÁTICA') .Or. xValor == UPPER('AUTOMÁTICA A CADA 1 MÊS')
			xValor := "2"
		ElseIf xValor == UPPER('EM INDETERMINADO')
			xValor := "1"
		ElseIf xValor == UPPER('DETERMINADO') .Or. xValor == UPPER('DETERMINADO COM ADITIVO')
			xValor := "0"
		Else
			xValor := "2"
		EndIf
	ElseIf cColuna == "AR"
		cField := "PX2_PRVENC"
		If ValType(xValor) <> "D"
			xValor := CTOD("")
		EndIf
	EndIf
		
	If ! Empty(cField)
		&(cAliasPX2 + "->" + cField) := xValor
	EndIf
Next

&(cAliasPX2 + "->PX2_XLOG") := cPX2_XLOG

Return

/*/{Protheus.doc} TrataPX3
Função para tratamento da gravação da tabela PB9
@author Wagner Mobile Costa
@since 22/05/2025
@version 1.00

@type function
/*/

Static Function TrataPX3(aColunas, aData, lNew)

Local cAliasPX3   := aQuery[4][2]:Alias()
Local cPX3_ITEM   := "0001"
Local cPX3_CODPRD := ""
Local cPX3_PROVI  := ""
Local aPX3        := {}
Local aLin        := {}
Local cAliasPX2   := aQuery[1][2]:Alias()
Local cPX2_CONTRA := &(cAliasPX2 + "->PX2_CONTRA")
Local cPX2_XLOG   := AllTrim(&(cAliasPX2 + "->PX2_XLOG"))
Local cPX2_XWAR   := AllTrim(&(cAliasPX2 + "->PX2_XWAR"))
Local cColuna     := ""
Local cField      := ""
Local nCol        := 1
Local nLin        := 1
Local nPos        := 1
Local cAlias      := ""
Local lGratuito   := .F.
Local lErro       := .F.

If ! lNew
	oExec := FwExecStatement():New("SELECT MAX(PX3_ITEM) AS PX3_ITEM FROM ? WHERE PX3_FILIAL = ? AND PX3_CONTRA = ? AND D_E_L_E_T_ = ?")
	oExec:SetUnsafe(1,aQuery[4][2]:cArqTrb)
	oExec:SetString(2,xFilial("PX3"))
	oExec:SetString(3,cPX2_CONTRA)
	oExec:SetString(4," ")
	cAlias := oExec:OpenAlias()
	cPX3_ITEM := Soma1((cAlias)->PX3_ITEM)
	(cAlias)->(DbCloseArea())
EndIf

For nCol := 1 To Len(aColunas)
	cField  := ""
	IF nCol > Len(aData)
		Loop
	EndIf
	xValor  := aData[nCol]
	cColuna := aColunas[nCol]
	cColuna := Left(cColuna, Len(cColuna) - 1)

	If cColuna == "AS"
		If ValType(xValor) == "N"
			aLin := { xValor }
		Else
			aLin := StrToArray(xValor,"##")
		EndIF
		lGratuito := aData[nCol + 1] == "GRATUITO"
		
		For nLin := 1 To Len(aLin)
			IF ValType(aLin[nLin]) == "C"
				aLin[nLin] := AllTrim(aLin[nLin])
				If Empty(aLin[nLin])
					Loop
				EndIf
				If aLin[nLin] == "-"
					aLin[nLin] := 0
				Else
					aLin[nLin] := StrTran(aLin[nLin], "R$ ", "")
					aLin[nLin] := StrTran(aLin[nLin], ".", "")
					aLin[nLin] := StrTran(aLin[nLin], ",", ".")
					aLin[nLin] := Val(aLin[nLin])
				EndIf
			EndIf
			
			If aLin[nLin] > 0 .Or. lGratuito
				Aadd(aPX3, { aLin[nLin], "", cPX3_PROVI, If(lGratuito, "5", "0") })
			EndIf
		Next

		If Len(aPX3) == 0
			If ! Empty(cPX2_XLOG)
				cPX2_XLOG += Chr(13) + Chr(10)
			EndIf
			cPX2_XLOG += "contrato sem valor definido"
			&(cAliasPX2 + "->PX2_NLOG") := &(cAliasPX2 + "->PX2_NLOG") + 1
		EndIF
	ElseIf cColuna == "AU"
		If ValType(xValor) == "N"
			aLin := { AllTrim(Str(xValor)) }
		Else
			xValor := StrTran(xValor," / ","##")
			aLin := StrToArray(xValor,"##")
		EndIF
		For nLin := 1 To Len(aLin)
			aLin[nLin] := AllTrim(aLin[nLin])
			lErro := .F.
			If aLin[nLin] == "-" .Or. Empty(aLin[nLin])
				aLin[nLin] := ""
			Else
				If (nPos := At("-", aLin[nLin])) > 0
					aLin[nLin] := Left(aLin[nLin], nPos - 1)
				ElseIf (nPos := At(" ", aLin[nLin])) > 0
					aLin[nLin] := Left(aLin[nLin], nPos - 1)
				EndIf
				aLin[nLin] := AllTrim(aLin[nLin])
				aLin[nLin] := Left(aLin[nLin] + Space(Len(PX3->PX3_CODPRD)), Len(PX3->PX3_CODPRD))

				If ! SB1->(DbSeek(xFilial() + aLin[nLin]))
					If ! Empty(cPX2_XLOG)
						cPX2_XLOG += Chr(13) + Chr(10)
					EndIf
					cPX2_XLOG += "Produto [" + aLin[nLin] + "] não existe"
					lErro := .T.
					&(cAliasPX2 + "->PX2_NLOG") := &(cAliasPX2 + "->PX2_NLOG") + 1
					aLin[nLin] := ""
				EndIf
			EndIf

			If nLin <= Len(aPX3)
				aPX3[nLin][2] := aLin[nLin]
			ElseIf ! Empty(aLin[nLin])
				If ! Empty(cPX2_XWAR)
					cPX2_XWAR += Chr(13) + Chr(10)
				EndIf
				cPX2_XWAR += "Produto [" + aLin[nLin] + "] superior a coluna [AS]"
				&(cAliasPX2 + "->PX2_XNWAR") := &(cAliasPX2 + "->PX2_XNWAR") + 1
				lErro := .T.
			EndIf

			If ! lErro .And. Empty(cPX3_CODPRD) .And. ! Empty(aLin[nLin])
				cPX3_CODPRD := aLin[nLin]
			EndIf
		Next

		If ! Empty(cPX3_CODPRD)
			For nLin := 1 To Len(aPX3)
				If Empty(aPX3[nLin][2])
					aPX3[nLin][2] := cPX3_CODPRD
				EndIf
			Next
		EndIf

	ElseIf cColuna == "AQ"
		cPX3_PROVI := If(xValor == "SIM", "1", "0")
	EndIF
Next

For nLin  := 1 To Len(aPX3)
	RecLock(cAliasPX3, .T.)
	&(cAliasPX3 + "->PX3_CONTRA") := cPX2_CONTRA
	&(cAliasPX3 + "->PX3_ITEM") := cPX3_ITEM
	&(cAliasPX3 + "->PX3_CODPRD") := aPX3[nLin][2]
	If aPX3[nLin][4] == "1"
		&(cAliasPX3 + "->PX3_QUANT") := 1
	EndIF
	&(cAliasPX3 + "->PX3_VALOR") := aPX3[nLin][1]
	&(cAliasPX3 + "->PX3_PROVI") := aPX3[nLin][3]
	&(cAliasPX3 + "->PX3_TPVALO") := aPX3[nLin][4]

	If Len(aPB9) > 0
		If nLin <= Len(aPB9)
			nPos := nLin
		Else
			nPos := 1
		EndIf

		&(cAliasPX3 + "->PX3_CCUSTO") := aPB9[nPos, 1]
		&(cAliasPX3 + "->PX3_ITEMCT") := aPB9[nPos, 2]
		&(cAliasPX3 + "->PX3_CLVL") := aPB9[nPos, 3]
	EndIf

	cPX3_ITEM := Soma1(cPX3_ITEM)

	(cAliasPX3)->(MsUnLock())
Next

&(cAliasPX2 + "->PX2_XLOG") := cPX2_XLOG
&(cAliasPX2 + "->PX2_XWAR") := cPX2_XWAR

Return

/*/{Protheus.doc} TrataPX4
Função para tratamento da gravação da tabela PX4
@author Wagner Mobile Costa
@since 22/05/2025
@version 1.00

@type function

// Comentários

	// PX4 - Empresas Pagadoras
	// AW até CI

	// AW - TOTVS S/A - MATRIZ					| 00001000100
	// AX - TOTVS S/A - ASSIS					| 00001002700
	// AY - TOTVS S/A - BELO HORIZONTE			| 00001001200
	// AZ - TOTVS S/A - CAXIAS DO SUL			| 00001002600
	// BA - TOTVS S/A - MARINGÁ					| 00001003100
	// BB - TOTVS S/A - MACAÉ					| 00001002300
	// BC - TOTVS S/A - PORTO ALEGRE			| 00001001100
	// BD - TOTVS S/A - RIO DE JANEIRO			| 00001000800
	// BE - TOTVS S/A - SANTA CATARINA			| 00001001700
	// BF - TTS (MATRIZ)						| 00202000100
	// BG - TTS - FILIAL BAHIA					| 00202000200
	// BH - TTS - FILIAL RIB.PRETO				| 00202000300
	// BI - TTS - FILIAL GOIÂNIA				| 00202000400
	// BJ - TTS - FILIAL CAXIAS DO SUL			| 00202000600
	// BK - TTS - FILIAL PORTO ALEGRE			| 00202000500
	// BL - TTS - FILIAL LIMEIRA				| 00202000900
	// BM - TTS - FILIAL JUNDIAÍ				| 00202000800
	// BN - TTS - FILIAL CAMPINAS				| 00202000700
	// BO - TTS - FILIAL FLORIANÓPOLIS			| 00202001000
	// BP - DIMENSA - MATRIZ					| 60 | 60001000100
	// BQ - DIMENSA - SÃO PAULO					| 60 | 02301000600
	// BR - DIMENSA - PORTO ALEGRE				| 60 | 02301000200
	// BS - DIMENSA - MINAS GERAIS				| 60 | ???????????
	// BT - TOTVS TECNOLOGIA EM SOFTWARE DE GESTÃO (JOINVILLE)		| 00302000600
	// BU - TOTVS TECNOLOGIA EM SOFTWARE DE GESTÃO (MATRIZ)			| 00302000100
	// BV - TOTVS TECNOLOGIA EM SOFTWARE DE GESTÃO (BH)				| 00302000200
	// BW - TOTVS TECNOLOGIA EM SOFTWARE DE GESTÃO (GOIÂNIA)		| 00302000500
	// BX - TOTVS HOSPITALITY										| 00401000100
	// BY - LARGE - BELO HORIZONTE				| 02501000500
	// BZ - LARGE - RIO DE JANEIRO				| 02501000700
	// CA - LARGE - MATRIZ						| ???????????
	// CB - LARGE - SÃO PAULO					| 02501000200
	// CC - LARGE - PINHEIROS					| 02501002300
	// CD - TOTVS RESERVAS 						| 02201000100
	// CE - VT COMÉRCIO DIGITAL S/A				| 00501000100
	// CF - WS									| 
	// CG - RJ CONSULTORES						| 02101000100
	// CH - TOTVS SERVIÇOS DE DESENVOLVIMENTO (ELEVE)	| ?????????????
	// CI - FEEDZ TECNOLOGIA S/A						| 04601000100

/*/

Static Function TrataPX4(aColunas, aData, lNew, lGravaPX4)

Local cAliasPX4   := aQuery[5][2]:Alias()
Local aPX4        := {}
Local cAliasPX2   := aQuery[1][2]:Alias()
Local cPX2_CONTRA := &(cAliasPX2 + "->PX2_CONTRA")
Local cColuna     := ""
Local cField      := ""
Local nCol        := 1
Local nLin        := 1

For nCol := 1 To Len(aColunas)
	cField  := ""
	IF nCol > Len(aData)
		Loop
	EndIf
	xValor  := aData[nCol]
	cColuna := aColunas[nCol]
	cColuna := Left(cColuna, Len(cColuna) - 1)

	If cColuna == "AW"
		If xValor == "X"
			Aadd(aPX4, { "00", "00001000100" } )
		EndIf
	ElseIf cColuna == "AX"
		If xValor == "X"
			Aadd(aPX4, { "00", "00001002700" } )
		EndIf
	ElseIf cColuna == "AY"
		If xValor == "X"
			Aadd(aPX4, { "00", "00001001200" } )
		EndIf
	ElseIf cColuna == "AZ"
		If xValor == "X"
			Aadd(aPX4, { "00", "00001002600" } )
		EndIf
	ElseIf cColuna == "BA"
		If xValor == "X"
			Aadd(aPX4, { "00", "00001003100" } )
		EndIf
	ElseIf cColuna == "BB"
		If xValor == "X"
			Aadd(aPX4, { "00", "00001002300" } )
		EndIf
	ElseIf cColuna == "BC"
		If xValor == "X"
			Aadd(aPX4, { "00", "00001001100" } )
		EndIf
	ElseIf cColuna == "BD"
		If xValor == "X"
			Aadd(aPX4, { "00", "00001000800" } )
		EndIf
	ElseIf cColuna == "BE"
		If xValor == "X"
			Aadd(aPX4, { "00", "00001001700" } )
		EndIf
	ElseIf cColuna == "BF"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202000100" } )
		EndIf
	ElseIf cColuna == "BG"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202000200" } )
		EndIf
	ElseIf cColuna == "BH"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202000300" } )
		EndIf
	ElseIf cColuna == "BI"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202000400" } )
		EndIf
	ElseIf cColuna == "BJ"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202000600" } )
		EndIf
	ElseIf cColuna == "BK"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202000500" } )
		EndIf
	ElseIf cColuna == "BL"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202000900" } )
		EndIf
	ElseIf cColuna == "BM"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202000800" } )
		EndIf
	ElseIf cColuna == "BN"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202000700" } )
		EndIf
	ElseIf cColuna == "BO"
		If xValor == "X"
			Aadd(aPX4, { "00", "00202001000" } )
		EndIf
	ElseIf cColuna == "BP"
		If xValor == "X"
			Aadd(aPX4, { "60", "60001000100" } )
		EndIf
	ElseIf cColuna == "BQ"
		If xValor == "X"
			Aadd(aPX4, { "60", "02301000600" } )
		EndIf
	ElseIf cColuna == "BR"
		If xValor == "X"
			Aadd(aPX4, { "60", "02301000200" } )
		EndIf
	ElseIf cColuna == "BT"
		If xValor == "X"
			Aadd(aPX4, { "00", "00302000600" } )
		EndIf
	ElseIf cColuna == "BU"
		If xValor == "X"
			Aadd(aPX4, { "00", "00302000100" } )
		EndIf
	ElseIf cColuna == "BV"
		If xValor == "X"
			Aadd(aPX4, { "00", "00302000200" } )
		EndIf
	ElseIf cColuna == "BW"
		If xValor == "X"
			Aadd(aPX4, { "00", "00302000500" } )
		EndIf
	ElseIf cColuna == "BX"
		If xValor == "X"
			Aadd(aPX4, { "00", "00401000100" } )
		EndIf
	ElseIf cColuna == "BY"
		If xValor == "X"
			Aadd(aPX4, { "00", "02501000500" } )
		EndIf
	ElseIf cColuna == "BZ"
		If xValor == "X"
			Aadd(aPX4, { "00", "02501000700" } )
		EndIf
	ElseIf cColuna == "CB"
		If xValor == "X"
			Aadd(aPX4, { "00", "02501000200" } )
		EndIf
	ElseIf cColuna == "CC"
		If xValor == "X"
			Aadd(aPX4, { "00", "02501002300" } )
		EndIf
	ElseIf cColuna == "CD"
		If xValor == "X"
			Aadd(aPX4, { "00", "02201000100" } )
		EndIf
	ElseIf cColuna == "CE"
		If xValor == "X"
			Aadd(aPX4, { "00", "00501000100" } )
		EndIf
	ElseIf cColuna == "CG"
		If xValor == "X"
			Aadd(aPX4, { "00", "02101000100" } )
		EndIf
	ElseIf cColuna == "CI"
		If xValor == "X"
			Aadd(aPX4, { "00", "04601000100" } )
		EndIf
	EndIf
Next

If lGravaPX4
	For nLin  := 1 To Len(aPX4)
		If (cAliasPX4)->(DbSeek(xFilial("PX4") + cPX2_CONTRA + aPX4[nLin][1] + aPX4[nLin][2]))
			Loop
		EndIf

		RecLock(cAliasPX4, .T.)
		&(cAliasPX4 + "->PX4_CONTRA") := cPX2_CONTRA
		&(cAliasPX4 + "->PX4_EMPRES") := aPX4[nLin][1]
		&(cAliasPX4 + "->PX4_FILPAG") := aPX4[nLin][2]

		(cAliasPX4)->(MsUnLock())
	Next
EndIf

Return aPX4

/*/{Protheus.doc} TrataPX6
Função para tratamento da gravação da tabela PX6
@author Wagner Mobile Costa
@since 22/05/2025
@version 1.00

@type function
/*/

Static Function TrataPX6(aColunas, aData, lNew)

Local cAliasPX6   := aQuery[6][2]:Alias()
Local aPX6        := {}
Local cPX6_USER   := ""
Local cPX6_TPUSU  := ""
Local cPX6_TIPCON := ""
Local cContato1   := ""
Local cContato2   := ""
Local cAliasPX2   := aQuery[1][2]:Alias()
Local cPX2_CONTRA := &(cAliasPX2 + "->PX2_CONTRA")
Local cColuna     := ""
Local cField      := ""
Local nCol        := 1
Local nLin        := 1
Local cAlias      := ""
Local oExec       := Nil
Local aArea       := GetArea() 

For nCol := 1 To Len(aColunas)
	cField  := ""
	IF nCol > Len(aData)
		Loop
	EndIf
	xValor  := aData[nCol]
	cColuna := aColunas[nCol]
	cColuna := Left(cColuna, Len(cColuna) - 1)

	If cColuna == "W"
		cContato1 := AllTrim(xValor)
	ElseIf cColuna == "Y"
		cContato2 := AllTrim(xValor)
	ElseIf cColuna == "I" .Or. cColuna == "X" .Or. cColuna == "Z"
		If xValor == "-"
			xValor := ""
		EndIf
		If Empty(xValor)
			Loop
		EndIf
		
		cPX6_USER 	:= ""
		cPX6_TPUSU  := ""
		cPX6_TIPCON := ""
		If cColuna == "I"
			cPX6_TPUSU  := "2"
			cPX6_TIPCON := "3"
			aLin := StrToArray(xValor,"##")
			For nLin := 1 To Len(aLin)
				aLin[nLin] := { "", AllTrim(aLin[nLin]), AllTrim(aLin[nLin]), cPX6_TPUSU }
			Next
		Else
			cPX6_TPUSU := If(cColuna == "X", "0", "1")
			xValor := AllTrim(StrTran(xValor, "##", ";"))
			xValor := StrTran(xValor, " / ", ";")

			If xValor == "-"
				xValor := ""
			EndIf
			aLin := StrToArray(xValor,";")

			For nLin := 1 To Len(aLin)
				oExec := FwExecStatement():New("SELECT USR_ID FROM SYS_USR WHERE UPPER(USR_EMAIL) = ? AND D_E_L_E_T_ = ?")
				oExec:SetString(1,Upper(aLin[nLin]))
				oExec:SetString(2," ")
				cAlias := oExec:OpenAlias()
				
				If ! Empty((cAlias)->USR_ID)
					aLin[nLin] := { (cAlias)->USR_ID, If(cColuna == "X", cContato1, cContato2), AllTrim(aLin[nLin]), cPX6_TPUSU }
				Else
					aLin[nLin] := { "", If(cColuna == "X", cContato1, cContato2), AllTrim(aLin[nLin]), "3" }
				EndIf
				DbSelectArea(cAlias)
				DbCloseArea()
			Next
		EndIf

		For nLin := 1 To Len(aLin)
			If ! Empty(aLin[nLin][2])
				Aadd(aPX6, { aLin[nLin][4], aLin[nLin][1], aLin[nLin][2], aLin[nLin][3], cPX6_TIPCON })
			EndIf
		Next
	EndIF
Next

For nLin := 1 To Len(aPX6)
	If (cAliasPX6)->(DbSeek(xFilial("PX6") + cPX2_CONTRA + aPX6[nLin][1] + aPX6[nLin][2] + aPX6[nLin][3]))
		Loop
	EndIf

	RecLock(cAliasPX6, .T.)
	&(cAliasPX6 + "->PX6_CONTRA") := cPX2_CONTRA
	&(cAliasPX6 + "->PX6_TPUSU") := aPX6[nLin][1]
	&(cAliasPX6 + "->PX6_USER") := aPX6[nLin][2]
	&(cAliasPX6 + "->PX6_NOME") := aPX6[nLin][3]
	&(cAliasPX6 + "->PX6_EMAIL") := aPX6[nLin][4]
	&(cAliasPX6 + "->PX6_TIPCON") := aPX6[nLin][5]

	(cAliasPX6)->(MsUnLock())
Next

RestArea(aArea)

Return

/*/{Protheus.doc} TrataPX7
Função para tratamento da gravação da tabela PX7
@author Wagner Mobile Costa
@since 22/05/2025
@version 1.00

@type function
/*/
Static Function TrataPX7(aColunas, aData, lNew)

Local cAliasPX7   := aQuery[3][2]:Alias()
Local aPX7        := {}
Local cAliasPX2   := aQuery[1][2]:Alias()
Local cPX2_CONTRA := &(cAliasPX2 + "->PX2_CONTRA")
Local cPX2_XLOG   := AllTrim(&(cAliasPX2 + "->PX2_XLOG"))
Local cColuna     := ""
Local cField      := ""
Local nCol        := 1
Local nLin        := 1

SA2->(DbSetOrder(1))

For nCol := 1 To Len(aColunas)
	cField  := ""
	IF nCol > Len(aData)
		Loop
	EndIf
	xValor  := aData[nCol]
	cColuna := aColunas[nCol]
	cColuna := Left(cColuna, Len(cColuna) - 1)

	If cColuna == "E"
		cField := "PX7_FORNEC"
		If ValType(xValor) = "N"
			xValor := StrZero(xValor, 6)
		EndIf
		aLin := StrToArray(xValor,"##")
		For nLin := 1 To Len(aLin)
			aLin[nLin] := AllTrim(aLin[nLin])
			If Empty(aLin[nLin])
				Loop
			EndIf
			Aadd(aPX7, { aLin[nLin], "0" })
		Next
		
	ElseIf cColuna == "H"
		cField := "PX7_PAGBLQ"
		For nLin := 1 To Len(aPX7)
			aPX7[nLin][2] := If(xValor == "SIM", "1", "0")
		Next
	EndIf
Next

For nLin := 1 To Len(aPX7)
	If SA2->(DbSeek(xFilial() + aPX7[nLin][1])) 
		IF (cAliasPX7)->(DbSeek(xFilial("PX7") + cPX2_CONTRA + aPX7[nLin][1]))
			Loop
		EndIF

		RecLock(cAliasPX7, .T.)
		&(cAliasPX7 + "->PX7_CONTRA") := cPX2_CONTRA
		&(cAliasPX7 + "->PX7_FORNEC") := aPX7[nLin][1]
		&(cAliasPX7 + "->PX7_LOJA") := "00"
		&(cAliasPX7 + "->PX7_PAGBLQ") := aPX7[nLin][2]
		(cAliasPX7)->(MsUnLock())
	Else
		If ! Empty(cPX2_XLOG)
			cPX2_XLOG += Chr(13) + Chr(10)
		EndIf
		cPX2_XLOG += "Fornecedor [" + aPX7[nLin][1] + "] não existe"
		&(cAliasPX2 + "->PX2_NLOG") := &(cAliasPX2 + "->PX2_NLOG") + 1
	EndIF
Next

&(cAliasPX2 + "->PX2_XLOG") := cPX2_XLOG

Return


/*/{Protheus.doc} TrataPB9
Função para tratamento da gravação da tabela PB9
@author Wagner Mobile Costa
@since 22/05/2025
@version 1.00

@type function
/*/

Static Function TrataPB9(aColunas, aData, lNew)

Local cAliasPB9   := aQuery[2][2]:Alias()
Local cPB9_CCUSTO := ""
Local cPB9_ITEMCT := ""
Local cPB9_CLVL   := ""
Local aPB9        := {}
Local lErro       := .F.
Local cAliasPX2   := aQuery[1][2]:Alias()
Local cPX2_CONTRA := &(cAliasPX2 + "->PX2_CONTRA")
Local cPX2_XLOG   := AllTrim(&(cAliasPX2 + "->PX2_XLOG"))
Local cColuna     := ""
Local cField      := ""
Local nCol        := 1
Local nLin        := 1

aPB9 := {}
For nCol := 1 To Len(aColunas)
	cField  := ""
	IF nCol > Len(aData)
		Loop
	EndIf
	xValor  := aData[nCol]
	cColuna := aColunas[nCol]
	cColuna := Left(cColuna, Len(cColuna) - 1)

	If cColuna == "AV"
		aLin := StrToArray(xValor,"##")
		For nLin := 1 To Len(aLin)
			aLin[nLin] := AllTrim(aLin[nLin])
			aLin[nLin] := StrTran(aLin[nLin], " ", "")

			If Empty(aLin[nLin])
				Loop
			EndIf
			cPB9_CCUSTO := Left(aLin[nLin], At("/", aLin[nLin]) - 1)
			cPB9_CCUSTO := StrTran(cPB9_CCUSTO, "-", "")

			aLin[nLin] := Subs(aLin[nLin], At("/", aLin[nLin]) + 1)
			cPB9_ITEMCT := Left(aLin[nLin], At("/", aLin[nLin]) - 1)
			cPB9_ITEMCT := StrTran(cPB9_ITEMCT, "-", "")

			aLin[nLin] := Subs(aLin[nLin], At("/", aLin[nLin]) + 1)		
			cPB9_CLVL := StrTran(aLin[nLin], "-", "")

			IF Empty(cPB9_CCUSTO) .And. Empty(cPB9_ITEMCT) .And. Empty(cPB9_CLVL)
				Loop
			EndIf
			cPB9_CCUSTO := Left(cPB9_CCUSTO + Space(Len(PB9->PB9_CCUSTO)), Len(PB9->PB9_CCUSTO))
			cPB9_ITEMCT := Left(cPB9_ITEMCT + Space(Len(PB9->PB9_ITEMCT)), Len(PB9->PB9_ITEMCT))
			cPB9_CLVL   := Left(cPB9_CLVL + Space(Len(PB9->PB9_CLVL)), Len(PB9->PB9_CLVL))

			Aadd(aPB9, { cPB9_CCUSTO, cPB9_ITEMCT, cPB9_CLVL })
		Next
	EndIf
Next

CTT->(DbSetOrder(1))
CTD->(DbSetOrder(1))
CTH->(DbSetOrder(1))

For nLin := 1 To Len(aPB9)
	lErro := .F.
	If ! CTT->(DbSeek(xFilial() + aPB9[nLin][1]))
		If ! Empty(cPX2_XLOG)
			cPX2_XLOG += Chr(13) + Chr(10)
		EndIf
		cPX2_XLOG += "Centro de Custo [" + aPB9[nLin][1] + "] não existe"
		lErro := .T.
		&(cAliasPX2 + "->PX2_NLOG") := &(cAliasPX2 + "->PX2_NLOG") + 1
	EndIf

	If ! CTD->(DbSeek(xFilial() + aPB9[nLin][2]))
		If ! Empty(cPX2_XLOG)
			cPX2_XLOG += Chr(13) + Chr(10)
		EndIf
		cPX2_XLOG += "Item Contábil [" + aPB9[nLin][2] + "] não existe"
		lErro := .T.
		&(cAliasPX2 + "->PX2_NLOG") := &(cAliasPX2 + "->PX2_NLOG") + 1
	EndIf

	If ! CTH->(DbSeek(xFilial() + aPB9[nLin][3]))
		If ! Empty(cPX2_XLOG)
			cPX2_XLOG += Chr(13) + Chr(10)
		EndIf
		cPX2_XLOG += "Classe de Valor [" + aPB9[nLin][3] + "] não existe"
		&(cAliasPX2 + "->PX2_NLOG") := &(cAliasPX2 + "->PX2_NLOG") + 1
		lErro := .T.
	EndIf

	If lErro
		Loop
	EndIf

	If (cAliasPB9)->(DbSeek(xFilial("PX9") + cPX2_CONTRA + aPB9[nLin, 1] + aPB9[nLin, 2] + aPB9[nLin, 3]))
		Loop
	EndIf

	RecLock(cAliasPB9, .T.)
	&(cAliasPB9 + "->PB9_CONTRA") := cPX2_CONTRA
	&(cAliasPB9 + "->PB9_CCUSTO") := aPB9[nLin, 1]
	&(cAliasPB9 + "->PB9_ITEMCT") := aPB9[nLin, 2]
	&(cAliasPB9 + "->PB9_CLVL") := aPB9[nLin, 3]

	(cAliasPB9)->(MsUnLock())
Next

aPB9 := Aclone(aPB9)

&(cAliasPX2 + "->PX2_XLOG") := cPX2_XLOG

Return
