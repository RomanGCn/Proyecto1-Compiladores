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
    
}

{op_logico} {          /* 1. Operadores logicos ----------------------------- */
    
}

{op_rel}    {          /* 2. Operadores relacionales ------------------------- */
    
}

{cte_ent} {              /* 3. Constantes enteras ---------------------------- */
    
}

{palRes}    {         /* 4. Palabras reservadas ---------------------------- */
    
}

{identificador} {      /* 5. Identificadores -------------------------------- */
    
}

{simbolos}  {            /* 6. Simbolos epeciales --------------------------- */
    
}

{op_asignacion} {        /* 7. Operadores de asignacion ------------------- */
    
}

{cte_cadena}    {       /* 8. Constantes cadenas ---------------------------*/
    
}

{op_cadena}     {       /* 9. Operadores sobre cadena -------------------  */
    
}

[ \t\n]+          /* Come espacios */
.       {
    printf("Caracter no reconocido: '%s'\n", yytext);
}

%%
int yywrap(){}
// ------------------------------------------------------------------------------------------- Código
// Definicion de estructuras

// Tokens ---------


// Catálogos


// Tabla de símbolos -------------

int main(){

    //entrada por archivo
    FILE *fp;
    char filename[50];
    printf("Enter the filename: \n");
    scanf("%s",filename);
    fp = fopen(filename,"r");
    yyin = fp;

    yylex();
    
return 0;
}



