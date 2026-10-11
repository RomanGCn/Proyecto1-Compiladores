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
#include <stdlib.h> 
/*Se agrega para funciones de gestión de memoria (malloc para darle memoria a los nodos, 
atoi que convierte cadenas a entero y exit por si se necesita abortar).*/
#include <string.h> 
/*Se agrega para manipulación de cadenas (strcmp para comparar dos cadenas siendo base para el árbol,
strcpy que copia cadenas a nodos y strlen para longitud).*/

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

/* -------------------------------------------------------------------------- */
/* Arbol de búsqueda binaria, tabla de simbolos y literales */
/* -------------------------------------------------------------------------- */
/* Para la tabla de simbolos */
typedef struct NodoSimb{ 
	int	pos; /* valor que se le asigna al token */
	char	nombre[100]; /*cadena con el */
	int	tipo; 
	struct NodoSimb *izq;
	struct NodoSimb *der;
} NodoSimb;

NodoSimb *raizSimb = NULL; /* apunta al nodo raíz del arbol y al estar vacío se iguala a NULL*/
int numbSimb = 0; /* este es un contador de identificadores insertados. Su valor actual es la siguiente posición disponible. Este arranca en 0 */
/* -------------------------------------------------------------------------- */
/* Para la tabla de literales */
typedef struct NodoLit{
	int	pos; /* posición asignada al insertar, valor de token */
	char cadena[200]; /* la cadena literal, completa e incluyendo comillas */
	struct NodoLit *izq;
	struct NodoLit *der;
}

NodoLit *raizLit = NULL;
int numLit = 0;
/* Es igual a la estructura del BSF para la tabla de simbolos */
/* -------------------------------------------------------------------------- */

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



