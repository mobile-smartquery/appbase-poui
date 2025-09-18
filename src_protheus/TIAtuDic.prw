#Include 'Protheus.ch'

/*
U_TIAtuDic()           // Atualização do dicionario com  base no diretorio _diferenca_  a ser executado pelo remote
*/



/*
####################################################################################################################################################################################
####################################################################################################################################################################################
####################################################################           ATUALIZAÇÃO            ##############################################################################
####################################################################################################################################################################################
####################################################################################################################################################################################
*/


Static __aEmps     := {}
Static __aEmpsRec  := {}
Static __cDirDif   := ""
Static __cDirLog   := ""
Static __cDirDoc   := ""

User Function TIAtuDic()
    Private oShortList
    Private oMainWnd
    Private oFont
    Private lLeft     := .F.
    Private cVersao   := GetVersao()
    Private dDataBase := MsDate()
    Private cUsuario  := "TOTVS"

    DEFINE FONT oFont NAME "MS Sans Serif" SIZE 0, -9

    DEFINE WINDOW oMainWnd FROM 0,0 TO 0,0 TITLE "Atualização de dicionario"
    oMainWnd:oFont := oFont
    oMainWnd:SetColor(CLR_BLACK,CLR_WHITE)
    oMainWnd:Cargo := oShortList
    oMainWnd:nClrText := 0
    //oMainWnd:lEscClose := .T.
    oMainWnd:ReadClientCoors()

    set epoch to 1980
    set century on

    ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT (TIAtuDic(), oMainWnd:End())

Return


Static Function TIAtuDic()
    Local cCaminho   := ""
    Local nSec       := 0
    Local nSec2      := 0
    Local nDifSeg    := 0
    Local __cEmp     := ""
    Local __cFil     := ""
    Local lRet       := .F.
    Local cDirLog    := FWTimeStamp()
    Local aDir       := {}
    Local cDir       := ""
    Local nx         := 0

    Private lAbortPrint := .F.

    OpenSm0()
    dbSelectArea("SM0")
    Set(11,"on")

    If !SelEmp(@__cEmp, @__cFil)
        Return .F.
    Endif
    RpcSetType(3)
    MsgRun("Montando Ambiente. Empresa [" + __cEmp + "] Filial [" + __cFil +"].", "Aguarde...", {||lRet := RpcSetEnv( __cEmp, __cFil,,,,,) } )
    If !lRet
        MsgAlert("Não foi possível montar o ambiente selecionado. " )
        Return .F.
    EndIf
    __cInterNet := Nil

    cCaminho  := cGetFile('Diferenças (*.dif)| *.dif', 'Informe o diretorio que contem os aquivos com as diferenças de dicionario', 1, Nil, .T., GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)

    If Empty(cCaminho)
        MsgAlert("Diretorio não informado!")
        Return
    EndIf

    __cDirDif := cCaminho

    cDir := ""
    aDir := Separa(cCaminho, "\", .T.)
    For nx:= 1 to len(aDir) - 2
        cDir += aDir[nx] + "\"
    Next

    __cDirLog := cDir + cDirLog + "\"
    __cDirDoc := cDir + "_doc_alias\"

    If ! MsgYesno("Confirma a atualização do dicionario?")
        Return
    EndIf

    nSec      := Seconds()

    GrvLog("")

    GrvLog("Inicio as " + Time())


    AtuaEmp() // set __aEmps com a abertura dos dicionarios para cada empresa
    AbreSxs() // abre com os alias

    GrvLog("Atualização dicionario conforme " + __cDirDif)
    Processa({|| ProcAtu()},,,.T.)

    If lAbortPrint
        GrvLog("Interrompido as " + Time())
    Else
        GrvLog("Termino as " + Time())
    EndIf
    nSec2 := Seconds()
    If nSec2 < nSec  // caso seja maior, significa que passaou da meia noite onde o seconds recomeça com 0
        nDifSeg := 86399 - nSec
        nDifSeg += nSec2
    Else
        nDifSeg := nSec2 - nSec
    EndIf

    GrvLog("")
    GrvLog("Tempo de processamento: " + Timer(nDifSeg))
    GrvLog("")

    MsgAlert("Gerado arquivos de log no diretorio "+ __cDirLog)
Return

Static Function AtuaEmp()
    Local aDirDif := {}
    Local nx      := 0
    Local cArq    := ""
    Local nSM0     := SM0->(Recno())

    __aEmps     := {}
    __aEmpsRec  := {}

    aDirDif := Directory(__cDirDif + "*.dif")
    For nx:= 1 to len(aDirDif)
        cArq   := aDirDif[nx, 1]
        If "_" $ cArq  // primeira versao
            cEmp   := Subs(cArq, 4, 2)
        Else // versao atual
            cEmp   := Subs(cArq, 4, 2)
        EndIf 

        If ! SM0->(DbSeek(cEmp))
            Loop 
        EndIf 

        If Ascan(__aEmps, cEmp) == 0
            aadd(__aEmps   , cEmp) 
            aadd(__aEmpsRec, 0   )
        EndIf 
    Next

    SM0->(DBGoto(nSM0))

Return 


Static Function ProcAtu()
    Local cArq    := ""
    Local aDirDif := {}
    Local aIndx   := {}
    Local cAlias  := ""
    Local cEmp    := ""
    Local cTipo   := ""
    Local aAltTab := {}
    Local nx
    Local nSM0     := SM0->(Recno())

    aDirDif := Directory(__cDirDif + "*.dif")

    ProcRegua(1)
    For nx := 1 to len(aDirDif)
        cArq   := aDirDif[nx, 1]
        If "_" $ cArq // primeira versao
            cAlias := Left(cArq, 3)
            cEmp   := Subs(cArq, 4, 2)
            cTipo  := IIF( Left(cArq, 3) <> "SX6", Subs(cArq, 7, 3), cAlias)
        Else // versao atual
            cTipo  := Left(cArq, 3)
            cEmp   := Subs(cArq, 4, 2)
            If cTipo == "SXB"
                cAlias := Subs(cArq, 6, 6)
            ElseIf cTipo == "SX1"
                cAlias := Subs(cArq, 6, 10)
            Else
                cAlias := Subs(cArq, 6, 3)
            EndIf 
        EndIf 

        If ! SM0->(DbSeek(cEmp))
            Loop 
        EndIf 

        IncProc("Processando arquivo: " + cArq)
        ProcessMessage()

        GrvLog(I18N("     Atualização #1 Alias: #2 Empresa: #3 ", {cTipo, cAlias, cEmp}))

        If cTipo == "SIX"
            AtuSIX(cEmp, __cDirDif + cArq, cAlias, aAltTab, aIndx)
        ElseIf cTipo == "SX2"
            AtuSX2(cEmp, __cDirDif + cArq, cAlias)
        ElseIf cTipo == "SX3"
            AtuSX3(cEmp, __cDirDif + cArq, cAlias, aAltTab)
        ElseIf cTipo == "SX7"
            AtuSX7(cEmp, __cDirDif + cArq, cAlias)
        ElseIf cTipo == "SXB"
            AtuSXB(cEmp, __cDirDif + cArq, cAlias)
        ElseIf cTipo == "SX1"
            AtuSX1(cEmp, __cDirDif + cArq, cAlias)
        ElseIf cTipo == "SX6"
            AtuSX6(cEmp, __cDirDif + cArq, cAlias)
        EndIf
    Next

    If len(aAltTab) > 0
        ProcRegua(len(aAltTab))
        For nx:= 1 to len(aAltTab)

            While .t.
                nLimite := LimThread()
                If nLimite > 0
                    Exit
                EndIf
                Sleep(1000)
                IncProc("Aguardando disponibilidade de threads...")
                ProcessMessage()
            End

            IncProc(I18N("Alterando tabela no banco: #1 #2", {aAltTab[nx, 1] , aAltTab[nx, 2]}))

            ProcessMessage()
            GrvLog(I18N("     Solicitação de atualização da tabela #1 da empresa #2", {aAltTab[nx, 2], aAltTab[nx, 1]} ))
            
            AtuTabela(aAltTab[nx, 1], aAltTab[nx, 2], aAltTab[nx, 3], aIndx)
            Sleep(1000)
        Next
        GrvLog("Verifique o arquivo no servidor \system\TIAlterTable.log com o resultado das alterações")
    EndIf
    SM0->(DBGoto(nSM0))

Return

Static Function LimThread()
    Local aInfo := {}
    Local nMaxThread := 75
    Local nQtdAtivo  := 0
    Local nx

    aInfo    := GetUserInfoArray()

    For nx:= 1 to len(aInfo)
        cObs	   := aInfo[nx, 11]
        If "TIAlterTable" == Left(cObs, 12)
            nQtdAtivo++
        EndIf
    Next

Return nMaxThread - nQtdAtivo

Static Function AtuSIX(cEmp, cArq, cAlias, aAltTab, aIndx)
    Local cSIXAtu := "SIX" + cEmp + "0"
    Local aAjuste := {}
    Local cAjuste := ""
    Local cOrdem  := ""
    Local nx      := 0
    Local aCabSIX := {}
    Local aDetSIX := {}

    Local cCampo  := ""
    Local nPos    := 0
    Local cChave  := NIL
    Local cChave2 := ""
    Local ny      := 0
    
    Local lInc    := .F.
    Local uValAtu := NIL
    Local uValNovo:= NIL
    Local lAlterou:= .F.
    Local lOnlyInd:= .T.
    Local np      := 0

    cAjuste := Alltrim(LeArq(cArq))
    FWJsonDeserialize(cAjuste, aAjuste)

    If Empty(aAjuste)
        Return
    EndIf

    aCabSIX := aAjuste[1]
    aDetSIX := aAjuste[2]

    GrvAlias(cAlias, I18N("Atualização do SIX #1 da empresa #2 em #3 as #4", {cAlias, cEmp, Dtoc(Date()), Time() }) )

    //GrvAlias(cAlias, ApagaIndice(cEmp, cAlias))

    (cSIXAtu)->(DbSetOrder(1))
    For nx := 1 to len(aDetSIX)
        cCampo := "INDICE"
        nPos   := Ascan(aCabSIX, {|x| x==  cCampo })
        cChave := aDetSIX[nx, nPos]

        cCampo := "ORDEM"
        nPos   := Ascan(aCabSIX, {|x| x==  cCampo })
        cChave += aDetSIX[nx, nPos]
        cOrdem := aDetSIX[nx, nPos]

        cCampo := "CHAVE"
        nPos   := Ascan(aCabSIX, {|x| x==  cCampo })
        cChave2:= aDetSIX[nx, nPos]

        AADD(aIndx, {cOrdem, cChave2})

        If (cSIXAtu)->(DBSeek(cChave))
            lInc := .F.
            (cSIXAtu)->(RecLock(cSIXAtu, .F.))
        Else
            lInc := .T.
            (cSIXAtu)->(RecLock(cSIXAtu, .T.))
        EndIf

        If lInc
            GrvAlias(cAlias, I18N("     Inclusão: #1 ", {cChave}))
        Else
            GrvAlias(cAlias, I18N("     Atualização #1 ", {cChave}))
            GrvAlias(cAlias, ApagaIndice(cEmp, cAlias, {cChave}, cOrdem))
        EndIf
        
        For ny := 1 to (cSIXAtu)->(Fcount())
            cCampo  := (cSIXAtu)->(FieldName(ny))
            uValAtu := (cSIXAtu)->(FieldGet(ny))
            nPos   := Ascan(aCabSIX, {|x| x==  cCampo })
            If nPos > 0
                uValNovo := aDetSIX[nx, nPos]
                If lInc .or. ! uValAtu == uValNovo
                    If lInc
                        GrvAlias(cAlias,  I18N("         #1 = [#2]" , {cCampo, cValToChar(uValNovo)}))
                    Else
                        GrvAlias(cAlias,  I18N("         #1 de [#2] para [#3]" , {cCampo, cValToChar(uValAtu), cValToChar(uValNovo)}))
                    EndIf
                    (cSIXAtu)->(FieldPut(ny, uValNovo))
                    lAlterou := .t.
                EndIf
            EndIf      
        Next ny
        If ! lAlterou
            GrvAlias(cAlias,"         Não houve alteração, os dados estão iguais!" )
        EndIf
        (cSIXAtu)->(MsUnLock())
    Next
    GrvAlias(cAlias,"")

    np := Ascan(aAltTab, {|x| x[1] + x[2] == cEmp + cAlias} )
    If Empty(np) 
        lOnlyInd := .T.
        aadd(aAltTab, {cEmp, cAlias, lOnlyInd})
    EndIf

Return()

Static Function AtuSX2(cEmp, cArq, cAlias)
    Local cSX2Atu := "SX2" + cEmp + "0"
    Local aAjuste := {}
    Local cAjuste := ""
    Local nx      := 0
    Local aCabSX2 := {}
    Local aDetSX2 := {}

    Local cCampo  := ""
    Local nPos    := 0
    Local cChave  := NIL
    Local ny      := 0
    
    Local lInc    := .F.
    Local uValAtu := NIL
    Local uValNovo:= NIL
    Local lAlterou:= .F.

    cAjuste := Alltrim(LeArq(cArq))
    FWJsonDeserialize(cAjuste, aAjuste)

    If Empty(aAjuste)
        Return
    EndIf

    aCabSX2 := aAjuste[1]
    aDetSX2 := aAjuste[2]

    GrvAlias(cAlias, I18N("Atualização do SX2 #1 da empresa #2 em #3 as #4", {cAlias, cEmp, Dtoc(Date()), Time() }) )

    (cSX2Atu)->(DbSetOrder(1))
    For nx := 1 to len(aDetSX2)
        cCampo := "X2_CHAVE"
        nPos   := Ascan(aCabSX2, {|x| x==  cCampo })
        cChave := aDetSX2[nx, nPos]

        If (cSX2Atu)->(DBSeek(cChave))
            lInc := .F.
            (cSX2Atu)->(RecLock(cSX2Atu, .F.))
        Else
            lInc := .T.
            (cSX2Atu)->(RecLock(cSX2Atu, .T.))
        EndIf

        If lInc
            GrvAlias(cAlias, I18N("     Inclusão: #1 ", {cChave}))
        Else
            GrvAlias(cAlias, I18N("     Atualização #1 ", {cChave}))
        EndIf
        
        For ny := 1 to (cSX2Atu)->(Fcount())
            cCampo  := (cSX2Atu)->(FieldName(ny))
            uValAtu := (cSX2Atu)->(FieldGet(ny))
            nPos   := Ascan(aCabSX2, {|x| x==  cCampo })
            If nPos > 0
                uValNovo := aDetSX2[nx, nPos]
                If lInc .or. ! uValAtu == uValNovo
                    If lInc
                        GrvAlias(cAlias,  I18N("         #1 = [#2]" , {cCampo, cValToChar(uValNovo)}))
                    Else
                        GrvAlias(cAlias,  I18N("         #1 de [#2] para [#3]" , {cCampo, cValToChar(uValAtu), cValToChar(uValNovo)}))
                    EndIf
                    (cSX2Atu)->(FieldPut(ny, uValNovo))

                    lAlterou := .t.
                EndIf
            EndIf
        Next
        If ! lAlterou
            GrvAlias(cAlias,"         Não houve alteração, os dados estão iguais!" )
        EndIf
        (cSX2Atu)->(MsUnLock())
    Next
    GrvAlias(cAlias,"")

Return


Static Function AtuSX3(cEmp, cArq, cAlias, aAltTab)
    Local cSX3Atu  := "SX3" + cEmp + "0"
    Local aAjuste  := {}
    Local cAjuste  := ""
    Local nx       := 0
    Local aCabSX3  := {}
    Local aDetSX3  := {}
 
 
    Local cCampo   := ""
    Local nPos     := 0
    Local cChave   := NIL
    Local ny       := 0
    Local lAltTab  := .F.
    Local lInc     := .F.
    Local uValAtu  := NIL
    Local uValNovo := NIL
    Local lAlterou := .F.
    Local cTipo    := ""
    Local nTam     := 0
    Local nDec     := 0
    Local np       := 0
    Local lOnlyInd := .F. 
    Local cContext := ""
    Local cOrdem   := ""
    Local cX3Campo := ""
    Local lExist   := .T.
    Local nz       := 0


    cAjuste := Alltrim(LeArq(cArq))
    cAjuste := Strtran(cAjuste, '"Date()','"MsDate()')
    cAjuste := Strtran(cAjuste, "'Date()","'MsDate()")
    FWJsonDeserialize(cAjuste, aAjuste)

    If Empty(aAjuste)
        Return
    EndIf

    aCabSX3 := aAjuste[1]
    aDetSX3 := aAjuste[2]

    GrvAlias(cAlias, I18N("Atualização do SX3 #1 da empresa #2 em #3 as #4", {cAlias, cEmp, Dtoc(Date()), Time() }) )

    For nx := 1 to len(aDetSX3)
        cCampo := "X3_CAMPO"
        nPos   := Ascan(aCabSX3, {|x| x==  cCampo })
        cChave := aDetSX3[nx, nPos]

        (cSX3Atu)->(DbSetOrder(2))
        If (cSX3Atu)->(DBSeek(cChave))
            nPos  := Ascan(aCabSX3, {|x| x== "X3_TIPO" })
            cTipo := aDetSX3[nx, nPos]

            nPos  := Ascan(aCabSX3, {|x| x== "X3_CONTEXT" })
            cContext := aDetSX3[nx, nPos]

            nPos  := Ascan(aCabSX3, {|x| x== "X3_TAMANHO" })
            nTam  := aDetSX3[nx, nPos]

            nPos  := Ascan(aCabSX3, {|x| x== "X3_DECIMAL" })
            nDec  := aDetSX3[nx, nPos]

            If cTipo != (cSX3Atu)->(FieldGet(FieldPos("X3_TIPO"))) .or. cContext != (cSX3Atu)->(FieldGet(FieldPos("X3_CONTEXT"))) .or. ( cTipo != "M" .and. (nTam != (cSX3Atu)->(FieldGet(FieldPos("X3_TAMANHO"))) .or. nDec  != (cSX3Atu)->(FieldGet(FieldPos("X3_DECIMAL")))))
                lAltTab := .t.
            EndIf
            lInc := .F.
            (cSX3Atu)->(RecLock(cSX3Atu, .F.))
        Else
            lAltTab := .t.
            lInc := .T.

            // Valida se o X3_ORDEM já existe, e assume o próximo disponível
            (cSX3Atu)->(DbSetOrder(1))
            cCampo := "X3_ORDEM"
            nPos   := Ascan(aCabSX3, {|x| x==  cCampo })
            cOrdem := aDetSX3[nx, nPos]

            If ((cSX3Atu)->(DBSeek(cAlias + cOrdem)))
                cX3Campo := (cSX3Atu)->(FieldGet(FieldPos("X3_CAMPO")))
                For nz := 1 to len(aDetSX3)
                    IF AllTrim(cX3Campo) == AllTrim(aDetSX3[nz, 3])
                        lExist = .F.
                    EndIF
                Next
                If lExist
                    While ((cSX3Atu)->(DBSeek(cAlias + cOrdem)))
                        cOrdem := Soma1(cOrdem)
                        If cOrdem == "Z9"
                            Exit
                        EndIf
                    EndDo
                    aDetSX3[nx, nPos] := cOrdem
                EndIf
            EndIf

            (cSX3Atu)->(RecLock(cSX3Atu, .T.))
        EndIf

        If lInc
            GrvAlias(cAlias, I18N("     Inclusão: #1 ", {cChave}))
        Else
            GrvAlias(cAlias, I18N("     Atualização #1 ", {cChave}))
        EndIf
        lAlterou := .f.
        For ny := 1 to (cSX3Atu)->(Fcount())
            cCampo  := (cSX3Atu)->(FieldName(ny))
            uValAtu := (cSX3Atu)->(FieldGet(ny))
            nPos   := Ascan(aCabSX3, {|x| x==  cCampo })
            If nPos > 0
                uValNovo := aDetSX3[nx, nPos]
                /*
                If cCampo == "X3_USADO"
                    uValNovo := "€€€€€€€€€€€€€€€"
                EndIf
                */
                If lInc .or. ! uValAtu == uValNovo
                    If lInc
                        GrvAlias(cAlias,  I18N("         #1 = [#2]" , {cCampo, cValToChar(uValNovo)}))
                    Else
                        GrvAlias(cAlias,  I18N("         #1 de [#2] para [#3]" , {cCampo, cValToChar(uValAtu), cValToChar(uValNovo)}))
                    EndIf
                    (cSX3Atu)->(FieldPut(ny, uValNovo))
                    lAlterou := .t.
                EndIf
            EndIf
        Next
        If ! lAlterou
            GrvAlias(cAlias,"         Não houve alteração, os dados estão iguais!" )
        EndIf
        (cSX3Atu)->(MsUnLock())
    Next
    GrvAlias(cAlias,"")
    If lAltTab 
        lOnlyInd := .F. 
        np := Ascan(aAltTab, {|x| x[1] + x[2] == cEmp + cAlias} )
        If Empty(np) 
           aadd(aAltTab, {cEmp, cAlias, lOnlyInd})
        Else
            If aAltTab[np, 3]  
                aAltTab[np, 3]  := lOnlyInd
            EndIf 
        EndIf 
    EndIf

Return


Static Function AtuTabela(cEmp, cAlias, lOnlyInd, aIndx)
    Local cAliasSX2 := "SX2" + cEmp + "0"
    Local cFile     := ""
    Local nRecnoSM0 := SM0->(Recno())
    Local np        := 0
    
    Default lOnlyInd:= .F.
    Default aIndx   := {}

    (cAliasSX2)->(dbSetOrder(1))  // X2_CHAVE
    If ! (cAliasSX2)->(DbSeek(cAlias))
        Return
    EndIf

    cFile := AllTrim((cAliasSX2)->(FieldGet(FieldPos("X2_ARQUIVO"))))

    /*
    If ! MsFile(cFile,,"TOPCONN")
        Return
    EndIf
    */
    np := Ascan(__aEmps, cEmp)
    SM0->(DbGoTo(__aEmpsRec[np]))
    StartJob("u_TIAlterTab", GetEnvServer(), .F., SM0->M0_CODIGO, Alltrim(SM0->M0_CODFIL), cAlias, lOnlyInd, aIndx)
    //U_TIALTERTAB(SM0->M0_CODIGO, Alltrim(SM0->M0_CODFIL), cAlias, lOnlyInd, aIndx)
    SM0->(DbGoTo(nRecnoSM0))

Return

User Function TIAlterTab(cEmp, cFil, cAlias, lOnlyInd, aIndx)
    Local cErro := ""
    Local nSec  := 0
    Local nSec2 := 0
    Local nDifSeg := 0

    RpcSetType(3)
    RpcSetEnv(cEmp, cFil,,,,,)
    GrvArq("TIAlterTable.log" ,I18N("Atualizando a tabela #1 Empresa #2 #3 #4 ", {cAlias, cEmp, Dtoc(Date()), Time()}))
    FWMonitorMsg( I18N("TIAlterTable - Atualizando tabela #1 Empresa #2" , {cAlias, cEmp}))

    nSec      := Seconds()
    If lOnlyInd
        GrvArq("TIAlterTable.log" ,I18N("Atualizando o Indice #1 Empresa #2 #3 #4 ", {cAlias, cEmp, Dtoc(Date()), Time()}))
        FWMonitorMsg( I18N("TIAlterTable - Atualizando Indice #1 Empresa #2" , {cAlias, cEmp}))
        fAtuIndex(cAlias, cEmp, aIndx)
    Else 
        GrvArq("TIAlterTable.log" ,I18N("Atualizando a tabela #1 Empresa #2 #3 #4 ", {cAlias, cEmp, Dtoc(Date()), Time()}))
        FWMonitorMsg( I18N("TIAlterTable - Atualizando tabela #1 Empresa #2" , {cAlias, cEmp}))
        __SetX31Mode(.F.)
        X31UpdTable(cAlias)
        Chkfile(cAlias)
    EndIf 

    nSec2 := Seconds()
    If nSec2 < nSec  // caso seja maior, significa que passaou da meia noite onde o seconds recomeça com 0
        nDifSeg := 86399 - nSec
        nDifSeg += nSec2
    Else
        nDifSeg := nSec2 - nSec
    EndIf

    If __GetX31Error()
        cErro :=__GetX31Trace()
        GrvArq("TIAlterTable.log" , I18N("Termino da atualização da tabela #1 empresa: #2 com erro #3 ", {cAlias, cEmp, CRLF + cErro})) 
        Return cErro
    EndIf
    GrvArq("TIAlterTable.log" , I18N("Termino da atualização da tabela #1 empresa: #2 #3 #4 processado em #5", {cAlias, cEmp, Dtoc(Date()), Time(), Timer(nDifSeg)}))

Return ""

Static Function AtuSX7(cEmp, cArq, cAlias)
    Local cSX7Atu := "SX7" + cEmp + "0"
    Local aAjuste := {}
    Local cAjuste := ""
    Local nx      := 0
    Local aCabSX7 := {}
    Local aDetSX7 := {}


    Local cCampo  := ""
    Local nPos    := 0
    Local cChave  := NIL
    Local ny      := 0
    
    Local lInc    := .F.
    Local uValAtu := NIL
    Local uValNovo:= NIL
    Local lAlterou:= .F.


    cAjuste := Alltrim(LeArq(cArq))
    FWJsonDeserialize(cAjuste, aAjuste)

    If Empty(aAjuste)
        Return
    EndIf

    aCabSX7 := aAjuste[1]
    aDetSX7 := aAjuste[2]

    GrvAlias(cAlias, I18N("Atualização do SX7 #1 da empresa #2 em #3 as #4", {cAlias, cEmp, Dtoc(Date()), Time() }) )

    (cSX7Atu)->(DbSetOrder(1))
    For nx := 1 to len(aDetSX7)
        cCampo := "X7_CAMPO"
        nPos   := Ascan(aCabSX7, {|x| x==  cCampo })
        cChave := aDetSX7[nx, nPos]

        cCampo := "X7_SEQUENC"
        nPos   := Ascan(aCabSX7, {|x| x==  cCampo })
        cChave += aDetSX7[nx, nPos]

        If (cSX7Atu)->(DBSeek(cChave))
            lInc := .F.
            (cSX7Atu)->(RecLock(cSX7Atu, .F.))
        Else
            lInc := .T.
            (cSX7Atu)->(RecLock(cSX7Atu, .T.))
        EndIf

        If lInc
            GrvAlias(cAlias, I18N("     Inclusão: #1 ", {cChave}))
        Else
            GrvAlias(cAlias, I18N("     Atualização #1 ", {cChave}))
        EndIf
        
        For ny := 1 to (cSX7Atu)->(Fcount())
            cCampo  := (cSX7Atu)->(FieldName(ny))
            uValAtu := (cSX7Atu)->(FieldGet(ny))
            nPos   := Ascan(aCabSX7, {|x| x==  cCampo })
            If nPos > 0
                uValNovo := aDetSX7[nx, nPos]
                If lInc .or. ! uValAtu == uValNovo
                    If lInc
                        GrvAlias(cAlias,  I18N("         #1 = [#2]" , {cCampo, cValToChar(uValNovo)}))
                    Else
                        GrvAlias(cAlias,  I18N("         #1 de [#2] para [#3]" , {cCampo, cValToChar(uValAtu), cValToChar(uValNovo)}))
                    EndIf
                    (cSX7Atu)->(FieldPut(ny, uValNovo))
                    lAlterou := .t.
                EndIf
            EndIf
        Next
        If ! lAlterou
            GrvAlias(cAlias,"         Não houve alteração, os dados estão iguais!" )
        EndIf
        (cSX7Atu)->(MsUnLock())
    Next
    GrvAlias(cAlias,"")

Return

Static Function AtuSXB(cEmp, cArq, cAlias)
    Local cSXBAtu := "SXB" + cEmp + "0"
    Local aAjuste := {}
    Local cAjuste := ""
    Local nx      := 0
    Local aCabSXB := {}
    Local aDetSXB := {}


    Local cCampo  := ""
    Local nPos    := 0
    Local cChave  := NIL
    Local ny      := 0
    
    Local lInc    := .F.
    Local uValAtu := NIL
    Local uValNovo:= NIL
    Local lAlterou:= .F.
    Local cCodCon := ""


    cAjuste := Alltrim(LeArq(cArq))
    FWJsonDeserialize(cAjuste, aAjuste)

    If Empty(aAjuste)
        Return
    EndIf

    aCabSXB := aAjuste[1]
    aDetSXB := aAjuste[2]

    

    (cSXBAtu)->(DbSetOrder(1))
    For nx := 1 to len(aDetSXB)
        cCampo := "XB_ALIAS"
        nPos   := Ascan(aCabSXB, {|x| x==  cCampo })
        cChave := aDetSXB[nx, nPos]

        cCodCon := aDetSXB[nx, nPos]
        If nx == 1
            GrvSXB(cCodCon, I18N("Atualização do SXB #1 da empresa #2 em #3 as #4", {cCodCon, cEmp, Dtoc(Date()), Time() }) )
        EndIf 

        cCampo := "XB_TIPO"
        nPos   := Ascan(aCabSXB, {|x| x==  cCampo })
        cChave += aDetSXB[nx, nPos]

        cCampo := "XB_SEQ"
        nPos   := Ascan(aCabSXB, {|x| x==  cCampo })
        cChave += aDetSXB[nx, nPos]
        
        cCampo := "XB_COLUNA"
        nPos   := Ascan(aCabSXB, {|x| x==  cCampo })
        cChave += aDetSXB[nx, nPos]


        If (cSXBAtu)->(DBSeek(cChave))
            lInc := .F.
            (cSXBAtu)->(RecLock(cSXBAtu, .F.))
        Else
            lInc := .T.
            (cSXBAtu)->(RecLock(cSXBAtu, .T.))
        EndIf

        If lInc
            GrvSXB(cCodCon, I18N("     Inclusão: #1 ", {cChave}))
        Else
            GrvSXB(cCodCon, I18N("     Atualização #1 ", {cChave}))
        EndIf
        
        For ny := 1 to (cSXBAtu)->(Fcount())
            cCampo  := (cSXBAtu)->(FieldName(ny))
            uValAtu := (cSXBAtu)->(FieldGet(ny))
            nPos   := Ascan(aCabSXB, {|x| x==  cCampo })
            If nPos > 0
                uValNovo := aDetSXB[nx, nPos]
                If lInc .or. ! uValAtu == uValNovo
                    If lInc
                        GrvSXB(cCodCon,  I18N("         #1 = [#2]" , {cCampo, cValToChar(uValNovo)}))
                    Else
                        GrvSXB(cCodCon,  I18N("         #1 de [#2] para [#3]" , {cCampo, cValToChar(uValAtu), cValToChar(uValNovo)}))
                    EndIf
                    (cSXBAtu)->(FieldPut(ny, uValNovo))
                    lAlterou := .t.
                EndIf
            EndIf
        Next
        If ! lAlterou
            GrvSXB(cCodCon,"         Não houve alteração, os dados estão iguais!" )
        EndIf
        (cSXBAtu)->(MsUnLock())
    Next
    GrvSXB(cCodCon,"")

Return


Static Function AtuSX1(cEmp, cArq, cAlias)
    Local cSX1Atu := "SX1" + cEmp + "0"
    Local aAjuste := {}
    Local cAjuste := ""
    Local nx      := 0
    Local aCabSX1 := {}
    Local aDetSX1 := {}


    Local cCampo  := ""
    Local nPos    := 0
    Local cChave  := NIL
    Local ny      := 0
    
    Local lInc    := .F.
    Local uValAtu := NIL
    Local uValNovo:= NIL
    Local lAlterou:= .F.
    Local cGrupo  := ""


    cAjuste := Alltrim(LeArq(cArq))
    FWJsonDeserialize(cAjuste, aAjuste)

    If Empty(aAjuste)
        Return
    EndIf

    aCabSX1 := aAjuste[1]
    aDetSX1 := aAjuste[2]

    
    (cSX1Atu)->(DbSetOrder(1))
    For nx := 1 to len(aDetSX1)
        cCampo := "X1_GRUPO"
        nPos   := Ascan(aCabSX1, {|x| x==  cCampo })
        cChave := aDetSX1[nx, nPos]
        cGrupo := aDetSX1[nx, nPos]

        If nx == 1
            GrvSX1(cGrupo, I18N("Atualização do SX1 da empresa #2 em #3 as #4", {cEmp, Dtoc(Date()), Time() }) )
        EndIf 

        cCampo := "X1_ORDEM"
        nPos   := Ascan(aCabSX1, {|x| x==  cCampo })
        cChave += aDetSX1[nx, nPos]

        If (cSX1Atu)->(DBSeek(cChave))
            lInc := .F.
            (cSX1Atu)->(RecLock(cSX1Atu, .F.))
        Else
            lInc := .T.
            (cSX1Atu)->(RecLock(cSX1Atu, .T.))
        EndIf

        If lInc
            GrvSX1(cGrupo, I18N("     Inclusão: #1 ", {cChave}))
        Else
            GrvSX1(cGrupo, I18N("     Atualização #1 ", {cChave}))
        EndIf
        
        For ny := 1 to (cSX1Atu)->(Fcount())
            cCampo  := (cSX1Atu)->(FieldName(ny))
            uValAtu := (cSX1Atu)->(FieldGet(ny))
            nPos   := Ascan(aCabSX1, {|x| x==  cCampo })
            If nPos > 0
                uValNovo := aDetSX1[nx, nPos]
                If lInc .or. ! uValAtu == uValNovo
                    If lInc
                        GrvSX1(cGrupo,  I18N("         #1 = [#2]" , {cCampo, cValToChar(uValNovo)}))
                    Else
                        GrvSX1(cGrupo,  I18N("         #1 de [#2] para [#3]" , {cCampo, cValToChar(uValAtu), cValToChar(uValNovo)}))
                    EndIf
                    (cSX1Atu)->(FieldPut(ny, uValNovo))
                    lAlterou := .t.
                EndIf
            EndIf
        Next
        If ! lAlterou
            GrvSX1(cGrupo,"         Não houve alteração, os dados estão iguais!" )
        EndIf
        (cSX1Atu)->(MsUnLock())
    Next
    GrvSX1(cGrupo,"")

Return


Static Function AtuSX6(cEmp, cArq, cAlias)
    Local cSX6Atu := "SX6" + cEmp + "0"
    Local aAjuste := {}
    Local cAjuste := ""
    Local nx      := 0
    Local aCabSX6 := {}
    Local aDetSX6 := {}


    Local cCampo  := ""
    Local nPos    := 0
    Local cChave  := NIL
    Local ny      := 0
    
    Local lInc    := .F.
    Local uValAtu := NIL
    Local uValNovo:= NIL
    Local lAlterou:= .F.
    

    cAjuste := Alltrim(LeArq(cArq))
    FWJsonDeserialize(cAjuste, aAjuste)

    If Empty(aAjuste)
        Return
    EndIf

    aCabSX6 := aAjuste[1]
    aDetSX6 := aAjuste[2]

    
    (cSX6Atu)->(DbSetOrder(1))
    For nx := 1 to len(aDetSX6)
        cCampo := "X6_FIL"
        nPos   := Ascan(aCabSX6, {|x| x==  cCampo })
        cChave := aDetSX6[nx, nPos]
        
        If nx == 1
            GrvSX6(I18N("Atualização do SX6 da empresa #2 em #3 as #4", {cEmp, Dtoc(Date()), Time() }) )
        EndIf 

        cCampo := "X6_VAR"
        nPos   := Ascan(aCabSX6, {|x| x==  cCampo })
        cChave += aDetSX6[nx, nPos]

        If (cSX6Atu)->(DBSeek(cChave))
            lInc := .F.
            (cSX6Atu)->(RecLock(cSX6Atu, .F.))
        Else
            lInc := .T.
            (cSX6Atu)->(RecLock(cSX6Atu, .T.))
        EndIf

        If lInc
            GrvSX6(I18N("     Inclusão: #1 ", {cChave}))
        Else
            GrvSX6(I18N("     Atualização #1 ", {cChave}))
        EndIf
        
        For ny := 1 to (cSX6Atu)->(Fcount())
            cCampo  := (cSX6Atu)->(FieldName(ny))
            uValAtu := (cSX6Atu)->(FieldGet(ny))
            nPos   := Ascan(aCabSX6, {|x| x==  cCampo })
            If nPos > 0
                uValNovo := aDetSX6[nx, nPos]
                If lInc .or. ! uValAtu == uValNovo
                    If lInc
                        GrvSX6(I18N("         #1 = [#2]" , {cCampo, cValToChar(uValNovo)}))
                    Else
                        GrvSX6(I18N("         #1 de [#2] para [#3]" , {cCampo, cValToChar(uValAtu), cValToChar(uValNovo)}))
                    EndIf
                    (cSX6Atu)->(FieldPut(ny, uValNovo))
                    lAlterou := .t.
                EndIf
            EndIf
        Next
        If ! lAlterou
            GrvSX6("         Não houve alteração, os dados estão iguais!" )
        EndIf
        (cSX6Atu)->(MsUnLock())
    Next
    GrvSX6("")

Return


// funcoes genericas

Static Function SelEmp(__cEmp, __cFil)
    Local oDlgLogin
    Local oCbxEmp
    Local oFont
    Local cEmpAtu			:= ""
    Local lOk				:= .F.
    Local aCbxEmp			:= {}
    Local npB
    Local npT

    oFont := TFont():New('Arial',, -11, .T., .T.)

    SM0->(DbGotop())
    While ! SM0->(Eof())
        Aadd(aCbxEmp,SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+Alltrim(SM0->M0_NOME)+' / '+SM0->M0_FILIAL)
        SM0->(DbSkip())
    EndDo

    DEFINE MSDIALOG oDlgLogin FROM  0,0 TO 210,380  Pixel TITLE "Login "
    oDlgLogin:lEscClose := .F.
    @ 010,005 Say "Selecione a Empresa:" PIXEL of oDlgLogin  FONT oFont //
    @ 018,005 MSCOMBOBOX oCbxEmp VAR cEmpAtu ITEMS aCbxEmp SIZE 180,10 OF oDlgLogin PIXEL

    TButton():New( 085,100,"&Ok"       , oDlgLogin, {|| lOk := .T.  ,oDlgLogin:End() }, 38, 14,,, .F., .t., .F.,, .F.,,, .F. )
    TButton():New( 085,140,"&Cancelar" , oDlgLogin, {|| lOk := .F. , oDlgLogin:End() }, 38, 14,,, .F., .t., .F.,, .F.,,, .F. )
    ACTIVATE MSDIALOG oDlgLogin CENTERED

    If lOk
        npB     := at("/", cEmpAtu)
        __cEmp  := Left(cEmpAtu, npB - 1)
        cEmpAtu := Subs(cEmpAtu, npB + 1)
        npT     := at("-", cEmpAtu)
        __cFil  := Left(cEmpAtu, npT - 2)
    EndIf

Return lOk

Static Function AbreSxs()
    Local nx       := 0
    Local cEmp     := ""
    Local cAliasIX := ""
    Local cAliasX2 := ""
    Local cAliasX3 := ""
    Local cAliasX7 := ""
    Local cAliasXG := ""
    Local cAliasXB := ""
    Local cAliasX1 := ""
    Local cAliasX6 := ""
    Local nSM0     := SM0->(Recno())

    AtuaEmp := {}


    For nx:= 1 to len(__aEmps)
        cEmp := __aEmps[nx]

        SM0->(dbSeek(cEmp))
        __aEmpsRec[nx] := SM0->(Recno())

        // Abrindo SX1
        cAliasIX :=  "SIX" + cEmp + "0"
        If Select(cAliasIX) > 0
            (cAliasIX)->(DbCloseArea())
        EndIf
        OpenSxs(,,,, cEmp, cAliasIX ,"SIX",,.F.)

        // Abrindo SX2
        cAliasX2 :=  "SX2" + cEmp + "0"

        If Select(cAliasX2) > 0
            (cAliasX2)->(DbCloseArea())
        EndIf
        OpenSxs(,,,, cEmp, cAliasX2 ,"SX2",,.F.)

        // Abrindo SX3
        cAliasX3 :=  "SX3" + cEmp + "0"
        If Select(cAliasX3) > 0
            (cAliasX3)->(DbCloseArea())
        EndIf
        OpenSxs(,,,, cEmp, cAliasX3 ,"SX3",,.F.)

        // Abrindo SX7
        cAliasX7 :=  "SX7" + cEmp + "0"
        If Select(cAliasX7) > 0
            (cAliasX7)->(DbCloseArea())
        EndIf
        OpenSxs(,,,, cEmp, cAliasX7 ,"SX7",,.F.)

        // Abrindo SXB
        cAliasXB :=  "SXB" + cEmp + "0"
        If Select(cAliasXB) > 0
            (cAliasXB)->(DbCloseArea())
        EndIf
        OpenSxs(,,,, cEmp, cAliasXB ,"SXB",,.F.)

        // Abrindo SXG
        cAliasXG :=  "SXG" + cEmp + "0"
        If Select(cAliasXG) > 0
            (cAliasXG)->(DbCloseArea())
        EndIf
        OpenSxs(,,,, cEmp, cAliasXG ,"SXG",,.F.)

        // Abrindo SX1
        cAliasX1 :=  "SX1" + cEmp + "0"
        If Select(cAliasX1) > 0
            (cAliasX1)->(DbCloseArea())
        EndIf
        OpenSxs(,,,, cEmp, cAliasX1 ,"SX1",,.F.)
        // Abrindo SX6

        cAliasX6 :=  "SX6" + cEmp + "0"
        If Select(cAliasX6) > 0
            (cAliasX6)->(DbCloseArea())
        EndIf
        OpenSxs(,,,, cEmp, cAliasX6 ,"SX6",,.F.)
    Next
    SM0->(DBGoto(nSM0))

Return


Static Function Timer(nSec)
    Local nHour := 0
    Local nMin  := 0

    nSec := If(nSec == NIL, 0, nSec)

    nMin  := Int(nSec/60)
    nHour := Int(nMin/60)

    If ( nMin > 0 )
        nSec -= nMin*60
    EndIf

    If ( nHour > 0 )
        nMin -= nHour*60
    EndIf

Return StrZero(nHour,2,0)+":"+StrZero(nMin,2,0)+":"+StrZero(nSec,2,0)


Static Function GrvLog(cMsg)
    Local cArquivo := ""

    If ! ExistDir(__cDirLog)
        MakeDir(__cDirLog)
    Endif

    cArquivo := __cDirLog + "_atudic.log"

    GrvArq(cArquivo, cMsg)
Return


Static Function GrvArq(cArquivo, cLinha, lCRLF)
    Local nHandle
    Default lCRLF:= .T.

    If ! File(cArquivo)
        If (nHandle := MSFCreate(cArquivo, 0)) == -1
            Return
        EndIf
    Else
        If (nHandle := FOpen(cArquivo, 2)) == -1
            Return
        EndIf
    EndIf
    FSeek(nHandle, 0, 2)
    FWrite(nHandle, cLinha + If(lCRLF, CRLF, ""))
    FClose(nHandle)
Return

Static Function LeArq(cArquivo)
    Local nh
    Local cConteudo := "" 
    Local nTBytes   := 0
    
    If ! File(cArquivo)
        Return ""
    EndIf

    nh := FOpen(cArquivo)
    nTBytes := fseek(nh,0, 2)
    fseek(nh, 0)
    cConteudo := ""
    FRead(nh, @cConteudo, nTBytes)
    Fclose(nh)


Return cConteudo

Static Function GrvAlias(cAlias, cMsg, cOk)
    Local cArquivo := ""
    Local cDir     := __cDirDoc
    Default cOk    := "ok"

    If ! ExistDir(cDir)
        MakeDir(cDir)
    Endif
    cArquivo := cDir + cAlias + "."+ cOk

    GrvArq(cArquivo, cMsg)

Return

Static Function GrvSXB(cCodCon, cMsg, cOk)
    Local cArquivo := ""
    Local cDir     := __cDirDoc
    Default cOk    := "ok"

    If ! ExistDir(cDir)
        MakeDir(cDir)
    Endif
    cArquivo := cDir + "SXB_" + cCodCon + "."+ cOk

    GrvArq(cArquivo, cMsg)

Return

Static Function GrvSX1(cGrupo, cMsg, cOk)
    Local cArquivo := ""
    Local cDir     := __cDirDoc
    Default cOk    := "ok"

    If ! ExistDir(cDir)
        MakeDir(cDir)
    Endif
    cArquivo := cDir + "SX1_" + cGrupo + "."+ cOk

    GrvArq(cArquivo, cMsg)

Return

Static Function GrvSX6( cMsg, cOk)
    Local cArquivo := ""
    Local cDir     := __cDirDoc
    Default cOk    := "ok"

    If ! ExistDir(cDir)
        MakeDir(cDir)
    Endif
    cArquivo := cDir + "SX6_NOVOS."+ cOk

    GrvArq(cArquivo, cMsg)

Return


Static Function ApagaIndice(cEmp, cAlias, aChave, cOrdem)
    Local cAliasSX2 := "SX2" + cEmp + "0"
    Local cFileIdx  := ""
    Local ni        := 0
    Local cMsg      := ""

    Default aChave := {}
    
    (cAliasSX2)->(dbSetOrder(1))  // X2_CHAVE
    If ! (cAliasSX2)->(DbSeek(cAlias))
        Return "SX2 Nao encontrado!"
    EndIf

    cFile   := AllTrim((cAliasSX2)->(FieldGet(FieldPos("X2_ARQUIVO"))))
    cFileIdx:= cFile + cOrdem

    If ! MsFile(cFile,,"TOPCONN")
        Return "Arquivo não existe!"
    EndIf    
    
    /*
    While nOrd <= 36 
        cFileIdx := cFile + RetAsc(Str(nOrd+=1), 1, .T.)
        If TcCanOpen(cFile, cFileIdx)
            Aadd(aDelKeys, cFile+'|'+cFileIdx)
        EndIf
    End
    */

    For ni := 1 To Len(aChave) 
        cMsg += "Apagado o indice: " + aChave[ni] +CRLF
        TcInternal(60, cFile+'|'+cFileIdx)
    Next
    TcRefresh(cFile)
    cMsg += "     Indice apagado!"

Return cMsg

Static Function fAtuIndex(cAlias, cEmp, aIndx)

    Local nX        := 0
    Local cOrdem    := ""
    Local cChave    := ""
    Local cTable    := RetSqlName( cAlias )

    For nX := 1 To Len( aIndx )
        ( cAlias )->(DbCloseArea())
        MsOpenDbf(.T.,"TOPCONN", cTable, cAlias,.F.,.F.,.F.,.F.)
        DBSelectArea( cAlias )
        
        cOrdem := cTable + aIndx[nX, 1]
        cChave := aIndx[nX, 2]

        MsOpenIdx(cOrdem,cChave,.T.,.F.,,cAlias)
        ( cAlias )->(DbCloseArea())
    Next nX
    
Return()
