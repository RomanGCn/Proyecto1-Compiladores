/***
Proyecto 1. Analizador léxico
Compiladores Gpo 1

Cano Roman Giselle
Téllez Mendoza Eunice Abigail
Velázquez Villegas Fabricio
**/


// Definiciones
%{
#include <stdio.h>

// para pruebas, cuenta el numero de clases encontrados
int nOpArit, nOpLog, nOpRel, nOpAsig, nOpCad  = 0;
int nCteNum, nPalRes, nIds, nSim, nCteCad = 0;

%}

// ---------------------------------------------------- Reglas
op_aritmeticos "+"|"-"|"*"|"/"|"%"

op_logico "&&"|"||"|"!"

op_rel ((">"|"<"|"!"|"=")"=")|(">"|"<")

cte_ent 0|[1-9][0-9]*|"("("+"|"-")[1-9][0-9]*")"

palRes assinado|caso|enquanto|fazer|flutuador|inteiro|para|quebrar|retorno|se|trocar

identificador "_"([a-z]|[A-Z])([a-z]|[A-Z]|[0-9])*"_"

simbolos \(|\)|\{|\}|\;|\,|\[|\]|\:|# 

op_asignacion "="|("+"|"-"|"*"|"/"|"%")"="

cte_cadena \"[^\"]*\"

op_cadena "&"|like

// -------------------------------------------------------------------- Codigo sobre las reglas
%%

{op_aritmeticos}    { /* 0. Operadores aritmeticos -------------------------- */
    printf("Operador aritmetico encontrado: '%s'\n", yytext);
    nOpArit++;
}

{op_logico} {          /* 1. Operadores logicos ----------------------------- */
    printf("Operador logico encontrado: '%s'\n", yytext);
    nOpLog++;
}

{op_rel}    {          /* 2. Operadores relacionales ------------------------- */
    printf("Operador relacional encontrado: '%s'\n", yytext);
    nOpRel++;
}

{cte_ent} {              /* 3. Constantes enteras ---------------------------- */
    printf("Constante entera encontrada: '%s'\n", yytext);
    nCteNum++;
}

{palRes}    {         /* 4. Palabras reservadas ---------------------------- */
    printf("Palabra Reservada encontrada: '%s'\n", yytext);
    nPalRes++;
}

{identificador} {      /* 5. Identificadores -------------------------------- */
    printf("Identificador encontrado: '%s'\n", yytext);
    nIds++;
}

{simbolos}  {            /* 6. Simbolos epeciales --------------------------- */
    printf("Simbolo especial encontrado: '%s'\n",yytext);
    nSim++;
}

{op_asignacion} {        /* 7. Operadores de asignacion ------------------- */
    printf("Operador de asignacion encontrado: '%s'\n", yytext);
    nOpAsig++;
}

{cte_cadena}    {       /* 8. Constantes cadenas ---------------------------*/
    printf("Constante cadena encontrada: '%s'\n", yytext);
    nCteCad++;
}

{op_cadena}     {       /* 9. Operadores sobre cadena -------------------  */
    printf("Operador de cadena encontrado: '%s'\n", yytext);
    nOpCad++;
}

[ \t\n]+          /* Come espacios */
.       {
    printf("Caracter no reconocido: '%s'\n", yytext);
}
%%

int yywrap(){}

int main(){

    //entrada por archivo
    FILE *fp;
    char filename[50];
    printf("Enter the filename: \n");
    scanf("%s",filename);
    fp = fopen(filename,"r");
    yyin = fp;

    yylex();
    

    // para pruebas, muestra en pantalla el numero total de las clases encontradas
    printf("\n");
    printf("Numero de op aritmeticos - %d\n", nOpArit); //0
    printf("Numero de op logicos - %d\n", nOpLog); //1
    printf("Numero de op relacionales - %d\n", nOpRel); //2
    printf("Numero de cte enteras - %d\n", nCteNum); //3
    printf("Numero de palabras reservadas - %d\n", nPalRes); //4
    printf("Numero de identificadores - %d\n", nIds); //5
    printf("Numero de simbolos - %d\n", nSim); //6
    printf("Numero de op asignacion - %d\n", nOpAsig); //7
    printf("Numero de cte cadenas - %d\n", nCteCad); //8
    printf("Numero de op cadena - %d\n", nOpCad); //9
    
return 0;
}



