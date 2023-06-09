#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'

#DEFINE LEFT 1
#DEFINE CENTER 2
#DEFINE RIGHT 3

#DEFINE GENERAL 1
#DEFINE NUMERIC 2
#DEFINE MONEY 3
#DEFINE DATETIME 4

/*/{Protheus.doc} User Function GetCurso
    Relat�rio em .xls gerado a partir de um bot�o na rotina em MVC de cadastro de cursos x alunos (MYMVC2).
    @type  Function
    @author Edison Cake
    @since 20/04/2023
    /*/
User Function GetCurso()
    local oExcel := FwMsExcelEx():New()
    local cPath     := "C:\Users\ediso\Desktop\"
    local cFile     := "Relatorio_Cursos.xls"

    local aDados    := {}
    local cAlias    := GetNextAlias()
    local aArea     := GetArea()
    local cQuery    := ""
    local cIdCurso  := ""
    local cCurso    := ""

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' TABLES 'ZZC' MODULO 'COM'

    cQuery := "SELECT ZZC.ZZC_CODIGO, ZZC.ZZC_CURSO, ZZB.ZZB_CURSO, ZZB.ZZB_COD, ZZB.ZZB_NOME, ZZB.ZZB_DTINIC, ZZB.D_E_L_E_T_ AS DEL1, ZZC.D_E_L_E_T_ AS DEL2 FROM " + RetSqlName("ZZC") + " ZZC INNER JOIN " + RetSqlName("ZZB") + " ZZB ON ZZC.ZZC_CODIGO = ZZB.ZZB_CURSO AND ZZB.D_E_L_E_T_ = ZZC.D_E_L_E_T_ WHERE ZZB.D_E_L_E_T_ = ' '"
    TCQUERY cQuery ALIAS &(cAlias) NEW

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    While (cAlias)->(!EoF())
        if cIdCurso != alltrim((cAlias)->(ZZC_CODIGO))
            
            cIdCurso := alltrim((cAlias)->(ZZC_CODIGO))
            cCurso := alltrim((cAlias)->(ZZC_CURSO))
            oExcel:AddWorkSheet(cCurso)
            oExcel:AddTable(cCurso, "Informa��es do Aluno")

            oExcel:AddColumn(cCurso, "Informa��es do Aluno", "C�digo", LEFT, GENERAL)
            oExcel:AddColumn(cCurso, "Informa��es do Aluno", "Nome", LEFT, GENERAL)
            oExcel:AddColumn(cCurso, "Informa��es do Aluno", "Dt. Inicio", CENTER, DATETIME)
        endif

        aAdd(aDados, alltrim((cAlias)->(ZZB_COD)))
        aAdd(aDados, alltrim((cAlias)->(ZZB_NOME)))
        aAdd(aDados, StoD((cAlias)->(ZZB_DTINIC)))

        oExcel:AddRow(cCurso, "Informa��es do Aluno", aDados)

        (cAlias)->(DbSkip())
        aDados := {}
    End do

    RestArea(aArea)
    oExcel:Activate()

    oExcel:GetXMLFile(cPath + cFile)

    if ApOleClient("MsExcel")

        oExec := MsExcel():New()
        oExec:WorkBooks:Open(cPath + cFile)
        oExec:SetVisible(.T.)
        oExec:Destroy()
    else
        FwAlertError("Arquivo n�o encontrado no Windows", "Excel n�o encontrado!")
    endif

    oExcel:DeActivate()
Return 
