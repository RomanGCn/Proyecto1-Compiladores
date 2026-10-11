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
    int clase;
    int valor;
} Token;

Token tokens[1000];
int   num_tokens = 0;

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
int numSimb = 0; /* este es un contador de identificadores insertados. Su valor actual es la siguiente posición disponible. Este arranca en 0 */
/* -------------------------------------------------------------------------- */
/* Para la tabla de literales */
typedef struct NodoLit{
	int	pos; /* posición asignada al insertar, valor de token */
	char cadena[200]; /* la cadena literal, completa e incluyendo comillas */
	struct NodoLit *izq;
	struct NodoLit *der;
} NodoLit;

NodoLit *raizLit = NULL;
int numLit = 0;
/* Es igual a la estructura del BSF para la tabla de simbolos */
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/* Funciones del árbol de busqueda para símbolos */
/* -------------------------------------------------------------------------- */

/* buscarSimb es una función que tiene como entradas la raíz del arbol o subarbol y nombre a buscar
mientras que sus salidas tiene un apuntador que contiene el nombre o NULL si no existe. La lógica es así:
1. Si el árbol esta vacío no existe y regresa NULL.
2. Si no lo está, compara el nombre buscándolo en el nodo actual:
	2.1. Si son iguales se encuentra y regresa el nodo.
	2.2. Si es menor baja al subárbol izquierdo.
	2.3. Si es mayor sube al subárbol derecho. */

NodoSimb* buscarSimb(NodoSimb *raiz, char *nombre){
	if (raiz == NULL) return NULL; /* Caso base donde esta vacío, no existe. */
	int cmp = strcmp(nombre, raiz -> nombre); /* Compara el nombre buscándolo con el nodo actual. */
	if (cmp == 0) return raiz; /* Si son iguales, aquí se encuentra. */
	if (cmp < 0) return buscarSimb(raiz -> izq, nombre); /* Si el buscado es menor, busca en el subárbol izquierdo */
	return buscarSimb(raiz -> der, nombre); /* Si el buscado es mayor, busca en el subárbol derecho*/
}
/* -------------------------------------------------------------------------- */

/*insertarSimb es una función que tiene como entradas la raíz del árbol, nombre a insertar y apuntador al contador 
numSimb pues este lo actualiza, mientras que sus salidas posiblemente es la raíz del árbol el cuál puede ser modificado.
Su lógica es:
1. Si el árbol esta vacío, crea un nuevo nodo con:
	- nombre copiado
	- tipo = -1 (aún no se sabe)
	- pos = (*pos)++ se asigna para luego incrementarse
	- izq = der = NULL y regresa el nodo nuevo
2. Si el nombre es menor que el actual, entonces se inserta en izquierdo
3. Si el nombre es mayor que el actual, entonces se inserta en derecha
4. Si el nombre es igual, no se va a insertar pues ya existe, el árbol no cambia aquí.*/

NodoSimb* insertarSimb(NodoSimb *raiz, char *nombre, int *pos){
	/*Casoo base, hoja vacía y nuevo nodo*/
	if (raiz == NULL) {
		/*Reservamos memoria para el nodo*/
		NodoSimb *nuevo = (NodoSimb*) malloc(sizeof(NodoSimb));
		/*Copiar el nombre del nodo*/
		strcpy(nuevo->nombre, nombre);
		/*Se inicializa el tipo en -1*/
		nuevo->tipo = -1;
		/*Asigna la siguiente posición y luego incrementa*/
		nuevo->pos = (*pos)++;
		/*Nodo recien creado sin hijos*/
		nuevo->izq = NULL;
		nuevo->der = NULL;
		/*Regresa el nodo nuevo el cuál se convierte en hoja*/
		return nuevo;
	}
	/*Compara nombre nuevo con el nodo actual*/
	int cmp = strcmp(nombre, raiz->nombre);
	/*Si este es menor, inserta en el subárbol izquierdo*/
	if(cmp<0)
		raiz->izq = insertarSimb(raiz->izq, nombre, pos);
	/*Si este es mayor, inserta en el subárbol derecho*/
	else if(cmp>0)
		raiz->der = insertarSimb(raiz->der, nombre, pos);
	/*Si es que cmp es igual a 0, el identificador ya existe, 
	entonces regresa la raíz sin cambios*/
	return raiz;
}

/* -------------------------------------------------------------------------- */
/*inOrdenSimb es una función que hace un recorrido en orden: izquierda -> raíz -> derecha
este recorrido produce elementos ordenados alfabeticamente. Su entrada es la raíz del arbol
y un archivo destino, su salida solamente escribe directamente al archivo.*/

void inOrdenSimb (NodoSimb *raiz, FILE *f){
	/*Caso base, árbol vacío sin nada que escribir*/
	if(raiz == NULL) return;
	/*Recorrido del subárbol izquierdo*/
	inOrdenSimb(raiz->izq, f);
	/*Imprime el nodo actual*/
	fprintf(f, "%d\t%s\t%d\n", raiz->pos, raiz -> nombre, raiz -> tipo);
	/*Recorrido del subárbol derecho*/
	inOrdenSimb(raiz->der, f);
}
/* -------------------------------------------------------------------------- */
/* Funciones del árbol de busqueda para literales */
/* -------------------------------------------------------------------------- */
/*insertarLit se hizo bajo la misma idea que insertarSimb pero ahora, para cadenas.
La diferencia clave radica que aquí sí se permiten duplicados ya que las cadenas se
insertan sin verificar. Se usa cmp <= 0 para que las cadenas repetidas se vayan al subárbol izquierdo y queden juntas.
Las entradas son la raíz, cadena y apuntador al contador numLit, mientras que las salidas
es la raíz del árbol actualizada.*/

NodoLit* insertarLit(NodoLit *raiz, char *cadena, int *pos){
	/*Caso base: crear nodo nuevo*/
	if(raiz == NULL){
		NodoLit *nuevo = (NodoLit*) malloc(sizeof(NodoLit));
		strcpy(nuevo -> cadena, cadena);
		nuevo -> pos = (*pos)++;
		nuevo -> izq = NULL;
		nuevo -> der = NULL;
		return nuevo;
	}
	/*Comparar cadena nueva con la del nodo actual*/
	int cmp = strcmp(cadena, raiz->cadena);
	/*Si es menor o igual, va a la izquierda.
	Lo que hace el <= permite que las cadenas duplicadas se agrupen.*/
	if(cmp <= 0)
		raiz->izq = insertarLit(raiz->izq, cadena, pos);
	/*Si es mayor, va a la derecha.*/
	else
		raiz->der = insertarLit(raiz->der, cadena, pos);
	return raiz;
}
/* -------------------------------------------------------------------------- */
/*inOrdenLit, es una función que es igual a inOrdenSimb pero para el árbol de literales.
Sus entradas son la raíz del arbol y archivo destino, mientras que su salida solamente
es escribir el archivo.*/

void inOrdenLit(NodoLit *raiz, FILE *f){
	/*Caso base.*/
	if(raiz == NULL) return;
	/*1. Subarbol izquierdo*/
	inOrdenLit(raiz->izq, f);
	/*2. Nodo actual*/
	fprintf(f, "%d\t%s\n", raiz->pos, raiz->cadena);
	/*Subárbol derecho*/
	inOrdenLit(raiz->der, f);
}
%}
/* -------------------------------------------------------------------------- */



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
    NodoSimb *n = buscarSimb(raizSimb, yytext);
    int pos;
    if(n == NULL){
        raizSimb = insertarSimb(raizSimb, yytext, &numSimb);
        pos = numSimb - 1;
    } else {
        pos = n->pos;
    }
    tokens[num_tokens].clase = 5;
    tokens[num_tokens].valor = pos;
    num_tokens++;
    printf("Token (5, %d)  <- %s\n", pos, yytext);
}
{simbolos}  {            /* 6. Simbolos epeciales --------------------------- */
    
}
{op_asignacion} {        /* 7. Operadores de asignacion ------------------- */
    
}
{cte_cadena}    {       /* 8. Constantes cadenas ---------------------------*/

    raizLit = insertarLit(raizLit, yytext, &numLit);
    int pos = numLit - 1;
    tokens[num_tokens].clase = 8;
    tokens[num_tokens].valor = pos;
    num_tokens++;
    printf("Token (8, %d)  <- %s\n", pos, yytext);
  
}
{op_cadena}     {       /* 9. Operadores sobre cadena -------------------  */
    
}
[ \t\n]+          /* Come espacios */
.       {
    printf("Caracter no reconocido: '%s'\n", yytext);
}
%%

// ------------------------------------------------------------------------------------------- Código
// Definicion de estructuras
// Tokens ---------
// Catálogos
// Tabla de símbolos -------------
int main(int argc, char **argv) {
    int i;    
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
    /* ---------- Tabla de simbolos ---------- */
    printf("\n-------------- TABLA DE SIMBOLOS --------------\n");
    printf("Pos\tNombre\tTipo\n");
    inOrdenSimb(raizSimb, stdout);
    /* ---------- Tabla de literales ---------- */
    printf("\n-------------- TABLA DE LITERALES --------------\n");
    printf("Pos\tCadena\n");
    inOrdenLit(raizLit, stdout);
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
