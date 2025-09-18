#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Class TGCFA001E FROM FWModelEvent

	Method New() CONSTRUCTOR
	Method ModelPosVld(oModel, cModelId)

	Private Method ValidPB9(oModPB9)
Endclass

Method New() Class TGCFA001E

Return

Method ModelPosVld(oModel, cModelId) Class TGCFA001E

	Local lRet       := .T.
	Local aSaveLines := FWSaveRows()
	Local oModPB9    := Nil
	Local nOperation := oModel:getOperation()

	If cModelId == "TGCFAM001"
		Begin Sequence
			oModPB9	:= oModel:GetModel("PB9DETAIL")

			If !Self:ValidPB9(oModPB9, nOperation)
				lRet := .F.
				Break
			EndIf
		End Sequence

	EndIf

	FWRestRows(aSaveLines)
Return lRet

Method ValidPB9(oModPB9) Class TGCFA001E

	Local nX       := 0
	Local nLinPB9  := 0
	Local cCC      := ""
	Local cCLVL    := ""
	Local cItem    := ""
	Local cMsgErro := ""
	Local lRet     := .T.
	Local nLines   := oModPB9:Length()

	nLinPB9 := oModPB9:GetLine()

	Begin Sequence
		
		For nX:= 1 to nLines
			oModPB9:GoLine(nX)
			If oModPB9:IsDeleted()
				Loop
			EndIf

			cCC   := oModPB9:GetValue("PB9_CCUSTO")
			cCLVL := oModPB9:GetValue("PB9_CLVL")
			cItem := oModPB9:GetValue("PB9_ITEMCT")

			If !Empty(cCC)
				lRet := U_VLDCONT(@cCC,@cItem,@cCLVL,.F., .T.,@cMsgErro)
				cMsg :=  "Linha: " + cValtoChar(nx) + " - " + cMsgErro

				If !lRet
					Help(" ",3, 'Help','TGCFA001_AUTO', "Combinações: " + cMsg, 3, 0)
					Break
				Endif
			ElseIf nLines > 1 .And. Empty(cCC)
				If Empty(cCC)
					Help(" ",3, 'Help','TGCFA001_AUTO', "O campo de centro de custo não pode estar vazio.", 3, 0)
					lret := .F.
					Break
				EndIf
			Endif
		Next

	End Sequence

	oModPB9:GoLine(nLinPB9)

Return lret
