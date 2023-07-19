#INCLUDE "totvs.ch"

User Function zGatServ()
    Local cGatilho
        if  M->B1_GRUPO == "001 " .OR. ;
            M->B1_GRUPO == "002 " .OR. ;
            M->B1_GRUPO == "004 " .OR. ;
            M->B1_GRUPO == "005 " .OR. ;
            M->B1_GRUPO == "006 " .OR. ;
            M->B1_GRUPO == "007 " .OR. ;
            M->B1_GRUPO == "008 " .OR. ;
            M->B1_GRUPO == "013 " .OR. ;
            M->B1_GRUPO == "015 " .OR. ;
            M->B1_GRUPO == "016 " .OR. ;
            M->B1_GRUPO == "017 " .OR. ;
            M->B1_GRUPO == "020 " .OR. ;
            M->B1_GRUPO == "021 " .OR. ;
            M->B1_GRUPO == "023 " .OR. ;
            M->B1_GRUPO == "034 " .OR. ;
            M->B1_GRUPO == "035 " .OR. ;
            M->B1_GRUPO == "037 " .OR. ;
            M->B1_GRUPO == "038 " .OR. ;
            M->B1_GRUPO == "039 " .OR. ;
            M->B1_GRUPO == "040 " .OR. ;
            M->B1_GRUPO == "041 " .OR. ;
            M->B1_GRUPO == "042 " .OR. ;
            M->B1_GRUPO == "043 " .OR. ;
            M->B1_GRUPO == "045 " .OR. ;
            M->B1_GRUPO == "046 " .OR. ;
            M->B1_GRUPO == "047 " .OR. ;
            M->B1_GRUPO == "048 " .OR. ;
            M->B1_GRUPO == "049 " .OR. ;
            M->B1_GRUPO == "052 " .OR. ;
            M->B1_GRUPO == "054 " .OR. ;
            M->B1_GRUPO == "063 " .OR. ;
            M->B1_GRUPO == "064 "
            cGatilho := "SV"
        endif
    
RETURN cGatilho
