#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

User Function testedejson()//U_testedejson
    //local aArray := StrTokArr( GetMV("Parâmetro separado por ponto e virgula"), ";" )
    

    local cLink := "http://localhost/erp/Logistica/PerfilNFEntradaDevolucaoAlterar.asp?Cod=5779"
    ShellExecute("Open", cLink, "", "", 1)
  /*
    if AScan( aArray , {|x| x == Valor_procurado })
        alert('success','success')
    end if 
    */
    
    

Return 
