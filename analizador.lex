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
/*Se agrega para funciones de gestión de memoria (malloc y realloc para memoria dinamica, 
atoi que convierte cadenas a entero y exit por si se necesita abortar).*/
#include <string.h> 
/*Se agrega para manipulación de cadenas (strcmp para comparar dos cadenas,
strcpy que copia cadenas a nodos y strlen para longitud).*/

/* -------------------------------------------------------------------------- */
/* Lista de tokens	- Roman */
/* -------------------------------------------------------------------------- */
int (*lTokens)[2];  //puntero a un array de 2 ints, cada columna es un token
int numTokens = 0;     //tamaño de la lista de tokens
/*
	Ejemplo
	ltokens = { {1,2}, {3,2} };
    en tabla:
            | t1    | t2    | ...
    -----------------------------------
    clase   | 1     | 3     | ...
    ----------------------------------
    valor   | 2     | 2     | ...
*/
// ------------------------------------------------------------ Catalogos
// Palabras reservadas
static const char *cat_PalRes[] = {"assinado", "caso", "enquanto", "fazer", "flutuador",
    "inteiro", "para", "quebrar", "retorno", "se", "trocar"};
static const int size_cat_PalRes = 11;
// Operadores logicos
static const char *cat_OpLog[] = {"&&", "||", "!"};
static const int size_cat_OpLog = 3;
// Operadores relacionales
static const char *cat_OpRel[] = {"==", "!=", ">", "<", ">=", "<="};
static const int size_cat_OpRel = 6;
// Operadores de asignacion
static const char *cat_OpAsig[] = {"=", "+=", "-=", "*=", "/=", "%="};
static const int size_cat_OpAsig = 6;
// Operadores sobre cadenas
static const char *cat_OpCad[] = {"&", "like"};
static const int size_cat_OpCad = 2;
// Simbolos especiales
static const char cat_Simbolos[] = {
    '#', '%', '(', ')', '*', '+', ',', '-', '/', ':', ';', '[', ']', '{', '}'};
static const int size_cat_SimASCII = 15;
// Equivalente en ASCII
static const int cat_ASCII[] = {
    35, 37, 40, 41, 42, 43, 44, 45, 47, 58, 59, 91, 93, 123, 125};

// ----------------------------------------------- Prototipos de Funciones Tokens
// Inserta en la lista de tokens un token con su clase y valor
void insertToken(int (**lTokens)[2], int *numTokens, int class, int val_pos, char *simbolo);

// Usado en la insercion, devuelve el valor del token 
int tokenizeValue(int classs, int_ val_pos, char *str);


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
/* Prototipos de funciones */
/* -------------------------------------------------------------------------- */
/* Para la tabla de simbolos */
NodoSimb* buscarSimb(NodoSimb *raiz, char *nombre);
NodoSimb* insertarSimb(NodoSimb *raiz, char *nombre, int *pos);
void inOrdenSimb (NodoSimb *raiz, FILE *f);

/* -------------------------------------------------------------------------- */
/* Para la tabla de literales */
NodoLit* insertarLit(NodoLit *raiz, char *cadena, int *pos);
void inOrdenLit(NodoLit *raiz, FILE *f);

%}
/* -------------------------------------------------------------------------- */

/* ----------------------------------------------------------------------------------------------- */
/* --------------                           Analizador                         ------------------ */
/* ----------------------------------------------------------------------------------------------- */

/* -----------------------------------------------------------------   Reglas */
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

/* ---------------------------------------------------- Operaciones sobre reglas */
%%
{op_aritmeticos}    { /* 0. Operadores aritmeticos -------------------------- */
    int class = 0; //clase del token
    insertToken(&lTokens, &numTokens, class, 0, yytext); //inserta el token en la lista de tokens
}
{op_logico} {          /* 1. Operadores logicos ----------------------------- */
    int class = 1; //clase del token
    insertToken(&lTokens, &numTokens, class, 0, yytext); //inserta el token en la lista de token
}
{op_rel}    {          /* 2. Operadores relacionales ------------------------- */
    int class = 2; //clase del token
    insertToken(&lTokens, &numTokens, class, 0, yytext); //inserta el token en la lista de token
}
{cte_ent} {              /* 3. Constantes enteras ---------------------------- */
    int class = 3; //clase del token
    int val_pos; //valor del token
    char *str; //cadena del token
    int i; //para recorrer la cadena
    
    if (yytext[0] == '(') { //si tiene signos
        if (yytext[1] == '+'){ //si tiene signo positivo
            //recorre la cadena sin los primeros 2 y ultimo caracter, quitando los parentesis
            for(i=0; i<(strlen(yytext)-3); i++){ 
                str[i] = yytext[i+2];
            }
        } else {
            //recorre la cadena sin el primer y ultimo caracter, quitando los parentesis
            for(i=0; i<(strlen(yytext)-2); i++){ 
                str[i] = yytext[i+1];
            }
        }
        val_pos = atoi(str);    // convierte la cadena limpia a entero

    } else { //si no tiene signos
        val_pos = atoi(yytext); // convierte la cadena dada a entero
    }

    insertToken(&lTokens, &lenght, class, val_pos, yytext); //inserta el token en la lista de tokens

}
{palRes}    {         /* 4. Palabras reservadas ---------------------------- */
    int class = 4; //clase del token
    insertToken(&lTokens, &numTokens, class, yytext); //inserta el token en la lista de tokens
}
{identificador} {      /* 5. Identificadores -------------------------------- */
    int class = 5; //clase del token
	NodoSimb *n = buscarSimb(raizSimb, yytext);
    int pos;

    if(n == NULL){
        raizSimb = insertarSimb(raizSimb, yytext, &numSimb);
        pos = numSimb - 1;
    } else {
        pos = n->pos;
    }

	insertToken(&lTokens, &numTokens, class, pos, yytext); //inserta el token en la lista de tokens
}
{simbolos}  {            /* 6. Simbolos epeciales --------------------------- */
    int class = 6; //clase del token
    insertToken(&lTokens, &numTokens, class, 0, yytext); //inserta el token en la lista de tokens
}
{op_asignacion} {        /* 7. Operadores de asignacion ------------------- */
    int class = 7; //clase del token
    insertToken(&lTokens, &numTokens, class, 0, yytext); //inserta el token en la lista de tokens
}
{cte_cadena}    {       /* 8. Constantes cadenas ---------------------------*/
	int class = 8; //clase del token
    raizLit = insertarLit(raizLit, yytext, &numLit);
    int pos = numLit - 1;

	insertToken(&lTokens, &numTokens, class, pos, yytext); //inserta el token en la lista de tokens  
}
{op_cadena}     {       /* 9. Operadores sobre cadena -------------------  */
    int class = 9; //clase del token
    insertToken(&lTokens, &numTokens, class, 0, yytext); //inserta el token en la lista de tokens
}
[ \t\n]+          /* Come espacios */
.       {
    printf("Caracter no reconocido: '%s'\n", yytext);
}
%%

int yywrap(){} //ENVUELVE EN ANALIZADOR PARA SER USADO

/* ----------------------------------------------------------------------------------------------- */
/* --------------                            Codigo                            ------------------ */
/* ----------------------------------------------------------------------------------------------- */

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

    lTokens = malloc(sizeof(int[1][2]));//cambio de double a int
    if(!lTokens){
        printf("Error de memoria\n");
        return -1; 
    }

    yylex();	// corre el analizador

    fclose(yyin);// cierra archivo

    FILE *archivo = fopen("salida.txt", "w");
    if (archivo == NULL) {
        printf("Error al abrir archivo para la salida\n");
        return 1;
    }

    /* ---------- Tabla de simbolos ---------- */
    printf("\n-------------- TABLA DE SIMBOLOS --------------\n");
    fprintf(archivo, "\n-------------- TABLA DE SIMBOLOS --------------\n");
    printf("Pos\tNombre\tTipo\n");
    fprintf(archivo, "Pos\tNombre\tTipo\n");
    inOrdenSimb(raizSimb, stdout);
    inOrdenSimb(raizSimb, archivo);

    // Tabla de Literales
    printf("\n-------------- TABLA DE LITERALES --------------\n");
    fprintf(archivo, "\n-------------- TABLA DE LITERALES --------------\n");
    printf("Pos\tCadena\n");
    fprintf(archivo, "Pos\tCadena\n");
    inOrdenLit(raizLit, stdout);
    inOrdenLit(raizLit, archivo);
    printf("\n");

    printf("\n-------------- TOKENS GENERADOS --------------\n");
    fprintf(archivo, "\n-------------- TOKENS GENERADOS --------------\n");
    printf("Clase\t  \tValor\n");
    fprintf(archivo, "Clase\t  \tValor\n");
    
    for(i = 0; i < numTokens; i++) {
        int clase = lTokens[i][0];
        int valor = lTokens[i][1];
        
        if(clase == 0 || clase == 6) {
            printf("%d\t\t%d ('%c')\n", clase, valor, (char)valor);
            fprintf(archivo, "%d\t\t%d ('%c')\n", clase, valor, (char)valor);
        } else {
            printf("%d\t\t%d\n", clase, valor);
            fprintf(archivo, "%d\t\t%d\n", clase, valor);
        }
    }
    
    free(lTokens);
    fclose(archivo);
    
    return 0;
}


/* -------------------------------------------------------------------------- */
/* Funciones Tokens */
/* -------------------------------------------------------------------------- */

void insertToken(int (**lTokens)[2], int *numTokens, int class, int val_pos, char *simbolo){
    int newlenght = *numTokens + 1; //añade 1
    int (*tmp)[2] = realloc(*lTokens, sizeof(double[newlenght][2])); //lista temporal para re-alocar memoria

    if (tmp){   //si re-aloco correctamente 
        //poniendo en la ultima
        tmp[*numTokens][0]= class;
        tmp[*numTokens][1]= tokenizeValue(class,val_pos,simbolo);

        *lTokens = tmp; //actualiza la lista de tokens
        *numTokens = newlenght; //actualiza el tamaño de la lista de tokens
    }
    return;
}

int tokenizeValue(int class, int val_pos, char *str){
    /*
    Notas:
        Esta funcion devuelve el valor del token

        Para las clases 1,2,3,7 y 9 se busca el valor del token en su catalogo correspondiente
        usando el indice de este. Para ello se usa strcmp.
        Notese que strcmp devuelve 0 si las cadenas son iguales

        Para las clases 0 y 6, se asigna a su equivalente en ASCII
        Si no encuentra la clase dentro de las opciones, 
        se asume que es parte de la clase 0 o 6

        Para las clases 3,5 y 8 se obtiene el valor a partir de la tabla
        de literales o de simbolos, indicado como 'valor_pos'

    - Roman
    */
    int valor = -1;
    int n;

    switch(class) {
        case 1:             // Operadores logicos
            for(n=0; n<(size_cat_OpLog); n++){
                if (!(strcmp(str,cat_OpLog[n]))){ 
                    valor = n;
                    break;
                }
            }
            break;
        case 2:             // Operadores relacionales
            for(n=0; n<(size_cat_OpRel); n++){
                if (!(strcmp(str,cat_OpRel[n]))){
                    valor = n;
                    break;
                }
            }
            break;
        case 3:             // Constantes enteras
            valor = val_pos;
            break;
        case 4:            // Palabras reservadas
            for(n=0; n<(size_cat_PalRes); n++){
                if (!(strcmp(str,cat_PalRes[n]))){
                    valor = n;
                    break;
                }
            }
            break;
        case 5:             // Identificadores
            valor = val_pos;
            break;

        case 7:             // Operadores de asignacion
            for(n=0; n<(size_cat_OpAsig); n++){
                if (!(strcmp(str,cat_OpAsig[n]))){
                    valor = n;
                    break;
                }
            }
            break;
        case 8:             // Constantes cadenas
            valor = val_pos;
            break;
        case 9:             // Operadores sobre cadenas
            for(n=0; n<(size_cat_OpCad); n++){
                if (!(strcmp(str,cat_OpCad[n]))){
                    valor = n;
                    break;
                }
            }
            break;
        default:
            // Asumiendo que sea un operador aritmetico o simbolo especial
            for(n=0; n<(size_cat_SimASCII); n++){
                if (str[0] == cat_Simbolos[n]){
                    valor = cat_ASCII[n];
                    break;
                }
            }
    }
    return valor;
}


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


