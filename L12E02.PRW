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


/*/{Protheus.doc} User Function L12E02
    Fun��o para cria��o de planilha em XLS do Excel com informa��es de Produtos
    @type  Function
    @author Edison Cake
    @since 20/04/2023
    /*/
User Function L12E02()
    local oExcel := FwMsExcelEx():New()
    local cPath     := "C:\Users\ediso\Desktop\"
    local cFile     := "Relatorio_Produtos.xls"

    local aDados    := {}
    local cAlias    := GetNextAlias()
    local aArea     := GetArea()
    local cQuery    := ""

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' TABLES 'SB1' MODULO 'COM'

    cQuery := "SELECT B1_COD, B1_DESC, B1_TIPO, B1_UM, B1_PRV1, D_E_L_E_T_ AS DEL FROM " + RetSqlName("SB1")
    TCQUERY cQuery ALIAS &(cAlias) NEW

    oExcel:AddWorkSheet("Produtos")
    oExcel:AddTable("Produtos", "Informa��es")

    oExcel:AddColumn("Produtos", "Informa��es", "C�digo", LEFT, GENERAL)
    oExcel:AddColumn("Produtos", "Informa��es", "Descri��o", LEFT, GENERAL)
    oExcel:AddColumn("Produtos", "Informa��es", "Tipo", LEFT, GENERAL)
    oExcel:AddColumn("Produtos", "Informa��es", "U.M.", LEFT, GENERAL)
    oExcel:AddColumn("Produtos", "Informa��es", "Pre�o", RIGHT, MONEY)

    oExcel:SetCelFrColor("#DC143C")

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    While (cAlias)->(!EoF())
        
        aAdd(aDados, alltrim((cAlias)->(B1_COD)))
        aAdd(aDados, alltrim((cAlias)->(B1_DESC)))
        aAdd(aDados, alltrim((cAlias)->(B1_TIPO)))
        aAdd(aDados, alltrim((cAlias)->(B1_UM)))
        aAdd(aDados, (cAlias)->(B1_PRV1))

        if (cAlias)->(DEL) == "*"
            oExcel:AddRow("Produtos", "Informa��es", aDados, {1, 2, 3, 4, 5})
        else

            oExcel:AddRow("Produtos", "Informa��es", aDados)
        endif

        aDados := {}
        (cAlias)->(DbSkip())

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
