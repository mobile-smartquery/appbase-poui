#Include 'Protheus.ch'


Static aRet__Func := {}
Static aRet__Class:= {}
Static cErroA	:= ""


User Function TIGerDif()
    Private oShortList
    Private oMainWnd
    Private oFont
    Private lLeft     := .F.
    Private cVersao   := GetVersao()
    Private dDataBase := MsDate()
    Private cUsuario  := "TOTVS"
    Private cAliasX   := ''
    Private cTipo     := ''

    DEFINE FONT oFont NAME "MS Sans Serif" SIZE 0, -9

    DEFINE WINDOW oMainWnd FROM 0,0 TO 0,0 TITLE "TI Geração de dicionario no formato .dif"
        oMainWnd:oFont := oFont
        oMainWnd:SetColor(CLR_BLACK,CLR_WHITE)
        oMainWnd:Cargo := oShortList
        oMainWnd:nClrText := 0
        oMainWnd:ReadClientCoors()
        set epoch to 1980
        set century on
    ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT (MainDevApp() , oMainWnd:End())

Return

Static Function MainDevApp()
    Local oDlg
    Local oRect
    Local oSize
 
    Local oFol
    Local oFolSX

    Local aFolder   := {'Dicionário', 'Inspeção de Funções/Comandos'}
    Local aSFolder3 := {"SIX", "SX2", "SX3", "SX7", "SXB", "SX1", "SX6"}

    Local nSF := 0
    Local lSetAnt := Set(11)

    Private aSXBrw   := Array(7)
    Private aSXLBrw  := Array(7)
    Private oInfBrw

    Private lRPO := lClasse := lADVPL := .T.

    Set(11,"on")

    cEmpAnt := ''
    cFilAnt := ''
    
    
    oSize := FwDefSize():New(.F.)
    oSize:AddObject( "PANEL" , 100, 100, .T., .T. )
    oSize:aWorkArea := {0,25,oMainWnd:nRight-15,oMainWnd:nBottom-100}
    oRect := TRect():New(7,-1,oMainWnd:nBottom-17,oMainWnd:nRight-7)
    oSize:lProp := .T.
    oSize:Process()

    DEFINE MSDIALOG oDlg FROM 0,0 TO 0,0 TITLE  "Ferramenta para geração de diferença de dicionario"
        oDlg:lEscClose := .F.
        oDlg:SetCoors(oRect)
        oFol := TFolder():New(, , aFolder, aFolder, oDlg, , , , .T., .F.)
        oFol:Align := CONTROL_ALIGN_ALLCLIENT


        oFolSx := TFolder():New(, , aSFolder3, aSFolder3, oFol:aDialogs[1], , , , .T., .F.)
        oFolSx:Align := CONTROL_ALIGN_ALLCLIENT
        For nSF := 1 to 7 
            FolderSX(oFolSX:aDialogs[nSF], oSize, nSF, aSFolder3[nSF])
        Next

        FolderInsp(oFol:aDialogs[2], oSize)        //--Folder Inspeção de Funções/Comandos
        
            
        DEFINE MESSAGE BAR oMsgBar OF oDLG PROMPT "TIGerDif " COLOR RGB(116,116,116) FONT oFont
        DEFINE MSGITEM oMsgIt of oMsgBar PROMPT "Empresa/Filial: [" + cEmpAnt + "/" + cFilAnt + "] " SIZE 100  
        DEFINE MSGITEM oMsgIt2 of oMsgBar PROMPT GetEnvServer() SIZE 100
    ACTIVATE MSDIALOG oDlg  ON INIT InitEmp(oMsgIt, oDlg)

    
    RpcClearEnv()

    Set(11, If(lSetAnt,"on","off"))
  

Return

Static Function InitEmp(oTMsgItem, oDlg)
    Local lRet:= .F.
    Local __cEmp
    Local __cFil

    OpenSm0()
    dbSelectArea("SM0")

    If ! SelEmp(@__cEmp, @__cFil)
        oDlg:End()
        Return .F.
    Endif

    RpcClearEnv()
    RpcSetType(3)
    MsgRun("Montando Ambiente. Empresa [" + __cEmp + "] Filial [" + __cFil +"].", "Aguarde...", {||lRet := RpcSetEnv( __cEmp, __cFil,,,,,) } )

    If !lRet
        MsgAlert("Não foi possível montar o ambiente selecionado. " )
        oDlg:End()
        Return .F.
    EndIf

    __cInterNet := Nil
    FWMonitorMsg( "### TOTVS TI GerDif ###" )
    oTMsgItem:SetText("Empresa/Filial: [" + __cEmp + "/" + __cFil + "] ")

Return lRet

Static Function SelEmp(__cEmp, __cFil)
    Local oDlgLogin
    Local oCbxEmp
    Local oFont      := TFont():New('Arial',, -11, .T., .T.)
    Local cEmpAtu    := ""
    Local lOk        := .F.
    Local aCbxEmp    := {}
    Local npB        := 0
    Local npT        := 0

    SM0->(DbGotop())
    While ! SM0->(Eof())
        Aadd(aCbxEmp, SM0->M0_CODIGO +'/' + SM0->M0_CODFIL + ' - ' + Alltrim(SM0->M0_NOME) + ' / ' + SM0->M0_FILIAL)
        SM0->(DbSkip())
    End

    DEFINE MSDIALOG oDlgLogin FROM  0,0 TO 210,380  Pixel TITLE "Login "
        oDlgLogin:lEscClose := .F.
        @ 010,005 Say "Selecione a Empresa:" PIXEL of oDlgLogin  FONT oFont 
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
 


Static Function FolderSX(oFol, oSize, np, cAliasSX)

    Local nB := oSize:GetDimension("PANEL", "LINEND")
    Local nR := oSize:GetDimension("PANEL", "COLEND")
    Local oPnlDicI

    Local oBut
    Local oBut2
    Local oBut3
    Local oBut4
    Local oBut5
    Local oPanelM1
    Local aIndice := {}
    Local cIndice := "Sem indice"
    Local oCbxInd
    Local cPesquisa := Space(200)
    Local cFiltro   := Space(200)
    Local oSplitV
    Local oPnlDic2

    If cAliasSX == "SIX"
        aIndice := {"SEM INDICE", "INDICE + ORDEM"}
    ElseIf cAliasSX == "SX2"
        aIndice := {"SEM INDICE", "X2_CHAVE"}
    ElseIf cAliasSX == "SX3"
        aIndice := {"SEM INDICE", "X3_ARQUIVO + X3_ORDEM", "X3_CAMPO"}
    ElseIf cAliasSX == "SX7"
        aIndice := {"SEM INDICE", "X7_CAMPO + X7_SEQUENC"}
    ElseIf cAliasSX == "SXB"
        aIndice := {"SEM INDICE", "XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA"}
    ElseIf cAliasSX == "SX1"
        aIndice := {"SEM INDICE", "X1_GRUPO + X1_ORDEM"}
    ElseIf cAliasSX == "SX6"
        aIndice := {"SEM INDICE", "X6_FIL + X6_VAR"}        
    EndIf

    oPanelM1 := TPanelCss():New(,,,oFol)
    oPanelM1 :SetCoors(TRect():New( 0,0, 30, 30))
    oPanelM1 :Align := CONTROL_ALIGN_TOP

    oPnlDicI := TPanelCss():New(,,,oFol)
    oPnlDicI :SetCoors(TRect():New( 0,0, nB , nR))
    oPnlDicI :Align :=CONTROL_ALIGN_ALLCLIENT

    @ 02, 02  BUTTON oBut  PROMPT '&Carregar'      SIZE 045,010 ACTION DicSX(cAliasSX, oPnlDicI, oPnlDic2, np) OF oPanelM1 PIXEL; oBut:nClrText :=0
    @ 02, 52  MSCOMBOBOX oCbxInd VAR cIndice ITEMS aIndice SIZE 130,10 OF oPanelM1 PIXEL VALID ( MudaOrdem(cAliasSX, oCbxInd, np, @cPesquisa ) )
    @ 05, 184 SAY "Pesquisa"   of oPanelM1 SIZE 030,09 PIXEL
    @ 02, 208 GET cPesquisa    of oPanelM1 SIZE 120,09 PIXEL VALID ( Posiciona(cAliasSX, cPesquisa, np ) ) PICTURE "@!"  when oCbxInd:nat > 1
    @ 05, 334 SAY "Filtro"     of oPanelM1 SIZE 030,09 PIXEL
    @ 02, 358 GET cFiltro      of oPanelM1 SIZE 120,09 PIXEL VALID ( Filtro(cAliasSX, cFiltro, np ) ) PICTURE "@!S50"

    oCbxInd:nat := 2
    @ 02, (nR * 0.25) + 125  BUTTON oBut2  PROMPT 'Adicionar'       SIZE 045,010 ACTION AtuSXL(cAliasSX, np, .F.) OF oPanelM1 PIXEL; oBut2:nClrText :=0
    @ 02, (nR * 0.25) + 175  BUTTON oBut2  PROMPT 'Adicionar Todos' SIZE 045,010 ACTION AtuSXL(cAliasSX, np, .T.) OF oPanelM1 PIXEL; oBut2:nClrText :=0
    @ 02, (nR * 0.25) + 225  BUTTON oBut3  PROMPT 'Excluir'         SIZE 045,010 ACTION DelSXL(cAliasSX, np) OF oPanelM1 PIXEL; oBut3:nClrText :=0
    @ 02, (nR * 0.25) + 275 BUTTON oBut4  PROMPT 'Excluir todos'    SIZE 045,010 ACTION DelAll(cAliasSX, np) OF oPanelM1 PIXEL; oBut4:nClrText :=0
    @ 02, (nR * 0.25) + 325 BUTTON oBut5  PROMPT 'Exportar'         SIZE 045,010 ACTION ExportSXL(cAliasSX, np) OF oPanelM1 PIXEL; oBut5:nClrText :=0
    oBut2:lVisibleControl:= .T.
    oBut3:lVisibleControl:= .T.
    oBut4:lVisibleControl:= .T.

    oPnlDic2:= TPanelCss():New(,,,oFol)
    oPnlDic2:SetCoors(TRect():New( 0,0, nB * 0.4, (nR * 0.5)-4))
    oPnlDic2:Align :=CONTROL_ALIGN_RIGHT
    oPnlDic2:lVisibleControl:= .T.

    @ 000,000 BUTTON oSplitV PROMPT "*" SIZE 4,4 OF oFol PIXEL
    oSplitV:cToolTip := "Habilita e desabilita Lista a exportar "
    oSplitV:bLClicked := {|| oPnlDic2:lVisibleControl := !oPnlDic2:lVisibleControl, ;
        oBut2:lVisibleControl := !oBut2:lVisibleControl,;
        oBut3:lVisibleControl := !oBut3:lVisibleControl,;
        oBut4:lVisibleControl := !oBut4:lVisibleControl,;
        oBut5:lVisibleControl := !oBut5:lVisibleControl}
    oSplitV:Align := CONTROL_ALIGN_RIGHT
    oSplitV:nClrText :=0

Return

Static Function MudaOrdem(cAlias, oCbxInd, np, cPesquisa)
    Local nOrdem := oCbxInd:nat -1

    (cAlias)->(DBSetOrder(nOrdem))

    If ValType(aSXBrw[np])=='O'
        aSXBrw[np]:Refresh()
    EndIf
    cPesquisa := Space(200)


Return

Static Function Filtro(cAlias, cFiltro, np)

    If Empty(cFiltro)
        (cAlias)->( dbClearFilter( ) )
    Else
        (cAlias)->( dbSetFilter( { || &(cFiltro) }, cFiltro ) )
    EndIf
    (cAlias)->( DbGotop())

    If ValType(aSXBrw[np])=='O'
        aSXBrw[np]:Refresh()
    EndIf

Return

Static Function Posiciona(cAlias, cPesquisa, np)

    (cAlias)->(DBSeek(Alltrim(cPesquisa)))

    If ValType(aSXBrw[np])=='O'
        aSXBrw[np]:Refresh()
    EndIf

Return

Static Function DicSX(cAlias, oPnlDicI, oPnlDic2, np)
    Local nX := 0
    Local cAliasTst := MyNextAlias()
    Local cDir    := ""
    Local aStruct:= {}
    Local aIndice := {}

    If empty(cFilAnt) .or. empty(cEmpAnt)
        MsgInfo("Ambiente não inicializado")
        Return
    EndIf

    If ValType(aSXBrw[np])=='O'
        Return
    EndIf

    cAliasTst := cAlias


    aSXBrw[np] := MsBrGetDBase():New(1, 1, __DlgWidth(oPnlDicI)-1, __DlgHeight(oPnlDicI) - 1,,,, oPnlDicI,,,,,,,,,,,, .F., cAliasTst, .T.,, .F.,,,)
    For nX:=1 To (cAliasTst)->(FCount())
        aSXBrw[np]:AddColumn( TCColumn():New( (cAliasTst)->(Field(nx)) , &("{ || " + cAliasTst + "->" + (cAliasTst)->(FieldName(nX)) + "}"),,,,, "LEFT") )
    Next nX

    aSXBrw[np]:lColDrag	:= .T.
    aSXBrw[np]:lLineDrag	:= .T.
    aSXBrw[np]:lJustific	:= .T.
    aSXBrw[np]:nColPos		:= 1
    aSXBrw[np]:Cargo		:= {|| __NullEditcoll()}
    aSXBrw[np]:Align       := CONTROL_ALIGN_ALLCLIENT
    aSXBrw[np]:bLDblClick  := {|| AtuSXL(cAlias, np)}

    aStruct := (cAliasTst)->(dbStruct())

    cDir := "system\tidev\"
    If ! ExistDir(cDir)
        MakeDir(cDir)
    Endif

    //dbCreate(cDir + cAliasLst, aStruct )
    //dbUseArea( .T., "DBFCDX", cDir + cAliasLst, cAliasX, .F., .F. )
    If cAlias == "SIX" 
        aIndice := { "INDICE", "ORDEM" }
    ElseIf cAlias == "SX2"
        aIndice := { "X2_CHAVE" }
    ElseIf cAlias == "SX3"
        aIndice := { "X3_ARQUIVO", "X3_CAMPO" }
    ElseIf cAlias == "SX7"
        aIndice := { "X7_CAMPO", "X7_SEQUENC" }
    ElseIf cAlias == "SXB" 
        aIndice := { "XB_ALIAS", "XB_TIPO", "XB_SEQ", "XB_COLUNA" }
    ElseIf cAlias == "SX1"
        aIndice := { "X1_GRUPO", "X1_ORDEM" }
    ElseIf cAlias == "SX6"  
        aIndice := { "X6_FIL", "X6_VAR" }
    EndIf

    cAliasX	:= GetNextAlias() 
    oTable := FWTemporaryTable():New( cAliasX, aStruct)
	oTable:AddIndex("01", aIndice)
    oTable:Create()
    xcAlias := oTable:GetRealName()

    aSXLBrw[np] := MsBrGetDBase():New(1, 1, __DlgWidth(oPnlDic2)-1, __DlgHeight(oPnlDic2) - 1,,,, oPnlDic2,,,,,,,,,,,, .F., cAliasX, .T.,, .F.,,,)
    For nX:=1 To (cAliasX)->(FCount())
        aSXLBrw[np]:AddColumn( TCColumn():New( (cAliasX)->(Field(nx)) , &("{ || " + cAliasX + "->" + (cAliasX)->(FieldName(nX)) + "}"),,,,, "LEFT") )
    Next nX
    aSXLBrw[np]:lColDrag	:= .T.
    aSXLBrw[np]:lLineDrag	:= .T.
    aSXLBrw[np]:lJustific	:= .T.
    aSXLBrw[np]:nColPos		:= 1
    aSXLBrw[np]:Cargo		:= {|| __NullEditcoll()}
    aSXLBrw[np]:Align       := CONTROL_ALIGN_ALLCLIENT
    aSXLBrw[np]:bLDblClick  := {||DelSXL(cAlias, np) }
    
    
Return

Static __cSeqAliasTmp := "000"

Static Function MyNextAlias()

    __cSeqAliasTmp := Soma1(__cSeqAliasTmp)

Return  "TI" + Strzero(ThreadId(), 6) + __cSeqAliasTmp

Static Function AtuSXL(cAlias, np, lTodos)
    Local lTem := .F.

    If Select(cAliasX) == 0
        Return 
    EndIf 
    
    If lTodos
        (cAliasX)->(DbGoTop())
    EndIf

    While (cAlias)->(! Eof())
        lTem := .F.
        If cAlias == "SIX" 
            lTem := (cAliasX)->(DbSeek(SIX->(INDICE + ORDEM)))
        ElseIf cAlias == "SX2"
            lTem := (cAliasX)->(DbSeek(SX2->X2_CHAVE))
        ElseIf cAlias == "SX3"
            lTem := (cAliasX)->(DbSeek(SX3->(X3_ARQUIVO + X3_CAMPO)))
        ElseIf cAlias == "SX7"
            lTem := (cAliasX)->(DbSeek(SX7->(X7_CAMPO + X7_SEQUENC)))
        ElseIf cAlias == "SXB" 
            lTem := (cAliasX)->(DbSeek(SXB->(XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA)))
        ElseIf cAlias == "SX1"  
            lTem := (cAliasX)->(DbSeek(SX1->(X1_GRUPO + X1_ORDEM)))
        ElseIf cAlias == "SX6"  
            lTem := (cAliasX)->(DbSeek(SX6->(X6_FIL + X6_VAR)))
        EndIf

        If lTodos
            If ! lTem
                Insere(cAliasX, cAlias)
            EndIf
            (cAlias)->(DbSkip())
        Else
            Exit
        EndIf
    End

    If ! lTodos .And. ! lTem
        Insere(cAliasX, cAlias)
    EndIf

    (cAlias)->(DBGoTop())
    (cAliasX)->(DBGoTop())
    aSXLBrw[np]:Refresh()

Return

Static Function Insere(cAliasX, cAlias)
    Local nx := 0

    (cAliasX)->(RecLock(cAliasX, .T.))
    For nx := 1 to (cAlias)->(FCount())
        (cAliasX)->(FieldPut(nx, (cAlias)->(FieldGet(nx))))
    Next
    (cAliasX)->(MsUnlock())

Return

Static Function DelSXL(cAlias, np)
    Local cChave := ""

    If Select(cAliasX) == 0
        Return 
    EndIf 

    If (cAliasX)->(Lastrec()) == 0
        Return 
    EndIf 

    If (cAliasX)->(Eof())
        Return
    EndIf
    

    If cAlias == "SIX"
        cChave := (cAliasX)->(FieldGet(FieldPos("INDICE"))) + (cAliasX)->(FieldGet(FieldPos("ORDEM")))
    ElseIf cAlias == "SX2"
        cChave := (cAliasX)->(FieldGet(FieldPos("X2_CHAVE")))
    ElseIf cAlias == "SX3"
        cChave := (cAliasX)->(FieldGet(FieldPos("X3_CAMPO")))
    ElseIf cAlias == "SX7"
        cChave := (cAliasX)->(FieldGet(FieldPos("X7_CAMPO")))  + (cAliasX)->(FieldGet(FieldPos("X7_SEQUENC")))
    ElseIf cAlias == "SXB"
        cChave := (cAliasX)->(FieldGet(FieldPos("XB_ALIAS"))) + (cAliasX)->(FieldGet(FieldPos("XB_TIPO"))) + (cAliasX)->(FieldGet(FieldPos("XB_SEQ"))) + (cAliasX)->(FieldGet(FieldPos("XB_COLUNA")))
    ElseIf cAlias == "SX1"        
        cChave := (cAliasX)->(FieldGet(FieldPos("X1_GRUPO")))  + (cAliasX)->(FieldGet(FieldPos("X1_ORDEM")))
    ElseIf cAlias == "SX6"        
        cChave := (cAliasX)->(FieldGet(FieldPos("X6_FIL")))    + (cAliasX)->(FieldGet(FieldPos("X6_VAR")))
    EndIf

    If MsgYesNo("Confirma a exclusão :" + cChave)
        (cAliasX)->(RecLock(cAliasX, .F.))
        (cAliasX)->(DbDelete())
        (cAliasX)->(MsUnlock())
    EndIf
    (cAliasX)->(DBGoTop())
    aSXLBrw[np]:Refresh()
Return

Static Function DelAll(cAlias, np)

    If Select(cAliasX) == 0
        Return 
    EndIf 

    If Select(cAlias) == 0
        Return 
    EndIf 

    If (cAliasX)->(Lastrec()) == 0
        Return 
    EndIf 


    If ! MsgYesNo("Confirma a exclusão de todas as linhas?" )
        Return
    EndIf

    (cAliasX)->(DbGotop())
    While (cAliasX)->(! Eof())
        (cAliasX)->(RecLock(cAliasX, .F.))
        (cAliasX)->(DbDelete())
        (cAliasX)->(MsUnlock())
        (cAliasX)->(DbSkip())
    End
    aSXLBrw[np]:Refresh()

Return

Static Function ExportSXL(cTipo, np)

    Local nx     := 0
    Local aCab   := {}
    Local aAux   := {}
    Local aItens := {}
    Local aTodos := {}
    Local cChave := ""
    Local cAlias := ""
    Local cDir   := ""
    Local cEmp   := ""
    Local aParamBox := {}
    Local aRet      := {}
    Local uVar
    Local lErro  := .f.
    
    If Select(cAliasX) == 0
        Return 
    EndIf 

    If (cAliasX)->(Lastrec()) == 0
        Return 
    EndIf 

    cDir  := cGetFile('Arquivo Dif (*.dif)| *.dif', 'Informe o diretorio de arquivos Dif', 1, Nil, .T., GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)

    If Empty(cDir)
        MsgAlert("Diretorio não informado!")
        Return
    EndIf

    PRIVATE lMsHelpAuto := .F.

    MV_PAR01:=""
    aAdd(aParamBox,{ 1, "Codigo da Empresa" ,	"99"  , "99", ,,, 3, .F.})

    If ! ParamBox(aParamBox, "Informe a empresa", @aRet)
        Return
    EndIf

    cEmp := aRet[1]

    aCab := {}
    For nx:= 1 to (cAliasX)->(FCount())
        aadd(aCab, (cAliasX)->(FieldName(nx)) )
    Next

    (cAliasX)->(DbGotop())
    While (cAliasX)->(! Eof())
        If cTipo == "SIX"
            cChave := (cAliasX)->INDICE
        ElseIf cTipo == "SX2"
            cChave := (cAliasX)->X2_CHAVE
        ElseIf cTipo == "SX3"
            cChave := (cAliasX)->X3_ARQUIVO
        ElseIf cTipo == "SX7"
            cChave := (cAliasX)->X7_CAMPO
            If Subs(cChave, 3 , 1) =="_"
                cChave := "S" + Left(cChave, 2)
            Else
                cChave := Left(cChave, 3)
            EndIf
        ElseIf cTipo == "SXB"
            cChave := (cAliasX)->XB_ALIAS
        ElseIf cTipo == "SX1" 
            cChave := (cAliasX)->X1_GRUPO
        ElseIf cTipo == "SX6" 
            cChave := (cAliasX)->X6_VAR
        EndIf
        cChave := AllTRim(cChave)
        aAux := {}
        For nx:= 1 to (cAliasX)->(FCount())
            uVar := (cAliasX)->(FieldGet(nx))
            If cTipo == "SX2" .and. (cAliasX)->(FieldName(nx)) == "X2_ARQUIVO"
                If cEmpAnt $ uVar
                    uVar := StrTran(uVar, cEmpAnt, cEmp)
                EndIf
            EndIf
            aadd(aAux, uVar)
        Next

        np:= Ascan(aTodos, {|x| x[1] == cChave})
        If Empty(np)
            aadd(aTodos, {cChave, {aClone(aAux)}})
        Else
            aadd(aTodos[np, 2], aClone(aAux))
        EndIf

        (cAliasX)->(DbSkip())
    End

    For nx:= 1 to len(aTodos)
        cAlias := aTodos[nx, 1]
        aItens := aClone(aTodos[nx, 2])
        If ! GrvDif(cDir, cAlias, cEmp, cTipo,  {aCab, aItens})
            lErro := .t.
        EndIf 
    Next
    (cAliasX)->(DbGotop())

    MsgAlert("Arquivos gerados em " + cDir)
    If lErro
        MsgAlert("Erro na gravação de arquivo .dif, verifique os arquivo com extensão [.Erro]!")
    EndIf 

Return


Static Function GrvDif(cDir, cAlias, cEmp, cTipo, aDif)
    Local cArquivo := ""
    Local cMsg := ""
    Local cMsg2:= ""
    Local aAux := {}

    If Right(Alltrim(cDir), 1) != "\"
        cDir += "\"
    EndIf
    If ! ExistDir(cDir)
        MakeDir(cDir)
    Endif-
    
    cArquivo := cDir + cTipo + cEmp + cAlias + ".dif"

    cMsg := FwJsonSerialize(aDif)

    GrvArq(cArquivo, cMsg)

    cMsg2 := Alltrim(LeArq(cArquivo))
    FWJsonDeserialize(cMsg2, aAux)

    If ! Empty(aDif) .and. Empty(aAux)
        GrvArq(cDir + cTipo + cEmp + cAlias + ".erro", "Erro")
        Return .f.
    EndIf 

Return .t.


Static Function GrvArq(cArquivo,cLinha)
    If ! File(cArquivo)
        If (nHandle2 := MSFCreate(cArquivo,0)) == -1
            Return
        EndIf
    Else
        If (nHandle2 := FOpen(cArquivo,2)) == -1
            Return
        EndIf
    EndIf
    FSeek(nHandle2,0,2)
    FWrite(nHandle2,cLinha+CRLF)
    FClose(nHandle2)
Return

User Function LeArq(cArquivo)
Return LeArq(cArquivo)

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

Static Function FolderInsp(oFol, oSize)
    Local nB := oSize:GetDimension("PANEL", "LINEND")
    Local nR := oSize:GetDimension("PANEL", "COLEND")
    Local oBut
    Local oBut2
    LOcal oPanelM1
    Local oCheck
    Local oPnlInfI
    Local oPnlInfI2
    Local cFunInf := Space(30)
    Local cObjInf := Space(255)

    oPanelM1 := TPanelCss():New(,,,oFol)
    oPanelM1 :SetCoors(TRect():New( 0,0, 60, 60))
    oPanelM1 :Align := CONTROL_ALIGN_TOP

    @ 003, 002 SAY "Função:" of oPanelM1 SIZE 030, 09 PIXEL
    @ 003, 025 GET cFunInf   of oPanelM1 SIZE 060, 08 PIXEL
    @ 003, 090 BUTTON   oBut				PROMPT 'Pesquisar' SIZE 045,010 ACTION PesqFunc(cFunInf, oPnlInfI, oPnlInfI2) OF oPanelM1 PIXEL ; oBut:nClrText :=0
    @ 003, 150 CHECKBOX oCheck VAR lRPO	    PROMPT 'RPO'	   SIZE 030,010 OF oPanelM1 PIXEL
    @ 003, 180 CHECKBOX oCheck VAR lADVPL	PROMPT 'ADVPL'     SIZE 030,010 OF oPanelM1 PIXEL
    @ 003, 210 CHECKBOX oCheck VAR lClasse  PROMPT 'CLASSE'    SIZE 030,010 OF oPanelM1 PIXEL

    @ 18, 002 SAY "Objeto:" of oPanelM1 SIZE 030, 09 PIXEL
    @ 18, 025 GET  cObjInf  of oPanelM1 SIZE 255, 08 PIXEL
    @ 18, 290 BUTTON   oBut2				 PROMPT 'Pesquisar' SIZE 045,010 ACTION ObjInfo(cObjInf, oPnlInfI2)  OF oPanelM1 PIXEL           ; oBut2:nClrText :=0

    oPnlInfI:= TPanelCss():New(,,,oFol)
    oPnlInfI:SetCoors(TRect():New( 0,0, nB * 0.4 , nR * 0.5))
    oPnlInfI:Align :=CONTROL_ALIGN_ALLCLIENT

    oPnlInfI2:= TPanelCss():New(,,,oFol)
    oPnlInfI2:SetCoors(TRect():New( 0,0, nB * 0.4, nR * 0.5))
    oPnlInfI2:Align :=CONTROL_ALIGN_RIGHT

Return

Static Function ChkErr(oErroArq)
    Local ni:= 0

    If oErroArq:GenCode > 0
        cErroA := '(' + Alltrim( Str( oErroArq:GenCode ) ) + ') : ' + AllTrim( oErroArq:Description ) + CRLF
    EndIf
    ni := 2
    While ( !Empty(ProcName(ni)) )
        cErroA +=	Trim(ProcName(ni)) +"(" + Alltrim(Str(ProcLine(ni))) + ") " + CRLF
        ni++
    End

    Break
Return


Static Function PesqFunc(cFunc, oPnlInfI, oPnlInfI2)
    Local aType,aFile,aLine,aDate,aTime
    Local nCount
    Local aDados := {}
    Local aFuns  := {}
    Local aFields:= { 'Função','Tipo','Arquivo','Linha','Data','Hora'}

    If empty(cFunc)
        Return
    EndIf

    If empty(cFilAnt) .or. empty(cEmpAnt)
        MsgInfo("Ambiente Não Inicializado")
        Return
    EndIf

    If Type('oInfBrw')=='O'
        oInfBrw:DeActivate(.T.)
    EndIf
    oInfBrw := FWBrowse():New(oPnlInfI)
    oInfBrw:SetDataArray(.T.)
    oInfBrw:SetDescription("Info")
    oInfBrw:SetUpdateBrowse({||.T.})
    oInfBrw:SetEditCell(.T.,{||.F.})
    oInfBrw:SetDoubleClick({|o|BuscaPar(o, oPnlInfI2 )})
    oInfBrw:SetSeek()
    oInfBrw:SetUseFilter()
    oInfBrw:SetDBFFilter()

    aColunas := {}
    for nCount:= 1 to Len(aFields)
        oCol := FWBrwColumn():New()
        oCol:SetTitle(aFields[nCount])
        oCol:SetData(&("{|x|x:oData:aArray[x:At()]["+Str(nCount)+"]}"))
        aAdd(aColunas,oCol)
    next

    MsgRun("Buscando funções protheus.","Aguarde",{||aFuns := GetFuncArray(Alltrim(cFunc), aType, aFile, aLine, aDate, aTime)})

    If lADVPL
        For nCount := 1 To Len(aFuns)
            AAdd(aDados, { aFuns[nCount], aType[nCount], aFile[nCount], aLine[nCount], aDate[nCount], aTime[nCount]} )
        Next
    EndIf

    lComMask := '*'$cFunc

    cFunc := StrTran(cFunc,"*","")
    cFunc := Upper(AllTrim(cFunc))

    If Empty(aRet__Func)
        aRet__Func:= __FunArr()
    EndIf

    If Empty(aRet__Class)
        aRet__Class:= __ClsArr()
    EndIf

    If lComMask
        If lADVPL
            AEval(aRet__Func,{|x,y|If(Empty(cFunc) .Or. cFunc $ Upper(x[1]),AAdd(aDados, { x[1], "ADVPL", "", "", "", ""}),Nil)})
        EndIf
        If lClasse
            AEval(aRet__Class,{|x,y|If(Empty(cFunc) .Or. cFunc $ Upper(x[1]),AAdd(aDados, { x[1], "Classe", "", "", "", ""}),Nil)})
        EndIf
    Else
        If lADVPL
            If ( nCount := AScan(aRet__Func,{|x| cFunc == Upper(x[1])  }) ) > 0
                AAdd(aDados, { aRet__Func[nCount][1], "ADVPL", "", "", "", ""} )
            EndIf
        EndIf

        If lClasse
            If ( nCount := AScan(aRet__Class,{|x| cFunc == Upper(x[1])  }) ) > 0
                AAdd(aDados, { aRet__Class[nCount][1], "Classe", "", "", "", ""} )
            EndIf
        EndIf
    EndIf

    oInfBrw:SetColumns(aColunas)
    oInfBrw:SetArray(aDados)
    oInfBrw:Activate()
Return


Static Function BuscaPar(oObj, oPnlInfI2)

    Local cRet    := ""
    Local cRetPar := ""
    Local cPar    := ""
    Local nX  := 0
    Local nY := 0
    Local nZ := 0
    Local aRet2   := {}
    Local cNomeFunc := oObj:oData:aArray[oObj:At()][1]
    Local lAdvpl    := oObj:oData:aArray[oObj:At()][2] =="ADVPL"
    Local lClasse   := oObj:oData:aArray[oObj:At()][2] =="Classe"
    Local cChamada := 'Chamada: ' +CHR(9)+ cNomeFunc+'( '

    If lClasse
        nX := ascan(aRet__Class,{|x|cNomeFunc $ x[1]})
        cRetPar += 'Classe:' + aRet__Class[nx][1]+CRLF
        If !empty(aRet__Class[nx][2])
            cRetPar += 'Herdada de: ' + aRet__Class[nx][2]+CRLF
        EndIf

        If !empty(aRet__Class[nx][3])
            cRetPar += CRLF
            cRetPar += 'Variáveis: '+CRLF
            for nY:= 1 to Len(aRet__Class[nx][3])
                cRetPar += "   "+aRet__Class[nx][3][nY][1]+CRLF
            next
        EndIf

        If !empty(aRet__Class[nx][4])
            cRetPar += CRLF
            cRetPar += 'Métodos: '+CRLF
            for nY:= 1 to Len(aRet__Class[nx][4])
                cRetPar += "   "+aRet__Class[nx][4][nY][1]+CRLF

                If !empty(aRet__Class[nx][4][nY][2])
                    cRetPar += "    "+"Parâmetros:"+CRLF

                    For nZ:= 1 to len(aRet__Class[nx][4][nY][2]) step 2
                        cPar:=SubStr(aRet__Class[nx][4][nY][2],nZ,2)
                        Do Case
                        Case Left(cPar,1)=='*'
                            cRet:='xExp'+strZero((nZ+1)/2,2)+' - variavel'
                        Case Left(cPar,1)=='C'
                            cRet:='cExp'+strZero((nZ+1)/2,2)+' - caracter'
                        Case Left(cPar,1)=='N'
                            cRet:='nExp'+strZero((nZ+1)/2,2)+' - numerico'
                        Case Left(cPar,1)=='A'
                            cRet:='aExp'+strZero((nZ+1)/2,2)+' - array'
                        Case Left(cPar,1)=='L'
                            cRet:='lExp'+strZero((nZ+1)/2,2)+' - logico'
                        Case Left(cPar,1)=='B'
                            cRet:='bExp'+strZero((nZ+1)/2,2)+' - bloco de codigo'
                        Case Left(cPar,1)=='O'
                            cRet:='oExp'+strZero((nZ+1)/2,2)+' - objeto'
                        EndCase
                        If Right(cPar,1)=='R'
                            cRet+=' [obrigatorio]'
                        ElseIf Right(cPar,1)=='O'
                            cRet+=' [opcional]'
                        EndIf
                        cRetPar += "       "+cRet+CRLF
                    Next nZ

                EndIf
                cRetPar += CRLF
            next
        EndIf
    ElseIf lAdvpl
        nX := ascan(aRet__Func,{|x|cNomeFunc $ x[1]})
        If nX>0
            For nY := 1 to len(aRet__Func[nX][2]) step 2
                cPar := SubStr(aRet__Func[nX][2],nY,2)

                If Right(cPar,1)=='R'
                    cRet:= Chr(9)+' [obrigatorio]'
                ElseIf Right(cPar,1)=='O'
                    cRet:= Chr(9)+' [opcional]'
                EndIf

                Do Case
                Case Left(cPar,1)=='*'
                    cPar:= 'xExp'+strZero((nY+1)/2,2)
                    cRet:= cPar+' - variavel'+cRet
                Case Left(cPar,1)=='C'
                    cPar:= 'cExp'+strZero((nY+1)/2,2)
                    cRet:= cPar+' - caracter'+cRet
                Case Left(cPar,1)=='N'
                    cPar:= 'nExp'+strZero((nY+1)/2,2)
                    cRet:= cPar+' - numerico'+cRet
                Case Left(cPar,1)=='A'
                    cPar:= 'aExp'+strZero((nY+1)/2,2)
                    cRet:= cPar+' - array'+cRet
                Case Left(cPar,1)=='L'
                    cPar:= 'lExp'+strZero((nY+1)/2,2)
                    cRet:= cPar+' - logico'+cRet
                Case Left(cPar,1)=='B'
                    cPar:= 'bExp'+strZero((nY+1)/2,2)
                    cRet:= cPar+' - bloco de codigo'+cRet
                Case Left(cPar,1)=='O'
                    cPar:= 'oExp'+strZero((nY+1)/2,2)
                    cRet:= cPar+' - objeto'+cRet
                EndCase
                cChamada += cPar+', '
                cRetPar += "    Parametro " + cValtoChar((nY+1)/2) + " = " + cRet + CRLF

            Next nY
        EndIf
    Else
        aRet2:= GetFuncPrm(cNomeFunc)

        for nY:= 1 to Len(aRet2)
            cPar:= aRet2[nY]
            Do Case
            Case Left(cPar,1)=='X'
                cRet:=' - variavel'
            Case Left(cPar,1)=='C'
                cRet:=' - caracter'
            Case Left(cPar,1)=='N'
                cRet:=' - numerico'
            Case Left(cPar,1)=='A'
                cRet:=' - array'
            Case Left(cPar,1)=='L'
                cRet:=' - logico'
            Case Left(cPar,1)=='D'
                cRet:=' - data'
            Case Left(cPar,1)=='B'
                cRet:=' - bloco de codigo'
            Case Left(cPar,1)=='O'
                cRet:=' - objeto'
            OtherWise
                cRet:=' - Unknown'
            EndCase
            cChamada += cPar+', '
            cRetPar += "    Parametro " + cValtoChar(nY) + " = " + aRet2[nY]+cRet + CRLF
        Next
    EndIf

    If !lClasse
        If ','$cChamada
            cChamada := SubStr(cChamada,1,Len(cChamada)-2)
        EndIf
        cRetPar := cChamada +' )'+ CRLF + CRLF + cRetPar
    EndIf

    oGet:= tMultiget():new(,,bSETGET(cRetPar),oPnlInfI2)
    oGet:Align := CONTROL_ALIGN_ALLCLIENT

Return


Static Function ObjInfo(cObj, oPnlInfI2)
    Local aInfo:={}
    Local nX := 0
    Local nY := 0
    Local cRet:=''
    Local oObj
    Local cObjName:=''
    Local cRetPar :=''
    Local bErroA := ErrorBlock( { |oErro| ChkErr( oErro ) } )

    cErroA := ""

    cObj:= Alltrim(cObj)

    Begin Sequence

        If !('('$cObj)
            oObj:= &(cObj+'():New()')
        Else
            oObj:= &(cObj)
        EndIf

        If oObj!= Nil .and. ValType(oObj)=='O'
            cObjName:= Alltrim(Upper(GetClassName(oObj)))
            cRetPar += 'Objeto: '+cObjName
            aInfo:= ClassDataArr(oObj,.T.)
            cRetPar += CRLF
            cRetPar += "    "+"Variáveis:"+CRLF

            for nX:= 1 to Len(aInfo)
                cPar:= aInfo[nX][1]
                Do Case
                Case Left(cPar,1)=='*'
                    cRet:=' - variavel'
                Case Left(cPar,1)=='U'
                    cRet:=' - variavel'
                Case Left(cPar,1)=='C'
                    cRet:=' - caracter'
                Case Left(cPar,1)=='N'
                    cRet:=' - numerico'
                Case Left(cPar,1)=='A'
                    cRet:=' - array'
                Case Left(cPar,1)=='L'
                    cRet:=' - logico'
                Case Left(cPar,1)=='B'
                    cRet:=' - bloco de codigo'
                Case Left(cPar,1)=='O'
                    cRet:=' - objeto'
                OtherWise
                    cRet:=' - desconhecido'
                EndCase
                cRet:= "    " + strZero(nx,3)+ "= " + aInfo[nX][1]+cRet

                If !empty(aInfo[nX][4]) .and. Alltrim(aInfo[nX][4])!= cObjName
                    cRet:= cRet + Chr(9) + Chr(9) +" Herdado de: " + Alltrim(aInfo[nX][4])
                EndIf

                cRetPar += cRet+CRLF
            next

            aInfo:= ClassMethArr(oObj,.T.)

            for nX:= 1 to Len(aInfo)
                cRetPar += CRLF
                cRetPar += 'Método: '+aInfo[nX][1]+CRLF
                If !empty(aInfo[nX][2])
                    cRetPar += "    "+"Parâmetros:"+CRLF
                    for nY:= 1 to Len(aInfo[nX][2])
                        cPar:= aInfo[nX][2][nY]
                        Do Case
                        Case Left(cPar,1)=='*'
                            cRet:=' - variavel'
                        Case Left(cPar,1)=='U'
                            cRet:=' - variavel'
                        Case Left(cPar,1)=='C'
                            cRet:=' - caracter'
                        Case Left(cPar,1)=='N'
                            cRet:=' - numerico'
                        Case Left(cPar,1)=='A'
                            cRet:=' - array'
                        Case Left(cPar,1)=='L'
                            cRet:=' - logico'
                        Case Left(cPar,1)=='B'
                            cRet:=' - bloco de codigo'
                        Case Left(cPar,1)=='O'
                            cRet:=' - objeto'
                        OtherWise
                            cRet:=' - desconhecido'
                        EndCase
                        cRet:= "    Parametro " + strZero(nY,3)+ "= " + aInfo[nX][2][nY]+cRet
                        cRetPar += cRet+CRLF
                    next
                EndIf
            next

            FreeObj(oObj)
        Else
            cRetPar := CRLF+ 'Problemas na inicialização do Objeto.' + CRLF + 'Objeto Invalido.'
        EndIf
    End Sequence
    ErrorBlock( bErroA )

    If ! Empty(cErroA)
        cRetPar := "Classe não encontrada no RPO ou erro no momento de iniciar o objeto!  " + CRLF + CRLF + cErroA
    EndIf 

    oGet:= tMultiget():new(,,bSETGET(cRetPar), oPnlInfI2)
    oGet:Align := CONTROL_ALIGN_ALLCLIENT
Return


















