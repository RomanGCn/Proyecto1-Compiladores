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

typedef struct {
    int posicion;
    char nombre[100];
    int tipo; 
} Simbolo;

typedef struct {
    int posicion;
    char dato[255];
} Literal;      //cadenas

typedef struct {
    int clase;
    int valor;
} Token;

Simbolo tabla_simbolos[200];
int num_simbolos = 0;

Literal tabla_literales[200];
int num_literales = 0;

Token tokens[1000];
int num_tokens = 0;


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


int main(int argc, char **argv) {
    
    if(argc > 1) {
        yyin = fopen(argv[1], "r");
        if(!yyin) {
            printf("Error al abrir el archivo %s\n", argv[1]);
            return 1;
        }
        printf("Analizando el archivo: %s\n\n", argv[1]);
    } else {
        printf("Error: Falta el archivo de entrada.\n");
        return 1;
    }

    yylex();
    fclose(yyin);// cierra archivo

    int i=0;    
    printf("\n-------------- TABLA DE SÍMBOLOS --------------\n");
    printf("Posicion\t  Tipo    \tNombre    \n");
    for( i = 0; i < num_simbolos; i++) {
        printf("%d\t\t%d\t%s\n", tabla_simbolos[i].posicion, tabla_simbolos[i].tipo, tabla_simbolos[i].nombre);
    }

    printf("\n");
    printf("\n-------------- TABLA DE LITERALES --------------\n");
    printf("Posicion\tCadena\n");
    for( i = 0; i < num_literales; i++) {
        printf("%d\t\t%s\n", tabla_literales[i].posicion, tabla_literales[i].dato);
    }

    printf("\n");
    printf("\n-------------- TOKENS GENERADOS --------------\n");
    printf("Clase\t\tValor\n");
    for( i = 0; i < num_tokens; i++) {
        if(tokens[i].clase == 0 || tokens[i].clase == 6) {
            printf("%d\t\t%d ('%c')\n", tokens[i].clase, tokens[i].valor, (char)tokens[i].valor);
        } else {
            printf("%d\t\t%d\n", tokens[i].clase, tokens[i].valor);
        }
    }

    return 0;
}



